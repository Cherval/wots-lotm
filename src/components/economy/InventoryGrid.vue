<template>
  <div class="inventory-grid-wrapper">
    <!-- Grid Container -->
    <div 
      ref="gridContainer"
      class="inventory-grid relative bg-black/60 border-2 border-vic-brown rounded-lg p-2 overflow-hidden"
      :style="{ 
        width: `${(GRID_COLS * CELL_SIZE) + 16}px`, 
        height: `${(GRID_ROWS * CELL_SIZE) + 16}px` 
      }"
      @mousemove="handleDrag"
      @mouseup="handleDrop"
      @mouseleave="handleDrop"
      @touchmove.prevent="handleTouchMove"
      @touchend="handleDrop"
    >
      <!-- Grid Background Cells -->
      <div 
        class="grid gap-0 absolute inset-2"
        :style="{ gridTemplateColumns: `repeat(${GRID_COLS}, ${CELL_SIZE}px)` }"
      >
        <div 
          v-for="i in GRID_COLS * GRID_ROWS" 
          :key="'cell-' + i"
          class="border border-white/5 bg-black/30 transition-colors duration-150"
          :class="{
            'bg-green-900/30 border-green-500/50': isValidDropTarget(i),
            'bg-red-900/30 border-red-500/50': isInvalidDropTarget(i)
          }"
          :style="{ width: `${CELL_SIZE}px`, height: `${CELL_SIZE}px` }"
        />
      </div>

      <!-- Placed Items -->
      <TransitionGroup name="item-move">
        <div
          v-for="item in placedItems"
          :key="item.id"
          class="inventory-item absolute cursor-grab rounded border-2 overflow-hidden transition-all duration-200 group"
          :class="{
            'border-vic-gold shadow-lg': !item.isDragging,
            'border-blue-400 shadow-[0_0_20px_rgba(59,130,246,0.5)] cursor-grabbing z-50 scale-105': item.isDragging,
            'hover:border-white hover:shadow-xl': !item.isDragging
          }"
          :style="getItemStyle(item)"
          @mousedown.prevent="startDrag($event, item)"
          @touchstart.prevent="startTouchDrag($event, item)"
          @click.stop="showItemDetail(item)"
        >
          <!-- Item Background -->
          <div class="absolute inset-0 bg-gradient-to-br from-neutral-800 to-neutral-900" />
          
          <!-- Item Image -->
          <img 
            :src="item.items.image_url" 
            :alt="item.items.name"
            class="absolute inset-0 w-full h-full object-cover opacity-60 group-hover:opacity-80 transition"
          />

          <!-- Item Name Overlay -->
          <div class="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/90 to-transparent p-1">
            <div class="text-[10px] text-vic-gold font-bold truncate text-center leading-tight">
              {{ item.items.name }}
            </div>
            <div v-if="item.quantity > 1" class="text-[9px] text-white/70 text-center">
              x{{ item.quantity }}
            </div>
          </div>

          <!-- Equipped Indicator -->
          <div 
            v-if="item.is_equipped" 
            class="absolute top-0.5 right-0.5 w-3 h-3 bg-green-500 rounded-full border border-white shadow animate-pulse"
          />

          <!-- Slot Type Badge -->
          <div 
            v-if="item.items.slot_type"
            class="absolute top-0.5 left-0.5 text-[8px] px-1 py-0.5 rounded bg-black/70 text-white/80 uppercase font-bold"
          >
            {{ slotTypeLabels[item.items.slot_type] }}
          </div>
        </div>
      </TransitionGroup>

      <!-- Dragging Ghost -->
      <div
        v-if="dragState.isDragging && dragState.item"
        class="absolute pointer-events-none z-50 opacity-70 border-2 border-dashed border-blue-400 rounded bg-blue-900/30"
        :style="getGhostStyle()"
      />
    </div>

    <!-- Item Detail Popup -->
    <Teleport to="body">
      <Transition name="popup">
        <div 
          v-if="selectedItem" 
          class="fixed inset-0 z-[200] flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm"
          @click.self="selectedItem = null"
        >
          <div class="bg-vic-darkbrown border-2 border-vic-gold rounded-lg shadow-2xl max-w-sm w-full animate-slide-up">
            <!-- Header -->
            <div class="relative h-32 overflow-hidden rounded-t-lg">
              <img 
                :src="selectedItem.items.image_url" 
                class="w-full h-full object-cover opacity-80"
              />
              <div class="absolute inset-0 bg-gradient-to-t from-vic-darkbrown via-transparent to-transparent" />
              <button 
                @click="selectedItem = null" 
                class="absolute top-2 right-2 text-white/80 hover:text-white text-xl"
              >✕</button>
            </div>

            <!-- Content -->
            <div class="p-4">
              <h3 class="text-xl text-vic-gold font-bold mb-1">{{ selectedItem.items.name }}</h3>
              <div class="flex gap-2 mb-2">
                <span class="text-xs px-2 py-0.5 bg-black/40 rounded capitalize text-gray-400">
                  {{ selectedItem.items.type }}
                </span>
                <span v-if="selectedItem.items.slot_type" class="text-xs px-2 py-0.5 bg-purple-900/50 rounded text-purple-300">
                  {{ slotTypeLabels[selectedItem.items.slot_type] }}
                </span>
              </div>
              <p class="text-sm text-gray-400 mb-3">{{ selectedItem.items.description }}</p>

              <!-- Effects -->
              <div v-if="selectedItem.items.effects && Object.keys(selectedItem.items.effects).length > 0" class="mb-3">
                <div class="text-xs text-vic-gold font-bold mb-1">Effects:</div>
                <div class="flex flex-wrap gap-1">
                  <span 
                    v-for="(value, key) in selectedItem.items.effects" 
                    :key="key"
                    class="text-xs px-2 py-0.5 bg-green-900/50 rounded text-green-300"
                  >
                    {{ formatEffect(key, value) }}
                  </span>
                </div>
              </div>

              <!-- Sell Price Info -->
              <div class="mb-3 p-2 bg-yellow-900/30 rounded border border-yellow-700/50 flex items-center justify-between">
                <span class="text-xs text-yellow-400">💰 ราคาขายคืน:</span>
                <span class="text-yellow-300 font-bold">฿{{ selectedItem.items.price_sell || Math.floor((selectedItem.items.price_buy || 0) / 2) }}</span>
              </div>

              <!-- Actions -->
              <div class="flex gap-2 mb-2">
                <button 
                  v-if="selectedItem.items.type === 'equipment'"
                  @click="toggleEquip(selectedItem)"
                  class="flex-1 py-2 rounded font-bold text-sm transition"
                  :class="selectedItem.is_equipped 
                    ? 'bg-red-900 text-red-200 border border-red-600 hover:bg-red-800' 
                    : 'bg-green-900 text-green-200 border border-green-600 hover:bg-green-800'"
                >
                  {{ selectedItem.is_equipped ? '⛔ ถอดออก' : '⚔️ สวมใส่' }}
                </button>
                <button 
                  @click="$emit('transfer-item', selectedItem); selectedItem = null"
                  class="px-4 py-2 bg-purple-900 text-purple-200 rounded border border-purple-600 hover:bg-purple-800 text-sm"
                >
                  🎁
                </button>
              </div>
              <!-- Sell/Discard Actions -->
              <div class="flex gap-2">
                <button 
                  @click="$emit('sell-item', selectedItem); selectedItem = null"
                  class="flex-1 py-2 bg-yellow-900 text-yellow-200 rounded border border-yellow-600 hover:bg-yellow-800 text-sm font-bold"
                >
                  💰 ขายคืนร้าน
                </button>
                <button 
                  @click="$emit('discard-item', selectedItem); selectedItem = null"
                  class="flex-1 py-2 bg-red-900 text-red-200 rounded border border-red-600 hover:bg-red-800 text-sm font-bold"
                >
                  🗑️ ทิ้ง
                </button>
              </div>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import type { InventoryItem } from '@/lib/constants'

