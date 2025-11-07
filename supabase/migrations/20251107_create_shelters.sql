-- =====================================================
-- SHELTERS TABLE
-- Stores shelter and rescue organization information
-- =====================================================

-- Create shelters table
CREATE TABLE IF NOT EXISTS public.shelters (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Organization Information
    organization_name TEXT NOT NULL,
    organization_type TEXT NOT NULL CHECK (organization_type IN (
        'animal-shelter',
        'rescue-organization',
        'humane-society',
        'spca',
        'municipal-shelter',
        'foster-network',
        'other'
    )),
    
    -- Contact Information
    contact_name TEXT NOT NULL,
    contact_title TEXT,
    phone TEXT NOT NULL,
    email TEXT NOT NULL,
    website TEXT,
    
    -- Address
    street_address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    zip_code TEXT NOT NULL,
    
    -- Organization Details
    year_founded INTEGER,
    tax_id TEXT, -- EIN for non-profits
    annual_adoptions INTEGER,
    current_capacity INTEGER,
    animal_types TEXT[], -- Array of animal types they work with
    
    -- Partnership Details
    primary_goals TEXT[], -- Array of goals for partnership
    current_challenges TEXT,
    existing_software TEXT,
    integration_needs TEXT,
    
    -- Communication Preferences
    agree_contact BOOLEAN NOT NULL DEFAULT false,
    newsletter_opt_in BOOLEAN DEFAULT false,
    
    -- Status Fields
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'active', 'inactive', 'rejected')),
    approved BOOLEAN DEFAULT false,
    verified BOOLEAN DEFAULT false,
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    reviewed_by UUID REFERENCES auth.users(id),
    notes TEXT -- Admin notes
);

-- Add indexes for common queries
CREATE INDEX idx_shelters_status ON public.shelters(status);
CREATE INDEX idx_shelters_organization_name ON public.shelters(organization_name);
CREATE INDEX idx_shelters_city_state ON public.shelters(city, state);
CREATE INDEX idx_shelters_email ON public.shelters(email);
CREATE INDEX idx_shelters_created_at ON public.shelters(created_at DESC);

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION update_shelters_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER shelters_updated_at
    BEFORE UPDATE ON public.shelters
    FOR EACH ROW
    EXECUTE FUNCTION update_shelters_updated_at();

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS
ALTER TABLE public.shelters ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can insert (public enrollment)
CREATE POLICY "Anyone can enroll a shelter"
    ON public.shelters
    FOR INSERT
    WITH CHECK (true);

-- Policy: Shelters can view their own records (if we add user_id later)
CREATE POLICY "Shelters can view own records"
    ON public.shelters
    FOR SELECT
    USING (true); -- For now, authenticated users can view all

-- Policy: Only admins can update shelter records
CREATE POLICY "Only admins can update shelters"
    ON public.shelters
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE user_profiles.id = auth.uid()
            AND user_profiles.user_type = 'admin'
        )
    );

-- Policy: Only admins can delete shelter records
CREATE POLICY "Only admins can delete shelters"
    ON public.shelters
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE user_profiles.id = auth.uid()
            AND user_profiles.user_type = 'admin'
        )
    );

-- =====================================================
-- COMMENTS
-- =====================================================

COMMENT ON TABLE public.shelters IS 'Stores shelter and rescue organization enrollment information';
COMMENT ON COLUMN public.shelters.id IS 'Unique identifier for the shelter';
COMMENT ON COLUMN public.shelters.organization_name IS 'Official name of the shelter or rescue organization';
COMMENT ON COLUMN public.shelters.organization_type IS 'Type of organization (shelter, rescue, etc.)';
COMMENT ON COLUMN public.shelters.status IS 'Enrollment status: pending, approved, active, inactive, rejected';
COMMENT ON COLUMN public.shelters.animal_types IS 'Array of animal types the organization works with (dogs, cats, etc.)';
COMMENT ON COLUMN public.shelters.primary_goals IS 'Array of goals for the partnership (reduce returns, post-adoption support, etc.)';
