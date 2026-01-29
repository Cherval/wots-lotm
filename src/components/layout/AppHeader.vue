<script setup lang="ts">
/**
 * AppHeader.vue
 * Main application header with hero section
 */
import type { Player } from '@/lib/constants'
import { getRoleLabel } from '@/lib/supabase'
import { HEADER_IMG } from '@/lib/constants'

const props = defineProps<{
    currentUser: Player | null
    showInstallButton?: boolean
}>()

const emit = defineEmits<{
    logout: []
    upgrade: []
    install: []
}>()
</script>

<template>
    <div 
        class="w-full h-64 bg-cover bg-center relative border-b-4 border-vic-gold"
        :style="{ backgroundImage: `url(${HEADER_IMG})` }"
    >
        <!-- Overlay -->
        <div class="absolute inset-0 bg-black/60 flex items-center justify-center flex-col">
            <h1 class="text-5xl md:text-6xl text-vic-gold font-bold drop-shadow-lg tracking-wider font-serif">
                Whisper of the Shadow
            </h1>
            <p class="text-vic-cream/80 mt-2 text-xl font-serif">เสียงเพรียกแห่งเงามืด</p>
        </div>

        <!-- User Info & SP Badge -->
        <div class="absolute top-4 right-4 flex items-center gap-3">
            <!-- PWA Install Button -->
            <button 
                v-if="showInstallButton"
                @click="emit('install')"
                class="bg-gradient-to-r from-vic-gold to-yellow-600 hover:from-yellow-500 hover:to-vic-gold text-black px-3 py-1.5 rounded-lg text-xs font-bold shadow-lg flex items-center gap-2 transition-all hover:scale-105"
            >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/>
                </svg>
                ติดตั้งแอป
            </button>

            <!-- SP Notification Badge -->
            <button 
                v-if="currentUser?.skill_points && currentUser.skill_points > 0"
                @click="emit('upgrade')"
                class="bg-green-700/90 hover:bg-green-600 text-white px-3 py-1 rounded text-xs font-bold border border-green-500 animate-pulse shadow-[0_0_10px_rgba(34,197,94,0.5)] flex items-center gap-1"
            >
                💪 SP <span class="bg-black/30 px-1 rounded">{{ currentUser.skill_points }}</span>
            </button>

            <!-- User Profile -->
            <div class="bg-black/80 p-1 px-3 rounded border border-vic-gold flex items-center gap-3">
                <img 
                    :src="currentUser?.character_img_url || 'https://placehold.co/50x50/2a2a2a/d4a574?text=?'"
                    class="w-8 h-8 rounded-full border border-vic-gold object-cover" 
                />
                <div class="text-right hidden md:block">
                    <p class="text-vic-gold font-bold text-sm leading-tight">
                        {{ currentUser?.character_name || 'ผู้เยี่ยมชม' }}
                    </p>
                    <p class="text-[10px] uppercase text-gray-400 leading-tight">
                        {{ getRoleLabel(currentUser?.role || 'player') }}
                    </p>
                </div>
                <button 
                    @click="emit('logout')"
                    class="text-xs text-red-400 hover:text-red-300 border border-red-900 p-1 rounded hover:bg-red-900/30"
                >
                    ออก
                </button>
            </div>
        </div>
    </div>
</template>