// Grid Configuration
const GRID_COLS = 12
const GRID_ROWS = 5
const CELL_SIZE = 48  // pixels per cell

interface Props {
  items: InventoryItem[]
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'toggle-equip': [item: InventoryItem]
  'update-position': [itemId: string, x: number, y: number]
  'transfer-item': [item: InventoryItem]
  'sell-item': [item: InventoryItem]
  'discard-item': [item: InventoryItem]
  'grid-full': []
}>()

// Expose function to check if grid has space
function hasSpaceForItem(width: number, height: number): boolean {
  const pos = findNextFreePositionInArray(width, height, placedItems.value)
  return pos.x >= 0 && pos.y >= 0
}

// Calculate remaining grid space
function getRemainingSpace(): { cells: number; total: number } {
  const total = GRID_COLS * GRID_ROWS
  let usedCells = 0
  for (const item of placedItems.value) {
    usedCells += (item.items.grid_width || 1) * (item.items.grid_height || 1)
  }
  return { cells: total - usedCells, total }
}

// Expose for parent component
defineExpose({ hasSpaceForItem, getRemainingSpace })

// Slot type labels
const slotTypeLabels: Record<string, string> = {
  weapon: '⚔️',
  head: '👑',
  body: '🛡️',
  accessory: '💍'
}

