<template>
  <section
    class="relative min-h-screen flex flex-col justify-center overflow-hidden pt-16"
  >
    <!-- Background gradient -->
    <div
      class="absolute inset-0 bg-gradient-to-b from-transparent via-waste2way-teal/5 to-waste2way-blue/10 pointer-events-none"
    />

    <!-- Floating icons in background -->
    <div
      ref="iconsRef"
      class="absolute inset-0 pointer-events-none overflow-hidden"
    >
      <div
        class="floating-icon absolute top-1/4 left-[15%] text-waste2way-teal/20 animate-float"
      >
        <Recycle :size="80" />
      </div>
      <div
        class="floating-icon absolute top-1/3 right-[20%] text-waste2way-blue/20 animate-float"
      >
        <MapPin :size="60" />
      </div>
      <div
        class="floating-icon absolute bottom-1/4 left-[30%] text-waste2way-green/20 animate-float"
      >
        <BarChart3 :size="70" />
      </div>
    </div>

    <div class="section-container relative z-10">
      <div class="max-w-4xl mx-auto text-center">
        <div
          class="inline-block rounded-full bg-waste2way-teal/10 px-4 py-1.5 mb-6"
        >
          <span class="text-waste2way-teal text-sm font-medium"
            >Transforming Waste Into Opportunity</span
          >
        </div>

        <h1 class="text-4xl md:text-6xl font-bold mb-6 leading-tight">
          <span class="text-gradient">Plastic Waste</span> to
          <br class="hidden sm:block" />
          <span class="text-gradient"> Sustainable Infrastructure</span>
        </h1>

        <p
          class="text-lg md:text-xl text-muted-foreground mb-10 max-w-2xl mx-auto"
        >
          An AI-powered platform turning plastic pollution into durable urban
          infrastructure. Join us in creating a circular economy for plastic
          waste.
        </p>

        <div class="flex flex-wrap justify-center gap-4">
          <NuxtLink to="/features" class="btn-primary">
            Explore Features
          </NuxtLink>
          <NuxtLink to="/dashboard" class="btn-secondary">
            View Dashboard <ArrowRight class="ml-2 h-4 w-4 inline" />
          </NuxtLink>
        </div>
      </div>

      <div
        class="mt-20 max-w-6xl mx-auto glass-card dark:glass-card-dark p-6 md:p-8 animate-fade-in"
      >
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div class="stagger-item animate-fade-in p-4 text-center">
            <div
              class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-waste2way-teal/10 text-waste2way-teal mb-4"
            >
              <Recycle class="h-8 w-8" />
            </div>
            <h3 class="text-2xl font-bold mb-2">8.5M+</h3>
            <p class="text-muted-foreground">Tons of plastic waste processed</p>
          </div>

          <div class="stagger-item animate-fade-in p-4 text-center">
            <div
              class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-waste2way-blue/10 text-waste2way-blue mb-4"
            >
              <MapPin class="h-8 w-8" />
            </div>
            <h3 class="text-2xl font-bold mb-2">150+</h3>
            <p class="text-muted-foreground">
              Cities implementing our solutions
            </p>
          </div>

          <div class="stagger-item animate-fade-in p-4 text-center">
            <div
              class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-waste2way-green/10 text-waste2way-green mb-4"
            >
              <BarChart3 class="h-8 w-8" />
            </div>
            <h3 class="text-2xl font-bold mb-2">43%</h3>
            <p class="text-muted-foreground">
              Average CO₂ reduction in projects
            </p>
          </div>
        </div>
      </div>
    </div>

    <!-- Scroll down indicator -->
    <div
      class="absolute bottom-10 left-1/2 transform -translate-x-1/2 text-center"
    >
      <div class="animate-bounce">
        <div
          class="w-1 h-10 mx-auto bg-gradient-to-b from-foreground/30 to-foreground/5 rounded-full"
        ></div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
const iconsRef = ref<HTMLDivElement | null>(null);

onMounted(() => {
  const icons = iconsRef.value?.querySelectorAll(".floating-icon");

  if (icons) {
    icons.forEach((icon, index) => {
      const element = icon as HTMLElement;
      element.style.animationDelay = `${index * 0.8}s`;
    });
  }
});
</script>

<style>
.floating-icon {
  animation: float 6s ease-in-out infinite;
}

@keyframes float {
  0%,
  100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-20px);
  }
}

.text-gradient {
  @apply bg-clip-text text-transparent bg-gradient-to-r from-waste2way-teal to-waste2way-blue;
}

.glass-card {
  @apply bg-white/70 backdrop-blur-lg rounded-xl shadow-lg;
}

.glass-card-dark {
  @apply bg-gray-900/70;
}

.animate-fade-in {
  animation: fadeIn 0.5s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
