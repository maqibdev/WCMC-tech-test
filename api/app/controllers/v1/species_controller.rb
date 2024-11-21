module V1
  class SpeciesController < ApplicationController
    before_action :validate_scientific_name, only: [:locations_by_name]
    before_action :set_species, only: [:locations_by_name]

    def locations_by_name
      if @species.present?
        render json: @species.locations
      else
        render json: { error: 'Species not found' }, status: :not_found
      end
    end

    private

    def validate_scientific_name
      @scientific_name = params.require(:scientificName).strip
    rescue ActionController::ParameterMissing => e
      render json: { error: "Missing parameter: #{e.param}" }, status: :bad_request
    end

    def set_species
      @species = Species.find_by(scientific_name: @scientific_name)
    end
  end
end
