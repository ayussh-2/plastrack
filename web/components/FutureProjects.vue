<template>
    <div class="py-16">
        <div class="section-container">
            <div class="mb-12 text-center">
                <h2 class="mb-4 text-3xl font-bold md:text-4xl">
                    Future Infrastructure Planning
                </h2>
                <p class="max-w-2xl mx-auto text-muted-foreground">
                    Visualize the future of urban infrastructure with our innovative projects that utilize recycled waste materials.
                </p>
            </div>

            <!-- Project Tabs -->
            <div class="flex justify-center mb-10">
                <div
                    class="inline-flex p-1 rounded-full glass-card dark:glass-card-dark"
                >
                    <button
                        v-for="(_, tab) in tabData"
                        :key="tab"
                        class="px-5 py-2 text-sm font-medium transition-all rounded-full"
                        :class="
                            selectedTab === tab
                                ? 'bg-waste2way-teal text-white shadow-md'
                                : 'hover:bg-white/10'
                        "
                        @click="selectedTab = tab"
                    >
                        {{ tab.charAt(0).toUpperCase() + tab.slice(1) }}
                    </button>
                </div>
            </div>

            <!-- Project Details -->
            <div class="grid items-center grid-cols-1 gap-10 md:grid-cols-2">
                <div
                    class="order-2 p-6 glass-card dark:glass-card-dark rounded-2xl md:order-1"
                >
                    <h3 class="mb-3 text-2xl font-bold">
                        {{ currentTabData.title }}
                    </h3>
                    <p class="mb-6 text-muted-foreground">
                        {{ currentTabData.description }}
                    </p>

                    <div class="grid grid-cols-3 gap-4 mb-6">
                        <div
                            v-for="(stat, index) in currentTabData.stats"
                            :key="index"
                            class="p-3 text-center bg-white/5 rounded-xl"
                        >
                            <p class="mb-1 text-2xl font-bold">
                                {{ stat.value }}
                            </p>
                            <p class="text-xs text-muted-foreground">
                                {{ stat.label }}
                            </p>
                        </div>
                    </div>

                    <div class="mb-6">
                        <h4 class="mb-3 font-medium">Key Benefits</h4>
                        <ul class="space-y-2">
                            <li
                                v-for="(
                                    benefit, index
                                ) in currentTabData.benefits"
                                :key="index"
                                class="flex"
                            >
                                <CheckCircle
                                    class="flex-shrink-0 w-5 h-5 mr-2 text-waste2way-green"
                                />
                                <span>{{ benefit }}</span>
                            </li>
                        </ul>
                    </div>

                    <div class="flex mt-6 space-x-4">
                        <button class="btn-primary">
                            View Projects <MapPin class="inline w-4 h-4 ml-2" />
                        </button>
                        <button class="btn-secondary">
                            Impact Report
                            <TrendingUp class="inline w-4 h-4 ml-2" />
                        </button>
                    </div>
                </div>

                <div class="order-1 md:order-2">
                    <div
                        class="relative overflow-hidden shadow-xl rounded-2xl h-80"
                    >
                        <img
                            :src="currentTabData.image"
                            :alt="currentTabData.title"
                            class="object-cover w-full h-full"
                        />
                        <div
                            class="absolute inset-0 bg-gradient-to-t from-waste2way-dark to-transparent opacity-60"
                        ></div>
                        <div class="absolute bottom-0 left-0 right-0 p-6">
                            <h4 class="text-xl font-bold text-white">
                                {{ currentTabData.title }}
                            </h4>
                            <button
                                class="flex items-center px-4 py-2 mt-3 text-sm text-white transition-colors rounded-full bg-white/10 hover:bg-white/20 backdrop-blur-sm"
                            >
                                View 3D Model
                                <ArrowRight class="w-4 h-4 ml-2" />
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Implementation Map Preview -->
            <div class="p-6 mt-16 glass-card dark:glass-card-dark rounded-2xl">
                <div class="flex items-center justify-between mb-6">
                    <h3 class="text-xl font-medium">
                        Implementation Priority Map
                    </h3>
                    <button
                        class="flex items-center text-sm text-waste2way-blue hover:underline"
                    >
                        Full Map View <ArrowRight class="w-4 h-4 ml-1" />
                    </button>
                </div>

                <div
                    class="relative h-64 overflow-hidden rounded-xl bg-slate-100"
                >
                    <!-- Map would be implemented here with an actual mapping library -->
                    <div
                        class="w-full h-full opacity-70 bg-[url('https://www.transparenttextures.com/patterns/cartographer.png')]"
                    ></div>

                    <!-- Priority Zones -->
                    <div
                        class="absolute w-16 h-16 rounded-full top-1/4 left-1/4 bg-red-500/30 animate-pulse-light"
                    >
                        <div
                            class="absolute w-6 h-6 transform -translate-x-1/2 -translate-y-1/2 bg-red-500 rounded-full top-1/2 left-1/2"
                        >
                            <MapPin
                                class="absolute text-white transform -translate-x-1/2 -translate-y-1/2 top-1/2 left-1/2"
                                size="12"
                            />
                        </div>
                    </div>

                    <div
                        class="absolute w-12 h-12 rounded-full top-2/3 right-1/3 bg-yellow-500/30 animate-pulse-light"
                    >
                        <div
                            class="absolute w-4 h-4 transform -translate-x-1/2 -translate-y-1/2 bg-yellow-500 rounded-full top-1/2 left-1/2"
                        >
                            <MapPin
                                class="absolute text-white transform -translate-x-1/2 -translate-y-1/2 top-1/2 left-1/2"
                                size="8"
                            />
                        </div>
                    </div>

                    <div
                        class="absolute w-10 h-10 rounded-full top-1/3 right-1/4 bg-green-500/30 animate-pulse-light"
                    >
                        <div
                            class="absolute w-3 h-3 transform -translate-x-1/2 -translate-y-1/2 bg-green-500 rounded-full top-1/2 left-1/2"
                        >
                            <MapPin
                                class="absolute text-white transform -translate-x-1/2 -translate-y-1/2 top-1/2 left-1/2"
                                size="6"
                            />
                        </div>
                    </div>

                    <!-- Overlay gradient -->
                    <div
                        class="absolute inset-0 pointer-events-none bg-gradient-to-t from-slate-200/50 to-transparent"
                    ></div>
                </div>

                <!-- Legend -->
                <div class="flex items-center justify-center mt-4 space-x-8">
                    <div class="flex items-center">
                        <div class="w-3 h-3 mr-2 bg-red-500 rounded-full"></div>
                        <span class="text-xs">High Priority</span>
                    </div>
                    <div class="flex items-center">
                        <div
                            class="w-3 h-3 mr-2 bg-yellow-500 rounded-full"
                        ></div>
                        <span class="text-xs">Medium Priority</span>
                    </div>
                    <div class="flex items-center">
                        <div
                            class="w-3 h-3 mr-2 bg-green-500 rounded-full"
                        ></div>
                        <span class="text-xs">Low Priority</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import { ArrowRight, MapPin, TrendingUp, CheckCircle } from "lucide-vue-next";

