FactoryBot.define do
  factory :location do
    locality { "Serengeti" }
    latitude { 15.5 }
    longitude { 30.0 }
    geodetic_datum { "WGS84" }
    coordinate_uncertainty { 0 }
  end
end
