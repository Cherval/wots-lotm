<script setup lang="ts">
/**
 * SkillsGrid.vue
 * Skills display grid component
 */
import { SKILL_LABELS } from '@/lib/constants'

const props = defineProps<{
    skills: Record<string, number>
}>()

function formatSkillValue(value: number | undefined): string {
    const v = value || 0
    return v >= 0 ? `+${v}` : `${v}`
}

function getSkillClass(value: number | undefined): string {
    const v = value || 0
    if (v > 0) return 'text-green-400'
    if (v < 0) return 'text-red-400'
    return 'text-gray-600'
}
</script>

<template>
    <div class="mb-2">
        <h3 class="text-sm text-vic-gold uppercase font-bold mb-2">สกิล</h3>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-2">
            <div 
                v-for="(label, key) in SKILL_LABELS" 
                :key="key" 
                class="bg-black/20 p-2 rounded border border-white/5 text-[12px] flex justify-between"
            >
                <span class="truncate text-gray-300">{{ label }}</span>
                <span 
                    class="font-mono font-bold"
                    :class="getSkillClass(skills[key])"
                >
                    {{ formatSkillValue(skills[key]) }}
                </span>
            </div>
        </div>
    </div>
</template>
