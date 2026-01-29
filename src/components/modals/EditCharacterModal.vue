<template>
  <!-- Modal: Edit Character (เหมือน old-version) -->
  <div v-if="show" class="fixed inset-0 bg-black/95 z-[150] flex items-center justify-center p-4 backdrop-blur-md">
    <div class="bg-vic-darkbrown w-full max-w-2xl rounded border-2 border-blue-500 shadow-2xl flex flex-col relative animate-slide-up max-h-[90vh]">
      
      <!-- Header -->
      <div class="p-4 border-b border-gray-700 flex justify-between items-center bg-black/20">
        <h3 class="text-xl text-blue-400 font-bold font-serif">
          {{ form.id ? 'โหมดแก้ไข' : 'สร้างตัวละครใหม่' }}: {{ form.character_name }}
        </h3>
        <button @click="$emit('close')" class="text-gray-400 hover:text-white transition text-2xl">✕</button>
      </div>
      
      <!-- Tab Buttons -->
      <div class="flex bg-black/40 border-b border-gray-700 shrink-0">
        <button 
          @click="activeTab = 'general'" 
          :class="activeTab === 'general' ? 'bg-blue-900/50 text-blue-300 border-b-2 border-blue-400' : 'text-gray-400 hover:text-white'"
          class="flex-1 py-3 text-xs font-bold uppercase tracking-widest transition"
        >
          ข้อมูลทั่วไป
        </button>
        <button 
          @click="activeTab = 'stats'" 
          :class="activeTab === 'stats' ? 'bg-blue-900/50 text-blue-300 border-b-2 border-blue-400' : 'text-gray-400 hover:text-white'"
          class="flex-1 py-3 text-xs font-bold uppercase tracking-widest border-x border-gray-700 transition"
        >
          ค่าพลังหลัก
        </button>
        <button 
          @click="activeTab = 'skills'" 
          :class="activeTab === 'skills' ? 'bg-blue-900/50 text-blue-300 border-b-2 border-blue-400' : 'text-gray-400 hover:text-white'"
          class="flex-1 py-3 text-xs font-bold uppercase tracking-widest transition"
        >
          ทักษะ (Skills)
        </button>
      </div>

      <!-- Content -->
      <div class="flex-1 overflow-y-auto p-6 custom-scroll">
        
        <!-- Tab: General -->
        <div v-if="activeTab === 'general'" class="space-y-4">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="text-[10px] text-gray-400 block mb-1 uppercase">ชื่อตัวละคร</label>
              <input v-model="form.character_name" class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-blue-400 outline-none">
            </div>
            <div>
              <label class="text-[10px] text-gray-400 block mb-1 uppercase">URL รูปภาพ</label>
              <input v-model="form.character_img_url" class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-blue-400 outline-none">
            </div>
            
            <div>
              <label class="text-xs text-gray-400">เส้นทาง (Pathway)</label>
              <select v-model="form.pathways" class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-blue-400 outline-none">
                <option value="" disabled>-- เลือก --</option>
                <option v-for="path in pathways" :key="path.id" :value="path.name">{{ path.name }}</option>
              </select>
            </div>
            <div>
              <label class="text-xs text-gray-400">ลำดับ (Sequence)</label>
              <select v-model="form.sequence" class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-blue-400 outline-none" :disabled="!form.pathways">
                <option value="" disabled>-- เลือก --</option>
                <option v-for="seq in availableSequences" :key="seq.id" :value="seq.seq_number">
                  Seq {{ seq.seq_number }}: {{ seq.title }}
                </option>
              </select>
            </div>

            <div>
              <label class="text-[10px] text-gray-400 block mb-1 uppercase">สัญชาติ</label>
              <input v-model="form.nationality" class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-blue-400 outline-none">
            </div>
            <div>
              <label class="text-[10px] text-gray-400 block mb-1 uppercase">เพศ</label>
              <select v-model="form.sex" class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-blue-400 outline-none">
                <option value="">เลือกเพศ</option>
                <option value="Male">ชาย</option>
                <option value="Female">หญิง</option>
                <option value="Other">อื่นๆ</option>
              </select>
            </div>

            <div v-if="isAdmin && type === 'player'" class="col-span-full bg-blue-900/20 p-3 rounded border border-blue-500/50">
              <label class="text-xs text-blue-300 block mb-1">🔗 เชื่อมต่อผู้เล่น (Auth ID)</label>
              <div class="flex gap-2">
                <input v-model="form.auth_id" class="flex-1 bg-black/50 border border-vic-brown rounded px-3 py-2 text-xs font-mono text-blue-200 focus:border-blue-400 outline-none">
                <button @click="form.auth_id = ''" class="text-xs text-red-400 underline hover:text-red-300">ล้างค่า</button>
              </div>
            </div>

            <div v-if="type === 'player'">
              <label class="text-[10px] text-gray-400 block mb-1 uppercase">บทบาท</label>
              <select v-model="form.role" class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-blue-400 outline-none">
                <option value="player">Player</option>
                <option value="assistant">Assistant</option>
                <option value="dungeon_master">Dungeon Master</option>
              </select>
            </div>
            <div v-if="type === 'player'">
              <label class="text-[10px] text-gray-400 block mb-1 uppercase">สถานะ</label>
              <select v-model="form.status" class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-blue-400 outline-none">
                <option value="active">🟢 กำลังเล่น</option>
                <option value="hide">🟡 ซ่อนตัว</option>
                <option value="die">⚫ ตาย</option>
              </select>
            </div>

            <!-- Economy (Player only) -->
            <div v-if="type === 'player'">
              <label class="text-[10px] text-gray-400 block mb-1 uppercase">💰 เงินสด</label>
              <input v-model.number="form.money" type="number" class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-blue-400 outline-none">
            </div>
            <div v-if="type === 'player'">
              <label class="text-[10px] text-gray-400 block mb-1 uppercase">🏦 ธนาคาร</label>
              <input v-model.number="form.bank_balance" type="number" class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-blue-400 outline-none">
            </div>
          </div>
        </div>

        <!-- Tab: Stats -->
        <div v-if="activeTab === 'stats'" class="space-y-6">
          <!-- Combat Stats -->
          <div class="grid grid-cols-3 gap-3">
            <div class="bg-black/40 p-3 rounded border border-vic-brown text-center">
              <label class="text-[10px] text-red-400 block mb-1 font-bold">HP</label>
              <input v-model.number="form.hp" type="number" class="w-full bg-black/50 border border-vic-brown rounded px-2 py-2 text-center text-lg font-bold text-vic-cream focus:border-red-400 outline-none">
            </div>
            <div class="bg-black/40 p-3 rounded border border-vic-brown text-center">
              <label class="text-[10px] text-orange-400 block mb-1 font-bold">ATK</label>
              <input v-model.number="form.atk" type="number" class="w-full bg-black/50 border border-vic-brown rounded px-2 py-2 text-center text-lg font-bold text-vic-cream focus:border-orange-400 outline-none">
            </div>
            <div class="bg-black/40 p-3 rounded border border-vic-brown text-center">
              <label class="text-[10px] text-blue-400 block mb-1 font-bold">AC</label>
              <input v-model.number="form.ac" type="number" class="w-full bg-black/50 border border-vic-brown rounded px-2 py-2 text-center text-lg font-bold text-vic-cream focus:border-blue-400 outline-none">
            </div>
          </div>

          <!-- Ability Scores -->
          <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
            <div v-for="stat in statsConfig" :key="stat.key" class="bg-neutral-800 p-3 rounded border border-vic-brown flex flex-col gap-2">
              <label class="text-[11px] text-vic-gold uppercase font-bold text-center tracking-wider">{{ stat.label }}</label>
              
              <input 
                type="number" 
                v-model.number="form[stat.key]" 
                @input="calculateMod(stat)"
                class="w-full bg-black/50 border border-vic-brown rounded px-2 py-1 text-center text-sm font-bold text-vic-cream focus:border-vic-gold outline-none"
              >
              
              <div class="flex items-center gap-1 bg-blue-900/20 rounded border border-blue-800/40 px-2 py-1">
                <span class="text-[8px] text-blue-400 font-bold uppercase shrink-0">Mod</span>
                <input 
                  type="number" 
                  v-model.number="form[stat.mod]"
                  class="bg-transparent text-center text-xs text-blue-200 w-full outline-none font-bold"
                >
              </div>
            </div>
          </div>
        </div>

        <!-- Tab: Skills -->
        <div v-if="activeTab === 'skills'" class="grid grid-cols-2 md:grid-cols-3 gap-x-4 gap-y-2">
          <div 
            v-for="(label, key) in skillLabels" 
            :key="key" 
            class="flex justify-between items-center bg-black/20 p-2 rounded text-[10px] border border-white/5"
          >
            <span class="text-gray-400 truncate">{{ label }}</span>
            <input 
              v-model.number="formSkills[key]" 
              type="number" 
              class="w-12 bg-transparent border-b border-vic-gold text-right text-vic-gold font-bold outline-none"
            >
          </div>
        </div>

      </div>

      <!-- Footer -->
      <div class="p-4 border-t border-gray-700 bg-black/20 flex justify-end gap-3 shrink-0">
        <button 
          @click="$emit('close')" 
          class="text-gray-400 px-6 hover:text-white transition uppercase text-xs font-bold"
        >
          ยกเลิก
        </button>
        <button 
          @click="submitEdit" 
          :disabled="loading"
          class="bg-blue-700 hover:bg-blue-600 text-white border border-blue-500 px-8 py-2 rounded uppercase font-bold text-xs tracking-widest disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
        >
          <svg v-if="loading" class="animate-spin h-4 w-4" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          {{ loading ? 'กำลังบันทึก...' : 'บันทึกข้อมูล' }}
        </button>
      </div>

    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import { supabase } from '../../lib/supabase'

