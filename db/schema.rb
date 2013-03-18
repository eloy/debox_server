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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 201303031950) do

  create_table "apps", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "apps", ["name"], :name => "index_apps_on_name"

  create_table "jobs", :force => true do |t|
    t.integer  "recipe_id"
    t.string   "task"
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "success"
    t.text     "log"
    t.text     "error"
    t.text     "config"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "jobs", ["recipe_id"], :name => "index_jobs_on_recipe_id"

  create_table "recipes", :force => true do |t|
    t.integer  "app_id"
    t.string   "name"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "recipes", ["app_id"], :name => "index_recipes_on_app_id"
  add_index "recipes", ["name"], :name => "index_recipes_on_name"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password"
    t.string   "api_key"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.boolean  "admin",                           :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token"

end
