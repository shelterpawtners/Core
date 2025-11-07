# Two-Table Partner System: Implementation Plan
## Business Registration → Offer Management Workflow

---

## 🎯 REVISED ARCHITECTURE

### Two-Table System Design

```
┌─────────────────────────────────────────────────────────────┐
│                    PARTNER WORKFLOW                          │
└─────────────────────────────────────────────────────────────┘

Step 1: Business Registration (business-signup.html)
   ↓
   Creates record in → business_partners table
   ↓
Step 2: Create First Offer (offer-application.html)
   ↓
   Creates record in → partner_offers table
   ↓
Step 3: Partner Dashboard (partner-dashboard.html)
   ↓
   Manage/Edit/Create → multiple offers in partner_offers table
```

---

## 📊 TABLE 1: business_partners (The Business Profile)

**Purpose**: Store business information, contact details, and account settings
**Created By**: business-signup.html form
**One record per business**

### Schema:

```sql
CREATE TABLE business_partners (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Business Core Information
    business_name TEXT NOT NULL,
    business_type TEXT NOT NULL CHECK (business_type IN (
        'veterinarian', 'groomer', 'trainer', 'pet_store', 'boarding',
        'daycare', 'walker', 'sitter', 'photography', 'nutrition', 'other'
    )),
    
    -- Business Contact Information
    email TEXT NOT NULL UNIQUE, -- Used for login
    phone TEXT,
    website TEXT,
    
    -- Business Location
    address TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT,
    
    -- Contact Person (Admin User)
    contact_first_name TEXT,
    contact_last_name TEXT,
    contact_email TEXT, -- Personal email, can differ from business email
    contact_phone TEXT,
    contact_title TEXT,
    
    -- Business Details
    business_hours TEXT,
    description TEXT, -- About the business
    
    -- Social Media Links (Individual fields for each platform)
    facebook_url TEXT,
    instagram_url TEXT,
    tiktok_url TEXT,
    x_url TEXT, -- Formerly Twitter
    linkedin_url TEXT,
    pinterest_url TEXT,
    other_social_url TEXT,
    
    -- Account Status
    partnership_tier TEXT DEFAULT 'basic' CHECK (partnership_tier IN ('basic', 'featured', 'premium')),
    verified BOOLEAN DEFAULT FALSE, -- Admin verified
    active BOOLEAN DEFAULT TRUE, -- Can login and manage offers
    featured_until TIMESTAMPTZ, -- When featured/premium tier expires
    
    -- Business Assets
    logo_url TEXT,
    cover_photo_url TEXT,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_login TIMESTAMPTZ
);
```

---

## 📊 TABLE 2: partner_offers (Individual Discount Offers)

**Purpose**: Store specific discount offers from partners
**Created By**: offer-application.html form
**Multiple offers per business allowed**

### Schema:

```sql
CREATE TABLE partner_offers (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Foreign Key to Business
    business_id UUID NOT NULL REFERENCES business_partners(id) ON DELETE CASCADE,
    
    -- Offer Details
    offer_title TEXT NOT NULL, -- "25% Off First Visit", "BOGO Training Sessions"
    offer_description TEXT NOT NULL, -- Full description of the offer
    discount_percentage INTEGER CHECK (discount_percentage >= 0 AND discount_percentage <= 100),
    discount_type TEXT CHECK (discount_type IN ('percentage', 'fixed_amount', 'bogo', 'free_item', 'other')),
    discount_value DECIMAL(10,2), -- For fixed amount discounts like "$20 off"
    
    -- Offer Specifics
    services TEXT[], -- Which services/products this applies to
    special_instructions TEXT, -- How to redeem: "Show ShelterCARD at checkout"
    restrictions TEXT, -- "New clients only", "Cannot combine with other offers"
    terms_conditions TEXT, -- Full terms and conditions
    
    -- Offer Availability
    valid_from DATE,
    valid_until DATE, -- NULL = ongoing offer
    max_redemptions INTEGER, -- NULL = unlimited
    current_redemptions INTEGER DEFAULT 0,
    
    -- Offer Visibility
    active BOOLEAN DEFAULT TRUE, -- Partner can turn on/off
    featured BOOLEAN DEFAULT FALSE, -- Admin can feature specific offers
    priority INTEGER DEFAULT 0, -- Display order (higher = shown first)
    
    -- Offer Media
    offer_image_url TEXT,
    offer_photos TEXT[], -- Array of image URLs
    
    -- Service Area (for mobile services)
    service_area TEXT[], -- ["Austin", "Round Rock", "Cedar Park"]
    online_only BOOLEAN DEFAULT FALSE,
    
    -- Analytics
    view_count INTEGER DEFAULT 0,
    click_count INTEGER DEFAULT 0,
    redemption_count INTEGER DEFAULT 0,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    approved_by UUID, -- Admin who approved
    approved_at TIMESTAMPTZ
);

-- Indexes for performance
CREATE INDEX idx_partner_offers_business_id ON partner_offers(business_id);
CREATE INDEX idx_partner_offers_active ON partner_offers(active);
CREATE INDEX idx_partner_offers_valid_until ON partner_offers(valid_until);
```

