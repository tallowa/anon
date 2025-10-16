# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_15_232252) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.string "domain", null: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "logo_url"
    t.integer "max_users", default: 50
    t.string "email_domain"
    t.index ["domain"], name: "index_companies_on_domain", unique: true
    t.index ["email_domain"], name: "index_companies_on_email_domain"
  end

  create_table "invites", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "invited_by_id", null: false
    t.string "email", null: false
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.boolean "accepted", default: false
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "accepted_by_user_id"
    t.index ["accepted_by_user_id"], name: "index_invites_on_accepted_by_user_id"
    t.index ["company_id"], name: "index_invites_on_company_id"
    t.index ["email"], name: "index_invites_on_email"
    t.index ["invited_by_id"], name: "index_invites_on_invited_by_id"
    t.index ["token"], name: "index_invites_on_token", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "email_hash", null: false
    t.string "password_digest", null: false
    t.string "job_title"
    t.string "department"
    t.boolean "email_verified", default: false
    t.datetime "last_sign_in_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email"
    t.index ["email_hash"], name: "index_users_on_email_hash", unique: true
  end

  create_table "verification_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token", null: false
    t.string "token_type", null: false
    t.datetime "expires_at", null: false
    t.boolean "used", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_verification_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_verification_tokens_on_user_id"
  end

  add_foreign_key "invites", "companies"
  add_foreign_key "invites", "users", column: "invited_by_id"
  add_foreign_key "users", "companies"
  add_foreign_key "verification_tokens", "users"
end
