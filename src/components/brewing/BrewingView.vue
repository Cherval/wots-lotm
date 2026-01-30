<script setup lang="ts">
/**
 * BrewingView.vue
 * Main brewing view - Potion brewing system with drag & drop
 */
import { ref, computed, onMounted, watch } from 'vue'
import type { Recipe, RecipeStep, InventoryItem, Item, PlayerBrewingStep } from '@/lib/constants'
import { DIFFICULTY_LABELS, UNIT_LABELS, FIRE_LEVEL_LABELS } from '@/lib/constants'
import { supabase } from '@/lib/supabase'
import BrewingPot from './BrewingPot.vue'
import IngredientPanel from './IngredientPanel.vue'
import RecipeSelector from './RecipeSelector.vue'
import BrewingTimer from './BrewingTimer.vue'
import AmountInputModal from '../modals/AmountInputModal.vue'
import BrewingResultModal from '../modals/BrewingResultModal.vue'
import RecipeConfigModal from '../modals/RecipeConfigModal.vue'

const props = defineProps<{
    currentUserId: string
    inventoryList: InventoryItem[]
    isAdmin: boolean
}>()

const emit = defineEmits<{
    refreshInventory: []
    showToast: [msg: string, type: 'success' | 'error', title?: string]
    addLog: [actionType: string, options: Record<string, any>]
}>()

// ================= STATE =================

// Recipe data
const recipes = ref<Recipe[]>([])
const selectedRecipe = ref<Recipe | null>(null)
const recipesLoading = ref(true)

// Brewing state
const isBrewing = ref(false)
const currentFireLevel = ref(0)
const playerSteps = ref<PlayerBrewingStep[]>([])
const potContents = ref<{ item: Item, amount: number, unit: string }[]>([])

// Timer state
const isTimerRunning = ref(false)
const timerSeconds = ref(0)
const timerTargetSeconds = ref(0)

// Drag & drop state
const draggedItem = ref<InventoryItem | null>(null)
const isDragOver = ref(false)

// Modal states
const showAmountModal = ref(false)
const amountModalItem = ref<InventoryItem | null>(null)
const showResultModal = ref(false)
const brewingResult = ref<{ success: boolean, message: string, accuracy: number, reward?: Item }>({
    success: false,
    message: '',
    accuracy: 0
})
const showRecipeConfigModal = ref(false)
const editingRecipe = ref<Recipe | null>(null)
const recipeConfigLoading = ref(false)

// ================= COMPUTED =================

// Get materials from inventory
const materialItems = computed(() => {
    return props.inventoryList.filter(inv => inv.items.type === 'material')
})

// Get recipe items from inventory (สูตรยาที่ผู้เล่นมี)
const ownedRecipeItems = computed(() => {
    return props.inventoryList.filter(inv => inv.items.type === 'recipe')
})

// Get recipe IDs that player owns
const ownedRecipeIds = computed(() => {
    return ownedRecipeItems.value
        .map(inv => inv.items.recipe_id)
        .filter((id): id is string => !!id)
})

// Filter recipes based on ownership (for players) or show all (for admin)
const availableRecipes = computed(() => {
    if (props.isAdmin) {
        // Admin can see all recipes
        return recipes.value
    }
    // Players can only see recipes they own
    return recipes.value.filter(recipe => ownedRecipeIds.value.includes(recipe.id))
})

// Current step hint
const currentStepHint = computed(() => {
    if (!selectedRecipe.value?.steps) return null
    const stepIndex = playerSteps.value.length
    return selectedRecipe.value.steps[stepIndex] || null
})

// Progress percentage
const brewingProgress = computed(() => {
    if (!selectedRecipe.value?.steps?.length) return 0
    return Math.round((playerSteps.value.length / selectedRecipe.value.steps.length) * 100)
})

// ================= DATA FETCHING =================

