<template>
  <div class="ct-map">
    <div ref="map" class="ct-map__container" />
  </div>
</template>

<script>
import Mapbox from 'mapbox-gl'

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

  methods: {
    generateTooltip (speciesList, locationName, currentPage = 1) {
      const totalPages = speciesList.length

      const species = speciesList[currentPage - 1]

      const speciesHtml = `
        <strong>ID:</strong> ${species.id} <br />
        <strong>Species Name:</strong> ${species.scientificName} <br />
        <strong>Genus:</strong> ${species.genus} <br />
        <strong>Family:</strong> ${species.family} <br />
        <strong>Country:</strong> ${species.country} <br />
        <strong>WaterBody:</strong> ${species.waterBody} <br />
        <strong>Location:</strong> ${locationName}
        <strong>Scientific Name Authorship:</strong> ${species.scientificNameAuthorship}
      `

      const paginationHtml = `
        <div class='ct-pagination'>
          ${currentPage > 1 ? '<button class="prev">Previous</button>' : ''}
          Page ${currentPage} of ${totalPages}
          ${currentPage < totalPages ? '<button class="next">Next</button>' : ''}
        </div>
      `

      return `
        ${speciesHtml}
        ${paginationHtml}
      `
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
        data: 'https://services3.arcgis.com/fp1tibNcN9mbExhG/arcgis/rest/services/Fiji_Sponges_Algae/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson'
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

      this.map.on('click', 'markers', (e) => {
        const features = this.map.queryRenderedFeatures(e.point, { layers: ['markers'] })

        const speciesList = features.map(feature => ({
          id: feature.properties.id,
          scientificName: feature.properties.scientificName,
          genus: feature.properties.genus,
          family: feature.properties.family,
          country: feature.properties.country,
          waterBody: feature.properties.waterBody,
          scientificNameAuthorship: feature.properties.scientificNameAuthorship
        }))
        const locationName = features[0].properties.locality || 'Unknown Location'

        let currentPage = 1

        const popup = new Mapbox.Popup()
          .setLngLat(features[0].geometry.coordinates.slice())
          .setHTML(this.generateTooltip(speciesList, locationName, currentPage))
          .addTo(this.map)

        popup.getElement().addEventListener('click', (event) => {
          if (event.target.classList.contains('prev')) {
            currentPage -= 1
          } else if (event.target.classList.contains('next')) {
            currentPage += 1
          } else {
            return
          }

          popup.setHTML(this.generateTooltip(speciesList, locationName, currentPage))
        })
      })
    })
  }
}
</script>

<style lang="postcss" scoped>
.ct-map {
  height: 512px;

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
</style>
