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

ActiveRecord::Schema[8.1].define(version: 2025_12_18_042914) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "newsletter_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "newsletter_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["newsletter_id", "tag_id"], name: "index_newsletter_tags_on_newsletter_id_and_tag_id", unique: true
    t.index ["newsletter_id"], name: "index_newsletter_tags_on_newsletter_id"
    t.index ["tag_id"], name: "index_newsletter_tags_on_tag_id"
  end

  create_table "newsletters", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "preview_text"
    t.datetime "scheduled_at"
    t.datetime "sent_at"
    t.string "status", default: "draft", null: false
    t.string "subject"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["scheduled_at"], name: "index_newsletters_on_scheduled_at"
    t.index ["status"], name: "index_newsletters_on_status"
    t.index ["user_id", "status"], name: "index_newsletters_on_user_id_and_status"
    t.index ["user_id"], name: "index_newsletters_on_user_id"
  end

  create_table "subscriber_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "subscriber_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["subscriber_id", "tag_id"], name: "index_subscriber_tags_on_subscriber_id_and_tag_id", unique: true
    t.index ["subscriber_id"], name: "index_subscriber_tags_on_subscriber_id"
    t.index ["tag_id"], name: "index_subscriber_tags_on_tag_id"
  end

  create_table "subscribers", force: :cascade do |t|
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "status", default: "pending", null: false
    t.datetime "subscribed_at"
    t.string "unsubscribe_token"
    t.datetime "unsubscribed_at"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["confirmation_token"], name: "index_subscribers_on_confirmation_token", unique: true
    t.index ["status"], name: "index_subscribers_on_status"
    t.index ["unsubscribe_token"], name: "index_subscribers_on_unsubscribe_token", unique: true
    t.index ["user_id", "email"], name: "index_subscribers_on_user_id_and_email", unique: true
    t.index ["user_id"], name: "index_subscribers_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "color", default: "#3b82f6"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "name"], name: "index_tags_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "password_reset_sent_at"
    t.string "password_reset_token"
    t.datetime "remember_created_at"
    t.string "remember_token"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["password_reset_token"], name: "index_users_on_password_reset_token", unique: true
    t.index ["remember_token"], name: "index_users_on_remember_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "newsletter_tags", "newsletters"
  add_foreign_key "newsletter_tags", "tags"
  add_foreign_key "newsletters", "users"
  add_foreign_key "subscriber_tags", "subscribers"
  add_foreign_key "subscriber_tags", "tags"
  add_foreign_key "subscribers", "users"
  add_foreign_key "tags", "users"
end
