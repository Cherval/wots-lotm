/**
 * Application Constants & Configuration
 * Centralized configuration for the WOTS application
 */

// Supabase Configuration - Read from environment variables
// For Vercel: Add these in Project Settings > Environment Variables
// For local dev: Create .env file (see .env.example)
export const SUPABASE_URL = import.meta.env.PUBLIC_SUPABASE_URL || ''
export const SUPABASE_KEY = import.meta.env.PUBLIC_SUPABASE_KEY || ''

// Default Images - Using placehold.co (reliable placeholder service)
export const DEFAULT_IMG = 'https://placehold.co/300x300/2a2a2a/d4a574?text=No+Image'
export const HEADER_IMG = 'https://placehold.co/1200x400/1a1a1a/d4a574?text=Victorian+Era+Campaign'

// Rank Groups for Pathway Sequences
export const RANK_GROUPS = [
    'Low (9-8)',
    'Mid (7-5)',
    'High (4)',
    'Saint (3)',
    'Angel (2-1)',
    'Deity (0)'
]

// Character Stats Configuration
export const STATS_CONFIG = [
    { label: 'STR', key: 'str', mod: 'str_mod' },
    { label: 'AGI', key: 'agi', mod: 'agi_mod' },
    { label: 'INT', key: 'int_stat', mod: 'int_mod' },
    { label: 'DEX', key: 'dex', mod: 'dex_mod' },
    { label: 'CON', key: 'con', mod: 'con_mod' },
    { label: 'WIS', key: 'wis', mod: 'wis_mod' },
    { label: 'CHA', key: 'cha', mod: 'cha_mod' }
] as const

// Skill Labels (English + Thai)
export const SKILL_LABELS: Record<string, string> = {
    athletics: 'Athletics (กรีฑา)',
    acrobatics: 'Acrobatics (กายกรรม)',
    sleight_of_hand: 'Sleight of Hand (มือไว)',
    stealth: 'Stealth (ลอบเร้น)',
    arcana: 'Arcana (เวทมนตร์)',
    history: 'History (ประวัติศาสตร์)',
    investigation: 'Investigation (สืบสวน)',
    nature: 'Nature (ธรรมชาติ)',
    religion: 'Religion (ศาสนา)',
    animal_handling: 'Animal Handling (คุมสัตว์)',
    insight: 'Insight (หยั่งรู้)',
    medicine: 'Medicine (การแพทย์)',
    perception: 'Perception (การรับรู้)',
    survival: 'Survival (เอาตัวรอด)',
    deception: 'Deception (หลอกลวง)',
    intimidation: 'Intimidation (ข่มขู่)',
    performance: 'Performance (การแสดง)',
    persuasion: 'Persuasion (ชักจูง)'
}

// Role Labels
export const ROLE_LABELS: Record<string, string> = {
    'dungeon_master': 'ผู้คุมกฎ (DM)',
    'assistant': 'ผู้ช่วย (Assistant)',
    'player': 'ผู้เล่น (Player)'
}

// Action Type Labels for Transaction Logs
export const ACTION_LABELS: Record<string, string> = {
    'money_transfer': '💸 โอนเงิน',
    'money_grant': '✨ เสกเงิน',
    'item_use': '🧪 ใช้ไอเทม',
    'item_transfer': '📦 ส่งไอเทม',
    'item_discard': '🗑️ ทิ้งไอเทม',
    'item_create': '➕ เพิ่มสินค้า',
    'item_delete': '❌ ลบสินค้า',
    'item_buy': '🛒 ซื้อไอเทม',
    'item_sell': '💰 ขายไอเทม',
    'bank_deposit': '🏦 ฝากเงิน',
    'bank_withdraw': '🏦 ถอนเงิน',
    'brewing_success': '🧪 ปรุงยาสำเร็จ',
    'brewing_failed': '💨 ปรุงยาล้มเหลว',
    'grant_recipe': '📜 มอบสูตรยา'
}

// Shop Categories
export const SHOP_CATEGORIES = [
    { key: 'wizard_guild', label: '🧙 ชุมนุมผู้วิเศษ', description: 'อาวุธ ชุด และอุปกรณ์' },
    { key: 'market', label: '🏪 ตลาด', description: 'วัตถุดิบ ของกิน ของใช้ทั่วไป' },
    { key: 'mysterious', label: '🔮 ร้านค้าลึกลับ', description: 'ของพิเศษและสิ่งลึกลับ' }
] as const

export type ShopCategory = 'wizard_guild' | 'market' | 'mysterious'

// Navigation Items
export const NAV_ITEMS = [
    { key: 'dashboard', label: 'หน้าหลัก', icon: null, adminOnly: false },
    { key: 'inventory', label: '🎒 กระเป๋า', icon: null, adminOnly: false },
    { key: 'shop', label: '🛒 ร้านค้า', icon: null, adminOnly: false },
    { key: 'brewing', label: '🧪 ปรุงยา', icon: null, adminOnly: false },
    { key: 'players', label: 'ผู้เล่น', icon: null, adminOnly: false },
    { key: 'enemies', label: 'ศัตรู', icon: null, adminOnly: false },
    { key: 'magic', label: 'เวทย์', icon: null, adminOnly: true },
    { key: 'map', label: 'แผนที่', icon: null, adminOnly: false },
    { key: 'logs', label: '📋 Log', icon: null, adminOnly: false }
]

