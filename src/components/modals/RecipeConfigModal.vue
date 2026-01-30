<script setup lang="ts">
/**
 * RecipeConfigModal.vue
 * Admin modal for creating/editing recipes
 */
import { ref, watch, computed } from 'vue'
import type { Recipe, RecipeStep, Item } from '@/lib/constants'
import { DIFFICULTY_LABELS, FIRE_LEVEL_LABELS, UNIT_LABELS } from '@/lib/constants'
import { supabase } from '@/lib/supabase'
import BaseModal from '../ui/BaseModal.vue'

const props = defineProps<{
    show: boolean
    recipe: Recipe | null
    loading: boolean
}>()

const emit = defineEmits<{
    close: []
    save: [recipe: any]
}>()

// Form data
const formData = ref({
    id: '',
    name: '',
    description: '',
    image_url: '',
    result_item_id: '',
    result_quantity: 1,
    difficulty: 'normal' as 'easy' | 'normal' | 'hard' | 'expert',
    tolerance_percent: 10
})

// Steps
const steps = ref<Partial<RecipeStep>[]>([])

// Items for dropdown
const items = ref<Item[]>([])
const materialItems = computed(() => items.value.filter(i => i.type === 'material'))
const resultItems = computed(() => items.value.filter(i => i.type === 'consumable' || i.type === 'special'))

// Load items
async function loadItems() {
    const { data } = await supabase.from('items').select('*').order('name')
    items.value = data || []
}

// Watch for recipe changes
watch(() => props.show, async (show) => {
    if (show) {
        await loadItems()
        
        if (props.recipe) {
            // Edit mode
            formData.value = {
                id: props.recipe.id,
                name: props.recipe.name,
                description: props.recipe.description || '',
                image_url: props.recipe.image_url || '',
                result_item_id: props.recipe.result_item_id,
                result_quantity: props.recipe.result_quantity,
                difficulty: props.recipe.difficulty,
                tolerance_percent: props.recipe.tolerance_percent
            }
            steps.value = (props.recipe.steps || []).map(s => ({
                step_type: s.step_type,
                fire_level: s.fire_level,
                item_id: s.item_id,
                amount: s.amount,
                unit: s.unit,
                duration_seconds: s.duration_seconds,
                description: s.description
            }))
        } else {
            // Create mode
            resetForm()
        }
    }
})

function resetForm() {
    formData.value = {
        id: '',
        name: '',
        description: '',
        image_url: '',
        result_item_id: '',
        result_quantity: 1,
        difficulty: 'normal',
        tolerance_percent: 10
    }
    steps.value = []
}

// Step management
function addStep(type: 'set_fire' | 'add_ingredient' | 'simmer') {
    const newStep: Partial<RecipeStep> = {
        step_type: type,
        description: ''
    }
    
    switch (type) {
        case 'set_fire':
            newStep.fire_level = 1
            newStep.description = 'จุดไฟระดับ 1'
            break
        case 'add_ingredient':
            newStep.amount = 0
            newStep.unit = 'g'
            newStep.description = 'ใส่ส่วนผสม'
            break
        case 'simmer':
            newStep.duration_seconds = 60
            newStep.description = 'ต้มทิ้งไว้ 1 นาที'
            break
    }
    
    steps.value.push(newStep)
}

function removeStep(index: number) {
    steps.value.splice(index, 1)
}

function moveStep(index: number, direction: 'up' | 'down') {
    const newIndex = direction === 'up' ? index - 1 : index + 1
    if (newIndex < 0 || newIndex >= steps.value.length) return
    
    const temp = steps.value[index]
    steps.value[index] = steps.value[newIndex]
    steps.value[newIndex] = temp
}

// Update step description automatically
function updateStepDescription(step: Partial<RecipeStep>, index: number) {
    switch (step.step_type) {
        case 'set_fire':
            step.description = `จุดไฟระดับ ${step.fire_level}`
            break
        case 'add_ingredient':
            const item = items.value.find(i => i.id === step.item_id)
            step.description = `ใส่${item?.name || 'ส่วนผสม'} ${step.amount} ${UNIT_LABELS[step.unit || 'g']}`
            break
        case 'simmer':
            const mins = Math.floor((step.duration_seconds || 0) / 60)
            const secs = (step.duration_seconds || 0) % 60
            step.description = mins > 0 
                ? `ต้มทิ้งไว้ ${mins} นาที ${secs > 0 ? secs + ' วินาที' : ''}`
                : `ต้มทิ้งไว้ ${secs} วินาที`
            break
    }
}

