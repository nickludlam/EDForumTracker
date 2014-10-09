require 'open-uri'

class Author < ActiveRecord::Base
  has_many :posts, dependent: :delete_all
  validates_uniqueness_of :forum_id
  
  AUTHOR_STATS_URL_PREFIX = "http://forums.frontier.co.uk/member.php?u=%d"
  AUTHOR_POSTS_URL_PREFIX = "http://forums.frontier.co.uk/search.php?do=finduser&u=%d"
  
  def current_forum_post_count
    author_doc = Nokogiri::HTML(open(AUTHOR_STATS_URL_PREFIX % forum_id))
    
    post_count_label = author_doc.at('span:contains("Total Posts")')
    if post_count_label
      current_post_count = post_count_label.parent.children.last.text.to_i
      return current_post_count 
    else
      logger.warn("Failed to find the post count span for author id #{forum_id}")
      return 0
    end
  end
  
  def cache_new_posts(replace_existing=false)
    logger.debug("Starting cache_new_posts")
    posts_doc = Nokogiri::HTML(open(Author::AUTHOR_POSTS_URL_PREFIX % forum_id))
    threads_list_element = posts_doc.css("table#threadslist")[0]
    if threads_list_element
      while threads_list_element = threads_list_element.next_sibling
        if threads_list_element.attributes["id"] && threads_list_element.attributes["id"].text =~ /post(\d+)/
          # Its a snippet, so grab the HTML
          post_id = threads_list_element.attributes["id"].text.match(/post(\d+)/)[1].to_i
          
          # These contain: Replies, Views, Posted by, and the excerpt
          if threads_list_element.css("div.smallfont").count == 4
            post_author_name = threads_list_element.css("div.smallfont")[2].children[1].text
            update_attribute(:name, post_author_name) if name != post_author_name
          end
          
          # We don't want to store posts we've previously fetched, unless we're forcing a replacement
          if Post.where(["author_id = ? AND forum_post_id = ?", forum_id, post_id]).count > 0
            break unless replace_existing
          end
          
          create_normalized_post(post_id, threads_list_element.to_s, replace_existing)
        end
      end
    end
    
    logger.debug("Finished cache_new_posts")
  end
  
  def create_normalized_post(post_id, body, find_existing=false)
    body.gsub!(/src="/, "src=\"http://forums.frontier.co.uk/")
    body.gsub!(/href="/, "href=\"http://forums.frontier.co.uk/")
    
    if find_existing && p = Post.find_by_forum_post_id(post_id)
      p.update_attributes(body: body)
    else
      posts.create(forum_post_id: post_id, body: body)
    end
  end
end
