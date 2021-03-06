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

ActiveRecord::Schema.define(:version => 20100429233225) do

  create_table "db_files", :force => true do |t|
    t.binary "data", :limit => 16777215
  end

  create_table "expeditions", :force => true do |t|
    t.string   "name",            :null => false
    t.datetime "target_date",     :null => false
    t.integer  "captain_id",      :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "geo_location_id", :null => false
    t.integer  "sponsor_id"
  end

  add_index "expeditions", ["captain_id"], :name => "index_expeditions_on_captain_id"
  add_index "expeditions", ["sponsor_id"], :name => "index_expeditions_on_sponsor_id"

  create_table "expeditions_teams", :id => false, :force => true do |t|
    t.integer  "expedition_id",   :null => false
    t.integer  "team_id",         :null => false
    t.integer  "geo_location_id"
    t.date     "cleaning_at",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "expeditions_teams", ["expedition_id", "team_id"], :name => "index_expeditions_teams_on_expedition_id_and_team_id"
  add_index "expeditions_teams", ["team_id"], :name => "index_expeditions_teams_on_team_id"

  create_table "facebook_users", :force => true do |t|
    t.string   "facebook_id"
    t.string   "name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "link"
    t.string   "email"
    t.integer  "timezone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "geo_locations", :force => true do |t|
    t.string   "name",                                        :null => false
    t.text     "description"
    t.decimal  "lat",         :precision => 20, :scale => 15, :null => false
    t.decimal  "lng",         :precision => 20, :scale => 15, :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "geo_locations", ["lat"], :name => "index_geo_locations_on_lat"
  add_index "geo_locations", ["lng"], :name => "index_geo_locations_on_lng"

  create_table "logos", :force => true do |t|
    t.string   "content_type"
    t.string   "filename"
    t.integer  "size"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pictures", :force => true do |t|
    t.integer "story_id"
    t.string  "content_type"
    t.string  "filename"
    t.integer "size"
    t.integer "parent_id"
    t.string  "thumbnail"
    t.integer "width"
    t.integer "height"
    t.integer "db_file_id"
  end

  add_index "pictures", ["story_id"], :name => "index_pictures_on_cleaning_event_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sponsors", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "url"
    t.string   "email"
    t.integer  "logo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sponsors", ["name"], :name => "index_sponsors_on_name"

  create_table "stories", :force => true do |t|
    t.integer  "facebook_user_id",                :null => false
    t.text     "blog"
    t.integer  "geo_location_id"
    t.integer  "weight",           :default => 0, :null => false
    t.datetime "cleaning_at",                     :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "expedition_id"
  end

  add_index "stories", ["cleaning_at"], :name => "index_cleaning_events_on_cleaning_at"
  add_index "stories", ["expedition_id"], :name => "index_cleaning_events_on_expedition_id"
  add_index "stories", ["facebook_user_id"], :name => "index_cleaning_events_on_user_id"
  add_index "stories", ["geo_location_id"], :name => "index_cleaning_events_on_geo_location_id"

  create_table "teams", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "motto"
    t.integer  "captain_id", :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "teams", ["captain_id"], :name => "index_teams_on_captain_id"

  create_table "teams_users", :id => false, :force => true do |t|
    t.integer  "team_id",    :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teams_users", ["team_id", "user_id"], :name => "index_teams_users_on_team_id_and_user_id"
  add_index "teams_users", ["user_id"], :name => "index_teams_users_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "password_reset_code",       :limit => 40
    t.boolean  "enabled",                                 :default => true
    t.integer  "preallowed_id"
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "users", ["activation_code"], :name => "index_users_on_activation_code"
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["first_name"], :name => "index_users_on_first_name"
  add_index "users", ["last_name"], :name => "index_users_on_last_name"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["password_reset_code"], :name => "index_users_on_password_reset_code"

end
