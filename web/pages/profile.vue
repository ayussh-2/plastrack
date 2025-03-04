<template>
    <div class="container mx-auto px-4 py-8">
        <h1 class="text-3xl font-bold mb-4">User Profile</h1>
        <div v-if="authStore.user">
            <p>Email: {{ authStore.user.email }}</p>
            <p>Display Name: {{ authStore.getUserDisplayName }}</p>
        </div>
        <div v-else>
            <p>Please log in to view your profile</p>
        </div>
    </div>
</template>

<script setup>
definePageMeta({
    middleware: ["auth"],
});

const authStore = useAuthStore();
</script>
