<script setup lang="ts">
/**
 * LoginScreen.vue
 * User authentication login form
 */
import { ref } from 'vue'
import { supabase } from '@/lib/supabase'

const emit = defineEmits<{
    success: []
    error: [message: string]
}>()

const email = ref('')
const password = ref('')
const loading = ref(false)

async function handleLogin() {
    if (loading.value) return

    loading.value = true
    
    const { error } = await supabase.auth.signInWithPassword({
        email: email.value,
        password: password.value
    })

    if (error) {
        emit('error', error.message)
    } else {
        emit('success')
    }
    
    loading.value = false
}
</script>

<template>
    <div class="flex items-center justify-center min-h-screen bg-[url('https://www.transparenttextures.com/patterns/black-scales.png')]">
        <div class="bg-vic-darkbrown p-8 rounded border-2 border-vic-gold shadow-2xl w-96 text-center relative overflow-hidden">
            <!-- Top Gold Line -->
            <div class="absolute top-0 left-0 w-full h-1 bg-vic-gold"></div>
            
            <!-- Title -->
            <h1 class="text-3xl text-vic-gold mb-6 font-bold uppercase tracking-widest font-serif">
                เข้าสู่ระบบ
            </h1>
            
            <!-- Login Form -->
            <form @submit.prevent="handleLogin">
                <input 
                    v-model="email" 
                    type="email" 
                    placeholder="อีเมล" 
                    class="input-vic mb-4" 
                    required 
                />
                <input 
                    v-model="password" 
                    type="password" 
                    placeholder="รหัสผ่าน" 
                    class="input-vic mb-6" 
                    required 
                />
                <button 
                    type="submit" 
                    :disabled="loading" 
                    class="btn-gold w-full font-bold text-lg"
                >
                    <span v-if="loading" class="flex items-center justify-center gap-2">
                        <svg class="animate-spin h-5 w-5" fill="none" viewBox="0 0 24 24">
                            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                        </svg>
                        กำลังเข้าสู่ระบบ...
                    </span>
                    <span v-else>เปิดประตูมิติ</span>
                </button>
            </form>
        </div>
    </div>
</template>
