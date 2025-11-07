-- Update admin_users record to include user_id for better authentication
-- This links the admin record to the actual auth.users record

UPDATE admin_users
SET user_id = '6e3cd7fa-3300-43d9-b92f-118261b370e1'
WHERE email = 'irishjimmyward@gmail.com';

-- Verify the update
SELECT id, email, full_name, role, active, user_id, created_at
FROM admin_users
WHERE email = 'irishjimmyward@gmail.com';
