<script setup lang="ts">
/**
 * TransferItemModal.vue
 * Item transfer modal component
 */
import { ref, watch, computed } from 'vue'
import type { Player, InventoryItem } from '@/lib/constants'
import BaseModal from '../ui/BaseModal.vue'

const props = defineProps<{
    show: boolean
    currentUser: Player
    players: Player[]
    item: InventoryItem | null
}>()

const emit = defineEmits<{
    close: []
    submit: [targetId: string, quantity: number]
}>()

const searchQuery = ref('')
const selectedTargetId = ref('')
const quantity = ref(1)

watch(() => props.show, (newVal) => {
    if (newVal) {
        searchQuery.value = ''
        selectedTargetId.value = ''
        quantity.value = 1
    }
})

const maxQuantity = computed(() => props.item?.quantity ?? 1)

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
    if (selectedTargetId.value && quantity.value > 0 && quantity.value <= maxQuantity.value) {
        emit('submit', selectedTargetId.value, quantity.value)
    }
}
</script>

<template>
    <BaseModal 
        :show="show" 
        size="sm"
        border-color="border-green-500"
        @close="emit('close')"
    >
        <template #default>
            <h3 class="text-xl text-green-400 font-bold mb-4 text-center">🎁 ส่งไอเทม</h3>
            
            <!-- Item Preview -->
            <div v-if="item" class="bg-black/40 p-3 rounded border border-gray-700 mb-4 flex items-center gap-3">
                <img 
                    :src="item.items.image_url" 
                    class="w-12 h-12 rounded border border-gray-600 object-cover"
                />
                <div>
                    <div class="text-vic-gold font-bold">{{ item.items.name }}</div>
                    <div class="text-xs text-gray-400">มีอยู่: {{ item.quantity }} ชิ้น</div>
                </div>
            </div>

            <!-- Target Search -->
            <label class="text-xs text-gray-400 mb-1 block">ส่งให้ใคร?</label>
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

            <!-- Quantity Input -->
            <label class="text-xs text-gray-400 mb-1 block">จำนวนที่ต้องการส่ง</label>
            <input 
                type="number" 
                v-model.number="quantity" 
                min="1" 
                :max="maxQuantity"
                class="input-vic mb-4 text-center text-xl font-bold" 
            />

            <!-- Selected Player Preview -->
            <div v-if="selectedPlayer" class="bg-green-900/20 p-3 rounded border border-green-700 mb-4 text-center">
                <p class="text-xs text-gray-400">ส่งให้</p>
                <p class="text-green-400 font-bold">{{ selectedPlayer.character_name }}</p>
                <p class="text-xs text-gray-500">({{ selectedPlayer.name }})</p>
            </div>

            <!-- Submit Button -->
            <button 
                @click="handleSubmit"
                :disabled="!selectedTargetId || quantity <= 0 || quantity > maxQuantity"
                class="w-full bg-green-800 hover:bg-green-700 text-white font-bold py-2 rounded border border-green-600 shadow disabled:opacity-50 disabled:cursor-not-allowed"
            >
                ยืนยันการส่ง
            </button>
        </template>
    </BaseModal>
</template>