interface Props {
  show: boolean
  character: any
  type: 'player' | 'enemy'
  pathways: any[]
  sequences: any[]
  isAdmin?: boolean
}

const props = defineProps<Props>()

const emit = defineEmits<{
  close: []
  saved: [data: { isNew: boolean, characterName: string, characterId: string, type: string }]
}>()

// State
const loading = ref(false)
const activeTab = ref('general')
const form = ref<any>({})
const formSkills = ref<Record<string, number>>({})

// Stats Config (เหมือน old-version)
const statsConfig = [
  { label: 'STR', key: 'str', mod: 'str_mod' },
  { label: 'AGI', key: 'agi', mod: 'agi_mod' },
  { label: 'INT', key: 'int_stat', mod: 'int_mod' },
  { label: 'DEX', key: 'dex', mod: 'dex_mod' },
  { label: 'CON', key: 'con', mod: 'con_mod' },
  { label: 'WIS', key: 'wis', mod: 'wis_mod' },
  { label: 'CHA', key: 'cha', mod: 'cha_mod' }
]

// Skill Labels (เหมือน old-version)
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

// Available sequences based on selected pathway
const availableSequences = computed(() => {
  if (!form.value.pathways) return []
  const path = props.pathways.find(p => p.name === form.value.pathways)
  if (!path) return []
  return props.sequences.filter(s => s.pathway_id === path.id).sort((a, b) => b.seq_number - a.seq_number)
})

