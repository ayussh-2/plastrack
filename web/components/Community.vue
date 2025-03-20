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
            <!-- <router-link
              to="/community"
              class="flex items-center text-sm text-waste2way-blue hover:underline"
            >
              View All <ArrowRight class="w-4 h-4 ml-1" />
            </router-link> -->
          </div>

          <div class="space-y-2">
            <div v-if="isLoading" class="py-4 text-center">
              <span>Loading leaderboard...</span>
            </div>

            <div v-else-if="error" class="py-4 text-center text-red-500">
              {{ error }}
            </div>

            <template v-else>
              <LeaderboardItem
                v-for="item in leaderboardData"
                :key="item.rank"
                :rank="item.rank"
                :name="item.name"
                :contributions="item.contributions"
                :avatar="item.avatar"
              />
            </template>
          </div>

          <!-- <div class="pt-6 mt-6 border-t border-white/10">
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
          </div> -->
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
      leaderboardData: [],
      isLoading: false,
      error: null,
      achievements: [
        // ...existing achievements data...
      ],
    };
  },
  async created() {
    try {
      this.isLoading = true;
      const response = await fetch(
        "http://localhost:4000/api/game/leaderboard?limit=5"
      );

      if (!response.ok) {
        throw new Error("Failed to fetch leaderboard data");
      }

      const data = await response.json();

      // Transform the API data to match our component's structure
      this.leaderboardData = data.data.users.map((user, index) => ({
        rank: index + 1,
        name: user.name,
        contributions: user.points,
        avatar:
          user.profilePicture || `https://i.pravatar.cc/150?img=${index + 1}`,
      }));
    } catch (error) {
      this.error = "Failed to load leaderboard data";
      console.error("Error:", error);
    } finally {
      this.isLoading = false;
    }
  },
};
</script>
