-- =============================================================================
-- BREWING SYSTEM UPDATE - Shop Categories & Recipe Items
-- Whisper of the Shadow - Enhanced Shop and Recipe System
-- =============================================================================

-- ================= ADD SHOP CATEGORY TO ITEMS =================
-- เพิ่ม column shop_category สำหรับแยกหมวดหมู่ร้านค้า
ALTER TABLE items ADD COLUMN IF NOT EXISTS shop_category VARCHAR(50) DEFAULT 'market';

-- เพิ่ม column recipe_id สำหรับไอเทมประเภท "recipe" ที่เชื่อมโยงกับสูตรยา
ALTER TABLE items ADD COLUMN IF NOT EXISTS recipe_id UUID REFERENCES recipes(id);

-- เพิ่มประเภท 'recipe' ในไอเทม
-- ปรับ type constraint ให้รองรับ 'recipe'
-- Note: ถ้ามี constraint เดิม ต้องลบก่อน
-- ALTER TABLE items DROP CONSTRAINT IF EXISTS items_type_check;
-- ALTER TABLE items ADD CONSTRAINT items_type_check CHECK (type IN ('consumable', 'equipment', 'material', 'special', 'recipe'));

-- ================= SHOP CATEGORIES =================
-- ชุมนุมผู้วิเศษ (wizard_guild) - อาวุธ, ชุด, equipment
-- ตลาด (market) - วัตถุดิบปรุงยา, ของกิน, consumables, materials
-- ร้านค้าลึกลับ (mysterious) - อื่น ๆ, special items

-- ================= UPDATE EXISTING ITEMS WITH CATEGORIES =================

-- อัปเดตไอเทม equipment ให้เป็น wizard_guild
UPDATE items SET shop_category = 'wizard_guild' WHERE type = 'equipment';

-- อัปเดตไอเทม material/consumable ให้เป็น market
UPDATE items SET shop_category = 'market' WHERE type IN ('material', 'consumable');

-- อัปเดตไอเทม special ให้เป็น mysterious
UPDATE items SET shop_category = 'mysterious' WHERE type = 'special';

-- ================= CREATE RECIPE ITEMS =================
-- สร้างไอเทม "สูตรยา" สำหรับแต่ละ recipe

-- สูตรยาเอนกประสงค์
INSERT INTO items (name, description, type, shop_category, image_url, price_buy, price_sell, grid_width, grid_height, recipe_id)
SELECT 
    'สูตร: ' || r.name,
    'สูตรปรุงยา - ' || r.description,
    'recipe',
    'mysterious',
    'https://placehold.co/100x100/4a3728/d4af37?text=Recipe',
    0, -- price_buy = 0 เพราะมอบโดยแอดมิน
    0,
    1,
    1,
    r.id
FROM recipes r
WHERE NOT EXISTS (
    SELECT 1 FROM items i WHERE i.recipe_id = r.id
);

-- ================= INDEX FOR BETTER PERFORMANCE =================
CREATE INDEX IF NOT EXISTS idx_items_shop_category ON items(shop_category);
CREATE INDEX IF NOT EXISTS idx_items_recipe_id ON items(recipe_id);

-- ================= SAMPLE RECIPE ITEMS =================
-- (จะถูกสร้างอัตโนมัติจาก query ด้านบน ถ้ามี recipes อยู่แล้ว)
