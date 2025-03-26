<template>
    <div
        id="documentation"
        class="py-16 bg-gradient-to-b from-background to-waste2way-teal/5"
    >
        <div class="section-container">
            <div class="mb-12 text-center">
                <h2 class="mb-4 text-3xl font-bold md:text-4xl">
                    Documentation
                </h2>
                <p class="max-w-2xl mx-auto text-muted-foreground">
                    Comprehensive guide to using the Waste2Way platform and
                    understanding its features
                </p>
            </div>

            <!-- Documentation Tabs -->
            <div class="flex justify-center mb-10">
                <div
                    class="inline-flex p-1 rounded-full glass-card dark:glass-card-dark"
                >
                    <button
                        v-for="tab in tabs"
                        :key="tab.id"
                        class="px-5 py-2 text-sm font-medium transition-all rounded-full"
                        :class="
                            selectedTab === tab.id
                                ? 'bg-waste2way-teal text-white shadow-md'
                                : 'hover:bg-white/10'
                        "
                        @click="selectedTab = tab.id"
                    >
                        {{ tab.label }}
                    </button>
                </div>
            </div>

            <!-- Documentation Content -->
            <div class="grid grid-cols-1 gap-8 md:grid-cols-3">
                <!-- Table of Contents Sidebar -->
                <div class="md:col-span-1">
                    <div
                        class="p-6 sticky top-24 glass-card dark:glass-card-dark rounded-xl"
                    >
                        <h3 class="mb-4 text-lg font-medium">
                            Table of Contents
                        </h3>
                        <ul class="space-y-3">
                            <li
                                v-for="section in currentTabContent.sections"
                                :key="section.id"
                            >
                                <a
                                    :href="`#${section.id}`"
                                    class="flex items-center transition-colors hover:text-waste2way-teal"
                                    :class="
                                        activeSection === section.id
                                            ? 'text-waste2way-teal font-medium'
                                            : ''
                                    "
                                >
                                    <div
                                        class="w-1.5 h-1.5 mr-2 rounded-full bg-waste2way-teal"
                                    ></div>
                                    {{ section.title }}
                                </a>
                            </li>
                        </ul>
                    </div>
                </div>

                <!-- Documentation Main Content -->
                <div class="md:col-span-2">
                    <div class="p-6 glass-card dark:glass-card-dark rounded-xl">
                        <div
                            v-for="section in currentTabContent.sections"
                            :key="section.id"
                            :id="section.id"
                            class="mb-10"
                        >
                            <h3
                                class="mb-4 text-xl font-bold text-waste2way-teal"
                            >
                                {{ section.title }}
                            </h3>
                            <div
                                v-if="section.content"
                                class="space-y-4 text-muted-foreground"
                            >
                                <p
                                    v-for="(paragraph, idx) in section.content"
                                    :key="idx"
                                >
                                    {{ paragraph }}
                                </p>
                            </div>

                            <div v-if="section.steps" class="mt-6 space-y-4">
                                <div
                                    v-for="(step, idx) in section.steps"
                                    :key="idx"
                                    class="flex"
                                >
                                    <div
                                        class="flex-shrink-0 w-8 h-8 flex items-center justify-center rounded-full bg-waste2way-teal/10 text-waste2way-teal font-medium"
                                    >
                                        {{ idx + 1 }}
                                    </div>
                                    <div class="ml-4">
                                        <h4 class="font-medium">
                                            {{ step.title }}
                                        </h4>
                                        <p
                                            class="text-sm text-muted-foreground"
                                        >
                                            {{ step.description }}
                                        </p>
                                    </div>
                                </div>
                            </div>

                            <div
                                v-if="section.code"
                                class="mt-6 p-4 bg-waste2way-dark/90 rounded-lg overflow-x-auto"
                            >
                                <pre
                                    class="text-sm text-white font-mono"
                                ><code>{{ section.code }}</code></pre>
                            </div>

                            <div v-if="section.image" class="mt-6">
                                <img
                                    :src="section.image"
                                    :alt="section.title"
                                    class="rounded-lg shadow-md"
                                />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: "DocumentationPage",
    data() {
        return {
            selectedTab: "web",
            activeSection: "",
            tabs: [
                { id: "web", label: "Web Platform" },
                { id: "mobile", label: "Mobile App" },
                { id: "api", label: "API Reference" },
            ],
            documentation: {
                web: {
                    sections: [
                        {
                            id: "overview",
                            title: "Overview",
                            content: [
                                "The Waste2Way web platform provides a comprehensive interface for waste management and infrastructure planning using recycled materials.",
                                "The platform combines AI-powered waste identification, community engagement through gamification, and real-time mapping of waste hotspots.",
                            ],
                        },
                        {
                            id: "waste-identification",
                            title: "Waste Identification",
                            content: [
                                "Our AI-powered system identifies waste types with 90%+ accuracy and determines their suitability for usage in sustainable infrastructure.",
                            ],
                            steps: [
                                {
                                    title: "Upload an Image",
                                    description:
                                        "Click on the upload area or drag and drop an image of waste material.",
                                },
                                {
                                    title: "View Analysis",
                                    description:
                                        "The system will analyze the image and provide detailed classification, recyclability score, and infrastructure suitability metrics.",
                                },
                                {
                                    title: "Environmental Impact",
                                    description:
                                        "See the potential environmental benefits of repurposing the identified waste.",
                                },
                            ],
                        },
                        {
                            id: "hotspot-map",
                            title: "Trash Hotspot Map",
                            content: [
                                "The interactive map visualizes waste concentration areas with severity levels from 1-5.",
                                "This helps authorities and communities identify areas requiring immediate attention.",
                            ],
                            steps: [
                                {
                                    title: "Navigate the Map",
                                    description:
                                        "Use the map controls to zoom and pan around your area of interest.",
                                },
                                {
                                    title: "Filter by Severity",
                                    description:
                                        "Use the filter button to show hotspots based on their severity levels.",
                                },
                                {
                                    title: "View Hotspot Details",
                                    description:
                                        "Click on any hotspot to view detailed information about the waste accumulation.",
                                },
                            ],
                        },
                        {
                            id: "analytics",
                            title: "Analytics Dashboard",
                            content: [
                                "The analytics dashboard provides data-driven insights on waste collection, processing, and infrastructure impact.",
                                "Charts and statistics help track progress and identify opportunities for improvement.",
                            ],
                        },
                        {
                            id: "community",
                            title: "Community & Gamification",
                            content: [
                                "Join our community of changemakers and earn rewards for your contributions to waste management.",
                                "The leaderboard showcases top contributors based on their activity and impact.",
                            ],
                        },
                    ],
                },
                mobile: {
                    sections: [
                        {
                            id: "mobile-overview",
                            title: "Mobile App Overview",
                            content: [
                                "The Waste2Way mobile app allows users to report waste on the go, track their contributions, and stay updated on community activities.",
                                "Available for Android devices, the app provides a streamlined version of the web platform with additional mobile-specific features.",
                            ],
                        },
                        {
                            id: "installation",
                            title: "Installation",
                            content: [
                                "Download the Waste2Way app from the Google Play Store or directly from our website.",
                            ],
                            steps: [
                                {
                                    title: "Register an Account",
                                    description:
                                        "Create a new account or sign in with existing credentials.",
                                },
                                {
                                    title: "Enable Permissions",
                                    description:
                                        "Allow camera and location access for full functionality.",
                                },
                                {
                                    title: "Complete Your Profile",
                                    description:
                                        "Add your details to personalize your experience and track contributions.",
                                },
                            ],
                        },
                        {
                            id: "reporting",
                            title: "Reporting Waste",
                            content: [
                                "The mobile app makes it easy to report waste incidents with its streamlined camera interface and location tracking.",
                            ],
                            steps: [
                                {
                                    title: "Capture Image",
                                    description:
                                        "Take a photo of the waste using the in-app camera.",
                                },
                                {
                                    title: "Set Severity Level",
                                    description:
                                        "Indicate the severity of the waste accumulation from 1-5.",
                                },
                                {
                                    title: "Submit Report",
                                    description:
                                        "Send the report to be analyzed and added to the hotspot map.",
                                },
                            ],
                        },
                        {
                            id: "feedback",
                            title: "Providing Feedback",
                            content: [
                                "After submitting a report, you can view the AI analysis and provide feedback to improve our system.",
                            ],
                        },
                        {
                            id: "viewing-reports",
                            title: "Viewing Your Reports",
                            content: [
                                "Track all your submitted reports and see their impact on the environment.",
                            ],
                        },
                    ],
                },
                api: {
                    sections: [
                        {
                            id: "api-overview",
                            title: "API Overview",
                            content: [
                                "The Waste2Way API allows developers to integrate our waste management and analysis capabilities into their own applications.",
                                "All endpoints require authentication using Firebase tokens.",
                            ],
                        },
                        {
                            id: "authentication",
                            title: "Authentication",
                            content: [
                                "API requests require a valid Firebase authentication token included in the request header.",
                            ],
                            code: "Authorization: Bearer [YOUR_FIREBASE_TOKEN]",
                        },
                        {
                            id: "trash-endpoints",
                            title: "Trash Management Endpoints",
                            content: [
                                "These endpoints handle waste reporting, classification, and hotspot management.",
                            ],
                            steps: [
                                {
                                    title: "POST /trash/generate",
                                    description:
                                        "Submit a new trash report with image, location, and severity.",
                                },
                                {
                                    title: "POST /trash/classify",
                                    description:
                                        "Analyze an image to identify waste type and infrastructure suitability.",
                                },
                                {
                                    title: "GET /trash/hotspots",
                                    description:
                                        "Retrieve all waste hotspots based on aggregated reports.",
                                },
                                {
                                    title: "POST /trash/feedback",
                                    description:
                                        "Submit feedback on a specific waste report.",
                                },
                            ],
                        },
                        {
                            id: "user-endpoints",
                            title: "User Management Endpoints",
                            content: [
                                "These endpoints handle user registration, profile management, and authentication.",
                            ],
                            steps: [
                                {
                                    title: "POST /users/register",
                                    description:
                                        "Register a new user with Firebase ID and profile details.",
                                },
                                {
                                    title: "PUT /users/update",
                                    description:
                                        "Update user profile information.",
                                },
                                {
                                    title: "GET /users/:id",
                                    description:
                                        "Retrieve user profile information.",
                                },
                            ],
                        },
                        {
                            id: "game-endpoints",
                            title: "Gamification Endpoints",
                            content: [
                                "These endpoints handle points, leaderboards, and user achievements.",
                            ],
                            steps: [
                                {
                                    title: "GET /game/leaderboard",
                                    description:
                                        "Retrieve the top contributors leaderboard.",
                                },
                                {
                                    title: "GET /game/user-rank",
                                    description:
                                        "Get a specific user's rank and points.",
                                },
                            ],
                        },
                    ],
                },
            },
        };
    },
    computed: {
        currentTabContent() {
            return this.documentation[this.selectedTab];
        },
    },
    mounted() {
        // Set initial active section
        this.setInitialActiveSection();

        // Add scroll event listener to update active section
        window.addEventListener("scroll", this.handleScroll);
    },
    beforeUnmount() {
        // Remove event listener
        window.removeEventListener("scroll", this.handleScroll);
    },
    methods: {
        setInitialActiveSection() {
            if (this.currentTabContent.sections.length > 0) {
                this.activeSection = this.currentTabContent.sections[0].id;
            }
        },
        handleScroll() {
            const sections = this.currentTabContent.sections;

            // Find the section currently in view
            for (const section of sections) {
                const element = document.getElementById(section.id);
                if (element) {
                    const rect = element.getBoundingClientRect();
                    if (rect.top <= 100 && rect.bottom >= 100) {
                        this.activeSection = section.id;
                        break;
                    }
                }
            }
        },
    },
};
</script>

<style scoped>
/* Smooth scrolling for anchor links */
html {
    scroll-behavior: smooth;
}

/* Active section indicator animation */
a.text-waste2way-teal .bg-waste2way-teal {
    animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

@keyframes pulse {
    0%,
    100% {
        opacity: 1;
        transform: scale(1);
    }
    50% {
        opacity: 0.7;
        transform: scale(1.2);
    }
}
</style>
