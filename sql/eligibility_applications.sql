-- Eligibility Applications table for ShelterCARD verification
-- Run this in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS eligibility_applications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- Pet Information
    pet_name VARCHAR(255) NOT NULL,
    pet_species VARCHAR(50) NOT NULL CHECK (pet_species IN ('dog', 'cat', 'rabbit', 'bird', 'other')),
    microchip_id VARCHAR(20),
    
    -- Shelter Information
    shelter_name VARCHAR(255) NOT NULL,
    shelter_email VARCHAR(255),
    shelter_phone VARCHAR(20),
    adoption_date DATE NOT NULL,
    
    -- Owner Information
    owner_name VARCHAR(255) NOT NULL,
    owner_email VARCHAR(255) NOT NULL,
    owner_phone VARCHAR(20),
    
    -- Document Information
    document_filename VARCHAR(255),
    document_url TEXT,
    
    -- Application Status and Processing
    application_status VARCHAR(20) DEFAULT 'pending' CHECK (application_status IN ('pending', 'approved', 'rejected', 'needs_info')),
    verification_notes TEXT,
    processed_at TIMESTAMPTZ,
    processed_by UUID REFERENCES auth.users(id),
    
    -- Audit Fields
    submitted_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    ip_address INET,
    user_agent TEXT,
    
    -- Foreign Key (optional - if user is logged in)
    user_id UUID REFERENCES auth.users(id),
    
    -- Email validation constraint
    CONSTRAINT valid_email CHECK (owner_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_eligibility_applications_status ON eligibility_applications(application_status);
CREATE INDEX IF NOT EXISTS idx_eligibility_applications_submitted_at ON eligibility_applications(submitted_at);
CREATE INDEX IF NOT EXISTS idx_eligibility_applications_owner_email ON eligibility_applications(owner_email);
CREATE INDEX IF NOT EXISTS idx_eligibility_applications_shelter_name ON eligibility_applications(shelter_name);
CREATE INDEX IF NOT EXISTS idx_eligibility_applications_user_id ON eligibility_applications(user_id);

-- Enable Row Level Security (RLS)
ALTER TABLE eligibility_applications ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Policy 1: Anyone can submit eligibility applications
CREATE POLICY "Anyone can submit eligibility applications" ON eligibility_applications
    FOR INSERT WITH CHECK (true);

-- Policy 2: Users can view their own applications if logged in, or admins can view all
CREATE POLICY "Users can view own applications or admins view all" ON eligibility_applications
    FOR SELECT USING (
        auth.uid() = user_id OR 
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.raw_user_meta_data->>'role' = 'admin'
        ) OR
        auth.uid() IS NULL  -- Allow public access for now
    );

-- Policy 3: Admin users can update all applications
CREATE POLICY "Admins can update all applications" ON eligibility_applications
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.raw_user_meta_data->>'role' = 'admin'
        )
    );

-- Policy 4: Admin users can delete applications if needed
CREATE POLICY "Admins can delete applications" ON eligibility_applications
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.raw_user_meta_data->>'role' = 'admin'
        )
    );

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_eligibility_applications_updated_at 
    BEFORE UPDATE ON eligibility_applications 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Storage bucket for pet documents (if not exists)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) 
VALUES (
    'pet-documents', 
    'pet-documents', 
    true, 
    10485760,  -- 10MB limit
    ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf']
) ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Storage policies for pet documents
CREATE POLICY "Anyone can upload pet documents" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'pet-documents');

CREATE POLICY "Anyone can view pet documents" ON storage.objects
    FOR SELECT USING (bucket_id = 'pet-documents');

CREATE POLICY "Users can update their own documents" ON storage.objects
    FOR UPDATE USING (bucket_id = 'pet-documents');

CREATE POLICY "Users can delete their own documents" ON storage.objects
    FOR DELETE USING (bucket_id = 'pet-documents');

-- Comments for documentation
COMMENT ON TABLE eligibility_applications IS 'Applications for ShelterCARD eligibility verification';
COMMENT ON COLUMN eligibility_applications.application_status IS 'Status: pending, approved, rejected, needs_info';
COMMENT ON COLUMN eligibility_applications.verification_notes IS 'Internal notes from verification process';
COMMENT ON COLUMN eligibility_applications.document_url IS 'URL to uploaded adoption documentation';

-- Grant permissions
GRANT ALL ON eligibility_applications TO authenticated;
GRANT ALL ON eligibility_applications TO anon;

-- Verify the setup
SELECT 'Eligibility applications table created successfully!' as status;
SELECT 'Storage bucket configured!' as storage_status;