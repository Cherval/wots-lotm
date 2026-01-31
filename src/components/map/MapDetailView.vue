<template>
  <div class="animate-fade-in h-[calc(100vh-150px)] flex flex-col">
    <!-- Header Bar -->
    <div class="flex justify-between items-center mb-2 bg-black/50 p-2 rounded border-b border-vic-gold">
      <div class="flex items-center gap-3">
        <button @click="emit('back')" class="text-vic-gold hover:text-white text-lg">❮ กลับ</button>
        <h2 class="text-xl font-bold text-white">{{ map?.name }}</h2>
        <!-- Lock Status Badge -->
        <span 
          v-if="map?.is_locked" 
          class="text-xs bg-red-600 text-white px-2 py-0.5 rounded font-bold flex items-center gap-1"
        >
          🔒 ล็อคอยู่
        </span>
      </div>
      <div class="flex items-center gap-3">
        <span v-if="isEditMode" class="text-xs text-yellow-400 animate-pulse">🔧 โหมดแก้ไข</span>
        <span v-else class="text-xs text-gray-400">คลิกที่ตัวละครเพื่อดูรายละเอียด</span>
        
        <!-- Lock/Unlock Button (Admin Only) -->
        <button
          v-if="isAdmin"
          @click="emit('toggleLock')"
          class="px-3 py-1 text-xs rounded border transition font-bold"
          :class="map?.is_locked 
            ? 'bg-red-900 text-red-200 border-red-600 hover:bg-red-800' 
            : 'bg-green-900 text-green-200 border-green-600 hover:bg-green-800'"
        >
          {{ map?.is_locked ? '🔓 ปลดล็อค' : '🔒 ล็อค' }}
        </button>
        
        <!-- Place Self Button (Player Only, when not on map and not locked) -->
        <button
          v-if="!isAdmin && !isPlayerOnMap && !map?.is_locked && (moveToken ?? 0) >= 3"
          @click="emit('placeSelf')"
          class="px-3 py-1 text-xs rounded border transition font-bold bg-green-900 text-green-200 border-green-600 hover:bg-green-800"
        >
          📍 วางตัวเองที่นี่ (-3 Stamina)
        </button>

        <!-- Move Mode Toggle (Player Only, when on map and not locked) -->
        <button
          v-if="!isAdmin && isPlayerOnMap && !map?.is_locked"
          @click="isMoveMode = !isMoveMode"
          class="px-3 py-1 text-xs rounded border transition font-bold"
          :class="isMoveMode 
            ? 'bg-yellow-600 text-black border-yellow-400 animate-pulse' 
            : 'bg-blue-900 text-blue-200 border-blue-600 hover:bg-blue-800'"
        >
          {{ isMoveMode ? '⚠️ กำลังย้ายตำแหน่ง' : '✋ ย้ายตำแหน่ง' }}
        </button>
        
        <!-- Not enough stamina warning -->
        <span
          v-if="!isAdmin && !isPlayerOnMap && !map?.is_locked && (moveToken ?? 0) < 3"
          class="text-xs text-red-400"
        >
          ⚠️ Stamina ไม่พอ (ต้องการ 3)
        </span>
        
        <!-- Edit Mode Toggle (Admin Only) -->
        <button
          v-if="isAdmin"
          @click="emit('toggleEditMode')"
          class="px-3 py-1 text-xs rounded border transition font-bold"
          :class="isEditMode ? 'bg-yellow-600 text-black border-yellow-400' : 'bg-gray-800 text-gray-300 border-gray-600 hover:bg-gray-700'"
        >
          {{ isEditMode ? '✓ เสร็จสิ้น' : '✏️ แก้ไขตำแหน่ง' }}
        </button>
      </div>
    </div>

    <!-- Stamina Info Bar -->
    <div class="mb-2 p-2 bg-blue-900/30 border border-blue-700/50 rounded flex justify-between items-center">
      <div class="flex items-center gap-2">
        <span class="text-blue-300 text-sm font-bold">🏃 Stamina:</span>
        <span 
          class="text-lg font-bold px-2 py-0.5 rounded"
          :class="(moveToken ?? 0) > 5 ? 'text-green-400 bg-green-900/50' : (moveToken ?? 0) > 2 ? 'text-yellow-400 bg-yellow-900/50' : 'text-red-400 bg-red-900/50'"
        >
          {{ moveToken ?? 0 }}
        </span>
      </div>
      <div class="text-xs text-gray-400">
        <span class="text-blue-300">ℹ️</span> เดินทางในพื้นที่เสีย <span class="text-yellow-300 font-bold">1</span> หน่วย | ข้ามแผนที่อื่นเสีย <span class="text-orange-300 font-bold">3</span> หน่วย
        <span v-if="isAdmin" class="ml-2 text-purple-300">(DM/Assistant ไม่ต้องใช้)</span>
      </div>
    </div>

    <!-- Locked Map Warning (for Players) -->
    <div 
      v-if="!isAdmin && map?.is_locked"
      class="mb-2 p-2 bg-red-900/30 border border-red-700 rounded text-center"
    >
      <span class="text-red-300 text-sm">🔒 แผนที่นี้ถูกล็อค - คุณไม่สามารถย้ายหรือวางตัวละครได้ในขณะนี้</span>
    </div>

    <!-- Map Container -->
    <div
      class="flex-1 overflow-auto bg-neutral-900 relative flex justify-center items-start p-4 border border-vic-brown custom-scroll rounded-lg shadow-inner"
    >
      <div
        class="relative min-w-[800px] w-[1000px] max-w-full aspect-square bg-black shadow-2xl select-none"
        data-map
        @click="handleMapClick"
        @mousemove="onDrag"
        @mouseup="endDrag"
        @mouseleave="endDrag"
        @touchstart="handleTouchStart"
        @touchmove="handleTouchMove"
        @touchend="handleTouchEnd"
      >
        <!-- Map Background -->
        <img
          :src="map?.image_url"
          class="absolute inset-0 w-full h-full object-cover pointer-events-none"
          draggable="false"
        />

        <!-- Character Markers -->
        <template v-for="char in characters" :key="char.id">
          <div
            class="absolute cursor-pointer group z-10"
            :style="{
              left: (draggingCharacter?.id === char.id ? dragPosition.x : char.pos_x_percent) + '%',
              top: (draggingCharacter?.id === char.id ? dragPosition.y : char.pos_y_percent) + '%',
              transform: 'translate(-50%, -50%)' + ((isEditMode || canDrag(char)) && draggingCharacter?.id !== char.id ? ' rotate(0deg)' : ''),
              transition: draggingCharacter?.id === char.id ? 'none' : 'left 0.1s, top 0.1s'
            }"
            :class="{
              'animate-wiggle': (isEditMode || canDrag(char)) && draggingCharacter?.id !== char.id && currentUserId === char.id,
              'z-50 scale-110': draggingCharacter?.id === char.id,
              'ring-4 ring-green-500': currentUserId === char.id,
              'cursor-grab': canDrag(char),
              'cursor-not-allowed opacity-70': !isAdmin && map?.is_locked && currentUserId === char.id
            }"
            @mousedown="startDrag($event, char)"
            @click.stop="handleCharacterClick(char)"
          >
            <!-- Character Avatar -->
            <div
              class="w-10 h-10 md:w-12 md:h-12 rounded-full border-2 border-white shadow-lg overflow-hidden bg-black transition-transform relative"
              :class="{
                'border-green-500 ring-2 ring-green-500 ring-offset-2 ring-offset-black': currentUserId === char.id,
                'scale-125 shadow-2xl border-yellow-400': draggingCharacter?.id === char.id,
                'hover:scale-110': !isEditMode && !canDrag(char),
                'border-red-600 shadow-[0_0_30px_#ef4444] ring-2 ring-red-600 ring-offset-2 ring-offset-black z-20': char.is_enemy
              }"
            >
              <img :src="char.character_img_url" class="w-full h-full object-cover" draggable="false" />

              <!-- Red Glow Overlay for Enemies -->
              <div
                v-if="char.is_enemy"
                class="absolute inset-0 bg-red-600/30 rounded-full animate-pulse pointer-events-none border-2 border-red-500 shadow-[inset_0_0_15px_rgba(255,0,0,0.8)]"
              ></div>

              <!-- Evil Icon Badge -->
              <div
                v-if="char.is_enemy"
                class="absolute -top-2 -right-2 bg-black text-red-500 rounded-full border border-red-500 w-5 h-5 flex items-center justify-center text-[10px] shadow-sm z-30"
              >
                ⚔️
              </div>
              
              <!-- Lock Icon for locked map -->
              <div
                v-if="!isAdmin && map?.is_locked && currentUserId === char.id"
                class="absolute -bottom-1 -right-1 bg-red-600 text-white rounded-full w-4 h-4 flex items-center justify-center text-[8px] shadow-sm z-30"
              >
                🔒
              </div>
            </div>

            <!-- Delete Button (Edit Mode - Admin Only) -->
            <button
              v-if="isEditMode && isAdmin && draggingCharacter?.id !== char.id"
              @mousedown.stop
              @touchstart.stop
              @click.stop="emit('removePosition', char.pos_id)"
              class="absolute -top-1 -right-1 w-5 h-5 bg-red-600 text-white rounded-full flex items-center justify-center text-xs font-bold shadow-lg hover:bg-red-500 border border-red-400 z-30"
            >
              ✕
            </button>

            <!-- Character Name Tooltip -->
            <div
              v-if="!isEditMode"
              class="absolute left-1/2 -translate-x-1/2 -bottom-6 bg-black/90 text-white text-[10px] px-2 py-0.5 rounded whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none border border-vic-gold/50"
            >
              {{ char.character_name }}
            </div>
          </div>
        </template>

        <!-- Click to Place Hint (Admin, non-edit mode) -->
        <div
          v-if="isAdmin && !isEditMode && characters.length === 0"
          class="absolute inset-0 flex items-center justify-center pointer-events-none"
        >
          <div class="bg-black/60 text-vic-gold px-4 py-2 rounded border border-vic-gold/50 text-sm">
            คลิกที่แผนที่เพื่อวางตัวละคร
          </div>
        </div>

        <!-- Mobile Long Press Hint -->
        <div
          v-if="isAdmin && !isEditMode"
          class="absolute bottom-4 left-1/2 -translate-x-1/2 bg-black/70 text-gray-400 px-3 py-1 rounded text-xs md:hidden"
        >
          กดค้าง 1 วินาทีเพื่อแก้ไขตำแหน่ง
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import type { MapData } from '@/lib/constants'

