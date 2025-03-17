<template>
  <div class="py-16 bg-gradient-to-b from-background to-waste2way-teal/5">
    <div class="section-container">
      <div class="mb-12 text-center">
        <h2 class="mb-4 text-3xl font-bold md:text-4xl">Trash Hotspot Map</h2>
        <p class="max-w-2xl mx-auto text-muted-foreground">
          Real-time visualization of waste hotspots in your area
        </p>
      </div>

      <!-- Map container -->
      <div
        class="relative rounded-2xl overflow-hidden shadow-xl h-[500px] mb-8"
      >
        <div
          v-if="isLoading"
          class="absolute inset-0 flex items-center justify-center bg-slate-100"
        >
          <div
            class="w-12 h-12 border-b-2 rounded-full animate-spin border-waste2way-teal"
          ></div>
        </div>

        <TrashHotspotMap
          v-if="geoLocation && !isLoading"
          :hotspot-data="hotspotData"
          :geoLocation="geoLocation"
          :selected-location="selectedLocation"
          @location-selected="handleLocationSelect"
        />

        <!-- Map controls overlay -->
        <div class="absolute z-10 top-4 right-4">
          <div class="relative">
            <button
              class="flex items-center px-4 py-2 space-x-2 text-sm border rounded-lg shadow-md bg-white/90 backdrop-blur-md border-slate-200 text-slate-700"
              @click="filtersOpen = !filtersOpen"
            >
              <Filter class="w-4 h-4" />
              <span>Filter</span>
              <ChevronDown
                :class="[
                  'h-4 w-4 transition-transform',
                  filtersOpen ? 'transform rotate-180' : '',
                ]"
              />
            </button>

            <div
              v-if="filtersOpen"
              class="absolute right-0 z-20 w-48 p-2 mt-2 border rounded-lg shadow-lg bg-white/95 backdrop-blur-md border-slate-200 animate-scale-in"
            >
              <div class="space-y-1">
                <button
                  v-for="filter in filters"
                  :key="filter.id"
                  :class="[
                    'flex items-center w-full py-2 px-3 text-sm rounded-lg transition-colors',
                    activeFilter === filter.id
                      ? 'bg-waste2way-teal/20 text-waste2way-teal'
                      : 'hover:bg-slate-100 text-slate-800',
                  ]"
                  @click="setFilter(filter.id)"
                >
                  <CheckCircle2
                    v-if="activeFilter === filter.id"
                    class="w-4 h-4 mr-2"
                  />
                  <span>{{ filter.label }}</span>
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Map legend -->
        <div
          class="absolute z-10 p-3 border rounded-lg shadow-md bottom-4 left-4 bg-white/90 backdrop-blur-md border-slate-200"
        >
          <p class="mb-2 text-xs font-medium text-slate-800">
            Waste Concentration
          </p>
          <div class="space-y-1.5">
            <div
              v-for="(item, index) in legends"
              :key="index"
              class="flex items-center"
            >
              <div :class="`w-3 h-3 rounded-full ${item.color} mr-2`"></div>
              <span class="text-xs text-slate-700">{{ item.label }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { Filter, ChevronDown, CheckCircle2 } from "lucide-vue-next";
const { get } = useApi();

// State
const hotspotData = ref([]);
const geoLocation = ref(null);
const isLoading = ref(false);
const filtersOpen = ref(false);
const activeFilter = ref("all");
const selectedLocation = ref(null);

// Data
const filters = [
  { id: "all", label: "All Severities" },
  { id: "high", label: "High Concentration" },
  { id: "medium", label: "Medium Concentration" },
  { id: "low", label: "Low Concentration" },
];

const legends = [
  { color: "bg-red-600", label: "Critical (Level 5)" },
  { color: "bg-orange-500", label: "High (Level 4)" },
  { color: "bg-yellow-500", label: "Medium (Level 3)" },
  { color: "bg-green-500", label: "Low (Level 1-2)" },
];

function getGeoLocation() {
  return new Promise((resolve, reject) => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          resolve({
            lat: position.coords.latitude,
            lng: position.coords.longitude,
          });
        },
        (error) => {
          console.error("Error getting geolocation:", error.message);
          reject(error);
        }
      );
    } else {
      console.log("Geolocation is not supported by this browser.");
      reject(new Error("Geolocation not supported"));
    }
  });
}

async function getHotspots() {
  isLoading.value = true;
  try {
    const { data } = await get("/trash/hotspots");
    hotspotData.value = data;

    try {
      geoLocation.value = await getGeoLocation();
    } catch (error) {
      console.error("Failed to get geolocation:", error);
    }
  } catch (error) {
    console.error("Failed to fetch hotspots:", error);
  } finally {
    isLoading.value = false;
  }
}

const setFilter = (id) => {
  activeFilter.value = id;
  filtersOpen.value = false;
};

const handleLocationSelect = (location) => {
  selectedLocation.value = location;
};

onMounted(() => {
  getHotspots();
});
</script>

<style scoped>
.animate-pulse-light {
  animation: pulse 2s infinite;
}

.animate-scale-in {
  animation: scaleIn 0.2s ease-out forwards;
}

@keyframes pulse {
  0% {
    opacity: 0.6;
  }
  50% {
    opacity: 0.8;
  }
  100% {
    opacity: 0.6;
  }
}

@keyframes scaleIn {
  from {
    transform: scale(0.95);
    opacity: 0;
  }
  to {
    transform: scale(1);
    opacity: 1;
  }
}
</style>
