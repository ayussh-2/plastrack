<template>
  <div class="py-16">
    <div class="section-container">
      <div class="mb-12 text-center">
        <h2 class="mb-4 text-3xl font-bold md:text-4xl">
          Waste Identification
        </h2>
        <p class="max-w-2xl mx-auto text-muted-foreground">
          Our AI-powered system identifies waste types with 90%+ accuracy and
          determines their suitability for their usage in sustainable
          infrastructure.
        </p>
      </div>

      <div class="grid grid-cols-1 gap-10 md:grid-cols-2">
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
            <Icon
              name="lucide:upload"
              class="w-12 h-12 mb-4 text-muted-foreground"
            />
            <h3 class="mb-2 text-xl font-medium">Drag & drop image</h3>
            <p class="mb-6 text-center text-muted-foreground">
              Upload a photo of pliable waste to analyze its composition and
              potential uses for sustainable infrastructure
            </p>

            <label class="cursor-pointer btn-primary">
              <input
                type="file"
                class="hidden"
                accept="image/*"
                @change="handleFileSelect"
              />
              <Icon name="lucide:file-up" class="inline w-4 h-4 mr-2" />
              Upload Image
            </label>
          </div>

          <div v-else class="relative overflow-hidden rounded-2xl h-80 group">
            <img
              :src="image"
              alt="Uploaded plastic waste"
              class="object-cover w-full h-full"
            />
            <button
              @click="resetAnalysis"
              class="absolute p-2 text-white transition-opacity rounded-full opacity-0 top-4 right-4 bg-waste2way-dark/60 group-hover:opacity-100"
            >
              <Icon name="lucide:x" class="w-5 h-5" />
            </button>
          </div>
        </div>

        <div class="p-6 glass-card dark:glass-card-dark">
          <div
            v-if="!image"
            class="flex flex-col items-center justify-center h-full p-6 text-center"
          >
            <div
              class="flex items-center justify-center w-16 h-16 mb-4 rounded-full bg-waste2way-blue/10"
            >
              <Icon name="lucide:upload" class="w-8 h-8 text-waste2way-blue" />
            </div>
            <h3 class="mb-2 text-xl font-medium">No Image Uploaded</h3>
            <p class="text-muted-foreground">
              Upload an image to identify waste type and assess its potential
              for sustainable usage.
            </p>
          </div>

          <div
            v-else-if="analyzing"
            class="flex flex-col items-center justify-center h-full p-6"
          >
            <div
              class="w-20 h-20 mb-6 border-4 rounded-full border-waste2way-teal/30 border-t-waste2way-teal animate-spin"
            ></div>
            <h3 class="mb-2 text-xl font-medium">Analyzing Waste Sample</h3>
            <p class="text-muted-foreground">
              Our computer vision algorithms are identifying waste type and
              assessing infrastructure suitability with 90%+ accuracy...
            </p>
          </div>

          <div v-else-if="results" class="h-full">
            <!-- Show error state if error exists -->
            <div v-if="results.error" class="flex items-center mb-6">
              <div
                class="flex items-center justify-center w-12 h-12 mr-4 rounded-full bg-waste2way-coral/10"
              >
                <Icon
                  name="lucide:alert-triangle"
                  class="w-6 h-6 text-waste2way-coral"
                />
              </div>
              <div>
                <h3 class="text-xl font-medium text-waste2way-coral">
                  Analysis Failed
                </h3>
                <p class="text-muted-foreground">{{ results.error }}</p>
              </div>
            </div>

            <!-- Show results if no error -->
            <template v-else>
              <div class="flex items-center mb-6">
                <div
                  class="flex items-center justify-center w-12 h-12 mr-4 rounded-full bg-waste2way-green/10"
                >
                  <Icon
                    name="lucide:check"
                    class="w-6 h-6 text-waste2way-green"
                  />
                </div>
                <div>
                  <h3 class="text-xl font-medium">
                    {{ results.type }}
                  </h3>
                  <p class="text-muted-foreground">
                    Identified with
                    {{ results.confidence?.toFixed(1) }}% confidence
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
                <div class="w-full h-2 rounded-full bg-muted">
                  <div
                    class="h-2 rounded-full bg-gradient-to-r from-waste2way-teal to-waste2way-blue"
                    :style="{ width: `${results.recyclabilityScore}%` }"
                  ></div>
                </div>
              </div>

              <div class="mb-6">
                <h4 class="mb-3 font-medium">Infrastructure Suitability</h4>
                <div class="space-y-3">
                  <div
                    v-for="(item, index) in results.suitability"
                    :key="index"
                  >
                    <div class="flex justify-between mb-1">
                      <span class="text-sm">{{ item.purpose }}</span>
                      <span class="text-sm font-medium">{{ item.score }}%</span>
                    </div>
                    <div class="w-full h-2 rounded-full bg-muted">
                      <div
                        class="h-2 rounded-full bg-gradient-to-r from-waste2way-teal to-waste2way-blue"
                        :style="{ width: `${item.score}%` }"
                      ></div>
                    </div>
                  </div>
                </div>
              </div>

              <div>
                <h4 class="mb-3 font-medium">Environmental Impact</h4>
                <p class="mb-3 text-sm text-muted-foreground">
                  Repurposing this waste could save:
                </p>
                <div class="grid grid-cols-2 gap-3">
                  <div
                    class="p-3 rounded-lg bg-waste2way-dark/10 dark:bg-waste2way-dark/20"
                  >
                    <div class="flex items-center mb-1">
                      <Icon
                        name="lucide:trash-2"
                        class="w-4 h-4 mr-2 text-waste2way-teal"
                      />
                      <span class="text-sm font-medium"
                        >Landfill Reduction</span
                      >
                    </div>
                    <span class="text-lg font-bold"
                      >{{ results?.impacts?.landfillReduction }} kg</span
                    >
                  </div>
                  <div
                    class="p-3 rounded-lg bg-waste2way-dark/10 dark:bg-waste2way-dark/20"
                  >
                    <div class="flex items-center mb-1">
                      <Icon
                        name="lucide:cloud"
                        class="w-4 h-4 mr-2 text-waste2way-blue"
                      />
                      <span class="text-sm font-medium">CO₂ Reduction</span>
                    </div>
                    <span class="text-lg font-bold"
                      >{{ results?.impacts?.co2Reduction }} kg</span
                    >
                  </div>
                </div>
              </div>
            </template>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import type {
  WasteClassificationResponse,
  AnalysisResult,
} from "~/types/waste";
import { useApi } from "~/composables/useApi";
import { uploadToCloudinary } from "~/utils/cloudinary";

