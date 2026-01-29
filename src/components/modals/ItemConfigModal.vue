<template>
  <!-- Modal: Item Configuration (Create/Edit) -->
  <div v-if="show" class="fixed inset-0 bg-black/95 z-[150] flex items-center justify-center p-4 backdrop-blur-md" @click.self="$emit('close')">
    <div class="bg-vic-darkbrown w-full max-w-2xl rounded border-2 border-vic-gold shadow-2xl flex flex-col relative animate-slide-up max-h-[90vh]">
      
      <!-- Header -->
      <div class="p-4 border-b border-gray-700 flex justify-between items-center bg-black/20">
        <h3 class="text-xl text-vic-gold font-bold font-serif">
          {{ isEdit ? '✏️ แก้ไขสินค้า' : '🛒 เพิ่มสินค้าใหม่' }}
        </h3>
        <button @click="$emit('close')" class="text-gray-400 hover:text-white transition text-2xl">✕</button>
      </div>
      
      <!-- Tabs -->
      <div class="flex bg-black/40 border-b border-gray-700 shrink-0">
        <button 
          @click="activeTab = 'general'" 
          :class="activeTab === 'general' ? 'bg-vic-gold/20 text-vic-gold border-b-2 border-vic-gold' : 'text-gray-400 hover:text-white'"
          class="flex-1 py-3 text-xs font-bold uppercase tracking-widest transition"
        >
          ข้อมูลทั่วไป
        </button>
        <button 
          @click="activeTab = 'effects'" 
          :class="activeTab === 'effects' ? 'bg-vic-gold/20 text-vic-gold border-b-2 border-vic-gold' : 'text-gray-400 hover:text-white'"
          class="flex-1 py-3 text-xs font-bold uppercase tracking-widest transition"
        >
          Effects (JSON)
        </button>
        <button 
          @click="activeTab = 'guide'" 
          :class="activeTab === 'guide' ? 'bg-vic-gold/20 text-vic-gold border-b-2 border-vic-gold' : 'text-gray-400 hover:text-white'"
          class="flex-1 py-3 text-xs font-bold uppercase tracking-widest transition"
        >
          📖 คู่มือ Effects
        </button>
      </div>

      <!-- Content -->
      <div class="flex-1 overflow-y-auto p-6 custom-scroll">
        
        <!-- Tab: General -->
        <div v-if="activeTab === 'general'" class="space-y-4">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <!-- Item Name -->
            <div class="col-span-full">
              <label class="text-xs text-gray-400 block mb-1 uppercase font-bold">ชื่อสินค้า *</label>
              <input 
                v-model="form.name" 
                type="text"
                placeholder="เช่น ยาฟื้นฟูพลัง"
                class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-vic-gold outline-none"
              />
            </div>

            <!-- Description -->
            <div class="col-span-full">
              <label class="text-xs text-gray-400 block mb-1 uppercase font-bold">รายละเอียด</label>
              <textarea 
                v-model="form.description" 
                rows="2"
                placeholder="คำอธิบายสินค้า..."
                class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-vic-gold outline-none resize-none"
              ></textarea>
            </div>

            <!-- Item Type -->
            <div>
              <label class="text-xs text-gray-400 block mb-1 uppercase font-bold">ประเภท</label>
              <select 
                v-model="form.type"
                class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-vic-gold outline-none"
              >
                <option value="consumable">🧪 Consumable (ใช้แล้วหมด)</option>
                <option value="equipment">⚔️ Equipment (อุปกรณ์)</option>
                <option value="material">📦 Material (วัตถุดิบ)</option>
                <option value="special">✨ Special (พิเศษ)</option>
              </select>
            </div>

            <!-- Slot Type (for Equipment) -->
            <div v-if="form.type === 'equipment'">
              <label class="text-xs text-gray-400 block mb-1 uppercase font-bold">ช่องอุปกรณ์</label>
              <select 
                v-model="form.slot_type"
                class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-vic-gold outline-none"
              >
                <option value="">-- ไม่ระบุ --</option>
                <option value="weapon">⚔️ อาวุธ (Weapon)</option>
                <option value="head">👑 ศีรษะ (Head)</option>
                <option value="body">🛡️ เกราะ (Body)</option>
                <option value="accessory">💍 เครื่องประดับ (Accessory)</option>
              </select>
            </div>

            <!-- Image URL -->
            <div>
              <label class="text-xs text-gray-400 block mb-1 uppercase font-bold">URL รูปภาพ</label>
              <input 
                v-model="form.image_url" 
                type="text"
                placeholder="https://example.com/item.jpg"
                class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-vic-gold outline-none"
              />
            </div>

            <!-- Grid Size (for Equipment) -->
            <div v-if="form.type === 'equipment'" class="col-span-full">
              <label class="text-xs text-gray-400 block mb-2 uppercase font-bold">📐 ขนาดในกระเป๋า (Grid)</label>
              <div class="flex gap-4 items-center">
                <div class="flex items-center gap-2">
                  <span class="text-xs text-gray-500">กว้าง:</span>
                  <select 
                    v-model.number="form.grid_width"
                    class="bg-black/50 border border-vic-brown rounded px-3 py-1.5 text-vic-cream focus:border-vic-gold outline-none text-sm"
                  >
                    <option :value="1">1 ช่อง</option>
                    <option :value="2">2 ช่อง</option>
                    <option :value="3">3 ช่อง</option>
                    <option :value="4">4 ช่อง</option>
                  </select>
                </div>
                <span class="text-gray-500">×</span>
                <div class="flex items-center gap-2">
                  <span class="text-xs text-gray-500">สูง:</span>
                  <select 
                    v-model.number="form.grid_height"
                    class="bg-black/50 border border-vic-brown rounded px-3 py-1.5 text-vic-cream focus:border-vic-gold outline-none text-sm"
                  >
                    <option :value="1">1 ช่อง</option>
                    <option :value="2">2 ช่อง</option>
                    <option :value="3">3 ช่อง</option>
                    <option :value="4">4 ช่อง</option>
                  </select>
                </div>
                <!-- Preview -->
                <div class="ml-4 flex items-center gap-2">
                  <span class="text-xs text-gray-500">ตัวอย่าง:</span>
                  <div 
                    class="grid gap-0.5"
                    :style="{ gridTemplateColumns: `repeat(${form.grid_width}, 12px)` }"
                  >
                    <div 
                      v-for="i in form.grid_width * form.grid_height" 
                      :key="i"
                      class="w-3 h-3 bg-vic-gold/80 rounded-sm border border-vic-gold"
                    ></div>
                  </div>
                </div>
              </div>
              <p class="text-[10px] text-gray-500 mt-1">ขนาดไอเทมในระบบกริด Inventory (1×1 ถึง 4×4)</p>
            </div>

            <!-- Buy Price -->
            <div>
              <label class="text-xs text-gray-400 block mb-1 uppercase font-bold">💰 ราคาซื้อ</label>
              <input 
                v-model.number="form.price_buy" 
                type="number"
                min="0"
                class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-vic-gold outline-none"
              />
            </div>

            <!-- Sell Price -->
            <div>
              <label class="text-xs text-gray-400 block mb-1 uppercase font-bold">💵 ราคาขาย</label>
              <input 
                v-model.number="form.price_sell" 
                type="number"
                min="0"
                class="w-full bg-black/50 border border-vic-brown rounded px-3 py-2 text-vic-cream focus:border-vic-gold outline-none"
              />
            </div>
          </div>

          <!-- Image Preview -->
          <div v-if="form.image_url" class="border border-vic-brown rounded overflow-hidden">
            <img 
              :src="form.image_url" 
              alt="Preview" 
              class="w-full h-32 object-cover opacity-80"
              @error="handleImageError"
            />
          </div>
        </div>

        <!-- Tab: Effects -->
        <div v-if="activeTab === 'effects'" class="space-y-4">
          <div class="bg-blue-900/20 p-3 rounded border border-blue-800/50 text-sm text-blue-200">
            <p>⚠️ Effects เป็น JSON Object ที่กำหนดผลของไอเทมเมื่อใช้งาน</p>
            <p class="text-xs text-blue-400 mt-1">ดูแท็บ "คู่มือ Effects" สำหรับตัวอย่างและคีย์ที่รองรับ</p>
          </div>

          <textarea 
            v-model="form.effects"
            rows="12"
            placeholder='{ "heal_hp": 50 }'
            class="w-full bg-black/70 border border-vic-brown rounded px-4 py-3 text-green-400 font-mono text-sm focus:border-vic-gold outline-none resize-none"
            spellcheck="false"
          ></textarea>

          <!-- JSON Validation -->
          <div v-if="effectsError" class="bg-red-900/30 p-3 rounded border border-red-700 text-sm text-red-400">
            ❌ JSON ไม่ถูกต้อง: {{ effectsError }}
          </div>
          <div v-else-if="form.effects && form.effects.trim() !== '{}'" class="bg-green-900/30 p-3 rounded border border-green-700 text-sm text-green-400">
            ✅ JSON ถูกต้อง
          </div>
        </div>

        <!-- Tab: Guide -->
        <div v-if="activeTab === 'guide'" class="space-y-4 text-sm">
          <div class="bg-vic-gold/10 p-4 rounded border border-vic-gold/30">
            <h4 class="text-vic-gold font-bold mb-2">📖 คู่มือ Effects ที่รองรับ</h4>
            <p class="text-gray-400 text-xs">Effects คือ JSON object ที่กำหนดว่าไอเทมมีผลอย่างไรเมื่อผู้เล่นใช้งาน</p>
          </div>

          <!-- Effect Keys Table -->
          <div class="bg-black/40 rounded border border-vic-brown overflow-hidden">
            <table class="w-full text-xs">
              <thead class="bg-black/60">
                <tr>
                  <th class="text-left p-2 text-vic-gold">Key</th>
                  <th class="text-left p-2 text-vic-gold">ประเภท</th>
                  <th class="text-left p-2 text-vic-gold">คำอธิบาย</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-white/5">
                <tr>
                  <td class="p-2 font-mono text-green-400">heal_hp</td>
                  <td class="p-2 text-gray-400">number</td>
                  <td class="p-2 text-gray-300">ฟื้นฟู HP ตามจำนวนที่กำหนด</td>
                </tr>
                <tr>
                  <td class="p-2 font-mono text-green-400">buff_str</td>
                  <td class="p-2 text-gray-400">number</td>
                  <td class="p-2 text-gray-300">เพิ่ม/ลด STR (Strength)</td>
                </tr>
                <tr>
                  <td class="p-2 font-mono text-green-400">buff_agi</td>
                  <td class="p-2 text-gray-400">number</td>
                  <td class="p-2 text-gray-300">เพิ่ม/ลด AGI (Agility)</td>
                </tr>
                <tr>
                  <td class="p-2 font-mono text-green-400">buff_int_stat</td>
                  <td class="p-2 text-gray-400">number</td>
                  <td class="p-2 text-gray-300">เพิ่ม/ลด INT (Intelligence)</td>
                </tr>
                <tr>
                  <td class="p-2 font-mono text-green-400">buff_dex</td>
                  <td class="p-2 text-gray-400">number</td>
                  <td class="p-2 text-gray-300">เพิ่ม/ลด DEX (Dexterity)</td>
                </tr>
                <tr>
                  <td class="p-2 font-mono text-green-400">buff_con</td>
                  <td class="p-2 text-gray-400">number</td>
                  <td class="p-2 text-gray-300">เพิ่ม/ลด CON (Constitution)</td>
                </tr>
                <tr>
                  <td class="p-2 font-mono text-green-400">buff_wis</td>
                  <td class="p-2 text-gray-400">number</td>
                  <td class="p-2 text-gray-300">เพิ่ม/ลด WIS (Wisdom)</td>
                </tr>
                <tr>
                  <td class="p-2 font-mono text-green-400">buff_cha</td>
                  <td class="p-2 text-gray-400">number</td>
                  <td class="p-2 text-gray-300">เพิ่ม/ลด CHA (Charisma)</td>
                </tr>
                <tr>
                  <td class="p-2 font-mono text-green-400">buff_atk</td>
                  <td class="p-2 text-gray-400">number</td>
                  <td class="p-2 text-gray-300">เพิ่ม/ลด ATK (Attack Power)</td>
                </tr>
                <tr>
                  <td class="p-2 font-mono text-green-400">buff_ac</td>
                  <td class="p-2 text-gray-400">number</td>
                  <td class="p-2 text-gray-300">เพิ่ม/ลด AC (Armor Class)</td>
                </tr>
                <tr>
                  <td class="p-2 font-mono text-green-400">advance_sequence</td>
                  <td class="p-2 text-gray-400">boolean</td>
                  <td class="p-2 text-gray-300">เลื่อนลำดับ Sequence (9 → 8 → ...)</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Examples -->
          <div class="space-y-3">
            <h4 class="text-vic-gold font-bold">💡 ตัวอย่างการใช้งาน:</h4>

            <!-- Example 1 -->
            <div class="bg-black/60 p-3 rounded border border-vic-brown">
              <p class="text-xs text-gray-400 mb-2">🩹 ยารักษา (ฟื้นฟู 50 HP)</p>
              <pre class="text-green-400 font-mono text-xs overflow-x-auto">{
  "heal_hp": 50
}</pre>
              <button @click="applyExample({ heal_hp: 50 })" class="mt-2 text-xs text-blue-400 hover:underline">ใช้ตัวอย่างนี้</button>
            </div>

            <!-- Example 2 -->
            <div class="bg-black/60 p-3 rounded border border-vic-brown">
              <p class="text-xs text-gray-400 mb-2">💪 ยาเพิ่มพลัง (STR +2, CON +1)</p>
              <pre class="text-green-400 font-mono text-xs overflow-x-auto">{
  "buff_str": 2,
  "buff_con": 1
}</pre>
              <button @click="applyExample({ buff_str: 2, buff_con: 1 })" class="mt-2 text-xs text-blue-400 hover:underline">ใช้ตัวอย่างนี้</button>
            </div>

            <!-- Example 3 -->
            <div class="bg-black/60 p-3 rounded border border-vic-brown">
              <p class="text-xs text-gray-400 mb-2">🧠 ยาเพิ่มสติปัญญา (INT +3, WIS +2)</p>
              <pre class="text-green-400 font-mono text-xs overflow-x-auto">{
  "buff_int_stat": 3,
  "buff_wis": 2
}</pre>
              <button @click="applyExample({ buff_int_stat: 3, buff_wis: 2 })" class="mt-2 text-xs text-blue-400 hover:underline">ใช้ตัวอย่างนี้</button>
            </div>

            <!-- Example 4 -->
            <div class="bg-black/60 p-3 rounded border border-vic-brown">
              <p class="text-xs text-gray-400 mb-2">⚔️ ยาพลังโจมตี (ATK +5, ฟื้นฟู 20 HP)</p>
              <pre class="text-green-400 font-mono text-xs overflow-x-auto">{
  "buff_atk": 5,
  "heal_hp": 20
}</pre>
              <button @click="applyExample({ buff_atk: 5, heal_hp: 20 })" class="mt-2 text-xs text-blue-400 hover:underline">ใช้ตัวอย่างนี้</button>
            </div>

            <!-- Example 5 -->
            <div class="bg-black/60 p-3 rounded border border-vic-brown">
              <p class="text-xs text-gray-400 mb-2">🛡️ โล่ป้องกัน (AC +3)</p>
              <pre class="text-green-400 font-mono text-xs overflow-x-auto">{
  "buff_ac": 3
}</pre>
              <button @click="applyExample({ buff_ac: 3 })" class="mt-2 text-xs text-blue-400 hover:underline">ใช้ตัวอย่างนี้</button>
            </div>

            <!-- Example 6 -->
            <div class="bg-black/60 p-3 rounded border border-vic-brown">
              <p class="text-xs text-gray-400 mb-2">✨ ยาเลื่อนขั้น (Advance Sequence)</p>
              <pre class="text-green-400 font-mono text-xs overflow-x-auto">{
  "advance_sequence": true
}</pre>
              <button @click="applyExample({ advance_sequence: true })" class="mt-2 text-xs text-blue-400 hover:underline">ใช้ตัวอย่างนี้</button>
            </div>

            <!-- Example 7 -->
            <div class="bg-black/60 p-3 rounded border border-vic-brown">
              <p class="text-xs text-gray-400 mb-2">🎯 ไอเทมไม่มีผล (วัตถุดิบ/สะสม)</p>
              <pre class="text-green-400 font-mono text-xs overflow-x-auto">{}</pre>
              <button @click="applyExample({})" class="mt-2 text-xs text-blue-400 hover:underline">ใช้ตัวอย่างนี้</button>
            </div>

            <!-- Equipment Section Header -->
            <div class="mt-6 pt-4 border-t border-vic-gold/30">
              <h4 class="text-vic-gold font-bold mb-2">🛡️ ตัวอย่าง Equipment (บัฟชั่วคราว)</h4>
              <p class="text-xs text-gray-500 mb-3">เมื่อสวมใส่จะได้บัฟ / เมื่อถอดออกบัฟจะหายไป</p>
            </div>

            <!-- Example 8: Weapon -->
            <div class="bg-purple-900/30 p-3 rounded border border-purple-700">
              <p class="text-xs text-gray-400 mb-2">⚔️ ดาบเหล็กกล้า (Weapon - ATK +5, STR +2)</p>
              <pre class="text-green-400 font-mono text-xs overflow-x-auto">{
  "buff_atk": 5,
  "buff_str": 2
}</pre>
              <button @click="applyExample({ buff_atk: 5, buff_str: 2 })" class="mt-2 text-xs text-blue-400 hover:underline">ใช้ตัวอย่างนี้</button>
            </div>

            <!-- Example 9: Head -->
            <div class="bg-purple-900/30 p-3 rounded border border-purple-700">
              <p class="text-xs text-gray-400 mb-2">👑 หมวกปราชญ์ (Head - INT +3, WIS +2)</p>
              <pre class="text-green-400 font-mono text-xs overflow-x-auto">{
  "buff_int_stat": 3,
  "buff_wis": 2
}</pre>
              <button @click="applyExample({ buff_int_stat: 3, buff_wis: 2 })" class="mt-2 text-xs text-blue-400 hover:underline">ใช้ตัวอย่างนี้</button>
            </div>

            <!-- Example 10: Body -->
            <div class="bg-purple-900/30 p-3 rounded border border-purple-700">
              <p class="text-xs text-gray-400 mb-2">🛡️ เกราะเหล็กหนัก (Body - AC +5, CON +3)</p>
              <pre class="text-green-400 font-mono text-xs overflow-x-auto">{
  "buff_ac": 5,
  "buff_con": 3
}</pre>
              <button @click="applyExample({ buff_ac: 5, buff_con: 3 })" class="mt-2 text-xs text-blue-400 hover:underline">ใช้ตัวอย่างนี้</button>
            </div>

            <!-- Example 11: Accessory -->
            <div class="bg-purple-900/30 p-3 rounded border border-purple-700">
              <p class="text-xs text-gray-400 mb-2">💍 แหวนเวทย์มนตร์ (Accessory - CHA +2, DEX +1)</p>
              <pre class="text-green-400 font-mono text-xs overflow-x-auto">{
  "buff_cha": 2,
  "buff_dex": 1
}</pre>
              <button @click="applyExample({ buff_cha: 2, buff_dex: 1 })" class="mt-2 text-xs text-blue-400 hover:underline">ใช้ตัวอย่างนี้</button>
            </div>
          </div>

          <!-- Grid Size Info -->
          <div class="bg-blue-900/20 p-4 rounded border border-blue-700/50 mt-4">
            <h4 class="text-blue-300 font-bold mb-2">📐 ขนาดไอเทมในกระเป๋า</h4>
            <div class="text-xs text-blue-200 space-y-1">
              <p>• <span class="text-white font-bold">1×1</span> - ไอเทมเล็ก (แหวน, ยา, เหรียญ)</p>
              <p>• <span class="text-white font-bold">2×1</span> - ไอเทมแนวนอน (มีด, กำไล)</p>
              <p>• <span class="text-white font-bold">1×2</span> - ไอเทมแนวตั้ง (คทา, ขวด)</p>
              <p>• <span class="text-white font-bold">2×2</span> - ไอเทมกลาง (โล่, หนังสือ)</p>
              <p>• <span class="text-white font-bold">2×3</span> - ไอเทมใหญ่ (ดาบยาว, ธนู)</p>
              <p>• <span class="text-white font-bold">2×4</span> - ไอเทมใหญ่มาก (หอก, ไม้พลอง)</p>
            </div>
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
          @click="handleSubmit" 
          :disabled="loading || !isValid || !!effectsError"
          class="bg-vic-gold hover:bg-white text-black font-bold px-8 py-2 rounded uppercase text-xs tracking-widest disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
        >
          <svg v-if="loading" class="animate-spin h-4 w-4" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          {{ loading ? 'กำลังบันทึก...' : (isEdit ? 'บันทึกการแก้ไข' : 'เพิ่มสินค้า') }}
        </button>
      </div>

    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import type { Item } from '@/lib/constants'

