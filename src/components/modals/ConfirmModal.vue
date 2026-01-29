<script setup lang="ts">
/**
 * ConfirmModal.vue
 * Confirmation dialog modal component
 */
import BaseModal from '../ui/BaseModal.vue'

const props = defineProps<{
    show: boolean
    title: string
    message: string
    type?: 'confirm' | 'delete' | 'use'
    confirmText?: string
    loading?: boolean
}>()

const emit = defineEmits<{
    close: []
    confirm: []
}>()

const borderColor = computed(() => {
    switch (props.type) {
        case 'delete': return 'border-red-500'
        case 'use': return 'border-blue-500'
        default: return 'border-vic-gold'
    }
})

const buttonClass = computed(() => {
    switch (props.type) {
        case 'delete': return 'bg-red-700 hover:bg-red-600 border-red-500'
        case 'use': return 'bg-blue-700 hover:bg-blue-600 border-blue-500'
        default: return 'bg-vic-gold hover:bg-yellow-500 border-yellow-400 text-black'
    }
})

import { computed } from 'vue'
</script>

<template>
    <BaseModal 
        :show="show" 
        size="sm"
        :border-color="borderColor"
        @close="emit('close')"
    >
        <div class="text-center">
            <!-- Icon -->
            <div class="text-5xl mb-4">
                {{ type === 'delete' ? '⚠️' : (type === 'use' ? '🧪' : '❓') }}
            </div>

            <!-- Title -->
            <h3 class="text-xl font-bold mb-2 text-vic-gold font-serif">{{ title }}</h3>

            <!-- Message -->
            <p class="text-gray-300 mb-6">{{ message }}</p>

            <!-- Actions -->
            <div class="flex gap-3">
                <button 
                    @click="emit('close')"
                    :disabled="loading"
                    class="flex-1 py-2 rounded border border-gray-600 text-gray-400 hover:bg-gray-800 transition"
                >
                    ยกเลิก
                </button>
                <button 
                    @click="emit('confirm')"
                    :disabled="loading"
                    class="flex-1 py-2 rounded font-bold transition border disabled:opacity-50 text-white"
                    :class="buttonClass"
                >
                    <span v-if="loading" class="flex items-center justify-center gap-2">
                        <svg class="animate-spin h-4 w-4" fill="none" viewBox="0 0 24 24">
                            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
                        </svg>
                        กำลังดำเนินการ...
                    </span>
                    <span v-else>{{ confirmText || 'ยืนยัน' }}</span>
                </button>
            </div>
        </div>
    </BaseModal>
</template>
