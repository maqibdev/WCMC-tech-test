class Location < ApplicationRecord
  has_many :species_locations
  has_many :species, through: :species_locations

  validates :locality, presence: true
  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :geodetic_datum, presence: true, inclusion: { in: ['WGS84', 'NAD83', 'ETRS89'], message: "%{value} is not a valid geodetic datum" }
  validates :coordinate_uncertainty, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end
