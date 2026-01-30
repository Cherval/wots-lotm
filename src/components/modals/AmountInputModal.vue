<script setup lang="ts">
/**
 * AmountInputModal.vue
 * Modal for inputting ingredient amount (grams/ml)
 */
import { ref, watch, computed } from 'vue'
import type { Item } from '@/lib/constants'
import { UNIT_LABELS } from '@/lib/constants'
import BaseModal from '../ui/BaseModal.vue'

const props = defineProps<{
    show: boolean
    item: Item | null | undefined
}>()

const emit = defineEmits<{
    close: []
    submit: [amount: number, unit: string]
}>()

const amount = ref(0)
const unit = ref('g')

// Get default unit from item
const defaultUnit = computed(() => {
    if (props.item?.effects?.unit) {
        return props.item.effects.unit
    }
    return 'g'
})

// Reset when modal opens
watch(() => props.show, (show) => {
    if (show) {
        amount.value = 0
        unit.value = defaultUnit.value
    }
})

// Quick amount buttons based on unit
const quickAmounts = computed(() => {
    if (unit.value === 'ml') {
        return [50, 100, 200, 300, 500]
    } else if (unit.value === 'piece') {
        return [1, 2, 3, 5, 10]
    }
    return [1, 3, 5, 10, 20, 50]
})

function handleSubmit() {
    if (amount.value <= 0) return
    emit('submit', amount.value, unit.value)
}

function setQuickAmount(val: number) {
    amount.value = val
}

function adjustAmount(delta: number) {
    const newVal = amount.value + delta
    if (newVal >= 0) {
        amount.value = newVal
    }
}
</script>

<template>
    <BaseModal 
        :show="show" 
        :title="`🧪 ใส่ ${item?.name || 'วัตถุดิบ'}`"
        size="sm"
        @close="emit('close')"
    >
        <div class="space-y-4">
            <!-- Item Preview -->
            <div 
                v-if="item"
                class="flex items-center gap-4 p-3 bg-black/30 rounded-lg border border-gray-700"
            >
                <img 
                    :src="item.image_url" 
                    :alt="item.name"
                    class="w-16 h-16 rounded-lg object-cover"
                />
                <div>
                    <div class="text-vic-gold font-bold">{{ item.name }}</div>
                    <div class="text-sm text-gray-400">{{ item.description }}</div>
                </div>
            </div>

            <!-- Unit Selection -->
            <div>
                <label class="block text-sm text-gray-400 mb-2">หน่วย</label>
                <div class="flex gap-2">
                    <button
                        v-for="u in ['g', 'ml', 'piece']"
                        :key="u"
                        @click="unit = u"
                        class="flex-1 py-2 rounded border-2 transition font-bold"
                        :class="{
                            'bg-vic-gold/20 border-vic-gold text-vic-gold': unit === u,
                            'bg-gray-800 border-gray-600 text-gray-400 hover:border-gray-500': unit !== u
                        }"
                    >
                        {{ UNIT_LABELS[u] }}
                    </button>
                </div>
            </div>

            <!-- Amount Input -->
            <div>
                <label class="block text-sm text-gray-400 mb-2">ปริมาณ</label>
                <div class="flex items-center gap-3">
                    <button
                        @click="adjustAmount(-1)"
                        class="w-12 h-12 bg-red-900 hover:bg-red-800 text-red-200 rounded-lg text-2xl font-bold transition"
                        :disabled="amount <= 0"
                    >
                        −
                    </button>
                    <input
                        v-model.number="amount"
                        type="number"
                        min="0"
                        step="1"
                        class="flex-1 input-vic text-center text-2xl font-bold h-12"
                        placeholder="0"
                    />
                    <button
                        @click="adjustAmount(1)"
                        class="w-12 h-12 bg-green-900 hover:bg-green-800 text-green-200 rounded-lg text-2xl font-bold transition"
                    >
                        +
                    </button>
                </div>
            </div>

            <!-- Quick Amounts -->
            <div>
                <label class="block text-sm text-gray-400 mb-2">ปริมาณด่วน</label>
                <div class="flex flex-wrap gap-2">
                    <button
                        v-for="val in quickAmounts"
                        :key="val"
                        @click="setQuickAmount(val)"
                        class="px-4 py-2 rounded border transition"
                        :class="{
                            'bg-purple-900 border-purple-500 text-purple-200': amount === val,
                            'bg-gray-800 border-gray-600 text-gray-300 hover:border-gray-500': amount !== val
                        }"
                    >
                        {{ val }} {{ UNIT_LABELS[unit] }}
                    </button>
                </div>
            </div>

            <!-- Preview -->
            <div 
                v-if="amount > 0"
                class="p-3 bg-green-900/20 border border-green-700 rounded-lg text-center"
            >
                <span class="text-green-300 text-lg">
                    จะใส่ <strong>{{ item?.name }}</strong> {{ amount }} {{ UNIT_LABELS[unit] }}
                </span>
            </div>
        </div>

        <template #footer>
            <div class="flex gap-3">
                <button
                    @click="emit('close')"
                    class="flex-1 py-2 bg-gray-700 hover:bg-gray-600 text-gray-200 rounded-lg transition"
                >
                    ยกเลิก
                </button>
                <button
                    @click="handleSubmit"
                    class="flex-1 py-2 btn-gold"
                    :disabled="amount <= 0"
                >
                    ✅ ใส่ลงหม้อ
                </button>
            </div>
        </template>
    </BaseModal>
</template>
