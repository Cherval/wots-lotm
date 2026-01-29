<template>
  <!-- Modal: Embed Code -->
  <div v-if="show" class="fixed inset-0 bg-black/95 z-[150] flex items-center justify-center p-4 backdrop-blur-md" @click.self="$emit('close')">
    <div class="bg-vic-darkbrown w-full max-w-xl rounded border-2 border-vic-gold shadow-2xl flex flex-col relative animate-slide-up">
      
      <!-- Header -->
      <div class="p-4 border-b border-gray-700 flex justify-between items-center bg-black/20">
        <h3 class="text-xl text-vic-gold font-bold font-serif">
          🔗 Embed Code
        </h3>
        <button @click="$emit('close')" class="text-gray-400 hover:text-white transition text-2xl">✕</button>
      </div>
      
      <!-- Content -->
      <div class="p-6 space-y-4">
        <p class="text-sm text-gray-400">
          คัดลอกโค้ดด้านล่างไปวางในเว็บไซต์หรือ Discord เพื่อแสดงการ์ดตัวละคร:
        </p>

        <!-- Character Preview -->
        <div v-if="player" class="flex items-center gap-4 bg-black/40 p-3 rounded border border-vic-brown">
          <img 
            :src="player.character_img_url" 
            :alt="player.character_name"
            class="w-16 h-16 object-cover rounded border border-vic-gold"
          />
          <div>
            <h4 class="text-vic-gold font-bold">{{ player.character_name }}</h4>
            <p class="text-xs text-gray-400">{{ player.pathways }} | Seq {{ player.sequence }}</p>
          </div>
        </div>

        <!-- Embed Code -->
        <div class="bg-black/60 p-4 rounded border border-vic-brown">
          <textarea 
            ref="codeTextarea"
            :value="embedCode"
            readonly
            rows="4"
            class="w-full bg-transparent text-xs text-green-400 font-mono resize-none outline-none"
          ></textarea>
        </div>

        <!-- Card URL -->
        <div class="bg-black/40 p-3 rounded border border-vic-brown">
          <label class="text-[10px] text-gray-400 uppercase font-bold block mb-1">Direct Link</label>
          <div class="flex items-center gap-2">
            <input 
              :value="cardUrl"
              readonly
              class="flex-1 bg-transparent text-xs text-blue-400 font-mono outline-none"
            />
            <button 
              @click="copyUrl" 
              class="text-xs bg-blue-900 text-blue-200 px-3 py-1 rounded border border-blue-700 hover:bg-blue-800"
            >
              คัดลอก URL
            </button>
          </div>
        </div>
      </div>

      <!-- Footer -->
      <div class="p-4 border-t border-gray-700 bg-black/20 flex justify-end gap-3">
        <button 
          @click="$emit('close')" 
          class="text-gray-400 px-6 hover:text-white transition uppercase text-xs font-bold"
        >
          ปิด
        </button>
        <button 
          @click="copyEmbedCode" 
          class="bg-vic-gold hover:bg-white text-black font-bold px-8 py-2 rounded uppercase text-xs tracking-widest flex items-center gap-2"
        >
          📋 คัดลอก Embed Code
        </button>
      </div>

    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { Player } from '@/lib/constants'

interface Props {
  show: boolean
  player: Player | null
}

const props = defineProps<Props>()

const emit = defineEmits<{
  close: []
  copied: [message: string]
}>()

const cardUrl = computed(() => {
  if (!props.player) return ''
  return `${window.location.origin}/card.html?id=${props.player.id}`
})

const embedCode = computed(() => {
  if (!props.player) return ''
  return `<iframe src="${cardUrl.value}" width="350" height="550" style="border:none; border-radius: 8px; overflow:hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.5);" title="${props.player.character_name}"></iframe>`
})

function copyEmbedCode() {
  navigator.clipboard.writeText(embedCode.value)
    .then(() => emit('copied', 'คัดลอก Embed Code แล้ว'))
    .catch(() => emit('copied', 'ไม่สามารถคัดลอกได้'))
}

function copyUrl() {
  navigator.clipboard.writeText(cardUrl.value)
    .then(() => emit('copied', 'คัดลอก URL แล้ว'))
    .catch(() => emit('copied', 'ไม่สามารถคัดลอกได้'))
}
</script>
