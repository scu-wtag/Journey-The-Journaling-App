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

ActiveRecord::Schema[8.0].define(version: 2025_10_29_083106) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "completed_tasks", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "task_id"
    t.bigint "assignee_id", null: false
    t.datetime "completed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_completed_tasks_on_assignee_id"
    t.index ["completed_at"], name: "index_completed_tasks_on_completed_at"
    t.index ["task_id"], name: "index_completed_tasks_on_task_id_partial", unique: true, where: "(task_id IS NOT NULL)"
    t.index ["team_id", "assignee_id"], name: "index_completed_tasks_on_team_id_and_assignee_id"
    t.index ["team_id"], name: "index_completed_tasks_on_team_id"
  end

  create_table "journal_entries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.date "entry_date", null: false
    t.time "time_from"
    t.time "time_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "entry_date"], name: "index_journal_entries_on_user_id_and_entry_date"
    t.index ["user_id"], name: "index_journal_entries_on_user_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "team_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role"], name: "index_memberships_on_role"
    t.index ["team_id"], name: "index_memberships_on_team_id"
    t.index ["user_id", "team_id"], name: "index_memberships_on_user_id_and_team_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "phone_country_code"
    t.string "phone_local"
    t.string "phone"
    t.date "birthday"
    t.string "country"
    t.string "headquarters"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "journal_entry_id"
    t.bigint "creator_id", null: false
    t.bigint "assignee_id"
    t.string "title", null: false
    t.text "notes"
    t.integer "status", default: 0, null: false
    t.date "due_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["due_on"], name: "index_tasks_on_due_on"
    t.index ["journal_entry_id"], name: "index_tasks_on_journal_entry_id"
    t.index ["status"], name: "index_tasks_on_status"
    t.index ["team_id"], name: "index_tasks_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_teams_on_name"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", null: false
    t.string "encrypted_password", limit: 128, null: false
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.string "name"
    t.integer "role", default: 1, null: false
    t.integer "last_team_id"
    t.string "first_name"
    t.string "last_name"
    t.string "locale", default: "en", null: false
    t.string "theme", default: "light", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["last_team_id"], name: "index_users_on_last_team_id"
    t.index ["locale"], name: "index_users_on_locale"
    t.index ["remember_token"], name: "index_users_on_remember_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["theme"], name: "index_users_on_theme"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "completed_tasks", "tasks", on_delete: :nullify
  add_foreign_key "completed_tasks", "teams"
  add_foreign_key "completed_tasks", "users", column: "assignee_id"
  add_foreign_key "journal_entries", "users"
  add_foreign_key "memberships", "teams"
  add_foreign_key "memberships", "users"
  add_foreign_key "profiles", "users"
  add_foreign_key "tasks", "journal_entries"
  add_foreign_key "tasks", "teams"
  add_foreign_key "tasks", "users", column: "assignee_id"
  add_foreign_key "tasks", "users", column: "creator_id"
end
