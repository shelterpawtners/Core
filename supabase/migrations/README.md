# Supabase Database Migrations

## Overview
This directory contains SQL migration files for the Shelter Pawtners partner management system.

## Two-Table Architecture

### 1. `business_partners` Table
- **Purpose**: Business profile and contact information
- **Key Features**:
  - Linked to Supabase Auth (`user_id` → `auth.users.id`)
  - Individual social media URL fields (7 fields)
  - Contact person information
  - Partnership tier (basic/featured/premium)
  - Admin controls: `active` (can disable login/offers), `verified` (marketplace badge)
  - Self-service enabled by default

### 2. `partner_offers` Table
- **Purpose**: Individual discount offers from businesses
- **Key Features**:
  - One-to-many relationship with `business_partners`
  - Multiple discount types (percentage, fixed_amount, bogo, free_item, other)
  - Analytics tracking (views, clicks, redemptions)
  - Validity period and max redemptions
  - Self-service creation, admin can disable via `approved` flag
  - Partner can toggle `active` status anytime

## Running Migrations

### Option 1: Supabase CLI (Recommended)
```bash
# Install Supabase CLI if not already installed
npm install -g supabase

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref nudwqhncbctyqkhafttd

# Run migrations
supabase db push

# Or run individually
supabase db execute -f supabase/migrations/20251107_create_business_partners.sql
supabase db execute -f supabase/migrations/20251107_create_partner_offers.sql
```

### Option 2: Supabase Dashboard SQL Editor
1. Go to https://supabase.com/dashboard/project/nudwqhncbctyqkhafttd/sql
2. Copy and paste the contents of each migration file
3. Run in order:
   - `20251107_create_business_partners.sql` (run first)
   - `20251107_create_partner_offers.sql` (run second)

### Option 3: Direct PostgreSQL Connection
```bash
# Connect to Supabase PostgreSQL directly
psql "postgresql://postgres:[YOUR-PASSWORD]@db.nudwqhncbctyqkhafttd.supabase.co:5432/postgres"

# Run migrations
\i supabase/migrations/20251107_create_business_partners.sql
\i supabase/migrations/20251107_create_partner_offers.sql
```

## Migration Files

### `20251107_create_business_partners.sql`
Creates the business profiles table with:
- ✅ Supabase Auth integration
- ✅ Business core info (name, type, contact)
- ✅ 7 individual social media URL fields
- ✅ Contact person fields
- ✅ Partnership tier and verification
- ✅ Admin controls (active/verified flags)
- ✅ Row Level Security (RLS) policies
- ✅ Automated `updated_at` trigger
- ✅ Performance indexes

### `20251107_create_partner_offers.sql`
Creates the offers table with:
- ✅ Foreign key to `business_partners`
- ✅ 5 discount types with validation
- ✅ Analytics (views, clicks, redemptions)
- ✅ Validity period and max redemptions
- ✅ Service area for mobile businesses
- ✅ Self-service creation (approved by default)
- ✅ Admin can disable via `approved` flag
- ✅ RLS policies for partner self-management
- ✅ Helper functions for analytics
- ✅ Automated `updated_at` trigger

## Row Level Security (RLS)

### business_partners Policies
1. **Partners can view own profile** - `SELECT` where `auth.uid() = user_id`
2. **Partners can update own profile** - `UPDATE` but cannot change `active` or `verified` (admin only)
3. **Anyone can create business profile** - `INSERT` for signup (no auth required)
4. **Public can view active businesses** - `SELECT` where `active = TRUE AND verified = TRUE`

### partner_offers Policies
1. **Partners can view own offers** - `SELECT` their business's offers
2. **Partners can create offers** - `INSERT` if business is active
3. **Partners can update own offers** - `UPDATE` but cannot change `approved` (admin only)
4. **Partners can delete own offers** - `DELETE` (soft delete via `active = FALSE` preferred)
5. **Public can view active offers** - `SELECT` where active, approved, non-expired, from verified businesses

## Helper Functions

### `increment_offer_views(offer_id UUID)`
Increments view count and updates last_viewed_at timestamp.

### `increment_offer_clicks(offer_id UUID)`
Increments click count when user clicks "Get Offer" button.

### `increment_offer_redemptions(offer_id UUID)`
Increments redemption count, checks max_redemptions limit, returns boolean success.

## Verification

After running migrations, verify with these queries:

```sql
-- Check tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('business_partners', 'partner_offers');

-- Check RLS is enabled
SELECT tablename, rowsecurity FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('business_partners', 'partner_offers');

-- View all policies
SELECT schemaname, tablename, policyname, cmd 
FROM pg_policies 
WHERE tablename IN ('business_partners', 'partner_offers');

-- Check indexes
SELECT tablename, indexname FROM pg_indexes 
WHERE schemaname = 'public' 
AND tablename IN ('business_partners', 'partner_offers');
```

## Next Steps

After running migrations:

1. ✅ **Update business-signup.html** - Add social media fields, remove offer fields, target `business_partners` table
2. ⏳ **Rebuild offer-application.html** - Create offer-specific form targeting `partner_offers` table
3. ⏳ **Create partner-dashboard.html** - Partner control center for managing offers
4. ⏳ **Update partner-offers.html** - Query `partner_offers` joined with `business_partners`
5. ⏳ **Create partner-login.html** - Supabase Auth login page
6. ⏳ **Set up email templates** - Signup confirmation, password reset, etc.

## Rollback

To rollback migrations:

```sql
-- Drop tables in reverse order
DROP TABLE IF EXISTS partner_offers CASCADE;
DROP TABLE IF EXISTS business_partners CASCADE;

-- Drop helper functions
DROP FUNCTION IF EXISTS increment_offer_views(UUID);
DROP FUNCTION IF EXISTS increment_offer_clicks(UUID);
DROP FUNCTION IF EXISTS increment_offer_redemptions(UUID);
DROP FUNCTION IF EXISTS update_business_partners_updated_at();
DROP FUNCTION IF EXISTS update_partner_offers_updated_at();
```

## Support

For questions or issues:
- Supabase Docs: https://supabase.com/docs
- Project Dashboard: https://supabase.com/dashboard/project/nudwqhncbctyqkhafttd
