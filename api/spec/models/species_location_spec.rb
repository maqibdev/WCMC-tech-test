require 'rails_helper'

RSpec.describe SpeciesLocation, type: :model do
  it { should belong_to(:species) }
  it { should belong_to(:location) }

  context 'validations' do
    it 'is valid with valid species and location' do
      species = Species.create!(scientific_name: "Panthera leo", kingdom: "Animalia", phylum: "Chordata")
      location = Location.create!(locality: "Savannah", latitude: 15.5, longitude: 30.0, geodetic_datum: "WGS84")
      species_location = SpeciesLocation.new(species: species, location: location)
      expect(species_location).to be_valid
    end

    it 'is invalid without a species_id' do
      location = Location.create!(locality: "Savannah", latitude: 15.5, longitude: 30.0, geodetic_datum: "WGS84")
      species_location = SpeciesLocation.new(location: location)
      expect(species_location).to_not be_valid
      expect(species_location.errors[:species_id]).to include("can't be blank")
    end

    it 'is invalid without a location_id' do
      species = Species.create!(scientific_name: "Panthera leo", kingdom: "Animalia", phylum: "Chordata")
      species_location = SpeciesLocation.new(species: species)
      expect(species_location).to_not be_valid
      expect(species_location.errors[:location_id]).to include("can't be blank")
    end

    it 'is invalid with a duplicate species_id and location_id combination' do
      species = Species.create!(scientific_name: "Panthera leo", kingdom: "Animalia", phylum: "Chordata")
      location = Location.create!(locality: "Savannah", latitude: 15.5, longitude: 30.0, geodetic_datum: "WGS84")
      SpeciesLocation.create!(species: species, location: location)

      duplicate_species_location = SpeciesLocation.new(species: species, location: location)
      expect(duplicate_species_location).to_not be_valid
      expect(duplicate_species_location.errors[:species_id]).to include("has already been associated with this location")
    end
  end
end
