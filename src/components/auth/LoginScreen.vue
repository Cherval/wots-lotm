<script setup lang="ts">
/**
 * LoginScreen.vue
 * User authentication login form
 */
import { ref } from 'vue'
import { supabase } from '@/lib/supabase'
import { authStore, saveAuthToStorage } from '@/stores/auth'

const emit = defineEmits<{
    success: []
    error: [message: string]
}>()

const email = ref('')
const password = ref('')
const loading = ref(false)
const oauthLoading = ref<'google' | 'discord' | null>(null)

async function handleLogin() {
    if (loading.value) return

    loading.value = true
    console.log('[LoginScreen] Attempting login...')
    
    const { data, error } = await supabase.auth.signInWithPassword({
        email: email.value,
        password: password.value
    })

    console.log('[LoginScreen] Login result - error:', error, 'session:', !!data?.session)

    if (error) {
        emit('error', error.message)
    } else if (data.session) {
        // Store session data to be used by parent before updating authStore
        // This prevents the component from unmounting before the event is processed
        const session = data.session
        
        console.log('[LoginScreen] Emitting success event first...')
        
        // Update authStore AFTER emitting - use a microtask to ensure event is processed
        // But we need to set authStore for fetchData to work, so we pass session via custom approach
        
        // Set authStore immediately so fetchData can use it
        console.log('[LoginScreen] Setting authStore session and user...')
        authStore.session = session
        authStore.user = session.user
        saveAuthToStorage(session)
        console.log('[LoginScreen] authStore.user set to:', authStore.user?.id)
        
        // Emit success - parent will handle fetching data
        // Use queueMicrotask to ensure this runs before Vue re-renders
        emit('success')
    }
    
    loading.value = false
}

async function handleOAuthLogin(provider: 'google' | 'discord') {
    if (oauthLoading.value) return
    
    oauthLoading.value = provider
    console.log(`[LoginScreen] Attempting ${provider} OAuth login...`)
    
    const { error } = await supabase.auth.signInWithOAuth({
        provider,
        options: {
            redirectTo: window.location.origin
        }
    })
    
    if (error) {
        emit('error', error.message)
        oauthLoading.value = null
    }
    // Note: OAuth will redirect, so we don't need to handle success here
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

            <!-- Divider -->
            <div class="flex items-center my-6">
                <div class="flex-1 h-px bg-vic-gold/30"></div>
                <span class="px-4 text-vic-gold/60 text-sm">หรือ</span>
                <div class="flex-1 h-px bg-vic-gold/30"></div>
            </div>

            <!-- OAuth Buttons -->
            <div class="space-y-3">
                <!-- Google Login -->
                <button 
                    @click="handleOAuthLogin('google')"
                    :disabled="!!oauthLoading"
                    class="w-full py-3 px-4 rounded border-2 border-gray-600 bg-white text-gray-800 font-bold flex items-center justify-center gap-3 hover:bg-gray-100 transition disabled:opacity-50 disabled:cursor-not-allowed"
                >
                    <span v-if="oauthLoading === 'google'" class="flex items-center gap-2">
                        <svg class="animate-spin h-5 w-5" fill="none" viewBox="0 0 24 24">
                            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                        </svg>
                        กำลังเชื่อมต่อ...
                    </span>
                    <template v-else>
                        <svg class="w-5 h-5" viewBox="0 0 24 24">
                            <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                            <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                            <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                            <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                        </svg>
                        เข้าสู่ระบบด้วย Google
                    </template>
                </button>

                <!-- Discord Login -->
                <button 
                    @click="handleOAuthLogin('discord')"
                    :disabled="!!oauthLoading"
                    class="w-full py-3 px-4 rounded border-2 border-[#5865F2] bg-[#5865F2] text-white font-bold flex items-center justify-center gap-3 hover:bg-[#4752C4] transition disabled:opacity-50 disabled:cursor-not-allowed"
                >
                    <span v-if="oauthLoading === 'discord'" class="flex items-center gap-2">
                        <svg class="animate-spin h-5 w-5" fill="none" viewBox="0 0 24 24">
                            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                        </svg>
                        กำลังเชื่อมต่อ...
                    </span>
                    <template v-else>
                        <svg class="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0 12.64 12.64 0 0 0-.617-1.25.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 0 0 .031.057 19.9 19.9 0 0 0 5.993 3.03.078.078 0 0 0 .084-.028 14.09 14.09 0 0 0 1.226-1.994.076.076 0 0 0-.041-.106 13.107 13.107 0 0 1-1.872-.892.077.077 0 0 1-.008-.128 10.2 10.2 0 0 0 .372-.292.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.062 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127 12.299 12.299 0 0 1-1.873.892.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028 19.839 19.839 0 0 0 6.002-3.03.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.03zM8.02 15.33c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.956-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.956 2.418-2.157 2.418zm7.975 0c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.955-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.946 2.418-2.157 2.418z"/>
                        </svg>
                        เข้าสู่ระบบด้วย Discord
                    </template>
                </button>
            </div>

            <!-- Privacy Notice -->
            <div class="mt-6 p-3 bg-gray-800/50 rounded border border-gray-700/50">
                <p class="text-xs text-gray-400 leading-relaxed">
                    🔒 <span class="text-gray-300">นโยบายความเป็นส่วนตัว:</span><br>
                    WotS ไม่ได้รับข้อมูลส่วนตัวของท่านโดยตรง เราได้รับเพียงอีเมลและข้อมูลยืนยันตัวตนที่ถูกเข้ารหัสจากแพลตฟอร์มเท่านั้น
                </p>
            </div>
        </div>
    </div>
</template>
