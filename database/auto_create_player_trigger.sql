-- =============================================
-- AUTO CREATE PLAYER ON AUTH USER CREATION
-- =============================================
-- This trigger automatically creates a player record and player_skills
-- when a new user signs up via any auth method (Email, Google, Discord)
--
-- Run this SQL in your Supabase SQL Editor
-- =============================================

-- Step 1: Create the trigger function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    new_player_id UUID;
    user_display_name TEXT;
BEGIN
    -- Extract display name from user metadata
    -- Google: full_name or name
    -- Discord: full_name or username
    -- Email: email prefix
    user_display_name := COALESCE(
        NEW.raw_user_meta_data->>'full_name',
        NEW.raw_user_meta_data->>'name',
        NEW.raw_user_meta_data->>'username',
        split_part(NEW.email, '@', 1)
    );

    -- Insert new player record
    INSERT INTO public.players (
        auth_id,
        name,
        role,
        status
    ) VALUES (
        NEW.id,
        user_display_name,
        'player',
        'active'
    )
    RETURNING id INTO new_player_id;

    -- Insert player_skills record with the new player's id
    INSERT INTO public.player_skills (player_id)
    VALUES (new_player_id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 2: Create the trigger on auth.users table
-- First, drop existing trigger if it exists (to avoid errors on re-run)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create the trigger
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- =============================================
-- VERIFICATION QUERIES (Optional - Run to test)
-- =============================================

-- Check if trigger exists:
-- SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';

-- Check if function exists:
-- SELECT * FROM pg_proc WHERE proname = 'handle_new_user';

-- =============================================
-- NOTES
-- =============================================
-- 1. This trigger fires AFTER a new user is inserted into auth.users
-- 2. It creates a player record with:
--    - auth_id linked to the auth user
--    - name extracted from OAuth metadata or email
--    - default role 'player' and status 'active'
-- 3. It also creates a player_skills record with all default values (0)
-- 4. The SECURITY DEFINER allows the function to bypass RLS policies
