<template>
  <div class="animate-fade-in max-w-5xl mx-auto">
    <div class="flex justify-between items-center mb-6 bg-vic-darkbrown p-4 rounded border border-vic-brown">
      <h2 class="text-2xl text-vic-gold font-bold font-serif">✨ Pathways & Sequences</h2>
      <button @click="emit('createPathway')" class="btn-gold text-sm">+ สร้างเส้นทางใหม่</button>
    </div>

    <!-- Empty State -->
    <div v-if="pathways.length === 0" class="text-center py-20 text-gray-500 border-2 border-dashed border-gray-700 rounded-lg">
      <p class="text-xl mb-2">🌟</p>
      <p>ยังไม่มี Pathway</p>
      <button @click="emit('createPathway')" class="mt-4 text-vic-gold underline hover:text-white">สร้าง Pathway แรก</button>
    </div>

    <div v-else class="space-y-6">
      <div v-for="path in pathways" :key="path.id" class="bg-neutral-900 border border-vic-gold/30 rounded-lg overflow-hidden">
        <!-- Pathway Header -->
        <div class="p-4 bg-black/40 flex justify-between items-center border-b border-vic-gold/20">
          <div>
            <h3 class="text-xl text-vic-gold font-bold">{{ path.name }}</h3>
            <p class="text-xs text-gray-500 uppercase">{{ path.goo_group || 'Unknown Group' }}</p>
          </div>

          <div class="flex gap-2">
            <button 
              @click="emit('createSequence', path.id)" 
              class="text-xs bg-green-900 text-green-200 px-2 py-1 rounded border border-green-700 hover:bg-green-800 transition"
            >
              + เพิ่มลำดับ
            </button>
            <button 
              @click="emit('editPathway', path)" 
              class="text-xs bg-blue-900 text-blue-200 px-2 py-1 rounded border border-blue-700 hover:bg-blue-800 transition"
            >
              ✏️ แก้ไข
            </button>
            <button 
              v-if="isAdmin"
              @click="emit('deletePathway', path.id)" 
              class="text-xs bg-red-900 text-red-200 px-2 py-1 rounded border border-red-700 hover:bg-red-800 transition"
            >
              🗑️ ลบ
            </button>
          </div>
        </div>

        <!-- Sequences List -->
        <div class="p-4">
          <div v-if="filteredSequences(path.id).length === 0" class="text-center text-gray-600 text-sm italic py-4">
            ยังไม่มีข้อมูลลำดับพลัง
          </div>

          <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-2">
            <div
              v-for="seq in filteredSequences(path.id)"
              :key="seq.id"
              class="flex items-center justify-between bg-black/30 p-3 rounded border border-gray-800 hover:border-vic-gold/50 transition group"
            >
              <div class="flex items-center gap-3">
                <span 
                  class="font-bold w-8 h-8 flex items-center justify-center rounded-full text-sm"
                  :class="getSequenceColor(seq.seq_number)"
                >
                  {{ seq.seq_number }}
                </span>
                <div>
                  <span class="text-vic-cream font-bold">{{ seq.title }}</span>
                  <span class="text-[10px] text-gray-500 border border-gray-700 px-1 rounded ml-2">{{ seq.rank_group }}</span>
                </div>
              </div>

              <div class="flex gap-1 opacity-50 group-hover:opacity-100 transition">
                <button 
                  @click="emit('editSequence', path.id, seq)" 
                  class="text-gray-400 hover:text-white px-2 py-1 rounded hover:bg-white/10"
                  title="แก้ไข"
                >
                  ✏️
                </button>
                <button 
                  @click="emit('deleteSequence', seq.id)" 
                  class="text-red-400 hover:text-red-200 px-2 py-1 rounded hover:bg-red-900/30"
                  title="ลบ"
                >
                  ✕
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Pathway, Sequence } from '@/lib/constants'

interface Props {
  pathways: Pathway[]
  sequences: Sequence[]
  isAdmin?: boolean
}

const props = defineProps<Props>()

const emit = defineEmits<{
  createPathway: []
  createSequence: [pathwayId: string]
  editPathway: [pathway: Pathway]
  editSequence: [pathwayId: string, sequence: Sequence]
  deletePathway: [pathwayId: string]
  deleteSequence: [sequenceId: string]
}>()

const filteredSequences = (pathwayId: string) => {
  return props.sequences
    .filter((s: Sequence) => s.pathway_id === pathwayId)
    .sort((a, b) => b.seq_number - a.seq_number) // Sort descending (9 -> 0)
}

// Get color based on sequence number (power level)
function getSequenceColor(seqNum: number): string {
  if (seqNum >= 8) return 'bg-gray-700 text-gray-300' // Low
  if (seqNum >= 6) return 'bg-green-900 text-green-300' // Mid-Low
  if (seqNum >= 4) return 'bg-blue-900 text-blue-300' // Mid
  if (seqNum >= 2) return 'bg-purple-900 text-purple-300' // High
  return 'bg-vic-gold text-black' // Mythical (0-1)
}
</script>