interface Character {
  id: string
  character_name: string
  character_img_url: string
  pos_x_percent: number
  pos_y_percent: number
  pos_id?: string
  is_enemy?: boolean
}

interface Props {
  map: MapData | null
  characters: Character[]
  isEditMode: boolean
  isAdmin: boolean
  currentUserId?: string
  draggingCharacter: Character | null
  dragPosition: { x: number; y: number }
  isPlayerOnMap?: boolean
  moveToken?: number
}

const props = defineProps<Props>()

const emit = defineEmits<{
  back: []
  toggleEditMode: []
  toggleLock: []
  placeSelf: []
  viewCharacter: [char: Character]
  removePosition: [posId: string | undefined]
  startDrag: [event: MouseEvent, char: Character]
  onDrag: [event: MouseEvent]
  endDrag: [event: MouseEvent]
  handleTouchStart: [event: TouchEvent]
  handleTouchMove: [event: TouchEvent]
  handleTouchEnd: [event: TouchEvent]
  handleMapClick: [event: MouseEvent]
}>()

const isDragging = ref(false)
const isMoveMode = ref(false)

// Check if current user can drag (Admin always, Player only if not locked and is self)
const canDrag = (char: Character) => {
  if (props.isAdmin) return props.isEditMode
  // Player can only drag themselves when not locked AND in Move Mode
  if (props.map?.is_locked) return false
  if (!isMoveMode.value) return false
  return char.id === props.currentUserId
}

