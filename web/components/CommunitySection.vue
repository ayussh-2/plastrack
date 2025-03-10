<template>
  <div class="py-16 bg-gradient-to-b from-background to-waste2way-blue/5">
    <div class="section-container">
      <div class="text-center mb-12">
        <h2 class="text-3xl md:text-4xl font-bold mb-4">
          Community & Gamification
        </h2>
        <p class="text-muted-foreground max-w-2xl mx-auto">
          Join a global network of changemakers and earn rewards for your
          contributions.
        </p>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-10">
        <!-- Leaderboard Section -->
        <div class="glass-card dark:glass-card-dark p-6 rounded-2xl">
          <div class="flex items-center justify-between mb-6">
            <h3 class="text-xl font-medium flex items-center">
              <Trophy class="mr-2 h-5 w-5 text-waste2way-coral" />
              Top Contributors
            </h3>
            <router-link
              to="/community"
              class="text-waste2way-blue text-sm flex items-center hover:underline"
            >
              View All <ArrowRight class="ml-1 h-4 w-4" />
            </router-link>
          </div>

          <div class="space-y-2">
            <LeaderboardItem
              v-for="item in leaderboardData"
              :key="item.rank"
              v-bind="item"
            />
          </div>

          <div class="mt-6 pt-6 border-t border-white/10">
            <div class="text-center">
              <p class="text-muted-foreground mb-3">Your current rank</p>
              <div class="inline-flex items-center justify-center space-x-2">
                <div class="w-12 h-12 rounded-full overflow-hidden">
                  <img
                    src="https://i.pravatar.cc/150?img=8"
                    alt="Your Avatar"
                    class="w-full h-full object-cover"
                  />
                </div>
                <div class="text-left">
                  <p class="font-medium">You</p>
                  <p class="text-sm text-muted-foreground">
                    Rank #42 • 578 points
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Achievements Section -->
        <div>
          <h3 class="text-xl font-medium mb-6 flex items-center">
            <Award class="mr-2 h-5 w-5 text-waste2way-teal" />
            Your Achievements
          </h3>

          <div class="space-y-5">
            <AchievementCard
              v-for="(achievement, index) in achievements"
              :key="index"
              v-bind="achievement"
            />
          </div>

          <div class="glass-card dark:glass-card-dark p-6 rounded-2xl mt-8">
            <h4 class="font-medium mb-4">Recent Activity</h4>
            <div class="space-y-4">
              <div class="flex space-x-3">
                <div class="w-1 bg-waste2way-teal rounded-full"></div>
                <div>
                  <p class="text-sm">You identified a new PET waste sample</p>
                  <p class="text-xs text-muted-foreground">
                    2 hours ago • +15 points
                  </p>
                </div>
              </div>
              <div class="flex space-x-3">
                <div class="w-1 bg-waste2way-blue rounded-full"></div>
                <div>
                  <p class="text-sm">
                    You reached level 5 in waste identification
                  </p>
                  <p class="text-xs text-muted-foreground">
                    Yesterday • Achievement unlocked
                  </p>
                </div>
              </div>
              <div class="flex space-x-3">
                <div class="w-1 bg-waste2way-coral rounded-full"></div>
                <div>
                  <p class="text-sm">
                    You reported a waste hotspot in your area
                  </p>
                  <p class="text-xs text-muted-foreground">
                    3 days ago • +30 points
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="mt-12 text-center">
        <router-link to="/community" class="btn-primary">
          Join Our Community
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Trophy, Users, Globe, Award, ArrowRight } from "lucide-vue-next";

interface LeaderboardItemProps {
  rank: number;
  name: string;
  contributions: number;
  avatar: string;
}

const leaderboardData: LeaderboardItemProps[] = [
  {
    rank: 1,
    name: "Alex Johnson",
    contributions: 2437,
    avatar: "https://i.pravatar.cc/150?img=1",
  },
  {
    rank: 2,
    name: "Maria Garcia",
    contributions: 2180,
    avatar: "https://i.pravatar.cc/150?img=5",
  },
  {
    rank: 3,
    name: "James Wilson",
    contributions: 1945,
    avatar: "https://i.pravatar.cc/150?img=3",
  },
  {
    rank: 4,
    name: "Emma Brown",
    contributions: 1832,
    avatar: "https://i.pravatar.cc/150?img=9",
  },
  {
    rank: 5,
    name: "David Lee",
    contributions: 1756,
    avatar: "https://i.pravatar.cc/150?img=4",
  },
];

const achievements = [
  {
    icon: h(Globe, { class: "h-6 w-6 text-waste2way-teal" }),
    title: "Global Impact",
    description: "Contribute to global waste reduction",
    progress: 75,
  },
  {
    icon: h(Users, { class: "h-6 w-6 text-waste2way-blue" }),
    title: "Community Leader",
    description: "Organize community clean-up events",
    progress: 40,
  },
  {
    icon: h(Award, { class: "h-6 w-6 text-waste2way-coral" }),
    title: "Waste Pioneer",
    description: "First to identify new waste types",
    progress: 90,
  },
];
</script>

<script lang="ts">
// LeaderboardItem component
const LeaderboardItem = defineComponent({
  props: {
    rank: { type: Number, required: true },
    name: { type: String, required: true },
    contributions: { type: Number, required: true },
    avatar: { type: String, required: true },
  },
  template: `
    <div class="flex items-center justify-between py-3 border-b border-white/10 last:border-0">
      <div class="flex items-center space-x-3">
        <div class="w-8 h-8 flex items-center justify-center font-medium">
          {{ rank }}
        </div>
        <div class="w-10 h-10 rounded-full overflow-hidden">
          <img :src="avatar" :alt="name" class="w-full h-full object-cover" />
        </div>
        <span class="font-medium">{{ name }}</span>
      </div>
      <div class="flex items-center">
        <span class="font-medium">{{ contributions }}</span>
        <Trophy class="w-4 h-4 ml-2 text-waste2way-coral" />
      </div>
    </div>
  `,
});

// AchievementCard component
const AchievementCard = defineComponent({
  props: {
    icon: { type: Object, required: true },
    title: { type: String, required: true },
    description: { type: String, required: true },
    progress: { type: Number, required: true },
  },
  template: `
    <div class="glass-card dark:glass-card-dark p-5 rounded-xl transition-all hover:shadow-lg hover:-translate-y-1">
      <div class="flex items-center space-x-4 mb-3">
        <div class="p-3 rounded-full bg-waste2way-teal/10">
          <component :is="icon" />
        </div>
        <div>
          <h3 class="font-medium">{{ title }}</h3>
          <p class="text-sm text-muted-foreground">{{ description }}</p>
        </div>
      </div>
      <div class="mt-2">
        <div class="flex justify-between text-sm mb-1">
          <span>Progress</span>
          <span class="font-medium">{{ progress }}%</span>
        </div>
        <div class="w-full bg-muted rounded-full h-2">
          <div 
            class="bg-gradient-to-r from-waste2way-teal to-waste2way-blue h-2 rounded-full"
            :style="{ width: progress + '%' }"
          ></div>
        </div>
      </div>
    </div>
  `,
});

export default {
  components: {
    LeaderboardItem,
    AchievementCard,
    Trophy,
    Users,
    Globe,
    Award,
    ArrowRight,
  },
};
</script>
