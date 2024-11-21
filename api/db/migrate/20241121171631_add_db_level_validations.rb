class AddDbLevelValidations < ActiveRecord::Migration[7.0]
  def change
    change_column_null :locations, :locality, false
    change_column_null :locations, :latitude, false
    change_column_null :locations, :longitude, false
    change_column_null :locations, :geodetic_datum, false

    change_column_null :species, :scientific_name, false
    change_column_null :species, :kingdom, false
    change_column_null :species, :phylum, false

    change_column_null :species_locations, :species_id, false
    change_column_null :species_locations, :location_id, false

    add_index :species, :scientific_name, unique: true
    add_index :species_locations, [:species_id, :location_id], unique: true, name: "index_unique_species_location"

    add_check_constraint :locations, 'latitude >= -90 AND latitude <= 90', name: 'check_latitude_range'
    add_check_constraint :locations, 'longitude >= -180 AND longitude <= 180', name: 'check_longitude_range'
    add_check_constraint :locations, 'coordinate_uncertainty >= 0', name: 'check_coordinate_uncertainty_non_negative'
    add_check_constraint :locations, "geodetic_datum IN ('WGS84', 'NAD83', 'ETRS89')", name: 'check_geodetic_datum_valid'
  end
end
