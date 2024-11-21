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

ActiveRecord::Schema[7.0].define(version: 2024_11_21_171631) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "locations", force: :cascade do |t|
    t.string "locality", null: false
    t.decimal "latitude", null: false
    t.decimal "longitude", null: false
    t.string "geodetic_datum", null: false
    t.integer "coordinate_uncertainty"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "coordinate_uncertainty >= 0", name: "check_coordinate_uncertainty_non_negative"
    t.check_constraint "geodetic_datum::text = ANY (ARRAY['WGS84'::character varying, 'NAD83'::character varying, 'ETRS89'::character varying]::text[])", name: "check_geodetic_datum_valid"
    t.check_constraint "latitude >= '-90'::integer::numeric AND latitude <= 90::numeric", name: "check_latitude_range"
    t.check_constraint "longitude >= '-180'::integer::numeric AND longitude <= 180::numeric", name: "check_longitude_range"
  end

  create_table "species", force: :cascade do |t|
    t.string "scientific_name", null: false
    t.string "genus"
    t.string "family"
    t.string "kingdom", null: false
    t.string "phylum", null: false
    t.string "class_name"
    t.string "order_name"
    t.string "scientific_name_authorship"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["scientific_name"], name: "index_species_on_scientific_name", unique: true
  end

  create_table "species_locations", force: :cascade do |t|
    t.bigint "species_id", null: false
    t.bigint "location_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_species_locations_on_location_id"
    t.index ["species_id", "location_id"], name: "index_unique_species_location", unique: true
    t.index ["species_id"], name: "index_species_locations_on_species_id"
  end

  add_foreign_key "species_locations", "locations"
  add_foreign_key "species_locations", "species"
end
