-- Add profile_picture_url column to user_profiles table
-- Run this in Supabase SQL Editor

-- Add the column if it doesn't exist
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS profile_picture_url TEXT;

-- Add index for faster lookups (optional but recommended)
CREATE INDEX IF NOT EXISTS idx_user_profiles_picture_url 
ON user_profiles(profile_picture_url) 
WHERE profile_picture_url IS NOT NULL;

-- Verify the column was added
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'user_profiles' 
AND column_name = 'profile_picture_url';