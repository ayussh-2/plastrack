<template>
  <div class="py-16 bg-gradient-to-b from-background to-waste2way-blue/5">
    <div class="section-container">
      <div class="mb-12 text-center">
        <h2 class="mb-4 text-3xl font-bold md:text-4xl">
          Community & Gamification
        </h2>
        <p class="max-w-2xl mx-auto text-muted-foreground">
          Join a global network of changemakers and earn rewards for your
          contributions.
        </p>
      </div>

      <div class="grid grid-cols-1 gap-10 lg:grid-cols-1">
        <!-- Leaderboard Section -->
        <div class="p-6 glass-card dark:glass-card-dark rounded-2xl">
          <div class="flex items-center justify-between mb-6">
            <h3 class="flex items-center text-xl font-medium">
              <Trophy class="w-5 h-5 mr-2 text-waste2way-coral" />
              Top Contributors
            </h3>
            <router-link
              to="/community"
              class="flex items-center text-sm text-waste2way-blue hover:underline"
            >
              View All <ArrowRight class="w-4 h-4 ml-1" />
            </router-link>
          </div>

          <div class="space-y-2">
            <LeaderboardItem
              v-for="item in leaderboardData"
              :key="item.rank"
              :rank="item.rank"
              :name="item.name"
              :contributions="item.contributions"
              :avatar="item.avatar"
            />
          </div>

          <div class="pt-6 mt-6 border-t border-white/10">
            <div class="text-center">
              <p class="mb-3 text-muted-foreground">Your current rank</p>
              <div class="inline-flex items-center justify-center space-x-2">
                <div class="w-12 h-12 overflow-hidden rounded-full">
                  <img
                    src="https://i.pravatar.cc/150?img=8"
                    alt="Your Avatar"
                    class="object-cover w-full h-full"
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

        
      </div>

      <div class="mt-12 text-center">
        <router-link to="/community" class="btn-primary">
          Join Our Community
        </router-link>
      </div>
    </div>
  </div>
</template>

<script>
import { Trophy, Users, Globe, Award, ArrowRight } from "lucide-vue-next";
import AchievementCard from "./AchievementCard.vue";
import LeaderboardItem from "./LeaderboardItem.vue";

// const LeaderboardItem = {
//   props: {
//     rank: {
//       type: Number,
//       required: true,
//     },
//     name: {
//       type: String,
//       required: true,
//     },
//     contributions: {
//       type: Number,
//       required: true,
//     },
//     avatar: {
//       type: String,
//       required: true,
//     },
//   },
//   template: `
//       <div class="flex items-center justify-between py-3 border-b border-white/10 last:border-0">
//         <div class="flex items-center space-x-3">
//           <div class="flex items-center justify-center w-8 h-8 font-medium">
//             {{ rank }}
//           </div>
//           <div class="w-10 h-10 overflow-hidden rounded-full">
//             <img :src="avatar" :alt="name" class="object-cover w-full h-full" />
//           </div>
//           <span class="font-medium">{{ name }}</span>
//         </div>
//         <div class="flex items-center">
//           <span class="font-medium">{{ contributions }}</span>
//           <Trophy class="w-4 h-4 ml-2 text-waste2way-coral" />
//         </div>
//       </div>
//     `,
// };

// const AchievementCard = {
//   props: {
//     icon: {
//       type: Object,
//       required: true,
//     },
//     title: {
//       type: String,
//       required: true,
//     },
//     description: {
//       type: String,
//       required: true,
//     },
//     progress: {
//       type: Number,
//       required: true,
//     },
//   },
//   template: `
//       <div class="p-5 transition-all glass-card dark:glass-card-dark rounded-xl hover:shadow-lg hover:-translate-y-1">
//         <div class="flex items-center mb-3 space-x-4">
//           <div class="p-3 rounded-full bg-waste2way-teal/10">
//             <component :is="icon" />
//           </div>
//           <div>
//             <h3 class="font-medium">{{ title }}</h3>
//             <p class="text-sm text-muted-foreground">{{ description }}</p>
//           </div>
//         </div>
//         <div class="mt-2">
//           <div class="flex justify-between mb-1 text-sm">
//             <span>Progress</span>
//             <span class="font-medium">{{ progress }}%</span>
//           </div>
//           <div class="w-full h-2 rounded-full bg-muted">
//             <div
//               class="h-2 rounded-full bg-gradient-to-r from-waste2way-teal to-waste2way-blue"
//               :style="{ width: progress + '%' }"
//             ></div>
//           </div>
//         </div>
//       </div>
//     `,
// };

export default {
  name: "CommunitySection",
  components: {
    Trophy,
    Users,
    Globe,
    Award,
    ArrowRight,
    LeaderboardItem,
    AchievementCard,
  },
  data() {
    return {
      leaderboardData: [
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
      ],
      achievements: [
        {
          icon: Globe,
          title: "Global Impact",
          description: "Contribute to global waste reduction",
          progress: 75,
        },
        {
          icon: Users,
          title: "Community Leader",
          description: "Organize community clean-up events",
          progress: 40,
        },
        {
          icon: Award,
          title: "Waste Pioneer",
          description: "First to identify new waste types",
          progress: 90,
        },
      ],
    };
  },
};
</script>
