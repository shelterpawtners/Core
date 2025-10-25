-- Temporary fix for RLS policy - run this in your Supabase SQL Editor
-- This will make the pets table policy more permissive for debugging

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view own pets" ON public.pets;
DROP POLICY IF EXISTS "Users can insert own pets" ON public.pets;
DROP POLICY IF EXISTS "Users can update own pets" ON public.pets;
DROP POLICY IF EXISTS "Users can delete own pets" ON public.pets;

-- Create more permissive policies for debugging
-- Users can insert pets if they are authenticated
CREATE POLICY "Authenticated users can insert pets" ON public.pets
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Users can view their own pets
CREATE POLICY "Users can view own pets" ON public.pets
    FOR SELECT USING (auth.uid() = owner_id);

-- Users can update their own pets
CREATE POLICY "Users can update own pets" ON public.pets
    FOR UPDATE USING (auth.uid() = owner_id);

-- Users can delete their own pets
CREATE POLICY "Users can delete own pets" ON public.pets
    FOR DELETE USING (auth.uid() = owner_id);

-- Also create a function to manually create a user profile if the trigger didn't work
CREATE OR REPLACE FUNCTION public.create_user_profile(user_id UUID, user_email TEXT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, first_name, last_name)
    VALUES (user_id, user_email, '', '')
    ON CONFLICT (id) DO NOTHING;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Test function to check if user profile exists
CREATE OR REPLACE FUNCTION public.check_user_profile(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (SELECT 1 FROM public.user_profiles WHERE id = user_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;