-- Create Test Users for Admin System
-- Run this in your Supabase SQL Editor to create sample users

-- Create admin users
INSERT INTO admin_users (email, full_name, role, active) VALUES
('admin@shelterpawtners.com', 'System Administrator', 'admin', true),
('manager@shelterpawtners.com', 'User Manager', 'admin', true)
ON CONFLICT (email) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    active = EXCLUDED.active;

-- Create business partners  
INSERT INTO business_partners (
    email, 
    business_name, 
    contact_name, 
    phone, 
    business_type, 
    services_offered, 
    description, 
    website, 
    address, 
    active, 
    verified
) VALUES
('vet@example.com', 'Happy Paws Veterinary', 'Dr. Sarah Johnson', '555-0123', 'Veterinary Clinic', 
 ARRAY['Health Check-ups', 'Vaccinations', 'Emergency Care'], 
 'Full-service veterinary clinic specializing in shelter pet care', 
 'https://happypawsvet.com', '123 Main St, Anytown, ST 12345', true, true),
 
('groomer@example.com', 'Fluffy & Clean Grooming', 'Mike Wilson', '555-0456', 'Pet Grooming', 
 ARRAY['Full Grooming', 'Nail Trimming', 'Bathing'], 
 'Professional pet grooming services with shelter pet discounts', 
 'https://fluffyandclean.com', '456 Oak Ave, Anytown, ST 12345', true, false),
 
('trainer@example.com', 'Good Dog Training Academy', 'Lisa Chen', '555-0789', 'Pet Training', 
 ARRAY['Basic Obedience', 'Behavioral Training', 'Puppy Classes'], 
 'Certified dog training for all ages and breeds', 
 'https://gooddogtraining.com', '789 Pine Rd, Anytown, ST 12345', true, true)
ON CONFLICT (email) DO UPDATE SET
    business_name = EXCLUDED.business_name,
    active = EXCLUDED.active,
    verified = EXCLUDED.verified;

-- Show results
SELECT 'Admin Users' as table_name, count(*) as count FROM admin_users WHERE active = true
UNION ALL
SELECT 'Business Partners' as table_name, count(*) as count FROM business_partners WHERE active = true;