# RLS Policy Fix - Business Signup

## Problem
Business signup was failing with error:
```
new row violates row-level security policy for table 'business_partners' (code: 42501)
```

## Root Cause
The original RLS INSERT policy had `WITH CHECK (true)` which should allow anyone to insert, but Supabase RLS requires an **authenticated session** to properly evaluate policies when inserting records with a `user_id` foreign key to `auth.users`.

When `signUp()` creates a user, it doesn't automatically establish an authenticated session in the same transaction, so the subsequent INSERT fails.

## Solution Applied

### 1. Updated RLS Policy
**File:** `supabase/migrations/20251107_create_business_partners.sql` (Lines 142-151)

**Before:**
```sql
CREATE POLICY "Anyone can create business profile"
ON business_partners
FOR INSERT
WITH CHECK (true);
```

**After:**
```sql
CREATE POLICY "Anyone can create business profile"
ON business_partners
FOR INSERT
TO authenticated, anon
WITH CHECK (
    -- Allow if user_id matches the authenticated user (for signup flow)
    (auth.uid() = user_id) OR
    -- Allow if user is anonymous and user_id is being set (during signup process)
    (auth.role() = 'anon' AND user_id IS NOT NULL)
);
```

This policy now explicitly allows:
- Authenticated users to create their own profile
- Anonymous users to insert during the signup process (as fallback)

### 2. Updated Signup Flow
**File:** `pages/business-signup.html` (Lines 468-510)

**New Steps:**
1. `signUp()` - Create auth user account
2. **`signInWithPassword()` - Immediately establish authenticated session** ← NEW
3. `insert()` - Create business_partners record (now with valid session)

**Key Code Addition:**
```javascript
// Step 2: Sign in immediately to establish session (required for RLS)
console.log('Step 3: Establishing authenticated session...');
const { data: sessionData, error: sessionError } = await supabaseClient.auth.signInWithPassword({
    email: businessData.contactEmail,
    password: businessData.password
});

if (sessionError) {
    console.error('Session error:', sessionError);
    // If email confirmation required, inform user
    if (sessionError.message.includes('Email not confirmed')) {
        showSuccessMessage('✅ Account created! Please check your email to confirm your account before continuing.');
        return;
    }
    throw new Error('Failed to establish session: ' + sessionError.message);
}
```

This ensures that:
- The authenticated session is established before attempting INSERT
- RLS policy can properly verify `auth.uid() = user_id`
- If email confirmation is required, user is informed gracefully

## Email Confirmation Handling

By default, Supabase requires email confirmation. The signup flow now handles this:

**Development/Testing:**
- Disable email confirmation in Supabase Dashboard: Authentication > Email Auth > "Enable email confirmations" = OFF
- This allows immediate sign-in after signup

**Production:**
- Keep email confirmation enabled
- User will receive "Please check your email" message
- After confirming email, they can sign in and complete profile

## Testing Steps

1. **Run Migration:**
   - Open Supabase Dashboard > SQL Editor
   - Paste contents of `20251107_create_business_partners.sql`
   - Click "Run"
   - Verify success message

2. **Disable Email Confirmation (for testing):**
   - Supabase Dashboard > Authentication > Providers > Email
   - Turn OFF "Enable email confirmations"
   - Save changes

3. **Test Signup:**
   - Open `test_business_signup.html` in browser
   - Click "Create Test Business" button
   - Should see success message and redirect to offer-application.html
   - Check Supabase Dashboard > Authentication > Users (should see new user)
   - Check Supabase Dashboard > Table Editor > business_partners (should see new record)

4. **Verify Console Logs:**
   ```
   Step 1: Creating auth user...
   Step 2: Auth user created: <user-id>
   Step 3: Establishing authenticated session...
   Step 4: Session established, creating business partner record...
   Success! Business partner created: <partner-id>
   ```

## What Changed

### Database (Migration File)
- ✅ RLS INSERT policy now explicitly checks `auth.uid() = user_id`
- ✅ Policy targets both `authenticated` and `anon` roles
- ✅ Dual conditions allow flexibility during signup process

### Frontend (business-signup.html)
- ✅ Added immediate sign-in after signup
- ✅ Added session establishment step
- ✅ Added email confirmation handling
- ✅ Updated console logging for debugging
- ✅ Graceful error messages for email confirmation

## Next Steps

1. Run the updated migration in Supabase Dashboard
2. Test complete signup flow with test_business_signup.html
3. Verify business_partners record created successfully
4. Proceed to Phase 2: Rebuild offer-application.html

## Lessons Learned

- **RLS Policies:** `WITH CHECK (true)` doesn't guarantee success if FK constraints point to auth.users
- **Session Timing:** Must establish authenticated session before INSERT operations that reference auth.uid()
- **Email Confirmation:** Always handle both confirmed and unconfirmed states gracefully
- **Testing:** Diagnostic dashboards are essential for catching these issues early
- **Error Visibility:** High z-index error messages help users (and developers) see what's happening

## Reference

- **Supabase RLS Documentation:** https://supabase.com/docs/guides/auth/row-level-security
- **Auth Helpers:** https://supabase.com/docs/guides/auth/auth-helpers
- **Common RLS Patterns:** https://supabase.com/docs/guides/database/postgres/row-level-security#common-rls-patterns
