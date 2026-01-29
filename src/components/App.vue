<script setup lang="ts">
/**
 * App.vue
 * Main Application Component
 * Whisper of the Shadow - Victorian Era RPG Character Management System
 */
import { ref, computed, onMounted } from 'vue'
import type { Player, Enemy, Pathway, Sequence, Item, InventoryItem, Toast } from '@/lib/constants'
import { supabase, getRoleLabel, calculateModifier } from '@/lib/supabase'
import { authStore, initializeAuth } from '../stores/auth'
import { STATS_CONFIG } from '@/lib/constants'

// UI Components
import ToastContainer from './ui/ToastContainer.vue'
import LoadingOverlay from './ui/LoadingOverlay.vue'

// Layout Components
import LoginScreen from './auth/LoginScreen.vue'
import AppHeader from './layout/AppHeader.vue'
import NavBar from './layout/NavBar.vue'

// View Components
import DashboardView from './dashboard/DashboardView.vue'
import PlayersList from './characters/PlayersList.vue'
import EnemiesList from './characters/EnemiesList.vue'
import InventoryView from './economy/InventoryView.vue'
import ShopView from './economy/ShopView.vue'
import MagicView from './magic/MagicView.vue'
import MapView from './map/MapView.vue'
import MapDetailView from './map/MapDetailView.vue'
import LogsView from './logs/LogsView.vue'

// Modal Components
import BankModal from './economy/BankModal.vue'
import TransferMoneyModal from './economy/TransferMoneyModal.vue'
import TransferItemModal from './economy/TransferItemModal.vue'
import ConfirmModal from './modals/ConfirmModal.vue'
import UpgradeModal from './modals/UpgradeModal.vue'
import GrantSpModal from './modals/GrantSpModal.vue'
import GrantMoneyModal from './modals/GrantMoneyModal.vue'
import EditCharacterModal from './modals/EditCharacterModal.vue'
import CharacterDetailModal from './modals/CharacterDetailModal.vue'
import CharacterListModal from './modals/CharacterListModal.vue'
import MapConfigModal from './modals/MapConfigModal.vue'
import EmbedModal from './modals/EmbedModal.vue'
import ItemConfigModal from './modals/ItemConfigModal.vue'
import SequenceAdvanceModal from './modals/SequenceAdvanceModal.vue'
import PathwayModal from './modals/PathwayModal.vue'
import SequenceModal from './modals/SequenceModal.vue'

// =============================================================================
// STATE MANAGEMENT
// =============================================================================

// System State
// Use global auth store instead of local session
const loading = ref(false)
const currentView = ref('dashboard')
const toasts = ref<Toast[]>([])

// Core Data  
const players = ref<Player[]>([])
const _currentUserData = ref<Player | null>(null)
const currentUser = computed({
    get: () => _currentUserData.value || (authStore.user ? players.value.find(p => p.auth_id === authStore.user?.id) || null : null),
    set: (val) => { _currentUserData.value = val }
})
const enemies = ref<Enemy[]>([])
const pathwaysList = ref<Pathway[]>([])
const sequencesList = ref<Sequence[]>([])
const currentUserSkills = ref<Record<string, number>>({})

// Economy Data
const inventoryList = ref<InventoryItem[]>([])
const shopList = ref<Item[]>([])

// Magic & World Data
const mapsList = ref<any[]>([])
const transactionLogs = ref<any[]>([])
const logsLoading = ref(false)

// Map Detail State
const currentMap = ref<any>(null)
const isMapEditMode = ref(false)
const mapPositions = ref<any[]>([])
const draggingCharacter = ref<any>(null)
const dragPosition = ref({ x: 0, y: 0 })

// Modal States
const showBankModal = ref(false)
const bankMode = ref<'deposit' | 'withdraw'>('deposit')
const showTransferMoneyModal = ref(false)
const showTransferItemModal = ref(false)
const transferItemTarget = ref<InventoryItem | null>(null)
const showConfirmModal = ref(false)
const showUpgradeModal = ref(false)
const showGrantSpModal = ref(false)
const showGrantMoneyModal = ref(false)
const showCharacterDetail = ref(false)
const showEditModal = ref(false)
const showMapConfigModal = ref(false)
const editingMap = ref<any>(null)
const mapLoading = ref(false)
const showEmbedModal = ref(false)
const embedTarget = ref<Player | null>(null)
const showItemConfigModal = ref(false)
const editingItem = ref<Item | null>(null)
const itemLoading = ref(false)

// Sequence Advance Modal State
const showSequenceAdvanceModal = ref(false)
const sequenceAdvanceData = ref({
    newSequence: 0,
    sequenceName: '',
    pathwayName: ''
})

// Pathway & Sequence Modal State
const showPathwayModal = ref(false)
const editingPathway = ref<Pathway | null>(null)
const pathwayLoading = ref(false)
const showSequenceModal = ref(false)
const editingSequence = ref<Sequence | null>(null)
const editingSequencePathwayId = ref('')
const sequenceLoading = ref(false)

// Modal Data
const confirmModalData = ref({
    title: '',
    message: '',
    type: 'confirm' as 'confirm' | 'delete' | 'use',
    confirmText: 'ยืนยัน',
    onConfirm: () => {}
})
const upgradeTarget = ref<Player | null>(null)
const grantTarget = ref<Player | null>(null)
const editingCharacter = ref<any>(null)
const editType = ref<'player' | 'enemy'>('player')
const selectedCharacter = ref<any>(null)
const nearbyCharacters = ref<any[]>([])
const showCharacterList = ref(false)

// Action Loading States
const actionLoading = ref({
    upgrade: false,
    grant: false,
    grantMoney: false
})

// =============================================================================
// COMPUTED PROPERTIES
// =============================================================================

const isAdmin = computed(() => {
    return ['dungeon_master', 'assistant'].includes(currentUser.value?.role || '')
})

const isSuperAdmin = computed(() => {
    return currentUser.value?.role === 'dungeon_master'
})

const getMapCharacters = computed(() => {
    if (!currentMap.value) return []
    return mapPositions.value.filter((pos: any) => pos.map_id === currentMap.value.id)
})

// =============================================================================
// TOAST NOTIFICATIONS
// =============================================================================

function showToast(msg: string, type: 'success' | 'error' = 'success', title = 'แจ้งเตือน') {
    const id = Date.now()
    toasts.value.push({ id, msg, type, title })
    setTimeout(() => {
        toasts.value = toasts.value.filter((t: Toast) => t.id !== id)
    }, 3000)
}

// =============================================================================
// AUTHENTICATION
// =============================================================================

async function handleLogout() {
    await supabase.auth.signOut()
    authStore.session = null
    authStore.user = null
    window.location.reload()
}

function onLoginSuccess() {
    showToast('ยินดีต้อนรับสู่โลกวิคตอเรียน', 'success', 'Login Success')
}

function onLoginError(message: string) {
    showToast(message, 'error', 'Login Failed')
}

// =============================================================================
// DATA FETCHING
// =============================================================================

// Flag to track if initial data is loaded
const isInitialLoad = ref(true)

