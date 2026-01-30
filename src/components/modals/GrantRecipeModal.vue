<script setup lang="ts">
/**
 * GrantRecipeModal.vue
 * Modal for admin to grant recipe items to players
 */
import { ref, watch, computed, onMounted } from 'vue'
import type { Player } from '@/lib/constants'
import { supabase } from '@/lib/supabase'
import BaseModal from '../ui/BaseModal.vue'

interface RecipeInfo {
    id: string
    name: string
    description: string | null
    difficulty: string
    image_url: string | null
}

const props = defineProps<{
    show: boolean
    players: Player[]
}>()

const emit = defineEmits<{
    close: []
    submit: [recipeId: string, playerId: string]
}>()

const selectedRecipeId = ref('')
const selectedPlayerId = ref('')
const recipes = ref<RecipeInfo[]>([])
const loading = ref(false)

// Load recipes
async function loadRecipes() {
    loading.value = true
    try {
        const { data, error } = await supabase
            .from('recipes')
            .select('id, name, description, difficulty, image_url')
            .order('name')
        
        if (error) throw error
        recipes.value = data || []
    } catch (error) {
        console.error('Error loading recipes:', error)
    }
    loading.value = false
}

// Reset when modal opens
watch(() => props.show, async (show) => {
    if (show) {
        selectedRecipeId.value = ''
        selectedPlayerId.value = ''
        await loadRecipes()
    }
})

// Filter only active players
const activePlayers = computed(() => {
    return props.players.filter(p => p.status !== 'die' && p.status !== 'hide')
})

// Selected recipe details
const selectedRecipe = computed(() => {
    return recipes.value.find(r => r.id === selectedRecipeId.value)
})

// Selected player details
const selectedPlayer = computed(() => {
    return props.players.find(p => p.id === selectedPlayerId.value)
})

// Form is valid
const isValid = computed(() => {
    return selectedRecipeId.value !== '' && selectedPlayerId.value !== ''
})

function handleSubmit() {
    if (!isValid.value) return
    emit('submit', selectedRecipeId.value, selectedPlayerId.value)
}
</script>

<template>
    <BaseModal 
        :show="show" 
        title="📜 มอบสูตรยา"
        size="md"
        @close="emit('close')"
    >
        <div class="space-y-4">
            <!-- Loading -->
            <div v-if="loading" class="text-center py-8">
                <div class="text-3xl animate-spin">⏳</div>
                <p class="text-gray-400 mt-2">กำลังโหลดสูตรยา...</p>
            </div>

            <template v-else>
                <!-- Recipe Selection -->
                <div>
                    <label class="block text-sm text-gray-400 mb-2">เลือกสูตรยาที่จะมอบ</label>
                    <select 
                        v-model="selectedRecipeId"
                        class="input-vic"
                    >
                        <option value="">-- เลือกสูตรยา --</option>
                        <option 
                            v-for="recipe in recipes" 
                            :key="recipe.id" 
                            :value="recipe.id"
                        >
                            {{ recipe.name }}
                        </option>
                    </select>
                </div>

                <!-- Selected Recipe Preview -->
                <div 
                    v-if="selectedRecipe"
                    class="p-3 bg-purple-900/20 border border-purple-600 rounded-lg"
                >
                    <div class="flex items-center gap-3">
                        <div class="w-12 h-12 rounded-lg overflow-hidden bg-gray-800">
                            <img 
                                v-if="selectedRecipe.image_url"
                                :src="selectedRecipe.image_url"
                                :alt="selectedRecipe.name"
                                class="w-full h-full object-cover"
                            />
                            <div v-else class="w-full h-full flex items-center justify-center text-2xl">
                                📜
                            </div>
                        </div>
                        <div>
                            <div class="text-purple-300 font-bold">{{ selectedRecipe.name }}</div>
                            <div class="text-xs text-gray-400">{{ selectedRecipe.description }}</div>
                        </div>
                    </div>
                </div>

                <!-- Player Selection -->
                <div>
                    <label class="block text-sm text-gray-400 mb-2">เลือกผู้เล่นที่จะได้รับ</label>
                    <select 
                        v-model="selectedPlayerId"
                        class="input-vic"
                    >
                        <option value="">-- เลือกผู้เล่น --</option>
                        <option 
                            v-for="player in activePlayers" 
                            :key="player.id" 
                            :value="player.id"
                        >
                            {{ player.character_name }} ({{ player.name }})
                        </option>
                    </select>
                </div>

                <!-- Selected Player Preview -->
                <div 
                    v-if="selectedPlayer"
                    class="p-3 bg-green-900/20 border border-green-600 rounded-lg"
                >
                    <div class="flex items-center gap-3">
                        <div class="w-12 h-12 rounded-full overflow-hidden bg-gray-800">
                            <img 
                                v-if="selectedPlayer.character_img_url"
                                :src="selectedPlayer.character_img_url"
                                :alt="selectedPlayer.character_name"
                                class="w-full h-full object-cover"
                            />
                            <div v-else class="w-full h-full flex items-center justify-center text-2xl">
                                👤
                            </div>
                        </div>
                        <div>
                            <div class="text-green-300 font-bold">{{ selectedPlayer.character_name }}</div>
                            <div class="text-xs text-gray-400">{{ selectedPlayer.name }}</div>
                        </div>
                    </div>
                </div>

                <!-- Summary -->
                <div 
                    v-if="isValid"
                    class="p-4 bg-vic-gold/10 border border-vic-gold rounded-lg text-center"
                >
                    <p class="text-vic-cream">
                        จะมอบ <strong class="text-purple-300">{{ selectedRecipe?.name }}</strong><br/>
                        ให้กับ <strong class="text-green-300">{{ selectedPlayer?.character_name }}</strong>
                    </p>
                </div>
            </template>
        </div>

        <template #footer>
            <div class="flex gap-3">
                <button
                    @click="emit('close')"
                    class="flex-1 py-2 bg-gray-700 hover:bg-gray-600 text-gray-200 rounded-lg transition"
                >
                    ยกเลิก
                </button>
                <button
                    @click="handleSubmit"
                    class="flex-1 py-2 btn-gold"
                    :disabled="!isValid"
                >
                    📜 มอบสูตรยา
                </button>
            </div>
        </template>
    </BaseModal>
</template>
