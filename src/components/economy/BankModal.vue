<script setup lang="ts">
/**
 * BankModal.vue
 * Bank deposit/withdraw modal component
 */
import { ref, watch } from 'vue'
import BaseModal from '../ui/BaseModal.vue'

const props = defineProps<{
    show: boolean
    mode: 'deposit' | 'withdraw'
    currentMoney: number
    currentBankBalance: number
}>()

const emit = defineEmits<{
    close: []
    submit: [amount: number]
    'update:mode': [mode: 'deposit' | 'withdraw']
}>()

const amount = ref(0)
const localMode = ref(props.mode)

watch(() => props.show, (newVal) => {
    if (newVal) {
        amount.value = 0
        localMode.value = props.mode
    }
})

watch(() => props.mode, (newVal) => {
    localMode.value = newVal
})

function handleSubmit() {
    if (amount.value > 0) {
        emit('submit', amount.value)
    }
}

const maxAmount = computed(() => {
    return localMode.value === 'deposit' ? props.currentMoney : props.currentBankBalance
})

import { computed } from 'vue'
</script>

<template>
    <BaseModal 
        :show="show" 
        title="ธนาคารกลาง (Central Bank)"
        size="sm"
        @close="emit('close')"
    >
        <!-- Mode Toggle -->
        <div class="flex bg-black p-1 rounded mb-6 border border-gray-700">
            <button 
                @click="localMode = 'deposit'; emit('update:mode', 'deposit')"
                class="flex-1 py-2 text-sm font-bold rounded transition"
                :class="localMode === 'deposit' ? 'bg-yellow-700 text-white' : 'text-gray-500 hover:text-gray-300'"
            >
                ฝากเงิน
            </button>
            <button 
                @click="localMode = 'withdraw'; emit('update:mode', 'withdraw')"
                class="flex-1 py-2 text-sm font-bold rounded transition"
                :class="localMode === 'withdraw' ? 'bg-blue-700 text-white' : 'text-gray-500 hover:text-gray-300'"
            >
                ถอนเงิน
            </button>
        </div>

        <!-- Balance Display -->
        <div class="mb-4 text-center">
            <p class="text-xs text-gray-400 mb-1">
                ยอดเงิน{{ localMode === 'deposit' ? 'ในตัว' : 'ในบัญชี' }}
            </p>
            <div 
                class="text-2xl font-bold"
                :class="localMode === 'deposit' ? 'text-yellow-500' : 'text-blue-500'"
            >
                ฿{{ localMode === 'deposit' ? currentMoney : currentBankBalance }}
            </div>
        </div>

        <!-- Amount Input -->
        <input 
            type="number" 
            v-model.number="amount" 
            placeholder="ระบุจำนวนเงิน" 
            class="input-vic text-center text-xl mb-6" 
            min="1"
            :max="maxAmount"
        />

        <!-- Submit Button -->
        <button 
            @click="handleSubmit"
            :disabled="amount <= 0 || amount > maxAmount"
            class="w-full font-bold py-3 rounded text-white shadow-lg transition disabled:opacity-50 disabled:cursor-not-allowed"
            :class="localMode === 'deposit' ? 'bg-yellow-800 hover:bg-yellow-700' : 'bg-blue-800 hover:bg-blue-700'"
        >
            ยืนยันการ{{ localMode === 'deposit' ? 'ฝาก' : 'ถอน' }}
        </button>
    </BaseModal>
</template>