async function fetchData(showSpinner = true) {
    try {
        // Only show spinner on initial load or when explicitly requested
        if (showSpinner && isInitialLoad.value) {
            loading.value = true
        }

        const { data: { user } } = await supabase.auth.getUser()

        // Fetch Pathways & Sequences
        const { data: pathData } = await supabase.from('pathways').select('*').order('name')
        pathwaysList.value = pathData || []

        const { data: seqData } = await supabase.from('sequences')
            .select('*')
            .order('seq_number', { ascending: false })
        sequencesList.value = seqData || []

        if (user) {
            // Get current user's player data
            const { data } = await supabase.from('players')
                .select('*')
                .eq('auth_id', user.id)
                .single()

            currentUser.value = (data || {
                role: 'guest',
                character_name: 'Unknown',
                money: 0,
                bank_balance: 0
            }) as Player

            // Fetch current user's skills
            if (data) {
                const { data: skillsData } = await supabase.from('player_skills')
                    .select('*')
                    .eq('player_id', data.id)
                    .single()

                if (skillsData) {
                    const { player_id: _, id: __, ...skills } = skillsData
                    currentUserSkills.value = skills
                }
            }

            // Fetch economy data
            await fetchEconomyData()

            // Fetch all players and enemies
            const { data: pData } = await supabase.from('players')
                .select('*')
                .order('character_name')
            players.value = pData || []

            const { data: eData } = await supabase.from('enemies')
                .select('*')
                .order('character_name')
            enemies.value = eData || []

            // Fetch maps
            const { data: mapsData } = await supabase.from('maps')
                .select('*')
                .order('name')
            mapsList.value = mapsData || []

            // Fetch map positions with character data
            const { data: posData } = await supabase.from('map_positions')
                .select('*')
        
            // Enrich positions with character data
            const enrichedPositions = (posData || []).map((pos: any) => {
                const player = players.value.find((p: Player) => p.id === pos.player_id)
                const enemy = enemies.value.find((e: Enemy) => e.id === pos.enemy_id)
                const char: any = player || enemy
            
                return {
                    ...pos,
                    ...char, // Spread full character data (hp, money, etc.)
                    pos_id: pos.id,
                    id: pos.player_id || pos.enemy_id,
                    character_name: char?.character_name || char?.name,
                    character_img_url: char?.character_img_url || char?.img_url,
                    pos_x_percent: pos.pos_x_percent ?? 50,
                    pos_y_percent: pos.pos_y_percent ?? 50,
                    is_enemy: !!enemy
                }
            })
            mapPositions.value = enrichedPositions

            // Fetch transaction logs (filtered by role)
            let logsQuery = supabase.from('transaction_logs')
                .select('*')
                .order('created_at', { ascending: false })
                .limit(100)
            
            // Non-admin users only see logs related to themselves
            if (!isAdmin.value && currentUser.value) {
                logsQuery = logsQuery.or(`actor_id.eq.${currentUser.value.id},target_id.eq.${currentUser.value.id}`)
            }
            
            const { data: logsData } = await logsQuery
            transactionLogs.value = logsData || []
    }

    loading.value = false
    } catch (error) {
        console.error('Error fetching data:', error)
        showToast('เกิดข้อผิดพลาดในการดึงข้อมูล', 'error')
        loading.value = false
    }
}

async function fetchEconomyData() {
    if (!currentUser.value) return

    // Fetch shop items
    const { data: shopData } = await supabase.from('items')
        .select('*')
        .order('price_buy')
    shopList.value = shopData || []

    // Fetch player inventory
    const { data: invData } = await supabase.from('inventory')
        .select('*, items(*)')
        .eq('player_id', currentUser.value.id)
        .order('updated_at')
    inventoryList.value = invData || []
}

// =============================================================================
// TRANSACTION LOG SYSTEM
// =============================================================================

/**
 * Add a transaction log entry
 * @param actionType - Type of action (e.g., 'item_buy', 'money_transfer')
 * @param options - Log options
 */
async function addLog(
    actionType: string,
    options: {
        actorId?: string
        actorName?: string
        targetId?: string
        targetName?: string
        itemName?: string
        amount?: number
        details?: Record<string, any>
    } = {}
) {
    try {
        const logEntry = {
            action_type: actionType,
            actor_id: options.actorId || currentUser.value?.id || null,
            actor_name: options.actorName || currentUser.value?.character_name || 'Unknown',
            target_id: options.targetId || null,
            target_name: options.targetName || null,
            item_name: options.itemName || null,
            amount: options.amount || null,
            details: options.details || null
        }
        
        await supabase.from('transaction_logs').insert([logEntry])
    } catch (error) {
        console.error('Failed to add log:', error)
    }
}

// =============================================================================
// BANK OPERATIONS
// =============================================================================

function openBankModal(mode: 'deposit' | 'withdraw') {
    bankMode.value = mode
    showBankModal.value = true
}

async function handleBankSubmit(amount: number) {
    if (!currentUser.value) return

    const isDeposit = bankMode.value === 'deposit'
    
    if (isDeposit && amount > currentUser.value.money) {
        showToast('เงินสดไม่พอ!', 'error')
        return
    }
    
    if (!isDeposit && amount > currentUser.value.bank_balance) {
        showToast('ยอดในบัญชีไม่พอ!', 'error')
        return
    }

    loading.value = true

    const newMoney = isDeposit 
        ? currentUser.value.money - amount 
        : currentUser.value.money + amount
    const newBank = isDeposit 
        ? currentUser.value.bank_balance + amount 
        : currentUser.value.bank_balance - amount

    const { error } = await supabase.from('players')
        .update({ money: newMoney, bank_balance: newBank })
        .eq('id', currentUser.value.id)

    if (error) {
        showToast(error.message, 'error')
    } else {
        currentUser.value.money = newMoney
        currentUser.value.bank_balance = newBank
        showToast(isDeposit ? 'ฝากเงินสำเร็จ' : 'ถอนเงินสำเร็จ', 'success')
        showBankModal.value = false
        
        // Log the bank transaction
        await addLog(isDeposit ? 'bank_deposit' : 'bank_withdraw', {
            amount: amount,
            details: { 
                newCash: newMoney, 
                newBank: newBank 
            }
        })
    }

    loading.value = false
}

// =============================================================================
// MONEY TRANSFER
// =============================================================================

function openTransferMoneyModal() {
    showTransferMoneyModal.value = true
}

async function handleTransferMoney(targetId: string, amount: number) {
    if (!currentUser.value) return

    if (amount > currentUser.value.bank_balance) {
        showToast('ยอดในบัญชีไม่พอ!', 'error')
        return
    }

    loading.value = true

    const target = players.value.find((p: Player) => p.id === targetId)
    if (!target) {
        showToast('ไม่พบผู้รับ', 'error')
        loading.value = false
        return
    }

    // Deduct from sender
    const { error: error1 } = await supabase.from('players')
        .update({ bank_balance: currentUser.value.bank_balance - amount })
        .eq('id', currentUser.value.id)

    if (error1) {
        showToast(error1.message, 'error')
        loading.value = false
        return
    }

    // Add to receiver
    const { error: error2 } = await supabase.from('players')
        .update({ bank_balance: target.bank_balance + amount })
        .eq('id', targetId)

    if (error2) {
        showToast(error2.message, 'error')
    } else {
        currentUser.value.bank_balance -= amount
        showToast(`โอนเงิน ฿${amount} ให้ ${target.character_name} สำเร็จ`, 'success')
        showTransferMoneyModal.value = false
        
        // Log the transfer
        await addLog('transfer_money', {
            targetId: target.id,
            targetName: target.character_name,
            amount: amount,
            details: { senderNewBank: currentUser.value.bank_balance, receiverNewBank: target.bank_balance + amount }
        })
    }

    loading.value = false
}

// =============================================================================
// PATHWAY & SEQUENCE MANAGEMENT (Magic View)
// =============================================================================

function openPathwayModal(pathway?: Pathway) {
    editingPathway.value = pathway || null
    showPathwayModal.value = true
}

async function handlePathwaySubmit(data: { id?: string, name: string, goo_group: string }) {
    pathwayLoading.value = true

    try {
        if (data.id) {
            // Update existing
            const { error } = await supabase.from('pathways')
                .update({ name: data.name, goo_group: data.goo_group })
                .eq('id', data.id)

            if (error) throw error
            showToast('แก้ไข Pathway สำเร็จ', 'success')
        } else {
            // Create new
            const { error } = await supabase.from('pathways')
                .insert([{ name: data.name, goo_group: data.goo_group }])

            if (error) throw error
            showToast('สร้าง Pathway สำเร็จ', 'success')
        }

        showPathwayModal.value = false
        editingPathway.value = null
        await fetchData(false)
    } catch (error: any) {
        showToast(error.message, 'error')
    }

    pathwayLoading.value = false
}

function deletePathway(pathwayId: string) {
    const pathway = pathwaysList.value.find((p: Pathway) => p.id === pathwayId)
    if (!pathway) return

    confirmModalData.value = {
        title: 'ลบ Pathway',
        message: `คุณแน่ใจหรือไม่ว่าต้องการลบ "${pathway.name}"? Sequence ทั้งหมดใน Pathway นี้จะถูกลบด้วย`,
        type: 'delete',
        confirmText: 'ลบเลย',
        onConfirm: async () => {
            loading.value = true

            // Delete all sequences in this pathway first
            await supabase.from('sequences')
                .delete()
                .eq('pathway_id', pathwayId)

            // Delete the pathway
            const { error } = await supabase.from('pathways')
                .delete()
                .eq('id', pathwayId)

            if (error) {
                showToast(error.message, 'error')
            } else {
                showToast('ลบ Pathway สำเร็จ', 'success')
                await fetchData(false)
            }

            showConfirmModal.value = false
            loading.value = false
        }
    }
    showConfirmModal.value = true
}

