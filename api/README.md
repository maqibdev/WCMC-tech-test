# WCMC Tech Test

## Rake Tasks

### Import Data from CSV to DB

To import species and location data into the database from a CSV file, run the following command:
```
sudo docker exec -it wcmc-tech-test-main-api-1 bin/rails import:species_and_locations
```

---

## API Endpoints

### Location Endpoint

This endpoint fetches species found at a given location. It is used to update the tooltip.
```
GET /locations/species?longitude=<longitude>&latitude=<latitude>
```

### Species Endpoint

This endpoint fetches all locations where a specific species is found, based on the scientific name of the species. It is used inside the tooltip with an additional button to view other locations where the species can be found.
```
GET /species/locations_by_name?scientificName=<species-scientific-name>
```

---

## Unit Tests

To run unit tests for the project, use the following command:
```
sudo docker exec -it wcmc-tech-test-main-api-1 bundle exec rspec
```