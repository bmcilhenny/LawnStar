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

ActiveRecord::Schema.define(version: 20171208153438) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.bigint "sport_id"
    t.string "opponent"
    t.string "arena"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sport_id"], name: "index_games_on_sport_id"
  end

  create_table "leagues", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "player_games", force: :cascade do |t|
    t.bigint "game_id"
    t.bigint "player_id"
    t.integer "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_player_games_on_game_id"
    t.index ["player_id"], name: "index_player_games_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.bigint "league_id"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.index ["league_id"], name: "index_players_on_league_id"
  end

  create_table "sports", force: :cascade do |t|
    t.string "name"
    t.string "rules"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "games", "sports"
  add_foreign_key "player_games", "games"
  add_foreign_key "player_games", "players"
  add_foreign_key "players", "leagues"
end