---

## 🔄 USER WORKFLOW

### Step 1: Business Registration (business-signup.html)

**Form Fields:**
1. Business Information
   - Business Name*
   - Business Type* (dropdown)
   - Business Email* (login email)
   - Business Phone*
   - Website
   
2. Location
   - Address*
   - City*
   - State*
   - ZIP Code*
   
3. Contact Person
   - First Name*
   - Last Name*
   - Email* (personal)
   - Phone*
   - Job Title
   
4. Business Details
   - Business Hours
   - About Your Business (description)
   
5. Social Media (all optional)
   - Facebook URL
   - Instagram URL
   - TikTok URL
   - X (Twitter) URL
   - LinkedIn URL
   - Pinterest URL
   - Other Social Media
   
6. Upload Logo (optional)

7. Partnership Tier
   - Basic (Free)
   - Featured ($49/month)
   - Premium ($99/month)

**On Submit:**
```javascript
1. Create business_partners record
2. Set active = FALSE (pending approval)
3. Send verification email
4. Redirect to → offer-application.html?business_id=XXX
```

---

### Step 2: Create First Offer (offer-application.html)

**Form Fields:**
1. Offer Basics
   - Offer Title* ("25% Off First Vet Visit")
   - Offer Description*
   
2. Discount Details
   - Discount Type* (dropdown: percentage, fixed amount, BOGO, free item, other)
   - Discount Percentage OR Fixed Amount*
   
3. What's Included
   - Services/Products* (textarea or multi-select)
   
4. Redemption Instructions
   - How to Redeem* ("Show ShelterCARD when scheduling")
   - Restrictions (optional: "New clients only")
   - Terms & Conditions (optional)
   
5. Availability
   - Start Date (default: today)
   - End Date (optional: ongoing if empty)
   - Max Redemptions (optional: unlimited if empty)
   
6. Service Area (if applicable)
   - Cities Served (for mobile services)
   - Online Only? (checkbox)
   
7. Offer Photos (optional)
   - Upload images

**On Submit:**
```javascript
1. Create partner_offers record linked to business_id
2. Set active = FALSE (pending approval)
3. Show success message
4. Redirect to → partner-dashboard.html
```

---

### Step 3: Partner Dashboard (partner-dashboard.html)

**Dashboard Sections:**

1. **Business Profile Card**
   - Business name, logo
   - Partnership tier badge
   - "Edit Profile" button → business-signup.html (edit mode)

2. **My Offers** (Grid/List View)
   - Display all offers for this business
   - Each offer shows:
     * Offer title
     * Status badge (Active/Pending/Expired)
     * View count, clicks, redemptions
     * Edit button → offer-application.html?offer_id=XXX (edit mode)
     * Delete button (soft delete: set active=FALSE)
     * Toggle Active/Inactive switch

3. **Quick Stats**
   - Total Offers: 5
   - Active Offers: 3
   - Total Views: 1,234
   - Total Redemptions: 45

4. **Create New Offer** Button
   - → offer-application.html (create mode)

5. **Account Settings**
   - Change password
   - Notification preferences
   - Billing (if featured/premium)

---

## 📄 PAGE MODIFICATIONS NEEDED

### 1. business-signup.html (EXISTING - MODIFY)

**Changes Needed:**
- ✅ Keep all existing business fields
- ✅ Add social media fields (7 individual inputs)
- ✅ Add business hours field
- ✅ Add description/about field
- ✅ Add logo upload
- ❌ **REMOVE**: discount_percentage field (moves to offer form)
- ❌ **REMOVE**: services field (moves to offer form)
- ❌ **REMOVE**: comments field (not needed)