// Calculate modifier from stat value
function calculateMod(stat: any) {
  const value = form.value[stat.key] || 10
  form.value[stat.mod] = Math.floor((value - 10) / 2)
}

// Load character data and skills
watch(() => props.character, async (char) => {
  if (!char) return
  
  activeTab.value = 'general'
  form.value = { ...char }
  
  // Load skills
  const skillTable = props.type === 'player' ? 'player_skills' : 'enemy_skills'
  const idCol = props.type === 'player' ? 'player_id' : 'enemy_id'
  
  const { data } = await supabase.from(skillTable)
    .select('*')
    .eq(idCol, char.id)
    .single()
  
  if (data) {
    const { [idCol]: _, id, ...skills } = data
    formSkills.value = skills
  } else {
    // Initialize empty skills
    formSkills.value = {}
    Object.keys(skillLabels).forEach(key => {
      formSkills.value[key] = 0
    })
  }
}, { immediate: true })

// Submit edit
async function submitEdit() {
  if (loading.value) return
  loading.value = true

  try {
    const table = props.type === 'player' ? 'players' : 'enemies'
    const skillTable = props.type === 'player' ? 'player_skills' : 'enemy_skills'
    const idCol = props.type === 'player' ? 'player_id' : 'enemy_id'

    // Check if creating new or updating
    const isNewCharacter = !form.value.id

    if (isNewCharacter) {
      // Create new character
      const { id, ...createData } = form.value
      const { data: newChar, error: err1 } = await supabase.from(table)
        .insert([createData])
        .select()
        .single()

      if (err1) {
        console.error('Create error:', err1)
        alert('เกิดข้อผิดพลาด: ' + err1.message)
        loading.value = false
        return
      }

      // Create skills for new character
      const skillPayload = {
        [idCol]: newChar.id,
        ...formSkills.value
      }
      
      await supabase.from(skillTable).insert([skillPayload])
      
      emit('saved', { 
        isNew: true, 
        characterName: newChar.character_name, 
        characterId: newChar.id,
        type: props.type 
      })
      emit('close')
    } else {
      // Update existing character
      const { error: err1 } = await supabase.from(table)
        .update(form.value)
        .eq('id', form.value.id)

      // Update skills (upsert)
      const skillPayload = {
        [idCol]: form.value.id,
        ...formSkills.value
      }
      
      const { error: err2 } = await supabase.from(skillTable)
        .upsert(skillPayload, { onConflict: idCol })

      if (!err1 && !err2) {
        emit('saved', { 
          isNew: false, 
          characterName: form.value.character_name, 
          characterId: form.value.id,
          type: props.type 
        })
        emit('close')
      } else {
        console.error('Save error:', err1 || err2)
        alert('เกิดข้อผิดพลาด: ' + (err1?.message || err2?.message))
      }
    }
  } catch (error: any) {
    console.error('Submit error:', error)
    alert('เกิดข้อผิดพลาด: ' + error.message)
  } finally {
    loading.value = false
  }
}
</script>