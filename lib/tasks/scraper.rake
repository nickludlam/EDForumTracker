namespace :scraper do
  desc "Scrape Elite Dangerous forums"
  task :scrape => :environment do
    
    Author.all.each do |author|
      # Have author, pull in posts by hitting the Frontier Forums
      current_count = author.current_forum_post_count
      if current_count > author.last_forum_post_count || ENV['FORCE']
        puts "Caching new posts for author with forum id #{author.forum_id}"
        author.cache_new_posts(ENV['FORCE'])
        author.update_attributes(last_forum_post_count: current_count)
      else
        puts "No new posts for author with forum id #{author.forum_id}"
      end
    end # Author.each
  end
  
end
