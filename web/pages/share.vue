<template>
  <div class="py-16 min-h-screen bg-gradient-to-b from-background to-waste2way-teal/5">
    <div class="section-container">
      <div class="mb-12 text-center">
        <h1 class="mb-4 text-3xl font-bold md:text-4xl">Waste Hotspot Alert</h1>
        <p class="max-w-2xl mx-auto text-muted-foreground">
          This area requires immediate attention from authorities
        </p>
        <div v-if="locationDetails" class="mt-4 p-4 rounded-lg bg-waste2way-teal/10 inline-block">
          <p class="font-semibold">Location: {{ locationDetails.address || 'Unknown location' }}</p>
          
          <!-- Enhanced severity display -->
          <div class="mt-2">
            <p class="text-sm font-medium text-slate-700 mb-1">Severity Assessment:</p>
            <div class="flex items-center justify-center gap-1">
              <div 
                v-for="level in 5" 
                :key="level"
                :class="[
                  'w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold',
                  level <= (locationDetails.severity || 3) 
                    ? getSeverityColorClass(level) 
                    : 'bg-gray-100 text-gray-400'
                ]"
              >
                {{ level }}
              </div>
            </div>
            <div class="flex items-center justify-center gap-6 mt-2">
              <div v-for="(label, index) in severityLabels" :key="'label-'+index" class="flex flex-col items-center">
                <div 
                  class="w-3 h-3 rounded-full"
                  :class="getSeverityDotClass(index+1)"
                ></div>
                <span class="text-xs mt-1 text-slate-600">{{ label }}</span>
              </div>
            </div>
            <p class="text-sm mt-2 font-medium">
              Current level: <span :class="getSeverityClass()">{{ getSeverityText() }}</span>
            </p>
          </div>
        </div>
      </div>

      <!-- Map container -->
      <div class="relative rounded-2xl overflow-hidden shadow-xl h-[500px] mb-8">
        <div
          v-if="isLoading"
          class="absolute inset-0 flex items-center justify-center bg-slate-100"
        >
          <div class="w-12 h-12 border-b-2 rounded-full animate-spin border-waste2way-teal"></div>
        </div>

        <TrashHotspotMap
          v-if="mapReady && !isLoading"
          :hotspot-data="hotspotData"
          :geoLocation="mapLocation"
          :selected-location="selectedHotspot"
          :highlight-point="true"
        />
      </div>

      <!-- Action buttons -->
      <div class="flex flex-col sm:flex-row justify-center gap-4 mb-12">
        <button 
          class="px-6 py-3 rounded-lg bg-waste2way-teal text-white flex items-center justify-center gap-2 hover:bg-waste2way-teal/90 transition-colors"
          @click="shareLocation"
        >
          <Share2 class="w-5 h-5" />
          Share This Location
        </button>
        <button 
          class="px-6 py-3 rounded-lg border border-waste2way-teal text-waste2way-teal flex items-center justify-center gap-2 hover:bg-waste2way-teal/10 transition-colors"
          @click="reportAction"
        >
          <Flag class="w-5 h-5" />
          Report Action Taken
        </button>
      </div>

      <!-- Additional information with enhanced severity display -->
      <div v-if="locationDetails" class="bg-white rounded-lg p-6 shadow-md">
        <h2 class="text-xl font-bold mb-4">Hotspot Details</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <h3 class="text-lg font-semibold mb-2">Location Information</h3>
            <p class="mb-1"><span class="font-medium">Address:</span> {{ locationDetails.address || 'Unknown address' }}</p>
            <p class="mb-1"><span class="font-medium">Coordinates:</span> {{ mapLocation.lat.toFixed(6) }}, {{ mapLocation.lng.toFixed(6) }}</p>
            <p class="mb-1"><span class="font-medium">First reported:</span> {{ locationDetails.reportedAt || 'Recently' }}</p>
          </div>
          <div>
            <h3 class="text-lg font-semibold mb-2">Waste Assessment</h3>
            
            <!-- Enhanced severity display -->
            <div class="mb-3">
              <p class="font-medium">Severity Levels:</p>
              <div class="flex items-center gap-2 mt-1 flex-wrap">
                <div class="flex items-center">
                  <div class="w-4 h-4 rounded-full bg-green-500 mr-1"></div>
                  <span class="text-sm">1-2: Low</span>
                </div>
                <div class="flex items-center">
                  <div class="w-4 h-4 rounded-full bg-yellow-500 mr-1"></div>
                  <span class="text-sm">3: Medium</span>
                </div>
                <div class="flex items-center">
                  <div class="w-4 h-4 rounded-full bg-orange-500 mr-1"></div>
                  <span class="text-sm">4: High</span>
                </div>
                <div class="flex items-center">
                  <div class="w-4 h-4 rounded-full bg-red-600 mr-1"></div>
                  <span class="text-sm">5: Critical</span>
                </div>
              </div>
            </div>
            
            <p class="mb-1">
              <span class="font-medium">Current Severity:</span> 
              <span :class="getSeverityClass()">
                {{ getSeverityText() }} (Level {{ locationDetails.severity || 3 }})
              </span>
            </p>
            
            <!-- Enhanced severity progress bar with level indicators -->
            <div class="relative w-full mt-2 mb-4">
              <div class="w-full bg-gray-200 rounded-full h-2.5">
                <div 
                  class="h-2.5 rounded-full" 
                  :class="getSeverityBarClass()"
                  :style="`width: ${(locationDetails.severity || 3) * 20}%`"
                ></div>
              </div>
              
              <!-- Level indicators -->
              <div class="flex justify-between mt-1">
                <div v-for="level in 5" :key="`indicator-${level}`" class="text-xs text-slate-500">{{ level }}</div>
              </div>
              <!-- Level labels -->
              <div class="flex text-xs text-slate-500 mt-1">
                <div class="w-[40%] text-left">Low</div>
                <div class="w-[20%] text-center">Medium</div>
                <div class="w-[20%] text-center">High</div>
                <div class="w-[20%] text-right">Critical</div>
              </div>
            </div>
            
            <p class="mb-1"><span class="font-medium">Type:</span> {{ locationDetails.wasteType || 'Mixed waste' }}</p>
            <p class="mb-1"><span class="font-medium">Estimated volume:</span> {{ locationDetails.estimatedVolume || 'Unknown' }}</p>
          </div>
        </div>

        <!-- Environmental impact section -->
        <div class="mt-6">
          <h3 class="text-lg font-semibold mb-2">Environmental Impact</h3>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-3">
            <div class="p-3 bg-red-50 border border-red-100 rounded-lg">
              <p class="text-sm font-medium text-red-700">Pollution Risk</p>
              <div class="flex items-center mt-1">
                <div 
                  v-for="dot in 5" 
                  :key="`pollution-${dot}`"
                  class="w-3 h-3 rounded-full mr-1"
                  :class="dot <= getImpactLevel('pollution') ? 'bg-red-500' : 'bg-gray-200'"
                ></div>
              </div>
            </div>
            <div class="p-3 bg-blue-50 border border-blue-100 rounded-lg">
              <p class="text-sm font-medium text-blue-700">Water Impact</p>
              <div class="flex items-center mt-1">
                <div 
                  v-for="dot in 5" 
                  :key="`water-${dot}`"
                  class="w-3 h-3 rounded-full mr-1"
                  :class="dot <= getImpactLevel('water') ? 'bg-blue-500' : 'bg-gray-200'"
                ></div>
              </div>
            </div>
            <div class="p-3 bg-amber-50 border border-amber-100 rounded-lg">
              <p class="text-sm font-medium text-amber-700">Wildlife Risk</p>
              <div class="flex items-center mt-1">
                <div 
                  v-for="dot in 5" 
                  :key="`wildlife-${dot}`"
                  class="w-3 h-3 rounded-full mr-1"
                  :class="dot <= getImpactLevel('wildlife') ? 'bg-amber-500' : 'bg-gray-200'"
                ></div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted, computed, useHead } from "#imports";
