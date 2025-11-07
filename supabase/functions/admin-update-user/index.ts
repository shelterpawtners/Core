/// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />

// Admin function to update user profiles
import { createClient } from 'jsr:@supabase/supabase-js@2'

interface UpdateRequest {
  userId: string
  updates: {
    user_type?: string
    status?: string
  }
}

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
        'Access-Control-Max-Age': '86400'
      }
    })
  }

  // Only allow POST requests
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      status: 405,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
      }
    })
  }

  try {
    // Create Supabase client with service role key
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Get the authorization header
    const authHeader = req.headers.get('Authorization')
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    const token = authHeader.replace('Bearer ', '')

    // Verify the user is authenticated
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)
    if (authError || !user) {
      return new Response(JSON.stringify({ error: 'Invalid token' }), {
        status: 401,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
        }
      })
    }

    // Check if user is an admin (check both user_id and email)
    // First try by email (more reliable for admin records)
    let adminCheck = null;
    let adminError = null;
    
    const emailCheck = await supabase
      .from('admin_users')
      .select('active, user_id, email')
      .eq('email', user.email)
      .eq('active', true)
      .maybeSingle()
    
    if (!emailCheck.error && emailCheck.data) {
      adminCheck = emailCheck.data;
    } else {
      // Fallback to user_id check
      const idCheck = await supabase
        .from('admin_users')
        .select('active, user_id, email')
        .eq('user_id', user.id)
        .eq('active', true)
        .maybeSingle()
      
      adminCheck = idCheck.data;
      adminError = idCheck.error;
    }

    console.log('Admin check result:', { adminCheck, adminError, userId: user.id, userEmail: user.email })

    if (adminError || !adminCheck) {
      console.error('Admin access denied:', { adminError, user: user.email })
      return new Response(JSON.stringify({ 
        error: 'Admin access required',
        details: 'User is not registered as an active admin'
      }), {
        status: 403,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
        }
      })
    }

    // Parse request body
    const { userId, updates }: UpdateRequest = await req.json()
    if (!userId || !updates) {
      return new Response(JSON.stringify({ error: 'Missing userId or updates' }), {
        status: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
        }
      })
    }

    // Prepare update object
    const updateData: any = {}
    if (updates.user_type) {
      updateData.user_type = updates.user_type
    }
    if (updates.status) {
      if (updates.status === 'locked') {
        updateData.locked_at = new Date().toISOString()
      } else if (updates.status === 'active') {
        updateData.locked_at = null
      }
    }

    console.log('Updating user profile:', { userId, updateData })

    // Update the user profile
    const { data, error: updateError } = await supabase
      .from('user_profiles')
      .update(updateData)
      .eq('id', userId)
      .select()

    console.log('Update result:', { data, error: updateError })

    if (updateError) {
      console.error('Error updating profile:', updateError)
      return new Response(JSON.stringify({ 
        error: 'Failed to update user profile',
        details: updateError.message,
        code: updateError.code
      }), {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
        }
      })
    }

    if (!data || data.length === 0) {
      console.error('No rows updated - possibly RLS issue or invalid userId')
      return new Response(JSON.stringify({ 
        error: 'Failed to update user profile',
        details: 'No rows were updated. Check RLS policies or userId.'
      }), {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
        }
      })
    }

    console.log('Successfully updated profile:', data[0])
    return new Response(JSON.stringify({ success: true, data: data[0] }), {
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
      }
    })

  } catch (error) {
    console.error('Unexpected error:', error)
    return new Response(JSON.stringify({ error: 'Internal server error' }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
      }
    })
  }
})