// Track if grid is full
const isGridFull = ref(false)

// Placed items with positions
const placedItems = ref<(InventoryItem & { gridX: number; gridY: number; isDragging?: boolean })[]>([])

// Drag state
const dragState = ref({
  isDragging: false,
  item: null as InventoryItem | null,
  startX: 0,
  startY: 0,
  currentX: 0,
  currentY: 0,
  offsetX: 0,
  offsetY: 0
})

// Selected item for popup
const selectedItem = ref<InventoryItem | null>(null)

// Grid container ref
const gridContainer = ref<HTMLElement | null>(null)

// Initialize placed items from props
watch(() => props.items, (newItems) => {
  const equipmentItems = newItems.filter(item => item.items.type === 'equipment')
  
  // Build new placed items array with proper positioning
  const newPlacedItems: (InventoryItem & { gridX: number; gridY: number; isDragging?: boolean })[] = []
  let hasOverflow = false
  
  for (const item of equipmentItems) {
    const width = item.items.grid_width || 1
    const height = item.items.grid_height || 1
    
    // Check if item already has stored position from database
    const hasStoredPosition = typeof item.grid_x === 'number' && typeof item.grid_y === 'number'
    
    // Check if we have existing position in current placedItems
    const existing = placedItems.value.find(p => p.id === item.id)
    
    let gridX: number
    let gridY: number
    
    if (existing) {
      // Use existing position from current state
      gridX = existing.gridX
      gridY = existing.gridY
    } else if (hasStoredPosition && item.grid_x! >= 0 && item.grid_y! >= 0) {
      // Use stored position from database (only if valid)
      gridX = item.grid_x!
      gridY = item.grid_y!
    } else {
      // Find new free position - check against already placed items in THIS array
      const pos = findNextFreePositionInArray(width, height, newPlacedItems)
      gridX = pos.x
      gridY = pos.y
      if (gridX === -1 || gridY === -1) hasOverflow = true
    }
    
    // Validate position doesn't overlap with items already in newPlacedItems
    if (!canPlaceAtInArray(gridX, gridY, width, height, null, newPlacedItems)) {
      // Position is occupied, find a new one
      const pos = findNextFreePositionInArray(width, height, newPlacedItems)
      gridX = pos.x
      gridY = pos.y
      if (gridX === -1 || gridY === -1) hasOverflow = true
    }
    
    // Only add if valid position found
    if (gridX >= 0 && gridY >= 0) {
      newPlacedItems.push({ ...item, gridX, gridY })
    } else {
      // Grid overflow - still add but mark
      newPlacedItems.push({ ...item, gridX: 0, gridY: 0 })
    }
  }
  
  placedItems.value = newPlacedItems
  isGridFull.value = hasOverflow
  
  if (hasOverflow) {
    emit('grid-full')
  }
}, { immediate: true, deep: true })

// Find next free position checking against a specific array
function findNextFreePositionInArray(
  width: number, 
  height: number, 
  itemsArray: { gridX: number; gridY: number; items: { grid_width?: number; grid_height?: number } }[]
): { x: number; y: number } {
  for (let y = 0; y <= GRID_ROWS - height; y++) {
    for (let x = 0; x <= GRID_COLS - width; x++) {
      if (canPlaceAtInArray(x, y, width, height, null, itemsArray)) {
        return { x, y }
      }
    }
  }
  // Grid is full - return -1,-1 to indicate overflow
  return { x: -1, y: -1 }
}

// Check if can place at position in a specific array
function canPlaceAtInArray(
  x: number, 
  y: number, 
  width: number, 
  height: number, 
  excludeId: string | null,
  itemsArray: { id?: string; gridX: number; gridY: number; items: { grid_width?: number; grid_height?: number } }[]
): boolean {
  if (x < 0 || y < 0 || x + width > GRID_COLS || y + height > GRID_ROWS) return false

  for (const item of itemsArray) {
    if (excludeId && item.id === excludeId) continue
    const itemW = item.items.grid_width || 1
    const itemH = item.items.grid_height || 1
    
    // Check overlap
    if (!(x + width <= item.gridX || x >= item.gridX + itemW || 
          y + height <= item.gridY || y >= item.gridY + itemH)) {
      return false
    }
  }
  return true
}

