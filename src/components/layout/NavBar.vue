<script setup lang="ts">
/**
 * NavBar.vue
 * Main navigation bar component
 */
import { NAV_ITEMS } from '@/lib/constants'

const props = defineProps<{
    currentView: string
    isAdmin: boolean
}>()

const emit = defineEmits<{
    navigate: [view: string]
}>()

const filteredNavItems = computed(() => {
    return NAV_ITEMS.filter(item => !item.adminOnly || props.isAdmin)
})

import { computed } from 'vue'
</script>

<template>
    <nav class="bg-vic-darkbrown border-b border-vic-gold sticky top-0 z-40 shadow-xl flex justify-center gap-1 overflow-x-auto">
        <button 
            v-for="item in filteredNavItems" 
            :key="item.key"
            @click="emit('navigate', item.key)"
            :class="[
                'px-6 py-3 uppercase text-sm whitespace-nowrap transition-colors',
                currentView === item.key || (item.key === 'map' && currentView === 'map_detail')
                    ? 'bg-vic-gold text-black font-bold' 
                    : 'text-vic-cream hover:bg-white/5'
            ]"
        >
            {{ item.label }}
        </button>
    </nav>
</template>
