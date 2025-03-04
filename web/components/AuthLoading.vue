<template>
    <div v-if="isLoading" class="auth-loading">
        <div class="loader"></div>
        <p>Loading authentication...</p>
    </div>
</template>

<script setup>
const loading = useState("auth:loading");
const authStore = useAuthStore();

const isLoading = computed(() => {
    return loading.value || !authStore.initialized;
});
</script>

<style scoped>
.auth-loading {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    background-color: rgba(255, 255, 255, 0.9);
    z-index: 1000;
}

.loader {
    border: 5px solid #f3f3f3;
    border-top: 5px solid #3498db;
    border-radius: 50%;
    width: 50px;
    height: 50px;
    animation: spin 1s linear infinite;
    margin-bottom: 20px;
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
