<script setup lang="ts">
/**
 * DashboardView.vue
 * Main dashboard view with character overview
 */
import { computed } from 'vue'
import type { Player, Sequence, Pathway } from '@/lib/constants'
import { STATS_CONFIG } from '@/lib/constants'
import { getRoleLabel } from '@/lib/supabase'
import StatCard from './StatCard.vue'
import CombatStats from './CombatStats.vue'
import CurrencyPanel from './CurrencyPanel.vue'
import SkillsGrid from './SkillsGrid.vue'

const props = defineProps<{
    currentUser: Player
    skills: Record<string, number>
    pathways: Pathway[]
    sequences: Sequence[]
    isAdmin: boolean
}>()

const emit = defineEmits<{
    embed: [player: Player]
    edit: [player: Player]
    deposit: []
    withdraw: []
    transfer: []
    upgrade: []
}>()

function getJobTitle(pathwayName: string, seqNum: number): string {
    const path = props.pathways.find(p => p.name === pathwayName)
    if (!path) return ''
    
    const seq = props.sequences.find(
        s => s.pathway_id === path.id && s.seq_number == seqNum
    )
    return seq ? seq.title : ''
}
</script>

<template>
    <div class="max-w-4xl mx-auto animate-fade-in">
        <div class="bg-vic-darkbrown p-6 rounded border border-vic-gold flex flex-col md:flex-row gap-6 items-stretch shadow-2xl relative overflow-hidden">
            
            <!-- Left: Portrait -->
            <div class="w-full md:w-1/3 text-center relative group isolate">
                <!-- Ambient Light Effect -->
                <div 
                    class="absolute inset-0 bg-cover bg-center rounded-lg blur-3xl opacity-60 scale-125 transition-opacity duration-1000 animate-pulse pointer-events-none -z-10 mix-blend-screen"
                    :style="{ backgroundImage: `url(${currentUser?.character_img_url || 'https://placehold.co/300x300/2a2a2a/d4a574?text=No+Image'})` }"
                ></div>
                
                <!-- Glow behind image -->
                <div class="absolute inset-4 bg-vic-gold/30 rounded-full blur-2xl -z-10 animate-pulse"></div>

                <img 
                    :src="currentUser?.character_img_url || 'https://placehold.co/300x300/2a2a2a/d4a574?text=No+Image'" 
                    class="w-full h-64 object-cover border-4 border-vic-gold rounded shadow-2xl mb-4 relative z-10" 
                />
                
                <div class="text-sm text-gray-400 relative z-10">{{ currentUser?.name || '-' }}</div>
                
                <div class="mt-3 flex justify-center gap-2 relative z-10">
                    <button 
                        @click="emit('embed', currentUser)" 
                        class="px-3 py-1 text-xs bg-black/60 text-vic-gold rounded border border-vic-gold/30"
                    >
                        Embed
                    </button>
                    <button 
                        v-if="isAdmin || currentUser?.id" 
                        @click="emit('edit', currentUser)"
                        class="px-3 py-1 text-xs bg-blue-900 text-blue-200 rounded border border-blue-700"
                    >
                        แก้ไข
                    </button>
                </div>
            </div>

            <!-- Middle: Identity & Core info -->
            <div class="flex-1">
                <h2 class="text-3xl text-vic-gold font-bold mb-1 font-serif">
                    {{ currentUser?.character_name || 'ผู้เยี่ยมชม' }}
                </h2>
                <p class="text-gray-400 italic mb-4">
                    {{ currentUser?.nationality || '-' }} | {{ currentUser?.sex || '-' }}
                </p>

                <!-- Character Info Grid -->
                <div class="grid grid-cols-2 gap-3 mb-4">
                    <div class="bg-black/20 p-3 rounded border border-vic-brown">
                        <div class="text-[10px] text-vic-gold uppercase">เส้นทาง</div>
                        <div class="text-lg font-bold">{{ currentUser?.pathways || '-' }}</div>
                    </div>
                    <div class="bg-black/20 p-3 rounded border border-vic-brown">
                        <div class="text-[10px] text-vic-gold uppercase">ลำดับ</div>
                        <div class="text-lg font-bold">
                            {{ currentUser?.sequence || '-' }} 
                            <span v-if="currentUser?.sequence"> — {{ getJobTitle(currentUser?.pathways, currentUser?.sequence) }}</span>
                        </div>
                    </div>
                    <div class="bg-black/20 p-3 rounded border border-vic-brown">
                        <div class="text-[10px] text-vic-gold uppercase">บทบาท</div>
                        <div class="text-lg font-bold">{{ getRoleLabel(currentUser?.role) }}</div>
                    </div>
                    <div class="bg-black/20 p-3 rounded border border-vic-brown">
                        <div class="text-[10px] text-vic-gold uppercase">สถานะ</div>
                        <div class="text-lg font-bold">{{ currentUser?.status || 'active' }}</div>
                    </div>
                </div>

                <!-- Combat Stats -->
                <CombatStats 
                    :hp="currentUser?.hp ?? 0"
                    :atk="currentUser?.atk ?? 0"
                    :ac="currentUser?.ac ?? 10"
                />

                <!-- Stats Summary -->
                <div class="mb-4">
                    <h3 class="text-sm text-vic-gold uppercase font-bold mb-2">ค่าพลัง</h3>
                    <div class="grid grid-cols-3 md:grid-cols-7 gap-2">
                        <StatCard
                            v-for="stat in STATS_CONFIG"
                            :key="stat.key"
                            :label="stat.label"
                            :value="currentUser?.[stat.key] ?? 10"
                            :modifier="currentUser?.[stat.mod]"
                        />
                    </div>
                </div>

                <!-- Skills Preview -->
                <SkillsGrid :skills="skills" />
            </div>

            <!-- Right: Currency & Quick Actions -->
            <CurrencyPanel
                :money="currentUser?.money ?? 0"
                :bank-balance="currentUser?.bank_balance ?? 0"
                :skill-points="currentUser?.skill_points ?? 0"
                @deposit="emit('deposit')"
                @withdraw="emit('withdraw')"
                @transfer="emit('transfer')"
                @upgrade="emit('upgrade')"
            />
        </div>
    </div>
</template>
