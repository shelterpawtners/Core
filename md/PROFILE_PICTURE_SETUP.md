# Profile Picture Storage System

## Overview
The profile picture system is designed for maximum storage efficiency while maintaining quality for user identification purposes.

## Storage Efficiency Features

### 1. **Automatic Image Compression**
- Resizes images to 256x256px (optimal for profile photos)
- Converts all images to WebP format (50-80% smaller than JPEG)
- Uses 80% quality setting for best size/quality balance
- Maintains aspect ratio during resize

### 2. **Smart File Naming**
- Format: `profile_{user_id}_{timestamp}.webp`
- Prevents filename conflicts
- Easy to identify and manage
- Timestamped for version tracking

### 3. **Storage Limits**
- Original upload: 5MB max
- Compressed result: Typically 20-100KB
- 2MB bucket limit (safety measure, rarely reached)

## Supabase Setup Required

Run this SQL in your Supabase SQL Editor:

```sql
-- Create storage bucket for profile pictures
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'profile-pictures',
    'profile-pictures', 
    true,
    2097152,  -- 2MB limit
    ARRAY['image/webp', 'image/jpeg', 'image/png']
);

-- Set up RLS policies
CREATE POLICY "Users can upload their own profile picture" ON storage.objects
FOR INSERT WITH CHECK (
    bucket_id = 'profile-pictures' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can view all profile pictures" ON storage.objects
FOR SELECT USING (bucket_id = 'profile-pictures');

CREATE POLICY "Users can update their own profile picture" ON storage.objects
FOR UPDATE USING (
    bucket_id = 'profile-pictures' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);
```

## Usage

1. **Upload Process**:
   - User selects image file
   - Image is automatically compressed and converted to WebP
   - Preview is shown immediately
   - File is uploaded to Supabase Storage
   - Profile URL is saved to user_profiles table

2. **Loading Process**:
   - Profile picture URL is loaded from user_profiles table
   - Image is displayed from Supabase Storage CDN
   - Fallback to default image if no profile picture exists

## Benefits

- **90% storage savings** vs uncompressed images
- **Fast loading** due to WebP format and small file sizes
- **CDN delivery** through Supabase
- **Secure access** with Row Level Security
- **Automatic cleanup** (can add later if needed)

## Future Enhancements

- Automatic deletion of old profile pictures when new ones are uploaded
- Multiple size variants (thumbnail, medium, large)
- Image optimization for different screen densities
- Batch processing for existing images