interface ItemForm {
  id?: string
  name: string
  description: string
  type: string
  slot_type: string
  grid_width: number
  grid_height: number
  price_buy: number
  price_sell: number
  image_url: string
  effects: string // JSON string
}

interface Props {
  show: boolean
  item?: Item | null
  loading?: boolean
}

const props = defineProps<Props>()

const emit = defineEmits<{
  close: []
  submit: [form: ItemForm]
}>()

const activeTab = ref('general')
const form = ref<ItemForm>({
  name: '',
  description: '',
  type: 'consumable',
  slot_type: '',
  grid_width: 1,
  grid_height: 1,
  price_buy: 0,
  price_sell: 0,
  image_url: '',
  effects: '{}'
})

const isEdit = computed(() => !!form.value.id)
const isValid = computed(() => form.value.name.trim() && form.value.price_buy >= 0)

// Validate JSON effects
const effectsError = computed(() => {
  try {
    JSON.parse(form.value.effects || '{}')
    return null
  } catch (e: any) {
    return e.message
  }
})

// Watch for item prop changes to populate form
watch(() => props.item, (newItem) => {
  if (newItem) {
    form.value = {
      id: newItem.id,
      name: newItem.name || '',
      description: newItem.description || '',
      type: newItem.type || 'consumable',
      slot_type: newItem.slot_type || '',
      grid_width: newItem.grid_width || 1,
      grid_height: newItem.grid_height || 1,
      price_buy: newItem.price_buy || 0,
      price_sell: newItem.price_sell || 0,
      image_url: newItem.image_url || '',
      effects: JSON.stringify(newItem.effects || {}, null, 2)
    }
  } else {
    form.value = {
      name: '',
      description: '',
      type: 'consumable',
      slot_type: '',
      grid_width: 1,
      grid_height: 1,
      price_buy: 0,
      price_sell: 0,
      image_url: '',
      effects: '{}'
    }
  }
  activeTab.value = 'general'
}, { immediate: true })

// Reset form when modal opens
watch(() => props.show, (newVal) => {
  if (newVal && !props.item) {
    form.value = {
      name: '',
      description: '',
      type: 'consumable',
      slot_type: '',
      grid_width: 1,
      grid_height: 1,
      price_buy: 0,
      price_sell: 0,
      image_url: '',
      effects: '{}'
    }
    activeTab.value = 'general'
  }
})

function handleSubmit() {
  if (isValid.value && !effectsError.value) {
    emit('submit', { ...form.value })
  }
}

function handleImageError(e: Event) {
  const img = e.target as HTMLImageElement
  img.src = 'https://placehold.co/400x200/2a2a2a/d4a574?text=Invalid+Image'
}

function applyExample(effectObj: Record<string, any>) {
  form.value.effects = JSON.stringify(effectObj, null, 2)
  activeTab.value = 'effects'
}
</script>
