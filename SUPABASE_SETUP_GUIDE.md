# 🚀 Supabase Setup Guide for Shelter Pawtners

## Step 1: Get Your Supabase Credentials

1. **Go to your Supabase Dashboard**: https://supabase.com/dashboard
2. **Select your project** (or create a new one if needed)
3. **Navigate to Settings > API**
4. **Copy these values**:
   - **Project URL** (looks like: `https://xyzabcdef.supabase.co`)
   - **Project API Keys > anon public** (long string starting with `eyJ...`)

## Step 2: Configure Your Application

1. **Open** `/workspaces/Core/js/supabase-config.js`
2. **Replace** the placeholder values:
   ```javascript
   const SUPABASE_CONFIG = {
       url: 'https://YOUR-PROJECT-ID.supabase.co', // Replace with your URL
       anonKey: 'eyJ...', // Replace with your anon key
   };
   ```

## Step 3: Create Database Schema

1. **Go to** Supabase Dashboard > SQL Editor
2. **Create a new query**
3. **Copy and paste** the entire contents of `/workspaces/Core/supabase-setup.sql`
4. **Click "Run"** to execute the schema
5. **Verify** tables were created in the Table Editor

## Step 4: Configure Authentication

1. **Go to** Supabase Dashboard > Authentication > Settings
2. **Enable Email/Password** provider (should be enabled by default)
3. **Optional: Configure Google OAuth**:
   - Go to Authentication > Settings > Auth Providers
   - Click on Google
   - Add your Google OAuth credentials
   - Set redirect URLs to include your domain

## Step 5: Test the Connection

1. **Start your local server**:
   ```bash
   cd /workspaces/Core
   python3 -m http.server 8080 --bind 0.0.0.0
   ```

2. **Open your browser** to `http://localhost:8080`

3. **Test the registration flow**:
   - Click "Pet Parents" button on homepage
   - Fill out registration form
   - Check Supabase Dashboard > Authentication > Users to see new user
   - Check Table Editor > user_profiles to see profile created

4. **Test login**:
   - Go to login page
   - Use credentials you just created
   - Should redirect to dashboard

## Step 6: Verify Database Tables

After running the schema, you should see these tables in Supabase Table Editor:

- ✅ `user_profiles` - User profile information
- ✅ `pets` - Pet records linked to users
- ✅ `medical_records` - Pet medical history
- ✅ `shelters` - Partner shelters
- ✅ `business_partners` - Service providers
- ✅ `savings_records` - User savings tracking

## What's Included in the Schema:

### 🔐 Security Features:
- **Row Level Security (RLS)** enabled on all tables
- **User isolation** - users can only see their own data
- **Automatic user profile creation** on signup
- **Secure authentication** with email verification

### 📊 Sample Data:
- **3 sample shelters** for testing
- **4 sample business partners** with different service types
- **Automated triggers** for updated_at timestamps

### 🔄 Real-time Features:
- **Automatic syncing** between client and database
- **Live updates** when data changes
- **Optimistic updates** for better UX

## Troubleshooting:

### ❌ "Supabase config not found"
- Make sure you've updated `supabase-config.js` with your real credentials
- Check that the URL and key don't contain placeholder text

### ❌ "Failed to create account" 
- Check Supabase Dashboard > Authentication > Settings
- Ensure email confirmation is configured as needed
- Check browser console for detailed error messages

### ❌ Tables not appearing
- Run the SQL schema again in Supabase SQL Editor
- Check for any error messages in the SQL execution
- Verify you have the correct permissions

### ❌ Login redirects to login page
- Check browser console for authentication errors
- Verify RLS policies are set up correctly
- Ensure user_profiles table has proper triggers

## 🎉 Success Indicators:

When everything is working:
- ✅ Registration creates new users in Supabase Auth
- ✅ User profiles are automatically created
- ✅ Login redirects to dashboard
- ✅ Dashboard shows user's name
- ✅ "Add Pet" form creates records in pets table
- ✅ Console shows "✅ Connected to Supabase database"

## Need Help?

If you run into issues:
1. Check the browser console for error messages
2. Check Supabase Dashboard > Logs for server-side errors
3. Verify all configuration values are correct
4. Test with a fresh browser session (clear cache)

## Next Steps After Setup:

1. **Deploy to production** (Netlify, Vercel, etc.)
2. **Configure custom domain** for Supabase
3. **Set up email templates** for user verification
4. **Add storage bucket** for pet photos
5. **Set up monitoring** and analytics