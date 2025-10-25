// Shelter Pawtners Database Integration
// Supabase Database Service

class ShelterPawtnerDB {
    constructor() {
        // Check if Supabase configuration is available
        if (typeof window !== 'undefined' && window.SUPABASE_CONFIG) {
            const config = window.SUPABASE_CONFIG;
            
            // Check if configuration is set up
            if (config.url && config.anonKey && 
                config.url !== 'YOUR_SUPABASE_URL_HERE' && 
                config.anonKey !== 'YOUR_SUPABASE_ANON_KEY_HERE') {
                
                // Real Supabase mode
                this.demoMode = false;
                this.supabaseUrl = config.url;
                this.supabaseKey = config.anonKey;
                
                // Initialize Supabase client (assumes Supabase JS library is loaded)
                if (typeof supabase !== 'undefined') {
                    this.supabase = supabase.createClient(this.supabaseUrl, this.supabaseKey);
                    console.log('✅ Connected to Supabase database');
                } else {
                    console.error('❌ Supabase library not loaded');
                    this.fallbackToDemo();
                }
            } else {
                console.log('⚠️  Supabase config not set up, falling back to demo mode');
                this.fallbackToDemo();
            }
        } else {
            console.log('⚠️  Supabase config not found, falling back to demo mode');
            this.fallbackToDemo();
        }
    }
    
    fallbackToDemo() {
        this.demoMode = true;
        console.log('🚧 Running in DEMO mode - no real database connection');
        this.demoData = {
            users: [],
            pets: [],
            medicalRecords: []
        };
    }

    // Initialize the database connection
    async initialize() {
        try {
            if (this.demoMode) {
                console.log('✅ Database initialized in demo mode');
                return { success: true, message: 'Demo mode initialized' };
            }

            // Test the Supabase connection
            if (this.supabase) {
                // Simple test query to verify connection
                const { data, error } = await this.supabase
                    .from('user_profiles')
                    .select('count')
                    .limit(1);
                
                if (error) {
                    console.log('⚠️  Supabase connection test failed, but connection established:', error.message);
                } else {
                    console.log('✅ Supabase connection verified');
                }
                
                return { success: true, message: 'Supabase connection initialized' };
            } else {
                throw new Error('Supabase client not initialized');
            }
        } catch (error) {
            console.error('❌ Database initialization failed:', error);
            return { success: false, message: error.message };
        }
    }

    // Authentication Methods
    async register(userData) {
        if (this.demoMode) {
            // Demo mode simulation
            const user = {
                id: 'demo_' + Date.now(),
                email: userData.email,
                name: `${userData.firstName} ${userData.lastName}`,
                created_at: new Date().toISOString()
            };
            
            this.demoData.users.push(user);
            
            return {
                success: true,
                user: user,
                message: 'Demo account created successfully'
            };
        }
        
        // Real Supabase registration
        try {
            const { data: authData, error: authError } = await this.supabase.auth.signUp({
                email: userData.email,
                password: userData.password,
                options: {
                    data: {
                        first_name: userData.firstName,
                        last_name: userData.lastName,
                        phone: userData.phone
                    }
                }
            });
            
            if (authError) throw authError;
            
            // The user profile will be created automatically via database trigger
            
            return {
                success: true,
                user: authData.user,
                message: 'Account created successfully! Please check your email to verify your account.'
            };
        } catch (error) {
            return {
                success: false,
                message: error.message
            };
        }
    }

    async loginUser(email, password) {
        if (this.demoMode) {
            // Demo mode simulation
            const user = this.demoData.users.find(u => u.email === email);
            if (user) {
                return {
                    success: true,
                    user: user,
                    message: 'Demo login successful'
                };
            } else {
                return {
                    success: false,
                    message: 'Demo user not found. Try registering first.'
                };
            }
        }
        
        // Real Supabase login
        try {
            const { data: authData, error: authError } = await this.supabase.auth.signInWithPassword({
                email: email,
                password: password
            });
            
            if (authError) throw authError;
            
            return {
                success: true,
                user: authData.user,
                session: authData.session,
                message: 'Login successful'
            };
        } catch (error) {
            return {
                success: false,
                message: error.message
            };
        }
    }

