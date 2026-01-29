<template>
  <div class="animate-fade-in max-w-5xl mx-auto">
    <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6 bg-vic-darkbrown p-4 rounded border border-vic-brown">
      <h2 class="text-2xl text-vic-gold font-bold font-serif">📋 บันทึกธุรกรรม</h2>

      <!-- Filter -->
      <div class="flex gap-2 w-full md:w-auto">
        <input
          v-model="filterText"
          @keyup.enter="applyFilter"
          placeholder="ค้นหาชื่อผู้เล่น..."
          class="input-vic flex-1 md:w-48 text-sm"
        />
        <button @click="applyFilter" class="px-4 py-2 bg-vic-gold text-black rounded font-bold text-sm hover:bg-white">
          🔍
        </button>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="text-center py-20 text-gray-500">
      <div class="animate-spin inline-block w-8 h-8 border-4 border-vic-gold border-t-transparent rounded-full mb-4"></div>
      <p>กำลังโหลด...</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="logs.length === 0" class="text-center py-20 text-gray-500 border-2 border-dashed border-gray-700 rounded-lg">
      ไม่มีรายการธุรกรรม
    </div>

    <!-- Logs Table -->
    <div v-else class="bg-vic-darkbrown rounded border border-vic-brown overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="bg-black/30 border-b border-vic-brown">
            <tr>
              <th class="px-4 py-3 text-left text-vic-gold font-bold">เวลา</th>
              <th class="px-4 py-3 text-left text-vic-gold font-bold">ประเภท</th>
              <th class="px-4 py-3 text-left text-vic-gold font-bold">ผู้ทำรายการ</th>
              <th class="px-4 py-3 text-left text-vic-gold font-bold">ผู้รับ/เป้าหมาย</th>
              <th class="px-4 py-3 text-left text-vic-gold font-bold">รายละเอียด</th>
              <th class="px-4 py-3 text-right text-vic-gold font-bold">จำนวน</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="log in logs"
              :key="log.id"
              class="border-b border-gray-800 hover:bg-white/5 transition"
              :class="{
                'bg-yellow-900/10': log.action_type === 'money_grant',
                'bg-red-900/10': log.action_type === 'item_delete' || log.action_type === 'item_discard'
              }"
            >
              <td class="px-4 py-3 text-gray-400 text-xs whitespace-nowrap">{{ formatDate(log.created_at) }}</td>
              <td class="px-4 py-3 whitespace-nowrap">
                <span
                  class="text-xs px-2 py-1 rounded"
                  :class="getActionColor(log.action_type)"
                >
                  {{ getActionLabel(log.action_type) }}
                </span>
              </td>
              <td class="px-4 py-3 text-white font-medium">{{ log.actor_name || '-' }}</td>
              <td class="px-4 py-3 text-gray-300">{{ log.target_name || '-' }}</td>
              <td class="px-4 py-3 text-gray-400 text-xs">{{ log.item_name || log.details?.note || '-' }}</td>
              <td
                class="px-4 py-3 text-right font-bold"
                :class="{
                  'text-green-400': (log.amount ?? 0) > 0,
                  'text-red-400': (log.amount ?? 0) < 0,
                  'text-gray-500': !log.amount
                }"
              >
                {{ log.amount ? ((log.amount ?? 0) > 0 ? '+' : '') + log.amount : '-' }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div class="flex items-center justify-between p-4 bg-black/20 border-t border-vic-brown">
        <div class="text-sm text-gray-400">
          หน้า {{ currentPage }} / {{ totalPages }}
        </div>

        <div class="flex items-center gap-2">
          <button
            @click="previousPage"
            :disabled="currentPage <= 1 || loading"
            class="px-3 py-1 rounded border border-gray-600 text-gray-400 hover:bg-gray-800 disabled:opacity-30 disabled:cursor-not-allowed"
          >
            ❮
          </button>

          <input
            type="number"
            v-model.number="currentPage"
            @blur="goToPage"
            min="1"
            :max="totalPages"
            class="w-16 px-2 py-1 bg-black/50 border border-gray-600 rounded text-center text-white text-sm"
          />

          <button
            @click="nextPage"
            :disabled="currentPage >= totalPages || loading"
            class="px-3 py-1 rounded border border-gray-600 text-gray-400 hover:bg-gray-800 disabled:opacity-30 disabled:cursor-not-allowed"
          >
            ❯
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import type { TransactionLog } from '@/lib/constants'
import { formatDate } from '@/lib/supabase'

interface Props {
  logs: TransactionLog[]
  loading?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  loading: false
})