import { Share2, Flag } from "lucide-vue-next";
const { get } = useApi();
const route = useRoute();
const router = useRouter();

// State
const hotspotData = ref([]);
const mapLocation = ref(null);
const isLoading = ref(true);
const mapReady = ref(false);
const selectedHotspot = ref(null);
const locationDetails = ref(null);
const severityLabels = ['Low', 'Low', 'Medium', 'High', 'Critical'];

// Get parameters from URL
const getLocationFromUrl = () => {
  const lat = Number(route.query.lat);
  const lng = Number(route.query.lng);
  
  if (isNaN(lat) || isNaN(lng)) {
    return null;
  }
  
  return { lat, lng };
};

// Generate dynamic meta tags for social sharing
const pageTitle = computed(() => {
  return locationDetails.value 
    ? `Waste Hotspot Alert: ${locationDetails.value.address || 'Location needs attention'}`
    : 'Waste Hotspot Alert';
});

const pageDescription = computed(() => {
  if (!locationDetails.value) return 'Help keep our environment clean by addressing this waste hotspot.';
  
  return `${getSeverityText()} waste accumulation detected at ${locationDetails.value.address || 'this location'}. Action required.`;
});

// Create dynamic OG image URL
const ogImageUrl = computed(() => {
  if (!mapLocation.value) return '';
  
  // This would be your API endpoint that generates dynamic OG images
  return `/api/og-image?lat=${mapLocation.value.lat}&lng=${mapLocation.value.lng}&severity=${locationDetails.value?.severity || 3}`;
});

// Set meta tags
useHead({
  title: pageTitle,
  meta: [
    { name: 'description', content: pageDescription },
    // Open Graph
    { property: 'og:title', content: pageTitle },
    { property: 'og:description', content: pageDescription },
    { property: 'og:image', content: ogImageUrl },
    { property: 'og:type', content: 'website' },
    // Twitter
    { name: 'twitter:card', content: 'summary_large_image' },
    { name: 'twitter:title', content: pageTitle },
    { name: 'twitter:description', content: pageDescription },
    { name: 'twitter:image', content: ogImageUrl }
  ]
});

