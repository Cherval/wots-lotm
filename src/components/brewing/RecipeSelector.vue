<script setup lang="ts">
/**
 * RecipeSelector.vue
 * Dropdown/list for selecting recipes
 */
import type { Recipe } from '@/lib/constants'
import { DIFFICULTY_LABELS } from '@/lib/constants'

const props = defineProps<{
    recipes: Recipe[]
    selectedRecipe: Recipe | null
    isBrewing: boolean
    isAdmin: boolean
    loading: boolean
}>()

const emit = defineEmits<{
    select: [recipe: Recipe]
    edit: [recipe: Recipe]
    delete: [recipeId: string]
}>()
</script>

<template>
    <div class="recipe-selector bg-vic-darkbrown border border-vic-brown rounded-lg p-4">
        <h3 class="text-vic-gold font-bold mb-4 flex items-center gap-2">
            📜 เลือกสูตรยา
        </h3>

        <!-- Loading -->
        <div v-if="loading" class="text-center py-8">
            <div class="text-3xl animate-spin">⚗️</div>
            <p class="text-gray-400 mt-2">กำลังโหลดสูตร...</p>
        </div>

        <!-- Empty State -->
        <div 
            v-else-if="recipes.length === 0"
            class="text-center py-8 text-gray-500"
        >
            <div class="text-3xl mb-2">📖</div>
            <p>ยังไม่มีสูตรยา</p>
            <p class="text-sm">แอดมินสามารถสร้างสูตรใหม่ได้</p>
        </div>

        <!-- Recipe List -->
        <div v-else class="space-y-2 max-h-64 overflow-y-auto custom-scroll">
            <div
                v-for="recipe in recipes"
                :key="recipe.id"
                class="recipe-card group relative p-3 rounded-lg border-2 cursor-pointer transition-all"
                :class="{
                    'border-vic-gold bg-vic-gold/10': selectedRecipe?.id === recipe.id,
                    'border-gray-700 hover:border-gray-500 bg-black/20': selectedRecipe?.id !== recipe.id,
                    'opacity-50 pointer-events-none': isBrewing
                }"
                @click="emit('select', recipe)"
            >
                <div class="flex items-start gap-3">
                    <!-- Recipe Image -->
                    <div class="w-14 h-14 rounded-lg overflow-hidden bg-gray-800 shrink-0">
                        <img 
                            v-if="recipe.image_url"
                            :src="recipe.image_url"
                            :alt="recipe.name"
                            class="w-full h-full object-cover"
                        />
                        <div v-else class="w-full h-full flex items-center justify-center text-2xl">
                            🧪
                        </div>
                    </div>

                    <!-- Recipe Info -->
                    <div class="flex-1 min-w-0">
                        <div class="flex items-center gap-2">
                            <span class="font-bold text-vic-cream truncate">{{ recipe.name }}</span>
                            <span 
                                v-if="selectedRecipe?.id === recipe.id"
                                class="text-xs px-2 py-0.5 bg-vic-gold text-black rounded-full font-bold"
                            >
                                เลือกแล้ว
                            </span>
                        </div>
                        <div class="text-xs text-gray-400 mt-0.5 truncate">
                            {{ recipe.description || 'ไม่มีคำอธิบาย' }}
                        </div>
                        <div class="flex items-center gap-2 mt-1">
                            <span class="text-xs" :title="recipe.difficulty">
                                {{ DIFFICULTY_LABELS[recipe.difficulty] || recipe.difficulty }}
                            </span>
                            <span class="text-xs text-gray-500">•</span>
                            <span class="text-xs text-gray-400">
                                {{ recipe.steps?.length || 0 }} ขั้นตอน
                            </span>
                        </div>
                    </div>

                    <!-- Result Item -->
                    <div 
                        v-if="recipe.result_item"
                        class="w-10 h-10 rounded-lg overflow-hidden bg-green-900/30 border border-green-600 shrink-0"
                        :title="`ผลลัพธ์: ${recipe.result_item.name}`"
                    >
                        <img 
                            :src="recipe.result_item.image_url"
                            :alt="recipe.result_item.name"
                            class="w-full h-full object-cover"
                        />
                    </div>
                </div>

                <!-- Admin Actions -->
                <div 
                    v-if="isAdmin && !isBrewing"
                    class="absolute top-2 right-2 flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity"
                >
                    <button
                        @click.stop="emit('edit', recipe)"
                        class="p-1.5 bg-blue-900 hover:bg-blue-800 rounded text-blue-200 text-xs"
                        title="แก้ไข"
                    >
                        ✏️
                    </button>
                    <button
                        @click.stop="emit('delete', recipe.id)"
                        class="p-1.5 bg-red-900 hover:bg-red-800 rounded text-red-200 text-xs"
                        title="ลบ"
                    >
                        🗑️
                    </button>
                </div>
            </div>
        </div>

        <!-- Selected Recipe Details -->
        <div 
            v-if="selectedRecipe && !isBrewing"
            class="mt-4 p-3 bg-green-900/20 border border-green-700 rounded-lg"
        >
            <div class="flex items-center gap-2 text-green-300 text-sm">
                <span>✅</span>
                <span>เลือก <strong>{{ selectedRecipe.name }}</strong> แล้ว</span>
            </div>
            <div class="text-xs text-green-400/70 mt-1">
                กดปุ่ม "เริ่มปรุง" เพื่อเริ่มกระบวนการ
            </div>
        </div>
    </div>
</template>

<style scoped>
.recipe-card {
    transition: all 0.2s ease;
}

.recipe-card:hover:not(.pointer-events-none) {
    transform: translateX(4px);
}
</style>
