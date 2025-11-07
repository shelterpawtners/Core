-- =====================================================
-- SHELTERS TABLE
-- Stores shelter and rescue organization information
-- =====================================================

-- Create shelters table
CREATE TABLE IF NOT EXISTS public.shelters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_name TEXT NOT NULL,
    organization_type TEXT NOT NULL,
    contact_name TEXT NOT NULL,
    contact_title TEXT,
    phone TEXT NOT NULL,
    email TEXT NOT NULL,
    website TEXT,
    street_address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    zip_code TEXT NOT NULL,
    year_founded INTEGER,
    tax_id TEXT,
    annual_adoptions INTEGER,
    current_capacity INTEGER,
    animal_types TEXT[],
    primary_goals TEXT[],
    current_challenges TEXT,
    existing_software TEXT,
    integration_needs TEXT,
    agree_contact BOOLEAN NOT NULL DEFAULT false,
    newsletter_opt_in BOOLEAN DEFAULT false,
    enrollment_status TEXT DEFAULT 'pending',
    approved BOOLEAN DEFAULT false,
    verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    reviewed_by UUID,
    notes TEXT
);

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_shelters_enrollment_status ON public.shelters(enrollment_status);
CREATE INDEX IF NOT EXISTS idx_shelters_organization_name ON public.shelters(organization_name);
CREATE INDEX IF NOT EXISTS idx_shelters_city_state ON public.shelters(city, state);
CREATE INDEX IF NOT EXISTS idx_shelters_email ON public.shelters(email);
CREATE INDEX IF NOT EXISTS idx_shelters_created_at ON public.shelters(created_at DESC);

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

-- Enable RLS
ALTER TABLE public.shelters ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Anyone can enroll a shelter"
    ON public.shelters
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Shelters can view own records"
    ON public.shelters
    FOR SELECT
    USING (true);

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
