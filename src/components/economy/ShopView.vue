<script setup lang="ts">
/**
 * ShopView.vue
 * Shop/store view component with categories and search
 */
import { ref, computed } from 'vue'
import type { Item, Player } from '@/lib/constants'
import { SHOP_CATEGORIES } from '@/lib/constants'

const props = defineProps<{
    currentUser: Player
    shopList: Item[]
    isAdmin: boolean
    gridSpaceInfo?: { cells: number; total: number }
}>()

const emit = defineEmits<{
    addItem: []
    editItem: [item: Item]
    deleteItem: [itemId: string]
    buyItem: [item: Item]
    grantRecipe: []
}>()

// Current category tab
const currentCategory = ref<string>('wizard_guild')

// Search query per category
const searchQueries = ref<Record<string, string>>({
    wizard_guild: '',
    market: '',
    mysterious: ''
})

// Current search query
const currentSearch = computed({
    get: () => searchQueries.value[currentCategory.value] || '',
    set: (val) => { searchQueries.value[currentCategory.value] = val }
})

// Get default category based on item type
function getDefaultCategory(item: Item): string {
    switch (item.type) {
        case 'equipment':
            return 'wizard_guild'
        case 'material':
        case 'consumable':
            return 'market'
        default:
            return 'mysterious'
    }
}

// Filter items by category
const categorizedItems = computed(() => {
    const categoryMap: Record<string, Item[]> = {
        wizard_guild: [],
        market: [],
        mysterious: []
    }
    
    props.shopList.forEach(item => {
        // Hide recipe items from shop (they are granted by admin)
        if (item.type === 'recipe') return
        
        const category = item.shop_category || getDefaultCategory(item)
        if (categoryMap[category]) {
            categoryMap[category].push(item)
        } else {
            categoryMap.mysterious.push(item) // fallback
        }
    })
    
    return categoryMap
})

// Filter items by search
const filteredItems = computed(() => {
    const items = categorizedItems.value[currentCategory.value] || []
    const query = currentSearch.value.toLowerCase().trim()
    
    if (!query) return items
    
    return items.filter(item => 
        item.name.toLowerCase().includes(query) ||
        item.description.toLowerCase().includes(query) ||
        item.type.toLowerCase().includes(query)
    )
})

// Get item count for each category
const categoryCounts = computed(() => {
    return {
        wizard_guild: categorizedItems.value.wizard_guild.length,
        market: categorizedItems.value.market.length,
        mysterious: categorizedItems.value.mysterious.length
    }
})

// Check if item can fit in grid
function canFitInGrid(item: Item): boolean {
    if (item.type !== 'equipment') return true
    if (!props.gridSpaceInfo) return true
    
    const itemSize = (item.grid_width || 1) * (item.grid_height || 1)
    return props.gridSpaceInfo.cells >= itemSize
}

// Handle buy button click
function handleBuyClick(item: Item) {
    emit('buyItem', item)
}

// Get buy button state
function getBuyButtonState(item: Item): { disabled: boolean; text: string; class: string } {
    if (props.currentUser.money < item.price_buy) {
        return { 
            disabled: true, 
            text: 'เงินไม่พอ', 
            class: 'bg-gray-700 text-gray-500 cursor-not-allowed border-gray-600' 
        }
    }
    
    if (item.type === 'equipment' && !canFitInGrid(item)) {
        return { 
            disabled: true,
            text: '📦 กระเป๋าเต็ม!', 
            class: 'bg-red-900 text-red-300 cursor-not-allowed border-red-700' 
        }
    }
    
    return { 
        disabled: false, 
        text: 'ซื้อเลย', 
        class: 'bg-green-700 hover:bg-green-600 text-white border-green-500' 
    }
}
</script>

