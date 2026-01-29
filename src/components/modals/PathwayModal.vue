<template>
  <!-- Pathway Modal (Create/Edit) -->
  <div v-if="show" class="fixed inset-0 bg-black/90 z-[120] flex items-center justify-center p-4 backdrop-blur-sm">
    <div class="bg-vic-darkbrown p-6 rounded border-2 border-vic-gold w-full max-w-sm relative shadow-2xl">
      <button @click="emit('close')" class="absolute top-2 right-4 text-gray-400 hover:text-white text-xl">✕</button>
      <h3 class="text-xl text-vic-gold font-bold mb-4">{{ form.id ? 'แก้ไข' : 'เพิ่ม' }} เส้นทาง</h3>
      
      <label class="text-xs text-gray-400 block mb-1">ชื่อ Pathway</label>
      <input 
        v-model="form.name" 
        placeholder="ชื่อ Pathway" 
        class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-vic-gold outline-none mb-3" 
      />
      
      <label class="text-xs text-gray-400 block mb-1">กลุ่ม GOO (Great Old One)</label>
      <input 
        v-model="form.goo_group" 
        placeholder="กลุ่ม GOO" 
        class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-vic-gold outline-none mb-4" 
      />
      
      <button 
        @click="handleSubmit" 
        :disabled="loading || !form.name"
        class="btn-gold w-full disabled:opacity-50 disabled:cursor-not-allowed"
      >
        <span v-if="loading">กำลังบันทึก...</span>
        <span v-else>บันทึก</span>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import type { Pathway } from '@/lib/constants'

interface Props {
  show: boolean
  pathway: Pathway | null
  loading?: boolean
}

const props = defineProps<Props>()

const emit = defineEmits<{
  close: []
  submit: [data: { id?: string, name: string, goo_group: string }]
}>()

const form = ref({
  id: '',
  name: '',
  goo_group: ''
})

watch(() => props.pathway, (pathway) => {
  if (pathway) {
    form.value = {
      id: pathway.id,
      name: pathway.name,
      goo_group: pathway.goo_group || ''
    }
  } else {
    form.value = {
      id: '',
      name: '',
      goo_group: ''
    }
  }
}, { immediate: true })

watch(() => props.show, (show) => {
  if (!show) {
    form.value = { id: '', name: '', goo_group: '' }
  }
})

function handleSubmit() {
  if (!form.value.name) return
  emit('submit', {
    id: form.value.id || undefined,
    name: form.value.name,
    goo_group: form.value.goo_group
  })
}
</script>
