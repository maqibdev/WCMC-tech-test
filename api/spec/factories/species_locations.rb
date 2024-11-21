FactoryBot.define do
  factory :species_location do
    association :species
    association :location
  end
end