**On Submit:**
```javascript
// Insert into business_partners table
// Redirect to: offer-application.html?new=true
```

---

### 2. offer-application.html (EXISTING - REBUILD)

**Current State**: Check what's there
**New Purpose**: Create/Edit individual offers

**Form Modes:**
1. **Create Mode**: `offer-application.html?new=true`
   - Empty form
   - Submit creates new partner_offers record
   
2. **Edit Mode**: `offer-application.html?offer_id=XXX`
   - Pre-populate form with existing offer data
   - Submit updates existing record

**Form Fields**: (Listed above in Step 2)

**On Submit:**
```javascript
if (offer_id exists) {
    // UPDATE existing offer
    supabase.from('partner_offers').update(data).eq('id', offer_id)
} else {
    // INSERT new offer
    supabase.from('partner_offers').insert(data)
}
// Redirect to: partner-dashboard.html
```

---

### 3. partner-dashboard.html (NEW - CREATE)

**Purpose**: Central hub for partners to manage their offers

**Layout:**
```
┌─────────────────────────────────────────────────────┐
│  Header: Welcome, [Business Name]!                  │
│  Your partnership tier: [Basic/Featured/Premium]    │
└─────────────────────────────────────────────────────┘

┌───────────────────┐ ┌───────────────────┐ ┌─────────┐
│  Total Offers: 5  │ │  Total Views: 1.2K│ │  Active │
└───────────────────┘ └───────────────────┘ └─────────┘

┌─────────────────────────────────────────────────────┐
│  [+ Create New Offer]                                │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  My Offers                          [Grid] [List]    │
├─────────────────────────────────────────────────────┤
│  ┌──────────────────┐  ┌──────────────────┐         │
│  │ 25% Off First    │  │ BOGO Training    │         │
│  │ Vet Visit        │  │ Sessions         │         │
│  │ ────────────     │  │ ────────────     │         │
│  │ Views: 234       │  │ Views: 156       │         │
│  │ Redeemed: 12     │  │ Redeemed: 8      │         │
│  │ [Edit] [Delete]  │  │ [Edit] [Delete]  │         │
│  │ [🟢 Active]      │  │ [🟢 Active]      │         │
│  └──────────────────┘  └──────────────────┘         │
└─────────────────────────────────────────────────────┘
```

**Required Functionality:**
- Fetch offers: `SELECT * FROM partner_offers WHERE business_id = current_user_business_id`
- Toggle active status
- Delete offer (soft delete)
- Edit offer → redirect to offer-application.html?offer_id=XXX
- Create offer → redirect to offer-application.html?new=true
- View analytics

---

### 4. partner-offers.html (EXISTING - MODIFY)

**Changes Needed:**

**Current Query:**
```javascript
// WRONG - queries business_partners directly
SELECT * FROM business_partners
```

**New Query:**
```javascript
// CORRECT - queries partner_offers joined with business info
SELECT 
    po.*,
    bp.business_name,
    bp.business_type,
    bp.city,
    bp.state,
    bp.phone,
    bp.email,
    bp.website,
    bp.logo_url
FROM partner_offers po
JOIN business_partners bp ON po.business_id = bp.id
WHERE po.active = TRUE
  AND po.valid_until >= NOW() OR po.valid_until IS NULL
  AND bp.active = TRUE
  AND bp.verified = TRUE
ORDER BY po.priority DESC, po.created_at DESC
```

**Offer Card Display:**
- Show offer_title (not business_name as main title)
- Show business_name as subtitle
- Show offer_description
- Show discount_percentage or discount_value
- Show special_instructions
- Show restrictions
- Link to business website/social media

---

## 🗂️ FILE STRUCTURE

```
/workspaces/Core/
├── pages/
│   ├── business-signup.html       ← Step 1: Register business
│   ├── offer-application.html     ← Step 2: Create/Edit offers
│   ├── partner-dashboard.html     ← NEW: Manage offers
│   ├── partner-offers.html        ← Public marketplace (modified query)
│   └── partner-login.html         ← NEW: Partner login page
├── js/
│   ├── partner-auth.js            ← NEW: Partner authentication
│   ├── partner-dashboard.js       ← NEW: Dashboard functionality
│   └── offer-manager.js           ← NEW: Offer CRUD operations
└── supabase/
    └── migrations/
        ├── create_business_partners.sql
        ├── create_partner_offers.sql
        └── create_rls_policies.sql
```

