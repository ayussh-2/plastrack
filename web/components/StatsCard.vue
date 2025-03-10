<template>
    <div class="glass-card dark:glass-card-dark p-5 rounded-xl">
        <div class="flex items-center space-x-2 mb-2">
            <div
                class="w-8 h-8 rounded-full bg-waste2way-teal/10 flex items-center justify-center"
            >
                <component :is="icon" class="h-4 w-4 text-waste2way-teal" />
            </div>
            <p class="text-sm text-muted-foreground">{{ title }}</p>
        </div>
        <div class="flex items-baseline space-x-2">
            <h3 class="text-2xl font-bold">{{ value }}</h3>
            <span
                v-if="change"
                :class="
                    positive
                        ? 'text-waste2way-green text-sm'
                        : 'text-waste2way-coral text-sm'
                "
            >
                {{ positive ? "+" : "-" }}{{ change }}
            </span>
        </div>
    </div>
</template>

<script setup>
import { MapPin } from "lucide-vue-next";

// Props with default values
const props = defineProps({
    title: {
        type: String,
        required: true,
    },
    value: {
        type: String,
        required: true,
    },
    change: {
        type: String,
        default: "",
    },
    positive: {
        type: Boolean,
        default: true,
    },
    icon: {
        type: Object,
        default: () => MapPin,
    },
});
</script>
