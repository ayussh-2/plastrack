<template>
    <div class="container mx-auto px-4 py-8 max-w-md">
        <h2 class="text-2xl font-bold mb-6 text-center">Register</h2>
        <form @submit.prevent="handleRegister" class="space-y-4">
            <div>
                <label class="block mb-2">Email</label>
                <input
                    v-model="email"
                    type="email"
                    required
                    class="w-full px-3 py-2 border rounded-lg"
                    placeholder="Enter your email"
                />
            </div>
            <div>
                <label class="block mb-2">Password</label>
                <input
                    v-model="password"
                    type="password"
                    required
                    minlength="6"
                    class="w-full px-3 py-2 border rounded-lg"
                    placeholder="Enter your password"
                />
            </div>
            <div>
                <label class="block mb-2">Confirm Password</label>
                <input
                    v-model="confirmPassword"
                    type="password"
                    required
                    class="w-full px-3 py-2 border rounded-lg"
                    placeholder="Confirm your password"
                />
            </div>
            <button
                type="submit"
                :disabled="authStore.loading"
                class="w-full bg-blue-500 text-white py-2 rounded-lg hover:bg-blue-600 disabled:opacity-50"
            >
                {{ authStore.loading ? "Registering..." : "Register" }}
            </button>

            <p v-if="authStore.error" class="text-red-500 text-center">
                {{ authStore.error }}
            </p>
        </form>
    </div>
</template>

<script setup>
definePageMeta({
    middleware: ["auth"],
});

const email = ref("");
const password = ref("");
const confirmPassword = ref("");
const authStore = useAuthStore();

const handleRegister = async () => {
    if (password.value !== confirmPassword.value) {
        authStore.error = "Passwords do not match";
        return;
    }

    try {
        await authStore.register(email.value, password.value);
        await navigateTo("/profile");
    } catch (error) {
        console.error("Registration failed", error);
    }
};
</script>