async function fetchRecipes() {
    recipesLoading.value = true
    try {
        const { data, error } = await supabase
            .from('recipes')
            .select(`
                *,
                result_item:items!result_item_id(*),
                steps:recipe_steps(
                    *,
                    item:items(*)
                )
            `)
            .order('name')

        if (error) throw error

        // Sort steps by step_order
        recipes.value = (data || []).map((recipe: Recipe) => ({
            ...recipe,
            steps: recipe.steps?.sort((a, b) => a.step_order - b.step_order) || []
        }))
    } catch (error: any) {
        emit('showToast', error.message, 'error', 'ไม่สามารถโหลดสูตรยาได้')
    }
    recipesLoading.value = false
}

onMounted(() => {
    fetchRecipes()
})

// ================= BREWING ACTIONS =================

function startBrewing() {
    if (!selectedRecipe.value) {
        emit('showToast', 'กรุณาเลือกสูตรยาก่อน', 'error')
        return
    }
    isBrewing.value = true
    playerSteps.value = []
    potContents.value = []
    currentFireLevel.value = 0
    emit('showToast', `เริ่มปรุง "${selectedRecipe.value.name}"`, 'success', '🧪 เริ่มปรุงยา')
}

function resetBrewing() {
    isBrewing.value = false
    playerSteps.value = []
    potContents.value = []
    currentFireLevel.value = 0
    isTimerRunning.value = false
    timerSeconds.value = 0
    timerTargetSeconds.value = 0
}

function setFireLevel(level: number) {
    if (!isBrewing.value) {
        emit('showToast', 'กรุณาเริ่มปรุงยาก่อน', 'error')
        return
    }
    if (isTimerRunning.value) {
        emit('showToast', 'ไม่สามารถเปลี่ยนไฟขณะต้มได้', 'error')
        return
    }
    
    currentFireLevel.value = level
    
    // Record step
    playerSteps.value.push({
        step_type: 'set_fire',
        fire_level: level,
        timestamp: Date.now()
    })
    
    emit('showToast', FIRE_LEVEL_LABELS[level], 'success', '🔥 ตั้งระดับไฟ')
}

// ================= DRAG & DROP =================

function handleDragStart(item: InventoryItem) {
    if (!isBrewing.value) return
    draggedItem.value = item
}

function handleDragEnd() {
    draggedItem.value = null
    isDragOver.value = false
}

function handleDragOver(e: DragEvent) {
    if (!isBrewing.value || !draggedItem.value) return
    e.preventDefault()
    isDragOver.value = true
}

function handleDragLeave() {
    isDragOver.value = false
}

function handleDrop(e: DragEvent) {
    e.preventDefault()
    isDragOver.value = false
    
    if (!isBrewing.value || !draggedItem.value) return
    if (isTimerRunning.value) {
        emit('showToast', 'ไม่สามารถใส่ส่วนผสมขณะต้มได้', 'error')
        return
    }
    
    // Show amount modal
    amountModalItem.value = draggedItem.value
    showAmountModal.value = true
    draggedItem.value = null
}

function handleItemClick(item: InventoryItem) {
    if (!isBrewing.value) {
        emit('showToast', 'กรุณาเริ่มปรุงยาก่อน', 'error')
        return
    }
    if (isTimerRunning.value) {
        emit('showToast', 'ไม่สามารถใส่ส่วนผสมขณะต้มได้', 'error')
        return
    }
    
    amountModalItem.value = item
    showAmountModal.value = true
}

async function addIngredient(amount: number, unit: string) {
    if (!amountModalItem.value || !isBrewing.value) return
    
    const item = amountModalItem.value.items
    
    // Add to pot contents
    potContents.value.push({
        item,
        amount,
        unit
    })
    
    // Record step
    playerSteps.value.push({
        step_type: 'add_ingredient',
        item_id: item.id,
        item_name: item.name,
        amount,
        unit,
        timestamp: Date.now()
    })
    
    emit('showToast', `ใส่ ${item.name} ${amount} ${UNIT_LABELS[unit] || unit}`, 'success', '🧪 เพิ่มส่วนผสม')
    
    showAmountModal.value = false
    amountModalItem.value = null
    
    // Check if brewing is complete
    checkBrewingComplete()
}

// ================= TIMER =================

