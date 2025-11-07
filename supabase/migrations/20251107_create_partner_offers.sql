-- ============================================
-- Migration: Create partner_offers Table
-- Version: 1.0
-- Date: 2025-11-07
-- Description: Individual partner discount offers with analytics
-- ============================================

-- Drop table if exists (for clean re-runs in development)
DROP TABLE IF EXISTS partner_offers CASCADE;

-- Create partner_offers table
CREATE TABLE partner_offers (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Foreign Key to Business
    business_id UUID NOT NULL REFERENCES business_partners(id) ON DELETE CASCADE,
    
    -- Offer Core Information
    offer_title TEXT NOT NULL, -- e.g., "25% Off First Veterinary Visit"
    offer_description TEXT, -- Detailed description
    
    -- Discount Details
    discount_type TEXT NOT NULL CHECK (discount_type IN (
        'percentage', -- % off
        'fixed_amount', -- $ off
        'bogo', -- Buy one get one
        'free_item', -- Free service/product
        'other' -- Custom deal
    )),
    discount_percentage INTEGER CHECK (discount_percentage >= 0 AND discount_percentage <= 100), -- For percentage type
    discount_value DECIMAL(10, 2), -- For fixed_amount type (e.g., $25 off)
    discount_details TEXT, -- For BOGO/free_item/other types
    
    -- Services/Products
    services TEXT[], -- Array of applicable services/products
    
    -- Redemption Details
    special_instructions TEXT, -- How to redeem (show card, mention code, etc.)
    restrictions TEXT, -- Terms & conditions, exclusions
    redemption_code TEXT, -- Optional unique code for tracking
    max_redemptions INTEGER, -- NULL = unlimited
    current_redemptions INTEGER DEFAULT 0,
    
    -- Validity Period
    valid_from TIMESTAMPTZ DEFAULT NOW(),
    valid_until TIMESTAMPTZ, -- NULL = no expiration
    
    -- Location/Availability
    service_area TEXT[], -- For mobile services (cities, zip codes)
    online_only BOOLEAN DEFAULT FALSE,
    in_store_only BOOLEAN DEFAULT FALSE,
    
    -- Offer Status
    active BOOLEAN DEFAULT TRUE, -- Partner can toggle on/off
    approved BOOLEAN DEFAULT TRUE, -- Admin approval (self-serve from start, admin can disable)
    featured BOOLEAN DEFAULT FALSE, -- Appears first in marketplace
    
    -- Offer Assets
    offer_image_url TEXT, -- Main offer image
    thumbnail_url TEXT, -- Smaller version for cards
    
    -- Analytics
    view_count INTEGER DEFAULT 0, -- How many times offer was viewed
    click_count INTEGER DEFAULT 0, -- How many times "Get Offer" clicked
    redemption_count INTEGER DEFAULT 0, -- How many times actually redeemed
    last_viewed_at TIMESTAMPTZ,
    last_redeemed_at TIMESTAMPTZ,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_discount_percentage CHECK (
        discount_type != 'percentage' OR discount_percentage IS NOT NULL
    ),
    CONSTRAINT valid_discount_value CHECK (
        discount_type != 'fixed_amount' OR discount_value IS NOT NULL
    ),
    CONSTRAINT valid_date_range CHECK (
        valid_until IS NULL OR valid_until > valid_from
    )
);

-- Create indexes for performance
CREATE INDEX idx_partner_offers_business_id ON partner_offers(business_id);
CREATE INDEX idx_partner_offers_active ON partner_offers(active);
CREATE INDEX idx_partner_offers_approved ON partner_offers(approved);
CREATE INDEX idx_partner_offers_featured ON partner_offers(featured);
CREATE INDEX idx_partner_offers_valid_until ON partner_offers(valid_until);
CREATE INDEX idx_partner_offers_discount_type ON partner_offers(discount_type);
CREATE INDEX idx_partner_offers_created_at ON partner_offers(created_at DESC);

-- Composite index for marketplace queries
CREATE INDEX idx_partner_offers_marketplace ON partner_offers(active, approved, featured, valid_until);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_partner_offers_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER trigger_update_partner_offers_updated_at
    BEFORE UPDATE ON partner_offers
    FOR EACH ROW
    EXECUTE FUNCTION update_partner_offers_updated_at();

-- Add helpful comments
COMMENT ON TABLE partner_offers IS 'Individual discount offers from business partners with analytics';
COMMENT ON COLUMN partner_offers.business_id IS 'Links to business_partners - one business can have many offers';
COMMENT ON COLUMN partner_offers.discount_type IS 'Type of discount: percentage, fixed_amount, bogo, free_item, other';
COMMENT ON COLUMN partner_offers.active IS 'Partner can toggle offer on/off without deleting';
COMMENT ON COLUMN partner_offers.approved IS 'Admin can disable problematic offers (self-serve enabled by default)';
COMMENT ON COLUMN partner_offers.max_redemptions IS 'NULL = unlimited, otherwise cap total redemptions';
COMMENT ON COLUMN partner_offers.service_area IS 'Array of cities/zip codes for mobile services';

-- ============================================
-- Row Level Security (RLS) Policies
-- ============================================

-- Enable RLS
ALTER TABLE partner_offers ENABLE ROW LEVEL SECURITY;

