class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.references :author
      t.integer :forum_post_id
      t.text :body
      t.timestamps null: false
    end
    
    add_index :posts, [:author_id, :forum_post_id]
  end
end
