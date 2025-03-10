<template>
  <div class="py-16">
    <div class="section-container">
      <div class="text-center mb-12">
        <h2 class="text-3xl md:text-4xl font-bold mb-4">
          Waste Identification
        </h2>
        <p class="text-muted-foreground max-w-2xl mx-auto">
          Our AI-powered system can identify plastic types and determine their
          suitability for infrastructure projects.
        </p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-10">
        <div>
          <div
            v-if="!image"
            :class="[
              'border-2 border-dashed rounded-2xl h-80 flex flex-col items-center justify-center p-6 transition-all',
              isDragging
                ? 'border-waste2way-teal bg-waste2way-teal/5'
                : 'border-border bg-white/5 dark:bg-black/5',
            ]"
            @dragover.prevent="isDragging = true"
            @dragleave.prevent="isDragging = false"
            @drop.prevent="handleFileDrop"
          >
            <Upload class="h-12 w-12 text-muted-foreground mb-4" />
            <h3 class="text-xl font-medium mb-2">Drag & drop image</h3>
            <p class="text-muted-foreground text-center mb-6">
              Upload a photo of plastic waste to analyze its composition and
              potential uses
            </p>

            <label class="btn-primary cursor-pointer">
              <input
                type="file"
                class="hidden"
                accept="image/*"
                @change="handleFileSelect"
              />
              <FileUp class="h-4 w-4 mr-2 inline" />
              Upload Image
            </label>
          </div>

          <div v-else class="relative rounded-2xl overflow-hidden h-80 group">
            <img
              :src="image"
              alt="Uploaded plastic waste"
              class="w-full h-full object-cover"
            />
            <button
              @click="resetAnalysis"
              class="absolute top-4 right-4 bg-waste2way-dark/60 text-white rounded-full p-2 opacity-0 group-hover:opacity-100 transition-opacity"
            >
              <X class="h-5 w-5" />
            </button>
          </div>
        </div>

        <div class="glass-card dark:glass-card-dark p-6">
          <div
            v-if="!image"
            class="h-full flex flex-col items-center justify-center text-center p-6"
          >
            <div
              class="w-16 h-16 rounded-full bg-waste2way-blue/10 flex items-center justify-center mb-4"
            >
              <Upload class="h-8 w-8 text-waste2way-blue" />
            </div>
            <h3 class="text-xl font-medium mb-2">No Image Uploaded</h3>
            <p class="text-muted-foreground">
              Upload an image to identify plastic waste type and assess its
              infrastructure potential.
            </p>
          </div>

          <div
            v-else-if="analyzing"
            class="h-full flex flex-col items-center justify-center p-6"
          >
            <div
              class="w-20 h-20 rounded-full border-4 border-waste2way-teal/30 border-t-waste2way-teal animate-spin mb-6"
            ></div>
            <h3 class="text-xl font-medium mb-2">Analyzing Waste Sample</h3>
            <p class="text-muted-foreground">
              Our AI is identifying plastic type and assessing infrastructure
              suitability...
            </p>
          </div>

          <div v-else-if="results" class="h-full">
            <div class="flex items-center mb-6">
              <div
                class="w-12 h-12 rounded-full bg-waste2way-green/10 flex items-center justify-center mr-4"
              >
                <Check class="h-6 w-6 text-waste2way-green" />
              </div>
              <div>
                <h3 class="text-xl font-medium">{{ results.type }}</h3>
                <p class="text-muted-foreground">
                  Identified with {{ results.confidence.toFixed(1) }}%
                  confidence
                </p>
              </div>
            </div>

            <div class="mb-6">
              <div class="flex justify-between mb-2">
                <span class="text-sm font-medium">Recyclability</span>
                <span
                  :class="[
                    'text-sm font-medium',
                    results.recyclable
                      ? 'text-waste2way-green'
                      : 'text-waste2way-coral',
                  ]"
                >
                  {{ results.recyclable ? "Recyclable" : "Non-recyclable" }}
                </span>
              </div>
            </div>

            <div>
              <h4 class="font-medium mb-3">Infrastructure Suitability</h4>
              <div class="space-y-3">
                <div v-for="(item, index) in results.suitability" :key="index">
                  <div class="flex justify-between mb-1">
                    <span class="text-sm">{{ item.purpose }}</span>
                    <span class="text-sm font-medium">{{ item.score }}%</span>
                  </div>
                  <div class="w-full bg-muted rounded-full h-2">
                    <div
                      class="bg-gradient-to-r from-waste2way-teal to-waste2way-blue h-2 rounded-full"
                      :style="{ width: `${item.score}%` }"
                    ></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface AnalysisResult {
  type: string;
  confidence: number;
  recyclable: boolean;
  suitability: Array<{
    purpose: string;
    score: number;
  }>;
}

const isDragging = ref(false);
const image = ref<string | null>(null);
const analyzing = ref(false);
const results = ref<AnalysisResult | null>(null);

const handleFileDrop = (e: DragEvent) => {
  isDragging.value = false;
  const file = e.dataTransfer?.files[0];
  if (file) processFile(file);
};

const handleFileSelect = (e: Event) => {
  const target = e.target as HTMLInputElement;
  if (target.files?.[0]) {
    processFile(target.files[0]);
  }
};

const processFile = (file: File) => {
  if (file && file.type.match("image.*")) {
    const reader = new FileReader();

    reader.onload = (e) => {
      if (e.target?.result && typeof e.target.result === "string") {
        image.value = e.target.result;
        analyzeImage();
      }
    };

    reader.readAsDataURL(file);
  }
};

const analyzeImage = () => {
  analyzing.value = true;
  results.value = null;

  // Simulate API call with timeout
  setTimeout(() => {
    analyzing.value = false;
    // Mock results
    results.value = {
      type: "Polyethylene Terephthalate (PET)",
      confidence: 89.7,
      recyclable: true,
      suitability: [
        { purpose: "Road Surface", score: 87 },
        { purpose: "Paving Blocks", score: 92 },
        { purpose: "Benches", score: 75 },
        { purpose: "Barriers", score: 62 },
      ],
    };
  }, 2500);
};

const resetAnalysis = () => {
  image.value = null;
  results.value = null;
};
</script>

<style>
.glass-card {
  @apply bg-gray-100 backdrop-blur-lg rounded-xl shadow-lg;
}

.glass-card-dark {
  @apply bg-gray-900 bg-opacity-80 backdrop-blur-lg;
}
</style>
