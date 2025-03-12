<template>
  <div class="p-5 glass-card dark:glass-card-dark rounded-xl">
    <div class="flex items-center mb-2 space-x-2">
      <div
        class="flex items-center justify-center w-8 h-8 rounded-full bg-waste2way-teal/10"
      >
        <slot name="icon">
          <MapPin class="w-4 h-4 text-waste2way-teal" />
        </slot>
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

defineProps({
  title: { type: String, required: true },
  value: { type: String, required: true },
  change: { type: String, default: undefined },
  positive: { type: Boolean, default: true }
});
</script>