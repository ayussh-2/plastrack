<template>
  <div
    class="p-5 transition-all glass-card dark:glass-card-dark rounded-xl hover:shadow-lg hover:-translate-y-1"
  >
    <div class="flex items-center mb-3 space-x-4">
      <div class="p-3 rounded-full bg-waste2way-teal/10">
        <component :is="icon" />
      </div>
      <div>
        <h3 class="font-medium">{{ title }}</h3>
        <p class="text-sm text-muted-foreground">{{ description }}</p>
      </div>
    </div>
    <div class="mt-2">
      <div class="flex justify-between mb-1 text-sm">
        <span>Progress</span>
        <span class="font-medium">{{ progress }}%</span>
      </div>
      <div class="w-full h-2 rounded-full bg-muted">
        <div
          class="h-2 rounded-full bg-gradient-to-r from-waste2way-teal to-waste2way-blue"
          :style="{ width: progress + '%' }"
        ></div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "AchievementCard",
  props: {
    icon: {
      type: [Object, Function], // Accept both Object and Function types
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
    progress: {
      type: Number,
      required: true,
    },
  },
};
</script>
