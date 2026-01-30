-- =============================================================================
-- BREWING SYSTEM - Database Schema
-- Whisper of the Shadow - Potion Brewing System
-- =============================================================================

-- ================= RECIPES TABLE =================
-- Main table for storing potion recipes
CREATE TABLE IF NOT EXISTS recipes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,                    -- ชื่อสูตร เช่น "ยาเอนกประสงค์"
    description TEXT,                              -- คำอธิบายสูตร
    image_url TEXT,                                -- รูปภาพของยาที่ปรุงเสร็จ
    result_item_id UUID REFERENCES items(id),      -- ไอเทมที่จะได้รับเมื่อปรุงสำเร็จ
    result_quantity INT DEFAULT 1,                 -- จำนวนไอเทมที่ได้
    difficulty VARCHAR(50) DEFAULT 'normal',       -- ระดับความยาก: easy, normal, hard, expert
    tolerance_percent DECIMAL(5,2) DEFAULT 10.00,  -- % ความคลาดเคลื่อนที่ยอมรับได้
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id)
);

-- ================= RECIPE STEPS TABLE =================
-- Ordered steps for each recipe
CREATE TABLE IF NOT EXISTS recipe_steps (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE,
    step_order INT NOT NULL,                       -- ลำดับขั้นตอน (1, 2, 3, ...)
    step_type VARCHAR(50) NOT NULL,                -- ประเภทขั้นตอน: 'set_fire', 'add_ingredient', 'simmer'
    
    -- สำหรับ step_type = 'set_fire'
    fire_level INT CHECK (fire_level >= 0 AND fire_level <= 3),  -- ระดับไฟ 0-3
    
    -- สำหรับ step_type = 'add_ingredient'
    item_id UUID REFERENCES items(id),             -- ไอเทมที่ต้องใส่
    amount DECIMAL(10,2),                          -- จำนวน (กรัม หรือ มล.)
    unit VARCHAR(20),                              -- หน่วย: 'ml', 'g', 'piece'
    
    -- สำหรับ step_type = 'simmer'
    duration_seconds INT,                          -- เวลาต้ม (วินาที)
    
    description TEXT,                              -- คำอธิบายขั้นตอน
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ================= BREWING SESSIONS TABLE =================
-- Track active/completed brewing sessions
CREATE TABLE IF NOT EXISTS brewing_sessions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    recipe_id UUID REFERENCES recipes(id),
    status VARCHAR(50) DEFAULT 'in_progress',      -- in_progress, success, failed
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- บันทึกขั้นตอนที่ผู้เล่นทำ (JSON array)
    player_steps JSONB DEFAULT '[]'::jsonb,
    
    -- ผลลัพธ์
    accuracy_score DECIMAL(5,2),                   -- คะแนนความแม่นยำ %
    result_message TEXT
);

-- ================= INDEXES =================
CREATE INDEX IF NOT EXISTS idx_recipe_steps_recipe_id ON recipe_steps(recipe_id);
CREATE INDEX IF NOT EXISTS idx_recipe_steps_order ON recipe_steps(recipe_id, step_order);
CREATE INDEX IF NOT EXISTS idx_brewing_sessions_player ON brewing_sessions(player_id);
CREATE INDEX IF NOT EXISTS idx_brewing_sessions_status ON brewing_sessions(status);

-- ================= RLS POLICIES =================
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipe_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE brewing_sessions ENABLE ROW LEVEL SECURITY;

-- Everyone can read recipes
CREATE POLICY "recipes_read_all" ON recipes FOR SELECT USING (true);

-- Only admins can modify recipes
CREATE POLICY "recipes_admin_insert" ON recipes FOR INSERT 
    WITH CHECK (EXISTS (
        SELECT 1 FROM players 
        WHERE auth_id = auth.uid() 
        AND role IN ('dungeon_master', 'assistant')
    ));

