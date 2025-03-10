<template>
    <div class="flex flex-col min-h-screen">
      <Navbar />
      <main class="flex-grow">
        <slot></slot>
      </main>
      <!-- <Footer/> -->
    </div>
  </template>
  
  <script setup lang="ts">
  onMounted(() => {
    const main = document.querySelector('main')
    if (main) {
      main.classList.add('page-transition')
    }
  })
  </script>
  
  <style>
  .page-transition {
    transition: all 0.3s ease-in-out;
  }
  </style>