require 'csv'

namespace :import do
  desc 'Import species and locations from CSV to their respective models'
  task species_and_locations: :environment do
    csv_file_path = Rails.root.join('lib', 'data', 'Survey_of_algae,_sponges,_and_ascidians,_Fiji,_2007.csv')

    CSV.foreach(csv_file_path, headers: true) do |row|
      location = Location.find_or_create_by!(
        locality: row['locality'],
        latitude: row['decimalLatitude'].to_f.round(2),
        longitude: row['decimalLongitude'].to_f.round(2),
        geodetic_datum: row['geodeticDatum'],
        coordinate_uncertainty: row['coordinateUncertaintyInMeters'].to_i
      )

      species = Species.find_or_create_by!(
        scientific_name: row['scientificName'],
        genus: row['genus'],
        family: row['family'],
        kingdom: row['kingdom'],
        phylum: row['phylum'],
        class_name: row['class'],
        order_name: row['order_'],
        scientific_name_authorship: row['scientificNameAuthorship']
      )

      SpeciesLocation.find_or_create_by!(species: species, location: location)
    end

    puts 'Data imported successfully!'
  end
end