function openSequenceModal(pathwayId: string, sequence?: Sequence) {
    editingSequencePathwayId.value = pathwayId
    editingSequence.value = sequence || null
    showSequenceModal.value = true
}

async function handleSequenceSubmit(data: { id?: string, pathway_id: string, seq_number: number, title: string, rank_group: string }) {
    sequenceLoading.value = true

    try {
        if (data.id) {
            // Update existing
            const { error } = await supabase.from('sequences')
                .update({ 
                    seq_number: data.seq_number, 
                    title: data.title, 
                    rank_group: data.rank_group 
                })
                .eq('id', data.id)

            if (error) throw error
            showToast('แก้ไข Sequence สำเร็จ', 'success')
        } else {
            // Create new
            const { error } = await supabase.from('sequences')
                .insert([{ 
                    pathway_id: data.pathway_id, 
                    seq_number: data.seq_number, 
                    title: data.title, 
                    rank_group: data.rank_group 
                }])

            if (error) throw error
            showToast('สร้าง Sequence สำเร็จ', 'success')
        }

        showSequenceModal.value = false
        editingSequence.value = null
        editingSequencePathwayId.value = ''
        await fetchData(false)
    } catch (error: any) {
        showToast(error.message, 'error')
    }

    sequenceLoading.value = false
}

function deleteSequence(sequenceId: string) {
    const sequence = sequencesList.value.find((s: Sequence) => s.id === sequenceId)
    if (!sequence) return

    confirmModalData.value = {
        title: 'ลบ Sequence',
        message: `คุณแน่ใจหรือไม่ว่าต้องการลบ "${sequence.title}"?`,
        type: 'delete',
        confirmText: 'ลบเลย',
        onConfirm: async () => {
            loading.value = true

            const { error } = await supabase.from('sequences')
                .delete()
                .eq('id', sequenceId)

            if (error) {
                showToast(error.message, 'error')
            } else {
                showToast('ลบ Sequence สำเร็จ', 'success')
                await fetchData(false)
            }

            showConfirmModal.value = false
            loading.value = false
        }
    }
    showConfirmModal.value = true
}

// =============================================================================
// MAP VIEW
// =============================================================================

function handleMapView(map: any) {
    currentMap.value = map
    isMapEditMode.value = false
    currentView.value = 'map_detail'
}

// =============================================================================
// MAP CRUD OPERATIONS
// =============================================================================

function openCreateMap() {
    editingMap.value = null
    showMapConfigModal.value = true
}

function openEditMap(map: any) {
    editingMap.value = { ...map }
    showMapConfigModal.value = true
}

async function handleMapSubmit(formData: any) {
    mapLoading.value = true

    try {
        if (formData.id) {
            // Update existing map
            const { error } = await supabase.from('maps')
                .update({
                    name: formData.name,
                    description: formData.description,
                    image_url: formData.image_url
                })
                .eq('id', formData.id)

            if (error) {
                showToast(error.message, 'error')
            } else {
                showToast('แก้ไขแผนที่สำเร็จ', 'success')
                showMapConfigModal.value = false
                
                // Log the edit
                await addLog('edit_map', {
                    itemName: formData.name,
                    details: { mapId: formData.id }
                })
                
                await fetchData(false)
            }
        } else {
            // Create new map
            const { error } = await supabase.from('maps')
                .insert([{
                    name: formData.name,
                    description: formData.description,
                    image_url: formData.image_url
                }])

            if (error) {
                showToast(error.message, 'error')
            } else {
                showToast('สร้างแผนที่สำเร็จ', 'success')
                showMapConfigModal.value = false
                
                // Log the creation
                await addLog('create_map', {
                    itemName: formData.name
                })
                
                await fetchData(false)
            }
        }
    } catch (error: any) {
        showToast(error.message || 'เกิดข้อผิดพลาด', 'error')
    }

    mapLoading.value = false
}

function deleteMap(mapId: string) {
    const map = mapsList.value.find((m: any) => m.id === mapId)
    if (!map) return

    confirmModalData.value = {
        title: 'ลบแผนที่',
        message: `คุณแน่ใจหรือไม่ว่าต้องการลบแผนที่ "${map.name}"? ตำแหน่งตัวละครทั้งหมดในแผนที่นี้จะถูกลบด้วย`,
        type: 'delete',
        confirmText: 'ลบเลย',
        onConfirm: async () => {
            loading.value = true

            // Delete all positions in this map first
            await supabase.from('map_positions')
                .delete()
                .eq('map_id', mapId)

            // Delete the map
            const { error } = await supabase.from('maps')
                .delete()
                .eq('id', mapId)

            if (error) {
                showToast(error.message, 'error')
            } else {
                showToast('ลบแผนที่สำเร็จ', 'success')
                
                // Log the deletion
                await addLog('delete_map', {
                    itemName: map.name,
                    details: { mapId: mapId }
                })
                
                await fetchData(false)
            }

            showConfirmModal.value = false
            loading.value = false
        }
    }
    showConfirmModal.value = true
}

// =============================================================================
// MAP DRAG & DROP
// =============================================================================

function startDrag(event: MouseEvent, char: any) {
    if (!isMapEditMode.value) return
    
    // Set initial drag position to character's current position
    dragPosition.value = {
        x: char.pos_x_percent,
        y: char.pos_y_percent
    }
    
    draggingCharacter.value = char
}

function onDrag(event: MouseEvent) {
    if (!draggingCharacter.value || !currentMap.value) return

    const mapElement = (event.target as HTMLElement).closest('[data-map]') as HTMLElement
    if (!mapElement) return

    const rect = mapElement.getBoundingClientRect()
    const x = ((event.clientX - rect.left) / rect.width) * 100
    const y = ((event.clientY - rect.top) / rect.height) * 100

    dragPosition.value = {
        x: Math.max(0, Math.min(100, x)),
        y: Math.max(0, Math.min(100, y))
    }
}

function endDrag() {
    if (!draggingCharacter.value) return

    // Find position by matching the character id
    const posIndex = mapPositions.value.findIndex((p: any) => p.id === draggingCharacter.value.id)
    if (posIndex !== -1) {
        // Update local state
        mapPositions.value[posIndex].pos_x_percent = dragPosition.value.x
        mapPositions.value[posIndex].pos_y_percent = dragPosition.value.y
        
        // Save to database
        savePosition(mapPositions.value[posIndex])
    }

    draggingCharacter.value = null
}

async function savePosition(pos: any) {
    const { error } = await supabase.from('map_positions')
        .update({
            pos_x_percent: pos.pos_x_percent,
            pos_y_percent: pos.pos_y_percent
        })
        .eq('id', pos.pos_id)

    if (error) {
        showToast('บันทึกตำแหน่งไม่สำเร็จ', 'error')
    } else {
        showToast('บันทึกตำแหน่งสำเร็จ', 'success')
    }
}

async function removePosition(posId: string | undefined) {
    if (!posId) return

    const { error } = await supabase.from('map_positions')
        .delete()
        .eq('id', posId)

    if (error) {
        showToast('ลบตำแหน่งไม่สำเร็จ', 'error')
    } else {
        mapPositions.value = mapPositions.value.filter((p: any) => p.id !== posId)
        showToast('ลบตำแหน่งสำเร็จ', 'success')
    }
}

function handleMapClick(event: MouseEvent) {
    // Placeholder for adding character to map
    // Will implement in next phase
}

function viewCharacterDetail(char: any) {
    // Find characters nearby (within 5% distance - characters that overlap)
    const nearby = findNearbyCharacters(char, 5)
    
    if (nearby.length > 1) {
        // Multiple characters in the area - show list to choose
        nearbyCharacters.value = nearby
        showCharacterList.value = true
    } else {
        // Only one character - show detail directly
        selectedCharacter.value = char
        showCharacterDetail.value = true
    }
}

function findNearbyCharacters(character: any, threshold: number) {
    // Get all characters on current map
    const allChars = getMapCharacters.value
    
    // Find characters within threshold distance
    return allChars.filter(char => {
        const dx = Math.abs(char.pos_x_percent - character.pos_x_percent)
        const dy = Math.abs(char.pos_y_percent - character.pos_y_percent)
        const distance = Math.sqrt(dx * dx + dy * dy)
        return distance <= threshold
    })
}

function selectCharacterFromList(character: any) {
    showCharacterList.value = false
    selectedCharacter.value = character
    showCharacterDetail.value = true
}

