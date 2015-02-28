class CreateVirtualFtsPosts < ActiveRecord::Migration
  def up
    execute "CREATE VIRTUAL TABLE fts_posts USING fts4(id, post_id, body);"
  end
  
  def down
    execute "DROP TABLE fts_posts;"
  end
end
