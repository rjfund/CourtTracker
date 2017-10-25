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

ActiveRecord::Schema.define(version: 20171025171521) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "case_types", force: :cascade do |t|
    t.string "title"
  end

  create_table "cases", force: :cascade do |t|
    t.string   "uid"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "title"
    t.integer  "user_id"
    t.integer  "case_type_id"
    t.index ["case_type_id"], name: "index_cases_on_case_type_id", using: :btree
    t.index ["user_id"], name: "index_cases_on_user_id", using: :btree
  end

  create_table "documents", force: :cascade do |t|
    t.date     "date"
    t.string   "title"
    t.string   "filed_by"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "case_id"
    t.boolean  "needs_email", default: false
    t.index ["case_id"], name: "index_documents_on_case_id", using: :btree
  end

  create_table "hearings", force: :cascade do |t|
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "case_id"
    t.string   "title"
    t.datetime "time"
    t.boolean  "needs_email", default: false
    t.string   "location"
    t.index ["case_id"], name: "index_hearings_on_case_id", using: :btree
  end

  create_table "invite_codes", force: :cascade do |t|
    t.bigint   "code"
    t.boolean  "used",       default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "voice_messages", force: :cascade do |t|
    t.text     "url"
    t.integer  "user_id"
    t.boolean  "is_new"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_voice_messages_on_user_id", using: :btree
  end

  add_foreign_key "cases", "case_types"
  add_foreign_key "cases", "users"
  add_foreign_key "documents", "cases"
  add_foreign_key "hearings", "cases"
  add_foreign_key "voice_messages", "users"
end
