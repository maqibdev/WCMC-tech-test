require 'rails_helper'

RSpec.describe V1::LocationsController, type: :controller do
  describe 'GET #species_by_coordinates' do
    let(:location) { create(:location, latitude: 15.5, longitude: 30.0) }
    let(:species) { create(:species) }
    let!(:species_location) { create(:species_location, species: species, location: location) }

    context 'when valid coordinates are provided' do
      before do
        get :species_by_coordinates, params: { latitude: location.latitude, longitude: location.longitude }
      end

      it 'returns the correct species' do
        expect(response).to have_http_status(:ok)
        species_data = JSON.parse(response.body)
        expect(species_data.size).to eq(1)
        expect(species_data.first['scientific_name']).to eq(species.scientific_name)
      end
    end

    context 'when location is not found' do
      before do
        get :species_by_coordinates, params: { latitude: 99.9, longitude: 99.9 }
      end

      it 'returns an error message' do
        expect(response).to have_http_status(:not_found)
        error_data = JSON.parse(response.body)
        expect(error_data['error']).to eq('Location not found')
      end
    end

    context 'when required parameters are missing' do
      before do
        get :species_by_coordinates, params: {}
      end

      it 'returns an error message' do
        expect(response).to have_http_status(:bad_request)
        error_data = JSON.parse(response.body)
        expect(error_data['error']).to include('Missing parameter')
      end
    end
  end
end
