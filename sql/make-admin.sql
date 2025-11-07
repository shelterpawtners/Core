-- Quick Admin User Setup
-- Use this to make yourself an admin user

-- Option 1: Create admin with default credentials
-- Email: admin@shelterpawtners.com
-- Password: admin123 (CHANGE THIS IMMEDIATELY!)

INSERT INTO admin_users (email, password_hash, full_name, role, active) 
VALUES (
    'admin@shelterpawtners.com',
    '$2b$10$8OxgHn0aWHdwLwPFz9.2G.jN0QM0QVZy0nY5Kq2MkY6.FzV3H2BnG', -- Hash for 'admin123'
    'System Administrator',
    'super_admin',
    true
) ON CONFLICT (email) DO NOTHING;

-- Option 2: Create admin with YOUR email (recommended)
-- REPLACE 'your-email@example.com' with your actual email
-- Password will be 'admin123' - change it after first login!

INSERT INTO admin_users (email, password_hash, full_name, role, active) 
VALUES (
    'your-email@example.com',  -- ⚠️  CHANGE THIS TO YOUR EMAIL
    '$2b$10$8OxgHn0aWHdwLwPFz9.2G.jN0QM0QVZy0nY5Kq2MkY6.FzV3H2BnG', -- Hash for 'admin123'
    'Your Name',               -- ⚠️  CHANGE THIS TO YOUR NAME
    'super_admin',
    true
) ON CONFLICT (email) DO NOTHING;

-- Option 3: Check existing admin users
SELECT id, email, full_name, role, active, created_at, last_login 
FROM admin_users 
ORDER BY created_at DESC;

-- Option 4: Update existing user to admin (if you have their email)
-- REPLACE 'existing-user@example.com' with the email you want to make admin
/*
UPDATE admin_users 
SET role = 'super_admin', active = true 
WHERE email = 'existing-user@example.com';
*/