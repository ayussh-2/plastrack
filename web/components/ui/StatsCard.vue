<template>
  <div class="glass-card dark:glass-card-dark p-5 rounded-xl">
    <div class="flex items-center space-x-2 mb-2">
      <div
        class="w-8 h-8 rounded-full bg-waste2way-teal/10 flex items-center justify-center"
      >
        <component :is="icon" class="h-4 w-4 text-waste2way-teal" v-if="icon" />
        <MapPin v-else class="h-4 w-4 text-waste2way-teal" />
      </div>
      <p class="text-sm text-muted-foreground">{{ title }}</p>
    </div>
    <div class="flex items-baseline space-x-2">
      <h3 class="text-2xl font-bold">{{ value }}</h3>
      <span
        v-if="change"
        :class="
          positive
            ? 'text-waste2way-green text-sm'
            : 'text-waste2way-coral text-sm'
        "
      >
        {{ positive ? "+" : "-" }}{{ change }}
      </span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { MapPin } from "lucide-vue-next";

defineProps<{
  title: string;
  value: string;
  change?: string;
  positive?: boolean;
  icon?: any;
}>();
</script>
