<script setup lang="ts">
/**
 * CombatStats.vue
 * Combat stats display (HP, ATK, AC)
 */
defineProps<{
    hp: number
    atk: number
    ac: number
}>()
</script>

<template>
    <div class="mb-4">
        <h3 class="text-sm text-vic-gold uppercase font-bold mb-2">ค่าต่อสู้</h3>
        <div class="grid grid-cols-3 gap-2">
            <!-- HP -->
            <div class="bg-red-900/20 p-3 rounded border border-red-900/50 text-center">
                <div class="text-[10px] text-red-400 uppercase font-bold">HP</div>
                <div class="text-2xl font-bold text-red-500">{{ hp }}</div>
            </div>
            
            <!-- ATK -->
            <div class="bg-orange-900/20 p-3 rounded border border-orange-900/50 text-center">
                <div class="text-[10px] text-orange-400 uppercase font-bold">ATK</div>
                <div class="text-2xl font-bold text-orange-500">{{ atk }}</div>
            </div>
            
            <!-- AC -->
            <div class="bg-blue-900/20 p-3 rounded border border-blue-900/50 text-center">
                <div class="text-[10px] text-blue-400 uppercase font-bold">AC</div>
                <div class="text-2xl font-bold text-blue-300">{{ ac }}</div>
            </div>
        </div>
    </div>
</template>
