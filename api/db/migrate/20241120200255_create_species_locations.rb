class CreateSpeciesLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :species_locations do |t|
      t.references :species, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true

      t.timestamps
    end
  end
end
