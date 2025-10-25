-- Shelter Pawtners Database Schema Setup
-- Run this script in Supabase SQL Editor

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom user profiles table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT NOT NULL,
    first_name TEXT,
    last_name TEXT,
    phone TEXT,
    user_type TEXT DEFAULT 'pet_parent' CHECK (user_type IN ('pet_parent', 'business_partner', 'shelter', 'admin')),
    profile_complete BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create shelters table
CREATE TABLE IF NOT EXISTS public.shelters (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT,
    phone TEXT,
    email TEXT,
    website TEXT,
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create pets table
CREATE TABLE IF NOT EXISTS public.pets (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    owner_id UUID REFERENCES auth.users(id) NOT NULL,
    shelter_id UUID REFERENCES public.shelters(id),
    name TEXT NOT NULL,
    species TEXT NOT NULL,
    breed TEXT,
    age NUMERIC,
    weight NUMERIC,
    gender TEXT CHECK (gender IN ('male', 'female', 'unknown')),
    description TEXT,
    microchip_id TEXT,
    adoption_date DATE,
    shelter_name TEXT, -- For cases where shelter isn't in our system yet
    spayed_neutered BOOLEAN DEFAULT FALSE,
    photo_url TEXT,
    vaccinations JSONB DEFAULT '[]'::jsonb,
    health_notes TEXT,
    profile_complete BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create medical records table
CREATE TABLE IF NOT EXISTS public.medical_records (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    pet_id UUID REFERENCES public.pets(id) NOT NULL,
    record_type TEXT NOT NULL CHECK (record_type IN ('vaccination', 'checkup', 'treatment', 'surgery', 'medication', 'allergy', 'note')),
    title TEXT NOT NULL,
    description TEXT,
    date_performed DATE,
    veterinarian TEXT,
    clinic_name TEXT,
    cost NUMERIC,
    documents JSONB DEFAULT '[]'::jsonb, -- Array of document URLs
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create business partners table
CREATE TABLE IF NOT EXISTS public.business_partners (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    business_name TEXT NOT NULL,
    business_type TEXT CHECK (business_type IN ('veterinarian', 'groomer', 'trainer', 'pet_store', 'boarding', 'other')),
    address TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT,
    phone TEXT,
    email TEXT,
    website TEXT,
    services JSONB DEFAULT '[]'::jsonb,
    discount_percentage NUMERIC DEFAULT 0,
    verified BOOLEAN DEFAULT FALSE,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create savings tracking table
CREATE TABLE IF NOT EXISTS public.savings_records (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) NOT NULL,
    pet_id UUID REFERENCES public.pets(id),
    business_partner_id UUID REFERENCES public.business_partners(id),
    service_type TEXT,
    original_amount NUMERIC NOT NULL,
    discount_amount NUMERIC NOT NULL,
    final_amount NUMERIC NOT NULL,
    transaction_date DATE DEFAULT CURRENT_DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at triggers to all tables
CREATE TRIGGER set_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_pets_updated_at
    BEFORE UPDATE ON public.pets
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_medical_records_updated_at
    BEFORE UPDATE ON public.medical_records
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_shelters_updated_at
    BEFORE UPDATE ON public.shelters
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_business_partners_updated_at
    BEFORE UPDATE ON public.business_partners
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Enable Row Level Security
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medical_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shelters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.savings_records ENABLE ROW LEVEL SECURITY;

-- Create RLS policies

-- User profiles: Users can only see/edit their own profile
CREATE POLICY "Users can view own profile" ON public.user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.user_profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Pets: Users can only see/edit their own pets
CREATE POLICY "Users can view own pets" ON public.pets
    FOR SELECT USING (auth.uid() = owner_id);

CREATE POLICY "Users can insert own pets" ON public.pets
    FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update own pets" ON public.pets
    FOR UPDATE USING (auth.uid() = owner_id);

CREATE POLICY "Users can delete own pets" ON public.pets
    FOR DELETE USING (auth.uid() = owner_id);

-- Medical records: Users can see records for their pets
CREATE POLICY "Users can view medical records for own pets" ON public.medical_records
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.pets 
            WHERE pets.id = medical_records.pet_id 
            AND pets.owner_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert medical records for own pets" ON public.medical_records
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.pets 
            WHERE pets.id = medical_records.pet_id 
            AND pets.owner_id = auth.uid()
        )
    );

CREATE POLICY "Users can update medical records for own pets" ON public.medical_records
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.pets 
            WHERE pets.id = medical_records.pet_id 
            AND pets.owner_id = auth.uid()
        )
    );

-- Shelters: Public read access, authenticated insert
CREATE POLICY "Anyone can view shelters" ON public.shelters
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Authenticated users can insert shelters" ON public.shelters
    FOR INSERT TO authenticated WITH CHECK (true);

-- Business partners: Public read for active/verified, owners can edit
CREATE POLICY "Anyone can view active business partners" ON public.business_partners
    FOR SELECT TO authenticated USING (active = true AND verified = true);

CREATE POLICY "Users can view own business profile" ON public.business_partners
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own business profile" ON public.business_partners
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own business profile" ON public.business_partners
    FOR UPDATE USING (auth.uid() = user_id);

-- Savings records: Users can only see their own savings
CREATE POLICY "Users can view own savings" ON public.savings_records
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own savings" ON public.savings_records
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_pets_owner_id ON public.pets(owner_id);
CREATE INDEX IF NOT EXISTS idx_medical_records_pet_id ON public.medical_records(pet_id);
CREATE INDEX IF NOT EXISTS idx_pets_microchip ON public.pets(microchip_id);
CREATE INDEX IF NOT EXISTS idx_business_partners_type ON public.business_partners(business_type);
CREATE INDEX IF NOT EXISTS idx_savings_user_id ON public.savings_records(user_id);

-- Insert some sample data for testing
INSERT INTO public.shelters (name, city, state, phone, email, verified) VALUES
    ('Happy Tails Animal Rescue', 'Denver', 'CO', '(303) 555-0123', 'info@happytails.org', true),
    ('Pawsome Pet Rescue', 'Austin', 'TX', '(512) 555-0456', 'contact@pawsomerescue.org', true),
    ('Furry Friends Shelter', 'Portland', 'OR', '(503) 555-0789', 'help@furryfriends.org', true)
ON CONFLICT DO NOTHING;

INSERT INTO public.business_partners (business_name, business_type, city, state, phone, discount_percentage, verified, active) VALUES
    ('Healthy Paws Veterinary Clinic', 'veterinarian', 'Denver', 'CO', '(303) 555-1111', 15, true, true),
    ('Pampered Pets Grooming', 'groomer', 'Austin', 'TX', '(512) 555-2222', 20, true, true),
    ('Train Right Dog Training', 'trainer', 'Portland', 'OR', '(503) 555-3333', 10, true, true),
    ('Pet Paradise Supply Store', 'pet_store', 'Seattle', 'WA', '(206) 555-4444', 12, true, true)
ON CONFLICT DO NOTHING;

-- Create a function to automatically create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, first_name, last_name)
    VALUES (
        NEW.id,
        NEW.email,
        NEW.raw_user_meta_data->>'first_name',
        NEW.raw_user_meta_data->>'last_name'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on user signup
CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Shelter Pawtners database schema created successfully!';
    RAISE NOTICE 'Tables created: user_profiles, pets, medical_records, shelters, business_partners, savings_records';
    RAISE NOTICE 'RLS policies and triggers configured';
    RAISE NOTICE 'Sample data inserted for testing';
END $$;