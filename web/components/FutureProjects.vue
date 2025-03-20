<template>
    <div class="py-16">
        <div class="section-container">
            <!-- Header -->
            <div class="mb-12 text-center">
                <h2 class="mb-4 text-3xl font-bold md:text-4xl">
                    The Impact of Waste Classification
                </h2>
                <p class="max-w-2xl mx-auto text-muted-foreground">
                    Explore how our innovative projects utilize recycled waste materials to revolutionize urban infrastructure.
                </p>
            </div>

            <!-- Project Tabs -->
            <div class="flex justify-center mb-10">
                <div class="inline-flex p-1 rounded-full glass-card dark:glass-card-dark">
                    <button
                        v-for="(_, tab) in tabData"
                        :key="tab"
                        class="px-5 py-2 text-sm font-medium transition-all rounded-full"
                        :class="selectedTab === tab
                            ? 'bg-waste2way-teal text-white shadow-md'
                            : 'hover:bg-white/10'"
                        @click="selectedTab = tab"
                    >
                        {{ tab.charAt(0).toUpperCase() + tab.slice(1) }}
                    </button>
                </div>
            </div>

            <!-- Project Details -->
            <div class="grid items-center grid-cols-1 gap-10 md:grid-cols-2">
                <div class="order-2 p-6 glass-card dark:glass-card-dark rounded-2xl md:order-1">
                    <h3 class="mb-3 text-2xl font-bold">
                        {{ currentTabData.title }}
                    </h3>
                    <p class="mb-6 text-muted-foreground">
                        {{ currentTabData.description }}
                    </p>

                    <!-- Statistics -->
                    <div class="grid grid-cols-3 gap-4 mb-6">
                        <div v-for="(stat, index) in currentTabData.stats" :key="index" class="p-3 text-center bg-white/5 rounded-xl">
                            <p class="mb-1 text-2xl font-bold">
                                {{ stat.value }}
                            </p>
                            <p class="text-xs text-muted-foreground">
                                {{ stat.label }}
                            </p>
                        </div>
                    </div>

                    <!-- Benefits -->
                    <div class="mb-6">
                        <h4 class="mb-3 font-medium">Key Benefits</h4>
                        <ul class="space-y-2">
                            <li v-for="(benefit, index) in currentTabData.benefits" :key="index" class="flex">
                                <CheckCircle class="flex-shrink-0 w-5 h-5 mr-2 text-waste2way-green" />
                                <span>{{ benefit }}</span>
                            </li>
                        </ul>
                    </div>
                </div>

                <!-- Image Section -->
                <div class="order-1 md:order-2">
                    <div class="relative overflow-hidden shadow-xl rounded-2xl h-80">
                        <img :src="currentTabData.image" :alt="currentTabData.title" class="object-cover w-full h-full" />
                        <div class="absolute inset-0 bg-gradient-to-t from-waste2way-dark to-transparent opacity-60"></div>
                        <div class="absolute bottom-0 left-0 right-0 p-6">
                            <h4 class="text-xl font-bold text-white">
                                {{ currentTabData.title }}
                            </h4>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import { CheckCircle } from "lucide-vue-next";

export default {
    name: "FutureProjects",
    components: { CheckCircle },
    data() {
        return {
            selectedTab: "roads",
            tabData: {
                roads: {
                    title: "Plastic Roads",
                    description: "Plastic waste-based roads offer increased durability, weather resistance, and significantly reduce asphalt’s carbon footprint.",
                    stats: [
                        { label: "Durability Increase", value: "+45%" },
                        { label: "Cost Efficiency", value: "+30%" },
                        { label: "CO₂ Emissions Reduction", value: "-32%" },
                    ],
                    benefits: [
                        "Less frequent maintenance",
                        "Water-resistant surface",
                        "Reduced greenhouse gas emissions",
                        "Recycles up to 8 tons of plastic per km",
                    ],
                    image: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/Road_in_Norway.jpg/1200px-Road_in_Norway.jpg",
                },
                pavements: {
                    title: "Plastic Pavements",
                    description: "Recycled plastic sidewalks offer higher durability, cost-effectiveness, and lower environmental impact compared to traditional materials.",
                    stats: [
                        { label: "Durability Increase", value: "+35%" },
                        { label: "Cost Efficiency", value: "+25%" },
                        { label: "CO₂ Emissions Reduction", value: "-28%" },
                    ],
                    benefits: [
                        "Slip-resistant and weatherproof",
                        "Crack-resistant for longer lifespan",
                        "Quick and cost-effective installation",
                        "Recycles up to 4 tons of plastic per km",
                    ],
                    image: "https://borntoengineer.ams3.cdn.digitaloceanspaces.com/2020/10/shane-mcknight-hA6nChzApqo-unsplash-1024x576.jpg",
                },
                furniture: {
                    title: "Urban Furniture",
                    description: "Benches, tables, and playground equipment made from recycled plastic waste ensure durability, safety, and weather resistance.",
                    stats: [
                        { label: "Durability Increase", value: "+50%" },
                        { label: "Cost Efficiency", value: "+20%" },
                        { label: "CO₂ Emissions Reduction", value: "-25%" },
                    ],
                    benefits: [
                        "Weather and UV-resistant",
                        "No need for painting or waterproofing",
                        "Splinter-free and safe for public use",
                        "Each bench recycles ~3,000 plastic bottles",
                    ],
                    image: "https://media.istockphoto.com/id/1456590290/photo/trash-dump-with-old-worn-out-matrasses-armchairs-and-other-broken-furniture.jpg?s=612x612&w=0&k=20&c=KPfIlXs6rYybklaVcmNUdxJE4pWE8L-T2qbvyHMYuaQ=",
                },
            },
        };
    },
    computed: {
        currentTabData() {
            return this.tabData[this.selectedTab];
        },
    },
};
</script>

<style scoped>
.animate-pulse-light {
    animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

@keyframes pulse {
    0%, 100% {
        opacity: 1;
    }
    50% {
        opacity: 0.5;
    }
}
</style>
