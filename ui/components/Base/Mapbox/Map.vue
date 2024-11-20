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
        const feature = features[0]
        const coordinates = feature.geometry.coordinates.slice()
        const properties = feature.properties

        new Mapbox.Popup().setLngLat(coordinates).setHTML(`
          <strong>ID:</strong> ${properties.id} <br />
          <strong>Species Name:</strong> ${properties.scientificName} <br />
          <strong>Genus:</strong> ${properties.genus} <br />
          <strong>Family:</strong> ${properties.family} <br />
          <strong>Country:</strong> ${properties.country} <br />
          <strong>WaterBody:</strong> ${properties.waterBody} <br />
          <strong>Location:</strong> ${properties.locality || 'Unknown Location'} <br />
          <strong>Scientific Name Authorship:</strong> ${properties.scientificNameAuthorship}
          `)
          .addTo(this.map)
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
</style>