    async loginWithGoogle() {
        if (this.demoMode) {
            console.log('Demo: Google OAuth login');
            return { success: true, user: { email: 'demo@gmail.com', id: this.generateUUID() }};
        }
        
        // Real Supabase implementation:
        /*
        const { data, error } = await this.supabase.auth.signInWithOAuth({
            provider: 'google',
            options: {
                redirectTo: window.location.origin + '/dashboard.html'
            }
        });
        return { success: !error, error: error };
        */
    }

    // Pet Management Methods
    async createPet(petData) {
        if (this.demoMode) {
            console.log('Demo: Creating pet', petData);
            const pet = {
                id: this.generateUUID(),
                owner_id: 'demo_user',
                created_at: new Date().toISOString(),
                ...petData
            };
            this.demoData.pets.push(pet);
            return { success: true, pet: pet };
        }
        
        try {
            // Try to get current user from multiple sources
            let user = null;
            let userId = null;
            
            // First try Supabase auth
            try {
                const { data: { user: supabaseUser } } = await this.supabase.auth.getUser();
                if (supabaseUser) {
                    user = supabaseUser;
                    userId = supabaseUser.id;
                }
            } catch (authError) {
                console.log('No Supabase auth session:', authError.message);
            }
            
            // If no Supabase user, try AuthManager
            if (!userId && window.authManager) {
                const currentUser = window.authManager.getCurrentUser();
                if (currentUser && currentUser.id) {
                    userId = currentUser.id;
                    user = currentUser;
                }
            }
            
            // If still no user, return error
            if (!userId) {
                return { success: false, message: 'User not authenticated. Please log in first.' };
            }

            console.log('Creating pet for user:', userId);

            // Insert pet record
            const { data, error } = await this.supabase
                .from('pets')
                .insert([{
                    owner_id: userId,
                    ...petData
                }])
                .select();
                
            if (error) {
                console.error('Supabase error creating pet:', error);
                return { success: false, message: error.message };
            }
            
            return { success: true, pet: data[0], message: 'Pet profile created successfully!' };
            
        } catch (error) {
            console.error('Error creating pet:', error);
            return { success: false, message: 'Failed to create pet profile' };
        }
    }

    async updatePet(petId, petData) {
        if (this.demoMode) {
            const petIndex = this.demoData.pets.findIndex(p => p.id === petId);
            if (petIndex !== -1) {
                this.demoData.pets[petIndex] = {
                    ...this.demoData.pets[petIndex],
                    ...petData,
                    updated_at: new Date().toISOString()
                };
                return { success: true, pet: this.demoData.pets[petIndex], message: 'Pet profile updated successfully!' };
            } else {
                return { success: false, message: 'Pet not found' };
            }
        }

        try {
            // Get current user
            let userId = null;
            let user = null;

            // Try to get user from Supabase auth first
            try {
                const { data: { user: supabaseUser } } = await this.supabase.auth.getUser();
                if (supabaseUser) {
                    user = supabaseUser;
                    userId = supabaseUser.id;
                }
            } catch (authError) {
                console.log('No Supabase auth session:', authError.message);
            }
            
            // If no Supabase user, try AuthManager
            if (!userId && window.authManager) {
                const currentUser = window.authManager.getCurrentUser();
                if (currentUser && currentUser.id) {
                    userId = currentUser.id;
                    user = currentUser;
                }
            }
            
            // If still no user, return error
            if (!userId) {
                return { success: false, message: 'User not authenticated. Please log in first.' };
            }

            console.log('Updating pet for user:', userId);

            // Update pet record (only if it belongs to the current user)
            const { data, error } = await this.supabase
                .from('pets')
                .update({
                    ...petData,
                    updated_at: new Date().toISOString()
                })
                .eq('id', petId)
                .eq('owner_id', userId) // Ensure user can only update their own pets
                .select();
                
            if (error) {
                console.error('Supabase error updating pet:', error);
                return { success: false, message: error.message };
            }
            
            if (data.length === 0) {
                return { success: false, message: 'Pet not found or you do not have permission to update this pet.' };
            }
            
            return { success: true, pet: data[0], message: 'Pet profile updated successfully!' };
            
        } catch (error) {
            console.error('Error updating pet:', error);
            return { success: false, message: 'Failed to update pet profile' };
        }
    }

