<script setup lang="ts">
/**
 * BaseModal.vue
 * Reusable modal wrapper component
 */
defineProps<{
    show: boolean
    title?: string
    size?: 'sm' | 'md' | 'lg' | 'xl'
    borderColor?: string
}>()

const emit = defineEmits<{
    close: []
}>()

const sizeClasses = {
    sm: 'max-w-sm',
    md: 'max-w-md',
    lg: 'max-w-lg',
    xl: 'max-w-2xl'
}
</script>

<template>
    <Transition name="modal">
        <div 
            v-if="show" 
            class="fixed inset-0 bg-black/90 z-[100] flex items-center justify-center p-4 backdrop-blur-sm"
            @click.self="emit('close')"
        >
                <div 
                    class="bg-vic-darkbrown w-full rounded border-2 shadow-2xl animate-fade-in relative"
                    :class="[sizeClasses[size || 'md'], borderColor || 'border-vic-gold']"
                >
                    <!-- Close Button -->
                    <button 
                        @click="emit('close')" 
                        class="absolute top-2 right-4 text-gray-400 hover:text-white text-xl z-10"
                    >
                        ✕
                    </button>

                    <!-- Header -->
                    <div v-if="title" class="p-4 border-b border-vic-brown/50">
                        <h3 class="text-xl text-vic-gold font-bold font-serif">{{ title }}</h3>
                    </div>

                    <!-- Content -->
                    <div class="p-6">
                        <slot />
                    </div>

                    <!-- Footer -->
                    <div v-if="$slots.footer" class="p-4 border-t border-vic-brown/50 bg-black/20">
                        <slot name="footer" />
                    </div>
                </div>
            </div>
        </Transition>
</template>

<style scoped>
.modal-enter-active,
.modal-leave-active {
    transition: opacity 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
    opacity: 0;
}

.modal-enter-active .bg-vic-darkbrown {
    animation: fadeIn 0.3s ease-out;
}
</style>
