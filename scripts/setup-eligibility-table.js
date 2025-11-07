#!/usr/bin/env node

/**
 * Setup script for eligibility_applications table
 * This script checks if the table exists and creates it if needed
 */

const SUPABASE_URL = 'https://nudwqhncbctyqkhafttd.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im51ZHdxaG5jYmN0eXFraGFmdHRkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk1MDY5NDAsImV4cCI6MjA3NTA4Mjk0MH0.8UmnamHbWEjCB2GG6KRrlDr1NXa2_3J8tntOTPzZ5E0';

async function checkTable() {
    console.log('🔍 Checking if eligibility_applications table exists...\n');
    
    try {
        const response = await fetch(`${SUPABASE_URL}/rest/v1/eligibility_applications?limit=1`, {
            method: 'GET',
            headers: {
                'apikey': SUPABASE_ANON_KEY,
                'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
                'Content-Type': 'application/json'
            }
        });

        if (response.ok) {
            console.log('✅ Table EXISTS - eligibility_applications is already set up!\n');
            
            // Get count of applications
            const countResponse = await fetch(`${SUPABASE_URL}/rest/v1/eligibility_applications?select=count`, {
                method: 'HEAD',
                headers: {
                    'apikey': SUPABASE_ANON_KEY,
                    'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
                    'Prefer': 'count=exact'
                }
            });
            
            const count = countResponse.headers.get('content-range')?.split('/')[1] || '0';
            console.log(`📊 Current applications in database: ${count}\n`);
            return true;
        } else if (response.status === 404 || response.status === 400) {
            console.log('❌ Table DOES NOT EXIST\n');
            console.log('⚠️  You need to run the SQL setup script manually.\n');
            console.log('📝 Instructions:');
            console.log('   1. Go to: https://supabase.com/dashboard/project/nudwqhncbctyqkhafttd/sql/new');
            console.log('   2. Copy the contents of: sql/eligibility_applications.sql');
            console.log('   3. Paste into the SQL Editor');
            console.log('   4. Click "Run" to execute\n');
            return false;
        } else {
            const errorText = await response.text();
            console.log('⚠️  Unexpected response:', response.status, errorText);
            return false;
        }
    } catch (error) {
        console.error('❌ Error checking table:', error.message);
        return false;
    }
}

// Run the check
checkTable().then(exists => {
    if (exists) {
        console.log('✨ Everything is set up correctly!\n');
        process.exit(0);
    } else {
        console.log('🔧 Setup required - follow the instructions above.\n');
        process.exit(1);
    }
});
