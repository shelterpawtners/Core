-- Add 'shelter' to user_type enum if it doesn't exist
-- This ensures the user_profiles table accepts 'shelter' as a valid user type

-- Check if the user_type column uses an enum, and if so, add 'shelter' if missing
DO $$ 
BEGIN
    -- Try to add 'shelter' to the enum type if it exists
    -- This will fail silently if the enum doesn't exist or 'shelter' is already present
    BEGIN
        ALTER TYPE user_type_enum ADD VALUE IF NOT EXISTS 'shelter';
    EXCEPTION
        WHEN undefined_object THEN
            -- If enum doesn't exist, the column might be text type, which is fine
            RAISE NOTICE 'user_type_enum does not exist, column may be text type';
        WHEN duplicate_object THEN
            -- Value already exists, which is fine
            RAISE NOTICE 'shelter already exists in user_type_enum';
    END;
END $$;

-- If user_type is a text column with a check constraint, update the constraint
-- First, check if there's a check constraint
DO $$
BEGIN
    -- Drop old constraint if it exists
    IF EXISTS (
        SELECT 1 FROM information_schema.constraint_column_usage 
        WHERE table_name = 'user_profiles' 
        AND column_name = 'user_type'
        AND constraint_name LIKE '%user_type%check%'
    ) THEN
        ALTER TABLE user_profiles DROP CONSTRAINT IF EXISTS user_profiles_user_type_check;
    END IF;
    
    -- Add new constraint with all valid types
    ALTER TABLE user_profiles 
    ADD CONSTRAINT user_profiles_user_type_check 
    CHECK (user_type IN ('pet_parent', 'business', 'shelter', 'admin'));
    
EXCEPTION
    WHEN duplicate_object THEN
        RAISE NOTICE 'Constraint already exists';
    WHEN others THEN
        RAISE NOTICE 'Could not add constraint: %', SQLERRM;
END $$;

-- Verify the change
SELECT 
    column_name, 
    data_type, 
    udt_name,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_profiles' 
AND column_name = 'user_type';
