<template>
  <!-- Modal: Map Configuration (Create/Edit) -->
  <div v-if="show" class="fixed inset-0 bg-black/95 z-[150] flex items-center justify-center p-4 backdrop-blur-md" @click.self="$emit('close')">
    <div class="bg-vic-darkbrown w-full max-w-lg rounded border-2 border-vic-gold shadow-2xl flex flex-col relative animate-slide-up">
      
      <!-- Header -->
      <div class="p-4 border-b border-gray-700 flex justify-between items-center bg-black/20">
        <h3 class="text-xl text-vic-gold font-bold font-serif">
          {{ isEdit ? '✏️ แก้ไขแผนที่' : '🗺️ สร้างแผนที่ใหม่' }}
        </h3>
        <button @click="$emit('close')" class="text-gray-400 hover:text-white transition text-2xl">✕</button>
      </div>
      
      <!-- Content -->
      <div class="p-6 space-y-4">
        <!-- Map Name -->
        <div>
          <label class="text-xs text-gray-400 block mb-1 uppercase font-bold">ชื่อแผนที่ *</label>
          <input 
            v-model="form.name" 
            type="text"
            placeholder="เช่น เมืองบาคเลเบิร์ก"
            class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-vic-gold outline-none"
          />
        </div>

        <!-- Image URL -->
        <div>
          <label class="text-xs text-gray-400 block mb-1 uppercase font-bold">URL รูปภาพแผนที่ *</label>
          <input 
            v-model="form.image_url" 
            type="text"
            placeholder="https://example.com/map.jpg"
            class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-vic-gold outline-none"
          />
        </div>

        <!-- Image Preview -->
        <div v-if="form.image_url" class="border border-vic-brown rounded overflow-hidden">
          <img 
            :src="form.image_url" 
            alt="Preview" 
            class="w-full h-40 object-cover opacity-80"
            @error="handleImageError"
          />
        </div>

        <!-- Description -->
        <div>
          <label class="text-xs text-gray-400 block mb-1 uppercase font-bold">รายละเอียด</label>
          <textarea 
            v-model="form.description" 
            rows="3"
            placeholder="รายละเอียดเกี่ยวกับแผนที่..."
            class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-vic-gold outline-none resize-none"
          ></textarea>
        </div>
      </div>

      <!-- Footer -->
      <div class="p-4 border-t border-gray-700 bg-black/20 flex justify-end gap-3">
        <button 
          @click="$emit('close')" 
          class="text-gray-400 px-6 hover:text-white transition uppercase text-xs font-bold"
        >
          ยกเลิก
        </button>
        <button 
          @click="handleSubmit" 
          :disabled="loading || !isValid"
          class="bg-vic-gold hover:bg-white text-black font-bold px-8 py-2 rounded uppercase text-xs tracking-widest disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
        >
          <svg v-if="loading" class="animate-spin h-4 w-4" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          {{ loading ? 'กำลังบันทึก...' : (isEdit ? 'บันทึกการแก้ไข' : 'สร้างแผนที่') }}
        </button>
      </div>

    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, computed } from 'vue'

interface MapForm {
  id?: string
  name: string
  description: string
  image_url: string
}

interface Props {
  show: boolean
  map?: MapForm | null
  loading?: boolean
}

const props = defineProps<Props>()

const emit = defineEmits<{
  close: []
  submit: [form: MapForm]
}>()

const form = ref<MapForm>({
  name: '',
  description: '',
  image_url: ''
})

const isEdit = computed(() => !!form.value.id)
const isValid = computed(() => form.value.name.trim() && form.value.image_url.trim())

// Watch for map prop changes to populate form
watch(() => props.map, (newMap) => {
  if (newMap) {
    form.value = { ...newMap }
  } else {
    form.value = {
      name: '',
      description: '',
      image_url: ''
    }
  }
}, { immediate: true })

// Reset form when modal opens
watch(() => props.show, (newVal) => {
  if (newVal && !props.map) {
    form.value = {
      name: '',
      description: '',
      image_url: ''
    }
  }
})

function handleSubmit() {
  if (isValid.value) {
    emit('submit', { ...form.value })
  }
}

function handleImageError(e: Event) {
  const img = e.target as HTMLImageElement
  img.src = 'https://placehold.co/400x200/2a2a2a/d4a574?text=Invalid+Image'
}
</script>
