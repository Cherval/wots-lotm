<script setup lang="ts">
/**
 * GrantSpModal.vue
 * Admin grant SP modal
 */
import { ref, watch } from 'vue'
import type { Player } from '@/lib/constants'
import BaseModal from '../ui/BaseModal.vue'

const props = defineProps<{
    show: boolean
    target: Player | null
    loading?: boolean
}>()

const emit = defineEmits<{
    close: []
    submit: [amount: number]
}>()

const amount = ref(1)

watch(() => props.show, (newVal) => {
    if (newVal) {
        amount.value = 1
    }
})

function handleSubmit() {
    if (amount.value > 0) {
        emit('submit', amount.value)
    }
}
</script>

<template>
    <BaseModal 
        :show="show" 
        size="sm"
        border-color="border-purple-500"
        @close="emit('close')"
    >
        <div class="text-center">
            <h3 class="text-xl text-purple-400 font-bold mb-2">มอบแต้มทักษะ (Gift SP)</h3>
            <p class="text-sm text-gray-400 mb-4">
                มอบให้กับ: 
                <span class="text-vic-gold">{{ target?.character_name }}</span>
            </p>

            <!-- Amount Input -->
            <div class="flex justify-center mb-6">
                <input 
                    type="number" 
                    v-model.number="amount" 
                    min="1" 
                    class="input-vic text-center text-3xl font-bold w-32 h-16 border-purple-800 text-purple-200 focus:border-purple-500" 
                />
            </div>

            <!-- Submit Button -->
            <button 
                @click="handleSubmit" 
                :disabled="loading || amount <= 0"
                class="w-full bg-purple-900 hover:bg-purple-800 text-white font-bold py-3 rounded border border-purple-600 shadow-lg disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
            >
                <svg v-if="loading" class="animate-spin h-5 w-5" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
                </svg>
                {{ loading ? 'กำลังมอบ SP...' : 'ยืนยัน' }}
            </button>
        </div>
    </BaseModal>
</template>
