-- Update Admin System to Use Supabase Auth
-- Run this in Supabase SQL Editor

-- Step 1: Modify admin_users table to reference Supabase auth users
ALTER TABLE admin_users 
DROP COLUMN IF EXISTS password_hash,
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);

-- Step 2: Create admin users in Supabase Auth first, then link them
-- You'll need to do this through the Supabase Dashboard Auth section or via API

-- Step 3: Create a function to check if a user is an admin
CREATE OR REPLACE FUNCTION is_admin(user_email text)
RETURNS boolean AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM admin_users 
        WHERE email = user_email 
        AND active = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 4: Create RLS policies for admin access
CREATE POLICY "Admins can manage business_partners" ON business_partners
    FOR ALL TO authenticated
    USING (is_admin(auth.jwt() ->> 'email'));

-- Step 5: Enable RLS on business_partners if not already enabled
ALTER TABLE business_partners ENABLE ROW LEVEL SECURITY;

-- Step 6: Create a view for admin user info (optional)
CREATE OR REPLACE VIEW admin_user_info AS
SELECT 
    au.id,
    au.email,
    au.full_name,
    au.role,
    au.active,
    au.created_at,
    au.last_login,
    u.id as auth_user_id,
    u.created_at as auth_created_at
FROM admin_users au
LEFT JOIN auth.users u ON au.user_id = u.id
WHERE au.active = true;

-- Step 7: Check current admin users (cleanup needed)
SELECT * FROM admin_users;

-- Note: You'll need to:
-- 1. Create actual Supabase Auth users for each admin
-- 2. Update the admin_users table to link to those auth users
-- 3. Remove the old password_hash entries