-- Link Supabase Auth Users to Admin Users
-- Run this AFTER running the migration script

-- Step 1: Check what auth users exist
SELECT id, email, created_at, email_confirmed_at 
FROM auth.users 
ORDER BY created_at DESC;

-- Step 2: Check current admin_users
SELECT id, email, full_name, role, active, user_id 
FROM admin_users;

-- Step 3: Link your admin account (replace the email with your actual admin email)
-- IMPORTANT: Replace 'admin@shelterpawtners.com' with the email you used to create the Supabase Auth user

UPDATE admin_users 
SET user_id = (
    SELECT id 
    FROM auth.users 
    WHERE email = 'admin@shelterpawtners.com'  -- ⚠️ CHANGE THIS TO YOUR ADMIN EMAIL
    LIMIT 1
)
WHERE email = 'admin@shelterpawtners.com';  -- ⚠️ CHANGE THIS TO YOUR ADMIN EMAIL

-- Step 4: If you have a second admin user, link that too
-- UPDATE admin_users 
-- SET user_id = (
--     SELECT id 
--     FROM auth.users 
--     WHERE email = 'irishjimmywarde@gmail.com'  -- ⚠️ CHANGE THIS TO YOUR EMAIL
--     LIMIT 1
-- )
-- WHERE email = 'irishjimmywarde@gmail.com';  -- ⚠️ CHANGE THIS TO YOUR EMAIL

-- Step 5: Verify the linking worked
SELECT 
    au.email as admin_email,
    au.full_name,
    au.role,
    au.active,
    u.email as auth_email,
    u.id as auth_user_id,
    u.email_confirmed_at
FROM admin_users au
LEFT JOIN auth.users u ON au.user_id = u.id
WHERE au.active = true;