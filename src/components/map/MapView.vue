<template>
  <div class="animate-fade-in">
    <div class="flex justify-between items-center mb-6 bg-vic-darkbrown p-4 rounded border border-vic-brown">
      <h2 class="text-2xl text-vic-gold font-bold font-serif">แผนที่โลก (World Maps)</h2>
      <button @click="emit('createMap')" class="btn-gold text-sm">+ สร้างแผนที่</button>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div v-for="map in maps" :key="map.id" class="group relative bg-black border-2 border-vic-brown rounded-lg overflow-hidden shadow-lg hover:border-vic-gold transition">
        <img :src="map.image_url" class="w-full h-48 object-cover opacity-70 group-hover:opacity-100 transition duration-500" />
        
        <div v-if="isUserInMap(map.id)" class="absolute top-2 left-2 bg-green-600 text-white text-xs font-bold px-2 py-1 rounded shadow animate-pulse border border-green-400">
          📍 คุณอยู่ที่นี่
        </div>

        <div class="p-4 relative bg-vic-darkbrown">
          <h3 class="text-xl text-vic-gold font-bold mb-1">{{ map.name }}</h3>
          <p class="text-xs text-gray-400 mb-4 line-clamp-2">{{ map.description || 'ไม่มีรายละเอียด' }}</p>

          <div class="flex gap-2">
            <button @click="emit('viewMap', map)" class="flex-1 bg-vic-gold text-black font-bold py-2 rounded text-sm hover:bg-white transition">
              เปิดดูแผนที่เต็ม
            </button>
            <button @click="emit('editMap', map)" class="px-3 bg-blue-900 text-blue-200 rounded border border-blue-700 hover:bg-blue-800">
              ✏️
            </button>
            <button @click="emit('deleteMap', map.id)" class="px-3 bg-red-900 text-red-200 rounded border border-red-700 hover:bg-red-800">
              🗑️
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { MapData } from '@/lib/constants'

interface Props {
  maps: MapData[]
  currentUserId?: string
}

const props = defineProps<Props>()

const emit = defineEmits<{
  createMap: []
  viewMap: [map: MapData]
  editMap: [map: MapData]
  deleteMap: [mapId: string]
}>()

const isUserInMap = (mapId: string) => {
  // Check if user has a position in this map
  // Will be handled in parent component
  return false
}
</script>
