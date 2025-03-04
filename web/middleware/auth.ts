import { useAuthStore } from "~/stores/auth";

export default defineNuxtRouteMiddleware((to) => {
    const authStore = useAuthStore();
    const loading = useState("auth:loading");
    const publicRoutes = ["/", "/login", "/register"];
    if (loading.value || !authStore.initialized) {
        return;
    }

    if (!authStore.isAuthenticated && !publicRoutes.includes(to.path)) {
        return navigateTo("/login");
    }

    if (authStore.isAuthenticated && publicRoutes.slice(1).includes(to.path)) {
        return navigateTo("/dashboard");
    }
});
