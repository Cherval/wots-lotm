<template>
  <!-- Modal: Character Full Detail (เหมือน old-version) -->
  <div v-if="show" class="fixed inset-0 bg-black/90 z-[70] flex justify-center items-center p-4 backdrop-blur-md" @click.self="$emit('close')">
    <div class="bg-vic-darkbrown w-full max-w-4xl rounded border-2 border-vic-gold shadow-2xl flex flex-col md:flex-row relative animate-slide-up my-auto max-h-[90vh]">
      <button @click="$emit('close')" class="absolute top-4 right-4 text-vic-gold hover:text-white z-10 text-2xl">✕</button>

      <div v-if="character" class="w-full md:w-1/3 p-6 border-b md:border-b-0 md:border-r border-vic-brown bg-black/20 text-center flex flex-col">
        <!-- Character Image -->
        <img :src="character.character_img_url || character.img_url" :alt="characterName" class="w-full h-80 object-cover border-4 border-vic-gold rounded shadow-lg mb-6 mx-auto">
        
        <!-- Combat Stats -->
        <div class="space-y-3">
          <!-- HP -->
          <div class="bg-red-900/20 p-3 rounded border border-red-900/50">
            <div class="text-[10px] text-red-400 uppercase font-bold tracking-widest mb-1">Health Points</div>
            <div class="text-3xl font-bold text-red-500 font-serif">{{ character.hp || 0 }}</div>
          </div>

          <!-- ATK -->
          <div class="bg-orange-900/20 p-3 rounded border border-orange-900/50">
            <div class="text-[10px] text-orange-400 uppercase font-bold tracking-widest mb-1">Attack Power</div>
            <div class="text-3xl font-bold text-orange-500 font-serif">{{ character.atk || 0 }}</div>
          </div>

          <!-- AC -->
          <div class="bg-blue-900/20 p-3 rounded border border-blue-900/50">
            <div class="text-[10px] text-blue-400 uppercase font-bold tracking-widest mb-1">Armor Class</div>
            <div class="text-3xl font-bold text-blue-300 font-serif">{{ character.ac || 10 }}</div>
          </div>
        </div>
      </div>

      <!-- Right Panel: Character Info -->
      <div v-if="character" class="w-full md:w-2/3 p-8 overflow-y-auto custom-scroll">
        <!-- Character Name -->
        <h2 class="text-4xl text-vic-gold font-bold mb-1 font-serif">{{ characterName }}</h2>
        <p class="text-gray-400 italic mb-6 border-b border-vic-brown pb-2">
          {{ character.nationality || '-' }} | {{ character.sex || '-' }} | {{ character.pathways || '-' }}
        </p>

        <!-- Stats Grid -->
        <div class="grid grid-cols-3 md:grid-cols-6 gap-2 mb-6">
          <div v-for="stat in statsConfig" :key="stat.key" class="bg-neutral-800 p-2 rounded border border-vic-brown text-center">
            <div class="text-[10px] text-gray-400 uppercase">{{ stat.label }}</div>
            <div class="text-lg font-bold text-white">{{ character[stat.key] || 10 }}</div>
            <div class="text-xs font-bold" :class="(character[stat.mod] || 0) >= 0 ? 'text-green-400' : 'text-red-400'">
              {{ (character[stat.mod] || 0) >= 0 ? '+' : '' }}{{ character[stat.mod] || 0 }}
            </div>
          </div>
        </div>

        <!-- Skills Section -->
        <h3 class="text-lg text-vic-gold border-b border-vic-gold mb-3 font-bold uppercase tracking-widest">Skills</h3>
        <div class="grid grid-cols-2 gap-x-6 gap-y-2 text-sm">
          <div v-for="(val, key) in skills" :key="key" class="flex justify-between border-b border-white/10 py-1">
            <span class="text-gray-300">{{ skillLabels[key as string] || key }}</span>
            <span class="font-bold" :class="val > 0 ? 'text-green-400' : 'text-gray-600'">{{ val > 0 ? '+' : ''}}{{ val }}</span>
          </div>
        </div>

        <!-- Enemy Badge -->
        <div v-if="character.is_enemy" class="mt-6 text-center">
          <span class="inline-block px-4 py-2 rounded-full text-sm font-bold bg-red-900/50 text-red-300 border border-red-500">
            ⚔️ ศัตรู
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { supabase } from '../../lib/supabase'

interface Props {
  show: boolean
  character: any | null
  currentUserId?: string
}

const props = defineProps<Props>()

defineEmits<{
  close: []
}>()

// Stats configuration (เหมือน old-version)
const statsConfig = [
  { label: 'STR', key: 'str', mod: 'str_mod' },
  { label: 'AGI', key: 'agi', mod: 'agi_mod' },
  { label: 'INT', key: 'int_stat', mod: 'int_mod' },
  { label: 'DEX', key: 'dex', mod: 'dex_mod' },
  { label: 'CON', key: 'con', mod: 'con_mod' },
  { label: 'WIS', key: 'wis', mod: 'wis_mod' },
  { label: 'CHA', key: 'cha', mod: 'cha_mod' }
]

// Skill labels (เหมือน old-version)
const skillLabels: Record<string, string> = {
  athletics: 'Athletics (กรีฑา)',
  acrobatics: 'Acrobatics (กายกรรม)',
  sleight_of_hand: 'Sleight of Hand (มือไว)',
  stealth: 'Stealth (ลอบเร้น)',
  arcana: 'Arcana (เวทมนตร์)',
  history: 'History (ประวัติศาสตร์)',
  investigation: 'Investigation (สืบสวน)',
  nature: 'Nature (ธรรมชาติ)',
  religion: 'Religion (ศาสนา)',
  animal_handling: 'Animal Handling (คุมสัตว์)',
  insight: 'Insight (หยั่งรู้)',
  medicine: 'Medicine (การแพทย์)',
  perception: 'Perception (การรับรู้)',
  survival: 'Survival (เอาตัวรอด)',
  deception: 'Deception (หลอกลวง)',
  intimidation: 'Intimidation (ข่มขู่)',
  performance: 'Performance (การแสดง)',
  persuasion: 'Persuasion (ชักจูง)'
}

// Skills data
const skills = ref<Record<string, number>>({})

const characterName = computed(() => {
  return props.character?.name || props.character?.character_name || 'Unknown'
})

// Fetch skills when character changes (เหมือน showFullDetail ใน old-version)
watch(() => props.character, async (char) => {
  if (!char) {
    skills.value = {}
    return
  }
  
  const table = char.is_enemy ? 'enemy_skills' : 'player_skills'
  const idCol = char.is_enemy ? 'enemy_id' : 'player_id'

  const { data } = await supabase.from(table)
    .select('*')
    .eq(idCol, char.id)
    .single()

  if (data) {
    const { [idCol]: _, id, ...skillsData } = data
    skills.value = skillsData
  } else {
    skills.value = {}
  }
}, { immediate: true })
</script>
