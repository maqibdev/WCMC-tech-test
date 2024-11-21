module V1
  class LocationsController < ApplicationController
    before_action :set_coordinates, only: [:species_by_coordinates]

    def species_by_coordinates
      location = Location.find_by(longitude: @longitude, latitude: @latitude)

      if location.present?
        render json: location.species
      else
        render json: { error: 'Location not found' }, status: :not_found
      end
    end

    private

    def set_coordinates
      @longitude = params.require(:longitude).to_f.round(2)
      @latitude = params.require(:latitude).to_f.round(2)
    rescue ActionController::ParameterMissing => e
      render json: { error: "Missing parameter: #{e.param}" }, status: :bad_request
    end
  end
end
