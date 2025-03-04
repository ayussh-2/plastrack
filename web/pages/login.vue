<template>
    <div class="min-h-screen flex items-center justify-center bg-gray-100">
        <div class="bg-white p-8 rounded-lg shadow-md w-full max-w-md">
            <h2 class="text-2xl font-bold mb-6 text-center">Login</h2>
            <form @submit.prevent="handleLogin" class="space-y-4">
                <div>
                    <label class="block text-gray-700 mb-2">Email</label>
                    <input
                        v-model="email"
                        type="email"
                        required
                        class="w-full px-3 py-2 border rounded-lg"
                        placeholder="Enter your email"
                    />
                </div>
                <div>
                    <label class="block text-gray-700 mb-2">Password</label>
                    <input
                        v-model="password"
                        type="password"
                        required
                        class="w-full px-3 py-2 border rounded-lg"
                        placeholder="Enter your password"
                    />
                </div>
                <button
                    type="submit"
                    :disabled="authStore.loading"
                    class="w-full bg-blue-500 text-white py-2 rounded-lg hover:bg-blue-600 disabled:opacity-50"
                >
                    {{ authStore.loading ? "Logging in..." : "Login" }}
                </button>

                <p v-if="authStore.error" class="text-red-500 text-center">
                    {{ authStore.error }}
                </p>

                <div class="text-center">
                    <NuxtLink
                        to="/register"
                        class="text-blue-500 hover:underline"
                    >
                        Create an account
                    </NuxtLink>
                </div>
            </form>
        </div>
    </div>
</template>

<script setup>
definePageMeta({
    middleware: ["auth"],
});
const email = ref("");
const password = ref("");
const authStore = useAuthStore();

const handleLogin = async () => {
    try {
        await authStore.login(email.value, password.value);
        await navigateTo("/dashboard");
    } catch (error) {
        console.error("Login failed", error);
    }
};
</script>