CREATE POLICY "recipes_admin_update" ON recipes FOR UPDATE 
    USING (EXISTS (
        SELECT 1 FROM players 
        WHERE auth_id = auth.uid() 
        AND role IN ('dungeon_master', 'assistant')
    ));

CREATE POLICY "recipes_admin_delete" ON recipes FOR DELETE 
    USING (EXISTS (
        SELECT 1 FROM players 
        WHERE auth_id = auth.uid() 
        AND role = 'dungeon_master'
    ));

-- Recipe steps policies
CREATE POLICY "recipe_steps_read_all" ON recipe_steps FOR SELECT USING (true);
CREATE POLICY "recipe_steps_admin_insert" ON recipe_steps FOR INSERT 
    WITH CHECK (EXISTS (
        SELECT 1 FROM players 
        WHERE auth_id = auth.uid() 
        AND role IN ('dungeon_master', 'assistant')
    ));
CREATE POLICY "recipe_steps_admin_update" ON recipe_steps FOR UPDATE 
    USING (EXISTS (
        SELECT 1 FROM players 
        WHERE auth_id = auth.uid() 
        AND role IN ('dungeon_master', 'assistant')
    ));
CREATE POLICY "recipe_steps_admin_delete" ON recipe_steps FOR DELETE 
    USING (EXISTS (
        SELECT 1 FROM players 
        WHERE auth_id = auth.uid() 
        AND role IN ('dungeon_master', 'assistant')
    ));

-- Brewing sessions - players can only see their own
CREATE POLICY "brewing_sessions_own" ON brewing_sessions FOR ALL
    USING (player_id IN (
        SELECT id FROM players WHERE auth_id = auth.uid()
    ));

-- Admins can see all brewing sessions
CREATE POLICY "brewing_sessions_admin" ON brewing_sessions FOR SELECT
    USING (EXISTS (
        SELECT 1 FROM players 
        WHERE auth_id = auth.uid() 
        AND role IN ('dungeon_master', 'assistant')
    ));

-- ================= SAMPLE DATA =================

-- สร้างไอเทมวัตถุดิบตัวอย่าง (ถ้ายังไม่มี)
INSERT INTO items (name, description, type, image_url, price_buy, price_sell, grid_width, grid_height, effects)
VALUES 
    ('น้ำเปล่า', 'น้ำบริสุทธิ์สำหรับปรุงยา', 'material', 'https://placehold.co/100x100/1a3a5c/ffffff?text=Water', 5, 2, 1, 1, '{"unit": "ml"}'),
    ('ผลงคริสตัล', 'ผลไม้เรืองแสงจากป่าลึก', 'material', 'https://placehold.co/100x100/9b59b6/ffffff?text=Crystal', 50, 25, 1, 1, '{"unit": "g"}'),
    ('ไม้มะเกลือบด', 'ผงไม้มะเกลือบดละเอียด', 'material', 'https://placehold.co/100x100/5d4037/ffffff?text=Ebony', 30, 15, 1, 1, '{"unit": "g"}'),
    ('ใบสะระแหน่', 'สมุนไพรหอมสดชื่น', 'material', 'https://placehold.co/100x100/27ae60/ffffff?text=Mint', 10, 5, 1, 1, '{"unit": "g"}'),
    ('เกลือทะเล', 'เกลือจากทะเลลึก', 'material', 'https://placehold.co/100x100/ecf0f1/333333?text=Salt', 8, 4, 1, 1, '{"unit": "g"}'),
    ('น้ำผึ้งป่า', 'น้ำผึ้งจากรังผึ้งในป่าดึกดำบรรพ์', 'material', 'https://placehold.co/100x100/f39c12/ffffff?text=Honey', 40, 20, 1, 1, '{"unit": "ml"}'),
    ('ดอกมะลิ', 'ดอกมะลิแห้งสำหรับปรุงยา', 'material', 'https://placehold.co/100x100/ecf0f1/333333?text=Jasmine', 25, 12, 1, 1, '{"unit": "g"}'),
    ('รากโสม', 'รากโสมอายุร้อยปี', 'material', 'https://placehold.co/100x100/c0392b/ffffff?text=Ginseng', 200, 100, 1, 1, '{"unit": "g"}')