// Fetch data
async function getHotspotData() {
  isLoading.value = true;
  
  try {
    // Get location from URL
    const urlLocation = getLocationFromUrl();
    
    if (!urlLocation) {
      console.error('No valid location provided in URL');
      router.push('/'); // Redirect to home if no valid coordinates
      return;
    }
    
    mapLocation.value = urlLocation;
    
    // Fetch all hotspots to display on map
    const { data } = await get("/trash/hotspots");
    hotspotData.value = data || [];
    
    // Find the current hotspot from the data
    const currentHotspot = hotspotData.value.find(spot => {
      // Find closest matching hotspot (within small radius)
      const latDiff = Math.abs(spot.lat - mapLocation.value.lat);
      const lngDiff = Math.abs(spot.lng - mapLocation.value.lng);
      return latDiff < 0.0001 && lngDiff < 0.0001;
    });

    if (currentHotspot) {
      selectedHotspot.value = currentHotspot;
      
      // Fetch additional details for this hotspot
      try {
        const { data: details } = await get(`/trash/hotspots/${currentHotspot.id}`);
        locationDetails.value = details;
      } catch (error) {
        console.error('Failed to fetch hotspot details:', error);
        // Create basic details from the hotspot data
        locationDetails.value = {
          address: currentHotspot.location || 'Unknown location',
          severity: currentHotspot.severity || 3,
          reportedAt: new Date().toLocaleDateString(),
          wasteType: 'Mixed waste',
          estimatedVolume: 'Medium'
        };
      }
    } else {
      // Create minimal location details
      locationDetails.value = {
        address: 'Unknown location',
        severity: 3,
        reportedAt: new Date().toLocaleDateString(),
        wasteType: 'Unknown',
        estimatedVolume: 'Unknown'
      };
    }
  } catch (error) {
    console.error('Failed to fetch hotspot data:', error);
  } finally {
    isLoading.value = false;
    mapReady.value = true;
  }
}

// Helper methods - Enhanced with new severity methods
const getSeverityText = () => {
  const severity = locationDetails.value?.severity || 3;
  if (severity >= 5) return 'Critical';
  if (severity === 4) return 'High';
  if (severity === 3) return 'Medium';
  return 'Low';
};

const getSeverityClass = () => {
  const severity = locationDetails.value?.severity || 3;
  if (severity >= 5) return 'text-red-600 font-bold';
  if (severity === 4) return 'text-orange-500 font-bold';
  if (severity === 3) return 'text-yellow-500 font-bold';
  return 'text-green-500 font-bold';
};

// Method for severity indicator color
const getSeverityColorClass = (level) => {
  if (level >= 5) return 'bg-red-600 text-white';
  if (level === 4) return 'bg-orange-500 text-white';
  if (level === 3) return 'bg-yellow-500 text-white';
  return 'bg-green-500 text-white';
};

// Method for severity dot indicators
const getSeverityDotClass = (level) => {
  if (level >= 5) return 'bg-red-600';
  if (level === 4) return 'bg-orange-500';
  if (level === 3) return 'bg-yellow-500';
  return 'bg-green-500';
};

// Method for severity progress bar
const getSeverityBarClass = () => {
  const severity = locationDetails.value?.severity || 3;
  if (severity >= 5) return 'bg-red-600';
  if (severity === 4) return 'bg-orange-500';
  if (severity === 3) return 'bg-yellow-500';
  return 'bg-green-500';
};

// Method to get impact level based on severity
const getImpactLevel = (type) => {
  const severity = locationDetails.value?.severity || 3;
  
  // Different impact factors based on the impact type
  switch(type) {
    case 'pollution':
      return Math.min(5, Math.ceil(severity * 0.8 + 1));
    case 'water':
      return Math.min(5, Math.ceil(severity * 0.6 + 0.5));
    case 'wildlife':
      return Math.min(5, Math.ceil(severity * 0.7));
    default:
      return Math.min(5, Math.ceil(severity * 0.8));
  }
};

// Action methods
const shareLocation = async () => {
  const url = window.location.href;
  
  try {
    if (navigator.share) {
      await navigator.share({
        title: pageTitle.value,
        text: pageDescription.value,
        url: url
      });
    } else {
      await navigator.clipboard.writeText(url);
      alert('Link copied to clipboard!');
    }
  } catch (error) {
    console.error('Error sharing:', error);
  }
};

const reportAction = () => {
  router.push({
    path: '/report-action',
    query: { 
      lat: mapLocation.value?.lat, 
      lng: mapLocation.value?.lng,
      hotspotId: selectedHotspot.value?.id || ''
    }
  });
};

onMounted(() => {
  getHotspotData();
});
</script>

<style scoped>
@reference "../assets/css/main.css";

.section-container {
  @apply container mx-auto px-4;
}
</style>