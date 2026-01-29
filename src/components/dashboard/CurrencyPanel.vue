<script setup lang="ts">
/**
 * CurrencyPanel.vue
 * Currency display and quick actions panel
 */
defineProps<{
    money: number
    bankBalance: number
    skillPoints: number
}>()

const emit = defineEmits<{
    deposit: []
    withdraw: []
    transfer: []
    upgrade: []
}>()
</script>

<template>
    <div class="w-full md:w-56 flex flex-col gap-3">
        <!-- Cash -->
        <div class="bg-yellow-900/10 p-4 rounded border border-yellow-600/40 text-center">
            <div class="text-[10px] text-yellow-300 uppercase">เงินสด (Cash)</div>
            <div class="text-2xl font-bold text-yellow-400">฿{{ money }}</div>
            <div class="mt-3 flex gap-2">
                <button 
                    @click="emit('deposit')" 
                    class="flex-1 text-xs bg-yellow-700 text-black rounded px-2 py-1 border border-yellow-500"
                >
                    ฝาก
                </button>
                <button 
                    @click="emit('transfer')" 
                    class="flex-1 text-xs bg-purple-800 text-white rounded px-2 py-1"
                >
                    โอน
                </button>
            </div>
        </div>

        <!-- Bank -->
        <div class="bg-blue-900/10 p-4 rounded border border-blue-700/40 text-center">
            <div class="text-[10px] text-blue-300 uppercase">ธนาคาร (Bank)</div>
            <div class="text-2xl font-bold text-blue-300">฿{{ bankBalance }}</div>
            <div class="mt-3">
                <button 
                    @click="emit('withdraw')" 
                    class="w-full text-xs bg-blue-800 text-white rounded px-2 py-1 border border-blue-500"
                >
                    ถอน
                </button>
            </div>
        </div>

        <!-- Skill Points -->
        <div class="bg-black/20 p-3 rounded border border-vic-brown text-center">
            <div class="text-xs text-gray-400">แต้ม SP</div>
            <div class="text-xl font-bold text-green-400">{{ skillPoints }}</div>
            <div class="mt-2">
                <button 
                    @click="emit('upgrade')" 
                    :disabled="skillPoints <= 0"
                    class="text-xs bg-green-700 text-white px-2 py-1 rounded disabled:opacity-50 disabled:cursor-not-allowed"
                >
                    ใช้ SP
                </button>
            </div>
        </div>
    </div>
</template>