ON CONFLICT DO NOTHING;

-- สร้างไอเทมผลลัพธ์ (ยาที่ปรุงเสร็จ)
INSERT INTO items (name, description, type, image_url, price_buy, price_sell, grid_width, grid_height, effects)
VALUES 
    ('ยาเอนกประสงค์', 'ยาฟื้นฟูพลังชีวิตขั้นพื้นฐาน', 'consumable', 'https://placehold.co/100x100/e74c3c/ffffff?text=Potion', 100, 50, 1, 1, '{"heal_hp": 20}'),
    ('ยาเพิ่มพลัง', 'ยาเพิ่มพลังโจมตีชั่วคราว', 'consumable', 'https://placehold.co/100x100/e67e22/ffffff?text=Power', 150, 75, 1, 1, '{"buff_atk": 5, "duration": 300}'),
    ('ยาคลายพิษ', 'ยาถอนพิษทุกชนิด', 'consumable', 'https://placehold.co/100x100/2ecc71/ffffff?text=Antidote', 80, 40, 1, 1, '{"cure_poison": true}'),
    ('น้ำมนตร์', 'น้ำที่อัดแน่นไปด้วยพลังเวทย์', 'consumable', 'https://placehold.co/100x100/3498db/ffffff?text=Mana', 120, 60, 1, 1, '{"restore_mp": 30}')
ON CONFLICT DO NOTHING;

-- สร้างสูตรยาตัวอย่าง
DO $$
DECLARE
    water_id UUID;
    crystal_id UUID;
    ebony_id UUID;
    mint_id UUID;
    honey_id UUID;
    potion_id UUID;
    power_potion_id UUID;
    recipe_basic_id UUID;
    recipe_power_id UUID;
