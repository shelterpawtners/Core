-- Create business_applications table for handling business partner signups
-- Run this in Supabase SQL Editor after the main schema setup

CREATE TABLE IF NOT EXISTS public.business_applications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    
    -- Business Information
    business_name TEXT NOT NULL,
    business_type TEXT NOT NULL CHECK (business_type IN (
        'veterinarian', 'groomer', 'trainer', 'pet_store', 'boarding', 
        'daycare', 'walker', 'sitter', 'photography', 'nutrition', 'other'
    )),
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    zip_code TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT NOT NULL,
    website TEXT,
    
    -- Contact Person Information
    contact_first_name TEXT NOT NULL,
    contact_last_name TEXT NOT NULL,
    contact_email TEXT NOT NULL,
    contact_phone TEXT NOT NULL,
    contact_title TEXT,
    
    -- Partnership Details
    discount_percentage NUMERIC,
    partnership_tier TEXT NOT NULL CHECK (partnership_tier IN ('basic', 'featured', 'premium')),
    services TEXT,
    comments TEXT,
    newsletter_opt_in BOOLEAN DEFAULT FALSE,
    
    -- Application Status
    application_status TEXT DEFAULT 'pending' CHECK (application_status IN ('pending', 'approved', 'rejected', 'needs_info')),
    reviewed_by UUID REFERENCES auth.users(id),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    admin_notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.business_applications ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Anyone can insert business applications" ON public.business_applications
    FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "Admins can view all business applications" ON public.business_applications
    FOR SELECT TO authenticated USING (
        EXISTS (
            SELECT 1 FROM public.admin_users 
            WHERE admin_users.user_id = auth.uid()
        )
    );

CREATE POLICY "Admins can update business applications" ON public.business_applications
    FOR UPDATE TO authenticated USING (
        EXISTS (
            SELECT 1 FROM public.admin_users 
            WHERE admin_users.user_id = auth.uid()
        )
    );

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_business_applications_status ON public.business_applications(application_status);
CREATE INDEX IF NOT EXISTS idx_business_applications_email ON public.business_applications(contact_email);
CREATE INDEX IF NOT EXISTS idx_business_applications_location ON public.business_applications(city, state);
CREATE INDEX IF NOT EXISTS idx_business_applications_type ON public.business_applications(business_type);

-- Add trigger for updated_at
CREATE TRIGGER set_business_applications_updated_at
    BEFORE UPDATE ON public.business_applications
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Business applications table created successfully!';
    RAISE NOTICE 'Table includes business info, contact details, partnership preferences, and admin review features';
    RAISE NOTICE 'RLS policies configured for public insert and admin management';
END $$;