// Form validation
const isValid = computed(() => {
    return formData.value.name.trim() !== '' &&
           formData.value.result_item_id !== '' &&
           steps.value.length > 0
})

// Submit
function handleSubmit() {
    if (!isValid.value) return
    
    emit('save', {
        ...formData.value,
        steps: steps.value
    })
}
</script>

<template>
    <BaseModal 
        :show="show" 
        :title="recipe ? '✏️ แก้ไขสูตรยา' : '➕ สร้างสูตรยาใหม่'"
        size="xl"
        @close="emit('close')"
    >
        <div class="space-y-6 max-h-[70vh] overflow-y-auto custom-scroll pr-2">
            <!-- Basic Info -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm text-gray-400 mb-1">ชื่อสูตร *</label>
                    <input
                        v-model="formData.name"
                        type="text"
                        class="input-vic"
                        placeholder="เช่น ยาเอนกประสงค์"
                    />
                </div>
                <div>
                    <label class="block text-sm text-gray-400 mb-1">ความยาก</label>
                    <select v-model="formData.difficulty" class="input-vic">
                        <option v-for="(label, key) in DIFFICULTY_LABELS" :key="key" :value="key">
                            {{ label }}
                        </option>
                    </select>
                </div>
            </div>

            <div>
                <label class="block text-sm text-gray-400 mb-1">คำอธิบาย</label>
                <textarea
                    v-model="formData.description"
                    class="input-vic resize-none"
                    rows="2"
                    placeholder="คำอธิบายสูตรยา..."
                />
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm text-gray-400 mb-1">URL รูปภาพ</label>
                    <input
                        v-model="formData.image_url"
                        type="text"
                        class="input-vic"
                        placeholder="https://..."
                    />
                </div>
                <div>
                    <label class="block text-sm text-gray-400 mb-1">% ความคลาดเคลื่อนที่ยอมรับ</label>
                    <input
                        v-model.number="formData.tolerance_percent"
                        type="number"
                        min="1"
                        max="50"
                        class="input-vic"
                    />
                </div>
            </div>

            <!-- Result Item -->
            <div class="p-4 bg-green-900/20 border border-green-700 rounded-lg">
                <h4 class="text-green-400 font-bold mb-3">🎁 ผลลัพธ์เมื่อปรุงสำเร็จ</h4>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm text-gray-400 mb-1">ไอเทมที่ได้รับ *</label>
                        <select v-model="formData.result_item_id" class="input-vic">
                            <option value="">-- เลือกไอเทม --</option>
                            <option v-for="item in resultItems" :key="item.id" :value="item.id">
                                {{ item.name }}
                            </option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm text-gray-400 mb-1">จำนวน</label>
                        <input
                            v-model.number="formData.result_quantity"
                            type="number"
                            min="1"
                            class="input-vic"
                        />
                    </div>
                </div>
            </div>

            <!-- Steps -->
            <div class="p-4 bg-blue-900/20 border border-blue-700 rounded-lg">
                <div class="flex items-center justify-between mb-4">
                    <h4 class="text-blue-400 font-bold">📋 ขั้นตอนการปรุง</h4>
                    <div class="flex gap-2">
                        <button
                            @click="addStep('set_fire')"
                            class="px-3 py-1 text-xs bg-orange-900 hover:bg-orange-800 text-orange-200 rounded border border-orange-600"
                        >
                            🔥 ตั้งไฟ
                        </button>
                        <button
                            @click="addStep('add_ingredient')"
                            class="px-3 py-1 text-xs bg-purple-900 hover:bg-purple-800 text-purple-200 rounded border border-purple-600"
                        >
                            🧪 ใส่ของ
                        </button>
                        <button
                            @click="addStep('simmer')"
                            class="px-3 py-1 text-xs bg-cyan-900 hover:bg-cyan-800 text-cyan-200 rounded border border-cyan-600"
                        >
                            ⏱️ ต้ม
                        </button>
                    </div>
                </div>

                <!-- Steps List -->
                <div v-if="steps.length === 0" class="text-center py-8 text-gray-500">
                    <div class="text-3xl mb-2">📝</div>
                    <p>ยังไม่มีขั้นตอน</p>
                    <p class="text-sm">คลิกปุ่มด้านบนเพื่อเพิ่มขั้นตอน</p>
                </div>

                <div v-else class="space-y-3">
                    <div 
                        v-for="(step, index) in steps"
                        :key="index"
                        class="p-3 bg-black/30 rounded-lg border"
                        :class="{
                            'border-orange-600': step.step_type === 'set_fire',
                            'border-purple-600': step.step_type === 'add_ingredient',
                            'border-cyan-600': step.step_type === 'simmer'
                        }"
                    >
                        <div class="flex items-start gap-3">
                            <!-- Step Number -->
                            <div 
                                class="w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold shrink-0"
                                :class="{
                                    'bg-orange-900 text-orange-200': step.step_type === 'set_fire',
                                    'bg-purple-900 text-purple-200': step.step_type === 'add_ingredient',
                                    'bg-cyan-900 text-cyan-200': step.step_type === 'simmer'
                                }"
                            >
                                {{ index + 1 }}
                            </div>

                            <!-- Step Content -->
                            <div class="flex-1 min-w-0">
                                <!-- Set Fire -->
                                <div v-if="step.step_type === 'set_fire'" class="space-y-2">
                                    <div class="text-orange-400 font-bold text-sm">🔥 ตั้งระดับไฟ</div>
                                    <select 
                                        v-model.number="step.fire_level"
                                        class="input-vic text-sm"
                                        @change="updateStepDescription(step, index)"
                                    >
                                        <option v-for="level in [0, 1, 2, 3]" :key="level" :value="level">
                                            {{ FIRE_LEVEL_LABELS[level] }}
                                        </option>
                                    </select>
                                </div>

                                <!-- Add Ingredient -->
                                <div v-else-if="step.step_type === 'add_ingredient'" class="space-y-2">
                                    <div class="text-purple-400 font-bold text-sm">🧪 ใส่ส่วนผสม</div>
                                    <div class="grid grid-cols-3 gap-2">
                                        <select 
                                            v-model="step.item_id"
                                            class="input-vic text-sm col-span-2"
                                            @change="updateStepDescription(step, index)"
                                        >
                                            <option value="">-- เลือกวัตถุดิบ --</option>
                                            <option v-for="item in materialItems" :key="item.id" :value="item.id">
                                                {{ item.name }}
                                            </option>
                                        </select>
                                        <select 
                                            v-model="step.unit"
                                            class="input-vic text-sm"
                                            @change="updateStepDescription(step, index)"
                                        >
                                            <option value="g">กรัม</option>
                                            <option value="ml">มล.</option>
                                            <option value="piece">ชิ้น</option>
                                        </select>
                                    </div>
                                    <input
                                        v-model.number="step.amount"
                                        type="number"
                                        min="0"
                                        step="0.1"
                                        class="input-vic text-sm"
                                        placeholder="ปริมาณ"
                                        @change="updateStepDescription(step, index)"
                                    />
                                </div>

                                <!-- Simmer -->
                                <div v-else-if="step.step_type === 'simmer'" class="space-y-2">
                                    <div class="text-cyan-400 font-bold text-sm">⏱️ ต้มทิ้งไว้</div>
                                    <div class="flex items-center gap-2">
                                        <input
                                            v-model.number="step.duration_seconds"
                                            type="number"
                                            min="1"
                                            class="input-vic text-sm flex-1"
                                            placeholder="วินาที"
                                            @change="updateStepDescription(step, index)"
                                        />
                                        <span class="text-gray-400 text-sm">วินาที</span>
                                    </div>
                                </div>

                                <!-- Description Preview -->
                                <div class="mt-2 text-xs text-gray-400 italic">
                                    {{ step.description }}
                                </div>
                            </div>

                            <!-- Actions -->
                            <div class="flex flex-col gap-1">
                                <button
                                    @click="moveStep(index, 'up')"
                                    :disabled="index === 0"
                                    class="p-1 text-gray-400 hover:text-white disabled:opacity-30"
                                >
                                    ▲
                                </button>
                                <button
                                    @click="moveStep(index, 'down')"
                                    :disabled="index === steps.length - 1"
                                    class="p-1 text-gray-400 hover:text-white disabled:opacity-30"
                                >
                                    ▼
                                </button>
                                <button
                                    @click="removeStep(index)"
                                    class="p-1 text-red-400 hover:text-red-300"
                                >
                                    ✕
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <template #footer>
            <div class="flex gap-3">
                <button
                    @click="emit('close')"
                    class="flex-1 py-2 bg-gray-700 hover:bg-gray-600 text-gray-200 rounded-lg transition"
                    :disabled="loading"
                >
                    ยกเลิก
                </button>
                <button
                    @click="handleSubmit"
                    class="flex-1 py-2 btn-gold"
                    :disabled="!isValid || loading"
                >
                    <span v-if="loading">กำลังบันทึก...</span>
                    <span v-else>💾 {{ recipe ? 'บันทึกการแก้ไข' : 'สร้างสูตร' }}</span>
                </button>
            </div>
        </template>
    </BaseModal>
</template>
