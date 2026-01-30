<script setup lang="ts">
/**
 * BrewingPot.vue
 * Animated cauldron with fire effects and drop zone
 */
import { computed } from 'vue'
import type { Item } from '@/lib/constants'

const props = defineProps<{
    isBrewing: boolean
    fireLevel: number
    contents: { item: Item, amount: number, unit: string }[]
    isTimerRunning: boolean
    isDragOver: boolean
}>()

const emit = defineEmits<{
    dragover: [e: DragEvent]
    dragleave: []
    drop: [e: DragEvent]
}>()

// Fire colors based on level
const fireColors = computed(() => {
    switch (props.fireLevel) {
        case 1: return { from: '#fbbf24', to: '#f59e0b', glow: 'rgba(251, 191, 36, 0.4)' }
        case 2: return { from: '#f97316', to: '#ea580c', glow: 'rgba(249, 115, 22, 0.5)' }
        case 3: return { from: '#ef4444', to: '#dc2626', glow: 'rgba(239, 68, 68, 0.6)' }
        default: return { from: '#374151', to: '#1f2937', glow: 'transparent' }
    }
})

// Bubble animation speed based on fire level
const bubbleSpeed = computed(() => {
    switch (props.fireLevel) {
        case 1: return '3s'
        case 2: return '2s'
        case 3: return '1s'
        default: return '0s'
    }
})

// Liquid color based on contents
const liquidColor = computed(() => {
    if (props.contents.length === 0) return 'rgba(59, 130, 246, 0.6)'
    
    // Mix colors based on ingredients
    const colors = [
        'rgba(139, 92, 246, 0.7)',  // purple
        'rgba(34, 197, 94, 0.7)',   // green
        'rgba(234, 88, 12, 0.7)',   // orange
        'rgba(239, 68, 68, 0.7)',   // red
    ]
    return colors[props.contents.length % colors.length]
})
</script>

