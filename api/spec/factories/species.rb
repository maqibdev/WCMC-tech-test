FactoryBot.define do
  factory :species do
    sequence(:scientific_name) { |n| "Species_#{n}" }
    kingdom { "Animalia" }
    phylum { "Chordata" }
  end
end
