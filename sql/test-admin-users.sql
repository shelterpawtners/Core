-- Simple test data for user management
-- Run this in your Supabase SQL Editor to create test admin users

INSERT INTO admin_users (email, full_name, role, active) VALUES
('admin@shelterpawtners.com', 'System Administrator', 'admin', true),
('manager@shelterpawtners.com', 'Site Manager', 'admin', true)
ON CONFLICT (email) DO NOTHING;

-- Check if the data was inserted
SELECT * FROM admin_users WHERE active = true;