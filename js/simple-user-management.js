// Simple User Management JavaScript
// Initialize Supabase client
const { createClient } = supabase;
const supabaseClient = createClient(SUPABASE_CONFIG.url, SUPABASE_CONFIG.anonKey);

// Simple admin authentication check
async function checkAdminAuth() {
    try {
        const { data: { session }, error } = await supabaseClient.auth.getSession();
        
        if (error || !session) {
            redirectToLogin();
            return false;
        }

        // Check admin privileges
        const { data: adminUser, error: adminError } = await supabaseClient
            .from('admin_users')
            .select('*')
            .eq('email', session.user.email.toLowerCase())
            .eq('active', true)
            .single();

        if (adminError || !adminUser) {
            await supabaseClient.auth.signOut();
            redirectToLogin();
            return false;
        }

        return true;
    } catch (error) {
        console.error('Auth check error:', error);
        redirectToLogin();
        return false;
    }
}

function redirectToLogin() {
    window.location.href = 'admin-login.html';
}

async function logout() {
    if (confirm('Are you sure you want to log out?')) {
        try {
            await supabaseClient.auth.signOut();
            window.location.href = 'admin-login.html';
        } catch (error) {
            console.error('Logout error:', error);
            window.location.href = 'admin-login.html';
        }
    }
}

// Add admin user
async function addAdmin() {
    const email = document.getElementById('adminEmail').value.trim();
    const name = document.getElementById('adminName').value.trim();
    
    if (!email || !name) {
        alert('Please enter both email and name.');
        return;
    }
    
    try {
        // Use upsert to handle existing inactive records
        const { data, error } = await supabaseClient
            .from('admin_users')
            .upsert({
                email: email.toLowerCase(),
                full_name: name,
                role: 'admin',
                active: true
            }, {
                onConflict: 'email'
            });
        
        if (error) {
            throw error;
        } else {
            alert('Admin user added successfully!');
            document.getElementById('adminEmail').value = '';
            document.getElementById('adminName').value = '';
            loadAdminList();
        }
    } catch (error) {
        console.error('Error adding admin:', error);
        alert('Error adding admin user: ' + error.message);
    }
}

// Remove admin user
async function removeAdmin() {
    const email = document.getElementById('removeEmail').value.trim();
    
    if (!email) {
        alert('Please enter an email address.');
        return;
    }
    
    if (!confirm(`Are you sure you want to remove admin access for ${email}?`)) {
        return;
    }
    
    try {
        const { data, error } = await supabaseClient
            .from('admin_users')
            .update({ active: false })
            .eq('email', email.toLowerCase());
        
        if (error) throw error;
        
        alert('Admin access removed successfully!');
        document.getElementById('removeEmail').value = '';
        loadAdminList();
    } catch (error) {
        console.error('Error removing admin:', error);
        alert('Error removing admin access: ' + error.message);
    }
}

// Load admin list
async function loadAdminList() {
    const listDiv = document.getElementById('adminList');
    listDiv.innerHTML = '<div class="loading-state">Loading admin users...</div>';
    
    try {
        // Get all admin users for debugging
        const { data: allAdmins, error: allError } = await supabaseClient
            .from('admin_users')
            .select('*')
            .order('created_at', { ascending: false });
        
        console.log('All admin users in database:', allAdmins);
        
        // Get only active admin users for display
        const { data: admins, error } = await supabaseClient
            .from('admin_users')
            .select('*')
            .eq('active', true)
            .order('created_at', { ascending: false });
        
        if (error) throw error;
        
        if (!admins || admins.length === 0) {
            listDiv.innerHTML = '<div class="empty-state">No admin users found.</div>';
            return;
        }
        
        listDiv.innerHTML = admins.map(admin => `
            <div style="padding: 1rem; margin: 0.5rem 0; background: rgba(255, 255, 255, 0.1); border-radius: 8px; border: 1px solid rgba(139, 92, 246, 0.3);">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <div>
                        <strong style="color: #F9FAFB;">${admin.full_name}</strong>
                        <br>
                        <span style="color: #D1D5DB; font-size: 0.875rem;">${admin.email}</span>
                        <br>
                        <span style="color: #9CA3AF; font-size: 0.75rem;">
                            Role: ${admin.role} | Created: ${new Date(admin.created_at).toLocaleDateString()}
                        </span>
                    </div>
                    <button onclick="quickRemoveAdmin('${admin.email}')" class="btn btn-danger" style="font-size: 0.75rem; padding: 0.5rem;">
                        Remove
                    </button>
                </div>
            </div>
        `).join('');
        
    } catch (error) {
        console.error('Error loading admin list:', error);
        listDiv.innerHTML = '<div class="empty-state">Error loading admin users.</div>';
    }
}

// Quick remove admin (from the list)
async function quickRemoveAdmin(email) {
    if (!confirm(`Remove admin access for ${email}?`)) {
        return;
    }
    
    try {
        const { error } = await supabaseClient
            .from('admin_users')
            .update({ active: false })
            .eq('email', email.toLowerCase());
        
        if (error) throw error;
        
        alert('Admin access removed!');
        loadAdminList();
    } catch (error) {
        console.error('Error removing admin:', error);
        alert('Error: ' + error.message);
    }
}

// Debug function to check database
async function debugDatabase() {
    try {
        const { data: allUsers, error } = await supabaseClient
            .from('admin_users')
            .select('*');
        
        console.log('=== DATABASE DEBUG ===');
        console.log('All admin_users records:', allUsers);
        
        if (allUsers) {
            allUsers.forEach(user => {
                console.log(`Email: ${user.email}, Active: ${user.active}, Created: ${user.created_at}`);
            });
        }
        
        alert('Check the browser console for database contents.');
    } catch (error) {
        console.error('Debug error:', error);
        alert('Error checking database: ' + error.message);
    }
}

// Add debug button functionality
function addDebugButton() {
    const container = document.querySelector('.management-section');
    if (container) {
        const debugBtn = document.createElement('button');
        debugBtn.textContent = 'Debug Database';
        debugBtn.className = 'btn';
        debugBtn.style.marginLeft = '1rem';
        debugBtn.onclick = debugDatabase;
        container.appendChild(debugBtn);
    }
}

// Initialize page
document.addEventListener('DOMContentLoaded', async function() {
    const isAuthenticated = await checkAdminAuth();
    if (isAuthenticated) {
        loadAdminList();
        addDebugButton();
    }
});