<template>
  <div class="py-16 bg-gradient-to-b from-background to-waste2way-teal/5">
    <div class="section-container">
      <div class="text-center mb-12">
        <h2 class="text-3xl md:text-4xl font-bold mb-4">Geospatial Insights</h2>
        <p class="text-muted-foreground max-w-2xl mx-auto">
          Visualize plastic waste hotspots and identify areas for potential
          infrastructure projects.
        </p>
      </div>

      <!-- Map container -->
      <div
        class="relative rounded-2xl overflow-hidden shadow-xl h-[500px] mb-8"
      >
        <div class="absolute inset-0 bg-slate-100">
          <div
            class="w-full h-full opacity-70 bg-[url('https://www.transparenttextures.com/patterns/cartographer.png')]"
          ></div>

          <!-- Sample hotspots on the map -->
          <div
            v-for="hotspot in filteredHotspots"
            :key="hotspot.id"
            :class="[
              'absolute rounded-full animate-pulse-light',
              {
                'w-24 h-24 bg-red-500/40': hotspot.size === 'large',
                'w-16 h-16 bg-yellow-500/40': hotspot.size === 'medium',
                'w-12 h-12 bg-green-500/40': hotspot.size === 'small',
              },
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
                {
                  'w-8 h-8 bg-red-500': hotspot.size === 'large',
                  'w-6 h-6 bg-yellow-500': hotspot.size === 'medium',
                  'w-4 h-4 bg-green-500': hotspot.size === 'small',
                },
              ]"
            >
              <MapPin
                class="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 text-white"
                :size="hotspot.size === 'large' ? 16 : 12"
              />
            </div>
            <div
              class="absolute top-full left-1/2 transform -translate-x-1/2 mt-1 whitespace-nowrap"
            >
              <span
                class="text-xs bg-slate-700 text-white py-1 px-2 rounded-full"
              >
                {{ hotspot.label }}
              </span>
            </div>
          </div>

          <!-- Overlay gradient -->
          <div
            class="absolute inset-0 bg-gradient-to-t from-slate-200/50 to-transparent pointer-events-none"
          ></div>
        </div>

        <!-- Map controls overlay -->
        <div class="absolute top-4 right-4 z-10">
          <div class="relative">
            <button
              class="bg-white/90 backdrop-blur-md border border-slate-200 shadow-md rounded-lg flex items-center space-x-2 py-2 px-4 text-sm text-slate-700"
              @click="filtersOpen = !filtersOpen"
            >
              <Filter class="h-4 w-4" />
              <span>Filter</span>
              <ChevronDown
                :class="[
                  'h-4 w-4 transition-transform',
                  { 'transform rotate-180': filtersOpen },
                ]"
              />
            </button>

            <div
              v-if="filtersOpen"
              class="absolute right-0 mt-2 w-48 bg-white/95 backdrop-blur-md border border-slate-200 p-2 rounded-lg shadow-lg animate-scale-in z-20"
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
                  @click="selectFilter(filter.id)"
                >
                  <CheckCircle2
                    v-if="activeFilter === filter.id"
                    class="h-4 w-4 mr-2"
                  />
                  <span>{{ filter.label }}</span>
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Map legend -->
        <div
          class="absolute bottom-4 left-4 bg-white/90 backdrop-blur-md border border-slate-200 p-3 rounded-lg shadow-md z-10"
        >
          <p class="text-xs font-medium mb-2 text-slate-800">
            Waste Concentration
          </p>
          <div class="space-y-1.5">
            <div
              v-for="(item, index) in legends"
              :key="index"
              class="flex items-center"
            >
              <div :class="['w-3 h-3 rounded-full mr-2', item.color]"></div>
              <span class="text-xs text-slate-700">{{ item.label }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Stats cards -->
      <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-6">
        <StatsCard
          title="Total Waste Locations"
          value="4,287"
          change="12%"
          :icon="MapPin"
        />
        <StatsCard
          title="PET Concentrations"
          value="1,842"
          change="8%"
          :positive="true"
        />
        <StatsCard
          title="HDPE Hotspots"
          value="973"
          change="5%"
          :positive="false"
        />
        <StatsCard
          title="Collection Efficiency"
          value="76%"
          change="3%"
          :positive="true"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from "vue";
import { MapPin, Filter, ChevronDown, CheckCircle2 } from "lucide-vue-next";
import StatsCard from "./ui/StatsCard.vue";

const activeFilter = ref("all");
const filtersOpen = ref(false);

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

const filteredHotspots = computed(() => {
  return hotspots.filter(
    (hotspot) =>
      activeFilter.value === "all" || hotspot.type === activeFilter.value
  );
});

const selectFilter = (filterId: string) => {
  activeFilter.value = filterId;
  filtersOpen.value = false;
};
</script>

<style scoped>
.animate-pulse-light {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

@keyframes pulse {
  0%,
  100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

.animate-scale-in {
  animation: scaleIn 0.2s ease-out;
}

@keyframes scaleIn {
  from {
    opacity: 0;
    transform: scale(0.95);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}
</style>
