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

ActiveRecord::Schema.define(version: 2019_05_31_160221) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "balances", force: :cascade do |t|
    t.string "client", null: false
    t.string "project", null: false
    t.date "date", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "editable", default: true
    t.string "balance_type", default: "standard", null: false
  end

  create_table "coaching_sessions", force: :cascade do |t|
    t.bigint "balance_id"
    t.date "date", null: false
    t.string "description", null: false
    t.string "complementary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["balance_id"], name: "index_coaching_sessions_on_balance_id"
  end

  create_table "coaching_sessions_kleerers", id: false, force: :cascade do |t|
    t.bigint "kleerer_id", null: false
    t.bigint "coaching_session_id", null: false
    t.index ["coaching_session_id"], name: "index_coaching_sessions_kleerers_on_coaching_session_id"
    t.index ["kleerer_id"], name: "index_coaching_sessions_kleerers_on_kleerer_id"
  end

  create_table "distributions", force: :cascade do |t|
    t.bigint "balance_id", null: false
    t.bigint "kleerer_id", null: false
    t.decimal "amount", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["balance_id"], name: "index_distributions_on_balance_id"
    t.index ["kleerer_id"], name: "index_distributions_on_kleerer_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.bigint "balance_id"
    t.string "description", null: false
    t.decimal "amount", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["balance_id"], name: "index_expenses_on_balance_id"
  end

  create_table "feature_flags", force: :cascade do |t|
    t.string "feature"
    t.boolean "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "incomes", force: :cascade do |t|
    t.bigint "balance_id"
    t.string "description", null: false
    t.decimal "amount", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["balance_id"], name: "index_incomes_on_balance_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "income_id"
    t.decimal "invoice_id"
    t.decimal "percentage"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["income_id"], name: "index_invoices_on_income_id"
  end

  create_table "kleerers", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "option_id"
    t.index ["option_id"], name: "index_kleerers_on_option_id"
  end

  create_table "options", force: :cascade do |t|
    t.string "name"
    t.decimal "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "percentages", force: :cascade do |t|
    t.bigint "balance_id", null: false
    t.bigint "kleerer_id", null: false
    t.decimal "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["balance_id"], name: "index_percentages_on_balance_id"
    t.index ["kleerer_id"], name: "index_percentages_on_kleerer_id"
  end

  create_table "saldos", force: :cascade do |t|
    t.bigint "balance_id"
    t.bigint "kleerer_id", null: false
    t.decimal "amount", null: false
    t.string "reference", null: false
    t.string "concept", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["balance_id"], name: "index_saldos_on_balance_id"
    t.index ["kleerer_id"], name: "index_saldos_on_kleerer_id"
  end

  create_table "tax_masters", force: :cascade do |t|
    t.string "name"
    t.decimal "value"
    t.string "type_tax"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "taxes", force: :cascade do |t|
    t.bigint "balance_id"
    t.string "name", null: false
    t.decimal "amount", null: false
    t.decimal "percentage", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "invoice_id"
    t.date "invoice_date"
    t.index ["balance_id"], name: "index_taxes_on_balance_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
  end

end
