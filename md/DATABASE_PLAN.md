# 🐾 Shelter Pawtners - Database Implementation Plan

## Database Architecture Overview

### **Primary Solution: Supabase (PostgreSQL)**
- **Cost**: FREE (up to 500MB database, 50,000 monthly active users)
- **Features**: Authentication, real-time APIs, file storage, edge functions
- **Upgrade Path**: $25/month for Pro when needed

---

## Database Schema Design

### **1. Core Tables**

#### `users` (Supabase Auth handles this)
```sql
-- Auto-created by Supabase Auth
id (uuid, primary key)
email (text)
created_at (timestamp)
updated_at (timestamp)
user_metadata (jsonb) -- Custom profile fields
```

#### `pet_owners` 
```sql
id (uuid, primary key)
user_id (uuid, foreign key to auth.users)
first_name (text)
last_name (text)  
phone (text)
address (text)
city (text)
state (text)
zip_code (text)
emergency_contact_name (text)
emergency_contact_phone (text)
created_at (timestamp)
updated_at (timestamp)
```

#### `pets`
```sql
id (uuid, primary key)
owner_id (uuid, foreign key to pet_owners)
name (text)
species (text) -- dog, cat, etc.
breed (text)
age (integer)
weight (decimal)
color (text)
microchip_id (text, unique)
adoption_date (date)
shelter_id (uuid, foreign key)
photo_url (text)
active (boolean, default true)
created_at (timestamp)
updated_at (timestamp)
```

#### `shelters`
```sql
id (uuid, primary key)
name (text)
address (text)
city (text)
state (text)
zip_code (text)
phone (text)
email (text)
website (text)
license_number (text)
active (boolean, default true)
created_at (timestamp)
```

#### `medical_records`
```sql
id (uuid, primary key)
pet_id (uuid, foreign key)
record_type (text) -- vaccination, medication, procedure, checkup
record_date (date)
provider_name (text)
notes (text)
attachments (text[]) -- Array of file URLs
created_at (timestamp)
```

#### `vaccinations`
```sql
id (uuid, primary key)
pet_id (uuid, foreign key)
vaccine_name (text)
vaccination_date (date)
expiration_date (date)
veterinarian (text)
batch_number (text)
created_at (timestamp)
```

#### `medications`
```sql
id (uuid, primary key)
pet_id (uuid, foreign key)
medication_name (text)
dosage (text)
frequency (text)
start_date (date)
end_date (date)
prescribing_vet (text)
active (boolean, default true)
created_at (timestamp)
```

#### `behavioral_notes`
```sql
id (uuid, primary key)
pet_id (uuid, foreign key)
note_type (text) -- training, behavior, preference, trigger
title (text)
description (text)
severity (integer) -- 1-5 scale
created_at (timestamp)
```

#### `business_partners`
```sql
id (uuid, primary key)
business_name (text)
business_type (text) -- vet, groomer, trainer, store
contact_email (text)
phone (text)
address (text)
city (text)
state (text)
zip_code (text)
discount_percentage (decimal)
services_offered (text[])
active (boolean, default true)
created_at (timestamp)
```

#### `sheltercard_benefits`
```sql
id (uuid, primary key)
owner_id (uuid, foreign key)
partner_id (uuid, foreign key)
benefit_type (text)
discount_percentage (decimal)
usage_count (integer, default 0)
last_used (timestamp)
active (boolean, default true)
created_at (timestamp)
```

---

## Implementation Phases

### **Phase 1: User Authentication & Pet Registration (Week 1-2)**

**Pages to Convert to Functional:**
1. **Pet Owner Registration** (`owners.html` → `register.html`)
2. **Pet Profile Creation** (`#create-profile` → `create-pet.html`)
3. **Login/Dashboard** (new: `dashboard.html`)

**Key Features:**
- Email/password registration
- Google OAuth integration
- Basic pet profile creation
- Microchip ID validation

### **Phase 2: Medical Records & ShelterCARD (Week 3-4)**

**Pages to Add:**
1. **Medical Records Dashboard** (`medical-records.html`)
2. **ShelterCARD Activation** (`#activate-card` → `activate-sheltercard.html`)
3. **Partner Directory** (`partner-directory.html`)

**Key Features:**
- Upload vaccination records
- Track medications
- ShelterCARD benefit activation
- QR code generation for vet visits

### **Phase 3: Business & Shelter Portals (Week 5-6)**

**Pages to Add:**
1. **Business Registration** (`business-register.html`)
2. **Shelter Partner Portal** (`shelter-portal.html`)
3. **Veterinarian Dashboard** (`vet-dashboard.html`)

**Key Features:**
- Business partner onboarding
- Shelter intake integration
- Veterinarian record access (with consent)

---

## Alternative Database Options

### **Option 2: Firebase (Google)**
**Pros:**
- 1GB storage free
- Built-in authentication
- Real-time database
- Good mobile integration

**Cons:**
- NoSQL only
- More complex querying
- $25/month for significant usage

### **Option 3: PlanetScale (MySQL)**
**Pros:**
- 5GB storage free
- Branching for database schema changes
- Excellent performance

**Cons:**
- No built-in auth (need separate service)
- MySQL only

### **Option 4: Neon (PostgreSQL)**
**Pros:**
- 3GB storage free
- PostgreSQL compatible
- Serverless

**Cons:**
- No built-in auth
- Newer service

---

## Cost Analysis (Monthly)

| Service | Free Tier | Pro Tier | Users Supported | Storage |
|---------|-----------|----------|-----------------|---------|
| **Supabase** | $0 | $25 | 50K / 100K | 500MB / 8GB |
| Firebase | $0 | $25 | Unlimited | 1GB / 10GB |
| PlanetScale | $0 | $29 | N/A | 5GB / 10GB |
| Neon | $0 | $19 | N/A | 3GB / 10GB |

---

## Security & Privacy Features

### **Data Protection:**
- Row Level Security (RLS) policies
- Encrypted data at rest and in transit
- HIPAA-ready infrastructure (Supabase Pro)
- User consent management for data sharing

### **Access Controls:**
- Pet owners can only access their own data
- Veterinarians require explicit consent
- Businesses see only aggregate/anonymous data
- Shelters maintain intake records

---

## Next Steps

### **Immediate Actions (This Week):**
1. Set up Supabase project
2. Create database schema
3. Convert first registration form
4. Set up authentication flow

### **Required Files to Create:**
- `js/database.js` - Supabase client setup
- `js/auth.js` - Authentication functions  
- `pages/register.html` - Pet owner registration
- `pages/dashboard.html` - User dashboard
- `pages/create-pet.html` - Pet profile creation

**Would you like me to start implementing the Supabase setup and create the first functional registration form?**