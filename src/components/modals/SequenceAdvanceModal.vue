<template>
  <!-- Sequence Advance Celebration Modal -->
  <Transition name="sequence-advance">
    <div 
      v-if="show" 
      class="fixed inset-0 z-[9999] flex items-center justify-center"
      @click="handleClose"
    >
      <!-- Dark Overlay -->
      <div class="absolute inset-0 bg-black/90 backdrop-blur-sm"></div>
      
      <!-- Particles Container -->
      <div class="absolute inset-0 overflow-hidden pointer-events-none">
        <!-- Magic Particles -->
        <div 
          v-for="i in 50" 
          :key="'particle-' + i"
          class="particle"
          :style="getParticleStyle(i)"
        ></div>
        
        <!-- Sparkles -->
        <div 
          v-for="i in 30" 
          :key="'sparkle-' + i"
          class="sparkle"
          :style="getSparkleStyle(i)"
        >✦</div>
        
        <!-- Rising Stars -->
        <div 
          v-for="i in 20" 
          :key="'star-' + i"
          class="rising-star"
          :style="getRisingStarStyle(i)"
        >★</div>
      </div>

      <!-- Main Content -->
      <div class="relative z-10 text-center px-8 animate-scale-in" @click.stop>
        <!-- Sequence Number -->
        <div class="sequence-number-container mb-4">
          <span class="sequence-number">{{ newSequence }}</span>
        </div>
        
        <!-- Main Text -->
        <div class="main-text-container">
          <p class="advance-label">เลื่อนลำดับสู่</p>
          <h1 class="sequence-title">
            ลำดับที่ {{ newSequence }}
          </h1>
          <h2 class="sequence-name">{{ sequenceName }}</h2>
          <p class="pathway-name">{{ pathwayName }}</p>
        </div>

        <!-- Continue Button -->
        <button 
          @click.stop="handleClose"
          class="mt-8 px-8 py-3 bg-gradient-to-r from-yellow-600 via-yellow-500 to-yellow-600 
                 text-black font-bold rounded-lg shadow-lg shadow-yellow-500/50
                 hover:from-yellow-500 hover:via-yellow-400 hover:to-yellow-500 
                 transition-all duration-300 transform hover:scale-105
                 border border-yellow-400/50"
        >
          ✨ ดำเนินการต่อ ✨
        </button>
      </div>
    </div>
  </Transition>
</template>

<script setup lang="ts">
import { ref, watch, onUnmounted } from 'vue'

interface Props {
  show: boolean
  newSequence: number
  sequenceName: string
  pathwayName: string
}

const props = defineProps<Props>()
const emit = defineEmits<{
  close: []
}>()

// Generate random particle styles
function getParticleStyle(index: number) {
  const delay = Math.random() * 2
  const duration = 2 + Math.random() * 3
  const left = Math.random() * 100
  const size = 3 + Math.random() * 8
  
  return {
    left: `${left}%`,
    animationDelay: `${delay}s`,
    animationDuration: `${duration}s`,
    width: `${size}px`,
    height: `${size}px`
  }
}

function getSparkleStyle(index: number) {
  const delay = Math.random() * 3
  const duration = 1 + Math.random() * 2
  const left = Math.random() * 100
  const top = Math.random() * 100
  const size = 12 + Math.random() * 24
  
  return {
    left: `${left}%`,
    top: `${top}%`,
    animationDelay: `${delay}s`,
    animationDuration: `${duration}s`,
    fontSize: `${size}px`
  }
}

function getRisingStarStyle(index: number) {
  const delay = Math.random() * 2
  const duration = 3 + Math.random() * 2
  const left = Math.random() * 100
  const size = 16 + Math.random() * 20
  
  return {
    left: `${left}%`,
    animationDelay: `${delay}s`,
    animationDuration: `${duration}s`,
    fontSize: `${size}px`
  }
}

function handleClose() {
  emit('close')
}

// Auto-close after some time (optional)
let autoCloseTimer: ReturnType<typeof setTimeout> | null = null
let isMounted = true

watch(() => props.show, (newVal, oldVal) => {
  if (newVal && !oldVal) {
    // Clear any existing timer
    if (autoCloseTimer) {
      clearTimeout(autoCloseTimer)
      autoCloseTimer = null
    }
    // Auto close after 10 seconds (only if still mounted)
    autoCloseTimer = setTimeout(() => {
      if (isMounted) {
        emit('close')
      }
    }, 10000)
  } else if (!newVal && oldVal) {
    // Clear timer when closing
    if (autoCloseTimer) {
      clearTimeout(autoCloseTimer)
      autoCloseTimer = null
    }
  }
})

onUnmounted(() => {
  isMounted = false
  if (autoCloseTimer) {
    clearTimeout(autoCloseTimer)
    autoCloseTimer = null
  }
})
</script>

