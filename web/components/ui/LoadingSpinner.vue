<template>
    <ClientOnly>
        <div
            v-if="isAuthLoading"
            class="h-screen flex justify-center items-center"
        >
            <p>Authentication loading...</p>
            <div class="spinner"></div>
        </div>
    </ClientOnly>
</template>

<script setup>
const isAuthLoading = useState("auth:loading", () => true);
</script>

<style scoped>
.spinner {
    width: 40px;
    height: 40px;
    border: 4px solid #f3f3f3;
    border-top: 4px solid #3498db;
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    0% {
        transform: rotate(0deg);
    }
    100% {
        transform: rotate(360deg);
    }
}
</style>
