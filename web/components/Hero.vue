<template>
  <section
    class="relative flex flex-col justify-center min-h-screen pt-16 overflow-hidden"
  >
    <!-- Background gradient -->
    <div
      class="absolute inset-0 pointer-events-none bg-gradient-to-b from-transparent via-waste2way-teal/5 to-waste2way-blue/10"
    />

    <!-- Floating icons in background -->
    <div
      ref="iconsRef"
      class="absolute inset-0 overflow-hidden pointer-events-none"
    >
      <div
        class="floating-icon absolute top-1/4 left-[15%] text-waste2way-teal/20 animate-float"
      >
        <Icon name="lucide:recycle" size="80" />
      </div>
      <div
        class="floating-icon absolute top-1/3 right-[20%] text-waste2way-blue/20 animate-float"
      >
        <Icon name="lucide:map-pin" size="60" />
      </div>
      <div
        class="floating-icon absolute bottom-1/4 left-[30%] text-waste2way-green/20 animate-float"
      >
        <Icon name="lucide:smartphone" size="70" />
      </div>
    </div>

    <div class="relative z-10 section-container">
      <div class="max-w-4xl mx-auto text-center">
        <div
          class="inline-block rounded-full bg-waste2way-teal/10 px-4 py-1.5 mb-6"
        >
          <span class="text-sm font-medium text-waste2way-teal"
            >Smart Waste Management for Urban Development</span
          >
        </div>

        <h1 class="mb-6 -space-y-2 text-4xl font-bold md:text-6xl">
          <span class="text-gradient">Transforming Waste</span>
          <br class="hidden sm:block" />
          <span class="text-gradient"> Into Sustainable Infrastructure</span>
        </h1>

        <p
          class="max-w-2xl mx-auto mb-10 text-lg md:text-xl text-muted-foreground"
        >
          Our AI-powered platform optimizes waste collection, sorting, and
          recycling. Through collaboration with local authorities, we’re
          building a sustainable, tech-driven waste management solution.
        </p>

        <div class="flex flex-wrap justify-center gap-4">
          <NuxtLink to="/#download" class="btn-primary">
            Download Our App
          </NuxtLink>
          <NuxtLink to="/#try" class="btn-secondary">
            Try it Out
            <Icon name="lucide:arrow-right" class="inline w-4 h-4 ml-2" />
          </NuxtLink>
        </div>
      </div>

      <div
        class="max-w-6xl p-6 mx-auto mt-20 glass-card dark:glass-card-dark md:p-8 animate-fade-in"
      >
        <div class="grid grid-cols-1 gap-8 md:grid-cols-2">
          <div class="p-4 text-center stagger-item animate-fade-in">
            <div
              class="inline-flex items-center justify-center w-16 h-16 mb-4 rounded-full bg-waste2way-teal/10 text-waste2way-teal"
            >
              <Icon name="lucide:scan" class="w-8 h-8" />
            </div>
            <h3 class="mb-2 text-2xl font-bold">90%+</h3>
            <p class="text-muted-foreground">
              Accuracy in waste identification
            </p>
          </div>

          <div class="p-4 text-center stagger-item animate-fade-in">
            <div
              class="inline-flex items-center justify-center w-16 h-16 mb-4 rounded-full bg-waste2way-blue/10 text-waste2way-blue"
            >
              <Icon name="lucide:map" class="w-8 h-8" />
            </div>
            <h3 class="mb-2 text-2xl font-bold">1+</h3>
            <p class="text-muted-foreground">Cities with waste heat mapping</p>
          </div>

          <!-- <div class="p-4 text-center stagger-item animate-fade-in">
            <div
              class="inline-flex items-center justify-center w-16 h-16 mb-4 rounded-full bg-waste2way-green/10 text-waste2way-green"
            >
              <Icon name="lucide:layout-dashboard" class="w-8 h-8" />
            </div>
            <h3 class="mb-2 text-2xl font-bold">5</h3>
            <p class="text-muted-foreground">
              Integrated APIs for closed-loop systems
            </p>
          </div> -->
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
const iconsRef = ref(null);

onMounted(() => {
  const icons = iconsRef.value?.querySelectorAll(".floating-icon");

  if (icons) {
    icons.forEach((icon, index) => {
      icon.style.animationDelay = `${index * 0.8}s`;
    });
  }
});
</script>

<style scoped>
.animate-float {
  animation: float 6s ease-in-out infinite;
}

@keyframes float {
  0% {
    transform: translateY(0px);
  }
  50% {
    transform: translateY(-20px);
  }
  100% {
    transform: translateY(0px);
  }
}

.animate-fade-in {
  animation: fadeIn 1s ease-in-out forwards;
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

.text-gradient {
  @apply bg-clip-text text-transparent;
}
</style>
