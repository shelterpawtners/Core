-- QUICK ADMIN SETUP - Run this in Supabase SQL Editor
-- This will create the admin_users table and add your first admin

-- Step 1: Create the admin_users table
CREATE TABLE IF NOT EXISTS admin_users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'admin',
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE
);

-- Step 2: Add your admin user (CHANGE THE EMAIL TO YOUR EMAIL!)
INSERT INTO admin_users (email, password_hash, full_name, role, active) 
VALUES (
    'admin@shelterpawtners.com',  -- ⚠️ CHANGE THIS TO YOUR EMAIL
    'admin123',                   -- Simple password for demo
    'System Administrator',       -- ⚠️ CHANGE THIS TO YOUR NAME
    'super_admin',
    true
) ON CONFLICT (email) DO NOTHING;

-- Step 3: Verify the admin was created
SELECT * FROM admin_users;