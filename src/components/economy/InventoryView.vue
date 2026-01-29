<script setup lang="ts">
/**
 * InventoryView.vue
 * Player inventory view component with drag-and-drop grid and equipment slots
 */
import { ref, computed } from 'vue'
import type { InventoryItem, Player } from '@/lib/constants'
import InventoryGrid from './InventoryGrid.vue'
import EquipmentSlots from './EquipmentSlots.vue'

const props = defineProps<{
    currentUser: Player
    inventoryList: InventoryItem[]
}>()

const emit = defineEmits<{
    deposit: []
    withdraw: []
    transfer: []
    toggleEquip: [item: InventoryItem]
    use: [item: InventoryItem]
    transferItem: [item: InventoryItem]
    sell: [item: InventoryItem]
    discard: [item: InventoryItem]
    updatePosition: [itemId: string, x: number, y: number]
    applyBuffs: [buffs: Record<string, number>]
    removeBuffs: [buffs: Record<string, number>]
}>()

// Tab state: 'grid' or 'list'
const viewMode = ref<'grid' | 'list'>('grid')

// Reference to InventoryGrid for checking space
const inventoryGridRef = ref<InstanceType<typeof InventoryGrid> | null>(null)

// Check if there's space for an item in the grid
function hasSpaceForItem(width: number, height: number): boolean {
    if (!inventoryGridRef.value) {
        // If grid not mounted yet, calculate manually
        const equipItems = props.inventoryList.filter(inv => inv.items.type === 'equipment')
        const usedCells = equipItems.reduce((sum, item) => {
            return sum + (item.items.grid_width || 1) * (item.items.grid_height || 1)
        }, 0)
        const totalCells = 12 * 5 // GRID_COLS * GRID_ROWS
        return usedCells + (width * height) <= totalCells
    }
    return inventoryGridRef.value.hasSpaceForItem(width, height)
}

// Get remaining space info
function getRemainingSpace(): { cells: number; total: number } {
    if (!inventoryGridRef.value) {
        const equipItems = props.inventoryList.filter(inv => inv.items.type === 'equipment')
        const usedCells = equipItems.reduce((sum, item) => {
            return sum + (item.items.grid_width || 1) * (item.items.grid_height || 1)
        }, 0)
        const total = 12 * 5
        return { cells: total - usedCells, total }
    }
    return inventoryGridRef.value.getRemainingSpace()
}

// Expose for parent
defineExpose({ hasSpaceForItem, getRemainingSpace })

// Separate equipment and consumables
const equipmentItems = computed(() => 
    props.inventoryList.filter(inv => inv.items.type === 'equipment')
)

const consumableItems = computed(() => 
    props.inventoryList.filter(inv => inv.items.type !== 'equipment')
)

// Handle equip item from equipment slots
function handleEquipItem(item: InventoryItem) {
    // Apply buffs when equipping
    if (item.items.effects) {
        const buffs: Record<string, number> = {}
        for (const [key, value] of Object.entries(item.items.effects)) {
            if (key.startsWith('buff_')) {
                buffs[key] = value as number
            }
        }
        if (Object.keys(buffs).length > 0) {
            emit('applyBuffs', buffs)
        }
    }
    emit('toggleEquip', item)
}

// Handle unequip item from equipment slots
function handleUnequipItem(item: InventoryItem) {
    // Remove buffs when unequipping
    if (item.items.effects) {
        const buffs: Record<string, number> = {}
        for (const [key, value] of Object.entries(item.items.effects)) {
            if (key.startsWith('buff_')) {
                buffs[key] = value as number
            }
        }
        if (Object.keys(buffs).length > 0) {
            emit('removeBuffs', buffs)
        }
    }
    emit('toggleEquip', item)
}

// Handle toggle equip from grid
function handleToggleEquip(item: InventoryItem) {
    if (item.is_equipped) {
        handleUnequipItem(item)
    } else {
        handleEquipItem(item)
    }
}

// Handle position update
function handleUpdatePosition(itemId: string, x: number, y: number) {
    emit('updatePosition', itemId, x, y)
}
</script>

