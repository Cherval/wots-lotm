<template>
  <!-- Sequence Modal (Create/Edit) -->
  <div v-if="show" class="fixed inset-0 bg-black/90 z-[120] flex items-center justify-center p-4 backdrop-blur-sm">
    <div class="bg-vic-darkbrown p-6 rounded border-2 border-green-600 w-full max-w-sm relative shadow-2xl">
      <button @click="emit('close')" class="absolute top-2 right-4 text-gray-400 hover:text-white text-xl">✕</button>
      <h3 class="text-xl text-green-400 font-bold mb-4">{{ form.id ? 'แก้ไข' : 'เพิ่ม' }} ลำดับพลัง</h3>

      <label class="text-xs text-gray-400 block mb-1">เลขลำดับ (0-9)</label>
      <input 
        type="number" 
        v-model.number="form.seq_number" 
        max="9" 
        min="0" 
        class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-green-500 outline-none mb-3" 
      />

      <label class="text-xs text-gray-400 block mb-1">ชื่ออาชีพ (Title)</label>
      <input 
        v-model="form.title" 
        placeholder="เช่น Seer, Spectator" 
        class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-green-500 outline-none mb-3" 
      />

      <label class="text-xs text-gray-400 block mb-1">ระดับพลัง</label>
      <select 
        v-model="form.rank_group" 
        class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-green-500 outline-none mb-4"
      >
        <option v-for="g in RANK_GROUPS" :key="g" :value="g">{{ g }}</option>
      </select>

      <button 
        @click="handleSubmit" 
        :disabled="loading || !form.title"
        class="w-full bg-green-700 hover:bg-green-600 text-white font-bold py-2 rounded disabled:opacity-50 disabled:cursor-not-allowed"
      >
        <span v-if="loading">กำลังบันทึก...</span>
        <span v-else>บันทึก</span>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import type { Sequence } from '@/lib/constants'

const RANK_GROUPS = [
  'Low (9-8)',
  'Mid-Low (7-6)', 
  'Mid (5-4)',
  'High (3-2)',
  'Mythical (1-0)'
]

interface Props {
  show: boolean
  sequence: Sequence | null
  pathwayId: string
  loading?: boolean
}

const props = defineProps<Props>()

const emit = defineEmits<{
  close: []
  submit: [data: { id?: string, pathway_id: string, seq_number: number, title: string, rank_group: string }]
}>()

const form = ref({
  id: '',
  pathway_id: '',
  seq_number: 9,
  title: '',
  rank_group: 'Low (9-8)'
})

watch([() => props.sequence, () => props.pathwayId], ([sequence, pathwayId]) => {
  if (sequence) {
    form.value = {
      id: sequence.id,
      pathway_id: sequence.pathway_id,
      seq_number: sequence.seq_number,
      title: sequence.title,
      rank_group: sequence.rank_group || 'Low (9-8)'
    }
  } else {
    form.value = {
      id: '',
      pathway_id: pathwayId || '',
      seq_number: 9,
      title: '',
      rank_group: 'Low (9-8)'
    }
  }
}, { immediate: true })

watch(() => props.show, (show) => {
  if (!show) {
    form.value = { id: '', pathway_id: '', seq_number: 9, title: '', rank_group: 'Low (9-8)' }
  }
})

function handleSubmit() {
  if (!form.value.title) return
  emit('submit', {
    id: form.value.id || undefined,
    pathway_id: form.value.pathway_id || props.pathwayId,
    seq_number: form.value.seq_number,
    title: form.value.title,
    rank_group: form.value.rank_group
  })
}
</script>
