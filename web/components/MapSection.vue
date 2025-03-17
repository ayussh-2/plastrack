<template>
  <div class="py-16 bg-gradient-to-b from-background to-waste2way-teal/5">
    <div class="section-container">
      <div class="mb-12 text-center">
        <h2 class="mb-4 text-3xl font-bold md:text-4xl">Geospatial Insights</h2>
        <p class="max-w-2xl mx-auto text-muted-foreground">
          Visualize waste hotspots and identify areas for potential
          infrastructure projects.
        </p>
      </div>

      <!-- Map container -->
      <div
        class="relative rounded-2xl overflow-hidden shadow-xl h-[500px] mb-8"
      >
        <!-- Interactive map would be implemented here with an actual mapping library -->
        <div class="absolute inset-0 bg-slate-100">
          <!-- Placeholder map background -->
          <div
            class="w-full h-full opacity-70 bg-[url('https://www.transparenttextures.com/patterns/cartographer.png')]"
          ></div>

          <!-- Sample hotspots on the map -->
          <div
            v-for="hotspot in filteredHotspots"
            :key="hotspot.id"
            :class="[
              'absolute rounded-full animate-pulse-light',
              hotspot.size === 'large'
                ? 'w-24 h-24 bg-red-500/40'
                : hotspot.size === 'medium'
                ? 'w-16 h-16 bg-yellow-500/40'
                : 'w-12 h-12 bg-green-500/40',
            ]"
            :style="{
              left: `${hotspot.lng}%`,
              top: `${hotspot.lat}%`,
              transform: 'translate(-50%, -50%)',
            }"
          >
            <div
              :class="[
                'absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 rounded-full',
                hotspot.size === 'large'
                  ? 'w-8 h-8 bg-red-500'
                  : hotspot.size === 'medium'
                  ? 'w-6 h-6 bg-yellow-500'
                  : 'w-4 h-4 bg-green-500',
              ]"
            >
              <MapPin
                class="absolute text-white transform -translate-x-1/2 -translate-y-1/2 top-1/2 left-1/2"
                :size="hotspot.size === 'large' ? 16 : 12"
              />
            </div>
            <div
              class="absolute mt-1 transform -translate-x-1/2 top-full left-1/2 whitespace-nowrap"
            >
              <span
                class="px-2 py-1 text-xs text-white rounded-full bg-slate-700"
              >
                {{ hotspot.label }}
              </span>
            </div>
          </div>

          <!-- Overlay gradient -->
          <div
            class="absolute inset-0 pointer-events-none bg-gradient-to-t from-slate-200/50 to-transparent"
          ></div>
        </div>

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

      <!-- Stats cards -->
      <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 md:grid-cols-4">
        <StatsCard
          title="Total Waste Locations"
          value="4,287"
          change="12%"
          :positive="true"
          :icon="MapPin"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from "vue";
import { MapPin, Filter, ChevronDown, CheckCircle2 } from "lucide-vue-next";

// State
const activeFilter = ref("all");
const filtersOpen = ref(false);

// Data
const filters = [
  { id: "all", label: "All Waste Types" },
  { id: "pet", label: "PET (Type 1)" },
  { id: "hdpe", label: "HDPE (Type 2)" },
  { id: "pvc", label: "PVC (Type 3)" },
  { id: "ldpe", label: "LDPE (Type 4)" },
];

const hotspots = [
  {
    id: 1,
    lat: 30,
    lng: 45,
    type: "pet",
    size: "large",
    label: "Coastal Region A",
  },
  {
    id: 2,
    lat: 60,
    lng: 20,
    type: "hdpe",
    size: "medium",
    label: "Urban Center B",
  },
  {
    id: 3,
    lat: 45,
    lng: 70,
    type: "pvc",
    size: "small",
    label: "Rural Area C",
  },
  {
    id: 4,
    lat: 20,
    lng: 30,
    type: "ldpe",
    size: "large",
    label: "Industrial Zone D",
  },
  {
    id: 5,
    lat: 70,
    lng: 60,
    type: "pet",
    size: "medium",
    label: "Riverside E",
  },
];

const legends = [
  { color: "bg-red-500", label: "High Concentration" },
  { color: "bg-yellow-500", label: "Medium Concentration" },
  { color: "bg-green-500", label: "Low Concentration" },
];

// Computed properties
const filteredHotspots = computed(() => {
  return hotspots.filter(
    (hotspot) =>
      activeFilter.value === "all" || hotspot.type === activeFilter.value
  );
});

// Methods
const setFilter = (id) => {
  activeFilter.value = id;
  filtersOpen.value = false;
};
</script>

<style scoped>
/* You may need to define these animations */
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
