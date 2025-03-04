import { defineNuxtPlugin } from "#app";

export default defineNuxtPlugin(async ({ $pinia, app }) => {
    const authStore = useAuthStore();

    const loading = useState("auth:loading", () => true);

    if (process.client) {
        try {
            await authStore.initAuth();
            console.log("After initAuth call");
        } finally {
            loading.value = false;
        }
    } else {
        authStore.setInitialized(false);
    }
});
