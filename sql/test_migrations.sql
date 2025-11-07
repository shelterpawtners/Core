-- Quick test to check if tables exist
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('business_partners', 'partner_offers')
ORDER BY tablename;

-- Check if we have any test data
SELECT COUNT(*) as business_count FROM business_partners;
SELECT COUNT(*) as offer_count FROM partner_offers;
