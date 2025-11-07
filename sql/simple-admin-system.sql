-- SIMPLE Admin System - Much Easier to Manage
-- Run this in Supabase SQL Editor

-- Step 1: Simplify the admin_users table (keep it simple)
DROP TABLE IF EXISTS admin_users;

CREATE TABLE admin_users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'admin',
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    notes TEXT
);

-- Step 2: Add your admin users (just email addresses!)
INSERT INTO admin_users (email, full_name, role) VALUES
('admin@shelterpawtners.com', 'System Administrator', 'super_admin'),
('irishjimmywarde@gmail.com', 'Jimmy Ward', 'super_admin')
ON CONFLICT (email) DO NOTHING;

-- Step 3: Create simple admin check function
CREATE OR REPLACE FUNCTION is_admin(user_email text)
RETURNS boolean AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM admin_users 
        WHERE email = LOWER(user_email) 
        AND active = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 4: Easy function to add new admins
CREATE OR REPLACE FUNCTION add_admin(
    admin_email text,
    admin_name text DEFAULT 'Admin User',
    admin_role text DEFAULT 'admin'
)
RETURNS text AS $$
BEGIN
    INSERT INTO admin_users (email, full_name, role)
    VALUES (LOWER(admin_email), admin_name, admin_role)
    ON CONFLICT (email) 
    DO UPDATE SET 
        full_name = EXCLUDED.full_name,
        role = EXCLUDED.role,
        active = true;
    
    RETURN 'Admin added: ' || admin_email;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 5: Easy function to remove admins
CREATE OR REPLACE FUNCTION remove_admin(admin_email text)
RETURNS text AS $$
BEGIN
    UPDATE admin_users 
    SET active = false 
    WHERE email = LOWER(admin_email);
    
    RETURN 'Admin deactivated: ' || admin_email;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 6: View current admins
SELECT * FROM admin_users WHERE active = true;