<template>
    <div 
        class="brewing-pot-container relative flex flex-col items-center justify-center py-8"
        @dragover.prevent="emit('dragover', $event)"
        @dragleave="emit('dragleave')"
        @drop="emit('drop', $event)"
    >
        <!-- Drop Zone Indicator -->
        <div 
            v-if="isDragOver"
            class="absolute inset-0 border-4 border-dashed border-green-400 rounded-xl bg-green-900/20 z-10 flex items-center justify-center"
        >
            <div class="text-2xl text-green-300 font-bold animate-pulse">
                🎯 วางที่นี่!
            </div>
        </div>

        <!-- Pot SVG Container -->
        <div class="relative w-80 h-80">
            <!-- Glow Effect -->
            <div 
                class="absolute inset-0 rounded-full blur-3xl transition-all duration-500"
                :style="{ 
                    background: `radial-gradient(circle, ${fireColors.glow} 0%, transparent 70%)`,
                    opacity: fireLevel > 0 ? 1 : 0
                }"
            />

            <!-- Fire Animation -->
            <div 
                v-if="fireLevel > 0"
                class="absolute bottom-4 left-1/2 -translate-x-1/2 w-48 h-24"
            >
                <div class="fire-container">
                    <div 
                        v-for="i in 8"
                        :key="i"
                        class="flame"
                        :style="{
                            '--delay': `${i * 0.1}s`,
                            '--color-from': fireColors.from,
                            '--color-to': fireColors.to,
                            left: `${10 + i * 10}%`
                        }"
                    />
                </div>
            </div>

            <!-- Cauldron SVG -->
            <svg viewBox="0 0 200 200" class="w-full h-full relative z-10">
                <!-- Pot Base Shadow -->
                <ellipse cx="100" cy="180" rx="60" ry="10" fill="rgba(0,0,0,0.3)" />
                
                <!-- Pot Legs -->
                <rect x="50" y="155" width="8" height="30" rx="4" fill="#3e2723" />
                <rect x="142" y="155" width="8" height="30" rx="4" fill="#3e2723" />
                <rect x="96" y="165" width="8" height="25" rx="4" fill="#3e2723" />

                <!-- Pot Body -->
                <path 
                    d="M40 80 Q40 160 100 160 Q160 160 160 80 L160 70 Q160 60 150 60 L50 60 Q40 60 40 70 Z"
                    fill="url(#potGradient)"
                    stroke="#5d4037"
                    stroke-width="3"
                />

                <!-- Pot Rim -->
                <ellipse cx="100" cy="60" rx="55" ry="12" fill="#4a3728" stroke="#3e2723" stroke-width="2" />
                <ellipse cx="100" cy="58" rx="50" ry="10" fill="#5d4037" />

                <!-- Liquid Inside -->
                <ellipse 
                    v-if="isBrewing || contents.length > 0"
                    cx="100" 
                    cy="62" 
                    rx="45" 
                    ry="8"
                    :fill="liquidColor"
                    class="transition-all duration-500"
                />

                <!-- Bubbles -->
                <g v-if="fireLevel > 0 && (isBrewing || isTimerRunning)">
                    <circle 
                        v-for="i in 6" 
                        :key="'bubble-'+i"
                        class="bubble"
                        :cx="70 + i * 10"
                        cy="58"
                        r="3"
                        fill="rgba(255,255,255,0.6)"
                        :style="{ 
                            animationDuration: bubbleSpeed,
                            animationDelay: `${i * 0.2}s`
                        }"
                    />
                </g>

                <!-- Steam -->
                <g v-if="fireLevel > 0 && (isBrewing || isTimerRunning)" class="steam-container">
                    <path 
                        v-for="i in 3"
                        :key="'steam-'+i"
                        class="steam"
                        :d="`M${85 + i * 15} 50 Q${80 + i * 15} 35 ${90 + i * 15} 20`"
                        fill="none"
                        stroke="rgba(255,255,255,0.3)"
                        stroke-width="4"
                        stroke-linecap="round"
                        :style="{ animationDelay: `${i * 0.3}s` }"
                    />
                </g>

                <!-- Handles -->
                <path d="M38 75 Q25 75 25 90 Q25 105 38 105" fill="none" stroke="#3e2723" stroke-width="6" stroke-linecap="round" />
                <path d="M162 75 Q175 75 175 90 Q175 105 162 105" fill="none" stroke="#3e2723" stroke-width="6" stroke-linecap="round" />

                <!-- Gradients -->
                <defs>
                    <linearGradient id="potGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                        <stop offset="0%" style="stop-color:#5d4037" />
                        <stop offset="50%" style="stop-color:#4a3728" />
                        <stop offset="100%" style="stop-color:#3e2723" />
                    </linearGradient>
                </defs>
            </svg>

            <!-- Timer Running Indicator -->
            <div 
                v-if="isTimerRunning"
                class="absolute top-0 left-1/2 -translate-x-1/2 bg-purple-900 border border-purple-400 px-3 py-1 rounded-full text-purple-200 text-sm font-bold animate-pulse"
            >
                ⏳ กำลังต้ม...
            </div>
        </div>

        <!-- Contents List -->
        <div 
            v-if="contents.length > 0"
            class="mt-4 bg-black/40 rounded-lg p-3 max-w-xs"
        >
            <div class="text-xs text-gray-400 mb-2">🧪 ส่วนผสมในหม้อ:</div>
            <div class="flex flex-wrap gap-1">
                <span 
                    v-for="(content, i) in contents"
                    :key="i"
                    class="text-xs px-2 py-1 bg-purple-900/50 rounded text-purple-200"
                >
                    {{ content.item.name }} {{ content.amount }}{{ content.unit === 'ml' ? 'มล.' : content.unit === 'g' ? 'ก.' : '' }}
                </span>
            </div>
        </div>

        <!-- Not Brewing State -->
        <div 
            v-if="!isBrewing"
            class="absolute inset-0 flex items-center justify-center bg-black/40 rounded-xl"
        >
            <div class="text-center text-gray-400">
                <div class="text-4xl mb-2">🧪</div>
                <div>เลือกสูตรและกดเริ่มปรุง</div>
            </div>
        </div>
    </div>
</template>

<style scoped>
.brewing-pot-container {
    background: linear-gradient(180deg, rgba(30, 20, 15, 0.8) 0%, rgba(20, 15, 10, 0.9) 100%);
    border: 2px solid #5d4037;
    border-radius: 1rem;
    min-height: 400px;
}

/* Fire Animation */
.fire-container {
    position: relative;
    width: 100%;
    height: 100%;
}

.flame {
    position: absolute;
    bottom: 0;
    width: 20px;
    height: 60px;
    background: linear-gradient(to top, var(--color-from), var(--color-to), transparent);
    border-radius: 50% 50% 50% 50% / 60% 60% 40% 40%;
    animation: flicker 0.5s ease-in-out infinite alternate;
    animation-delay: var(--delay);
    transform-origin: bottom center;
}

@keyframes flicker {
    0% {
        transform: scaleY(1) scaleX(1) rotate(-2deg);
        opacity: 1;
    }
    100% {
        transform: scaleY(1.2) scaleX(0.9) rotate(2deg);
        opacity: 0.8;
    }
}

/* Bubble Animation */
.bubble {
    animation: rise ease-in-out infinite;
    transform-origin: center;
}

@keyframes rise {
    0% {
        transform: translateY(0) scale(0.5);
        opacity: 0;
    }
    50% {
        opacity: 0.8;
    }
    100% {
        transform: translateY(-15px) scale(1);
        opacity: 0;
    }
}

/* Steam Animation */
.steam {
    animation: steam-rise 2s ease-out infinite;
    opacity: 0;
}

@keyframes steam-rise {
    0% {
        opacity: 0;
        transform: translateY(0) scaleY(0.5);
    }
    50% {
        opacity: 0.5;
    }
    100% {
        opacity: 0;
        transform: translateY(-30px) scaleY(1.5);
    }
}
</style>