const startDrag = (event: MouseEvent, char: Character) => {
  if (!canDrag(char)) return
  isDragging.value = false
  emit('startDrag', event, char)
}

const onDrag = (event: MouseEvent) => {
  // Allow drag for admin in edit mode OR player dragging themselves
  if (!props.draggingCharacter) return
  if (!props.isAdmin && props.map?.is_locked) return
  if (!props.isEditMode && !canDrag(props.draggingCharacter)) return
  isDragging.value = true
  emit('onDrag', event)
}

const endDrag = (event: MouseEvent) => {
  if (!props.draggingCharacter) return
  emit('endDrag', event)
  // Reset isDragging after a short delay
  setTimeout(() => {
    isDragging.value = false
  }, 100)
}

const handleCharacterClick = (char: Character) => {
  // Only trigger view character if not in edit mode and not dragging
  if (!props.isEditMode && !isDragging.value) {
    emit('viewCharacter', char)
  }
}

const handleTouchStart = (event: TouchEvent) => {
  emit('handleTouchStart', event)
}

const handleTouchMove = (event: TouchEvent) => {
  emit('handleTouchMove', event)
}

const handleTouchEnd = (event: TouchEvent) => {
  emit('handleTouchEnd', event)
}

const handleMapClick = (event: MouseEvent) => {
  emit('handleMapClick', event)
}
</script>