<style scoped>
/* Transition */
.sequence-advance-enter-active {
  transition: all 0.5s ease-out;
}
.sequence-advance-leave-active {
  transition: all 0.3s ease-in;
}
.sequence-advance-enter-from {
  opacity: 0;
}
.sequence-advance-leave-to {
  opacity: 0;
}

/* Scale In Animation */
@keyframes scaleIn {
  0% {
    transform: scale(0.5);
    opacity: 0;
  }
  50% {
    transform: scale(1.1);
  }
  100% {
    transform: scale(1);
    opacity: 1;
  }
}

.animate-scale-in {
  animation: scaleIn 0.6s ease-out forwards;
}

/* Sequence Number */
.sequence-number-container {
  position: relative;
}

.sequence-number {
  font-size: 120px;
  font-weight: 900;
  font-family: 'Sarabun', sans-serif;
  background: linear-gradient(180deg, #fff9c4 0%, #ffd700 30%, #ffb347 60%, #ff8c00 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  filter: drop-shadow(0 0 20px rgba(255, 215, 0, 0.6));
  animation: numberPulse 1.5s ease-in-out infinite;
}

@keyframes numberPulse {
  0%, 100% {
    transform: scale(1);
    filter: drop-shadow(0 0 20px rgba(255, 215, 0, 0.6));
  }
  50% {
    transform: scale(1.05);
    filter: drop-shadow(0 0 40px rgba(255, 215, 0, 0.9));
  }
}

/* Main Text */
.main-text-container {
  position: relative;
}

.advance-label {
  font-size: 18px;
  color: #ffd700;
  letter-spacing: 8px;
  text-transform: uppercase;
  margin-bottom: 8px;
  text-shadow: 0 0 10px rgba(255, 215, 0, 0.6);
  animation: textGlow 2s ease-in-out infinite;
}

.sequence-title {
  font-size: 32px;
  font-weight: bold;
  font-family: 'Sarabun', sans-serif;
  background: linear-gradient(180deg, #ffffff 0%, #ffd700 50%, #ffb347 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin-bottom: 8px;
}

.sequence-name {
  font-size: 42px;
  font-weight: 900;
  font-family: 'Sarabun', sans-serif;
  background: linear-gradient(180deg, #fff9c4 0%, #ffd700 40%, #daa520 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin-bottom: 8px;
  animation: nameShine 3s ease-in-out infinite;
}

@keyframes nameShine {
  0%, 100% {
    filter: brightness(1) drop-shadow(0 0 15px rgba(255, 215, 0, 0.6));
  }
  50% {
    filter: brightness(1.3) drop-shadow(0 0 30px rgba(255, 215, 0, 0.9));
  }
}

.pathway-name {
  font-size: 20px;
  color: #b8860b;
  letter-spacing: 4px;
  text-shadow: 0 0 10px rgba(255, 215, 0, 0.4);
}

@keyframes textGlow {
  0%, 100% {
    text-shadow: 0 0 10px rgba(255, 215, 0, 0.6);
  }
  50% {
    text-shadow: 0 0 20px rgba(255, 215, 0, 0.9), 0 0 40px rgba(255, 215, 0, 0.4);
  }
}

/* Particles */
.particle {
  position: absolute;
  bottom: -20px;
  background: radial-gradient(circle, #ffd700 0%, #ff8c00 50%, transparent 70%);
  border-radius: 50%;
  animation: particleRise 4s ease-out infinite;
  opacity: 0;
}

@keyframes particleRise {
  0% {
    transform: translateY(0) scale(1);
    opacity: 0;
  }
  10% {
    opacity: 1;
  }
  90% {
    opacity: 0.8;
  }
  100% {
    transform: translateY(-100vh) scale(0.3);
    opacity: 0;
  }
}

/* Sparkles */
.sparkle {
  position: absolute;
  color: #ffd700;
  animation: sparkle 2s ease-in-out infinite;
  opacity: 0;
  text-shadow: 0 0 10px #ffd700;
}

@keyframes sparkle {
  0%, 100% {
    transform: scale(0) rotate(0deg);
    opacity: 0;
  }
  50% {
    transform: scale(1) rotate(180deg);
    opacity: 1;
  }
}

/* Rising Stars */
.rising-star {
  position: absolute;
  bottom: -30px;
  color: #ffd700;
  animation: starRise 4s ease-out infinite;
  opacity: 0;
  text-shadow: 0 0 15px #ffd700, 0 0 30px #ff8c00;
}

@keyframes starRise {
  0% {
    transform: translateY(0) rotate(0deg) scale(0.5);
    opacity: 0;
  }
  20% {
    opacity: 1;
  }
  80% {
    opacity: 0.6;
  }
  100% {
    transform: translateY(-100vh) rotate(720deg) scale(1.2);
    opacity: 0;
  }
}
</style>
