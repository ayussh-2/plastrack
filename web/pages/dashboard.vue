<template>
    <client-only>
        <div class="container mx-auto px-4 py-8">
            <h1 class="text-3xl font-bold mb-6">Dashboard</h1>

            <div
                v-if="authStore.user"
                class="bg-white shadow-md rounded-lg p-6"
            >
                <h2 class="text-xl mb-4">
                    Welcome, {{ authStore.user.email }}
                </h2>

                <div class="space-y-4">
                    <p>User ID: {{ authStore.user.uid }}</p>
                    <p>
                        Email Verified:
                        {{ authStore.user.emailVerified ? "Yes" : "No" }}
                    </p>

                    <button
                        @click="handleLogout"
                        class="bg-red-500 text-white px-4 py-2 rounded-lg hover:bg-red-600"
                    >
                        Logout
                    </button>
                </div>
            </div>
        </div>
    </client-only>
</template>

<script setup>
definePageMeta({
    middleware: ["auth"],
});

const authStore = useAuthStore();

const handleLogout = async () => {
    try {
        await authStore.logout();
        await navigateTo("/login");
    } catch (error) {
        console.error("Logout failed", error);
    }
};
</script>