// Check if item can be placed at position
function canPlaceAt(x: number, y: number, width: number, height: number, excludeId: string | null): boolean {
  if (x < 0 || y < 0 || x + width > GRID_COLS || y + height > GRID_ROWS) return false

  for (const item of placedItems.value) {
    if (excludeId && item.id === excludeId) continue
    const itemW = item.items.grid_width || 1
    const itemH = item.items.grid_height || 1
    
    // Check overlap
    if (!(x + width <= item.gridX || x >= item.gridX + itemW || 
          y + height <= item.gridY || y >= item.gridY + itemH)) {
      return false
    }
  }
  return true
}

// Get item style for positioning
function getItemStyle(item: any) {
  const width = (item.items.grid_width || 1) * CELL_SIZE
  const height = (item.items.grid_height || 1) * CELL_SIZE
  
  if (item.isDragging) {
    return {
      width: `${width}px`,
      height: `${height}px`,
      left: `${dragState.value.currentX - dragState.value.offsetX + 8}px`,
      top: `${dragState.value.currentY - dragState.value.offsetY + 8}px`,
      transition: 'none'
    }
  }
  
  return {
    width: `${width}px`,
    height: `${height}px`,
    left: `${item.gridX * CELL_SIZE + 8}px`,
    top: `${item.gridY * CELL_SIZE + 8}px`
  }
}

// Get ghost preview style
function getGhostStyle() {
  if (!dragState.value.item) return {}
  const item = dragState.value.item
  const width = (item.items.grid_width || 1) * CELL_SIZE
  const height = (item.items.grid_height || 1) * CELL_SIZE
  
  // Calculate grid position
  const gridX = Math.round((dragState.value.currentX - dragState.value.offsetX) / CELL_SIZE)
  const gridY = Math.round((dragState.value.currentY - dragState.value.offsetY) / CELL_SIZE)
  
  return {
    width: `${width}px`,
    height: `${height}px`,
    left: `${gridX * CELL_SIZE + 8}px`,
    top: `${gridY * CELL_SIZE + 8}px`
  }
}

// Start dragging
function startDrag(event: MouseEvent, item: InventoryItem & { gridX: number; gridY: number }) {
  const rect = gridContainer.value?.getBoundingClientRect()
  if (!rect) return

  const itemIndex = placedItems.value.findIndex(p => p.id === item.id)
  if (itemIndex !== -1) {
    placedItems.value[itemIndex].isDragging = true
  }

  dragState.value = {
    isDragging: true,
    item: item,
    startX: item.gridX * CELL_SIZE,
    startY: item.gridY * CELL_SIZE,
    currentX: event.clientX - rect.left,
    currentY: event.clientY - rect.top,
    offsetX: event.clientX - rect.left - item.gridX * CELL_SIZE,
    offsetY: event.clientY - rect.top - item.gridY * CELL_SIZE
  }
}

// Touch drag start
function startTouchDrag(event: TouchEvent, item: InventoryItem & { gridX: number; gridY: number }) {
  const touch = event.touches[0]
  const rect = gridContainer.value?.getBoundingClientRect()
  if (!rect || !touch) return

  const itemIndex = placedItems.value.findIndex(p => p.id === item.id)
  if (itemIndex !== -1) {
    placedItems.value[itemIndex].isDragging = true
  }

  dragState.value = {
    isDragging: true,
    item: item,
    startX: item.gridX * CELL_SIZE,
    startY: item.gridY * CELL_SIZE,
    currentX: touch.clientX - rect.left,
    currentY: touch.clientY - rect.top,
    offsetX: touch.clientX - rect.left - item.gridX * CELL_SIZE,
    offsetY: touch.clientY - rect.top - item.gridY * CELL_SIZE
  }
}

// Handle drag move
function handleDrag(event: MouseEvent) {
  if (!dragState.value.isDragging) return
  
  const rect = gridContainer.value?.getBoundingClientRect()
  if (!rect) return

  dragState.value.currentX = event.clientX - rect.left
  dragState.value.currentY = event.clientY - rect.top
}

// Handle touch move
function handleTouchMove(event: TouchEvent) {
  if (!dragState.value.isDragging) return
  
  const touch = event.touches[0]
  const rect = gridContainer.value?.getBoundingClientRect()
  if (!rect || !touch) return

  dragState.value.currentX = touch.clientX - rect.left
  dragState.value.currentY = touch.clientY - rect.top
}

