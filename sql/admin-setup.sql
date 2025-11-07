-- Admin Users Table Setup for Shelter Pawtners
-- Run this in Supabase SQL Editor

-- Create admin users table
CREATE TABLE IF NOT EXISTS admin_users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'admin',
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    created_by INTEGER REFERENCES admin_users(id)
);

-- Enable RLS (Row Level Security)
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Admin users can view all admin records" ON admin_users
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "Admin users can insert new admin records" ON admin_users  
    FOR INSERT TO authenticated
    WITH CHECK (true);

CREATE POLICY "Admin users can update admin records" ON admin_users
    FOR UPDATE TO authenticated
    USING (true);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_admin_users_email ON admin_users(email);
CREATE INDEX IF NOT EXISTS idx_admin_users_active ON admin_users(active);

-- Insert your first admin user (CHANGE THESE CREDENTIALS!)
-- Note: This uses a simple hash - in production use proper bcrypt hashing
INSERT INTO admin_users (email, password_hash, full_name, role) 
VALUES (
    'admin@shelterpawtners.com',  -- CHANGE THIS EMAIL
    '$2b$10$8OxgHn0aWHdwLwPFz9.2G.jN0QM0QVZy0nY5Kq2MkY6.FzV3H2BnG',  -- Default: 'admin123' - CHANGE THIS!
    'System Administrator',
    'super_admin'
) ON CONFLICT (email) DO NOTHING;

-- Add admin_user_id to business_partners for tracking who approved
ALTER TABLE business_partners 
ADD COLUMN IF NOT EXISTS approved_by INTEGER REFERENCES admin_users(id),
ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP WITH TIME ZONE;

COMMENT ON TABLE admin_users IS 'Stores admin user credentials and access control';
COMMENT ON COLUMN admin_users.password_hash IS 'Bcrypt hashed password - never store plain text!';
COMMENT ON COLUMN admin_users.role IS 'Admin role: super_admin, admin, moderator';