<template>
    <div class="animate-fade-in">
        <!-- Money Cards -->
        <div class="flex flex-col md:flex-row gap-4 mb-6">
            <!-- Cash Card -->
            <div class="flex-1 bg-gradient-to-r from-yellow-900/40 to-black border border-yellow-600 p-6 rounded-lg flex items-center justify-between shadow-lg">
                <div>
                    <h3 class="text-yellow-500 font-bold uppercase text-sm tracking-wider">เงินสด (Cash)</h3>
                    <div class="text-4xl font-serif text-white">฿{{ currentUser.money }}</div>
                </div>
                <div class="flex flex-col gap-2">
                    <div class="text-5xl text-center">💰</div>
                    <button 
                        @click="emit('deposit')" 
                        class="text-xs bg-yellow-700 hover:bg-yellow-600 text-black font-bold px-3 py-1 rounded border border-yellow-500 shadow"
                    >
                        ⬇️ ฝากเข้าธนาคาร
                    </button>
                </div>
            </div>

            <!-- Bank Card -->
            <div class="flex-1 bg-gradient-to-r from-blue-900/40 to-black border border-blue-600 p-6 rounded-lg flex items-center justify-between shadow-lg">
                <div>
                    <h3 class="text-blue-400 font-bold uppercase text-sm tracking-wider">ธนาคาร (Bank)</h3>
                    <div class="text-4xl font-serif text-white">฿{{ currentUser.bank_balance }}</div>
                </div>
                <div class="flex flex-col gap-2">
                    <div class="text-5xl text-center">🏦</div>
                    <button 
                        @click="emit('withdraw')" 
                        class="text-xs bg-blue-800 hover:bg-blue-700 text-white font-bold px-3 py-1 rounded border border-blue-500 shadow mb-1"
                    >
                        ⬆️ ถอนออกมา
                    </button>
                    <button 
                        @click="emit('transfer')" 
                        class="text-xs bg-purple-800 hover:bg-purple-700 text-white font-bold px-3 py-1 rounded border border-purple-500 shadow"
                    >
                        💸 โอนเงิน
                    </button>
                </div>
            </div>
        </div>

        <!-- Equipment Section -->
        <div class="mb-6">
            <h2 class="text-2xl text-vic-gold font-bold font-serif mb-4 border-b border-vic-brown pb-2 flex items-center gap-3">
                <span>⚔️ อุปกรณ์</span>
                <!-- View Toggle -->
                <div class="flex gap-1 ml-auto text-sm">
                    <button 
                        @click="viewMode = 'grid'"
                        class="px-3 py-1 rounded border transition"
                        :class="viewMode === 'grid' 
                            ? 'bg-vic-gold text-black border-vic-gold' 
                            : 'bg-black/40 text-gray-400 border-gray-700 hover:border-vic-gold'"
                    >
                        📦 กริด
                    </button>
                    <button 
                        @click="viewMode = 'list'"
                        class="px-3 py-1 rounded border transition"
                        :class="viewMode === 'list' 
                            ? 'bg-vic-gold text-black border-vic-gold' 
                            : 'bg-black/40 text-gray-400 border-gray-700 hover:border-vic-gold'"
                    >
                        📋 รายการ
                    </button>
                </div>
            </h2>

            <div class="grid grid-cols-1 lg:grid-cols-[1fr_220px] gap-6">
                <!-- Inventory Grid / List -->
                <div>
                    <!-- Grid View -->
                    <div v-if="viewMode === 'grid'" class="overflow-x-auto pb-4">
                        <InventoryGrid 
                            ref="inventoryGridRef"
                            v-if="equipmentItems.length > 0"
                            :items="equipmentItems"
                            @toggle-equip="handleToggleEquip"
                            @update-position="handleUpdatePosition"
                            @transfer-item="item => emit('transferItem', item)"
                            @sell-item="item => emit('sell', item)"
                            @discard-item="item => emit('discard', item)"
                        />
                        <div v-else class="text-center py-10 text-gray-500 border-2 border-dashed border-gray-700 rounded-lg">
                            ยังไม่มีอุปกรณ์... ไปหาซื้อมาเถอะ!
                        </div>
                    </div>

                    <!-- List View -->
                    <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-3">
                        <div 
                            v-for="inv in equipmentItems" 
                            :key="inv.id"
                            class="bg-neutral-900 border p-3 rounded flex gap-3 transition group relative"
                            :class="inv.is_equipped ? 'border-green-500 shadow-[0_0_10px_rgba(34,197,94,0.3)]' : 'border-gray-700 hover:border-vic-gold'"
                        >
                            <!-- Equipped Badge -->
                            <div 
                                v-if="inv.is_equipped" 
                                class="absolute -top-2 -left-2 bg-green-600 text-white text-[10px] font-bold px-2 py-0.5 rounded shadow z-10"
                            >
                                EQUIPPED
                            </div>

                            <!-- Item Image -->
                            <div class="w-14 h-14 bg-black rounded border border-gray-600 shrink-0 overflow-hidden relative">
                                <img :src="inv.items.image_url" class="w-full h-full object-cover" />
                                <div v-if="inv.items.slot_type" class="absolute top-0 left-0 text-[8px] px-1 bg-black/80 text-gray-300 uppercase">
                                    {{ inv.items.slot_type }}
                                </div>
                            </div>

                            <!-- Item Info -->
                            <div class="flex-1 min-w-0">
                                <h4 
                                    class="text-vic-gold font-bold text-sm truncate" 
                                    :class="{ 'text-green-400': inv.is_equipped }"
                                >
                                    {{ inv.items.name }}
                                </h4>
                                <p class="text-[10px] text-gray-500 line-clamp-1">{{ inv.items.description }}</p>
                            </div>

                            <!-- Actions -->
                            <div class="flex flex-col gap-1 justify-center">
                                <button 
                                    @click="handleToggleEquip(inv)"
                                    class="text-xs px-2 py-1 rounded border transition font-bold"
                                    :class="inv.is_equipped 
                                        ? 'bg-green-900 text-green-200 border-green-600 hover:bg-green-800' 
                                        : 'bg-gray-800 text-gray-300 border-gray-600 hover:bg-gray-700'"
                                >
                                    {{ inv.is_equipped ? '⛔' : '✅' }}
                                </button>
                                <button 
                                    @click="emit('transferItem', inv)" 
                                    class="text-xs bg-purple-900 text-purple-200 px-2 py-1 rounded border border-purple-700 hover:bg-purple-800"
                                >
                                    🎁
                                </button>
                            </div>
                        </div>
                        <div v-if="equipmentItems.length === 0" class="col-span-2 text-center py-10 text-gray-500 border-2 border-dashed border-gray-700 rounded-lg">
                            ยังไม่มีอุปกรณ์... ไปหาซื้อมาเถอะ!
                        </div>
                    </div>
                </div>

                <!-- Equipment Slots (Right Side) -->
                <div class="bg-black/30 p-4 rounded-lg border border-vic-brown/30">
                    <EquipmentSlots 
                        :items="inventoryList"
                        @equip-item="handleEquipItem"
                        @unequip-item="handleUnequipItem"
                    />
                </div>
            </div>
        </div>

        <!-- Consumables Section -->
        <div>
            <h2 class="text-2xl text-vic-gold font-bold font-serif mb-4 border-b border-vic-brown pb-2">
                🧪 ของใช้
            </h2>

            <!-- Empty State -->
            <div 
                v-if="consumableItems.length === 0" 
                class="text-center py-10 text-gray-500 border-2 border-dashed border-gray-700 rounded-lg"
            >
                ไม่มีของใช้ในกระเป๋า
            </div>

            <!-- Consumables Grid -->
            <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                <div 
                    v-for="inv in consumableItems" 
                    :key="inv.id"
                    class="bg-neutral-900 border border-gray-700 hover:border-vic-gold p-4 rounded flex gap-4 transition group relative"
                >
                    <!-- Item Image -->
                    <div class="w-16 h-16 bg-black rounded border border-gray-600 shrink-0 overflow-hidden relative">
                        <img :src="inv.items.image_url" class="w-full h-full object-cover" />
                        <div class="absolute bottom-0 right-0 bg-vic-gold text-black text-xs font-bold px-1.5 rounded-tl">
                            x{{ inv.quantity }}
                        </div>
                    </div>

                    <!-- Item Info -->
                    <div class="flex-1">
                        <h4 class="text-vic-gold font-bold">
                            {{ inv.items.name }}
                        </h4>
                        <p class="text-xs text-gray-400 mb-2 capitalize">{{ inv.items.type }}</p>
                        <div class="text-[10px] text-gray-500 bg-black/50 p-1 rounded border border-gray-800">
                            {{ inv.items.description }}
                        </div>
                    </div>

                    <!-- Actions -->
                    <div class="flex flex-col gap-1 justify-center min-w-[70px]">
                        <button 
                            @click="emit('use', inv)" 
                            class="text-xs bg-blue-900 text-blue-200 px-2 py-1 rounded border border-blue-700 hover:bg-blue-800"
                        >
                            ใช้
                        </button>
                        <button 
                            @click="emit('transferItem', inv)" 
                            class="text-xs bg-purple-900 text-purple-200 px-2 py-1 rounded border border-purple-700 hover:bg-purple-800"
                        >
                            🎁 ส่ง
                        </button>
                        <div class="flex gap-1">
                            <button 
                                @click="emit('sell', inv)" 
                                class="flex-1 text-[10px] bg-yellow-900 text-yellow-200 px-1 py-1 rounded border border-yellow-700 hover:bg-yellow-800"
                            >
                                ขาย
                            </button>
                            <button 
                                @click="emit('discard', inv)" 
                                class="flex-1 text-[10px] bg-red-900 text-red-200 px-1 py-1 rounded border border-red-700 hover:bg-red-800"
                            >
                                ทิ้ง
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
