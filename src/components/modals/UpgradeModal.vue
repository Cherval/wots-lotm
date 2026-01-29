<script setup lang="ts">
/**
 * UpgradeModal.vue
 * Stat upgrade modal (Spend SP)
 */
import { ref, watch, computed } from 'vue'
import type { Player } from '@/lib/constants'
import { STATS_CONFIG } from '@/lib/constants'
import BaseModal from '../ui/BaseModal.vue'

const props = defineProps<{
    show: boolean
    player: Player | null
    loading?: boolean
}>()

const emit = defineEmits<{
    close: []
    submit: [stats: Record<string, number>, usedSP: number]
}>()

const upgradeStats = ref<Record<string, number>>({})
const usedSP = ref(0)

watch(() => props.show, (newVal) => {
    if (newVal && props.player) {
        // Initialize with current stats
        upgradeStats.value = {}
        for (const stat of STATS_CONFIG) {
            upgradeStats.value[stat.key] = props.player[stat.key] ?? 10
        }
        usedSP.value = 0
    }
})

const remainingSP = computed(() => {
    return (props.player?.skill_points ?? 0) - usedSP.value
})

function increaseStat(statKey: string) {
    if (remainingSP.value > 0) {
        upgradeStats.value[statKey]++
        usedSP.value++
    }
}

function handleSubmit() {
    if (usedSP.value > 0) {
        emit('submit', { ...upgradeStats.value }, usedSP.value)
    }
}
</script>

<template>
    <BaseModal 
        :show="show" 
        size="xl"
        border-color="border-green-500"
        @close="emit('close')"
    >
        <template #default>
            <!-- Header -->
            <div class="flex justify-between items-center mb-4">
                <div>
                    <h3 class="text-2xl text-green-400 font-bold">อัปเกรดพลัง</h3>
                    <p class="text-gray-400 text-sm">ใช้ SP เพื่อเพิ่มค่าสถานะ</p>
                </div>
                <div class="text-right">
                    <span class="block text-xs text-gray-500">แต้มคงเหลือ</span>
                    <span class="text-2xl font-bold text-green-400">{{ remainingSP }} SP</span>
                </div>
            </div>

            <!-- Stats Grid -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 max-h-[50vh] overflow-y-auto custom-scroll p-1">
                <div 
                    v-for="stat in STATS_CONFIG" 
                    :key="stat.key" 
                    class="bg-neutral-900 p-3 rounded border border-gray-700 flex justify-between items-center"
                >
                    <div>
                        <div class="text-sm text-gray-400 font-bold">{{ stat.label }}</div>
                        <div class="text-2xl font-bold text-white">{{ upgradeStats[stat.key] }}</div>
                    </div>
                    <div class="flex items-center gap-2">
                        <div class="text-xs bg-black px-2 py-1 rounded text-gray-500">
                            Mod: {{ Math.floor((upgradeStats[stat.key] - 10) / 2) }}
                        </div>
                        <button 
                            @click="increaseStat(stat.key)" 
                            :disabled="remainingSP <= 0"
                            class="w-8 h-8 rounded bg-green-700 hover:bg-green-600 text-white font-bold flex items-center justify-center border border-green-500 disabled:opacity-30 disabled:cursor-not-allowed"
                        >
                            +
                        </button>
                    </div>
                </div>
            </div>
        </template>

        <template #footer>
            <div class="flex justify-end gap-3">
                <button 
                    @click="emit('close')" 
                    :disabled="loading" 
                    class="px-4 py-2 text-gray-400 hover:text-white"
                >
                    ยกเลิก
                </button>
                <button 
                    @click="handleSubmit" 
                    :disabled="loading || usedSP === 0"
                    class="bg-green-700 hover:bg-green-600 text-white px-6 py-2 rounded font-bold shadow-lg disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
                >
                    <svg v-if="loading" class="animate-spin h-4 w-4" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
                    </svg>
                    {{ loading ? 'กำลังบันทึก...' : 'ยืนยัน' }}
                </button>
            </div>
        </template>
    </BaseModal>
</template>
