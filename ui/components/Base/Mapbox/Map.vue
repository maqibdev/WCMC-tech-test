<template>
  <div class="ct-map">
    <div ref="map" class="ct-map__container" />
  </div>
</template>

<script>
import Mapbox from 'mapbox-gl'
import axios from 'axios'

export default {
  props: {
    configuration: {
      type: Object,
      default: () => ({})
    }
  },

  data () {
    return {
      loaded: false
    }
  },

  head () {
    return {
      link: [
        {
          rel: 'stylesheet',
          href: 'https://api.mapbox.com/mapbox-gl-js/v2.9.2/mapbox-gl.css'
        }
      ]
    }
  },

  mounted () {
    this.map = new Mapbox.Map({
      container: this.$refs.map,
      ...this.configuration
    })

    this.map.on('load', () => {
      this.loaded = true
      this.map.addSource('arcgis-data', {
        type: 'geojson',
        data: 'https://services3.arcgis.com/fp1tibNcN9mbExhG/arcgis/rest/services/Fiji_Sponges_Algae/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson',
        cluster: true,
        clusterMaxZoom: 14,
        clusterRadius: 50
      })

      this.map.addLayer({
        id: 'clusters',
        source: 'arcgis-data',
        type: 'circle',
        filter: ['has', 'point_count'],
        paint: {
          'circle-color': [
            'step',
            ['get', 'point_count'],
            '#51bbd6',
            100,
            '#f1f075',
            750,
            '#f28cb1'
          ],
          'circle-radius': [
            'step',
            ['get', 'point_count'],
            20,
            100,
            30,
            750,
            40
          ]
        }
      })

      this.map.addLayer({
        id: 'cluster-count',
        type: 'symbol',
        source: 'arcgis-data',
        filter: ['has', 'point_count'],
        layout: {
          'text-field': ['get', 'point_count_abbreviated'],
          'text-font': ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
          'text-size': 12
        }
      })

      this.map.addLayer({
        id: 'markers',
        source: 'arcgis-data',
        type: 'circle',
        filter: ['!', ['has', 'point_count']],
        paint: {
          'circle-color': '#8a11da',
          'circle-radius': 5,
          'circle-stroke-width': 1,
          'circle-stroke-color': '#fff'
        }
      })

      this.map.on('click', 'clusters', (e) => {
        const features = this.map.queryRenderedFeatures(e.point, {
          layers: ['clusters']
        })
        const clusterId = features[0].properties.cluster_id

        this.map.getSource('arcgis-data').getClusterExpansionZoom(
          clusterId,
          (err, zoom) => {
            if (err) { return }
            this.map.easeTo({
              center: features[0].geometry.coordinates,
              zoom
            })
          }
        )
      })

      this.map.on('click', 'markers', (e) => {
        const features = this.map.queryRenderedFeatures(e.point, {
          layers: ['markers']
        })

        const location = features[0]
        const longitude = location.geometry.coordinates[0]
        const latitude = location.geometry.coordinates[1]

        this.displayTooltip(longitude, latitude, location)
      })

      this.map.on('mouseenter', 'clusters', () => {
        this.map.getCanvas().style.cursor = 'pointer'
      })

      this.map.on('mouseleave', 'clusters', () => {
        this.map.getCanvas().style.cursor = ''
      })
    })
  },

  methods: {
    async fetchSpeciesByCoordinates (longitude, latitude) {
      try {
        const response = await axios.get('http://localhost:3000/v1/locations/species', {
          params: { longitude, latitude }
        })

        return response.data
      } catch (error) {
        console.error('Error fetching species:', error)
        return []
      }
    },

    async fetchLocationsBySpecies (speciesName) {
      try {
        const response = await axios.get('http://localhost:3000/v1/species/locations', {
          params: { scientificName: speciesName }
        })

        return response.data
      } catch (error) {
        console.error('Error fetching locations:', error)
        return []
      }
    },

    async displayTooltip (longitude, latitude, location) {
      const speciesList = await this.fetchSpeciesByCoordinates(longitude, latitude)

      const locationName = location.properties.locality || 'Unknown Location'
      let currentSpeciesPage = 1
      let currentLocationsPage = 1

      const popup = new Mapbox.Popup()
        .setLngLat([longitude, latitude])
        .setHTML(
          this.generateTooltip(speciesList, locationName, currentSpeciesPage)
        )
        .addTo(this.map)

      let speciesName = null
      let locations = []

      popup.getElement().addEventListener('click', async (event) => {
        if (event.target.classList.contains('prev')) {
          if (currentSpeciesPage > 1) {
            currentSpeciesPage -= 1
            popup.setHTML(
              this.generateTooltip(speciesList, locationName, currentSpeciesPage)
            )
          }
        } else if (event.target.classList.contains('next')) {
          if (currentSpeciesPage < speciesList.length) {
            currentSpeciesPage += 1
            popup.setHTML(
              this.generateTooltip(speciesList, locationName, currentSpeciesPage)
            )
          }
        } else if (event.target.classList.contains('ct-fetch-locations')) {
          speciesName = event.target.dataset.species
          locations = await this.fetchLocationsBySpecies(speciesName)
          popup.setHTML(
            this.generateLocationsTooltip(speciesName, locations, currentLocationsPage)
          )
        } else if (event.target.classList.contains('prev-locations')) {
          if (currentLocationsPage > 1) {
            currentLocationsPage -= 1
            popup.setHTML(
              this.generateLocationsTooltip(
                speciesName,
                locations,
                currentLocationsPage
              )
            )
          }
        } else if (event.target.classList.contains('next-locations')) {
          if (currentLocationsPage < Math.ceil(locations.length / 4)) {
            currentLocationsPage += 1
            popup.setHTML(
              this.generateLocationsTooltip(
                speciesName,
                locations,
                currentLocationsPage
              )
            )
          }
        }
      })
    },

    generateTooltip (speciesList, locationName, currentPage = 1) {
      const totalPages = speciesList.length

      const species = speciesList[currentPage - 1]

      const speciesHtml = `
        <strong>ID:</strong> ${species.id} <br/>
        <strong>Species Name:</strong> ${species.scientific_name} <br/>
        <strong>Genus:</strong> ${species.genus} <br/>
        <strong>Family:</strong> ${species.family} <br/>
        <strong>Location:</strong> ${locationName} <br/>
        <strong>Scientific Name Authorship:</strong> ${species.scientific_name_authorship} <br/>
        <button class="ct-fetch-locations" data-species="${species.scientific_name}">View other locations</button>
      `

      const paginationHtml = `
        <div class="ct-pagination">
          ${currentPage > 1 ? '<button class="prev">Previous</button>' : ''}
          Page ${currentPage} of ${totalPages}
          ${currentPage < totalPages ? '<button class="next">Next</button>' : ''}
        </div>
      `

      return `${speciesHtml}${paginationHtml}`
    },

    generateLocationsTooltip (speciesName, locations = [], currentPage = 1) {
      const itemsPerPage = 4
      const totalPages = Math.ceil(locations.length / itemsPerPage)

      const startIndex = (currentPage - 1) * itemsPerPage
      const endIndex = startIndex + itemsPerPage
      const paginatedLocations = locations.slice(startIndex, endIndex)

      const locationsHtml = paginatedLocations
        .map(loc => `<li>${loc.locality || 'Unknown Locality'}</li>`)
        .join('')

      const paginationHtml = `
        <div class="ct-pagination">
          ${currentPage > 1 ? '<button class="prev-locations">Previous</button>' : ''}
          Page ${currentPage} of ${totalPages}
          ${currentPage < totalPages ? '<button class="next-locations">Next</button>' : ''}
        </div>
      `

      return `
        <strong>Locations for species: ${speciesName}</strong>
        <ul>${locationsHtml}</ul>
        ${paginationHtml}
      `
    }
  }
}
</script>

<style lang="postcss" scoped>
.ct-map {
  height: 712px;

  &__container {
    @apply h-full;
  }
}

::v-deep .ct-pagination {
  display: flex;
  justify-content: space-between;
  margin-top: 10px;
}

::v-deep .ct-pagination button {
  background-color: #007bff;
  color: #fff;
  border: none;
  padding: 5px 10px;
  cursor: pointer;
  border-radius: 4px;
}

::v-deep .ct-pagination button:hover {
  background-color: #0056b3;
}

::v-deep .ct-pagination button:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

::v-deep .ct-fetch-locations {
  background: none;
  color: #007bff;
  border: none;
  padding: 0;
  cursor: pointer;
  text-decoration: underline;
  font-size: inherit;
}

::v-deep .ct-fetch-locations:hover {
  color: #0056b3;
  text-decoration: none;
}
</style>
