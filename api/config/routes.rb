# frozen_string_literal: true

# @see https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  namespace :v1 do
    resources :species, only: [] do
      get 'locations', on: :collection, to: 'species#locations_by_name'
    end

    resources :locations, only: [] do
      get 'species', on: :collection, to: 'locations#species_by_coordinates'
    end
  end
end
