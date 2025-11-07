# 🚀 Quick Start: Run Database Migrations

## ✅ Email Verification Stays ENABLED (Security First!)

**We DO NOT disable email confirmation!** Instead, we use a database trigger to automatically create business_partners records while keeping security intact.

---

## Method 1: Supabase Dashboard SQL Editor (EASIEST - Recommended)

### Step 1: Open SQL Editor
1. Go to: https://supabase.com/dashboard/project/nudwqhncbctyqkhafttd/sql
2. Click "New query" button

### Step 2: Run First Migration (business_partners)
1. Copy the entire contents of `supabase/migrations/20251107_create_business_partners.sql`
2. Paste into the SQL editor
3. Click "Run" button (or press Cmd/Ctrl + Enter)
4. ✅ You should see "Success. No rows returned" message
5. Verify by running: `SELECT * FROM business_partners LIMIT 1;`

### Step 3: Run Second Migration (partner_offers)
1. Create another new query
2. Copy the entire contents of `supabase/migrations/20251107_create_partner_offers.sql`
3. Paste into the SQL editor
4. Click "Run" button
5. ✅ You should see "Success. No rows returned" message
6. Verify by running: `SELECT * FROM partner_offers LIMIT 1;`

### Step 3: Run Auth Trigger Migration (NEW - IMPORTANT!)
1. Create another new query
2. Copy the entire contents of `supabase/migrations/20251107_create_auth_trigger.sql`
3. Paste into the SQL editor
4. Click "Run" button
5. ✅ You should see "Success" message
6. This creates a trigger that auto-creates business_partners records on signup!

### Step 4: Verify Everything
Run this verification query:
```sql
-- Check both tables exist with RLS enabled
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('business_partners', 'partner_offers')
ORDER BY tablename;
```

You should see:
```
schemaname | tablename          | rls_enabled
-----------+--------------------+-------------
public     | business_partners  | true
public     | partner_offers     | true
```

---

## Method 2: Supabase CLI (For Developers)

### Install & Setup
```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link to project
supabase link --project-ref nudwqhncbctyqkhafttd
```

### Run Migrations
```bash
# From project root
cd /workspaces/Core

# Run all migrations
supabase db push

# Or run individually
supabase db execute -f supabase/migrations/20251107_create_business_partners.sql
supabase db execute -f supabase/migrations/20251107_create_partner_offers.sql
```

---

## What Gets Created?

### ✅ business_partners Table
- **36 columns** including:
  - Business info (name, type, contact)
  - 7 social media URL fields
  - Contact person fields
  - Partnership tier & verification
  - Admin controls (active/verified)
- **6 indexes** for performance
- **4 RLS policies** for security
- **Auto-updating** `updated_at` trigger

### ✅ partner_offers Table
- **29 columns** including:
  - Offer details (title, description)
  - 5 discount types
  - Analytics (views, clicks, redemptions)
  - Validity period & limits
  - Service area for mobile businesses
- **8 indexes** for performance
- **5 RLS policies** for partner self-service
- **3 helper functions** for analytics
- **Auto-updating** `updated_at` trigger

---

## Next: Update business-signup.html

Once migrations are complete, we'll update the business signup form to:
1. ✅ Add 7 individual social media URL fields
2. ✅ Add business hours field
3. ✅ Add description/about field
4. ✅ Add logo upload
5. ✅ Remove discount_percentage (moves to offer form)
6. ✅ Remove services textarea (moves to offer form)
7. ✅ Target `business_partners` table instead of `business_applications`
8. ✅ Integrate Supabase Auth for account creation
9. ✅ Redirect to offer-application.html after signup

---

## Troubleshooting

### Error: "relation already exists"
**Solution**: Tables already exist. Either:
1. Drop existing tables first:
   ```sql
   DROP TABLE IF EXISTS partner_offers CASCADE;
   DROP TABLE IF EXISTS business_partners CASCADE;
   ```
2. Or modify the migration to use `CREATE TABLE IF NOT EXISTS`

### Error: "permission denied for schema public"
**Solution**: Check you're using the correct project credentials in Supabase dashboard.

### RLS Not Working
**Solution**: Verify RLS is enabled:
```sql
SELECT tablename, rowsecurity FROM pg_tables 
WHERE tablename IN ('business_partners', 'partner_offers');
```

If `rowsecurity = false`, manually enable:
```sql
ALTER TABLE business_partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_offers ENABLE ROW LEVEL SECURITY;
```

---

## 📞 Need Help?

Let me know when migrations are complete and we'll move on to updating business-signup.html!
