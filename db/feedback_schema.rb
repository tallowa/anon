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

ActiveRecord::Schema[8.0].define(version: 2025_10_10_200455) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "anonymous_profiles", force: :cascade do |t|
    t.string "profile_hash", null: false
    t.jsonb "cached_summary"
    t.jsonb "cached_themes"
    t.datetime "last_aggregated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_hash"], name: "index_anonymous_profiles_on_profile_hash", unique: true
  end

  create_table "feedback_requests", force: :cascade do |t|
    t.bigint "anonymous_profile_id", null: false
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.jsonb "questions", default: []
    t.boolean "active", default: true
    t.integer "response_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["anonymous_profile_id"], name: "index_feedback_requests_on_anonymous_profile_id"
    t.index ["expires_at"], name: "index_feedback_requests_on_expires_at"
    t.index ["token"], name: "index_feedback_requests_on_token", unique: true
  end

  create_table "feedback_responses", force: :cascade do |t|
    t.bigint "feedback_request_id", null: false
    t.text "content", null: false
    t.jsonb "ratings", default: {}
    t.string "response_hash", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.boolean "flagged", default: false
    t.string "flag_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_feedback_responses_on_created_at"
    t.index ["feedback_request_id"], name: "index_feedback_responses_on_feedback_request_id"
    t.index ["flagged"], name: "index_feedback_responses_on_flagged"
    t.index ["response_hash"], name: "index_feedback_responses_on_response_hash", unique: true
  end

  add_foreign_key "feedback_requests", "anonymous_profiles"
  add_foreign_key "feedback_responses", "feedback_requests"
end