// Handle drop
function handleDrop() {
  if (!dragState.value.isDragging || !dragState.value.item) return
  
  const item = dragState.value.item
  const itemW = item.items.grid_width || 1
  const itemH = item.items.grid_height || 1

  // Calculate target grid position
  let targetX = Math.round((dragState.value.currentX - dragState.value.offsetX) / CELL_SIZE)
  let targetY = Math.round((dragState.value.currentY - dragState.value.offsetY) / CELL_SIZE)

  // Clamp to grid bounds
  targetX = Math.max(0, Math.min(GRID_COLS - itemW, targetX))
  targetY = Math.max(0, Math.min(GRID_ROWS - itemH, targetY))

  // Check if valid position
  const itemIndex = placedItems.value.findIndex(p => p.id === item.id)
  if (itemIndex !== -1) {
    if (canPlaceAt(targetX, targetY, itemW, itemH, item.id)) {
      placedItems.value[itemIndex].gridX = targetX
      placedItems.value[itemIndex].gridY = targetY
      emit('update-position', item.id, targetX, targetY)
    }
    placedItems.value[itemIndex].isDragging = false
  }

  // Reset drag state
  dragState.value = {
    isDragging: false,
    item: null,
    startX: 0,
    startY: 0,
    currentX: 0,
    currentY: 0,
    offsetX: 0,
    offsetY: 0
  }
}

// Check if cell is valid drop target
function isValidDropTarget(cellIndex: number): boolean {
  if (!dragState.value.isDragging || !dragState.value.item) return false
  
  const item = dragState.value.item
  const itemW = item.items.grid_width || 1
  const itemH = item.items.grid_height || 1
  
  const targetX = Math.round((dragState.value.currentX - dragState.value.offsetX) / CELL_SIZE)
  const targetY = Math.round((dragState.value.currentY - dragState.value.offsetY) / CELL_SIZE)
  
  const cellX = (cellIndex - 1) % GRID_COLS
  const cellY = Math.floor((cellIndex - 1) / GRID_COLS)
  
  // Check if this cell is within the item's footprint
  if (cellX >= targetX && cellX < targetX + itemW && cellY >= targetY && cellY < targetY + itemH) {
    return canPlaceAt(targetX, targetY, itemW, itemH, item.id)
  }
  return false
}

// Check if cell is invalid drop target
function isInvalidDropTarget(cellIndex: number): boolean {
  if (!dragState.value.isDragging || !dragState.value.item) return false
  
  const item = dragState.value.item
  const itemW = item.items.grid_width || 1
  const itemH = item.items.grid_height || 1
  
  const targetX = Math.round((dragState.value.currentX - dragState.value.offsetX) / CELL_SIZE)
  const targetY = Math.round((dragState.value.currentY - dragState.value.offsetY) / CELL_SIZE)
  
  const cellX = (cellIndex - 1) % GRID_COLS
  const cellY = Math.floor((cellIndex - 1) / GRID_COLS)
  
  // Check if this cell is within the item's footprint
  if (cellX >= targetX && cellX < targetX + itemW && cellY >= targetY && cellY < targetY + itemH) {
    return !canPlaceAt(targetX, targetY, itemW, itemH, item.id)
  }
  return false
}

// Show item detail popup
function showItemDetail(item: InventoryItem) {
  if (!dragState.value.isDragging) {
    selectedItem.value = item
  }
}

// Toggle equip
function toggleEquip(item: InventoryItem) {
  emit('toggle-equip', item)
  selectedItem.value = null
}

// Format effect for display
function formatEffect(key: string, value: any): string {
  const effectLabels: Record<string, string> = {
    heal_hp: `HP +${value}`,
    buff_str: `STR ${value > 0 ? '+' : ''}${value}`,
    buff_agi: `AGI ${value > 0 ? '+' : ''}${value}`,
    buff_int_stat: `INT ${value > 0 ? '+' : ''}${value}`,
    buff_dex: `DEX ${value > 0 ? '+' : ''}${value}`,
    buff_con: `CON ${value > 0 ? '+' : ''}${value}`,
    buff_wis: `WIS ${value > 0 ? '+' : ''}${value}`,
    buff_cha: `CHA ${value > 0 ? '+' : ''}${value}`,
    buff_atk: `ATK ${value > 0 ? '+' : ''}${value}`,
    buff_ac: `AC ${value > 0 ? '+' : ''}${value}`,
    advance_sequence: '✨ เลื่อนขั้น'
  }
  return effectLabels[key] || `${key}: ${value}`
}
</script>

<style scoped>
.inventory-grid-wrapper {
  user-select: none;
}

.item-move-enter-active,
.item-move-leave-active {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.item-move-enter-from,
.item-move-leave-to {
  opacity: 0;
  transform: scale(0.8);
}

.popup-enter-active,
.popup-leave-active {
  transition: all 0.2s ease;
}

.popup-enter-from,
.popup-leave-to {
  opacity: 0;
}

.popup-enter-from .animate-slide-up,
.popup-leave-to .animate-slide-up {
  transform: translateY(20px);
}
</style>
