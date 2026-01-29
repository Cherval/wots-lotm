import { createClient } from '@supabase/supabase-js'
import { SUPABASE_URL, SUPABASE_KEY } from './constants'

/**
 * Supabase Client Instance
 * Shared across all components
 */
export const supabase = createClient(SUPABASE_URL, SUPABASE_KEY)

/**
 * Calculate stat modifier from score
 */
export function calculateModifier(score: number): number {
    return Math.floor((score - 10) / 2)
}

/**
 * Get role label in Thai
 */
export function getRoleLabel(role: string): string {
    const roleMap: Record<string, string> = {
        'dungeon_master': 'ผู้คุมกฎ (DM)',
        'assistant': 'ผู้ช่วย (Assistant)'
    }
    return roleMap[role] || 'ผู้เล่น (Player)'
}

/**
 * Format date for display
 */
export function formatDate(dateStr: string): string {
    const d = new Date(dateStr)
    return d.toLocaleString('th-TH', {
        day: '2-digit',
        month: 'short',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    })
}

/**
 * Format currency
 */
export function formatCurrency(amount: number): string {
    return `฿${amount.toLocaleString()}`
}