// Types
export interface Player {
    id: string
    auth_id: string
    name: string
    character_name: string
    character_img_url: string
    pathways: string
    sequence: number
    hp: number
    atk: number
    ac: number
    money: number
    bank_balance: number
    skill_points: number
    role: 'player' | 'assistant' | 'dungeon_master'
    status: 'active' | 'vip' | 'hide' | 'die'
    str: number
    agi: number
    int_stat: number
    dex: number
    con: number
    wis: number
    cha: number
    str_mod: number
    agi_mod: number
    int_mod: number
    dex_mod: number
    con_mod: number
    wis_mod: number
    cha_mod: number
    nationality: string
    sex: string
    source_url?: string
}

export interface Enemy {
    id: string
    character_name: string
    character_img_url: string
    pathways: string
    sequence: number
    nationality?: string
    sex?: string
    hp: number
    atk: number
    ac: number
    str: number
    agi: number
    int_stat: number
    dex: number
    con: number
    wis: number
    cha: number
}

export interface Item {
    id: string
    name: string
    description: string
    type: 'consumable' | 'equipment' | 'material' | 'special' | 'recipe'
    slot_type?: 'weapon' | 'head' | 'body' | 'accessory' | null  // Equipment slot type
    shop_category?: 'wizard_guild' | 'market' | 'mysterious'  // Shop category
    recipe_id?: string  // For recipe items - links to the recipe
    image_url: string
    price_buy: number
    price_sell: number
    grid_width: number   // Width in grid cells (1-4)
    grid_height: number  // Height in grid cells (1-4)
    effects?: Record<string, any>
}

export interface InventoryItem {
    id: string
    player_id: string
    item_id: string
    quantity: number
    is_equipped: boolean
    grid_x?: number      // Position in inventory grid (0-11)
    grid_y?: number      // Position in inventory grid (0-4)
    items: Item
}

export interface Pathway {
    id: string
    name: string
    goo_group: string
}

export interface Sequence {
    id: string
    pathway_id: string
    seq_number: number
    title: string
    rank_group: string
}

export interface Toast {
    id: number
    msg: string
    type: 'success' | 'error'
    title: string
}

export interface MapData {
    id: string
    name: string
    description: string
    image_url: string
}

export interface MapPosition {
    id: string
    map_id: string
    player_id: string
    pos_x: number
    pos_y: number
    pos_x_percent: number
    pos_y_percent: number
}

export interface TransactionLog {
    id: string
    action_type: string
    actor_id: string
    actor_name: string
    target_id?: string
    target_name?: string
    item_id?: string
    item_name?: string
    amount?: number
    details?: Record<string, any>
    created_at: string
}

// ================= BREWING SYSTEM TYPES =================

export interface Recipe {
    id: string
    name: string
    description?: string
    image_url?: string
    result_item_id: string
    result_quantity: number
    difficulty: 'easy' | 'normal' | 'hard' | 'expert'
    tolerance_percent: number
    created_at?: string
    updated_at?: string
    created_by?: string
    // Joined data
    result_item?: Item
    steps?: RecipeStep[]
}

export interface RecipeStep {
    id: string
    recipe_id: string
    step_order: number
    step_type: 'set_fire' | 'add_ingredient' | 'simmer'
    fire_level?: number          // 0-3 สำหรับ set_fire
    item_id?: string             // สำหรับ add_ingredient
    amount?: number              // กรัม หรือ มล.
    unit?: 'ml' | 'g' | 'piece'  // หน่วย
    duration_seconds?: number    // วินาที สำหรับ simmer
    description?: string
    created_at?: string
    // Joined data
    item?: Item
}

export interface BrewingSession {
    id: string
    player_id: string
    recipe_id?: string
    status: 'in_progress' | 'success' | 'failed'
    started_at: string
    completed_at?: string
    player_steps: PlayerBrewingStep[]
    accuracy_score?: number
    result_message?: string
}

export interface PlayerBrewingStep {
    step_type: 'set_fire' | 'add_ingredient' | 'simmer'
    fire_level?: number
    item_id?: string
    item_name?: string
    amount?: number
    unit?: string
    duration_seconds?: number
    timestamp: number
}

// Brewing Step Types for UI
export type BrewingStepType = 'set_fire' | 'add_ingredient' | 'simmer'

// Difficulty labels in Thai
export const DIFFICULTY_LABELS: Record<string, string> = {
    'easy': '🟢 ง่าย',
    'normal': '🟡 ปานกลาง',
    'hard': '🟠 ยาก',
    'expert': '🔴 เชี่ยวชาญ'
}

// Unit labels in Thai
export const UNIT_LABELS: Record<string, string> = {
    'ml': 'มล.',
    'g': 'กรัม',
    'piece': 'ชิ้น'
}

// Fire level labels
export const FIRE_LEVEL_LABELS: Record<number, string> = {
    0: '🔵 ปิด',
    1: '🟡 ไฟอ่อน',
    2: '🟠 ไฟปานกลาง',
    3: '🔴 ไฟแรง'
}
