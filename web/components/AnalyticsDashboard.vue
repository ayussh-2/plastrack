<template>
  <div class="py-16">
    <div class="section-container">
      <div class="text-center mb-12">
        <h2 class="text-3xl md:text-4xl font-bold mb-4">
          Analytics & Insights
        </h2>
        <p class="text-muted-foreground max-w-2xl mx-auto">
          Data-driven insights on waste collection, processing, and
          infrastructure impact.
        </p>
      </div>

      <!-- Stats Cards -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
        <StatsCard
          v-for="(stat, index) in statsCardsData"
          :key="index"
          v-bind="stat"
        />
      </div>

      <!-- Main charts -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <ChartCard title="Waste Volume by Type">
          <template #default="{ height }">
            <BarChart
              :data="wasteVolumeData"
              :height="height"
              :bars="[
                { key: 'PET', fill: '#2A9D8F' },
                { key: 'HDPE', fill: '#48CAE4' },
                { key: 'Other', fill: '#F4845F' },
              ]"
            />
          </template>
        </ChartCard>

        <ChartCard title="Durability Prediction (Years)">
          <template #default="{ height }">
            <LineChart
              :data="durabilityData"
              :height="height"
              :lines="[
                { key: 'standard', stroke: '#F4845F', name: 'Standard' },
                { key: 'enhanced', stroke: '#48CAE4', name: 'Enhanced' },
                { key: 'waste2way', stroke: '#57CC99', name: 'Waste2Way' },
              ]"
            />
          </template>
        </ChartCard>
      </div>

      <!-- Environmental Impact Chart -->
      <ChartCard class="mt-8" title="Environmental Impact">
        <template #default="{ height }">
          <AreaChart
            :data="impactData"
            :height="height"
            :areas="[
              {
                key: 'co2Reduction',
                name: 'CO₂ Reduction (%)',
                stroke: '#2A9D8F',
                gradient: 'colorCo2',
              },
              {
                key: 'wasteSaved',
                name: 'Waste Saved (tons)',
                stroke: '#48CAE4',
                gradient: 'colorWaste',
              },
            ]"
          />
        </template>
      </ChartCard>
    </div>
  </div>
</template>

<script setup lang="ts">
import {
  BarChart3,
  TrendingUp,
  PieChart as PieChartIcon,
} from "lucide-vue-next";

// Sample data
const wasteVolumeData = [
  { month: "Jan", PET: 4000, HDPE: 2400, Other: 1800 },
  { month: "Feb", PET: 3500, HDPE: 2600, Other: 1700 },
  { month: "Mar", PET: 5000, HDPE: 2800, Other: 2200 },
  { month: "Apr", PET: 4200, HDPE: 3000, Other: 2000 },
  { month: "May", PET: 4800, HDPE: 3500, Other: 2500 },
  { month: "Jun", PET: 5500, HDPE: 3700, Other: 2300 },
];

const durabilityData = [
  { year: "2023", standard: 65, enhanced: 78, waste2way: 91 },
  { year: "2024", standard: 67, enhanced: 80, waste2way: 93 },
  { year: "2025", standard: 68, enhanced: 82, waste2way: 95 },
  { year: "2026", standard: 70, enhanced: 83, waste2way: 96 },
  { year: "2027", standard: 71, enhanced: 84, waste2way: 97 },
  { year: "2028", standard: 73, enhanced: 85, waste2way: 97 },
];

const impactData = [
  { month: "Jan", co2Reduction: 20, wasteSaved: 40 },
  { month: "Feb", co2Reduction: 25, wasteSaved: 50 },
  { month: "Mar", co2Reduction: 30, wasteSaved: 60 },
  { month: "Apr", co2Reduction: 35, wasteSaved: 70 },
  { month: "May", co2Reduction: 45, wasteSaved: 85 },
  { month: "Jun", co2Reduction: 50, wasteSaved: 90 },
];

const statsCardsData = [
  {
    title: "Total Waste Collected",
    value: "24,582",
    change: "15%",
    description: "Tons of plastic waste",
    icon: markRaw(BarChart3),
    chartData: [
      { name: "PET", value: 45, color: "#2A9D8F" },
      { name: "HDPE", value: 30, color: "#48CAE4" },
      { name: "Other", value: 25, color: "#F4845F" },
    ],
  },
  {
    title: "Material Utilization",
    value: "87%",
    change: "5%",
    description: "Conversion efficiency",
    icon: markRaw(TrendingUp),
    chartData: [
      { name: "Used", value: 87, color: "#57CC99" },
      { name: "Unused", value: 13, color: "#F4845F" },
    ],
  },
  {
    title: "CO₂ Emissions Saved",
    value: "312",
    change: "8%",
    description: "Metric tons this month",
    icon: markRaw(PieChartIcon),
    chartData: [
      { name: "Direct", value: 65, color: "#48CAE4" },
      { name: "Indirect", value: 35, color: "#2A9D8F" },
    ],
  },
];
</script>