function startTimer(seconds: number) {
    if (!isBrewing.value) {
        emit('showToast', 'กรุณาเริ่มปรุงยาก่อน', 'error')
        return
    }
    if (currentFireLevel.value === 0) {
        emit('showToast', 'กรุณาจุดไฟก่อนต้ม', 'error')
        return
    }
    
    timerTargetSeconds.value = seconds
    timerSeconds.value = seconds
    isTimerRunning.value = true
    
    emit('showToast', `เริ่มต้ม ${seconds} วินาที`, 'success', '⏱️ ตั้งเวลา')
}

function onTimerComplete() {
    isTimerRunning.value = false
    
    // Record simmer step
    playerSteps.value.push({
        step_type: 'simmer',
        duration_seconds: timerTargetSeconds.value,
        fire_level: currentFireLevel.value,
        timestamp: Date.now()
    })
    
    emit('showToast', 'ต้มเสร็จแล้ว!', 'success', '✅ เวลาหมด')
    
    timerSeconds.value = 0
    timerTargetSeconds.value = 0
    
    // Check if brewing is complete
    checkBrewingComplete()
}

function onTimerTick(remaining: number) {
    timerSeconds.value = remaining
}

// ================= BREWING VALIDATION =================

function checkBrewingComplete() {
    if (!selectedRecipe.value?.steps) return
    
    // Check if all steps are done
    if (playerSteps.value.length >= selectedRecipe.value.steps.length) {
        finishBrewing()
    }
}

async function finishBrewing() {
    if (!selectedRecipe.value) return
    
    const result = validateBrewing()
    brewingResult.value = result
    
    // Save brewing session
    try {
        await supabase.from('brewing_sessions').insert({
            player_id: props.currentUserId,
            recipe_id: selectedRecipe.value.id,
            status: result.success ? 'success' : 'failed',
            completed_at: new Date().toISOString(),
            player_steps: playerSteps.value,
            accuracy_score: result.accuracy,
            result_message: result.message
        })
        
        // Always consume ingredients (whether success or failed)
        await consumeIngredients()
        
        // If success, add item to inventory
        if (result.success && selectedRecipe.value.result_item_id) {
            await addResultToInventory()
        }
        
        // Log the action
        emit('addLog', result.success ? 'brewing_success' : 'brewing_failed', {
            itemName: selectedRecipe.value.name,
            details: {
                accuracy: result.accuracy,
                recipe_id: selectedRecipe.value.id
            }
        })
        
    } catch (error: any) {
        console.error('Error saving brewing session:', error)
    }
    
    showResultModal.value = true
    isBrewing.value = false
}