-- Policy 1: Partners can view their own offers
DROP POLICY IF EXISTS "Partners can view own offers" ON partner_offers;
CREATE POLICY "Partners can view own offers"
ON partner_offers
FOR SELECT
USING (
    business_id IN (
        SELECT id FROM business_partners WHERE user_id = auth.uid()
    )
);

-- Policy 2: Partners can create offers for their business
DROP POLICY IF EXISTS "Partners can create offers" ON partner_offers;
CREATE POLICY "Partners can create offers"
ON partner_offers
FOR INSERT
WITH CHECK (
    business_id IN (
        SELECT id FROM business_partners WHERE user_id = auth.uid() AND active = TRUE
    )
);

-- Policy 3: Partners can update their own offers (except approved - admin only)
DROP POLICY IF EXISTS "Partners can update own offers" ON partner_offers;
CREATE POLICY "Partners can update own offers"
ON partner_offers
FOR UPDATE
USING (
    business_id IN (
        SELECT id FROM business_partners WHERE user_id = auth.uid()
    )
)
WITH CHECK (
    business_id IN (
        SELECT id FROM business_partners WHERE user_id = auth.uid()
    )
    AND approved = (SELECT approved FROM partner_offers WHERE id = partner_offers.id)
);

-- Policy 4: Partners can delete their own offers (soft delete - set active = false preferred)
DROP POLICY IF EXISTS "Partners can delete own offers" ON partner_offers;
CREATE POLICY "Partners can delete own offers"
ON partner_offers
FOR DELETE
USING (
    business_id IN (
        SELECT id FROM business_partners WHERE user_id = auth.uid()
    )
);

-- Policy 5: Public can view active, approved, non-expired offers (for marketplace)
DROP POLICY IF EXISTS "Public can view active offers" ON partner_offers;
CREATE POLICY "Public can view active offers"
ON partner_offers
FOR SELECT
USING (
    active = TRUE 
    AND approved = TRUE 
    AND (valid_until IS NULL OR valid_until > NOW())
    AND business_id IN (
        SELECT id FROM business_partners WHERE active = TRUE AND verified = TRUE
    )
);

-- ============================================
-- Helper Functions
-- ============================================

-- Function to increment view count
CREATE OR REPLACE FUNCTION increment_offer_views(offer_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE partner_offers
    SET 
        view_count = view_count + 1,
        last_viewed_at = NOW()
    WHERE id = offer_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to increment click count
CREATE OR REPLACE FUNCTION increment_offer_clicks(offer_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE partner_offers
    SET click_count = click_count + 1
    WHERE id = offer_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to increment redemption count
CREATE OR REPLACE FUNCTION increment_offer_redemptions(offer_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    offer_record RECORD;
BEGIN
    -- Get current offer data
    SELECT * INTO offer_record
    FROM partner_offers
    WHERE id = offer_id;
    
    -- Check if max redemptions reached
    IF offer_record.max_redemptions IS NOT NULL 
       AND offer_record.current_redemptions >= offer_record.max_redemptions THEN
        RETURN FALSE; -- Max redemptions reached
    END IF;
    
    -- Increment counts
    UPDATE partner_offers
    SET 
        redemption_count = redemption_count + 1,
        current_redemptions = current_redemptions + 1,
        last_redeemed_at = NOW()
    WHERE id = offer_id;
    
    RETURN TRUE; -- Success
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- Sample Data (Optional - comment out for production)
-- ============================================

-- Uncomment below to insert sample data for testing
-- NOTE: Requires business_partners sample data to be inserted first
/*
-- Get business IDs from sample businesses
DO $$
DECLARE
    austin_animal_id UUID;
    pawsome_id UUID;
BEGIN
    -- Get IDs
    SELECT id INTO austin_animal_id FROM business_partners WHERE business_name = 'Austin Animal Hospital';
    SELECT id INTO pawsome_id FROM business_partners WHERE business_name = 'Pawsome Grooming Spa';
    
    -- Insert offers
    INSERT INTO partner_offers (
        business_id, offer_title, offer_description,
        discount_type, discount_percentage,
        services, special_instructions, restrictions,
        valid_until, active, approved, featured
    ) VALUES
    (
        austin_animal_id,
        '25% Off First Veterinary Visit',
        'New patients receive 25% off their first comprehensive exam and consultation.',
        'percentage',
        25,
        ARRAY['Wellness Exam', 'Consultation', 'Basic Diagnostics'],
        'Present your ShelterCARD at check-in and mention this offer.',
        'Valid for new patients only. Cannot be combined with other offers. Does not include lab work or medications.',
        NOW() + INTERVAL '6 months',
        TRUE,
        TRUE,
        TRUE
    ),
    (
        pawsome_id,
        '30% Off Full Grooming Package',
        'Premium grooming package including bath, haircut, nail trim, and ear cleaning.',
        'percentage',
        30,
        ARRAY['Full Grooming', 'Bath', 'Haircut', 'Nail Trim', 'Ear Cleaning'],
        'Book online or call us and mention your ShelterCARD membership.',
        'Appointment required. Valid for dogs and cats. Additional charges may apply for matted fur.',
        NOW() + INTERVAL '3 months',
        TRUE,
        TRUE,
        FALSE
    );
END $$;
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
  AND table_name = 'partner_offers'
ORDER BY ordinal_position;

-- Verify indexes
SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'partner_offers';

-- Verify RLS policies
SELECT
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'partner_offers';

-- Verify helper functions
SELECT
    routine_name,
    routine_type,
    data_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE '%offer%';
