class Post < ActiveRecord::Base
  belongs_to :author, counter_cache: true
end
