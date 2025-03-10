<template>
  <div
    :class="[
      'p-6 rounded-2xl transition-all backdrop-blur-md',
      'bg-white/10 dark:bg-black/20 border border-white/20 dark:border-white/10',
      'shadow-lg',
    ]"
  >
    <h3 class="text-lg font-medium mb-4">{{ title }}</h3>
    <div class="h-80">
      <slot :height="320"></slot>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  title: string;
}>();
</script>
