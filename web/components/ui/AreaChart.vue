<template>
  <ResponsiveContainer width="100%" :height="height">
    <AreaChart :data="data" :height="height" :areas="areas">
      <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.1)" />
      <XAxis dataKey="month" stroke="rgba(255,255,255,0.5)" />
      <YAxis stroke="rgba(255,255,255,0.5)" />
      <Tooltip
        :contentStyle="{
          backgroundColor: 'rgba(0,0,0,0.8)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '6px',
        }"
      />
      <Legend />
      <defs>
        <linearGradient id="colorCo2" x1="0" y1="0" x2="0" y2="1">
          <stop offset="5%" stopColor="#2A9D8F" stopOpacity="0.8" />
          <stop offset="95%" stopColor="#2A9D8F" stopOpacity="0.1" />
        </linearGradient>
        <linearGradient id="colorWaste" x1="0" y1="0" x2="0" y2="1">
          <stop offset="5%" stopColor="#48CAE4" stopOpacity="0.8" />
          <stop offset="95%" stopColor="#48CAE4" stopOpacity="0.1" />
        </linearGradient>
      </defs>
      <Area
        v-for="area in areas"
        :key="area.key"
        type="monotone"
        :dataKey="area.key"
        :name="area.name"
        :stroke="area.stroke"
        fillOpacity="1"
        :fill="`url(#${area.gradient})`"
      />
    </AreaChart>
  </ResponsiveContainer>
</template>

<script setup lang="ts">
import {
  AreaChart as RechartsAreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from "recharts";

defineProps<{
  data: any[];
  height: number;
  areas: Array<{
    key: string;
    name: string;
    stroke: string;
    gradient: string;
  }>;
}>();
</script>
