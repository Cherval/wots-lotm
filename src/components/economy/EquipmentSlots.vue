<template>
  <div class="equipment-slots">
    <h3 class="text-vic-gold font-bold text-sm mb-3 flex items-center gap-2">
      <span>⚔️ อุปกรณ์ที่สวมใส่</span>
      <span class="text-xs text-gray-500">(ให้บัฟชั่วคราว)</span>
    </h3>
    
    <!-- Equipment Grid -->
    <div class="grid grid-cols-2 gap-3 mb-4">
      <!-- Weapon Slot -->
      <div 
        class="equipment-slot relative aspect-square rounded-lg border-2 transition-all duration-300 overflow-hidden"
        :class="getSlotClass('weapon')"
        @click="handleSlotClick('weapon')"
        @dragover.prevent
        @drop="handleSlotDrop($event, 'weapon')"
      >
        <div class="absolute inset-0 flex items-center justify-center">
          <template v-if="equippedWeapon">
            <img 
              :src="equippedWeapon.items.image_url" 
              class="w-full h-full object-cover opacity-80"
            />
            <div class="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent" />
            <div class="absolute bottom-1 inset-x-1 text-center">
              <div class="text-[10px] text-vic-gold font-bold truncate">{{ equippedWeapon.items.name }}</div>
            </div>
            <button 
              @click.stop="unequipItem(equippedWeapon)"
              class="absolute top-1 right-1 w-5 h-5 bg-red-900/90 border border-red-600 rounded-full text-red-200 text-xs hover:bg-red-800"
            >✕</button>
          </template>
          <template v-else>
            <span class="text-3xl opacity-30">⚔️</span>
          </template>
        </div>
        <div class="absolute top-1 left-1 text-[8px] px-1 py-0.5 bg-black/70 text-gray-400 rounded uppercase font-bold">
          อาวุธ
        </div>
      </div>

      <!-- Head Slot -->
      <div 
        class="equipment-slot relative aspect-square rounded-lg border-2 transition-all duration-300 overflow-hidden"
        :class="getSlotClass('head')"
        @click="handleSlotClick('head')"
        @dragover.prevent
        @drop="handleSlotDrop($event, 'head')"
      >
        <div class="absolute inset-0 flex items-center justify-center">
          <template v-if="equippedHead">
            <img 
              :src="equippedHead.items.image_url" 
              class="w-full h-full object-cover opacity-80"
            />
            <div class="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent" />
            <div class="absolute bottom-1 inset-x-1 text-center">
              <div class="text-[10px] text-vic-gold font-bold truncate">{{ equippedHead.items.name }}</div>
            </div>
            <button 
              @click.stop="unequipItem(equippedHead)"
              class="absolute top-1 right-1 w-5 h-5 bg-red-900/90 border border-red-600 rounded-full text-red-200 text-xs hover:bg-red-800"
            >✕</button>
          </template>
          <template v-else>
            <span class="text-3xl opacity-30">👑</span>
          </template>
        </div>
        <div class="absolute top-1 left-1 text-[8px] px-1 py-0.5 bg-black/70 text-gray-400 rounded uppercase font-bold">
          ศีรษะ
        </div>
      </div>

      <!-- Body Slot -->
      <div 
        class="equipment-slot relative aspect-square rounded-lg border-2 transition-all duration-300 overflow-hidden"
        :class="getSlotClass('body')"
        @click="handleSlotClick('body')"
        @dragover.prevent
        @drop="handleSlotDrop($event, 'body')"
      >
        <div class="absolute inset-0 flex items-center justify-center">
          <template v-if="equippedBody">
            <img 
              :src="equippedBody.items.image_url" 
              class="w-full h-full object-cover opacity-80"
            />
            <div class="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent" />
            <div class="absolute bottom-1 inset-x-1 text-center">
              <div class="text-[10px] text-vic-gold font-bold truncate">{{ equippedBody.items.name }}</div>
            </div>
            <button 
              @click.stop="unequipItem(equippedBody)"
              class="absolute top-1 right-1 w-5 h-5 bg-red-900/90 border border-red-600 rounded-full text-red-200 text-xs hover:bg-red-800"
            >✕</button>
          </template>
          <template v-else>
            <span class="text-3xl opacity-30">🛡️</span>
          </template>
        </div>
        <div class="absolute top-1 left-1 text-[8px] px-1 py-0.5 bg-black/70 text-gray-400 rounded uppercase font-bold">
          เกราะ
        </div>
      </div>

      <!-- Accessory Slot -->
      <div 
        class="equipment-slot relative aspect-square rounded-lg border-2 transition-all duration-300 overflow-hidden"
        :class="getSlotClass('accessory')"
        @click="handleSlotClick('accessory')"
        @dragover.prevent
        @drop="handleSlotDrop($event, 'accessory')"
      >
        <div class="absolute inset-0 flex items-center justify-center">
          <template v-if="equippedAccessory">
            <img 
              :src="equippedAccessory.items.image_url" 
              class="w-full h-full object-cover opacity-80"
            />
            <div class="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent" />
            <div class="absolute bottom-1 inset-x-1 text-center">
              <div class="text-[10px] text-vic-gold font-bold truncate">{{ equippedAccessory.items.name }}</div>
            </div>
            <button 
              @click.stop="unequipItem(equippedAccessory)"
              class="absolute top-1 right-1 w-5 h-5 bg-red-900/90 border border-red-600 rounded-full text-red-200 text-xs hover:bg-red-800"
            >✕</button>
          </template>
          <template v-else>
            <span class="text-3xl opacity-30">💍</span>
          </template>
        </div>
        <div class="absolute top-1 left-1 text-[8px] px-1 py-0.5 bg-black/70 text-gray-400 rounded uppercase font-bold">
          เครื่องประดับ
        </div>
      </div>
    </div>

    <!-- Active Buffs Display -->
    <div v-if="activeBuffs.length > 0" class="active-buffs bg-black/40 rounded-lg p-3 border border-vic-brown/50">
      <div class="text-vic-gold font-bold text-xs mb-2 flex items-center gap-2">
        <span class="text-base">✨</span>
        <span>บัฟจากอุปกรณ์</span>
      </div>
      <div class="flex flex-wrap gap-1">
        <TransitionGroup name="buff">
          <div 
            v-for="buff in activeBuffs" 
            :key="buff.key"
            class="buff-tag text-[10px] px-2 py-1 rounded-full font-bold flex items-center gap-1"
            :class="getBuffClass(buff.value)"
          >
            <span>{{ buff.label }}</span>
            <span class="text-white/80">{{ buff.value > 0 ? '+' : '' }}{{ buff.value }}</span>
          </div>
        </TransitionGroup>
      </div>
    </div>

    <!-- No Buffs Message -->
    <div v-else class="text-center text-gray-500 text-xs py-2">
      สวมใส่อุปกรณ์เพื่อรับบัฟ
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { InventoryItem } from '@/lib/constants'

