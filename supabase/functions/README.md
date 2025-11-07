# Supabase Edge Functions for Admin Operations

This directory contains Supabase Edge Functions that provide secure admin operations for the Shelter Pawtners application.

## Functions

### admin-get-users
- **Purpose**: Retrieves all user profiles for admin management
- **Method**: GET
- **Authentication**: Requires valid JWT token and admin privileges
- **Response**: JSON array of user profiles with id, email, first_name, last_name, user_type, created_at

### admin-update-user
- **Purpose**: Updates user profile information (user_type, status)
- **Method**: POST
- **Authentication**: Requires valid JWT token and admin privileges
- **Request Body**:
  ```json
  {
    "userId": "uuid",
    "updates": {
      "user_type": "pet_parent|business|shelter|admin",
      "status": "active|locked"
    }
  }
  ```

## Security Features

- **JWT Authentication**: Functions verify the user's JWT token
- **Admin Authorization**: Checks admin_users table for active admin status
- **Service Role Access**: Uses service role key for database operations
- **Input Validation**: Validates request parameters and data types

## Deployment

Run the deployment script:
```bash
./deploy-functions.sh
```

Or manually:
```bash
supabase login
supabase link --project-ref nudwqhncbctyqkhafttd
supabase functions deploy admin-get-users
supabase functions deploy admin-update-user
```

## Local Development

To test functions locally:
```bash
supabase start
supabase functions serve admin-get-users --no-verify-jwt
```

## Environment Variables Required

The functions use these environment variables (automatically set by Supabase):
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

## Error Handling

Functions return appropriate HTTP status codes:
- `401`: Unauthorized (invalid/missing token)
- `403`: Forbidden (not an admin)
- `400`: Bad Request (invalid parameters)
- `405`: Method Not Allowed
- `500`: Internal Server Error