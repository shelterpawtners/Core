# 🎯 Quick Reference: Partner Management System

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     TWO-TABLE SYSTEM                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  business_partners (36 columns)                                 │
│  ├── Business profile & contact info                            │
│  ├── 7 social media URLs                                        │
│  ├── Partnership tier (basic/featured/premium)                  │
│  ├── Admin controls (active/verified)                           │
│  └── Linked to: auth.users (user_id)                            │
│                                                                 │
│  partner_offers (29 columns)                                    │
│  ├── Offer details (title, description)                         │
│  ├── 5 discount types                                           │
│  ├── Analytics (views, clicks, redemptions)                     │
│  ├── Validity period & limits                                   │
│  └── Linked to: business_partners (business_id)                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## User Journey

```
1. SIGNUP (business-signup.html)
   ├── Fill business info + contact person + social media
   ├── Create password
   ├── Select partnership tier
   ├── Submit → Creates auth user + business_partners record
   └── Redirect to step 2 ↓

2. CREATE FIRST OFFER (offer-application.html)
   ├── Auto-populated with business_id
   ├── Fill offer details (title, discount, restrictions)
   ├── Upload offer photo
   ├── Submit → Creates partner_offers record
   └── Redirect to step 3 ↓

3. MANAGE OFFERS (partner-dashboard.html)
   ├── View all offers
   ├── Toggle active/inactive
   ├── Edit existing offers
   ├── Create new offers
   ├── View analytics
   └── Update business profile

4. PUBLIC VIEWS OFFERS (partner-offers.html)
   ├── Browse active offers
   ├── Filter by type/location
   ├── View offer details
   ├── Track analytics (views/clicks)
   └── Redeem offer with ShelterCARD
```

## Database Tables

### business_partners
```sql
Key Fields:
- id (UUID, PK)
- user_id (UUID, FK → auth.users.id)
- business_name, business_type, email, phone, website
- address, city, state, zip_code
- contact_first_name, contact_last_name, contact_email, contact_phone
- business_hours, description
- facebook_url, instagram_url, tiktok_url, x_url, linkedin_url, pinterest_url, other_social_url
- partnership_tier (basic/featured/premium)
- verified (admin badge), active (admin can disable)
- logo_url, cover_photo_url
- created_at, updated_at, last_login

Indexes: user_id, email, business_type, city, active, verified
RLS Policies: 4 policies (partner self-service + public read)
```

### partner_offers
```sql
Key Fields:
- id (UUID, PK)
- business_id (UUID, FK → business_partners.id)
- offer_title, offer_description
- discount_type (percentage/fixed_amount/bogo/free_item/other)
- discount_percentage, discount_value, discount_details
- services (array), special_instructions, restrictions
- redemption_code, max_redemptions, current_redemptions
- valid_from, valid_until
- service_area (array), online_only, in_store_only
- active (partner toggle), approved (admin control), featured
- offer_image_url, thumbnail_url
- view_count, click_count, redemption_count
- last_viewed_at, last_redeemed_at
- created_at, updated_at

Indexes: business_id, active, approved, featured, valid_until, discount_type
Composite Index: (active, approved, featured, valid_until) for marketplace
RLS Policies: 5 policies (partner CRUD + public read)
Helper Functions: increment_offer_views(), increment_offer_clicks(), increment_offer_redemptions()
```

## Page Status

| Page | Status | Purpose | Database Table |
|------|--------|---------|----------------|
| business-signup.html | ✅ UPDATED | Create account | business_partners |
| partner-login.html | ⏳ TO CREATE | Login | auth.users |
| offer-application.html | ⏳ TO REBUILD | Create/edit offers | partner_offers |
| partner-dashboard.html | ⏳ TO CREATE | Manage offers | both tables |
| partner-offers.html | ⏳ TO UPDATE | Public marketplace | both tables (JOIN) |

## Implementation Phases

### ✅ PHASE 1: COMPLETE
- [x] Create business_partners migration
- [x] Create partner_offers migration
- [x] Update business-signup.html with new fields
- [x] Add Supabase Auth integration
- [x] Remove offer fields from signup
- [x] Add redirect to offer creation

### ⏳ PHASE 2: NEXT (Waiting on you)
- [ ] Run migrations in Supabase Dashboard
- [ ] Verify tables created successfully
- [ ] Test business signup flow
- [ ] Begin offer-application.html rebuild

### ⏳ PHASE 3: FUTURE
- [ ] Create partner-dashboard.html
- [ ] Create partner-login.html
- [ ] Update partner-offers.html query
- [ ] Implement analytics tracking

## Key Files

```
/workspaces/Core/
├── supabase/
│   └── migrations/
│       ├── 20251107_create_business_partners.sql ✅
│       ├── 20251107_create_partner_offers.sql ✅
│       └── README.md ✅
├── pages/
│   ├── business-signup.html ✅ UPDATED
│   ├── partner-login.html ⏳ TO CREATE
│   ├── offer-application.html ⏳ TO REBUILD
│   ├── partner-dashboard.html ⏳ TO CREATE
│   └── partner-offers.html ⏳ TO UPDATE
├── MIGRATION_GUIDE.md ✅ Instructions for running migrations
├── PHASE1_COMPLETE.md ✅ Detailed summary
└── QUICK_REFERENCE.md ✅ This file
```

## Important Links

- **Supabase Dashboard:** https://supabase.com/dashboard/project/nudwqhncbctyqkhafttd
- **SQL Editor:** https://supabase.com/dashboard/project/nudwqhncbctyqkhafttd/sql
- **Auth Settings:** https://supabase.com/dashboard/project/nudwqhncbctyqkhafttd/auth/users
- **Table Editor:** https://supabase.com/dashboard/project/nudwqhncbctyqkhafttd/editor

## Admin Controls

### To Disable a Partner:
```sql
UPDATE business_partners 
SET active = FALSE 
WHERE id = 'partner_id';
-- Partner can no longer login or create offers
```

### To Verify a Partner:
```sql
UPDATE business_partners 
SET verified = TRUE 
WHERE id = 'partner_id';
-- Partner gets verified badge in marketplace
```

### To Disable an Offer:
```sql
UPDATE partner_offers 
SET approved = FALSE 
WHERE id = 'offer_id';
-- Offer hidden from marketplace
```

### To Feature an Offer:
```sql
UPDATE partner_offers 
SET featured = TRUE 
WHERE id = 'offer_id';
-- Offer appears first in marketplace
```

## Testing Queries

### View All Business Partners:
```sql
SELECT 
    id, business_name, business_type, email, 
    partnership_tier, verified, active, created_at
FROM business_partners
ORDER BY created_at DESC;
```

### View All Offers with Business Info:
```sql
SELECT 
    po.offer_title,
    po.discount_type,
    po.discount_percentage,
    po.active,
    po.approved,
    bp.business_name,
    bp.business_type,
    bp.city,
    bp.state
FROM partner_offers po
JOIN business_partners bp ON po.business_id = bp.id
ORDER BY po.created_at DESC;
```

### Count Offers by Business:
```sql
SELECT 
    bp.business_name,
    COUNT(po.id) as total_offers,
    SUM(CASE WHEN po.active = TRUE THEN 1 ELSE 0 END) as active_offers
FROM business_partners bp
LEFT JOIN partner_offers po ON bp.id = po.business_id
GROUP BY bp.id, bp.business_name
ORDER BY total_offers DESC;
```

---

**Ready for Phase 2?** Run the migrations then let me know! 🚀