function validateBrewing(): { success: boolean, message: string, accuracy: number, reward?: Item } {
    if (!selectedRecipe.value?.steps) {
        return { success: false, message: 'ไม่พบสูตรยา', accuracy: 0 }
    }
    
    const recipeSteps = selectedRecipe.value.steps
    const tolerance = selectedRecipe.value.tolerance_percent / 100
    
    let totalScore = 0
    let maxScore = recipeSteps.length
    const errors: string[] = []
    
    for (let i = 0; i < recipeSteps.length; i++) {
        const expected = recipeSteps[i]
        const actual = playerSteps.value[i]
        
        if (!actual) {
            errors.push(`ขั้นตอนที่ ${i + 1}: ไม่ได้ทำ`)
            continue
        }
        
        // Check step type
        if (actual.step_type !== expected.step_type) {
            errors.push(`ขั้นตอนที่ ${i + 1}: ประเภทไม่ถูกต้อง (ควรเป็น ${expected.step_type})`)
            continue
        }
        
        let stepScore = 0
        
        switch (expected.step_type) {
            case 'set_fire':
                if (actual.fire_level === expected.fire_level) {
                    stepScore = 1
                } else {
                    errors.push(`ขั้นตอนที่ ${i + 1}: ระดับไฟไม่ถูกต้อง (ควรเป็น ${expected.fire_level})`)
                }
                break
                
            case 'add_ingredient':
                if (actual.item_id !== expected.item_id) {
                    errors.push(`ขั้นตอนที่ ${i + 1}: ใส่ของผิด (ควรใส่ ${expected.item?.name})`)
                } else {
                    // Check amount within tolerance
                    const expectedAmount = expected.amount || 0
                    const actualAmount = actual.amount || 0
                    const diff = Math.abs(actualAmount - expectedAmount) / expectedAmount
                    
                    if (diff <= tolerance) {
                        stepScore = 1 - (diff / tolerance) * 0.5 // Partial score based on accuracy
                    } else {
                        errors.push(`ขั้นตอนที่ ${i + 1}: ปริมาณคลาดเคลื่อนมาก (ใส่ ${actualAmount} ควรใส่ ${expectedAmount})`)
                    }
                }
                break
                
            case 'simmer':
                // Check duration within tolerance
                const expectedDuration = expected.duration_seconds || 0
                const actualDuration = actual.duration_seconds || 0
                const durationDiff = Math.abs(actualDuration - expectedDuration) / expectedDuration
                
                if (durationDiff <= tolerance) {
                    stepScore = 1 - (durationDiff / tolerance) * 0.5
                } else {
                    errors.push(`ขั้นตอนที่ ${i + 1}: เวลาต้มไม่ถูกต้อง (ต้ม ${actualDuration}s ควรต้ม ${expectedDuration}s)`)
                }
                break
        }
        
        totalScore += stepScore
    }
    
    const accuracy = Math.round((totalScore / maxScore) * 100)
    const success = accuracy >= 70 // Need 70% accuracy to succeed
    
    return {
        success,
        accuracy,
        message: success 
            ? `ปรุงยาสำเร็จ! ความแม่นยำ ${accuracy}%`
            : `ปรุงยาล้มเหลว\n${errors.slice(0, 3).join('\n')}`,
        reward: success ? selectedRecipe.value.result_item : undefined
    }
}

async function addResultToInventory() {
    if (!selectedRecipe.value) return
    
    try {
        // Check if player already has this item
        const { data: existing } = await supabase
            .from('inventory')
            .select('id, quantity')
            .eq('player_id', props.currentUserId)
            .eq('item_id', selectedRecipe.value.result_item_id)
            .single()
        
        if (existing) {
            // Update quantity
            await supabase
                .from('inventory')
                .update({ quantity: existing.quantity + (selectedRecipe.value.result_quantity || 1) })
                .eq('id', existing.id)
        } else {
            // Insert new
            await supabase.from('inventory').insert({
                player_id: props.currentUserId,
                item_id: selectedRecipe.value.result_item_id,
                quantity: selectedRecipe.value.result_quantity || 1,
                is_equipped: false
            })
        }
        
        emit('refreshInventory')
    } catch (error: any) {
        console.error('Error adding result to inventory:', error)
    }
}

// Consume ingredients used in brewing
async function consumeIngredients() {
    if (!selectedRecipe.value || playerSteps.value.length === 0) return
    
    try {
        // Collect all ingredients used (with amounts)
        const ingredientsUsed: Map<string, number> = new Map()
        
        for (const step of playerSteps.value) {
            if (step.step_type === 'add_ingredient' && step.item_id) {
                const current = ingredientsUsed.get(step.item_id) || 0
                ingredientsUsed.set(step.item_id, current + (step.amount || 1))
            }
        }
        
        // Update inventory for each ingredient
        for (const [itemId, amountUsed] of ingredientsUsed) {
            // Get current inventory
            const { data: invItem } = await supabase
                .from('inventory')
                .select('id, quantity')
                .eq('player_id', props.currentUserId)
                .eq('item_id', itemId)
                .single()
            
            if (invItem) {
                const newQuantity = Math.max(0, invItem.quantity - amountUsed)
                
                if (newQuantity <= 0) {
                    // Remove from inventory completely
                    await supabase
                        .from('inventory')
                        .delete()
                        .eq('id', invItem.id)
                } else {
                    // Update quantity
                    await supabase
                        .from('inventory')
                        .update({ quantity: newQuantity })
                        .eq('id', invItem.id)
                }
            }
        }
        
        emit('refreshInventory')
    } catch (error: any) {
        console.error('Error consuming ingredients:', error)
    }
}

