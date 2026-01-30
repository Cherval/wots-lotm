<script setup lang="ts">
/**
 * BrewingResultModal.vue
 * Modal showing brewing success/failure result
 */
import type { Item } from '@/lib/constants'
import BaseModal from '../ui/BaseModal.vue'

const props = defineProps<{
    show: boolean
    result: {
        success: boolean
        message: string
        accuracy: number
        reward?: Item
    }
}>()

const emit = defineEmits<{
    close: []
}>()
</script>

<template>
    <BaseModal 
        :show="show" 
        :title="result.success ? '🎉 ปรุงยาสำเร็จ!' : '💥 ปรุงยาล้มเหลว'"
        size="md"
        :border-color="result.success ? 'border-green-500' : 'border-red-500'"
        @close="emit('close')"
    >
        <div class="text-center space-y-6">
            <!-- Icon Animation -->
            <div class="relative">
                <div 
                    class="text-8xl animate-bounce"
                    :class="{ 'animate-wiggle': !result.success }"
                >
                    {{ result.success ? '✨' : '💨' }}
                </div>
                
                <!-- Sparkles for success -->
                <div v-if="result.success" class="absolute inset-0 pointer-events-none">
                    <div 
                        v-for="i in 8"
                        :key="i"
                        class="absolute text-2xl animate-ping"
                        :style="{
                            left: `${20 + (i % 4) * 20}%`,
                            top: `${15 + Math.floor(i / 4) * 50}%`,
                            animationDelay: `${i * 0.1}s`,
                            animationDuration: '1.5s'
                        }"
                    >
                        ✨
                    </div>
                </div>
            </div>

            <!-- Accuracy Score -->
            <div class="relative">
                <div class="text-sm text-gray-400 mb-2">ความแม่นยำ</div>
                <div 
                    class="text-5xl font-bold font-mono"
                    :class="{
                        'text-green-400': result.accuracy >= 90,
                        'text-yellow-400': result.accuracy >= 70 && result.accuracy < 90,
                        'text-orange-400': result.accuracy >= 50 && result.accuracy < 70,
                        'text-red-400': result.accuracy < 50
                    }"
                >
                    {{ result.accuracy }}%
                </div>
                
                <!-- Accuracy Bar -->
                <div class="w-full h-4 bg-gray-800 rounded-full mt-3 overflow-hidden">
                    <div 
                        class="h-full transition-all duration-1000 rounded-full"
                        :class="{
                            'bg-gradient-to-r from-green-500 to-green-400': result.accuracy >= 90,
                            'bg-gradient-to-r from-yellow-500 to-yellow-400': result.accuracy >= 70 && result.accuracy < 90,
                            'bg-gradient-to-r from-orange-500 to-orange-400': result.accuracy >= 50 && result.accuracy < 70,
                            'bg-gradient-to-r from-red-500 to-red-400': result.accuracy < 50
                        }"
                        :style="{ width: `${result.accuracy}%` }"
                    />
                </div>
            </div>

            <!-- Message -->
            <div 
                class="p-4 rounded-lg whitespace-pre-line"
                :class="{
                    'bg-green-900/30 border border-green-600 text-green-200': result.success,
                    'bg-red-900/30 border border-red-600 text-red-200': !result.success
                }"
            >
                {{ result.message }}
            </div>

            <!-- Reward Item -->
            <div 
                v-if="result.success && result.reward"
                class="p-4 bg-vic-gold/10 border-2 border-vic-gold rounded-lg"
            >
                <div class="text-sm text-vic-gold mb-3">🎁 ได้รับไอเทม:</div>
                <div class="flex items-center justify-center gap-4">
                    <img 
                        :src="result.reward.image_url"
                        :alt="result.reward.name"
                        class="w-20 h-20 rounded-lg object-cover border-2 border-vic-gold"
                    />
                    <div class="text-left">
                        <div class="text-xl text-vic-gold font-bold">{{ result.reward.name }}</div>
                        <div class="text-sm text-gray-400">{{ result.reward.description }}</div>
                    </div>
                </div>
            </div>

            <!-- Rating Stars -->
            <div class="flex justify-center gap-2">
                <span 
                    v-for="i in 5"
                    :key="i"
                    class="text-3xl transition-transform hover:scale-125"
                    :class="{
                        'text-yellow-400': i <= Math.ceil(result.accuracy / 20),
                        'text-gray-600': i > Math.ceil(result.accuracy / 20)
                    }"
                >
                    ⭐
                </span>
            </div>
        </div>

        <template #footer>
            <button
                @click="emit('close')"
                class="w-full py-3 btn-gold text-lg"
            >
                {{ result.success ? '🎉 ยอดเยี่ยม!' : '🔄 ลองใหม่' }}
            </button>
        </template>
    </BaseModal>
</template>

<style scoped>
@keyframes wiggle {
    0%, 100% { transform: rotate(-5deg); }
    50% { transform: rotate(5deg); }
}

.animate-wiggle {
    animation: wiggle 0.3s ease-in-out infinite;
}
</style>
