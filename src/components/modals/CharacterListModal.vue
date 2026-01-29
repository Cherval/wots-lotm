<script setup>
import { defineProps, defineEmits } from 'vue';

const props = defineProps({
  characters: {
    type: Array,
    required: true
  }
});

const emit = defineEmits(['close', 'selectCharacter']);

const selectCharacter = (character) => {
  emit('selectCharacter', character);
};
</script>

<template>
  <div class="fixed inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center z-[80]" @click="emit('close')">
    <div class="bg-vic-darkbrown border-2 border-vic-gold rounded-lg p-6 max-w-md w-full mx-4 shadow-2xl" @click.stop>
      <div class="flex justify-between items-center mb-4">
        <h3 class="text-xl font-bold text-vic-gold font-serif">📍 ตัวละครในพื้นที่นี้</h3>
        <button @click="emit('close')" class="text-vic-gold hover:text-vic-cream transition-colors">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <div class="space-y-2 max-h-96 overflow-y-auto">
        <div
          v-for="char in characters"
          :key="char.id"
          @click="selectCharacter(char)"
          class="p-4 bg-vic-darkbrown hover:bg-vic-brown border border-vic-gold/30 hover:border-vic-gold rounded-lg cursor-pointer transition-all group"
        >
          <div class="flex items-center gap-4">
            <!-- Character Avatar -->
            <img 
              :src="char.character_img_url || char.img_url" 
              :alt="char.character_name || char.name"
              class="w-14 h-14 rounded-full border-2 border-vic-gold object-cover flex-shrink-0"
              :class="{ 'border-red-500 shadow-[0_0_10px_rgba(239,68,68,0.5)]': char.is_enemy }"
            />
            <div class="flex-1 min-w-0">
              <h4 class="text-vic-gold font-semibold text-lg group-hover:text-vic-cream transition-colors truncate">
                {{ char.character_name || char.name }}
              </h4>
              <div class="flex items-center gap-2 mt-1 text-sm text-vic-cream/70">
                <span v-if="char.pathways" class="truncate">{{ char.pathways }}</span>
                <span v-if="char.sequence !== undefined" class="text-xs bg-vic-gold/20 px-2 py-0.5 rounded">Seq {{ char.sequence }}</span>
                <span v-if="char.is_enemy" class="text-xs bg-red-900/50 text-red-300 px-2 py-0.5 rounded border border-red-500">ศัตรู</span>
              </div>
              <div class="flex items-center gap-3 mt-2 text-xs">
                <span class="text-red-400">❤️ {{ char.hp || 0 }}</span>
                <span class="text-orange-400">⚔️ {{ char.atk || 0 }}</span>
                <span class="text-blue-400">🛡️ {{ char.ac || 10 }}</span>
              </div>
            </div>
            <svg class="w-5 h-5 text-vic-gold/50 group-hover:text-vic-gold transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
