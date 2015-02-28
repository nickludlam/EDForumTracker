# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150228134707) do

  create_table "authors", force: true do |t|
    t.integer  "forum_id"
    t.string   "name"
    t.integer  "posts_count"
    t.integer  "last_forum_post_count", default: 0
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

# Could not dump table "fts_posts" because of following NoMethodError
#   undefined method `[]' for nil:NilClass

# Could not dump table "fts_posts_content" because of following NoMethodError
#   undefined method `[]' for nil:NilClass

  create_table "fts_posts_docsize", primary_key: "docid", force: true do |t|
    t.binary "size"
  end

  create_table "fts_posts_segdir", primary_key: "level", force: true do |t|
    t.integer "idx"
    t.integer "start_block"
    t.integer "leaves_end_block"
    t.integer "end_block"
    t.binary  "root"
  end

  add_index "fts_posts_segdir", ["level", "idx"], name: "sqlite_autoindex_fts_posts_segdir_1", unique: true

  create_table "fts_posts_segments", primary_key: "blockid", force: true do |t|
    t.binary "block"
  end

  create_table "fts_posts_stat", force: true do |t|
    t.binary "value"
  end

  create_table "posts", force: true do |t|
    t.integer  "author_id"
    t.integer  "forum_post_id"
    t.text     "body"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "posts", ["author_id", "forum_post_id"], name: "index_posts_on_author_id_and_forum_post_id"

end
