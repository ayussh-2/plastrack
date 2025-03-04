import { defineNuxtPlugin } from "#app";

export default defineNuxtPlugin(async ({ $pinia, app }) => {
    const authStore = useAuthStore();

    const loading = useState("auth:loading", () => true);

    try {
        loading.value = true;

        await authStore.initAuth();
    } finally {
        loading.value = false;
    }
});
