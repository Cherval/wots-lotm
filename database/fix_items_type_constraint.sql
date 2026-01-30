-- Fix items_type_check constraint to include 'recipe' type
-- Run this in Supabase SQL Editor

-- Step 1: Drop the existing constraint
ALTER TABLE items DROP CONSTRAINT IF EXISTS items_type_check;

-- Step 2: Add new constraint that includes 'recipe' type
ALTER TABLE items ADD CONSTRAINT items_type_check 
CHECK (type IN ('consumable', 'equipment', 'material', 'special', 'recipe'));

-- Verify the constraint was updated
SELECT conname, pg_get_constraintdef(oid) 
FROM pg_constraint 
WHERE conrelid = 'items'::regclass AND contype = 'c';
