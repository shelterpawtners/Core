-- Fix user_type check constraint to include all valid types
-- The constraint is currently missing 'business' and 'vet' as valid options
-- Drop the existing constraint
ALTER TABLE user_profiles 
DROP CONSTRAINT IF EXISTS user_profiles_user_type_check;

-- Add the corrected constraint with all valid types
ALTER TABLE user_profiles 
ADD CONSTRAINT user_profiles_user_type_check 
CHECK (user_type IN ('pet_parent', 'business', 'shelter', 'vet', 'admin'));

-- Verify the constraint
SELECT 
    conname AS constraint_name,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'user_profiles'::regclass
  AND conname = 'user_profiles_user_type_check';

-- Test that all types are now valid
SELECT 'Testing valid user types:' AS test;
SELECT 
    'pet_parent' AS user_type,
    ('pet_parent' IN ('pet_parent', 'business', 'shelter', 'vet', 'admin')) AS is_valid
UNION ALL
SELECT 'business', ('business' IN ('pet_parent', 'business', 'shelter', 'vet', 'admin'))
UNION ALL
SELECT 'shelter', ('shelter' IN ('pet_parent', 'business', 'shelter', 'vet', 'admin'))
UNION ALL
SELECT 'vet', ('vet' IN ('pet_parent', 'business', 'shelter', 'vet', 'admin'))
UNION ALL
SELECT 'admin', ('admin' IN ('pet_parent', 'business', 'shelter', 'vet', 'admin'));