function handleTouchStart(event: TouchEvent) {
    if (!event.touches[0]) return
    const mouseEvent = new MouseEvent('mousedown', {
        clientX: event.touches[0].clientX,
        clientY: event.touches[0].clientY
    })
    // Handle touch as mouse event
}

function handleTouchMove(event: TouchEvent) {
    if (!event.touches[0]) return
    const mouseEvent = new MouseEvent('mousemove', {
        clientX: event.touches[0].clientX,
        clientY: event.touches[0].clientY
    })
    onDrag(mouseEvent)
}

function handleTouchEnd(event: TouchEvent) {
    endDrag()
}

// =============================================================================
// EDIT FUNCTIONS
// =============================================================================

function editPlayer(player: Player) {
    editingCharacter.value = player
    editType.value = 'player'
    showEditModal.value = true
}

function editEnemy(enemy: Enemy) {
    editingCharacter.value = enemy
    editType.value = 'enemy'
    showEditModal.value = true
}

function viewEnemyDetail(enemy: Enemy) {
    // Set is_enemy flag so CharacterDetailModal knows to fetch from enemy_skills table
    selectedCharacter.value = { ...enemy, is_enemy: true }
    showCharacterDetail.value = true
}

async function onEditSaved(data?: { isNew: boolean, characterName: string, characterId: string, type: string }) {
    showToast('บันทึกข้อมูลสำเร็จ', 'success')
    showEditModal.value = false
    editingCharacter.value = null
    
    // Log the save action
    if (data) {
        const actionType = data.isNew 
            ? (data.type === 'player' ? 'create_player' : 'create_enemy')
            : (data.type === 'player' ? 'edit_player' : 'edit_enemy')
        
        await addLog(actionType, {
            targetId: data.characterId,
            targetName: data.characterName
        })
    }
    
    await fetchData(false)
}

// =============================================================================
// UPGRADE MODAL
// =============================================================================

function openUpgradeModal(player?: Player) {
    upgradeTarget.value = player || currentUser.value
    showUpgradeModal.value = true
}

async function handleUpgradeSubmit(stats: Record<string, number>, usedSP: number) {
    if (!upgradeTarget.value) return

    actionLoading.value.upgrade = true

    // Calculate new modifiers
    const updateData: Record<string, number> = { 
        ...stats,
        skill_points: (upgradeTarget.value.skill_points || 0) - usedSP
    }
    
    for (const stat of STATS_CONFIG) {
        updateData[stat.mod] = calculateModifier(stats[stat.key])
    }

    const { error } = await supabase.from('players')
        .update(updateData)
        .eq('id', upgradeTarget.value.id)

    if (error) {
        showToast(error.message, 'error')
    } else {
        // Update local state
        if (currentUser.value?.id === upgradeTarget.value.id) {
            Object.assign(currentUser.value, updateData)
        }
        showToast('อัปเกรดพลังสำเร็จ!', 'success')
        showUpgradeModal.value = false
        
        // Log the upgrade
        await addLog('upgrade_stats', {
            targetId: upgradeTarget.value.id,
            targetName: upgradeTarget.value.character_name,
            amount: usedSP,
            details: { upgradedStats: stats }
        })
        
        await fetchData()
    }

    actionLoading.value.upgrade = false
}

// =============================================================================
// GRANT SP (ADMIN)
// =============================================================================

function openGrantSpModal(player: Player) {
    grantTarget.value = player
    showGrantSpModal.value = true
}

async function handleGrantSp(amount: number) {
    if (!grantTarget.value) return

    actionLoading.value.grant = true

    const newSP = (grantTarget.value.skill_points || 0) + amount

    const { error } = await supabase.from('players')
        .update({ skill_points: newSP })
        .eq('id', grantTarget.value.id)

    if (error) {
        showToast(error.message, 'error')
    } else {
        showToast(`มอบ ${amount} SP ให้ ${grantTarget.value.character_name} สำเร็จ`, 'success')
        showGrantSpModal.value = false
        
        // Log the grant
        await addLog('grant_sp', {
            targetId: grantTarget.value.id,
            targetName: grantTarget.value.character_name,
            amount: amount,
            details: { newSP: newSP }
        })
        
        await fetchData()
    }

    actionLoading.value.grant = false
}

// =============================================================================
// GRANT MONEY (ADMIN)
// =============================================================================

function openGrantMoneyModal(player: Player) {
    grantTarget.value = player
    showGrantMoneyModal.value = true
}

async function handleGrantMoney(amount: number) {
    if (!grantTarget.value) return

    actionLoading.value.grantMoney = true

    const newBank = (grantTarget.value.bank_balance || 0) + amount

    const { error } = await supabase.from('players')
        .update({ bank_balance: newBank })
        .eq('id', grantTarget.value.id)

    if (error) {
        showToast(error.message, 'error')
    } else {
        showToast(`เสกเงิน ฿${amount} ให้ ${grantTarget.value.character_name} สำเร็จ`, 'success')
        showGrantMoneyModal.value = false
        
        // Log the grant
        await addLog('grant_money', {
            targetId: grantTarget.value.id,
            targetName: grantTarget.value.character_name,
            amount: amount,
            details: { newBank: newBank }
        })
        
        await fetchData()
    }

    actionLoading.value.grantMoney = false
}

// =============================================================================
// CHARACTER STATUS
// =============================================================================

async function changeStatus(playerId: string, status: string) {
    loading.value = true
    
    const player = players.value.find((p: Player) => p.id === playerId)

    const { error } = await supabase.from('players')
        .update({ status })
        .eq('id', playerId)

    if (error) {
        showToast(error.message, 'error')
    } else {
        showToast('เปลี่ยนสถานะสำเร็จ', 'success')
        
        // Log the status change
        if (player) {
            await addLog('change_status', {
                targetId: player.id,
                targetName: player.character_name,
                details: { newStatus: status }
            })
        }
        
        await fetchData()
    }

    loading.value = false
}

// =============================================================================
// DELETE CHARACTER
// =============================================================================

async function deletePlayer(playerId: string) {
    const player = players.value.find((p: Player) => p.id === playerId)
    if (!player) return

    confirmModalData.value = {
        title: 'ลบตัวละคร',
        message: `คุณแน่ใจหรือไม่ว่าต้องการลบ "${player.character_name}"? การกระทำนี้ไม่สามารถย้อนกลับได้`,
        type: 'delete',
        confirmText: 'ลบเลย',
        onConfirm: async () => {
            loading.value = true

            // Delete player skills first
            await supabase.from('player_skills')
                .delete()
                .eq('player_id', playerId)

            // Delete inventory
            await supabase.from('inventory')
                .delete()
                .eq('player_id', playerId)

            // Delete map positions
            await supabase.from('map_positions')
                .delete()
                .eq('player_id', playerId)

            // Delete player
            const { error } = await supabase.from('players')
                .delete()
                .eq('id', playerId)

            if (error) {
                showToast(error.message, 'error')
            } else {
                showToast('ลบตัวละครสำเร็จ', 'success')
                
                // Log the deletion
                await addLog('delete_character', {
                    targetId: player.id,
                    targetName: player.character_name
                })
                
                await fetchData()
                showConfirmModal.value = false
            }

            loading.value = false
        }
    }
    showConfirmModal.value = true
}

function viewPlayerDetail(player: Player) {
    selectedCharacter.value = { ...player, is_enemy: false }
    showCharacterDetail.value = true
}

// =============================================================================
// CREATE CHARACTER
// =============================================================================

function openCreatePlayer() {
    // Create a new empty player object for the edit modal
    editingCharacter.value = {
        id: null,
        character_name: 'ตัวละครใหม่',
        character_img_url: '',
        pathways: '',
        sequence: 9,
        nationality: '',
        sex: '',
        role: 'player',
        status: 'active',
        money: 0,
        bank_balance: 0,
        skill_points: 0,
        hp: 100,
        atk: 0,
        ac: 10,
        str: 10, str_mod: 0,
        agi: 10, agi_mod: 0,
        int_stat: 10, int_mod: 0,
        dex: 10, dex_mod: 0,
        con: 10, con_mod: 0,
        wis: 10, wis_mod: 0,
        cha: 10, cha_mod: 0
    }
    editType.value = 'player'
    showEditModal.value = true
}

// =============================================================================
// SHOP & INVENTORY
// =============================================================================

/**
 * Calculate grid space info for equipment
 */
