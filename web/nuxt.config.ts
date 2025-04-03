import tailwindcss from "@tailwindcss/vite";
export default defineNuxtConfig({
    compatibilityDate: "2024-11-01",
    ssr: true,
    devtools: { enabled: true },
    css: ["~/assets/css/main.css"],
    vite: {
        plugins: [tailwindcss()],
    },
    plugins: ["~/plugins/firebase.ts"],
    modules: [
        [
            "@pinia/nuxt",
            {
                autoImports: ["defineStore", "storeToRefs"],
            },
        ],
        "@nuxt/icon",
    ],

    runtimeConfig: {
        public: {
            firebaseApiKey: process.env.FIREBASE_API_KEY,
            firebaseAuthDomain: process.env.FIREBASE_AUTH_DOMAIN,
            firebaseProjectId: process.env.FIREBASE_PROJECT_ID,
            firebaseStorageBucket: process.env.FIREBASE_STORAGE_BUCKET,
            firebaseMessagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID,
            firebaseAppId: process.env.FIREBASE_APP_ID,
            firebaseMeasurementId: process.env.FIREBASE_MEASUREMENT_ID,
            apiBaseUrl: process.env.API_BASE_URL,
            googleMapsApiKey: process.env.NUXT_PUBLIC_GOOGLE_MAPS_API_KEY,
            cloudinaryCloudName: process.env.NUXT_PUBLIC_CLOUDINARY_CLOUD_NAME,
            cloudinaryUploadPreset:
                process.env.NUXT_PUBLIC_CLOUDINARY_UPLOAD_PRESET,
        },
    },
});
