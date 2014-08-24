require 'open-uri'
require 'nokogiri'
require 'yaml'

BYPASS_CACHE=false

database_file = ".fdstalker.yml"
html_template_file = "fdstalk2_template.html"
output_file = "stalked.html"
user_stats_url_prefix = "http://forums.frontier.co.uk/member.php?u="
user_posts_url_prefix = "http://forums.frontier.co.uk/search.php?do=finduser&u="

#ids = [2,6,7,14349,14849]
ids = [2,6,7,14349,14849,15645,15655,17666,22712,24222,25094,25095,26549,26755,26966,27895,31252,31348,31484,32310,32348,32574]

posts = {}

begin
  persistent_data = YAML::load_file(database_file)
rescue
  persistent_data = false
end

unless persistent_data
  persistent_data = {}
  ids.each { |id| persistent_data[id] = 0 }
  File.open(database_file, 'w') {|f| f.write persistent_data.to_yaml }
end

ids.each do |id|
  puts "Checking ID #{id}"
  doc = Nokogiri::HTML(open(user_stats_url_prefix + id.to_s))
  
  post_count_label = doc.at('span:contains("Total Posts")')
  if post_count_label
    current_post_count = post_count_label.parent.children.last.text.to_i
    puts "Post count for user #{id} is #{current_post_count}"

    last_post_count = persistent_data[id].to_i
    puts "Last post count is #{last_post_count}"
    
    if current_post_count > last_post_count || BYPASS_CACHE
      puts "They've made a new post!"
      
      doc = Nokogiri::HTML(open(user_posts_url_prefix + id.to_s))
      threads_list_element = doc.css("table#threadslist")[0]
      if threads_list_element
        
        while threads_list_element = threads_list_element.next_sibling
          if threads_list_element.attributes["id"] && threads_list_element.attributes["id"].text =~ /post(\d+)/
            # Its a snippet, so grab the HTML
            post_id = threads_list_element.attributes["id"].text.match(/post(\d+)/)[1].to_i
            # Collect the data
            posts[post_id] = threads_list_element.to_s
            puts "Added post id #{post_id} (#{post_id.class})"
          end
        end
      end
      
      # end of new posts loop
      persistent_data[id] = current_post_count
    else
      puts "No new posts from them!"
    end
  end
  sleep 1
end

# Sort and concat
all_posts_html = ""
posts.keys.sort.reverse.each do |post_id|
  html = posts[post_id]
  all_posts_html << html + "\n"
end

# Write out
template = File.open(html_template_file).read
output = template.gsub(/___INSERT_POSTS_HERE___/, all_posts_html)
File.open(output_file, 'w') {|f| f.write output }

File.open(database_file, 'w') {|f| f.write persistent_data.to_yaml }
