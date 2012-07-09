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

ActiveRecord::Schema.define(:version => 20120705222429) do

  create_table "acl_rules", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "group"
    t.string   "accessible_type"
    t.string   "accessible_identifier"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "acl_rules", ["accessible_type"], :name => "index_acl_rules_on_accessible_type"
  add_index "acl_rules", ["group"], :name => "index_acl_rules_on_group"
  add_index "acl_rules", ["name"], :name => "index_acl_rules_on_name"

  create_table "commands", :force => true do |t|
    t.string   "name"
    t.text     "command"
    t.text     "sudo_block"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "environments", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "log_entries", :force => true do |t|
    t.string   "event_type"
    t.integer  "result"
    t.text     "log_text"
    t.integer  "command_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "log_entries", ["command_id"], :name => "index_log_entries_on_command_id"
  add_index "log_entries", ["user_id"], :name => "index_log_entries_on_user_id"

  create_table "servers", :force => true do |t|
    t.string   "name"
    t.string   "role"
    t.text     "description"
    t.string   "datacenter"
    t.integer  "status"
    t.string   "pub_ip"
    t.string   "priv_ip"
    t.string   "fqdn"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.string   "single_access_token"
    t.string   "perishable_token"
    t.string   "oauth_token"
    t.string   "oauth_token_secret"
    t.string   "last_login_ip"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

end
