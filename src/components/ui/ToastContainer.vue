<script setup lang="ts">
/**
 * ToastContainer.vue
 * Toast notification display component
 */
import type { Toast } from '@/lib/constants'

defineProps<{
    toasts: Toast[]
}>()
</script>

<template>
    <div class="fixed bottom-10 left-1/2 transform -translate-x-1/2 z-[200] flex flex-col gap-3 pointer-events-none items-center w-full px-4">
        <TransitionGroup name="toast">
            <div 
                v-for="toast in toasts"
                :key="toast.id"
                class="pointer-events-auto min-w-[300px] md:min-w-[450px] p-5 rounded-lg shadow-[0_10px_40px_rgba(0,0,0,0.8)] border-l-8 flex items-center gap-5 animate-slide-up bg-vic-darkbrown text-white border-y border-r border-y-vic-gold/30 backdrop-blur-md"
                :class="toast.type === 'error' ? 'border-l-red-600' : 'border-l-green-600'"
            >
                <div class="text-3xl">{{ toast.type === 'error' ? '❌' : '✅' }}</div>
                <div>
                    <h4 class="font-bold text-lg text-vic-gold font-serif">{{ toast.title }}</h4>
                    <p class="text-sm text-gray-200">{{ toast.msg }}</p>
                </div>
            </div>
        </TransitionGroup>
    </div>
</template>

<style scoped>
.toast-enter-active {
    animation: slideUp 0.4s cubic-bezier(0.16, 1, 0.3, 1);
}

.toast-leave-active {
    animation: slideUp 0.3s ease-in reverse;
}
</style>
