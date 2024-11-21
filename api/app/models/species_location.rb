class SpeciesLocation < ApplicationRecord
  belongs_to :species
  belongs_to :location


  validates :species_id, presence: true
  validates :location_id, presence: true
  validates :species_id, uniqueness: { scope: :location_id, message: "has already been associated with this location" }
end