export default {
    name: "FutureProjects",
    components: {
        ArrowRight,
        MapPin,
        TrendingUp,
        CheckCircle,
    },
    data() {
        return {
            selectedTab: "roads",
            tabData: {
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
                    image: "https://images.unsplash.com/photo-1515630771457-09367d0ae68e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80",
                },
                pavements: {
                    title: "Plastic Pavements",
                    description:
                        "Sidewalks and pavements built using recycled plastic waste provide enhanced durability and reduced maintenance costs.",
                    stats: [
                        { label: "Durability", value: "+35%" },
                        { label: "Cost Efficiency", value: "+25%" },
                        { label: "CO₂ Reduction", value: "-28%" },
                    ],
                    benefits: [
                        "Slip-resistant surface",
                        "Flexible and crack-resistant",
                        "Easy installation process",
                        "Utilizes up to 4 tons of plastic per km",
                    ],
                    image: "https://images.unsplash.com/photo-1584036553516-bf83210aa16c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80",
                },
                furniture: {
                    title: "Urban Furniture",
                    description:
                        "Benches, tables, and playground equipment made from recycled plastic waste that are weather-resistant and durable.",
                    stats: [
                        { label: "Durability", value: "+50%" },
                        { label: "Cost Efficiency", value: "+20%" },
                        { label: "CO₂ Reduction", value: "-25%" },
                    ],
                    benefits: [
                        "Weather and UV resistant",
                        "No painting or waterproofing needed",
                        "Splinter-free and safe for all ages",
                        "Each bench recycles ~3,000 plastic bottles",
                    ],
                    image: "https://images.unsplash.com/photo-1620331310125-0bef072eae42?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80",
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
    0%,
    100% {
        opacity: 1;
    }
    50% {
        opacity: 0.5;
    }
}
</style>