<template>
    <div class="animate-fade-in">
        <!-- Header -->
        <div class="flex justify-between items-center mb-6 bg-vic-darkbrown p-4 rounded border border-vic-brown">
            <div>
                <h2 class="text-2xl text-vic-gold font-bold font-serif">🏪 ร้านค้า</h2>
                <div class="flex gap-4 mt-1">
                    <p class="text-xs text-gray-400">
                        เงินคงเหลือ: 
                        <span class="text-yellow-500 font-bold text-lg">฿{{ currentUser.money }}</span>
                    </p>
                    <p v-if="gridSpaceInfo" class="text-xs text-gray-400">
                        พื้นที่กระเป๋า: 
                        <span :class="gridSpaceInfo.cells > 0 ? 'text-green-400' : 'text-red-400'" class="font-bold">
                            {{ gridSpaceInfo.cells }}/{{ gridSpaceInfo.total }}
                        </span>
                        <span class="text-gray-500">ช่อง</span>
                    </p>
                </div>
            </div>
            <div v-if="isAdmin" class="flex gap-2">
                <button 
                    @click="emit('grantRecipe')" 
                    class="px-4 py-2 bg-purple-800 hover:bg-purple-700 text-purple-100 rounded border border-purple-500 text-sm font-bold flex items-center gap-2"
                >
                    📜 มอบสูตรยา
                </button>
                <button 
                    @click="emit('addItem')" 
                    class="btn-gold text-sm"
                >
                    + เพิ่มสินค้า
                </button>
            </div>
        </div>

        <!-- Category Tabs -->
        <div class="flex gap-2 mb-4 overflow-x-auto pb-2">
            <button
                v-for="cat in SHOP_CATEGORIES"
                :key="cat.key"
                @click="currentCategory = cat.key"
                class="flex items-center gap-2 px-4 py-3 rounded-lg border-2 transition whitespace-nowrap"
                :class="{
                    'bg-vic-gold/20 border-vic-gold text-vic-gold': currentCategory === cat.key,
                    'bg-black/40 border-gray-700 text-gray-400 hover:border-gray-500': currentCategory !== cat.key
                }"
            >
                <span class="text-lg">{{ cat.label.split(' ')[0] }}</span>
                <span class="font-bold">{{ cat.label.split(' ').slice(1).join(' ') }}</span>
                <span class="text-xs px-2 py-0.5 rounded-full bg-black/40">
                    {{ categoryCounts[cat.key as keyof typeof categoryCounts] }}
                </span>
            </button>
        </div>

        <!-- Category Description -->
        <div class="mb-4 text-sm text-gray-400">
            {{ SHOP_CATEGORIES.find(c => c.key === currentCategory)?.description }}
        </div>

        <!-- Search Bar -->
        <div class="mb-6 relative">
            <input
                v-model="currentSearch"
                type="text"
                placeholder="🔍 ค้นหาสินค้า..."
                class="input-vic w-full md:w-96 pl-4"
            />
            <button
                v-if="currentSearch"
                @click="currentSearch = ''"
                class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-white"
            >
                ✕
            </button>
        </div>

        <!-- Empty State -->
        <div 
            v-if="filteredItems.length === 0"
            class="text-center py-12 bg-black/20 rounded-lg border border-gray-800"
        >
            <div class="text-4xl mb-3">
                {{ currentSearch ? '🔍' : '📦' }}
            </div>
            <p class="text-gray-400">
                {{ currentSearch ? 'ไม่พบสินค้าที่ค้นหา' : 'ไม่มีสินค้าในหมวดนี้' }}
            </p>
        </div>

        <!-- Shop Grid -->
        <div 
            v-else
            class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6"
        >
            <div 
                v-for="item in filteredItems" 
                :key="item.id" 
                class="bg-black border border-vic-gold/30 rounded overflow-hidden hover:shadow-[0_0_15px_rgba(212,175,55,0.3)] transition flex flex-col group relative"
            >
                <!-- Admin Actions -->
                <div 
                    v-if="isAdmin" 
                    class="absolute top-2 left-2 z-20 flex gap-1 opacity-0 group-hover:opacity-100 transition"
                >
                    <button 
                        @click="emit('editItem', item)" 
                        class="bg-blue-900 text-white text-xs px-2 py-1 rounded border border-blue-500"
                    >
                        แก้ไข
                    </button>
                    <button 
                        @click="emit('deleteItem', item.id)" 
                        class="bg-red-900 text-white text-xs px-2 py-1 rounded border border-red-500"
                    >
                        ลบ
                    </button>
                </div>

                <!-- Item Image -->
                <div class="h-40 bg-neutral-800 relative">
                    <img 
                        :src="item.image_url" 
                        class="w-full h-full object-cover opacity-80 hover:opacity-100 transition" 
                    />
                    <div class="absolute top-2 right-2 bg-black/70 text-white text-xs px-2 py-1 rounded border border-gray-600 capitalize">
                        {{ item.type }}
                    </div>
                </div>

                <!-- Item Info -->
                <div class="p-4 flex-1 flex flex-col">
                    <h3 class="text-vic-gold font-bold text-lg mb-1">{{ item.name }}</h3>
                    <p class="text-xs text-gray-400 mb-2 flex-1">{{ item.description }}</p>
                    
                    <!-- Grid Size Info for Equipment -->
                    <div v-if="item.type === 'equipment'" class="mb-2 text-xs text-gray-500 flex items-center gap-2">
                        <span>📦 ขนาด: {{ item.grid_width || 1 }}×{{ item.grid_height || 1 }}</span>
                        <span v-if="item.slot_type" class="px-1.5 py-0.5 bg-purple-900/50 rounded text-purple-300 capitalize">
                            {{ item.slot_type }}
                        </span>
                    </div>

                    <!-- Price & Buy Button -->
                    <div class="flex justify-between items-center mt-2 pt-2 border-t border-gray-800">
                        <div class="text-yellow-500 font-bold text-xl">฿{{ item.price_buy }}</div>
                        <button 
                            @click="handleBuyClick(item)" 
                            :disabled="getBuyButtonState(item).disabled"
                            :class="getBuyButtonState(item).class"
                            class="px-4 py-1.5 rounded font-bold text-sm border shadow"
                        >
                            {{ getBuyButtonState(item).text }}
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
