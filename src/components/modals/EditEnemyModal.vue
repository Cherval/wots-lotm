<template>
  <div v-if="show" class="fixed inset-0 bg-black/80 backdrop-blur-sm z-[100] flex items-center justify-center p-4">
    <div class="bg-vic-darkbrown border-2 border-red-500 rounded-lg w-full max-w-2xl max-h-[90vh] overflow-y-auto">
      <!-- Header -->
      <div class="flex justify-between items-center p-6 border-b border-red-500">
        <h2 class="text-2xl font-bold text-red-400 font-serif">⚔️ แก้ไขข้อมูลศัตรู</h2>
        <button @click="$emit('close')" class="text-red-400 hover:text-white text-2xl">✕</button>
      </div>

      <!-- Form -->
      <form v-if="enemy" @submit.prevent="submitEdit" class="p-6 space-y-6">
        <!-- Character Name -->
        <div>
          <label class="block text-red-400 text-sm font-semibold mb-2">ชื่อศัตรู</label>
          <input 
            v-model="formData.character_name"
            type="text" 
            class="w-full bg-black/50 border border-red-900 rounded px-4 py-2 text-vic-cream focus:border-red-500"
            required
          />
        </div>

        <!-- Pathway & Sequence -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-red-400 text-sm font-semibold mb-2">Pathway</label>
            <input 
              v-model="formData.pathways"
              type="text" 
              class="w-full bg-black/50 border border-red-900 rounded px-4 py-2 text-vic-cream focus:border-red-500"
            />
          </div>
          <div>
            <label class="block text-red-400 text-sm font-semibold mb-2">Sequence</label>
            <input 
              v-model.number="formData.sequence"
              type="number" 
              class="w-full bg-black/50 border border-red-900 rounded px-4 py-2 text-vic-cream focus:border-red-500"
            />
          </div>
        </div>

        <!-- Personal Info -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-red-400 text-sm font-semibold mb-2">สัญชาติ</label>
            <input 
              v-model="formData.nationality"
              type="text" 
              class="w-full bg-black/50 border border-red-900 rounded px-4 py-2 text-vic-cream focus:border-red-500"
            />
          </div>
          <div>
            <label class="block text-red-400 text-sm font-semibold mb-2">เพศ</label>
            <select 
              v-model="formData.sex"
              class="w-full bg-black/50 border border-red-900 rounded px-4 py-2 text-vic-cream focus:border-red-500"
            >
              <option value="">เลือกเพศ</option>
              <option value="Male">ชาย</option>
              <option value="Female">หญิง</option>
              <option value="Other">อื่นๆ</option>
            </select>
          </div>
        </div>

        <!-- Combat Stats -->
        <div class="grid grid-cols-3 gap-4">
          <div>
            <label class="block text-red-400 text-sm font-semibold mb-2">HP</label>
            <input 
              v-model.number="formData.hp"
              type="number" 
              class="w-full bg-black/50 border border-red-900 rounded px-4 py-2 text-vic-cream focus:border-red-500"
            />
          </div>
          <div>
            <label class="block text-red-400 text-sm font-semibold mb-2">ATK</label>
            <input 
              v-model.number="formData.atk"
              type="number" 
              class="w-full bg-black/50 border border-red-900 rounded px-4 py-2 text-vic-cream focus:border-red-500"
            />
          </div>
          <div>
            <label class="block text-red-400 text-sm font-semibold mb-2">AC</label>
            <input 
              v-model.number="formData.ac"
              type="number" 
              class="w-full bg-black/50 border border-red-900 rounded px-4 py-2 text-vic-cream focus:border-red-500"
            />
          </div>
        </div>

        <!-- Ability Scores -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
          <div>
            <label class="block text-red-400 text-sm font-semibold mb-2">STR</label>
            <input 
              v-model.number="formData.str"
              type="number" 
              class="w-full bg-black/50 border border-red-900 rounded px-4 py-2 text-vic-cream focus:border-red-500"
            />
          </div>
          <div>
            <label class="block text-red-400 text-sm font-semibold mb-2">AGI</label>
            <input 
              v-model.number="formData.agi"
              type="number" 
              class="w-full bg-black/50 border border-red-900 rounded px-4 py-2 text-vic-cream focus:border-red-500"
            />
          </div>
          <div>
            <label class="block text-red-400 text-sm font-semibold mb-2">INT</label>
            <input 
              v-model.number="formData.int_stat"
              type="number" 
              class="w-full bg-black/50 border border-red-900 rounded px-4 py-2 text-vic-cream focus:border-red-500"
            />
          </div>
          <div>
            <label class="block text-red-400 text-sm font-semibold mb-2">DEX</label>
            <input 
              v-model.number="formData.dex"
              type="number" 
              class="w-full bg-black/50 border border-red-900 rounded px-4 py-2 text-vic-cream focus:border-red-500"
            />
          </div>
          <div>
            <label class="block text-red-400 text-sm font-semibold mb-2">CON</label>
            <input 
              v-model.number="formData.con"
              type="number" 
              class="w-full bg-black/50 border border-red-900 rounded px-4 py-2 text-vic-cream focus:border-red-500"
            />
          </div>
          <div>
            <label class="block text-red-400 text-sm font-semibold mb-2">WIS</label>
            <input 
              v-model.number="formData.wis"
              type="number" 
              class="w-full bg-black/50 border border-red-900 rounded px-4 py-2 text-vic-cream focus:border-red-500"
            />
          </div>
          <div>
            <label class="block text-red-400 text-sm font-semibold mb-2">CHA</label>
            <input 
              v-model.number="formData.cha"
              type="number" 
              class="w-full bg-black/50 border border-red-900 rounded px-4 py-2 text-vic-cream focus:border-red-500"
            />
          </div>
        </div>

        <!-- Actions -->
        <div class="flex gap-4 pt-4 border-t border-red-900">
          <button 
            type="button"
            @click="$emit('close')" 
            class="flex-1 bg-gray-700 hover:bg-gray-600 text-white py-3 px-4 rounded font-semibold transition"
          >
            ยกเลิก
          </button>
          <button 
            type="submit" 
            :disabled="loading"
            class="flex-1 bg-red-600 hover:bg-red-700 text-white py-3 px-4 rounded font-semibold transition disabled:opacity-50"
          >
            <span v-if="loading" class="animate-spin inline-block mr-2">⚪</span>
            {{ loading ? 'กำลังบันทึก...' : 'บันทึกการแก้ไข' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import type { Enemy } from '../../lib/constants'

interface Props {
  show: boolean
  enemy: Enemy | null
}

const props = defineProps<Props>()

const emit = defineEmits<{
  close: []
  save: [enemy: Enemy]
}>()

const loading = ref(false)
const formData = ref<Partial<Enemy>>({})

// Initialize form data when enemy changes
watch(() => props.enemy, (newEnemy) => {
  if (newEnemy) {
    formData.value = { ...newEnemy }
  }
}, { immediate: true })

async function submitEdit() {
  if (!props.enemy || loading.value) return
  
  loading.value = true
  try {
    emit('save', { ...props.enemy, ...formData.value } as Enemy)
  } finally {
    loading.value = false
  }
}
</script>