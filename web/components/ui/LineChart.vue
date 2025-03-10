<template>
  <ResponsiveContainer width="100%" :height="height">
    <RechartsLineChart :data="data" :height="height" :lines="lines">
      <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.1)" />
      <XAxis dataKey="year" stroke="rgba(255,255,255,0.5)" />
      <YAxis stroke="rgba(255,255,255,0.5)" />
      <Tooltip
        :contentStyle="{
          backgroundColor: 'rgba(0,0,0,0.8)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '6px',
        }"
      />
      <Legend />
      <Line
        v-for="line in lines"
        :key="line.key"
        type="monotone"
        :dataKey="line.key"
        :stroke="line.stroke"
        :name="line.name"
        :strokeWidth="line.key === 'waste2way' ? 3 : 2"
        :dot="{ r: 4 }"
        :activeDot="{ r: 6 }"
      />
    </RechartsLineChart>
  </ResponsiveContainer>
</template>

<script setup lang="ts">
import {
  LineChart as RechartsLineChart,
  Line,
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
  lines: Array<{
    key: string;
    stroke: string;
    name: string;
  }>;
}>();
</script>
