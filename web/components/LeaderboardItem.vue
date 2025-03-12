<template>
  <div
    class="flex items-center justify-between py-3 border-b border-white/10 last:border-0"
  >
    <div class="flex items-center space-x-3">
      <div class="flex items-center justify-center w-8 h-8 font-medium">
        {{ rank }}
      </div>
      <div class="w-10 h-10 overflow-hidden rounded-full">
        <img :src="avatar" :alt="name" class="object-cover w-full h-full" />
      </div>
      <span class="font-medium">{{ name }}</span>
    </div>
    <div class="flex items-center">
      <span class="font-medium">{{ contributions }}</span>
      <Trophy class="w-4 h-4 ml-2 text-waste2way-coral" />
    </div>
  </div>
</template>

<script>
import { Trophy } from "lucide-vue-next";

export default {
  name: "LeaderboardItem",
  components: {
    Trophy,
  },
  props: {
    rank: {
      type: Number,
      required: true,
    },
    name: {
      type: String,
      required: true,
    },
    contributions: {
      type: Number,
      required: true,
    },
    avatar: {
      type: String,
      required: true,
    },
  },
};
</script>
