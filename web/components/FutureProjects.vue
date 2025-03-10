<template>
  <div class="py-16">
    <div class="section-container">
      <div class="text-center mb-12">
        <h2 class="text-3xl md:text-4xl font-bold mb-4">
          Future Infrastructure Planning
        </h2>
        <p class="text-muted-foreground max-w-2xl mx-auto">
          Visualize the future of urban infrastructure built with recycled
          plastic waste.
        </p>
      </div>

      <!-- Project Tabs -->
      <div class="mb-10 flex justify-center">
        <div
          class="inline-flex p-1 glass-card dark:glass-card-dark rounded-full"
        >
          <button
            v-for="tab in Object.keys(tabData)"
            :key="tab"
            :class="[
              'px-5 py-2 text-sm font-medium rounded-full transition-all',
              selectedTab === tab
                ? 'bg-waste2way-teal text-white shadow-md'
                : 'hover:bg-white/10',
            ]"
            @click="selectedTab = tab"
          >
            {{ tab.charAt(0).toUpperCase() + tab.slice(1) }}
          </button>
        </div>
      </div>

      <!-- Project Details -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-10 items-center">
        <div
          class="glass-card dark:glass-card-dark p-6 rounded-2xl order-2 md:order-1"
        >
          <h3 class="text-2xl font-bold mb-3">{{ currentTabData.title }}</h3>
          <p class="text-muted-foreground mb-6">
            {{ currentTabData.description }}
          </p>

          <div class="grid grid-cols-3 gap-4 mb-6">
            <div
              v-for="(stat, index) in currentTabData.stats"
              :key="index"
              class="p-3 bg-white/5 rounded-xl text-center"
            >
              <p class="text-2xl font-bold mb-1">{{ stat.value }}</p>
              <p class="text-xs text-muted-foreground">{{ stat.label }}</p>
            </div>
          </div>

          <div class="mb-6">
            <h4 class="font-medium mb-3">Key Benefits</h4>
            <ul class="space-y-2">
              <li
                v-for="(benefit, index) in currentTabData.benefits"
                :key="index"
                class="flex"
              >
                <CheckCircle
                  class="h-5 w-5 text-waste2way-green mr-2 flex-shrink-0"
                />
                <span>{{ benefit }}</span>
              </li>
            </ul>
          </div>

          <div class="mt-6 flex space-x-4">
            <button class="btn-primary">
              View Projects <MapPin class="ml-2 h-4 w-4 inline" />
            </button>
            <button class="btn-secondary">
              Impact Report <TrendingUp class="ml-2 h-4 w-4 inline" />
            </button>
          </div>
        </div>

        <div class="order-1 md:order-2">
          <div class="relative rounded-2xl overflow-hidden h-80 shadow-xl">
            <img
              :src="currentTabData.image"
              :alt="currentTabData.title"
              class="w-full h-full object-cover"
            />
            <div
              class="absolute inset-0 bg-gradient-to-t from-waste2way-dark to-transparent opacity-60"
            ></div>
            <div class="absolute bottom-0 left-0 right-0 p-6">
              <h4 class="text-white text-xl font-bold">
                {{ currentTabData.title }}
              </h4>
              <button
                class="mt-3 bg-white/10 hover:bg-white/20 backdrop-blur-sm text-white px-4 py-2 rounded-full text-sm flex items-center transition-colors"
              >
                View 3D Model <ArrowRight class="ml-2 h-4 w-4" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Implementation Map Preview -->
      <div class="mt-16 glass-card dark:glass-card-dark p-6 rounded-2xl">
        <!-- Map content same as React version -->
        <div class="flex justify-between items-center mb-6">
          <h3 class="text-xl font-medium">Implementation Priority Map</h3>
          <button
            class="text-waste2way-blue text-sm flex items-center hover:underline"
          >
            Full Map View <ArrowRight class="ml-1 h-4 w-4" />
          </button>
        </div>

        <div class="relative rounded-xl overflow-hidden h-64 bg-slate-100">
          <div
            class="w-full h-full opacity-70 bg-[url('https://www.transparenttextures.com/patterns/cartographer.png')]"
          ></div>

          <!-- Priority Zones -->
          <div
            class="absolute top-1/4 left-1/4 w-16 h-16 rounded-full bg-red-500/30 animate-pulse-light"
          >
            <div
              class="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 rounded-full w-6 h-6 bg-red-500"
            >
              <MapPin
                class="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 text-white"
                :size="12"
              />
            </div>
          </div>

          <!-- Additional map elements same as React version -->

          <div
            class="absolute inset-0 bg-gradient-to-t from-slate-200/50 to-transparent pointer-events-none"
          ></div>
        </div>

        <!-- Legend -->
        <div class="mt-4 flex items-center justify-center space-x-8">
          <div class="flex items-center">
            <div class="w-3 h-3 rounded-full bg-red-500 mr-2"></div>
            <span class="text-xs">High Priority</span>
          </div>
          <div class="flex items-center">
            <div class="w-3 h-3 rounded-full bg-yellow-500 mr-2"></div>
            <span class="text-xs">Medium Priority</span>
          </div>
          <div class="flex items-center">
            <div class="w-3 h-3 rounded-full bg-green-500 mr-2"></div>
            <span class="text-xs">Low Priority</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from "vue";
import { MapPin, TrendingUp, CheckCircle, ArrowRight } from "lucide-vue-next";

const selectedTab = ref("roads");

const tabData = {
  roads: {
    title: "Plastic Roads",
    description:
      "Roads built with plastic waste are more durable, weather-resistant, and reduce the carbon footprint of traditional asphalt.",
    stats: [
      { label: "Durability", value: "+45%" },
      { label: "Cost Efficiency", value: "+30%" },
      { label: "CO₂ Reduction", value: "-32%" },
    ],
    benefits: [
      "Reduced maintenance frequency",
      "Water-resistant surface",
      "Lower greenhouse gas emissions",
      "Utilizes up to 8 tons of plastic per km",
    ],
    image:
      "https://images.unsplash.com/photo-1515630771457-09367d0ae68e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80",
  },
  pavements: {
    // ...same data as React version
  },
  furniture: {
    // ...same data as React version
  },
};

const currentTabData = computed(() => tabData[selectedTab.value]);
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
</style>