function getGridSpaceInfo(): { cells: number; total: number } {
    const GRID_COLS = 12
    const GRID_ROWS = 5
    const total = GRID_COLS * GRID_ROWS
    
    const equipmentItems = inventoryList.value.filter((inv: InventoryItem) => inv.items.type === 'equipment')
    const usedCells = equipmentItems.reduce((sum: number, inv: InventoryItem) => {
        return sum + (inv.items.grid_width || 1) * (inv.items.grid_height || 1)
    }, 0)
    
    return { cells: total - usedCells, total }
}

/**
 * Check if item can fit in inventory grid by simulating placement
 * This actually checks if there's a valid position for the item
 */
function canFitInGrid(item: Item): boolean {
    if (item.type !== 'equipment') return true
    
    const GRID_COLS = 12
    const GRID_ROWS = 5
    const itemWidth = item.grid_width || 1
    const itemHeight = item.grid_height || 1
    
    // Get all current equipment items with their positions
    const equipmentItems = inventoryList.value
        .filter((inv: InventoryItem) => inv.items.type === 'equipment')
        .map((inv: InventoryItem) => ({
            // Use stored position or calculate one
            x: inv.grid_x ?? 0,
            y: inv.grid_y ?? 0,
            width: inv.items.grid_width || 1,
            height: inv.items.grid_height || 1
        }))
    
    // Build a grid map of occupied cells
    const grid: boolean[][] = []
    for (let y = 0; y < GRID_ROWS; y++) {
        grid[y] = []
        for (let x = 0; x < GRID_COLS; x++) {
            grid[y][x] = false // false = empty
        }
    }
    
    // Mark occupied cells - auto-place items that don't have valid positions
    let placedItems: { x: number; y: number; width: number; height: number }[] = []
    
    for (const item of equipmentItems) {
        let posX = item.x
        let posY = item.y
        
        // If position is invalid or overlapping, find a new position
        if (!isValidPosition(posX, posY, item.width, item.height, grid, GRID_COLS, GRID_ROWS)) {
            const newPos = findFreePosition(item.width, item.height, grid, GRID_COLS, GRID_ROWS)
            if (newPos) {
                posX = newPos.x
                posY = newPos.y
            } else {
                // No space found, grid is effectively full for this item
                continue
            }
        }
        
        // Mark cells as occupied
        for (let dy = 0; dy < item.height; dy++) {
            for (let dx = 0; dx < item.width; dx++) {
                if (posY + dy < GRID_ROWS && posX + dx < GRID_COLS) {
                    grid[posY + dy][posX + dx] = true
                }
            }
        }
        
        placedItems.push({ x: posX, y: posY, width: item.width, height: item.height })
    }
    
    // Now try to find a position for the NEW item
    const newPos = findFreePosition(itemWidth, itemHeight, grid, GRID_COLS, GRID_ROWS)
    return newPos !== null
}

/**
 * Check if position is valid and not overlapping
 */
function isValidPosition(x: number, y: number, width: number, height: number, grid: boolean[][], cols: number, rows: number): boolean {
    if (x < 0 || y < 0 || x + width > cols || y + height > rows) return false
    
    for (let dy = 0; dy < height; dy++) {
        for (let dx = 0; dx < width; dx++) {
            if (grid[y + dy][x + dx]) return false // Cell is occupied
        }
    }
    return true
}

/**
 * Find a free position for an item in the grid
 */
function findFreePosition(width: number, height: number, grid: boolean[][], cols: number, rows: number): { x: number; y: number } | null {
    for (let y = 0; y <= rows - height; y++) {
        for (let x = 0; x <= cols - width; x++) {
            let canPlace = true
            for (let dy = 0; dy < height && canPlace; dy++) {
                for (let dx = 0; dx < width && canPlace; dx++) {
                    if (grid[y + dy][x + dx]) canPlace = false
                }
            }
            if (canPlace) return { x, y }
        }
    }
    return null // No space found
}

async function buyItem(item: Item) {
    if (!currentUser.value) return
    
    if (currentUser.value.money < item.price_buy) {
        showToast('เงินไม่พอ!', 'error')
        return
    }

    // Check grid space for equipment
    if (item.type === 'equipment' && !canFitInGrid(item)) {
        showToast('กระเป๋าเต็ม! ไม่มีพื้นที่ว่างสำหรับอุปกรณ์นี้ กรุณาขายหรือทิ้งไอเทมก่อน', 'error')
        return
    }

    confirmModalData.value = {
        title: 'ยืนยันการซื้อ',
        message: `ซื้อ ${item.name} ราคา ${item.price_buy} เหรียญ?`,
        type: 'confirm',
        confirmText: 'ซื้อเลย',
        onConfirm: async () => {
            loading.value = true

            // Add to inventory FIRST before deducting money
            // Equipment items don't stack - each one takes grid space
            // Consumables and other items can stack
            let insertError = null
            
            if (item.type === 'equipment') {
                // Equipment: always create new entry (no stacking)
                const { error } = await supabase.from('inventory')
                    .insert([{
                        player_id: currentUser.value!.id,
                        item_id: item.id,
                        quantity: 1
                    }])
                insertError = error
            } else {
                // Non-equipment: stack if exists
                const existing = inventoryList.value.find((i: InventoryItem) => i.item_id === item.id)

                if (existing) {
                    const { error } = await supabase.from('inventory')
                        .update({ quantity: existing.quantity + 1 })
                        .eq('id', existing.id)
                    insertError = error
                } else {
                    const { error } = await supabase.from('inventory')
                        .insert([{
                            player_id: currentUser.value!.id,
                            item_id: item.id,
                            quantity: 1
                        }])
                    insertError = error
                }
            }

            // Check if inventory operation succeeded
            if (insertError) {
                showToast(`เกิดข้อผิดพลาด: ${insertError.message}`, 'error')
                loading.value = false
                return
            }

            // Now deduct money after successful inventory update
            const newMoney = currentUser.value!.money - item.price_buy
            const { error } = await supabase.from('players')
                .update({ money: newMoney })
                .eq('id', currentUser.value!.id)

            if (error) {
                showToast(error.message, 'error')
                loading.value = false
                return
            }

            currentUser.value!.money = newMoney
            showToast(`ซื้อ ${item.name} สำเร็จ`, 'success')
            showConfirmModal.value = false
            
            // Log the purchase
            await addLog('buy_item', {
                itemName: item.name,
                amount: item.price_buy,
                details: { newMoney: newMoney, itemType: item.type }
            })
            
            await fetchEconomyData()
            loading.value = false
        }
    }
    showConfirmModal.value = true
}

// =============================================================================
// ITEM MANAGEMENT FUNCTIONS
// =============================================================================

/**
 * Sell an item back to shop
 */
function sellItem(invItem: InventoryItem) {
    if (!invItem?.items) {
        showToast('ไม่พบข้อมูลไอเทม', 'error')
        return
    }
    
    const sellPrice = invItem.items.price_sell || Math.floor((invItem.items.price_buy || 0) / 2)
    
    confirmModalData.value = {
        title: 'ยืนยันการขาย',
        message: `ขาย ${invItem.items.name} คืนร้านในราคา ${sellPrice} เหรียญ?`,
        type: 'confirm',
        confirmText: 'ขายเลย',
        onConfirm: async () => {
            if (!currentUser.value) return
            loading.value = true

            // Add money
            const newMoney = currentUser.value.money + sellPrice
            await supabase.from('players')
                .update({ money: newMoney })
                .eq('id', currentUser.value.id)

            // Remove from inventory (or decrease quantity)
            if (invItem.quantity > 1) {
                await supabase.from('inventory')
                    .update({ quantity: invItem.quantity - 1 })
                    .eq('id', invItem.id)
            } else {
                await supabase.from('inventory')
                    .delete()
                    .eq('id', invItem.id)
            }

            currentUser.value.money = newMoney
            showToast(`ขาย ${invItem.items.name} แล้ว`, 'success')
            showConfirmModal.value = false
            
            // Log the sale
            await addLog('sell_item', {
                itemName: invItem.items.name,
                amount: sellPrice,
                details: { newMoney: newMoney }
            })
            
            await fetchEconomyData()
            loading.value = false
        }
    }
    showConfirmModal.value = true
}

/**
 * Use an item that advances sequence (special handling with celebration modal)
 */
