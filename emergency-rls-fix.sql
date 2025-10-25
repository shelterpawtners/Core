-- Emergency RLS policy fix - completely open for debugging
-- Run this in your Supabase SQL Editor

-- Drop all existing policies for pets table
DROP POLICY IF EXISTS "Users can view own pets" ON public.pets;
DROP POLICY IF EXISTS "Authenticated users can insert pets" ON public.pets;
DROP POLICY IF EXISTS "Users can update own pets" ON public.pets;
DROP POLICY IF EXISTS "Users can delete own pets" ON public.pets;

-- Create completely permissive policies for debugging
CREATE POLICY "Allow all operations on pets" ON public.pets
    FOR ALL USING (true) WITH CHECK (true);

-- Also disable RLS temporarily for debugging (uncomment if needed)
-- ALTER TABLE public.pets DISABLE ROW LEVEL SECURITY;

-- Test query to check what auth.uid() returns
SELECT 
    auth.uid() as current_auth_uid,
    current_user as current_db_user,
    session_user as session_user;

-- Check if there are any pets in the table
SELECT COUNT(*) as pet_count FROM public.pets;

-- Show current RLS status
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'pets';