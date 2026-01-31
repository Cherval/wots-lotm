<script setup lang="ts">
/**
 * CharacterCard.vue
 * Character card component for players/enemies display
 */
import type { Player, Pathway, Sequence } from '@/lib/constants'

const props = defineProps<{
    player: Player
    isAdmin: boolean
    isSuperAdmin: boolean
    currentUserId?: string
    pathways: Pathway[]
    sequences: Sequence[]
}>()

const emit = defineEmits<{
    embed: [player: Player]
    edit: [player: Player]
    grantMoney: [player: Player]
    grantSp: [player: Player]
    grantStamina: [player: Player]
    changeStatus: [playerId: string, status: string]
    delete: [playerId: string]
    viewDetail: [player: Player]
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
    <div 
        v-if="player.status !== 'hide' || isAdmin"
        class="group bg-vic-darkbrown border border-vic-gold p-0 rounded overflow-hidden hover:shadow-2xl hover:border-white transition relative flex flex-col"
        :class="['status-' + player.status]"
    >
        <!-- Card Image -->
        <div class="h-72 overflow-hidden relative bg-black card-content">
            <img 
                :src="player.character_img_url"
                class="w-full h-full object-cover object-top transition duration-700 group-hover:scale-110 opacity-90 group-hover:opacity-100" 
            />
            <div class="absolute inset-0 bg-gradient-to-t from-black via-transparent to-transparent opacity-90"></div>

            <!-- Embed Button -->
            <div class="absolute top-2 left-2 z-20">
                <button 
                    @click="emit('embed', player)" 
                    class="bg-black/60 text-vic-gold border border-vic-gold/50 p-1.5 rounded hover:bg-vic-gold hover:text-black transition shadow-lg"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M17.25 6.75 22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3-4.5 19" />
                    </svg>
                </button>
            </div>

            <!-- Admin Actions -->
            <div v-if="isAdmin" class="absolute top-2 right-2 flex flex-col gap-1 opacity-0 group-hover:opacity-100 transition-opacity duration-200 z-30" @click.stop>
                <button 
                    @click="emit('grantMoney', player)" 
                    class="bg-yellow-700/90 text-white p-1.5 rounded hover:bg-yellow-600 text-xs border border-yellow-500 shadow flex items-center gap-1 w-full justify-center"
                >
                    💸 เสกเงิน
                </button>
                <button 
                    @click="emit('grantSp', player)" 
                    class="bg-purple-900/90 text-purple-200 p-1.5 rounded hover:bg-purple-800 text-xs border border-purple-500 shadow flex items-center gap-1 w-full justify-center"
                >
                    🎁 SP
                </button>
                <button 
                    @click="emit('grantStamina', player)" 
                    class="bg-cyan-900/90 text-cyan-200 p-1.5 rounded hover:bg-cyan-800 text-xs border border-cyan-500 shadow flex items-center gap-1 w-full justify-center"
                >
                    🏃 Stamina
                </button>
                <button 
                    @click="emit('edit', player)" 
                    class="bg-blue-900/90 text-blue-200 p-1.5 rounded hover:bg-blue-800 text-xs border border-blue-500 shadow flex items-center gap-1 w-full justify-center"
                >
                    ✏️ แก้
                </button>

                <!-- Status Dropdown -->
                <div class="relative group/status w-full">
                    <button class="bg-yellow-900/90 text-yellow-200 p-1.5 rounded border border-yellow-500 shadow text-xs w-full text-center">
                        👁️ สถานะ
                    </button>
                    <div class="absolute right-0 top-0 mr-full bg-vic-darkbrown border border-vic-gold rounded shadow-xl hidden group-hover/status:block w-32 z-30 overflow-hidden">
                        <button 
                            @click="emit('changeStatus', player.id, 'active')" 
                            class="block w-full text-left px-3 py-2 hover:bg-white/10 text-green-400 text-xs"
                        >
                            Active
                        </button>
                        <button 
                            @click="emit('changeStatus', player.id, 'vip')" 
                            class="block w-full text-left px-3 py-2 hover:bg-white/10 text-yellow-400 text-xs"
                        >
                            VIP
                        </button>
                        <button 
                            @click="emit('changeStatus', player.id, 'hide')" 
                            class="block w-full text-left px-3 py-2 hover:bg-white/10 text-gray-400 text-xs"
                        >
                            Hide
                        </button>
                        <button 
                            @click="emit('changeStatus', player.id, 'die')" 
                            class="block w-full text-left px-3 py-2 hover:bg-white/10 text-red-500 text-xs"
                        >
                            Die
                        </button>
                    </div>
                </div>

                <button 
                    v-if="isSuperAdmin" 
                    @click="emit('delete', player.id)" 
                    class="bg-red-900/90 text-red-200 p-1.5 rounded hover:bg-red-800 text-xs border border-red-500 shadow w-full"
                >
                    🗑️ ลบ
                </button>
            </div>

            <!-- Character Info Overlay -->
            <div class="absolute bottom-3 left-4 right-4">
                <div class="flex justify-between items-end mb-1">
                    <h3 class="text-2xl font-bold text-vic-gold truncate font-serif drop-shadow-md">
                        {{ player.character_name }}
                    </h3>
                    <span 
                        v-if="isAdmin || currentUserId === player.id" 
                        class="text-[10px] bg-blue-900/80 text-blue-200 px-2 py-0.5 rounded border border-blue-500"
                    >
                        SP: {{ player.skill_points || 0 }}
                    </span>
                </div>

                <!-- Combat Stats Badges -->
                <div class="flex gap-2 my-1.5">
                    <span class="text-[10px] bg-red-900/80 text-white px-2 py-0.5 rounded border border-red-500/50 font-bold shadow">
                        HP {{ player.hp }}
                    </span>
                    <span class="text-[10px] bg-orange-900/80 text-white px-2 py-0.5 rounded border border-orange-500/50 font-bold shadow">
                        ATK {{ player.atk || 0 }}
                    </span>
                    <span class="text-[10px] bg-blue-900/80 text-white px-2 py-0.5 rounded border border-blue-500/50 font-bold shadow">
                        AC {{ player.ac || 10 }}
                    </span>
                </div>

                <p class="text-xs text-gray-300">
                    {{ player.pathways }} 
                    <span v-if="player.sequence !== undefined && player.sequence !== null">
                        (Seq {{ player.sequence }}: {{ getJobTitle(player.pathways, player.sequence) }})
                    </span>
                </p>
            </div>
        </div>

        <!-- Death Overlay -->
        <div 
            v-if="player.status === 'die'" 
            class="absolute inset-0 flex items-center justify-center z-10 pointer-events-none"
        >
            <div class="bg-black/60 w-full text-center border-y-4 border-red-600 py-4 transform -rotate-12 backdrop-blur-sm shadow-xl">
                <h1 class="text-6xl font-bold text-red-600 tracking-widest drop-shadow-[0_0_10px_rgba(255,0,0,0.8)] font-serif">
                    OUT
                </h1>
            </div>
        </div>

        <!-- View Detail Button -->
        <button 
            @click="emit('viewDetail', player)" 
            :disabled="player.status === 'die'"
            class="w-full bg-neutral-900 text-vic-gold py-3 text-sm font-bold border-t border-vic-brown hover:bg-vic-gold hover:text-black transition disabled:opacity-50 disabled:cursor-not-allowed"
        >
            {{ player.status === 'die' ? '💀 เสียชีวิตแล้ว' : 'ดูข้อมูลตัวละคร' }}
        </button>
    </div>
</template>
