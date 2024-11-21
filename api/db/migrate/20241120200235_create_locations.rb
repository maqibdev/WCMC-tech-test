class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.string :locality
      t.decimal :latitude
      t.decimal :longitude
      t.string :geodetic_datum
      t.integer :coordinate_uncertainty

      t.timestamps
    end
  end
end
