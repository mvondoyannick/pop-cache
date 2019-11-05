# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_09_17_140239) do

  create_table "abonnements", force: :cascade do |t|
    t.integer "palier_id"
    t.integer "customer_id"
    t.date "date_debut"
    t.date "date_fin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_abonnements_on_customer_id"
    t.index ["palier_id"], name: "index_abonnements_on_palier_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "customer_id"
    t.float "amount"
    t.index ["customer_id"], name: "index_accounts_on_customer_id"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "agents", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "prenom"
    t.string "phone"
    t.integer "role_id"
    t.string "raison"
    t.string "password"
    t.string "authentication_token", limit: 30
    t.index ["authentication_token"], name: "index_agents_on_authentication_token", unique: true
    t.index ["email"], name: "index_agents_on_email", unique: true
    t.index ["reset_password_token"], name: "index_agents_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_agents_on_role_id"
  end

  create_table "answers", force: :cascade do |t|
    t.integer "customer_id"
    t.integer "question_id"
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_answers_on_customer_id"
    t.index ["question_id"], name: "index_answers_on_question_id"
  end

  create_table "awaits", force: :cascade do |t|
    t.string "amount"
    t.integer "customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "end"
    t.boolean "used"
    t.string "hashawait"
    t.string "agent"
    t.index ["customer_id"], name: "index_awaits_on_customer_id"
  end

  create_table "badges", force: :cascade do |t|
    t.integer "customer_id"
    t.boolean "activate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "qrcode"
    t.index ["customer_id"], name: "index_badges_on_customer_id"
  end

  create_table "categorie_services", force: :cascade do |t|
    t.string "name"
    t.string "detail"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cats", force: :cascade do |t|
    t.string "name"
    t.string "detail"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "commissions", force: :cascade do |t|
    t.string "code"
    t.string "amount_brut"
    t.string "amount_commission"
    t.string "commission"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customer_data", force: :cascade do |t|
    t.integer "customer_id"
    t.string "phone"
    t.string "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "customer_ip"
    t.string "device"
    t.string "uuid2"
    t.index ["customer_id"], name: "index_customer_data_on_customer_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "phone"
    t.string "second_name"
    t.string "cni"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "two_fa"
    t.string "perime_two_fa"
    t.string "apikey"
    t.integer "type_id"
    t.string "tokenauthentication"
    t.string "hand"
    t.string "authentication_token", limit: 30
    t.string "sexe"
    t.string "code"
    t.string "ip"
    t.string "pays"
    t.string "device"
    t.index ["authentication_token"], name: "index_customers_on_authentication_token", unique: true
    t.index ["email"], name: "index_customers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_customers_on_reset_password_token", unique: true
    t.index ["type_id"], name: "index_customers_on_type_id"
  end

  create_table "demo_user_accounts", force: :cascade do |t|
    t.integer "demo_user_id"
    t.float "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["demo_user_id"], name: "index_demo_user_accounts_on_demo_user_id"
  end

  create_table "demo_users", force: :cascade do |t|
    t.string "phone"
    t.string "date_debut"
    t.string "date_fin"
    t.integer "request_day"
    t.integer "request_mount"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key"
  end

  create_table "histories", force: :cascade do |t|
    t.integer "customer_id"
    t.float "amount"
    t.string "context"
    t.string "flag"
    t.string "code"
    t.string "region"
    t.string "ip"
    t.float "lat"
    t.float "long"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_histories_on_customer_id"
  end

  create_table "paliers", force: :cascade do |t|
    t.string "amount"
    t.string "max_retrait"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

  create_table "partners", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "second_name"
    t.string "phone"
    t.string "rib"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_partners_on_email", unique: true
    t.index ["reset_password_token"], name: "index_partners_on_reset_password_token", unique: true
  end

  create_table "qrmodels", force: :cascade do |t|
    t.string "context"
    t.string "montant"
    t.string "lat"
    t.string "lon"
    t.string "depart"
    t.string "arrive"
    t.integer "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_id"], name: "index_qrmodels_on_service_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
  end

  create_table "services", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key"
    t.integer "cat_id"
    t.index ["cat_id"], name: "index_services_on_cat_id"
  end

  create_table "sms_passwords", force: :cascade do |t|
    t.integer "customer_id"
    t.string "code"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_sms_passwords_on_customer_id"
  end

  create_table "solution_recharges", force: :cascade do |t|
    t.string "name"
    t.integer "type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "type_recharge_id"
    t.index ["type_id"], name: "index_solution_recharges_on_type_id"
    t.index ["type_recharge_id"], name: "index_solution_recharges_on_type_recharge_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "date"
    t.string "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "context"
    t.string "customer"
    t.string "flag"
    t.string "code"
    t.string "region"
    t.string "ip"
    t.string "lat"
    t.string "long"
    t.string "color"
  end

  create_table "type_recharges", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "types", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "second_name"
    t.string "phone"
    t.string "cni"
    t.string "ville"
    t.string "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "authentication_token", limit: 30
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
  end

  add_foreign_key "abonnements", "customers"
  add_foreign_key "abonnements", "paliers"
  add_foreign_key "accounts", "customers"
  add_foreign_key "accounts", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agents", "roles"
  add_foreign_key "answers", "customers"
  add_foreign_key "answers", "questions"
  add_foreign_key "awaits", "customers"
  add_foreign_key "badges", "customers"
  add_foreign_key "customer_data", "customers"
  add_foreign_key "customers", "types"
  add_foreign_key "demo_user_accounts", "demo_users"
  add_foreign_key "histories", "customers"
  add_foreign_key "qrmodels", "services"
  add_foreign_key "services", "cats"
  add_foreign_key "sms_passwords", "customers"
  add_foreign_key "solution_recharges", "type_recharges"
  add_foreign_key "solution_recharges", "types"
end
