class CreateAuthors < ActiveRecord::Migration
  def change
    create_table :authors do |t|
      t.integer :forum_id
      t.string :name
      t.integer :posts_count
      t.integer :last_forum_post_count, default: 0
      t.timestamps null: false
    end
  end
end
