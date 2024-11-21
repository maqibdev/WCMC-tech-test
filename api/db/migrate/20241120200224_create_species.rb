class CreateSpecies < ActiveRecord::Migration[7.0]
  def change
    create_table :species do |t|
      t.string :scientific_name
      t.string :genus
      t.string :family
      t.string :kingdom
      t.string :phylum
      t.string :class_name
      t.string :order_name
      t.string :scientific_name_authorship

      t.timestamps
    end
  end
end
