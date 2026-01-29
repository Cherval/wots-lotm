<script setup lang="ts">
/**
 * PlayersList.vue
 * Players list view component
 */
import type { Player, Pathway, Sequence } from '@/lib/constants'
import CharacterCard from './CharacterCard.vue'

defineProps<{
    players: Player[]
    currentUserId?: string
    isAdmin: boolean
    isSuperAdmin: boolean
    pathways: Pathway[]
    sequences: Sequence[]
    loading: boolean
}>()

const emit = defineEmits<{
    create: []
    embed: [player: Player]
    edit: [player: Player]
    grantMoney: [player: Player]
    grantSp: [player: Player]
    changeStatus: [playerId: string, status: string]
    delete: [playerId: string]
    viewDetail: [player: Player]
}>()
</script>

<template>
    <div class="animate-fade-in">
        <!-- Header -->
        <div class="flex justify-between items-center mb-6 bg-vic-darkbrown p-4 rounded border border-vic-brown">
            <h2 class="text-2xl text-vic-gold font-bold font-serif">ทำเนียบตัวละคร</h2>
            <button 
                v-if="isAdmin" 
                @click="emit('create')" 
                :disabled="loading" 
                class="btn-gold text-sm"
            >
                + เพิ่มผู้เล่น
            </button>
        </div>

        <!-- Players Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <CharacterCard
                v-for="player in players"
                :key="player.id"
                :player="player"
                :current-user-id="currentUserId"
                :is-admin="isAdmin"
                :is-super-admin="isSuperAdmin"
                :pathways="pathways"
                :sequences="sequences"
                @embed="emit('embed', $event)"
                @edit="emit('edit', $event)"
                @grant-money="emit('grantMoney', $event)"
                @grant-sp="emit('grantSp', $event)"
                @change-status="(playerId: string, status: string) => emit('changeStatus', playerId, status)"
                @delete="emit('delete', $event)"
                @view-detail="emit('viewDetail', $event)"
            />
        </div>
    </div>
</template>
