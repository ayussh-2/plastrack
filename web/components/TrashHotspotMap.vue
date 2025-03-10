<template>
    <div class="w-full">
        <!-- Map Container -->
        <div
            id="map"
            class="w-full h-[600px] md:h-[700px] rounded-lg shadow-md mb-5"
        ></div>

        <!-- Legends -->
        <div class="bg-white p-4 rounded-lg shadow-md max-w-xs">
            <h3 class="text-lg font-medium text-gray-800 mb-2">
                Severity Legend
            </h3>
            <div class="space-y-2">
                <div v-for="i in 5" :key="i" class="flex items-center">
                    <div
                        class="w-5 h-5 mr-3 rounded"
                        :style="{ backgroundColor: getSeverityColor(i, 0.8) }"
                    ></div>
                    <span class="text-sm text-gray-700">Level {{ i }}</span>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { Loader } from "@googlemaps/js-api-loader";

const props = defineProps({
    hotspotData: {
        type: Array,
        required: true,
    },
    geoLocation: {
        type: Object,
        required: true,
    },
});

const map = ref(null);
const markers = ref([]);
const circles = ref([]);
const googleInstance = ref(null);

const getSeverityColor = (severity, opacity = 0.6) => {
    // Color scheme from green (low) to red (high)
    const colors = {
        1: `rgba(0, 255, 0, ${opacity})`, // Green
        2: `rgba(144, 238, 144, ${opacity})`, // Light green
        3: `rgba(255, 255, 0, ${opacity})`, // Yellow
        4: `rgba(255, 165, 0, ${opacity})`, // Orange
        5: `rgba(255, 0, 0, ${opacity})`, // Red
    };
    return colors[severity] || `rgba(200, 200, 200, ${opacity})`;
};

const initializeMap = async () => {
    try {
        const loader = new Loader({
            apiKey: process.env.NUXT_PUBLIC_GOOGLE_MAPS_API_KEY,
            version: "weekly",
            libraries: ["maps"],
        });

        googleInstance.value = await loader.load();
        console.log(props.geoLocation);
        const center = new googleInstance.value.maps.LatLng(
            props.geoLocation.lat,
            props.geoLocation.lng
        );
        console.log(center);
        map.value = new googleInstance.value.maps.Map(
            document.getElementById("map"),
            {
                center: center,
                zoom: 14,
                styles: [
                    {
                        featureType: "poi",
                        elementType: "labels",
                        stylers: [{ visibility: "off" }],
                    },
                ],
            }
        );

        // Render hotspots if available
        if (props.hotspotData.length > 0) {
            renderHotspots(props.hotspotData, googleInstance.value);
        }
    } catch (error) {
        console.error("Error loading Google Maps:", error);
    }
};

watch(
    () => props.hotspotData,
    (newData) => {
        if (map.value && googleInstance.value) {
            renderHotspots(newData, googleInstance.value);
        }
    },
    { deep: true }
);

const renderHotspots = (hotspots, google) => {
    markers.value.forEach((marker) => marker.setMap(null));
    circles.value.forEach((circle) => circle.setMap(null));
    markers.value = [];
    circles.value = [];

    const bounds = new google.maps.LatLngBounds();

    hotspots.forEach((hotspot) => {
        const position = {
            lat: hotspot.latGroup,
            lng: hotspot.lngGroup,
        };

        bounds.extend(position);

        const circle = new google.maps.Circle({
            strokeColor: getSeverityColor(hotspot.avgSeverity, 1),
            strokeOpacity: 0.8,
            strokeWeight: 2,
            fillColor: getSeverityColor(hotspot.avgSeverity),
            fillOpacity: 0.6,
            map: map.value,
            center: position,
            radius: hotspot.reportCount * 50 + hotspot.avgSeverity * 20,
        });
        circles.value.push(circle);

        // info window content
        const infoContent = `
        <div style="font-family: ui-sans-serif, system-ui; padding: 0.75rem; max-width: 320px;">
          <h3 style="font-size: 1.125rem; font-weight: 600; color: #1f2937; margin-bottom: 0.5rem;">Trash Hotspot</h3>
          <div style="display: flex; gap: 1rem; margin-bottom: 0.5rem;">
            <div style="background-color: ${getSeverityColor(
                hotspot.avgSeverity
            )}; width: 3rem; height: 3rem; border-radius: 0.375rem; display: flex; align-items: center; justify-content: center; font-weight: bold; color: #1f2937;">${Math.round(
            hotspot.avgSeverity
        )}</div>
            <div>
              <p style="margin: 0.25rem 0; font-weight: 500;">Reports: <span style="font-weight: 600;">${
                  hotspot.reportCount
              }</span></p>
              <p style="margin: 0.25rem 0; font-weight: 500;">Severity: <span style="font-weight: 600;">${hotspot.avgSeverity.toFixed(
                  1
              )}</span></p>
            </div>
          </div>
          <p style="margin: 0.5rem 0; font-weight: 500;">Types: <span style="font-weight: normal;">${[
              ...new Set(hotspot.reports.map((r) => r.trashType)),
          ].join(", ")}</span></p>
          <hr style="border: 0; border-top: 1px solid #e5e7eb; margin: 0.75rem 0;">
          <h4 style="font-size: 1rem; font-weight: 600; color: #1f2937; margin-bottom: 0.5rem;">Recent Reports</h4>
          <div style="max-height: 200px; overflow-y: auto;">
            ${hotspot.reports
                .map(
                    (report) => `
              <div style="padding: 0.5rem; margin-bottom: 0.5rem; border-radius: 0.25rem; background-color: #f9fafb;">
                <div style="display: flex; justify-content: space-between;">
                  <span style="font-weight: 500;">${report.trashType}</span>
                  <span style="font-weight: 500; color: ${getSeverityColor(
                      report.severity,
                      1
                  )};">Level ${report.severity}</span>
                </div>
                <p style="margin: 0.25rem 0; font-size: 0.875rem; color: #6b7280;">
                  ${new Date(report.timestamp).toLocaleString()}
                </p>
              </div>
            `
                )
                .join("")}
          </div>
        </div>
      `;

        const infoWindow = new google.maps.InfoWindow({
            content: infoContent,
            maxWidth: 350,
        });

        circle.addListener("click", () => {
            infoWindow.setPosition(position);
            infoWindow.open(map.value);
        });
    });

    if (!bounds.isEmpty()) {
        map.value.fitBounds(bounds);

        if (props.geoLocation) {
            setTimeout(() => {
                map.value.setCenter(props.geoLocation);
            }, 100);
        }
    }
};

onMounted(() => {
    if (props.geoLocation) {
        initializeMap();
    }
});
</script>
