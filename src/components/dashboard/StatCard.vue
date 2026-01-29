<script setup lang="ts">
/**
 * StatCard.vue
 * Single stat display card component
 */
defineProps<{
    label: string
    value: number | string
    modifier?: number
    size?: 'sm' | 'md' | 'lg'
}>()

function formatModifier(mod: number | undefined): string {
    if (mod === undefined || mod === null) return '-'
    return mod >= 0 ? `+${mod}` : `${mod}`
}
</script>

<template>
    <div class="bg-neutral-800 p-2 rounded border border-vic-brown text-center">
        <div class="text-[10px] text-gray-400 uppercase">{{ label }}</div>
        <div class="text-lg font-bold">{{ value }}</div>
        <div 
            v-if="modifier !== undefined"
            class="text-xs font-bold"
            :class="modifier >= 0 ? 'text-green-400' : 'text-red-400'"
        >
            {{ formatModifier(modifier) }}
        </div>
    </div>
</template>
