-- ============================================
-- Migration: Create business_partners Table
-- Version: 1.0
-- Date: 2025-11-07
-- Description: Business profile table with Supabase Auth integration
-- ============================================

-- Drop table if exists (for clean re-runs in development)
DROP TABLE IF EXISTS business_partners CASCADE;

-- Create business_partners table
CREATE TABLE business_partners (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Link to Supabase Auth
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Business Core Information
    business_name TEXT NOT NULL,
    business_type TEXT NOT NULL CHECK (business_type IN (
        'veterinarian',
        'groomer',
        'trainer',
        'pet_store',
        'boarding',
        'daycare',
        'walker',
        'sitter',
        'photography',
        'nutrition',
        'other'
    )),
    
    -- Business Contact Information
    email TEXT NOT NULL UNIQUE, -- Business email, used for login
    phone TEXT,
    website TEXT,
    
    -- Business Location
    address TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT,
    
    -- Contact Person (Primary Admin User)
    contact_first_name TEXT,
    contact_last_name TEXT,
    contact_email TEXT, -- Personal email, can differ from business email
    contact_phone TEXT,
    contact_title TEXT,
    
    -- Business Details
    business_hours TEXT,
    description TEXT, -- About the business
    
    -- Social Media Links (Individual fields)
    facebook_url TEXT,
    instagram_url TEXT,
    tiktok_url TEXT,
    x_url TEXT, -- Formerly Twitter
    linkedin_url TEXT,
    pinterest_url TEXT,
    other_social_url TEXT,
    
    -- Account Status
    partnership_tier TEXT DEFAULT 'basic' CHECK (partnership_tier IN ('basic', 'featured', 'premium')),
    verified BOOLEAN DEFAULT FALSE, -- Admin verified badge
    active BOOLEAN DEFAULT TRUE, -- Can login and create offers (admin can disable)
    featured_until TIMESTAMPTZ, -- When featured/premium tier expires
    
    -- Business Assets
    logo_url TEXT,
    cover_photo_url TEXT,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_login TIMESTAMPTZ,
    
    -- Ensure user_id is unique (one business per auth user)
    CONSTRAINT unique_user_id UNIQUE (user_id)
);

-- Create indexes for performance
CREATE INDEX idx_business_partners_user_id ON business_partners(user_id);
CREATE INDEX idx_business_partners_email ON business_partners(email);
CREATE INDEX idx_business_partners_business_type ON business_partners(business_type);
CREATE INDEX idx_business_partners_city ON business_partners(city);
CREATE INDEX idx_business_partners_active ON business_partners(active);
CREATE INDEX idx_business_partners_verified ON business_partners(verified);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_business_partners_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER trigger_update_business_partners_updated_at
    BEFORE UPDATE ON business_partners
    FOR EACH ROW
    EXECUTE FUNCTION update_business_partners_updated_at();

-- Add helpful comments
COMMENT ON TABLE business_partners IS 'Business partner profiles with Supabase Auth integration';
COMMENT ON COLUMN business_partners.user_id IS 'Links to auth.users - one business per auth account';
COMMENT ON COLUMN business_partners.email IS 'Business email used for login and primary contact';
COMMENT ON COLUMN business_partners.active IS 'Admin can disable to prevent login/offer creation';
COMMENT ON COLUMN business_partners.verified IS 'Admin verified badge for marketplace display';
COMMENT ON COLUMN business_partners.partnership_tier IS 'Basic (free), Featured ($49/mo), Premium ($99/mo)';

-- ============================================
-- Row Level Security (RLS) Policies
-- ============================================

-- Enable RLS
ALTER TABLE business_partners ENABLE ROW LEVEL SECURITY;

-- Policy 1: Partners can view their own data
DROP POLICY IF EXISTS "Partners can view own profile" ON business_partners;
CREATE POLICY "Partners can view own profile"
ON business_partners
FOR SELECT
USING (auth.uid() = user_id);

-- Policy 2: Partners can update their own data (except active/verified - admin only)
DROP POLICY IF EXISTS "Partners can update own profile" ON business_partners;
CREATE POLICY "Partners can update own profile"
ON business_partners
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (
    auth.uid() = user_id 
    AND active = (SELECT active FROM business_partners WHERE user_id = auth.uid())
    AND verified = (SELECT verified FROM business_partners WHERE user_id = auth.uid())
);

-- Policy 3: Anyone can insert new business (signup)
-- This policy allows authenticated users AND the auth trigger to create profiles
-- The trigger runs with SECURITY DEFINER so it bypasses RLS, but this policy
-- allows future direct inserts if needed
DROP POLICY IF EXISTS "Anyone can create business profile" ON business_partners;
CREATE POLICY "Anyone can create business profile"
ON business_partners
FOR INSERT
TO authenticated, anon
WITH CHECK (
    -- Allow if user_id matches the authenticated user (for direct signup)
    (auth.uid() = user_id)
);

-- Policy 4: Public can view active verified businesses (for marketplace)
DROP POLICY IF EXISTS "Public can view active businesses" ON business_partners;
CREATE POLICY "Public can view active businesses"
ON business_partners
FOR SELECT
USING (active = TRUE AND verified = TRUE);

-- ============================================
-- Sample Data (Optional - comment out for production)
-- ============================================

-- Uncomment below to insert sample data for testing
/*
INSERT INTO business_partners (
    business_name, business_type, email, phone, website,
    address, city, state, zip_code,
    contact_first_name, contact_last_name, contact_email, contact_phone,
    business_hours, description,
    verified, active
) VALUES 
(
    'Austin Animal Hospital',
    'veterinarian',
    'info@austinanimalhospital.com',
    '(512) 555-PETS',
    'https://austinanimalhospital.com',
    '123 Pet Care Lane',
    'Austin',
    'TX',
    '78701',
    'Dr. Sarah',
    'Johnson',
    'dr.sarah@austinanimalhospital.com',
    '(512) 555-1234',
    'Mon-Fri: 8am-6pm, Sat: 9am-3pm, Sun: Closed',
    'Full-service veterinary hospital providing comprehensive care for pets in the Austin area.',
    TRUE,
    TRUE
),
(
    'Pawsome Grooming Spa',
    'groomer',
    'appointments@pawsomegroomingspa.com',
    '(214) 555-GROOM',
    'https://pawsomegroomingspa.com',
    '456 Grooming Ave',
    'Dallas',
    'TX',
    '75201',
    'Jennifer',
    'Martinez',
    'jennifer@pawsomegroomingspa.com',
    '(214) 555-5678',
    'Tue-Sat: 9am-7pm, Sun-Mon: Closed',
    'Luxury pet grooming spa with expert groomers and premium products.',
    TRUE,
    TRUE
);
*/

-- ============================================
-- Verification Queries
-- ============================================

-- Verify table structure
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'business_partners'
ORDER BY ordinal_position;

-- Verify indexes
SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'business_partners';

-- Verify RLS policies
SELECT
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'business_partners';
