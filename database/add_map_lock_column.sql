-- =============================================
-- ADD MAP LOCK FEATURE
-- =============================================
-- This adds an is_locked column to the maps table
-- to allow admin/assistant to lock player movement
--
-- Run this SQL in your Supabase SQL Editor
-- =============================================

-- Add is_locked column to maps table
ALTER TABLE public.maps
ADD COLUMN IF NOT EXISTS is_locked BOOLEAN DEFAULT FALSE;

-- Add comment for documentation
COMMENT ON COLUMN public.maps.is_locked IS 'When true, players cannot move or place themselves on this map. Only admin/assistant can modify.';