function useAdvanceSequenceItem(invItem: InventoryItem) {
    if (!currentUser.value) return
    
    // Check if already at sequence 1 (cannot advance further)
    if (currentUser.value.sequence <= 1) {
        showToast('คุณอยู่ในลำดับที่ 1 แล้ว ไม่สามารถเลื่อนลำดับได้อีก', 'error')
        return
    }
    
    const newSequence = currentUser.value.sequence - 1
    
    // Find sequence info
    const userPathway = pathwaysList.value.find((p: Pathway) => p.name === currentUser.value?.pathways)
    let sequenceInfo = null
    let pathwayName = currentUser.value.pathways || 'ไม่ทราบเส้นทาง'
    
    if (userPathway) {
        sequenceInfo = sequencesList.value.find(
            (s: Sequence) => s.pathway_id === userPathway.id && s.seq_number === newSequence
        )
    }
    
    const sequenceName = sequenceInfo?.title || `ลำดับที่ ${newSequence}`
    
    confirmModalData.value = {
        title: 'ยืนยันการเลื่อนลำดับ',
        message: `คุณต้องการใช้ "${invItem.items.name}" เพื่อเลื่อนลำดับจาก ${currentUser.value.sequence} ไปยังลำดับ ${newSequence} หรือไม่?`,
        type: 'use',
        confirmText: 'เลื่อนลำดับ!',
        onConfirm: async () => {
            if (!currentUser.value) return
            loading.value = true
            showConfirmModal.value = false
            
            // Update sequence in database
            const { error } = await supabase.from('players')
                .update({ sequence: newSequence })
                .eq('id', currentUser.value.id)
            
            if (error) {
                showToast(error.message, 'error')
                loading.value = false
                return
            }
            
            // Remove/decrease item
            if (invItem.quantity > 1) {
                await supabase.from('inventory')
                    .update({ quantity: invItem.quantity - 1 })
                    .eq('id', invItem.id)
            } else {
                await supabase.from('inventory')
                    .delete()
                    .eq('id', invItem.id)
            }
            
            // Update local state
            currentUser.value.sequence = newSequence
            
            // Log the use
            await addLog('use_item', {
                itemName: invItem.items.name,
                details: { 
                    effects: ['เลื่อนลำดับ'],
                    newSequence: newSequence,
                    sequenceName: sequenceName,
                    pathway: pathwayName
                }
            })
            
            await fetchEconomyData()
            loading.value = false
            
            // Show celebration modal
            sequenceAdvanceData.value = {
                newSequence: newSequence,
                sequenceName: sequenceName,
                pathwayName: pathwayName
            }
            showSequenceAdvanceModal.value = true
        }
    }
    showConfirmModal.value = true
}

/**
 * Use a consumable item
 */
function useItem(invItem: InventoryItem) {
    const effects = invItem.items.effects

    // Check if item has effects
    if (!effects || Object.keys(effects).length === 0) {
        showToast('ไอเทมนี้ไม่มีผลพิเศษ', 'error')
        return
    }

    // Special handling for advance_sequence items
    if (effects.advance_sequence) {
        useAdvanceSequenceItem(invItem)
        return
    }

    // Build effects preview for confirmation (advance_sequence is handled separately)
    const previewMessages: string[] = []
    if (effects.heal_hp) previewMessages.push(`ฟื้นฟู ${effects.heal_hp} HP`)
    STATS_CONFIG.forEach(stat => {
        const buffKey = `buff_${stat.key}`
        if (effects[buffKey]) {
            previewMessages.push(`${stat.label} ${effects[buffKey] > 0 ? '+' : ''}${effects[buffKey]}`)
        }
    })
    if (effects.buff_atk) previewMessages.push(`ATK ${effects.buff_atk > 0 ? '+' : ''}${effects.buff_atk}`)
    if (effects.buff_ac) previewMessages.push(`AC ${effects.buff_ac > 0 ? '+' : ''}${effects.buff_ac}`)

    const effectsText = previewMessages.length > 0 ? `\n\nผลของไอเทม: ${previewMessages.join(', ')}` : ''

    confirmModalData.value = {
        title: 'ยืนยันการใช้ไอเทม',
        message: `คุณต้องการใช้ "${invItem.items.name}" หรือไม่?${effectsText}`,
        type: 'use',
        confirmText: 'ใช้เลย',
        onConfirm: async () => {
            if (!currentUser.value) return
            loading.value = true

            const updateData: Record<string, any> = {}
            const messages: string[] = []

            // Process HP Healing
            if (effects.heal_hp) {
                const newHp = (currentUser.value.hp || 0) + effects.heal_hp
                updateData.hp = newHp
                messages.push(`ฟื้นฟู ${effects.heal_hp} HP`)
                currentUser.value.hp = newHp
            }

            // Process Stat Buffs
            STATS_CONFIG.forEach(stat => {
                const buffKey = `buff_${stat.key}`
                if (effects[buffKey]) {
                    const buffValue = effects[buffKey]
                    const currentVal = (currentUser.value as any)[stat.key] || 10
                    const newVal = currentVal + buffValue
                    const newMod = Math.floor((newVal - 10) / 2)

                    updateData[stat.key] = newVal
                    updateData[stat.mod] = newMod

                    messages.push(`${stat.label} ${buffValue > 0 ? '+' : ''}${buffValue}`)
                    ;(currentUser.value as any)[stat.key] = newVal
                    ;(currentUser.value as any)[stat.mod] = newMod
                }
            })

            // Process ATK/AC buffs
            if (effects.buff_atk) {
                const newAtk = (currentUser.value.atk || 0) + effects.buff_atk
                updateData.atk = newAtk
                messages.push(`ATK ${effects.buff_atk > 0 ? '+' : ''}${effects.buff_atk}`)
                currentUser.value.atk = newAtk
            }

            if (effects.buff_ac) {
                const newAc = (currentUser.value.ac || 10) + effects.buff_ac
                updateData.ac = newAc
                messages.push(`AC ${effects.buff_ac > 0 ? '+' : ''}${effects.buff_ac}`)
                currentUser.value.ac = newAc
            }

            // Note: advance_sequence is now handled separately in useAdvanceSequenceItem

            // Update player in database
            if (Object.keys(updateData).length > 0) {
                await supabase.from('players')
                    .update(updateData)
                    .eq('id', currentUser.value.id)
            }

            // Remove/decrease item
            if (invItem.quantity > 1) {
                await supabase.from('inventory')
                    .update({ quantity: invItem.quantity - 1 })
                    .eq('id', invItem.id)
            } else {
                await supabase.from('inventory')
                    .delete()
                    .eq('id', invItem.id)
            }

            showToast(`ใช้ ${invItem.items.name}: ${messages.join(', ')}`, 'success')
            showConfirmModal.value = false
            
            // Log the use
            await addLog('use_item', {
                itemName: invItem.items.name,
                details: { effects: messages }
            })
            
            await fetchEconomyData()
            loading.value = false
        }
    }
    showConfirmModal.value = true
}

/**
 * Discard an item from inventory
 */
function discardItem(invItem: InventoryItem) {
    if (!invItem?.items) {
        showToast('ไม่พบข้อมูลไอเทม', 'error')
        return
    }
    
    confirmModalData.value = {
        title: 'ทิ้งไอเทม',
        message: `คุณต้องการทิ้ง ${invItem.items.name} ใช่หรือไม่? (ไม่ได้เงินคืน)`,
        type: 'delete',
        confirmText: 'ทิ้งเลย',
        onConfirm: async () => {
            loading.value = true

            if (invItem.quantity > 1) {
                await supabase.from('inventory')
                    .update({ quantity: invItem.quantity - 1 })
                    .eq('id', invItem.id)
            } else {
                await supabase.from('inventory')
                    .delete()
                    .eq('id', invItem.id)
            }

            showToast('ทิ้งไอเทมแล้ว', 'success')
            showConfirmModal.value = false
            
            // Log the discard
            await addLog('discard_item', {
                itemName: invItem.items.name,
                details: { quantity: 1 }
            })
            
            await fetchEconomyData()
            loading.value = false
        }
    }
    showConfirmModal.value = true
}

/**
 * Toggle equipment status
 */
async function toggleEquipItem(invItem: InventoryItem) {
    if (invItem.items.type !== 'equipment') return

    loading.value = true

    const newStatus = !invItem.is_equipped
    await supabase.from('inventory')
        .update({ is_equipped: newStatus })
        .eq('id', invItem.id)

    showToast(newStatus ? 'สวมใส่แล้ว' : 'ถอดออกแล้ว', 'success')
    await fetchEconomyData()
    loading.value = false
}

