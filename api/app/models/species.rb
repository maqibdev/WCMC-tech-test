class Species < ApplicationRecord
  has_many :species_locations
  has_many :locations, through: :species_locations

  validates :scientific_name, presence: true, uniqueness: true
  validates :kingdom, presence: true
  validates :phylum, presence: true
end
