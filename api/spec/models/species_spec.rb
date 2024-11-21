require 'rails_helper'

RSpec.describe Species, type: :model do
  it { should have_many(:species_locations) }
  it { should have_many(:locations).through(:species_locations) }

  context 'validations' do
    it 'is valid with valid attributes' do
      species = Species.new(scientific_name: "Panthera leo", kingdom: "Animalia", phylum: "Chordata")
      expect(species).to be_valid
    end

    it 'is invalid without a scientific_name' do
      species = Species.new(kingdom: "Animalia", phylum: "Chordata")
      expect(species).to_not be_valid
      expect(species.errors[:scientific_name]).to include("can't be blank")
    end

    it 'is invalid with a duplicate scientific_name' do
      Species.create!(scientific_name: "Panthera leo", kingdom: "Animalia", phylum: "Chordata")
      species = Species.new(scientific_name: "Panthera leo", kingdom: "Animalia", phylum: "Chordata")
      expect(species).to_not be_valid
      expect(species.errors[:scientific_name]).to include("has already been taken")
    end

    it 'is invalid without a kingdom' do
      species = Species.new(scientific_name: "Panthera leo", phylum: "Chordata")
      expect(species).to_not be_valid
      expect(species.errors[:kingdom]).to include("can't be blank")
    end

    it 'is invalid without a phylum' do
      species = Species.new(scientific_name: "Panthera leo", kingdom: "Animalia")
      expect(species).to_not be_valid
      expect(species.errors[:phylum]).to include("can't be blank")
    end
  end
end
