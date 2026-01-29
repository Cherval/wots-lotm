<script setup lang="ts">
/**
 * LoadingOverlay.vue
 * Full-screen loading indicator
 */
defineProps<{
    show: boolean
    message?: string
}>()
</script>

<template>
    <Transition name="fade">
        <div 
            v-if="show" 
            class="fixed inset-0 bg-black/90 z-[90] flex items-center justify-center flex-col backdrop-blur-sm"
        >
            <div class="animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-vic-gold mb-4"></div>
            <p class="text-vic-gold animate-pulse text-lg tracking-widest font-serif">
                {{ message || 'กำลังโหลดข้อมูล...' }}
            </p>
        </div>
    </Transition>
</template>

<style scoped>
.fade-enter-active,
.fade-leave-active {
    transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
    opacity: 0;
}
</style>
