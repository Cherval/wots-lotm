<script setup lang="ts">
/**
 * TransferMoneyModal.vue
 * Money transfer modal component
 */
import { ref, watch, computed } from 'vue'
import type { Player } from '@/lib/constants'
import BaseModal from '../ui/BaseModal.vue'

const props = defineProps<{
    show: boolean
    currentUser: Player
    players: Player[]
}>()

const emit = defineEmits<{
    close: []
    submit: [targetId: string, amount: number]
}>()

const searchQuery = ref('')
const selectedTargetId = ref('')
const amount = ref(0)

watch(() => props.show, (newVal) => {
    if (newVal) {
        searchQuery.value = ''
        selectedTargetId.value = ''
        amount.value = 0
    }
})

const filteredPlayers = computed(() => {
    if (!searchQuery.value.trim()) return []
    const query = searchQuery.value.toLowerCase()
    return props.players.filter(p => 
        p.id !== props.currentUser.id &&
        (p.character_name.toLowerCase().includes(query) || 
         p.name.toLowerCase().includes(query))
    ).slice(0, 10)
})

const selectedPlayer = computed(() => {
    return props.players.find(p => p.id === selectedTargetId.value)
})

function selectTarget(player: Player) {
    selectedTargetId.value = player.id
    searchQuery.value = player.character_name
}

function handleSubmit() {
    if (selectedTargetId.value && amount.value > 0 && amount.value <= props.currentUser.bank_balance) {
        emit('submit', selectedTargetId.value, amount.value)
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
        <template #default>
            <h3 class="text-xl text-purple-400 font-bold mb-4 text-center">💸 โอนเงิน (Transfer Money)</h3>
            
            <p class="text-xs text-center text-gray-400 mb-4">
                จากยอดธนาคาร: 
                <span class="text-blue-400 font-bold">฿{{ currentUser.bank_balance }}</span>
            </p>

            <!-- Target Search -->
            <label class="text-xs text-gray-400 mb-1 block">โอนให้ใคร?</label>
            <div class="relative mb-3">
                <input 
                    type="text" 
                    v-model="searchQuery" 
                    placeholder="ค้นหาชื่อผู้เล่น..."
                    class="input-vic w-full"
                    @input="selectedTargetId = ''"
                />
                
                <!-- Dropdown -->
                <div 
                    v-if="searchQuery && !selectedTargetId" 
                    class="absolute left-0 right-0 top-full mt-1 bg-black border border-gray-600 rounded max-h-40 overflow-y-auto z-50 shadow-xl"
                >
                    <div 
                        v-if="filteredPlayers.length === 0" 
                        class="p-2 text-gray-500 text-xs italic"
                    >
                        ไม่พบชื่อนี้
                    </div>
                    <div 
                        v-for="p in filteredPlayers" 
                        :key="p.id" 
                        @click="selectTarget(p)"
                        class="p-2 hover:bg-vic-gold hover:text-black cursor-pointer text-sm border-b border-gray-800 last:border-0"
                    >
                        <span class="font-bold">{{ p.character_name }}</span> 
                        <span class="text-xs opacity-70">({{ p.name }})</span>
                    </div>
                </div>

                <!-- Selected Indicator -->
                <div 
                    v-if="selectedTargetId" 
                    class="absolute right-2 top-2 text-green-500 font-bold text-xs pointer-events-none"
                >
                    ✓
                </div>
            </div>

            <!-- Amount Input -->
            <label class="text-xs text-gray-400 mb-1 block">จำนวนเงิน</label>
            <input 
                type="number" 
                v-model.number="amount" 
                min="1" 
                :max="currentUser.bank_balance"
                class="input-vic mb-6 text-center text-xl font-bold" 
            />

            <!-- Submit Button -->
            <button 
                @click="handleSubmit"
                :disabled="!selectedTargetId || amount <= 0 || amount > currentUser.bank_balance"
                class="w-full bg-purple-800 hover:bg-purple-700 text-white font-bold py-2 rounded border border-purple-600 shadow disabled:opacity-50 disabled:cursor-not-allowed"
            >
                ยืนยันการโอน
            </button>
        </template>
    </BaseModal>
</template>
