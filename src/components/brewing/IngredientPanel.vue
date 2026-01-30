<script setup lang="ts">
/**
 * IngredientPanel.vue
 * Panel showing available materials for brewing with drag support
 */
import type { InventoryItem } from '@/lib/constants'

const props = defineProps<{
    items: InventoryItem[]
    isBrewing: boolean
    isTimerRunning: boolean
}>()

const emit = defineEmits<{
    dragStart: [item: InventoryItem]
    dragEnd: []
    itemClick: [item: InventoryItem]
}>()

function handleDragStart(e: DragEvent, item: InventoryItem) {
    if (!props.isBrewing || props.isTimerRunning) {
        e.preventDefault()
        return
    }
    
    e.dataTransfer?.setData('text/plain', item.id)
    emit('dragStart', item)
}

function handleDragEnd() {
    emit('dragEnd')
}

function handleClick(item: InventoryItem) {
    emit('itemClick', item)
}

// Get unit from item effects
function getUnit(item: InventoryItem): string {
    const effects = item.items.effects
    if (effects?.unit) return effects.unit
    return 'g' // default
}
</script>

<template>
    <div class="ingredient-panel bg-vic-darkbrown border border-vic-brown rounded-lg p-4">
        <h3 class="text-vic-gold font-bold mb-4 flex items-center gap-2">
            🧫 วัตถุดิบ
            <span class="text-xs text-gray-400 font-normal">({{ items.length }} รายการ)</span>
        </h3>

        <!-- Empty State -->
        <div 
            v-if="items.length === 0"
            class="text-center py-8 text-gray-500"
        >
            <div class="text-3xl mb-2">📦</div>
            <p>ไม่มีวัตถุดิบในกระเป๋า</p>
            <p class="text-sm">ซื้อวัตถุดิบจากร้านค้าก่อน</p>
        </div>

        <!-- Ingredients Grid -->
        <div 
            v-else
            class="grid grid-cols-3 gap-2 max-h-96 overflow-y-auto custom-scroll"
        >
            <div
                v-for="item in items"
                :key="item.id"
                class="ingredient-item relative group cursor-pointer select-none"
                :class="{
                    'opacity-50 cursor-not-allowed': !isBrewing || isTimerRunning,
                    'hover:scale-105 active:scale-95': isBrewing && !isTimerRunning
                }"
                :draggable="isBrewing && !isTimerRunning"
                @dragstart="handleDragStart($event, item)"
                @dragend="handleDragEnd"
                @click="handleClick(item)"
            >
                <!-- Item Card -->
                <div 
                    class="bg-gradient-to-br from-neutral-800 to-neutral-900 rounded-lg border-2 border-neutral-700 overflow-hidden transition-all group-hover:border-vic-gold"
                >
                    <!-- Image -->
                    <div class="relative aspect-square">
                        <img 
                            :src="item.items.image_url" 
                            :alt="item.items.name"
                            class="w-full h-full object-cover"
                            loading="lazy"
                        />
                        
                        <!-- Quantity Badge -->
                        <div 
                            class="absolute top-1 right-1 bg-black/80 px-1.5 py-0.5 rounded text-xs font-bold text-white"
                        >
                            x{{ item.quantity }}
                        </div>

                        <!-- Unit Badge -->
                        <div 
                            class="absolute bottom-1 left-1 bg-purple-900/80 px-1.5 py-0.5 rounded text-xs text-purple-200"
                        >
                            {{ getUnit(item) === 'ml' ? 'มล.' : getUnit(item) === 'g' ? 'กรัม' : 'ชิ้น' }}
                        </div>

                        <!-- Drag Indicator -->
                        <div 
                            v-if="isBrewing && !isTimerRunning"
                            class="absolute inset-0 bg-black/0 group-hover:bg-black/40 flex items-center justify-center transition-all"
                        >
                            <span class="text-2xl opacity-0 group-hover:opacity-100 transition-opacity">
                                👆
                            </span>
                        </div>
                    </div>

                    <!-- Name -->
                    <div class="p-1.5 bg-black/40">
                        <div class="text-xs text-center text-vic-cream truncate">
                            {{ item.items.name }}
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Instructions -->
        <div 
            v-if="isBrewing && !isTimerRunning && items.length > 0"
            class="mt-4 p-3 bg-blue-900/30 border border-blue-600 rounded-lg"
        >
            <div class="text-blue-300 text-sm flex items-center gap-2">
                <span>💡</span>
                <span>ลากวัตถุดิบลงหม้อ หรือคลิกเพื่อใส่</span>
            </div>
        </div>

        <div 
            v-else-if="isTimerRunning"
            class="mt-4 p-3 bg-yellow-900/30 border border-yellow-600 rounded-lg"
        >
            <div class="text-yellow-300 text-sm flex items-center gap-2">
                <span>⏳</span>
                <span>รอให้ต้มเสร็จก่อน</span>
            </div>
        </div>
    </div>
</template>

<style scoped>
.ingredient-item {
    transition: transform 0.15s ease, opacity 0.15s ease;
}

.ingredient-item:active {
    cursor: grabbing;
}
</style>
