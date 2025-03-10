<template>
  <ResponsiveContainer width="100%" :height="height">
    <BarChart :data="data" :height="height" :bars="bars">
      <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.1)" />
      <XAxis dataKey="month" stroke="rgba(255,255,255,0.5)" />
      <YAxis stroke="rgba(255,255,255,0.5)" />
      <Tooltip
        :contentStyle="{
          backgroundColor: 'rgba(0,0,0,0.8)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '6px'
        }"
      />
      <Legend />
      <Bar
        v-for="bar in bars"
        :key="bar.key"
        :dataKey="bar.key"
        :fill="bar.fill"
        :radius="[4, 4, 0, 0]"
      />
    </BarChart>
  </ResponsiveContainer>
</template>

<script setup lang="ts">
import {
  BarChart as RechartsBarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer
} from 'recharts'

defineProps<{
  data: any[]
  height: number
  bars: Array<{
    key: string
    fill: string
  }>
}>()
</script>