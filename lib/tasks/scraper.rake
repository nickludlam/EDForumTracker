namespace :scraper do
  desc "Scrape Elite Dangerous forums"
  task :scrape => :environment do
  
    if ENV['USE_MECHANIZE']
      puts "Using Mechanize to authenticate requests"
      agent = Mechanize.new
      url = "http://forums.frontier.co.uk/forum.php"
      page = agent.get(url)
      form = agent.page.forms.first
      form.vb_login_username = ENV['FORUM_USERNAME']
      form.vb_login_password = ENV['FORUM_PASSWORD']
      auth_results_page = form.submit form.buttons.first
      raise "Authentication failure" unless auth_results_page.body =~ /Thank you for logging in/
    end

    Author.all.each do |author|
      # Have author, pull in posts by hitting the Frontier Forums
      puts "Caching new posts for author with forum id #{author.forum_id}"
      
      if ENV['USE_MECHANIZE']
        author.cache_posts_with_agent(agent, true)
        sleep 2
      else
        author.cache_new_posts(true)
        sleep 5 # Required for the new forum rate limiting system!
      end
      
    end # Author.all.each
  end
end
