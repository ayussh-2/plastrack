<script setup lang="ts">
import DefaultTheme from "./layouts/DefaultTheme.vue";
</script>

<!-- app.vue -->
<template>
  <div>
    <AuthLoading />
    <DefaultTheme><NuxtPage /></DefaultTheme>
  </div>
</template>
