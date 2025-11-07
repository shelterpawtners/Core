-- Final working RLS policies for pets table
-- Run this in your Supabase SQL Editor to restore proper security

-- Drop the completely open policy
DROP POLICY IF EXISTS "Allow all operations on pets" ON public.pets;

-- Create proper working policies
-- INSERT: Allow authenticated users to create pets
CREATE POLICY "Authenticated users can create pets" ON public.pets
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL AND auth.uid() = owner_id);

-- SELECT: Users can view their own pets
CREATE POLICY "Users can view own pets" ON public.pets
    FOR SELECT USING (auth.uid() = owner_id);

-- UPDATE: Users can update their own pets  
CREATE POLICY "Users can update own pets" ON public.pets
    FOR UPDATE USING (auth.uid() = owner_id)
    WITH CHECK (auth.uid() = owner_id);

-- DELETE: Users can delete their own pets
CREATE POLICY "Users can delete own pets" ON public.pets
    FOR DELETE USING (auth.uid() = owner_id);

-- Verify the policies are working
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'pets';

-- Test that we can still query pets (should work for your own pets)
SELECT COUNT(*) as my_pets_count FROM public.pets WHERE owner_id = auth.uid();