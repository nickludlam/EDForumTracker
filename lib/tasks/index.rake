namespace :search do
  desc "HTML strip and index the current posts"
  task :index => :environment do
    Post.all.each do |post|
      post.create_fts_entry
    end
  end
end
