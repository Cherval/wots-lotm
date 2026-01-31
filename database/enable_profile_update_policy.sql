-- Enable RLS on players table (if not already enabled)
ALTER TABLE public.players ENABLE ROW LEVEL SECURITY;

-- Allow users to update their own profile (specifically character_img_url and source_url)
-- Checks if the auth_id of the row matches the currently logged in user's ID
CREATE POLICY "Users can update their own profile" 
ON public.players 
FOR UPDATE 
TO authenticated 
USING (auth_id = auth.uid())
WITH CHECK (auth_id = auth.uid());

-- Allow users to view all profiles (Select is usually needed for Update to find the row)
CREATE POLICY "Everyone can view profiles"
ON public.players
FOR SELECT
TO authenticated, anon
USING (true);
