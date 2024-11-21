require 'rails_helper'

RSpec.describe V1::SpeciesController, type: :controller do
  describe 'GET #locations_by_name' do
    let(:species) { create(:species, scientific_name: 'Panthera leo') }
    let(:location) { create(:location, locality: 'Serengeti') }
    let!(:species_location) { create(:species_location, species: species, location: location) }

    context 'when a valid scientific name is provided' do
      before do
        get :locations_by_name, params: { scientificName: species.scientific_name }
      end

      it 'returns the correct locations' do
        expect(response).to have_http_status(:ok)
        locations = JSON.parse(response.body)
        expect(locations.size).to eq(1)
        expect(locations.first['locality']).to eq(location.locality)
      end
    end

    context 'when species is not found' do
      before do
        get :locations_by_name, params: { scientificName: 'Unknown species' }
      end

      it 'returns an error message' do
        expect(response).to have_http_status(:not_found)
        error_data = JSON.parse(response.body)
        expect(error_data['error']).to eq('Species not found')
      end
    end

    context 'when required parameter is missing' do
      before do
        get :locations_by_name, params: {}
      end

      it 'returns an error message' do
        expect(response).to have_http_status(:bad_request)
        error_data = JSON.parse(response.body)
        expect(error_data['error']).to include('Missing parameter')
      end
    end
  end
end
