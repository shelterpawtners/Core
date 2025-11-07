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

-- Enable RLS first
ALTER TABLE public.shelters ENABLE ROW LEVEL SECURITY;

-- Simple RLS Policies (no complex checks)
CREATE POLICY "shelter_insert_policy" ON public.shelters FOR INSERT WITH CHECK (true);
CREATE POLICY "shelter_select_policy" ON public.shelters FOR SELECT USING (true);
CREATE POLICY "shelter_update_policy" ON public.shelters FOR UPDATE USING (true);
CREATE POLICY "shelter_delete_policy" ON public.shelters FOR DELETE USING (true);