/**
 * Apply equipment buffs to player stats (temporary)
 */
async function applyEquipmentBuffs(buffs: Record<string, number>) {
    if (!currentUser.value) return
    
    const updates: Record<string, number> = {}
    const player = currentUser.value
    
    for (const [key, value] of Object.entries(buffs)) {
        const statKey = key.replace('buff_', '') as keyof Player
        if (typeof player[statKey] === 'number') {
            updates[statKey] = (player[statKey] as number) + value
        }
    }
    
    if (Object.keys(updates).length > 0) {
        await supabase.from('players')
            .update(updates)
            .eq('id', player.id)
        
        // Update local state
        for (const [key, value] of Object.entries(updates)) {
            (currentUser.value as any)[key] = value
        }
    }
}

/**
 * Remove equipment buffs from player stats
 */
async function removeEquipmentBuffs(buffs: Record<string, number>) {
    if (!currentUser.value) return
    
    const updates: Record<string, number> = {}
    const player = currentUser.value
    
    for (const [key, value] of Object.entries(buffs)) {
        const statKey = key.replace('buff_', '') as keyof Player
        if (typeof player[statKey] === 'number') {
            updates[statKey] = (player[statKey] as number) - value
        }
    }
    
    if (Object.keys(updates).length > 0) {
        await supabase.from('players')
            .update(updates)
            .eq('id', player.id)
        
        // Update local state
        for (const [key, value] of Object.entries(updates)) {
            (currentUser.value as any)[key] = value
        }
    }
}

/**
 * Update item position in inventory grid
 */
async function updateItemPosition(itemId: string, x: number, y: number) {
    await supabase.from('inventory')
        .update({ grid_x: x, grid_y: y })
        .eq('id', itemId)
}

/**
 * Open transfer item modal
 */
function transferItem(invItem: InventoryItem) {
    transferItemTarget.value = invItem
    showTransferItemModal.value = true
}

/**
 * Handle item transfer submission
 */
async function handleTransferItem(targetId: string, quantity: number) {
    if (!currentUser.value || !transferItemTarget.value) return

    const invItem = transferItemTarget.value
    const target = players.value.find((p: Player) => p.id === targetId)
    
    if (!target) {
        showToast('ไม่พบผู้รับ', 'error')
        return
    }

    loading.value = true

    try {
        // Check if target already has this item
        const { data: existingInv } = await supabase
            .from('inventory')
            .select('*')
            .eq('player_id', targetId)
            .eq('item_id', invItem.item_id)
            .single()

        if (existingInv) {
            // Add to existing inventory
            await supabase.from('inventory')
                .update({ quantity: existingInv.quantity + quantity })
                .eq('id', existingInv.id)
        } else {
            // Create new inventory entry
            await supabase.from('inventory')
                .insert([{
                    player_id: targetId,
                    item_id: invItem.item_id,
                    quantity: quantity
                }])
        }

        // Remove/decrease from sender's inventory
        if (invItem.quantity > quantity) {
            await supabase.from('inventory')
                .update({ quantity: invItem.quantity - quantity })
                .eq('id', invItem.id)
        } else {
            await supabase.from('inventory')
                .delete()
                .eq('id', invItem.id)
        }

        showToast(`ส่ง ${invItem.items.name} x${quantity} ให้ ${target.character_name} สำเร็จ`, 'success')
        showTransferItemModal.value = false
        transferItemTarget.value = null
        
        // Log the transfer
        await addLog('transfer_item', {
            targetId: target.id,
            targetName: target.character_name,
            itemName: invItem.items.name,
            amount: quantity,
            details: { itemId: invItem.item_id }
        })
        
        await fetchEconomyData()
    } catch (error: any) {
        showToast(error.message || 'เกิดข้อผิดพลาด', 'error')
    }

    loading.value = false
}

// =============================================================================
// EMBED MODAL
// =============================================================================

function openEmbedModal(player: Player) {
    embedTarget.value = player
    showEmbedModal.value = true
}

function handleEmbedCopied(message: string) {
    showToast(message, 'success')
}

// =============================================================================
// ITEM MANAGEMENT (ADMIN)
// =============================================================================

function openAddItem() {
    editingItem.value = null
    showItemConfigModal.value = true
}

function openEditItem(item: Item) {
    editingItem.value = { ...item }
    showItemConfigModal.value = true
}

async function handleItemSubmit(formData: any) {
    itemLoading.value = true

    try {
        // Parse effects JSON string back to object
        const payload: Record<string, any> = {
            name: formData.name,
            description: formData.description,
            type: formData.type,
            price_buy: formData.price_buy,
            price_sell: formData.price_sell,
            image_url: formData.image_url,
            effects: JSON.parse(formData.effects || '{}')
        }

        // Add equipment-specific fields
        if (formData.type === 'equipment') {
            payload.slot_type = formData.slot_type || null
            payload.grid_width = formData.grid_width || 1
            payload.grid_height = formData.grid_height || 1
        }

        if (formData.id) {
            // Update existing item
            const { error } = await supabase.from('items')
                .update(payload)
                .eq('id', formData.id)

            if (error) {
                showToast(error.message, 'error')
            } else {
                showToast('แก้ไขสินค้าสำเร็จ', 'success')
                showItemConfigModal.value = false
                
                // Log the edit
                await addLog('edit_shop_item', {
                    itemName: formData.name,
                    details: { itemId: formData.id, type: formData.type }
                })
                
                await fetchEconomyData()
            }
        } else {
            // Create new item
            const { error } = await supabase.from('items')
                .insert([payload])

            if (error) {
                showToast(error.message, 'error')
            } else {
                showToast('เพิ่มสินค้าสำเร็จ', 'success')
                showItemConfigModal.value = false
                
                // Log the creation
                await addLog('create_shop_item', {
                    itemName: formData.name,
                    details: { type: formData.type, price: formData.price_buy }
                })
                
                await fetchEconomyData()
            }
        }
    } catch (e: any) {
        showToast('รูปแบบ JSON ใน Effects ไม่ถูกต้อง', 'error')
    }

    itemLoading.value = false
}

function deleteItem(itemId: string) {
    const item = shopList.value.find((i: Item) => i.id === itemId)
    if (!item) return

    confirmModalData.value = {
        title: 'ลบสินค้า',
        message: `คุณแน่ใจหรือไม่ว่าต้องการลบ "${item.name}"?`,
        type: 'delete',
        confirmText: 'ลบเลย',
        onConfirm: async () => {
            loading.value = true

            const { error } = await supabase.from('items')
                .delete()
                .eq('id', itemId)

            if (error) {
                showToast(error.message, 'error')
            } else {
                showToast('ลบสินค้าสำเร็จ', 'success')
                
                // Log the deletion
                await addLog('delete_shop_item', {
                    itemName: item.name,
                    details: { itemId: itemId }
                })
                
                await fetchEconomyData()
            }

            showConfirmModal.value = false
            loading.value = false
        }
    }
    showConfirmModal.value = true
}

// =============================================================================
// LIFECYCLE
// =============================================================================

onMounted(async () => {
    // Initialize global auth store
    await initializeAuth()
    
    // Fetch data if authenticated
    if (authStore.session) {
        await fetchData(true)
        isInitialLoad.value = false
    }
})
</script>

