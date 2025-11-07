# User Management Dashboard - Features Overview

## Lock/Unlock User Functionality

### What the Lock Button Does:

1. **When you click "Lock":**
   - Sets the `locked_at` timestamp in the user's profile
   - Prevents the user from logging in (if RLS policies are configured to check this)
   - Changes the status badge to show "locked"
   - Button text changes to "Unlock"

2. **When you click "Unlock":**
   - Clears the `locked_at` timestamp (sets it to null)
   - Re-enables login access for the user
   - Changes the status badge back to "active"
   - Button text changes back to "Lock"

3. **Use Cases:**
   - Temporarily suspend a user account for security reasons
   - Prevent access while investigating account issues
   - Implement account suspension policies
   - Quick disable without deleting the account

### Remove Button Functionality:

- Soft-deletes the user by setting `removed_at` timestamp
- Marks the account as removed in the system
- Can be used for permanent account deactivation
- Better than hard-delete for audit trail purposes

## User Types

The system supports four user types:

1. **Pet Parent** - Regular users who have adopted pets
2. **Business** - Service providers (vets, groomers, trainers, etc.)
3. **Shelter** - Animal shelters and rescue organizations
4. **Admin** - System administrators with full access

### User Type Features:

- **Dropdown Selection**: Admins can change user types from the dashboard
- **Automatic Saving**: Changes are saved immediately when selected
- **Visual Labels**: Each type has a clear, readable label
- **Database Validation**: User types are validated at the database level

## Current User List (4 users):

1. Jim Ward (jimwardjr@outlook.com) - Pet Parent
2. Admin (admin@shelterpawtners.com) - Pet Parent
3. Jim Ward (irishjimmyward@gmail.com) - Pet Parent - **Your Account**
4. Test User (test1761401071914@gmail.com) - Pet Parent

## Security Features:

✅ **Edge Functions** - All operations go through secure server-side functions
✅ **Admin Verification** - Only verified admins can access this dashboard
✅ **JWT Authentication** - Requires valid session token
✅ **No Exposed Keys** - Service role key is only used server-side
✅ **CORS Protection** - Proper cross-origin resource sharing configured

## Next Steps:

To make the Lock functionality work with authentication:
1. Update RLS policies to check `locked_at` field
2. Add logic in auth flow to prevent login for locked users
3. Consider adding unlock reason/notes for audit trail
