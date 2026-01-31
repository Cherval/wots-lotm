-- =============================================
-- ADD MOVE TOKEN (STAMINA) COLUMN TO PLAYERS
-- =============================================
-- This adds a move_token column for travel stamina system
--
-- Run this SQL in your Supabase SQL Editor
-- =============================================

-- Add move_token column to players table
ALTER TABLE public.players
ADD COLUMN IF NOT EXISTS move_token INTEGER DEFAULT 10;

-- Add comment for documentation
COMMENT ON COLUMN public.players.move_token IS 'Travel stamina tokens. Moving within map costs 1, moving to another map costs 3.';
