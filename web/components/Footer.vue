<template>
    <footer
        class="bg-gradient-to-b from-waste2way-dark to-waste2way-dark/95 text-white pt-16 pb-8"
    >
        <div class="container mx-auto px-4">
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-10">
                <div>
                    <div class="flex items-center space-x-2 mb-6">
                        <Icon
                            name="mdi:recycle"
                            class="h-8 w-8 text-waste2way-teal"
                        />
                        <span class="font-display font-bold text-xl"
                            >Waste2Way</span
                        >
                    </div>
                    <p class="text-white/60 mb-6">
                        Transforming plastic waste into sustainable urban
                        infrastructure through AI-powered solutions.
                    </p>
                    <div class="flex space-x-4">
                        <a
                            href="#"
                            class="text-white/60 hover:text-waste2way-teal transition-colors"
                        >
                            <Icon name="mdi:twitter" class="h-5 w-5" />
                        </a>
                        <a
                            href="#"
                            class="text-white/60 hover:text-waste2way-teal transition-colors"
                        >
                            <Icon name="mdi:facebook" class="h-5 w-5" />
                        </a>
                        <a
                            href="#"
                            class="text-white/60 hover:text-waste2way-teal transition-colors"
                        >
                            <Icon name="mdi:instagram" class="h-5 w-5" />
                        </a>
                        <a
                            href="#"
                            class="text-white/60 hover:text-waste2way-teal transition-colors"
                        >
                            <Icon name="mdi:email" class="h-5 w-5" />
                        </a>
                    </div>
                </div>

                <div>
                    <h3 class="text-lg font-medium mb-6">Quick Links</h3>
                    <ul class="space-y-3">
                        <li v-for="item in quickLinks" :key="item">
                            <NuxtLink
                                :to="
                                    item === 'Home'
                                        ? '/'
                                        : `/${item.toLowerCase()}`
                                "
                                class="text-white/60 hover:text-waste2way-teal transition-colors flex items-center"
                            >
                                <Icon
                                    name="mdi:chevron-right"
                                    class="h-4 w-4 mr-2"
                                />
                                {{ item }}
                            </NuxtLink>
                        </li>
                    </ul>
                </div>

                <div>
                    <h3 class="text-lg font-medium mb-6">Resources</h3>
                    <ul class="space-y-3">
                        <li v-for="item in resources" :key="item">
                            <a
                                href="#"
                                class="text-white/60 hover:text-waste2way-teal transition-colors flex items-center"
                            >
                                <Icon
                                    name="mdi:chevron-right"
                                    class="h-4 w-4 mr-2"
                                />
                                {{ item }}
                            </a>
                        </li>
                    </ul>
                </div>

                <div>
                    <h3 class="text-lg font-medium mb-6">Newsletter</h3>
                    <p class="text-white/60 mb-4">
                        Subscribe to our newsletter for the latest updates on
                        waste transformation.
                    </p>
                    <form class="mb-6" @submit.prevent="submitNewsletter">
                        <div class="flex">
                            <input
                                v-model="email"
                                type="email"
                                placeholder="Your email"
                                class="flex-grow px-4 py-2 bg-white/10 border border-white/20 rounded-l-lg focus:outline-none focus:ring-2 focus:ring-waste2way-teal/50"
                            />
                            <button
                                type="submit"
                                class="bg-waste2way-teal hover:bg-waste2way-teal/90 text-white px-4 py-2 rounded-r-lg transition-colors"
                            >
                                <Icon
                                    name="mdi:chevron-right"
                                    class="h-5 w-5"
                                />
                            </button>
                        </div>
                    </form>
                    <div class="flex items-center space-x-2 text-white/60">
                        <Icon name="mdi:earth" class="h-4 w-4" />
                        <span>Available in 12 countries</span>
                    </div>
                </div>
            </div>

            <div
                class="mt-16 pt-8 border-t border-white/10 flex flex-col md:flex-row justify-between items-center"
            >
                <p class="text-white/60 text-sm mb-4 md:mb-0">
                    &copy; {{ currentYear }} Waste2Way. All rights reserved.
                </p>
                <div class="flex space-x-6">
                    <a
                        href="#"
                        class="text-white/60 hover:text-waste2way-teal text-sm transition-colors"
                    >
                        Privacy Policy
                    </a>
                    <a
                        href="#"
                        class="text-white/60 hover:text-waste2way-teal text-sm transition-colors"
                    >
                        Terms of Service
                    </a>
                    <a
                        href="#"
                        class="text-white/60 hover:text-waste2way-teal text-sm transition-colors"
                    >
                        Contact Us
                    </a>
                </div>
            </div>
        </div>
    </footer>
</template>

<script>
export default {
    name: "Footer",
    data() {
        return {
            email: "",
            quickLinks: ["Home", "Features", "Dashboard", "Community"],
            resources: [
                "Documentation",
                "APIs",
                "Case Studies",
                "Research Papers",
            ],
        };
    },
    computed: {
        currentYear() {
            return new Date().getFullYear();
        },
    },
    methods: {
        submitNewsletter() {
            // Handle newsletter submission
            console.log("Newsletter subscription for:", this.email);
            this.email = "";
        },
    },
};
</script>
