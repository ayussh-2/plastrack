<template>
    <div class="container">
        <h1>Trash Hotspot Map</h1>
        <TrashHotspotMap
            v-if="geoLocation"
            :hotspot-data="hotspotData"
            :geoLocation="geoLocation"
        />
        <div v-if="geoLocation">Your location: {{ geoLocation }}</div>
    </div>
</template>

<script setup>
const { get } = useApi();
const hotspotData = ref([]);
const geoLocation = ref(null);
const isLoading = ref(false);

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

onMounted(() => {
    getHotspots();
});
</script>

<style scoped>
.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
}

h1 {
    text-align: center;
    margin-bottom: 30px;
}
</style>
