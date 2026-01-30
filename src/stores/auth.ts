/**
 * Global Auth Store for Astro Multi-Page
 * Persists auth state across page navigation
 */
import { ref, reactive } from 'vue'
import { supabase } from '../lib/supabase'

// Global reactive auth state
export const authStore = reactive({
  session: null as any,
  user: null as any,
  isLoading: false,
  isInitialized: false
})

// Persist auth state in localStorage
const AUTH_STORAGE_KEY = 'wots_auth_session'

export function saveAuthToStorage(session: any) {
  if (typeof window !== 'undefined') {
    if (session) {
      localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(session))
    } else {
      localStorage.removeItem(AUTH_STORAGE_KEY)
    }
  }
}

export function loadAuthFromStorage() {
  if (typeof window !== 'undefined') {
    const stored = localStorage.getItem(AUTH_STORAGE_KEY)
    return stored ? JSON.parse(stored) : null
  }
  return null
}

export async function initializeAuth() {
  if (authStore.isInitialized) return authStore

  authStore.isLoading = true

  try {
    // Try to get session from Supabase
    const { data: { session }, error } = await supabase.auth.getSession()
    
    // If there's an error (like invalid refresh token), clear stored session
    if (error) {
      console.warn('Auth session error, clearing stored session:', error.message)
      localStorage.removeItem(AUTH_STORAGE_KEY)
      authStore.session = null
      authStore.user = null
    } else if (session) {
      authStore.session = session
      authStore.user = session.user
      saveAuthToStorage(session)
    } else {
      // No session from Supabase, clear any stale localStorage data
      localStorage.removeItem(AUTH_STORAGE_KEY)
      authStore.session = null
      authStore.user = null
    }

    // Listen for auth changes
    supabase.auth.onAuthStateChange((event, session) => {
      // Handle sign out or token errors
      if (event === 'SIGNED_OUT' || event === 'TOKEN_REFRESHED' && !session) {
        authStore.session = null
        authStore.user = null
        localStorage.removeItem(AUTH_STORAGE_KEY)
        return
      }
      
      authStore.session = session
      authStore.user = session?.user || null
      saveAuthToStorage(session)
    })

  } catch (error) {
    console.error('Auth initialization error:', error)
  } finally {
    authStore.isLoading = false
    authStore.isInitialized = true
  }

  return authStore
}

export async function signOut() {
  await supabase.auth.signOut()
  authStore.session = null
  authStore.user = null
  saveAuthToStorage(null)
}