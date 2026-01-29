<script setup lang="ts">
/**
 * EnemiesList.vue
 * Enemies list view component
 */
import type { Enemy } from '@/lib/constants'

defineProps<{
    enemies: Enemy[]
    isAdmin: boolean
    isSuperAdmin: boolean
    loading: boolean
}>()

const emit = defineEmits<{
    create: []
    edit: [enemy: Enemy]
    delete: [enemyId: string]
    viewDetail: [enemy: Enemy]
}>()
</script>

<template>
    <div class="animate-fade-in">
        <!-- Header -->
        <div class="flex justify-between items-center mb-6 bg-red-950/30 p-4 rounded border border-red-900">
            <h2 class="text-2xl text-red-500 font-bold font-serif">บัญชีศัตรู</h2>
            <button 
                v-if="isAdmin" 
                @click="emit('create')" 
                :disabled="loading" 
                class="px-4 py-2 bg-red-900 text-red-100 border border-red-600 rounded hover:bg-red-800 font-bold text-sm"
            >
                + เพิ่มศัตรู
            </button>
        </div>

        <!-- Enemies Grid -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div 
                v-for="enemy in enemies" 
                :key="enemy.id" 
                class="bg-neutral-900 border border-red-900 p-4 rounded hover:border-red-500 transition relative group"
            >
                <div class="flex gap-4">
                    <img 
                        :src="enemy.character_img_url || 'https://placehold.co/100x100/2a2a2a/d4a574?text=Enemy'" 
                        class="w-20 h-20 object-cover rounded border border-red-800 shrink-0" 
                    />
                    <div>
                        <h3 class="text-lg text-red-500 font-bold mb-1">{{ enemy.character_name }}</h3>
                        <p class="text-sm text-gray-500">{{ enemy.pathways }}</p>
                        <p class="text-xs text-red-400 mt-1">HP: {{ enemy.hp }}</p>
                    </div>
                </div>

                <!-- Actions -->
                <div class="mt-4 flex gap-2">
                    <button 
                        @click="emit('viewDetail', enemy)" 
                        :disabled="loading" 
                        class="flex-1 text-xs text-center border border-red-900 text-red-400 py-1 rounded hover:bg-red-900 hover:text-white transition"
                    >
                        ค่าพลัง
                    </button>
                    <button 
                        v-if="isAdmin" 
                        @click="emit('edit', enemy)" 
                        :disabled="loading" 
                        class="px-2 text-xs border border-blue-900 text-blue-400 rounded hover:bg-blue-900 hover:text-white"
                    >
                        แก้ไข
                    </button>
                    <button 
                        v-if="isSuperAdmin" 
                        @click="emit('delete', enemy.id)" 
                        :disabled="loading" 
                        class="px-2 text-xs border border-red-900 text-red-400 rounded hover:bg-red-900 hover:text-white"
                    >
                        ลบ
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>
