<script setup lang="ts">
/**
 * BrewingTimer.vue
 * Real-time countdown timer with visual effects
 */
import { ref, watch, onUnmounted, computed } from 'vue'

const props = defineProps<{
    duration: number      // Total seconds
    isRunning: boolean
}>()

const emit = defineEmits<{
    complete: []
    tick: [remaining: number]
}>()

const remaining = ref(props.duration)
let intervalId: ReturnType<typeof setInterval> | null = null

// Progress percentage
const progress = computed(() => {
    if (props.duration === 0) return 0
    return ((props.duration - remaining.value) / props.duration) * 100
})

// Format time as MM:SS
const formattedTime = computed(() => {
    const mins = Math.floor(remaining.value / 60)
    const secs = remaining.value % 60
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
})

// Color based on remaining time
const timerColor = computed(() => {
    const percent = remaining.value / props.duration
    if (percent > 0.5) return { text: 'text-green-400', bg: 'from-green-500 to-green-600', ring: 'ring-green-500' }
    if (percent > 0.25) return { text: 'text-yellow-400', bg: 'from-yellow-500 to-orange-500', ring: 'ring-yellow-500' }
    return { text: 'text-red-400', bg: 'from-red-500 to-red-600', ring: 'ring-red-500' }
})

// Start/stop timer based on isRunning
watch(() => props.isRunning, (running) => {
    if (running) {
        remaining.value = props.duration
        startTimer()
    } else {
        stopTimer()
    }
}, { immediate: true })

watch(() => props.duration, (newDuration) => {
    if (props.isRunning) {
        remaining.value = newDuration
    }
})

function startTimer() {
    stopTimer() // Clear any existing interval
    
    intervalId = setInterval(() => {
        remaining.value--
        emit('tick', remaining.value)
        
        if (remaining.value <= 0) {
            stopTimer()
            emit('complete')
        }
    }, 1000)
}

function stopTimer() {
    if (intervalId) {
        clearInterval(intervalId)
        intervalId = null
    }
}

onUnmounted(() => {
    stopTimer()
})
</script>

<template>
    <div class="brewing-timer flex flex-col items-center py-4">
        <!-- Circular Progress -->
        <div class="relative w-32 h-32">
            <!-- Background Circle -->
            <svg class="w-full h-full -rotate-90" viewBox="0 0 100 100">
                <circle
                    cx="50"
                    cy="50"
                    r="45"
                    fill="none"
                    stroke="#374151"
                    stroke-width="8"
                />
                <!-- Progress Circle -->
                <circle
                    cx="50"
                    cy="50"
                    r="45"
                    fill="none"
                    :stroke="timerColor.text === 'text-green-400' ? '#22c55e' : timerColor.text === 'text-yellow-400' ? '#eab308' : '#ef4444'"
                    stroke-width="8"
                    stroke-linecap="round"
                    :stroke-dasharray="283"
                    :stroke-dashoffset="283 - (283 * progress / 100)"
                    class="transition-all duration-1000"
                />
            </svg>

            <!-- Timer Text -->
            <div class="absolute inset-0 flex flex-col items-center justify-center">
                <span 
                    class="text-3xl font-bold font-mono"
                    :class="timerColor.text"
                >
                    {{ formattedTime }}
                </span>
                <span class="text-xs text-gray-400 mt-1">เหลือ</span>
            </div>

            <!-- Pulse Ring -->
            <div 
                v-if="isRunning"
                class="absolute inset-0 rounded-full ring-4 animate-ping opacity-30"
                :class="timerColor.ring"
            />
        </div>

        <!-- Progress Bar -->
        <div class="w-full max-w-xs mt-4">
            <div class="h-2 bg-gray-800 rounded-full overflow-hidden">
                <div 
                    class="h-full transition-all duration-1000 bg-gradient-to-r"
                    :class="timerColor.bg"
                    :style="{ width: `${progress}%` }"
                />
            </div>
            <div class="flex justify-between text-xs text-gray-500 mt-1">
                <span>0s</span>
                <span>{{ duration }}s</span>
            </div>
        </div>

        <!-- Status -->
        <div 
            v-if="isRunning"
            class="mt-3 flex items-center gap-2 text-sm"
            :class="timerColor.text"
        >
            <span class="animate-pulse">🔥</span>
            <span>กำลังต้ม...</span>
        </div>
    </div>
</template>

<style scoped>
.brewing-timer {
    animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
    from { opacity: 0; transform: scale(0.9); }
    to { opacity: 1; transform: scale(1); }
}
</style>