BEGIN
    -- ดึง ID ของวัตถุดิบ
    SELECT id INTO water_id FROM items WHERE name = 'น้ำเปล่า' LIMIT 1;
    SELECT id INTO crystal_id FROM items WHERE name = 'ผลงคริสตัล' LIMIT 1;
    SELECT id INTO ebony_id FROM items WHERE name = 'ไม้มะเกลือบด' LIMIT 1;
    SELECT id INTO mint_id FROM items WHERE name = 'ใบสะระแหน่' LIMIT 1;
    SELECT id INTO honey_id FROM items WHERE name = 'น้ำผึ้งป่า' LIMIT 1;
    SELECT id INTO potion_id FROM items WHERE name = 'ยาเอนกประสงค์' LIMIT 1;
    SELECT id INTO power_potion_id FROM items WHERE name = 'ยาเพิ่มพลัง' LIMIT 1;
    
    -- สร้างสูตรยาเอนกประสงค์
    INSERT INTO recipes (name, description, image_url, result_item_id, result_quantity, difficulty, tolerance_percent)
    VALUES (
        'ยาเอนกประสงค์',
        'ยาฟื้นฟูพลังชีวิตขั้นพื้นฐาน เหมาะสำหรับผู้เริ่มต้นฝึกปรุงยา',
        'https://placehold.co/300x300/e74c3c/ffffff?text=Basic+Potion',
        potion_id,
        1,
        'easy',
        15.00
    )
    RETURNING id INTO recipe_basic_id;
    
    -- ขั้นตอนสูตรยาเอนกประสงค์
    INSERT INTO recipe_steps (recipe_id, step_order, step_type, fire_level, description)
    VALUES (recipe_basic_id, 1, 'set_fire', 1, 'จุดไฟระดับ 1 (ไฟอ่อน)');
    
    INSERT INTO recipe_steps (recipe_id, step_order, step_type, item_id, amount, unit, description)
    VALUES (recipe_basic_id, 2, 'add_ingredient', water_id, 500, 'ml', 'ใส่น้ำเปล่า 500 มล.');
    
    INSERT INTO recipe_steps (recipe_id, step_order, step_type, item_id, amount, unit, description)
    VALUES (recipe_basic_id, 3, 'add_ingredient', crystal_id, 3, 'g', 'ใส่ผลงคริสตัล 3 กรัม');
    
    INSERT INTO recipe_steps (recipe_id, step_order, step_type, duration_seconds, description)
    VALUES (recipe_basic_id, 4, 'simmer', 60, 'ต้มทิ้งไว้ 1 นาที');
    
    INSERT INTO recipe_steps (recipe_id, step_order, step_type, item_id, amount, unit, description)
    VALUES (recipe_basic_id, 5, 'add_ingredient', ebony_id, 5, 'g', 'ใส่ไม้มะเกลือบด 5 กรัม');
    
    INSERT INTO recipe_steps (recipe_id, step_order, step_type, duration_seconds, description)
    VALUES (recipe_basic_id, 6, 'simmer', 30, 'ต้มทิ้งไว้อีก 30 วินาที');
    
    -- สร้างสูตรยาเพิ่มพลัง
    INSERT INTO recipes (name, description, image_url, result_item_id, result_quantity, difficulty, tolerance_percent)
    VALUES (
        'ยาเพิ่มพลัง',
        'ยาเพิ่มพลังโจมตี ต้องใช้ความระมัดระวังในการปรุง',
        'https://placehold.co/300x300/e67e22/ffffff?text=Power+Potion',
        power_potion_id,
        1,
        'normal',
        10.00
    )
    RETURNING id INTO recipe_power_id;
    
    -- ขั้นตอนสูตรยาเพิ่มพลัง
    INSERT INTO recipe_steps (recipe_id, step_order, step_type, fire_level, description)
    VALUES (recipe_power_id, 1, 'set_fire', 2, 'จุดไฟระดับ 2 (ไฟปานกลาง)');
    
    INSERT INTO recipe_steps (recipe_id, step_order, step_type, item_id, amount, unit, description)
    VALUES (recipe_power_id, 2, 'add_ingredient', water_id, 300, 'ml', 'ใส่น้ำเปล่า 300 มล.');
    
    INSERT INTO recipe_steps (recipe_id, step_order, step_type, item_id, amount, unit, description)
    VALUES (recipe_power_id, 3, 'add_ingredient', honey_id, 50, 'ml', 'ใส่น้ำผึ้งป่า 50 มล.');
    
    INSERT INTO recipe_steps (recipe_id, step_order, step_type, fire_level, description)
    VALUES (recipe_power_id, 4, 'set_fire', 3, 'เพิ่มไฟเป็นระดับ 3 (ไฟแรง)');
    
    INSERT INTO recipe_steps (recipe_id, step_order, step_type, duration_seconds, description)
    VALUES (recipe_power_id, 5, 'simmer', 90, 'ต้มทิ้งไว้ 1 นาที 30 วินาที');
    
    INSERT INTO recipe_steps (recipe_id, step_order, step_type, item_id, amount, unit, description)
    VALUES (recipe_power_id, 6, 'add_ingredient', mint_id, 10, 'g', 'ใส่ใบสะระแหน่ 10 กรัม');
    
    INSERT INTO recipe_steps (recipe_id, step_order, step_type, fire_level, description)
    VALUES (recipe_power_id, 7, 'set_fire', 1, 'ลดไฟลงเป็นระดับ 1');
    
    INSERT INTO recipe_steps (recipe_id, step_order, step_type, duration_seconds, description)
    VALUES (recipe_power_id, 8, 'simmer', 45, 'ต้มทิ้งไว้อีก 45 วินาที');
    
END $$;
