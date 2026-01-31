-- =============================================
-- ADD PERCENT POSITION COLUMNS TO MAP_POSITIONS
-- =============================================
-- This adds pos_x_percent and pos_y_percent columns 
-- for responsive positioning on maps
--
-- Run this SQL in your Supabase SQL Editor
-- =============================================

-- Add pos_x_percent column (percentage 0-100)
ALTER TABLE public.map_positions
ADD COLUMN IF NOT EXISTS pos_x_percent NUMERIC DEFAULT 50;

-- Add pos_y_percent column (percentage 0-100)
ALTER TABLE public.map_positions
ADD COLUMN IF NOT EXISTS pos_y_percent NUMERIC DEFAULT 50;

-- Add comments for documentation
COMMENT ON COLUMN public.map_positions.pos_x_percent IS 'Horizontal position as percentage (0-100) of map width';
COMMENT ON COLUMN public.map_positions.pos_y_percent IS 'Vertical position as percentage (0-100) of map height';

-- Update existing records to use center position if null
UPDATE public.map_positions 
SET pos_x_percent = 50, pos_y_percent = 50 
WHERE pos_x_percent IS NULL OR pos_y_percent IS NULL;
