-- ============================================
-- TRIGGER: Auto-create business_partners on Auth Signup
-- ============================================
-- This trigger automatically creates a business_partners record
-- when a new user signs up via Supabase Auth.
-- This allows email verification to remain enabled for security
-- while still creating the profile record during signup.
-- ============================================

-- Function to handle new user signup
CREATE OR REPLACE FUNCTION public.handle_new_business_partner()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER -- Run with elevated privileges to bypass RLS
AS $$
BEGIN
    -- Only create business_partners record if user_type is 'business_partner'
    IF NEW.raw_user_meta_data->>'user_type' = 'business_partner' THEN
        INSERT INTO public.business_partners (
            user_id,
            business_name,
            business_type,
            email,
            phone,
            website,
            address,
            city,
            state,
            zip_code,
            contact_first_name,
            contact_last_name,
            contact_email,
            contact_phone,
            contact_title,
            business_hours,
            description,
            facebook_url,
            instagram_url,
            tiktok_url,
            x_url,
            linkedin_url,
            pinterest_url,
            other_social_url,
            partnership_tier,
            active,
            verified,
            created_at,
            updated_at
        )
        VALUES (
            NEW.id,
            COALESCE(NEW.raw_user_meta_data->>'business_name', 'New Business'),
            COALESCE(NEW.raw_user_meta_data->>'business_type', 'Other'),
            COALESCE(NEW.raw_user_meta_data->>'business_email', NEW.email),
            NEW.raw_user_meta_data->>'business_phone',
            NEW.raw_user_meta_data->>'business_website',
            NEW.raw_user_meta_data->>'business_address',
            NEW.raw_user_meta_data->>'business_city',
            NEW.raw_user_meta_data->>'business_state',
            NEW.raw_user_meta_data->>'business_zip',
            COALESCE(NEW.raw_user_meta_data->>'contact_first_name', ''),
            COALESCE(NEW.raw_user_meta_data->>'contact_last_name', ''),
            NEW.email,
            NEW.raw_user_meta_data->>'contact_phone',
            NEW.raw_user_meta_data->>'contact_title',
            NEW.raw_user_meta_data->>'business_hours',
            NEW.raw_user_meta_data->>'description',
            NEW.raw_user_meta_data->>'facebook_url',
            NEW.raw_user_meta_data->>'instagram_url',
            NEW.raw_user_meta_data->>'tiktok_url',
            NEW.raw_user_meta_data->>'x_url',
            NEW.raw_user_meta_data->>'linkedin_url',
            NEW.raw_user_meta_data->>'pinterest_url',
            NEW.raw_user_meta_data->>'other_social_url',
            COALESCE(NEW.raw_user_meta_data->>'partnership_tier', 'Free'),
            true,  -- Active by default (self-serve)
            false, -- Not verified until admin approves
            NOW(),
            NOW()
        );
    END IF;
    
    RETURN NEW;
END;
$$;

-- Create trigger on auth.users table
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_business_partner();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON public.business_partners TO postgres, anon, authenticated, service_role;

-- ============================================
-- NOTES:
-- ============================================
-- This trigger creates a MINIMAL business_partners record with just:
-- - user_id (from auth.users)
-- - business_name (from signup metadata)
-- - contact names (from signup metadata)
-- - contact_email (from auth email)
-- - active = true
-- - verified = false
--
-- The user will then need to COMPLETE their profile by:
-- 1. Confirming their email
-- 2. Logging in
-- 3. Being redirected to complete their business profile
-- 4. Filling in all the additional fields (address, phone, etc.)
--
-- This approach:
-- ✅ Keeps email verification enabled (security!)
-- ✅ Creates the business_partners record automatically
-- ✅ Allows the profile to be completed after email confirmation
-- ✅ Works with RLS policies (trigger runs with SECURITY DEFINER)
-- ============================================