---

## 🔐 AUTHENTICATION & AUTHORIZATION

### Auth Flow:

1. **Partner Signs Up** (business-signup.html)
   - Creates business_partners record
   - Creates Supabase Auth user with business email
   - Sends verification email

2. **Partner Logs In** (partner-login.html)
   - Supabase Auth login
   - Redirect to partner-dashboard.html

3. **Row Level Security (RLS)**

```sql
-- Business Partners RLS
CREATE POLICY "Partners can view own data" 
ON business_partners FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Partners can update own data" 
ON business_partners FOR UPDATE 
USING (auth.uid() = user_id);

-- Partner Offers RLS
CREATE POLICY "Partners can view own offers" 
ON partner_offers FOR SELECT 
USING (
    business_id IN (
        SELECT id FROM business_partners WHERE user_id = auth.uid()
    )
);

CREATE POLICY "Partners can manage own offers" 
ON partner_offers FOR ALL 
USING (
    business_id IN (
        SELECT id FROM business_partners WHERE user_id = auth.uid()
    )
);

-- Public can view active approved offers
CREATE POLICY "Public can view active offers" 
ON partner_offers FOR SELECT 
USING (active = TRUE AND approved_at IS NOT NULL);
```

---

## ✅ IMPLEMENTATION CHECKLIST

### Phase 1: Database Setup
- [ ] Create business_partners table with all fields
- [ ] Create partner_offers table with all fields
- [ ] Add user_id to business_partners (link to Supabase Auth)
- [ ] Create indexes for performance
- [ ] Set up RLS policies
- [ ] Add triggers for updated_at timestamps

### Phase 2: Business Registration (business-signup.html)
- [ ] Add 7 individual social media fields
- [ ] Add business_hours field
- [ ] Add description field
- [ ] Add logo upload functionality
- [ ] Remove discount_percentage, services, comments fields
- [ ] Update submit handler to create business_partners record
- [ ] Create Supabase Auth user
- [ ] Redirect to offer-application.html after signup

### Phase 3: Offer Management (offer-application.html)
- [ ] Rebuild form with offer-specific fields
- [ ] Add create/edit mode detection
- [ ] Pre-populate form in edit mode
- [ ] Add photo upload functionality
- [ ] Add service area selection
- [ ] Update submit handler for INSERT/UPDATE
- [ ] Add validation

### Phase 4: Partner Dashboard (partner-dashboard.html)
- [ ] Create dashboard layout
- [ ] Display business profile summary
- [ ] Display offers grid/list
- [ ] Add analytics cards
- [ ] Add edit/delete/toggle buttons
- [ ] Add "Create New Offer" button
- [ ] Implement offer filtering

### Phase 5: Marketplace Update (partner-offers.html)
- [ ] Update query to join partner_offers + business_partners
- [ ] Modify offer card template to show offer_title
- [ ] Add business_name as subtitle
- [ ] Display offer-specific fields
- [ ] Update modal to show full offer details

### Phase 6: Authentication
- [ ] Create partner-login.html
- [ ] Create partner-auth.js
- [ ] Implement Supabase Auth signup
- [ ] Implement Supabase Auth login
- [ ] Add password reset flow
- [ ] Protect dashboard with auth check

---

## 🎯 KEY BENEFITS OF THIS APPROACH

1. **Flexibility**: Businesses can have multiple offers (seasonal, product-specific, etc.)
2. **Analytics**: Track performance per offer, not just per business
3. **Management**: Partners can activate/deactivate offers independently
4. **Scalability**: Easy to add offer types, expiration dates, limits
5. **Better UX**: Cleaner marketplace showing actual offers, not just businesses
6. **A/B Testing**: Businesses can test different offer types
7. **Time-Limited Promotions**: Support for seasonal/holiday offers

---

## 🚀 NEXT STEPS

**Which phase should we start with?**

1. Create SQL migrations for both tables?
2. Update business-signup.html with new fields?
3. Rebuild offer-application.html?
4. Create partner-dashboard.html?
5. All of the above?

Let me know and I'll start building! 🔨
