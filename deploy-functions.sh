# Deploy Edge Functions

# 1. Login to Supabase (if not already logged in)
supabase login

# 2. Link to your project
supabase link --project-ref nudwqhncbctyqkhafttd

# 3. Deploy the functions
supabase functions deploy admin-get-users
supabase functions deploy admin-update-user

# 4. Test locally (optional)
supabase start
supabase functions serve admin-get-users --no-verify-jwt
