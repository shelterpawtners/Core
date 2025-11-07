/**
 * Shared Admin Authentication
 * Checks if logged-in user has user_type = 'admin' in user_profiles table
 */

async function checkAdminAuth() {
  const { createClient } = supabase;
  const client = createClient(SUPABASE_CONFIG.url, SUPABASE_CONFIG.anonKey);
  
  try {
    // Get current session
    const { data: { session }, error } = await client.auth.getSession();
    
    if (error || !session) {
      console.log('No active session');
      redirectToAdminLogin();
      return false;
    }
    
    // Check if user has admin user_type in user_profiles
    const { data: profile, error: profileErr } = await client
      .from('user_profiles')
      .select('user_type, email, full_name')
      .eq('id', session.user.id)
      .maybeSingle();
    
    if (profileErr) {
      console.error('Error checking user profile:', profileErr);
      await client.auth.signOut();
      alert('Error verifying admin access. Please log in again.');
      redirectToAdminLogin();
      return false;
    }
    
    if (!profile) {
      console.error('No user profile found');
      await client.auth.signOut();
      alert('User profile not found. Please contact support.');
      redirectToAdminLogin();
      return false;
    }
    
    if (profile.user_type !== 'admin') {
      console.error('Access denied: user_type =', profile.user_type);
      await client.auth.signOut();
      alert('Access denied. Only users with Admin type can access this page.');
      redirectToAdminLogin();
      return false;
    }
    
    // User is authenticated and has admin type
    console.log('Admin authenticated:', profile.email);
    return {
      session,
      profile,
      client
    };
    
  } catch (error) {
    console.error('Admin auth check error:', error);
    redirectToAdminLogin();
    return false;
  }
}

function redirectToAdminLogin() {
  // Check if we're already on the login page to prevent redirect loop
  if (!window.location.pathname.includes('admin-login.html')) {
    window.location.href = 'admin-login.html';
  }
}

// Export for use in admin pages
if (typeof window !== 'undefined') {
  window.checkAdminAuth = checkAdminAuth;
  window.redirectToAdminLogin = redirectToAdminLogin;
}