const isDragging = ref(false);
const image = ref<string | null>(null);
const analyzing = ref(false);
const results = ref<AnalysisResult | null>(null);

const handleFileDrop = (e: DragEvent) => {
  isDragging.value = false;
  const file = e.dataTransfer?.files[0];
  if (file) {
    processFile(file);
  }
};

const handleFileSelect = (e: Event) => {
  const target = e.target as HTMLInputElement;
  if (target.files && target.files[0]) {
    processFile(target.files[0]);
  }
};

const processFile = async (file: File) => {
  if (file && file.type.match("image.*")) {
    const reader = new FileReader();

    reader.onload = (e) => {
      if (e.target && typeof e.target.result === "string") {
        image.value = e.target.result;
        analyzeImage(file);
      }
    };

    reader.readAsDataURL(file);
  }
};

const analyzeImage = async (file: File) => {
  analyzing.value = true;
  results.value = null;

  try {
    const api = useApi();
    const cloudinaryUrl = await uploadToCloudinary(file);

    const response = await api.post<WasteClassificationResponse>(
      "/trash/classify",
      {
        image: cloudinaryUrl,
      }
    );

    analyzing.value = false;

    if (response.success) {
      if (response.data?.error) {
        results.value = {
          error: response.data?.error,
        };
        return;
      }

      const result: AnalysisResult = {
        type: response.data.material,
        confidence: response.data.confidence,
        recyclable: response.data.recyclability.includes("Recyclable"),
        recyclabilityScore: response.data.confidence,
        suitability: [
          {
            purpose: "Road Surface",
            score: response.data.infrastructure_suitability.road_surface,
          },
          {
            purpose: "Paving Blocks",
            score: response.data.infrastructure_suitability.paving_blocks,
          },
          {
            purpose: "Boundary Walls",
            score: response.data.infrastructure_suitability.boundary_walls,
          },
          {
            purpose: "Traffic Barriers",
            score: response.data.infrastructure_suitability.traffic_barriers,
          },
        ],
        impacts: {
          landfillReduction:
            response.data.environmental_impact.landfill_reduction,
          co2Reduction: response.data.environmental_impact.co2_reduction,
        },
      };

      results.value = result;
    }
  } catch (error) {
    console.error("Error analyzing image:", error);
    results.value = {
      error: "An error occurred while analyzing the image. Please try again.",
    };
  } finally {
    analyzing.value = false;
  }
};

const resetAnalysis = () => {
  image.value = null;
  results.value = null;
};
</script>
