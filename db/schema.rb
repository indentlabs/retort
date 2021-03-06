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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160517205104) do

  create_table "bigrams", force: :cascade do |t|
    t.string   "prior"
    t.string   "after"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identifier"
    t.string   "medium"
    t.string   "channel"
  end

  add_index "bigrams", ["after"], name: "index_bigrams_on_after"
  add_index "bigrams", ["prior"], name: "index_bigrams_on_prior"

  create_table "retorts", force: :cascade do |t|
    t.string   "stimulus"
    t.string   "response"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
