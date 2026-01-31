<script setup lang="ts">
import { ref, watch } from 'vue'
import BaseModal from '../ui/BaseModal.vue'

const props = defineProps<{
    show: boolean
    currentUrl: string
}>()

const emit = defineEmits<{
    close: []
    confirm: [newUrl: string]
}>()

const imageUrl = ref('')

watch(() => props.show, (newVal) => {
    if (newVal) {
        imageUrl.value = props.currentUrl || ''
    }
})

function handleConfirm() {
    if (!imageUrl.value) return
    emit('confirm', imageUrl.value)
    emit('close')
}
</script>

<template>
    <BaseModal 
        :show="show" 
        title="แก้ไขรูปโปรไฟล์" 
        @close="emit('close')"
    >
        <div class="space-y-4">
            <div class="flex flex-col items-center gap-4">
                <!-- Preview -->
                <div class="w-32 h-32 rounded-full border-4 border-vic-gold overflow-hidden bg-black shadow-lg">
                    <img 
                        :src="imageUrl || 'https://placehold.co/128x128/2a2a2a/d4a574?text=?'" 
                        class="w-full h-full object-cover"
                        @error="(e: any) => e.target.src = 'https://placehold.co/128x128/2a2a2a/d4a574?text=Error'"
                    />
                </div>
                
                <p class="text-sm text-gray-400 text-center">
                    ใส่ลิงก์รูปภาพโดยตรง (Direct URL) เท่านั้น<br>
                    รองรับ .jpg, .png, .gif, .webp
                </p>
            </div>

            <div class="space-y-2">
                <label class="text-vic-gold font-bold text-sm">ลิงก์รูปภาพ (URL)</label>
                <input 
                    v-model="imageUrl"
                    type="text"
                    class="input-vic"
                    placeholder="https://example.com/image.jpg"
                />
            </div>

            <div class="flex justify-end gap-3 pt-4 border-t border-gray-700">
                <button 
                    @click="emit('close')"
                    class="px-4 py-2 rounded border border-gray-600 text-gray-400 hover:bg-gray-800 transition"
                >
                    ยกเลิก
                </button>
                <button 
                    @click="handleConfirm"
                    class="btn-gold"
                    :disabled="!imageUrl"
                >
                    บันทึกรูปภาพ
                </button>
            </div>
        </div>
    </BaseModal>
</template>