function closeResultModal() {
    showResultModal.value = false
    resetBrewing()
}

// ================= RECIPE ADMIN =================

function openCreateRecipe() {
    editingRecipe.value = null
    showRecipeConfigModal.value = true
}

function openEditRecipe(recipe: Recipe) {
    editingRecipe.value = { ...recipe }
    showRecipeConfigModal.value = true
}

async function handleRecipeSave(recipeData: any) {
    recipeConfigLoading.value = true
    
    try {
        if (recipeData.id) {
            // Update existing recipe
            const { error } = await supabase
                .from('recipes')
                .update({
                    name: recipeData.name,
                    description: recipeData.description,
                    image_url: recipeData.image_url,
                    result_item_id: recipeData.result_item_id,
                    result_quantity: recipeData.result_quantity,
                    difficulty: recipeData.difficulty,
                    tolerance_percent: recipeData.tolerance_percent
                })
                .eq('id', recipeData.id)
            
            if (error) throw error
            
            // Update steps - delete old and insert new
            await supabase.from('recipe_steps').delete().eq('recipe_id', recipeData.id)
            
            if (recipeData.steps?.length) {
                await supabase.from('recipe_steps').insert(
                    recipeData.steps.map((step: any, index: number) => ({
                        recipe_id: recipeData.id,
                        step_order: index + 1,
                        ...step
                    }))
                )
            }
            
            emit('showToast', 'แก้ไขสูตรยาสำเร็จ', 'success')
        } else {
            // Create new recipe
            const { data: newRecipe, error } = await supabase
                .from('recipes')
                .insert({
                    name: recipeData.name,
                    description: recipeData.description,
                    image_url: recipeData.image_url,
                    result_item_id: recipeData.result_item_id,
                    result_quantity: recipeData.result_quantity,
                    difficulty: recipeData.difficulty,
                    tolerance_percent: recipeData.tolerance_percent
                })
                .select()
                .single()
            
            if (error) throw error
            
            // Insert steps
            if (recipeData.steps?.length) {
                await supabase.from('recipe_steps').insert(
                    recipeData.steps.map((step: any, index: number) => ({
                        recipe_id: newRecipe.id,
                        step_order: index + 1,
                        ...step
                    }))
                )
            }
            
            emit('showToast', 'สร้างสูตรยาสำเร็จ', 'success')
        }
        
        showRecipeConfigModal.value = false
        await fetchRecipes()
    } catch (error: any) {
        emit('showToast', error.message, 'error', 'เกิดข้อผิดพลาด')
    }
    
    recipeConfigLoading.value = false
}

async function deleteRecipe(recipeId: string) {
    if (!confirm('คุณแน่ใจหรือไม่ว่าต้องการลบสูตรนี้?')) return
    
    try {
        const { error } = await supabase.from('recipes').delete().eq('id', recipeId)
        if (error) throw error
        
        emit('showToast', 'ลบสูตรยาสำเร็จ', 'success')
        await fetchRecipes()
        
        if (selectedRecipe.value?.id === recipeId) {
            selectedRecipe.value = null
        }
    } catch (error: any) {
        emit('showToast', error.message, 'error', 'เกิดข้อผิดพลาด')
    }
}
</script>

