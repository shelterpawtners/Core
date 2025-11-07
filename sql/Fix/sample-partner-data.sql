-- Sample Business Partners Data for Testing
-- This will insert some demo partners to test the partner-offers.html page

-- Insert sample verified and active partners
INSERT INTO public.business_partners (
    business_name, 
    business_type, 
    address, 
    city, 
    state, 
    zip_code, 
    phone, 
    email, 
    website, 
    services, 
    discount_percentage, 
    verified, 
    active
) VALUES 
-- Veterinary Partners
(
    'Austin Animal Hospital', 
    'veterinarian', 
    '123 Pet Care Lane', 
    'Austin', 
    'TX', 
    '78701', 
    '(512) 555-0123', 
    'info@austinanimalhospital.com', 
    'https://austinanimalhospital.com', 
    '["Comprehensive veterinary care with 25% off first visit for ShelterCARD holders", "Full medical exams", "Vaccinations", "Emergency care"]', 
    25, 
    true, 
    true
),

-- Pet Food/Supply Partners
(
    'Premium Pet Nutrition', 
    'pet_store', 
    '456 Nutrition Blvd', 
    'Dallas', 
    'TX', 
    '75201', 
    '(214) 555-0456', 
    'orders@premiumpetnutrition.com', 
    'https://premiumpetnutrition.com', 
    '["High-quality, natural pet food with ongoing 20% discount for ShelterCARD members", "Grain-free options", "Senior pet formulas", "Puppy and kitten food"]', 
    20, 
    true, 
    true
),

-- Grooming Partners
(
    'Pawsome Grooming Spa', 
    'groomer', 
    '789 Grooming Street', 
    'Houston', 
    'TX', 
    '77002', 
    '(713) 555-0789', 
    'appointments@pawsomegroomingspa.com', 
    'https://pawsomegroomingspa.com', 
    '["Full-service grooming with luxury spa treatments", "30% off all services for ShelterCARD holders", "Nail trimming", "Teeth cleaning", "De-shedding treatments"]', 
    30, 
    true, 
    true
),

-- Training Partners
(
    'Happy Tails Training Academy', 
    'trainer', 
    '321 Training Ave', 
    'San Antonio', 
    'TX', 
    '78201', 
    '(210) 555-0321', 
    'trainers@happytailsacademy.com', 
    'https://happytailsacademy.com', 
    '["Professional dog training classes", "Buy one session, get one free for shelter pets", "Basic obedience", "Advanced training", "Behavioral modification"]', 
    50, 
    true, 
    true
),

-- Pet Supply Store
(
    'Pet Essentials Plus', 
    'pet_store', 
    '654 Supply Road', 
    'Fort Worth', 
    'TX', 
    '76102', 
    '(817) 555-0654', 
    'customer@petessentialsplus.com', 
    'https://petessentialsplus.com', 
    '["Everything your pet needs - toys, accessories, and more", "15% ongoing savings for ShelterCARD members", "Pet toys", "Leashes and collars", "Pet beds and carriers"]', 
    15, 
    true, 
    true
),

-- Boarding Services
(
    'Cozy Paws Boarding Resort', 
    'boarding', 
    '987 Resort Lane', 
    'Plano', 
    'TX', 
    '75024', 
    '(972) 555-0987', 
    'reservations@cozypawsresort.com', 
    'https://cozypawsresort.com', 
    '["Premium pet boarding and daycare", "First night free for ShelterCARD members", "24/7 supervision", "Luxury suites", "Daily exercise and playtime"]', 
    100, 
    true, 
    true
),

-- Online Pet Store
(
    'Shelter Pet Supply Co', 
    'pet_store', 
    '123 Online Commerce Dr', 
    'Austin', 
    'TX', 
    '78704', 
    '(800) 555-PETS', 
    'orders@shelterpetsupply.com', 
    'https://shelterpetsupply.com', 
    '["Nationwide shipping of premium pet supplies", "20% discount for all ShelterCARD holders", "Free shipping on orders over $50", "Eco-friendly products", "Shelter pet approved items"]', 
    20, 
    true, 
    true
),

-- Veterinary Specialist
(
    'Texas Pet Emergency Center', 
    'veterinarian', 
    '456 Emergency Blvd', 
    'Dallas', 
    'TX', 
    '75203', 
    '(214) 555-HELP', 
    'emergency@txpetemergency.com', 
    'https://txpetemergency.com', 
    '["24/7 emergency veterinary care", "15% discount for ShelterCARD holders", "Emergency surgery", "Critical care", "Specialist consultations"]', 
    15, 
    true, 
    true
),

-- Pending Application (for testing admin interface)
(
    'Paws & Claws Grooming', 
    'groomer', 
    '789 Pending Street', 
    'Garland', 
    'TX', 
    '75040', 
    '(972) 555-PAWS', 
    'info@pawsandclawsgrooming.com', 
    'https://pawsandclawsgrooming.com', 
    '["Full service pet grooming", "25% discount for ShelterCARD holders", "Walk-ins welcome"]', 
    25, 
    false, 
    false
),

-- Mobile Grooming Service
(
    'Mobile Paws Grooming', 
    'groomer', 
    '123 Mobile Unit Dr', 
    'Richardson', 
    'TX', 
    '75080', 
    '(469) 555-MOBIL', 
    'book@mobilepawsgrooming.com', 
    'https://mobilepawsgrooming.com', 
    '["Mobile grooming service that comes to you", "30% discount for ShelterCARD holders", "Full grooming in your driveway", "No stress for your pet"]', 
    30, 
    true, 
    true
);

-- Insert some sample savings records for testing
INSERT INTO public.savings_records (
    user_id,
    business_partner_id,
    service_type,
    original_amount,
    discount_amount,
    final_amount,
    transaction_date,
    notes
) VALUES 
-- Note: These will need actual user_ids from your auth.users table
-- For now, using placeholder UUIDs - update with real user IDs when testing
(
    '00000000-0000-0000-0000-000000000001'::uuid,
    (SELECT id FROM public.business_partners WHERE business_name = 'Austin Animal Hospital' LIMIT 1),
    'veterinary_checkup',
    120.00,
    30.00,
    90.00,
    '2024-10-15',
    'Annual wellness exam with ShelterCARD discount'
),
(
    '00000000-0000-0000-0000-000000000002'::uuid,
    (SELECT id FROM public.business_partners WHERE business_name = 'Pawsome Grooming Spa' LIMIT 1),
    'full_grooming',
    80.00,
    24.00,
    56.00,
    '2024-10-20',
    'Full grooming package with nail trim'
);

-- Update the user_profiles table to allow business_partner user type if needed
-- (This may already be set up in your schema)
-- UPDATE public.user_profiles SET user_type = 'business_partner' WHERE user_type IS NULL;