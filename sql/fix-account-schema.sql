-- Fix for "address column not found" error in user_profiles table
-- This is a consolidated fix that should resolve the account update issues

-- First, let's check if the columns exist and add them if they don't
DO $$
BEGIN
    -- Add address column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'user_profiles' AND column_name = 'address') THEN
        ALTER TABLE public.user_profiles ADD COLUMN address TEXT;
        RAISE NOTICE 'Added address column to user_profiles';
    END IF;
    
    -- Add city column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'user_profiles' AND column_name = 'city') THEN
        ALTER TABLE public.user_profiles ADD COLUMN city TEXT;
        RAISE NOTICE 'Added city column to user_profiles';
    END IF;
    
    -- Add state column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'user_profiles' AND column_name = 'state') THEN
        ALTER TABLE public.user_profiles ADD COLUMN state TEXT;
        RAISE NOTICE 'Added state column to user_profiles';
    END IF;
    
    -- Add zip_code column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'user_profiles' AND column_name = 'zip_code') THEN
        ALTER TABLE public.user_profiles ADD COLUMN zip_code TEXT;
        RAISE NOTICE 'Added zip_code column to user_profiles';
    END IF;
    
    -- Add username column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'user_profiles' AND column_name = 'username') THEN
        ALTER TABLE public.user_profiles ADD COLUMN username TEXT UNIQUE;
        RAISE NOTICE 'Added username column to user_profiles';
    END IF;
    
    -- Add emergency contact columns if they don't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'user_profiles' AND column_name = 'emergency_contact_name') THEN
        ALTER TABLE public.user_profiles ADD COLUMN emergency_contact_name TEXT;
        RAISE NOTICE 'Added emergency_contact_name column to user_profiles';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'user_profiles' AND column_name = 'emergency_contact_phone') THEN
        ALTER TABLE public.user_profiles ADD COLUMN emergency_contact_phone TEXT;
        RAISE NOTICE 'Added emergency_contact_phone column to user_profiles';
    END IF;
    
    -- Add profile picture column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'user_profiles' AND column_name = 'profile_picture_url') THEN
        ALTER TABLE public.user_profiles ADD COLUMN profile_picture_url TEXT;
        RAISE NOTICE 'Added profile_picture_url column to user_profiles';
    END IF;
    
    -- Add bio column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'user_profiles' AND column_name = 'bio') THEN
        ALTER TABLE public.user_profiles ADD COLUMN bio TEXT;
        RAISE NOTICE 'Added bio column to user_profiles';
    END IF;
    
    -- Add preferences column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'user_profiles' AND column_name = 'preferences') THEN
        ALTER TABLE public.user_profiles ADD COLUMN preferences JSONB DEFAULT '{}'::jsonb;
        RAISE NOTICE 'Added preferences column to user_profiles';
    END IF;
END $$;

-- Create indexes for better performance (only if they don't exist)
CREATE INDEX IF NOT EXISTS idx_user_profiles_username ON public.user_profiles(username);
CREATE INDEX IF NOT EXISTS idx_user_profiles_location ON public.user_profiles(city, state, zip_code);

-- Verify the schema
DO $$
DECLARE
    col_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO col_count 
    FROM information_schema.columns 
    WHERE table_name = 'user_profiles' 
    AND column_name IN ('address', 'city', 'state', 'zip_code', 'username', 
                       'emergency_contact_name', 'emergency_contact_phone', 
                       'profile_picture_url', 'bio', 'preferences');
    
    RAISE NOTICE 'Enhanced user_profiles table now has % additional columns', col_count;
    
    IF col_count = 10 THEN
        RAISE NOTICE '✅ All required columns are present in user_profiles table';
    ELSE
        RAISE NOTICE '⚠️  Some columns may be missing. Expected 10, found %', col_count;
    END IF;
    RAISE NOTICE 'Database schema update completed successfully!';
    RAISE NOTICE 'The account.html page should now be able to save all profile fields.';
END $$;