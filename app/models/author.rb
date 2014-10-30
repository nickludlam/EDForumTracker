require 'open-uri'

class Author < ActiveRecord::Base
  has_many :posts, dependent: :delete_all
  validates_uniqueness_of :forum_id
  default_scope { order('forum_id ASC') }
  
  FORUM_SITE = "http://forums.frontier.co.uk/"
  AUTHOR_STATS_URL = "#{FORUM_SITE}member.php?u=%d"
  AUTHOR_POSTS_URL = "#{FORUM_SITE}search.php?do=finduser&userid=%d&contenttype=vBForum_Post&showposts=1"
  AUTHOR_ACTIVITY_URL = "#{FORUM_SITE}/member.php?u=%d&tab=activitystream&type=user"
  
  def cache_posts_with_agent(agent, replace_existing=false)
    page = agent.get(AUTHOR_ACTIVITY_URL % forum_id)
    activity_doc = Nokogiri::HTML(page.body)
    
    # If they've changed their display name, or we don't yet have it
    post_author_name = activity_doc.css(".lastnavbit span").text
    update_attribute(:name, post_author_name) if name != post_author_name
    
    # Loop through the activity and cache the blocks
    post_elements = activity_doc.css("ul#activitylist li.activitybit")

    logger.debug("Found #{post_elements.count} post elements to traverse")
    if post_elements.count == 0
      logger.warn("Found no posts!")
      logger.warn(page.body)
    else
      post_elements.each do |post|
        thread_link = post.css("div.fulllink a")
        if thread_link
          thread_url = thread_link.attribute("href").text
          
          if post_match = thread_url.match(/post(\d+)/)
            post_id = post_match[1].to_i
          else
            # Thread query
            logger.warn("Found a new thread URL #{thread_url}. Opening...")
            thread_start_doc = Nokogiri::HTML(open(FORUM_SITE + thread_url))
            thread_anchor = thread_start_doc.css("span.nodecontrols a.postcounter")
            thread_url = thread_anchor.attribute("href").text
            
            if post_match = thread_url.match(/post(\d+)/)
              post_id = post_match[1].to_i
            else
              logger.warn("Failed to get URL for thread from #{thread_url}")
              break
            end
          end
        
          if Post.where(["author_id = ? AND forum_post_id = ?", forum_id, post_id]).count > 0
            break unless replace_existing
          end
        
          create_normalized_post(post_id, post.to_s, replace_existing)
        else
          logger.debug("Failed to find the fulllink element")
        end
      end      
    end
  end
  
  def cache_new_posts(replace_existing=false)
    logger.debug("Starting cache_new_posts")
    posts_doc = Nokogiri::HTML(open(Author::AUTHOR_POSTS_URL % forum_id))
    
    post_list_element = posts_doc.css("#searchbits .postbitcontainer")
    logger.error("Found post list count of #{post_list_element.count} for author with forum_id #{forum_id}")
    
    post_list_element.each do |post_li|
      post_id = post_li.attributes["id"].text.match(/post_(\d+)/)[1].to_i
      logger.debug("Evaluating post #{post_id} for author #{forum_id} (#{name})")
      post_author_name = post_li.css("div.username_container a")[1].text
      # Update the stored author name if it doesn't match our records
      update_attribute(:name, post_author_name) if name != post_author_name
      
      if Post.where(["author_id = ? AND forum_post_id = ?", forum_id, post_id]).count > 0
        break unless replace_existing
      end
      
      create_normalized_post(post_id, post_li.to_s, replace_existing)
    end
    
    logger.debug("Finished cache_new_posts")
  end
  
  def create_normalized_post(post_id, body, find_existing=false)
    body.gsub!(/src="/, "src=\"#{FORUM_SITE}")
    body.gsub!(/href="/, "href=\"#{FORUM_SITE}")
    
    if find_existing && p = Post.find_by_forum_post_id(post_id)
      p.update_attributes(body: body)
    else
      posts.create(forum_post_id: post_id, body: body)
    end
  end
end
