<template>
  <div>
    <!-- Loading State -->
    <div v-if="authStore.isLoading" class="min-h-screen bg-neutral-900 flex items-center justify-center">
      <div class="text-center">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-vic-gold mx-auto mb-4"></div>
        <p class="text-vic-cream">Loading authentication...</p>
      </div>
    </div>

    <!-- Not Authenticated -->
    <div v-else-if="!authStore.session" class="min-h-screen bg-neutral-900 flex items-center justify-center">
      <div class="text-center p-8">
        <h1 class="text-3xl font-bold text-vic-gold mb-4">Access Denied</h1>
        <p class="text-vic-cream mb-6">Please login to access this page</p>
        <button 
          @click="redirectToHome"
          class="bg-vic-gold text-black px-6 py-3 rounded font-semibold hover:bg-vic-cream transition"
        >
          Go to Login
        </button>
      </div>
    </div>

    <!-- Authenticated - Show Protected Content -->
    <App v-else />
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { authStore, initializeAuth } from '../stores/auth'
import App from './App.vue'

onMounted(async () => {
  await initializeAuth()
})

function redirectToHome() {
  window.location.href = '/'
}
</script>