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

ActiveRecord::Schema.define(version: 20130519053851) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "boards", force: true do |t|
    t.string   "title"
    t.hstore   "data",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "boards", ["data"], name: "boards_data", using: :gin

  create_table "columns", force: true do |t|
    t.integer  "board_id"
    t.integer  "display",    default: 0
    t.integer  "limit"
    t.boolean  "default",    default: false, null: false
    t.string   "title"
    t.hstore   "criteria",   default: "",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "columns", ["board_id"], name: "index_columns_on_board_id", using: :btree
  add_index "columns", ["criteria"], name: "columns_criteria", using: :gin

  create_table "stories", force: true do |t|
    t.integer  "priority",    default: 0
    t.integer  "column_id"
    t.integer  "swimlane_id"
    t.hstore   "data",        default: "", null: false
    t.hstore   "remote",      default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stories", ["column_id"], name: "index_stories_on_column_id", using: :btree
  add_index "stories", ["data"], name: "stories_data", using: :gin
  add_index "stories", ["remote"], name: "stories_remote", using: :gin

  create_table "swimlanes", force: true do |t|
    t.integer  "board_id"
    t.integer  "ordering",   default: 0
    t.integer  "limit"
    t.boolean  "default",    default: false, null: false
    t.string   "title"
    t.hstore   "criteria",   default: "",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "swimlanes", ["board_id"], name: "index_swimlanes_on_board_id", using: :btree
  add_index "swimlanes", ["criteria"], name: "swimlanes_criteria", using: :gin

end
