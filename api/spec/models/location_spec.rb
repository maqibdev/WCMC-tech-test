require 'rails_helper'

RSpec.describe Location, type: :model do
  subject do
    described_class.new(
      locality: 'Sample Location',
      latitude: 12.345,
      longitude: 67.890,
      geodetic_datum: 'WGS84',
      coordinate_uncertainty: 50
    )
  end

  describe 'associations' do
    it { should have_many(:species_locations) }
    it { should have_many(:species).through(:species_locations) }
  end

  describe 'validations' do
    it { should validate_presence_of(:locality) }

    it do
      should validate_numericality_of(:latitude).is_greater_than_or_equal_to(-90).is_less_than_or_equal_to(90)
    end

    it do
      should validate_numericality_of(:longitude).is_greater_than_or_equal_to(-180).is_less_than_or_equal_to(180)
    end

    it { should validate_presence_of(:geodetic_datum) }

    it 'should validate when geodetic_datum is WGS84' do
      subject.geodetic_datum = 'WGS84'
      expect(subject).to be_valid
    end

    it do
      should validate_numericality_of(:coordinate_uncertainty).only_integer.is_greater_than_or_equal_to(0).allow_nil
    end
  end

  describe 'explicit validation cases' do
    context 'latitude' do
      it 'is valid with a latitude of -90' do
        subject.latitude = -90
        expect(subject).to be_valid
      end

      it 'is invalid with a latitude less than -90' do
        subject.latitude = -91
        expect(subject).to_not be_valid
        expect(subject.errors[:latitude]).to include('must be greater than or equal to -90')
      end

      it 'is valid with a latitude of 90' do
        subject.latitude = 90
        expect(subject).to be_valid
      end

      it 'is invalid with a latitude greater than 90' do
        subject.latitude = 91
        expect(subject).to_not be_valid
        expect(subject.errors[:latitude]).to include('must be less than or equal to 90')
      end
    end

    context 'longitude' do
      it 'is valid with a longitude of -180' do
        subject.longitude = -180
        expect(subject).to be_valid
      end

      it 'is invalid with a longitude less than -180' do
        subject.longitude = -181
        expect(subject).to_not be_valid
        expect(subject.errors[:longitude]).to include('must be greater than or equal to -180')
      end

      it 'is valid with a longitude of 180' do
        subject.longitude = 180
        expect(subject).to be_valid
      end

      it 'is invalid with a longitude greater than 180' do
        subject.longitude = 181
        expect(subject).to_not be_valid
        expect(subject.errors[:longitude]).to include('must be less than or equal to 180')
      end
    end

    context 'geodetic datum' do
      it 'is invalid with an unsupported geodetic datum' do
        subject.geodetic_datum = 'INVALID_DATUM'
        expect(subject).to_not be_valid
        expect(subject.errors[:geodetic_datum]).to include('INVALID_DATUM is not a valid geodetic datum')
      end            
    end
  end
end
