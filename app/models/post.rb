require 'html/sanitizer'

class Post < ActiveRecord::Base
  FTS_ENABLED = false
  
  belongs_to :author, counter_cache: true
  has_one :fts_post
  
  after_commit :create_fts_entry, on: :create
  
  default_scope { order("forum_post_id DESC") }
  
  scope :matches_body, -> (term) { where("body LIKE ?", "%#{term}%")}
  scope :author, -> (author_id) { where author_id: author_id }
  
  
  # Bit ugly, but should be servicable
  def self.find_by_fts_search(term, author_id = nil)
    raise "FTS_ENABLED not enabled" unless FTS_ENABLED
    query = "SELECT * FROM posts WHERE id IN (
        SELECT post_id from fts_posts WHERE body match ?
      )"
    params = [term]
      
    if author_id
      query += " AND posts.author_id = ?"
      params.append(author_id)
    end
    
    query += " ORDER BY forum_post_id DESC LIMIT 30"
    Post.find_by_sql([query] + params)
  end
  
  def clean_old_fts_entries
    sql = ActiveRecord::Base.send(:sanitize_sql_array, ["DELETE FROM fts_posts WHERE post_id = ?", self.id])
    ActiveRecord::Base.connection.execute(sql) 
  end
  
  def create_fts_entry
    return unless FTS_ENABLED
    clean_old_fts_entries
    sanitizer = HTML::FullSanitizer.new
    sanitized_body = sanitizer.sanitize(self.body)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, ["INSERT INTO fts_posts (post_id, body) VALUES (?, ?)", self.id, sanitized_body])
    ActiveRecord::Base.connection.execute(sql) 
  end
  
end
