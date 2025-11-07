-- Automatically sync user_id in admin_users table
-- This ensures admin records always have the correct user_id linked

-- Function to sync user_id based on email
CREATE OR REPLACE FUNCTION sync_admin_user_id()
RETURNS TRIGGER AS $$
BEGIN
  -- If user_id is not set but email is provided, try to find matching user
  IF NEW.user_id IS NULL AND NEW.email IS NOT NULL THEN
    SELECT id INTO NEW.user_id
    FROM auth.users
    WHERE email = NEW.email
    LIMIT 1;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for INSERT operations
DROP TRIGGER IF EXISTS sync_admin_user_id_on_insert ON admin_users;
CREATE TRIGGER sync_admin_user_id_on_insert
  BEFORE INSERT ON admin_users
  FOR EACH ROW
  EXECUTE FUNCTION sync_admin_user_id();

-- Create trigger for UPDATE operations
DROP TRIGGER IF EXISTS sync_admin_user_id_on_update ON admin_users;
CREATE TRIGGER sync_admin_user_id_on_update
  BEFORE UPDATE ON admin_users
  FOR EACH ROW
  WHEN (NEW.email IS DISTINCT FROM OLD.email OR NEW.user_id IS NULL)
  EXECUTE FUNCTION sync_admin_user_id();

-- Update existing admin records with null user_id
UPDATE admin_users a
SET user_id = u.id
FROM auth.users u
WHERE a.email = u.email
  AND a.user_id IS NULL;

-- Verify all admin records now have user_id
SELECT 
  id,
  email,
  full_name,
  role,
  active,
  user_id,
  CASE 
    WHEN user_id IS NULL THEN '❌ Missing'
    ELSE '✅ Set'
  END as user_id_status
FROM admin_users
ORDER BY created_at;