<template>
    <div class="pb-20">
        <!-- Toast Notifications -->
        <ToastContainer :toasts="toasts" />

        <!-- Loading Overlay -->
        <LoadingOverlay :show="loading" />

        <!-- Login Screen -->
        <LoginScreen 
            v-if="!authStore.session"
            @success="onLoginSuccess"
            @error="onLoginError"
        />

        <!-- Main Application -->
        <div v-else>
            <!-- Header -->
            <AppHeader 
                :current-user="currentUser"
                @logout="handleLogout"
                @upgrade="openUpgradeModal()"
            />

            <!-- Navigation -->
            <NavBar 
                :current-view="currentView"
                :is-admin="isAdmin"
                @navigate="currentView = $event"
            />

            <!-- Main Content -->
            <main class="container mx-auto p-4 md:p-8 min-h-screen">
                <!-- Dashboard View -->
                <DashboardView
                    v-if="currentView === 'dashboard' && currentUser"
                    :current-user="currentUser"
                    :skills="currentUserSkills"
                    :pathways="pathwaysList"
                    :sequences="sequencesList"
                    :is-admin="isAdmin"
                    @deposit="openBankModal('deposit')"
                    @withdraw="openBankModal('withdraw')"
                    @transfer="openTransferMoneyModal"
                    @upgrade="openUpgradeModal()"
                    @edit="editPlayer"
                />

                <!-- Inventory View -->
                <InventoryView
                    v-if="currentView === 'inventory' && currentUser"
                    :current-user="currentUser"
                    :inventory-list="inventoryList"
                    @deposit="openBankModal('deposit')"
                    @withdraw="openBankModal('withdraw')"
                    @transfer="openTransferMoneyModal"
                    @use="useItem"
                    @sell="sellItem"
                    @discard="discardItem"
                    @toggle-equip="toggleEquipItem"
                    @transfer-item="transferItem"
                    @apply-buffs="applyEquipmentBuffs"
                    @remove-buffs="removeEquipmentBuffs"
                    @update-position="updateItemPosition"
                />

                <!-- Shop View -->
                <ShopView
                    v-if="currentView === 'shop' && currentUser"
                    :current-user="currentUser"
                    :shop-list="shopList"
                    :is-admin="isAdmin"
                    :grid-space-info="getGridSpaceInfo()"
                    @add-item="openAddItem"
                    @edit-item="openEditItem"
                    @delete-item="deleteItem"
                    @buy-item="buyItem"
                />

                <!-- Players List -->
                <PlayersList
                    v-if="currentView === 'players'"
                    :players="players"
                    :current-user-id="currentUser?.id"
                    :is-admin="isAdmin"
                    :is-super-admin="isSuperAdmin"
                    :pathways="pathwaysList"
                    :sequences="sequencesList"
                    :loading="loading"
                    @create="openCreatePlayer"
                    @embed="openEmbedModal"
                    @grant-money="openGrantMoneyModal"
                    @grant-sp="openGrantSpModal"
                    @change-status="changeStatus"
                    @edit="editPlayer"
                    @delete="deletePlayer"
                    @view-detail="viewPlayerDetail"
                />

                <!-- Enemies List -->
                <EnemiesList
                    v-if="currentView === 'enemies'"
                    :enemies="enemies"
                    :is-admin="isAdmin"
                    :is-super-admin="isSuperAdmin"
                    :loading="loading"
                    @edit="editEnemy"
                    @viewDetail="viewEnemyDetail"
                />

                <!-- Magic View -->
                <MagicView
                    v-if="currentView === 'magic'"
                    :pathways="pathwaysList"
                    :sequences="sequencesList"
                    :is-admin="isAdmin"
                    @create-pathway="openPathwayModal()"
                    @create-sequence="openSequenceModal"
                    @edit-pathway="openPathwayModal"
                    @edit-sequence="openSequenceModal"
                    @delete-pathway="deletePathway"
                    @delete-sequence="deleteSequence"
                />

                <!-- Map View -->
                <MapView
                    v-if="currentView === 'map'"
                    :maps="mapsList"
                    :current-user-id="currentUser?.id"
                    @create-map="openCreateMap"
                    @view-map="handleMapView"
                    @edit-map="openEditMap"
                    @delete-map="deleteMap"
                />

                <!-- Logs View -->
                <LogsView
                    v-if="currentView === 'logs'"
                    :logs="transactionLogs"
                    :loading="logsLoading"
                />

                <!-- Map Detail View -->
                <MapDetailView
                    v-if="currentView === 'map_detail'"
                    :map="currentMap"
                    :characters="getMapCharacters"
                    :is-edit-mode="isMapEditMode"
                    :is-admin="isAdmin"
                    :current-user-id="currentUser?.id"
                    :dragging-character="draggingCharacter"
                    :drag-position="dragPosition"
                    @back="currentView = 'map'; isMapEditMode = false"
                    @toggle-edit-mode="isMapEditMode = !isMapEditMode"
                    @view-character="viewCharacterDetail"
                    @remove-position="removePosition"
                    @start-drag="startDrag"
                    @on-drag="onDrag"
                    @end-drag="endDrag"
                    @handle-touch-start="handleTouchStart"
                    @handle-touch-move="handleTouchMove"
                    @handle-touch-end="handleTouchEnd"
                    @handle-map-click="handleMapClick"
                />
            </main>
        </div>

        <!-- Modals -->
        <BankModal
            :show="showBankModal"
            :mode="bankMode"
            :current-money="currentUser?.money ?? 0"
            :current-bank-balance="currentUser?.bank_balance ?? 0"
            @close="showBankModal = false"
            @submit="handleBankSubmit"
            @update:mode="bankMode = $event"
        />

        <TransferMoneyModal
            v-if="currentUser"
            :show="showTransferMoneyModal"
            :current-user="currentUser"
            :players="players"
            @close="showTransferMoneyModal = false"
            @submit="handleTransferMoney"
        />

        <TransferItemModal
            v-if="currentUser"
            :show="showTransferItemModal"
            :current-user="currentUser"
            :players="players"
            :item="transferItemTarget"
            @close="showTransferItemModal = false; transferItemTarget = null"
            @submit="handleTransferItem"
        />

        <ConfirmModal
            :show="showConfirmModal"
            :title="confirmModalData.title"
            :message="confirmModalData.message"
            :type="confirmModalData.type"
            :confirm-text="confirmModalData.confirmText"
            :loading="loading"
            @close="showConfirmModal = false"
            @confirm="confirmModalData.onConfirm"
        />

        <UpgradeModal
            :show="showUpgradeModal"
            :player="upgradeTarget"
            :loading="actionLoading.upgrade"
            @close="showUpgradeModal = false"
            @submit="handleUpgradeSubmit"
        />

        <GrantSpModal
            :show="showGrantSpModal"
            :target="grantTarget"
            :loading="actionLoading.grant"
            @close="showGrantSpModal = false"
            @submit="handleGrantSp"
        />

        <GrantMoneyModal
            :show="showGrantMoneyModal"
            :target="grantTarget"
            :loading="actionLoading.grantMoney"
            @close="showGrantMoneyModal = false"
            @submit="handleGrantMoney"
        />

        <CharacterListModal
            v-if="showCharacterList"
            :characters="nearbyCharacters"
            @close="showCharacterList = false"
            @select-character="selectCharacterFromList"
        />

        <CharacterDetailModal
            :show="showCharacterDetail"
            :character="selectedCharacter"
            @close="showCharacterDetail = false"
        />

        <!-- Edit Character Modal (เหมือน old-version) -->
        <EditCharacterModal
            :show="showEditModal"
            :character="editingCharacter"
            :type="editType"
            :pathways="pathwaysList"
            :sequences="sequencesList"
            :is-admin="isAdmin"
            @close="showEditModal = false; editingCharacter = null"
            @saved="onEditSaved"
        />

        <!-- Map Config Modal -->
        <MapConfigModal
            :show="showMapConfigModal"
            :map="editingMap"
            :loading="mapLoading"
            @close="showMapConfigModal = false; editingMap = null"
            @submit="handleMapSubmit"
        />

        <!-- Embed Modal -->
        <EmbedModal
            :show="showEmbedModal"
            :player="embedTarget"
            @close="showEmbedModal = false; embedTarget = null"
            @copied="handleEmbedCopied"
        />

        <!-- Item Config Modal -->
        <ItemConfigModal
            :show="showItemConfigModal"
            :item="editingItem"
            :loading="itemLoading"
            @close="showItemConfigModal = false; editingItem = null"
            @submit="handleItemSubmit"
        />

        <!-- Sequence Advance Celebration Modal -->
        <SequenceAdvanceModal
            :show="showSequenceAdvanceModal"
            :new-sequence="sequenceAdvanceData.newSequence"
            :sequence-name="sequenceAdvanceData.sequenceName"
            :pathway-name="sequenceAdvanceData.pathwayName"
            @close="showSequenceAdvanceModal = false"
        />

        <!-- Pathway Modal -->
        <PathwayModal
            :show="showPathwayModal"
            :pathway="editingPathway"
            :loading="pathwayLoading"
            @close="showPathwayModal = false; editingPathway = null"
            @submit="handlePathwaySubmit"
        />

        <!-- Sequence Modal -->
        <SequenceModal
            :show="showSequenceModal"
            :sequence="editingSequence"
            :pathway-id="editingSequencePathwayId"
            :loading="sequenceLoading"
            @close="showSequenceModal = false; editingSequence = null; editingSequencePathwayId = ''"
            @submit="handleSequenceSubmit"
        />
    </div>
</template>
