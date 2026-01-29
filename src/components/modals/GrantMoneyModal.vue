<script setup lang="ts">
/**
 * GrantMoneyModal.vue
 * Admin grant money modal
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

const amount = ref(0)

watch(() => props.show, (newVal) => {
    if (newVal) {
        amount.value = 0
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
        border-color="border-yellow-500"
        @close="emit('close')"
    >
        <div class="text-center">
            <h3 class="text-xl text-yellow-500 font-bold mb-2">💸 พลังแห่งเงินตรา</h3>
            <p class="text-sm text-gray-400 mb-4">
                เสกเงินเข้าธนาคารให้: 
                <span class="text-white font-bold">{{ target?.character_name }}</span>
            </p>

            <!-- Amount Input -->
            <input 
                type="number" 
                v-model.number="amount" 
                min="1" 
                class="input-vic mb-6 text-center text-3xl font-bold border-yellow-600 text-yellow-400" 
            />

            <!-- Submit Button -->
            <button 
                @click="handleSubmit"
                :disabled="loading || amount <= 0"
                class="w-full bg-yellow-700 hover:bg-yellow-600 text-black font-bold py-2 rounded border border-yellow-500 shadow disabled:opacity-50 disabled:cursor-not-allowed"
            >
                {{ loading ? 'กำลังเสก...' : 'ยืนยันการเสก' }}
            </button>
        </div>
    </BaseModal>
</template>
