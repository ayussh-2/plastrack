import { useAuthStore } from "~/stores/auth";

export default defineNuxtRouteMiddleware((to) => {
    const authStore = useAuthStore();
    const publicRoutes = ["/", "/login", "/register"];

    if (!authStore.isAuthenticated && !publicRoutes.includes(to.path)) {
        return navigateTo("/login");
    }

    if (authStore.isAuthenticated && publicRoutes.slice(1).includes(to.path)) {
        return navigateTo("/dashboard");
    }
});