<template>
    <div class="brewing-view animate-fade-in">
        <!-- Header -->
        <div class="flex items-center justify-between mb-6">
            <h2 class="text-3xl text-vic-gold font-bold font-serif flex items-center gap-3">
                🧪 ปรุงยา
            </h2>
            <button
                v-if="isAdmin"
                @click="openCreateRecipe"
                class="btn-gold text-sm"
            >
                ➕ สร้างสูตรใหม่
            </button>
        </div>

        <!-- Main Layout -->
        <div class="grid grid-cols-1 lg:grid-cols-[1fr_400px] gap-6">
            <!-- Left: Brewing Area -->
            <div class="space-y-6">
                <!-- No Recipes Message (for players) -->
                <div 
                    v-if="!isAdmin && availableRecipes.length === 0 && !recipesLoading"
                    class="bg-yellow-900/20 border border-yellow-600 rounded-lg p-6 text-center"
                >
                    <div class="text-4xl mb-3">📜</div>
                    <h3 class="text-yellow-400 font-bold text-lg mb-2">ยังไม่มีสูตรยา</h3>
                    <p class="text-yellow-300/70 text-sm">
                        คุณต้องได้รับสูตรยาจากแอดมินหรือผู้คุมกฎก่อน<br/>
                        สูตรยาจะปรากฏเมื่อมีในกระเป๋าของคุณ
                    </p>
                </div>

                <!-- Recipe Selector -->
                <RecipeSelector
                    v-if="availableRecipes.length > 0 || isAdmin"
                    :recipes="availableRecipes"
                    :selected-recipe="selectedRecipe"
                    :is-brewing="isBrewing"
                    :is-admin="isAdmin"
                    :loading="recipesLoading"
                    @select="selectedRecipe = $event"
                    @edit="openEditRecipe"
                    @delete="deleteRecipe"
                />

                <!-- Brewing Controls -->
                <div v-if="selectedRecipe" class="bg-vic-darkbrown border border-vic-brown rounded-lg p-4">
                    <div class="flex items-center justify-between mb-4">
                        <h3 class="text-vic-gold font-bold">🔥 ควบคุมการปรุง</h3>
                        <div class="flex gap-2">
                            <button
                                v-if="!isBrewing"
                                @click="startBrewing"
                                class="btn-gold text-sm"
                            >
                                ▶️ เริ่มปรุง
                            </button>
                            <button
                                v-else
                                @click="resetBrewing"
                                class="btn-danger text-sm"
                            >
                                🔄 เริ่มใหม่
                            </button>
                        </div>
                    </div>

                    <!-- Fire Level Control -->
                    <div class="mb-4">
                        <label class="block text-sm text-gray-400 mb-2">ระดับไฟ</label>
                        <div class="flex gap-2">
                            <button
                                v-for="level in [0, 1, 2, 3]"
                                :key="level"
                                @click="setFireLevel(level)"
                                class="flex-1 py-3 rounded-lg border-2 transition font-bold text-center"
                                :class="{
                                    'bg-gray-800 border-gray-600 text-gray-400': currentFireLevel !== level,
                                    'bg-blue-900 border-blue-400 text-blue-200': currentFireLevel === level && level === 0,
                                    'bg-yellow-900 border-yellow-400 text-yellow-200': currentFireLevel === level && level === 1,
                                    'bg-orange-900 border-orange-400 text-orange-200': currentFireLevel === level && level === 2,
                                    'bg-red-900 border-red-400 text-red-200': currentFireLevel === level && level === 3,
                                    'opacity-50 cursor-not-allowed': !isBrewing || isTimerRunning
                                }"
                                :disabled="!isBrewing || isTimerRunning"
                            >
                                {{ FIRE_LEVEL_LABELS[level] }}
                            </button>
                        </div>
                    </div>

                    <!-- Timer Controls -->
                    <div class="mb-4">
                        <label class="block text-sm text-gray-400 mb-2">⏱️ ต้มทิ้งไว้</label>
                        <div class="flex gap-2 flex-wrap">
                            <button
                                v-for="sec in [30, 45, 60, 90, 120]"
                                :key="sec"
                                @click="startTimer(sec)"
                                class="px-4 py-2 rounded border transition text-sm"
                                :class="{
                                    'bg-purple-900 border-purple-500 text-purple-200 hover:bg-purple-800': !isTimerRunning,
                                    'opacity-50 cursor-not-allowed': !isBrewing || isTimerRunning || currentFireLevel === 0
                                }"
                                :disabled="!isBrewing || isTimerRunning || currentFireLevel === 0"
                            >
                                {{ sec }}s
                            </button>
                        </div>
                    </div>

                    <!-- Timer Display -->
                    <BrewingTimer
                        v-if="isTimerRunning || timerSeconds > 0"
                        :duration="timerTargetSeconds"
                        :is-running="isTimerRunning"
                        @complete="onTimerComplete"
                        @tick="onTimerTick"
                    />

                    <!-- Progress Bar -->
                    <div class="mt-4">
                        <div class="flex justify-between text-sm text-gray-400 mb-1">
                            <span>ความคืบหน้า</span>
                            <span>{{ playerSteps.length }} / {{ selectedRecipe?.steps?.length || 0 }} ขั้นตอน</span>
                        </div>
                        <div class="h-3 bg-gray-800 rounded-full overflow-hidden">
                            <div 
                                class="h-full bg-gradient-to-r from-vic-gold to-yellow-400 transition-all duration-300"
                                :style="{ width: `${brewingProgress}%` }"
                            />
                        </div>
                    </div>
                </div>

                <!-- Brewing Pot -->
                <BrewingPot
                    :is-brewing="isBrewing"
                    :fire-level="currentFireLevel"
                    :contents="potContents"
                    :is-timer-running="isTimerRunning"
                    :is-drag-over="isDragOver"
                    @dragover="handleDragOver"
                    @dragleave="handleDragLeave"
                    @drop="handleDrop"
                />

                <!-- Current Step Hint -->
                <div 
                    v-if="isBrewing && currentStepHint" 
                    class="bg-blue-900/30 border border-blue-500 rounded-lg p-4"
                >
                    <div class="flex items-center gap-2 text-blue-300 text-sm mb-2">
                        <span>💡</span>
                        <span class="font-bold">ขั้นตอนถัดไป:</span>
                    </div>
                    <p class="text-blue-100">{{ currentStepHint.description }}</p>
                </div>
            </div>

            <!-- Right: Ingredients Panel -->
            <div>
                <IngredientPanel
                    :items="materialItems"
                    :is-brewing="isBrewing"
                    :is-timer-running="isTimerRunning"
                    @drag-start="handleDragStart"
                    @drag-end="handleDragEnd"
                    @item-click="handleItemClick"
                />

                <!-- Recipe Steps Reference -->
                <div 
                    v-if="selectedRecipe?.steps?.length"
                    class="mt-4 bg-vic-darkbrown border border-vic-brown rounded-lg p-4"
                >
                    <h4 class="text-vic-gold font-bold mb-3">📋 ขั้นตอนสูตร</h4>
                    <div class="space-y-2 max-h-64 overflow-y-auto custom-scroll">
                        <div 
                            v-for="(step, index) in selectedRecipe.steps"
                            :key="step.id"
                            class="flex items-start gap-2 text-sm p-2 rounded"
                            :class="{
                                'bg-green-900/30 border border-green-600': index < playerSteps.length,
                                'bg-blue-900/20 border border-blue-600': index === playerSteps.length && isBrewing,
                                'bg-gray-800/50': index > playerSteps.length
                            }"
                        >
                            <span 
                                class="w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold shrink-0"
                                :class="{
                                    'bg-green-600 text-white': index < playerSteps.length,
                                    'bg-blue-600 text-white animate-pulse': index === playerSteps.length && isBrewing,
                                    'bg-gray-600 text-gray-300': index > playerSteps.length
                                }"
                            >
                                {{ index < playerSteps.length ? '✓' : index + 1 }}
                            </span>
                            <span class="text-gray-300">{{ step.description }}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Amount Input Modal -->
        <AmountInputModal
            :show="showAmountModal"
            :item="amountModalItem?.items"
            @close="showAmountModal = false; amountModalItem = null"
            @submit="addIngredient"
        />

        <!-- Brewing Result Modal -->
        <BrewingResultModal
            :show="showResultModal"
            :result="brewingResult"
            @close="closeResultModal"
        />

        <!-- Recipe Config Modal (Admin) -->
        <RecipeConfigModal
            v-if="isAdmin"
            :show="showRecipeConfigModal"
            :recipe="editingRecipe"
            :loading="recipeConfigLoading"
            @close="showRecipeConfigModal = false"
            @save="handleRecipeSave"
        />
    </div>
</template>

<style scoped>
.brewing-view {
    min-height: 100vh;
}
</style>
