// Supabase Configuration for Shelter Pawtners
// Copy your actual values from Supabase Dashboard > Settings > API

const SUPABASE_CONFIG = {
    // Replace these with your actual Supabase project values
    url: 'https://nudwqhncbctyqkhafttd.supabase.co', // e.g., 'https://xyzabcdef.supabase.co'
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im51ZHdxaG5jYmN0eXFraGFmdHRkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk1MDY5NDAsImV4cCI6MjA3NTA4Mjk0MH0.8UmnamHbWEjCB2GG6KRrlDr1NXa2_3J8tntOTPzZ5E0', // Long string starting with 'eyJ...'
    
    // Optional: Service role key for admin operations (keep secret!)
    serviceRoleKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im51ZHdxaG5jYmN0eXFraGFmdHRkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTUwNjk0MCwiZXhwIjoyMDc1MDgyOTQwfQ.CtGx_LVUHoNECar8VKvn22MHsqZ7c3KYlLTh1HtopyQ' // Only if needed for admin functions
};

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SUPABASE_CONFIG;
}

// Make available globally for browser use
if (typeof window !== 'undefined') {
    window.SUPABASE_CONFIG = SUPABASE_CONFIG;
}

/* 
SETUP INSTRUCTIONS:

1. Go to https://supabase.com/dashboard
2. Select your project (or create new one)
3. Go to Settings > API
4. Copy the "Project URL" and paste it as the 'url' value above
5. Copy the "Project API Keys > anon public" key and paste it as 'anonKey' above
6. Save this file
7. Run the SQL schema script in Supabase SQL Editor
8. Test the connection!

SECURITY NOTES:
- The anon key is safe to use in frontend code
- Never expose the service role key in frontend code
- RLS (Row Level Security) is enabled to protect user data
- All API calls are authenticated and authorized
*/