    async getUserPets() {
        if (this.demoMode) {
            const pets = this.demoData.pets.filter(p => p.owner_id === 'demo_user');
            return { success: true, pets: pets };
        }
        
        try {
            // Get current user ID from Supabase auth
            const { data: { user } } = await this.supabase.auth.getUser();
            
            if (!user) {
                console.log('No authenticated user found');
                return { success: false, message: 'User not authenticated', pets: [] };
            }

            const { data, error } = await this.supabase
                .from('pets')
                .select('*')
                .eq('owner_id', user.id)
                .order('created_at', { ascending: false });
                
            if (error) {
                console.error('Error fetching pets:', error);
                return { success: false, message: error.message, pets: [] };
            }
            
            return { success: true, pets: data || [] };
            
        } catch (error) {
            console.error('Error getting user pets:', error);
            return { success: false, message: 'An error occurred while fetching pets', pets: [] };
        }
    }

    async getPetById(petId) {
        if (this.demoMode) {
            const pet = this.demoData.pets.find(p => p.id === petId);
            if (pet) {
                return { success: true, pet: pet };
            } else {
                return { success: false, message: 'Pet not found' };
            }
        }
        
        try {
            const { data, error } = await this.supabase
                .from('pets')
                .select(`
                    *,
                    shelters(name, city, state)
                `)
                .eq('id', petId)
                .single();
                
            if (error) {
                console.error('Supabase error getting pet:', error);
                return { success: false, message: error.message };
            }
            
            return { success: true, pet: data };
            
        } catch (error) {
            console.error('Error getting pet by ID:', error);
            return { success: false, message: 'An error occurred while fetching the pet.' };
        }
    }

    // Medical Records Methods
    async addMedicalRecord(petId, recordData) {
        if (this.demoMode) {
            const record = {
                id: this.generateUUID(),
                pet_id: petId,
                created_at: new Date().toISOString(),
                ...recordData
            };
            this.demoData.medicalRecords.push(record);
            return { success: true, record: record };
        }
        
        // Real implementation would go here
    }

    async getPetMedicalRecords(petId) {
        if (this.demoMode) {
            const records = this.demoData.medicalRecords.filter(r => r.pet_id === petId);
            return { success: true, records: records };
        }
        
        // Real implementation would go here
    }

    // Shelter Methods
    async getShelters() {
        if (this.demoMode) {
            return { 
                success: true, 
                shelters: [
                    { id: '1', name: 'Happy Paws Rescue', city: 'Austin', state: 'TX' },
                    { id: '2', name: 'Second Chance Animal Shelter', city: 'Denver', state: 'CO' },
                    { id: '3', name: 'Furry Friends Foundation', city: 'Portland', state: 'OR' }
                ]
            };
        }
        
        // Real implementation would go here
    }

    // Utility Methods
    generateUUID() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }

    // File Upload Methods (for photos, documents)
    async uploadFile(file, folder = 'pet-photos') {
        if (this.demoMode) {
            console.log('Demo: Uploading file', file.name);
            // Simulate file upload
            const fakeUrl = `https://demo-storage.com/${folder}/${this.generateUUID()}-${file.name}`;
            return { success: true, url: fakeUrl };
        }
        
        // Real Supabase implementation:
        /*
        const fileName = `${Date.now()}-${file.name}`;
        const { data, error } = await this.supabase.storage
            .from(folder)
            .upload(fileName, file);
        
        if (error) return { success: false, error: error };
        
        const { data: { publicUrl } } = this.supabase.storage
            .from(folder)
            .getPublicUrl(fileName);
            
        return { success: true, url: publicUrl };
        */
    }
}

// Initialize global database instance
window.shelterDB = new ShelterPawtnerDB();

// Export for module use
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ShelterPawtnerDB;
}