const filterText = ref('')
const currentPage = ref(1)
const itemsPerPage = 20

const filteredLogs = computed(() => {
  if (!filterText.value) return props.logs
  const search = filterText.value.toLowerCase()
  return props.logs.filter(
    (log) =>
      log.actor_name?.toLowerCase().includes(search) ||
      log.target_name?.toLowerCase().includes(search) ||
      log.item_name?.toLowerCase().includes(search)
  )
})

const totalPages = computed(() => Math.ceil(filteredLogs.value.length / itemsPerPage))

const logs = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  return filteredLogs.value.slice(start, start + itemsPerPage)
})

const applyFilter = () => {
  currentPage.value = 1
}

const previousPage = () => {
  if (currentPage.value > 1) currentPage.value--
}

const nextPage = () => {
  if (currentPage.value < totalPages.value) currentPage.value++
}

const goToPage = () => {
  if (currentPage.value < 1) currentPage.value = 1
  if (currentPage.value > totalPages.value) currentPage.value = totalPages.value
}

const getActionLabel = (actionType: string): string => {
  const labels: Record<string, string> = {
    // Money & Economy
    money_grant: '💸 เสกเงิน',
    grant_money: '💸 เสกเงิน',
    sp_grant: '⚡ เสก SP',
    grant_sp: '⚡ เสก SP',
    bank_deposit: '🏦 ฝากเงิน',
    bank_withdraw: '🏦 ถอนเงิน',
    transfer_money: '💵 โอนเงิน',
    money_transfer: '💵 โอนเงิน',
    
    // Items
    buy_item: '🛒 ซื้อสินค้า',
    item_buy: '🛒 ซื้อสินค้า',
    sell_item: '💰 ขายของ',
    item_sell: '💰 ขายของ',
    use_item: '✨ ใช้ของ',
    item_use: '✨ ใช้ของ',
    discard_item: '🗑️ ทิ้งของ',
    item_discard: '🗑️ ทิ้งของ',
    item_delete: '✕ ลบของ',
    transfer_item: '📦 ส่งของ',
    item_transfer: '📦 ส่งของ',
    
    // Shop Management
    create_shop_item: '➕ สร้างสินค้า',
    edit_shop_item: '✏️ แก้ไขสินค้า',
    delete_shop_item: '✕ ลบสินค้า',
    
    // Character Management
    create_player: '👤 สร้างตัวละคร',
    edit_player: '✏️ แก้ไขตัวละคร',
    create_enemy: '👹 สร้างศัตรู',
    edit_enemy: '✏️ แก้ไขศัตรู',
    delete_character: '✕ ลบตัวละคร',
    change_status: '🔄 เปลี่ยนสถานะ',
    upgrade_stats: '⬆️ อัปเกรดสถานะ',
    upgrade_stat: '⬆️ อพเกรดสถานะ',
    
    // Map Management
    create_map: '🗺️ สร้างแผนที่',
    edit_map: '✏️ แก้ไขแผนที่',
    delete_map: '✕ ลบแผนที่'
  }
  return labels[actionType] || actionType
}

const getActionColor = (actionType: string): string => {
  // Transfers
  if (actionType.includes('transfer')) return 'bg-purple-900/50 text-purple-300'
  
  // Grants (admin)
  if (actionType.includes('grant')) return 'bg-yellow-900/50 text-yellow-300'
  
  // Item usage
  if (actionType.includes('use')) return 'bg-blue-900/50 text-blue-300'
  
  // Create/Buy actions
  if (actionType.includes('buy') || actionType.includes('create')) return 'bg-green-900/50 text-green-300'
  
  // Delete/Discard/Sell actions
  if (actionType.includes('delete') || actionType.includes('discard') || actionType.includes('sell'))
    return 'bg-red-900/50 text-red-300'
  
  // Bank operations
  if (actionType.includes('bank')) return 'bg-gray-800 text-gray-300'
  
  // Upgrade operations
  if (actionType.includes('upgrade')) return 'bg-cyan-900/50 text-cyan-300'
  
  // Character/Status operations
  if (actionType.includes('player') || actionType.includes('enemy') || actionType.includes('character') || actionType.includes('status'))
    return 'bg-indigo-900/50 text-indigo-300'
  
  // Map operations
  if (actionType.includes('map')) return 'bg-amber-900/50 text-amber-300'
  
  // Edit operations
  if (actionType.includes('edit')) return 'bg-orange-900/50 text-orange-300'
  
  return 'bg-gray-800 text-gray-300'
}
</script>
