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

ActiveRecord::Schema.define(version: 20161130170705) do

  create_table "bingo_cards", force: :cascade do |t|
    t.integer  "room_id"
    t.integer  "user_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "numbers",    default: ""
    t.string   "checks"
  end

  create_table "bingo_users", force: :cascade do |t|
    t.integer  "room_id"
    t.integer  "user_id"
    t.integer  "times"
    t.integer  "seconds"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bootsy_image_galleries", force: :cascade do |t|
    t.string   "bootsy_resource_type"
    t.integer  "bootsy_resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bootsy_images", force: :cascade do |t|
    t.string   "image_file"
    t.integer  "image_gallery_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "card_numbers", force: :cascade do |t|
    t.integer  "bingo_card_id"
    t.integer  "number"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "isChecked",     default: false
  end

  create_table "communities", force: :cascade do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.text     "detail",     default: ""
  end

  create_table "community_administrators", force: :cascade do |t|
    t.integer  "community_id"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "community_user_lists", force: :cascade do |t|
    t.integer  "community_id"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "items", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "rarity"
    t.boolean  "AllowUseDuringGame"
    t.float    "effect",             default: 0.0
    t.boolean  "is_select_number",   default: false
    t.integer  "type",               default: 0
  end

  create_table "room_numbers", force: :cascade do |t|
    t.integer  "room_id"
    t.integer  "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "room_user_lists", force: :cascade do |t|
    t.integer  "room_id"
    t.integer  "user_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "got_item_pre_game",   default: false
    t.boolean  "got_item_after_game", default: false
  end

  create_table "rooms", force: :cascade do |t|
    t.string   "name"
    t.integer  "community_id"
    t.boolean  "isPlaying",           default: false, null: false
    t.boolean  "isFinished",          default: false, null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "canUseItem",          default: false
    t.string   "rates"
    t.boolean  "AllowGuest",          default: false
    t.text     "detail",              default: ""
    t.         "bingo_score",         default: "0.0"
    t.         "riichi_score",        default: "0.5"
    t.         "hole_score",          default: "0.2"
    t.boolean  "AllowJoinDuringGame", default: true
    t.integer  "user_id"
    t.integer  "profit",              default: 0
  end

  create_table "user_item_lists", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "community_id"
    t.integer  "item_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "quantity",     default: 0
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",          null: false
    t.string   "encrypted_password",     default: "",          null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,           null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "name",                   default: "anonymous"
    t.boolean  "isGuest",                default: false
    t.text     "detail",                 default: ""
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
