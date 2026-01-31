<script setup lang="ts">
/**
 * GrantStaminaModal.vue
 * Admin grant Stamina (move_token) modal
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

const amount = ref(5)

watch(() => props.show, (newVal) => {
    if (newVal) {
        amount.value = 5
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
        border-color="border-cyan-500"
        @close="emit('close')"
    >
        <div class="text-center">
            <h3 class="text-xl text-cyan-400 font-bold mb-2">🏃 มอบแต้มเดินทาง (Stamina)</h3>
            <p class="text-sm text-gray-400 mb-2">
                มอบให้กับ: 
                <span class="text-vic-gold">{{ target?.character_name }}</span>
            </p>
            <p class="text-xs text-gray-500 mb-4">
                Stamina ปัจจุบัน: <span class="text-cyan-300 font-bold">{{ target?.move_token ?? 0 }}</span>
            </p>

            <!-- Amount Input -->
            <div class="flex justify-center mb-4">
                <input 
                    type="number" 
                    v-model.number="amount" 
                    min="1" 
                    class="input-vic text-center text-3xl font-bold w-32 h-16 border-cyan-800 text-cyan-200 focus:border-cyan-500" 
                />
            </div>

            <!-- Info -->
            <p class="text-xs text-gray-500 mb-6">
                หลังมอบจะมี: <span class="text-green-400 font-bold">{{ (target?.move_token ?? 0) + amount }}</span> หน่วย
            </p>

            <!-- Submit Button -->
            <button 
                @click="handleSubmit" 
                :disabled="loading || amount <= 0"
                class="w-full bg-cyan-900 hover:bg-cyan-800 text-white font-bold py-3 rounded border border-cyan-600 shadow-lg disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
            >
                <svg v-if="loading" class="animate-spin h-5 w-5" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
                </svg>
                {{ loading ? 'กำลังมอบ Stamina...' : 'ยืนยัน' }}
            </button>
        </div>
    </BaseModal>
</template>