interface Props {
  items: InventoryItem[]
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'equip-item': [item: InventoryItem]
  'unequip-item': [item: InventoryItem]
}>()

// Equipped items by slot
const equippedWeapon = computed(() => 
  props.items.find(i => i.is_equipped && i.items.slot_type === 'weapon')
)

const equippedHead = computed(() => 
  props.items.find(i => i.is_equipped && i.items.slot_type === 'head')
)

const equippedBody = computed(() => 
  props.items.find(i => i.is_equipped && i.items.slot_type === 'body')
)

const equippedAccessory = computed(() => 
  props.items.find(i => i.is_equipped && i.items.slot_type === 'accessory')
)

// Calculate active buffs from all equipped items
const activeBuffs = computed(() => {
  const buffs: Map<string, number> = new Map()
  
  const equippedItems = [equippedWeapon.value, equippedHead.value, equippedBody.value, equippedAccessory.value]
  
  for (const item of equippedItems) {
    if (!item?.items.effects) continue
    
    for (const [key, value] of Object.entries(item.items.effects)) {
      if (key.startsWith('buff_')) {
        const current = buffs.get(key) || 0
        buffs.set(key, current + (value as number))
      }
    }
  }
  
  return Array.from(buffs.entries())
    .filter(([_, value]) => value !== 0)
    .map(([key, value]) => ({
      key,
      label: getBuffLabel(key),
      value
    }))
})

// Get buff label
function getBuffLabel(key: string): string {
  const labels: Record<string, string> = {
    buff_str: 'STR',
    buff_agi: 'AGI',
    buff_int_stat: 'INT',
    buff_dex: 'DEX',
    buff_con: 'CON',
    buff_wis: 'WIS',
    buff_cha: 'CHA',
    buff_atk: 'ATK',
    buff_ac: 'AC',
    buff_hp: 'HP',
    buff_mp: 'MP'
  }
  return labels[key] || key.replace('buff_', '').toUpperCase()
}

// Get buff styling class
function getBuffClass(value: number): string {
  if (value > 0) return 'bg-green-900 text-green-300 border border-green-700'
  if (value < 0) return 'bg-red-900 text-red-300 border border-red-700'
  return 'bg-gray-800 text-gray-400 border border-gray-600'
}

// Get slot styling class
function getSlotClass(slotType: string): string {
  const equipped = getEquippedForSlot(slotType)
  if (equipped) {
    return 'border-green-600 bg-green-900/20 shadow-[0_0_10px_rgba(34,197,94,0.3)]'
  }
  return 'border-vic-brown/50 bg-black/40 hover:border-vic-gold/50 cursor-pointer'
}

// Get equipped item for slot
function getEquippedForSlot(slotType: string): InventoryItem | undefined {
  switch (slotType) {
    case 'weapon': return equippedWeapon.value
    case 'head': return equippedHead.value
    case 'body': return equippedBody.value
    case 'accessory': return equippedAccessory.value
    default: return undefined
  }
}

// Handle slot click
function handleSlotClick(slotType: string) {
  const equipped = getEquippedForSlot(slotType)
  if (equipped) {
    // Already equipped - could show detail or unequip
  }
}

// Handle drop on slot
function handleSlotDrop(event: DragEvent, slotType: string) {
  const itemId = event.dataTransfer?.getData('text/plain')
  if (!itemId) return
  
  const item = props.items.find(i => i.id === itemId)
  if (!item) return
  
  // Check if item matches slot type
  if (item.items.slot_type === slotType) {
    emit('equip-item', item)
  }
}

// Unequip item
function unequipItem(item: InventoryItem) {
  emit('unequip-item', item)
}
</script>

<style scoped>
.equipment-slot {
  min-height: 80px;
}

.buff-enter-active,
.buff-leave-active {
  transition: all 0.3s ease;
}

.buff-enter-from,
.buff-leave-to {
  opacity: 0;
  transform: scale(0.8) translateY(-10px);
}

.buff-tag {
  animation: pulse-glow 2s ease-in-out infinite;
}

@keyframes pulse-glow {
  0%, 100% { box-shadow: 0 0 5px currentColor; }
  50% { box-shadow: 0 0 10px currentColor; }
}
</style>
