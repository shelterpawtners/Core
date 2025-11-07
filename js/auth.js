// Authentication Management
// Handles login, registration, session management

class AuthManager {
    constructor() {
        this.currentUser = null;
        this.loginCallbacks = [];
        this.logoutCallbacks = [];
        
        // Check for existing session on page load
        this.checkExistingSession();
    }

    // Session Management
    checkExistingSession() {
        const userData = localStorage.getItem('shelterpawtner_user');
        if (userData) {
            try {
                this.currentUser = JSON.parse(userData);
                this.triggerLoginCallbacks(this.currentUser);
            } catch (e) {
                console.error('Invalid session data, clearing:', e);
                this.clearSession();
            }
        }
    }

    saveSession(user) {
        this.currentUser = user;
        localStorage.setItem('shelterpawtner_user', JSON.stringify(user));
        this.triggerLoginCallbacks(user);
    }

    clearSession() {
        this.currentUser = null;
        localStorage.removeItem('shelterpawtner_user');
        this.triggerLogoutCallbacks();
    }

    // Event Listeners
    onLogin(callback) {
        this.loginCallbacks.push(callback);
    }

    onLogout(callback) {
        this.logoutCallbacks.push(callback);
    }

    triggerLoginCallbacks(user) {
        this.loginCallbacks.forEach(callback => callback(user));
    }

    triggerLogoutCallbacks() {
        this.logoutCallbacks.forEach(callback => callback());
    }

    // Authentication Methods
    async register(formData) {
        try {
            const response = await window.db.register({
                firstName: formData.firstName,
                lastName: formData.lastName,
                email: formData.email,
                password: formData.password,
                phone: formData.phone
            });

            if (response.success) {
                this.saveSession(response.user);
                return { success: true, message: response.message || 'Registration successful!' };
            } else {
                return { success: false, message: response.message || 'Registration failed' };
            }
        } catch (error) {
            console.error('Registration error:', error);
            return { success: false, message: 'Registration failed. Please try again.' };
        }
    }

    async login(email, password) {
        try {
            const response = await window.db.loginUser(email, password);

            if (response.success) {
                this.saveSession(response.user);
                return { success: true, message: response.message || 'Login successful!' };
            } else {
                return { success: false, message: response.message || 'Invalid email or password' };
            }
        } catch (error) {
            console.error('Login error:', error);
            return { success: false, message: 'Login failed. Please try again.' };
        }
    }

    async loginWithGoogle() {
        try {
            const response = await window.db.loginWithGoogle();
            
            if (response.success) {
                this.saveSession(response.user);
                return { success: true, message: 'Google login successful!' };
            } else {
                return { success: false, message: 'Google login failed' };
            }
        } catch (error) {
            console.error('Google login error:', error);
            return { success: false, message: 'Google login failed. Please try again.' };
        }
    }

    logout() {
        // Clear Supabase session if available
        if (window.db && window.db.supabase) {
            window.db.supabase.auth.signOut().catch(err => {
                console.error('Error signing out from Supabase:', err);
            });
        }
        
        // Clear local session
        this.clearSession();
        
        // Clear any other stored data
        localStorage.removeItem('shelterpawtner_redirect');
        
        // Redirect to homepage
        window.location.href = '/index.html';
    }

    // Utility Methods
    isLoggedIn() {
        return !!this.currentUser;
    }

    getCurrentUser() {
        return this.currentUser;
    }

    requireAuth() {
        if (!this.isLoggedIn()) {
            // Store the current page to redirect back after login
            localStorage.setItem('shelterpawtner_redirect', window.location.pathname);
            window.location.href = '/pages/login.html';
            return false;
        }
        return true;
    }

    // Async authentication check (for compatibility with async/await)
    async checkAuth() {
        return this.isLoggedIn();
    }

    // Form Validation
    validateEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    validatePassword(password) {
        // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
        const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$/;
        return passwordRegex.test(password);
    }

    validateForm(formData) {
        const errors = [];

        if (!formData.email) {
            errors.push('Email is required');
        } else if (!this.validateEmail(formData.email)) {
            errors.push('Please enter a valid email address');
        }

        if (!formData.password) {
            errors.push('Password is required');
        } else if (!this.validatePassword(formData.password)) {
            errors.push('Password must be at least 8 characters with uppercase, lowercase, and number');
        }

        if (formData.confirmPassword && formData.password !== formData.confirmPassword) {
            errors.push('Passwords do not match');
        }

        if (formData.firstName && formData.firstName.trim().length < 2) {
            errors.push('First name must be at least 2 characters');
        }

        if (formData.lastName && formData.lastName.trim().length < 2) {
            errors.push('Last name must be at least 2 characters');
        }

        return errors;
    }

    // UI Helper Methods
    showMessage(element, message, isError = false) {
        if (!element) return;
        
        element.textContent = message;
        element.className = `message ${isError ? 'error' : 'success'}`;
        element.style.display = 'block';
        
        // Clear message after 5 seconds
        setTimeout(() => {
            element.style.display = 'none';
        }, 5000);
    }

    toggleLoading(button, loading = true) {
        if (!button) return;
        
        if (loading) {
            button.disabled = true;
            button.dataset.originalText = button.textContent;
            button.textContent = 'Loading...';
        } else {
            button.disabled = false;
            button.textContent = button.dataset.originalText || button.textContent;
        }
    }
}

// Initialize global auth manager
window.authManager = new AuthManager();

// Update UI based on auth state
window.authManager.onLogin((user) => {
    console.log('User logged in:', user);
    // Update navigation to show user menu
    updateNavigationForLoggedInUser(user);
});

window.authManager.onLogout(() => {
    console.log('User logged out');
    // Reset navigation to default
    updateNavigationForLoggedOutUser();
});

// Navigation Update Functions
function updateNavigationForLoggedInUser(user) {
    // Find navigation elements and add user menu
    const nav = document.querySelector('.nav-menu');
    if (nav) {
        // Remove existing user menu
        const existingUserMenu = nav.querySelector('.user-menu');
        if (existingUserMenu) {
            existingUserMenu.remove();
        }
        
        // Add user menu
        const userMenuItem = document.createElement('li');
        userMenuItem.className = 'nav-item has-dropdown user-menu';
        userMenuItem.innerHTML = `
            <a href="#" class="nav-link" role="menuitem" aria-haspopup="true">
                👋 ${user.first_name || user.email}
            </a>
            <ul class="dropdown-menu" role="menu">
                <li role="none"><a href="/pages/dashboard.html" class="dropdown-link" role="menuitem">Dashboard</a></li>
                <li role="none"><a href="/pages/my-pets.html" class="dropdown-link" role="menuitem">My Pets</a></li>
                <li role="none"><a href="/pages/account.html" class="dropdown-link" role="menuitem">Account</a></li>
                <li role="none"><a href="#" class="dropdown-link logout-btn" role="menuitem">Logout</a></li>
            </ul>
        `;
        
        nav.appendChild(userMenuItem);
        
        // Add logout functionality
        const logoutBtn = userMenuItem.querySelector('.logout-btn');
        if (logoutBtn) {
            logoutBtn.addEventListener('click', (e) => {
                e.preventDefault();
                window.authManager.logout();
            });
        }
    }
}

function updateNavigationForLoggedOutUser() {
    // Remove user menu if present
    const userMenu = document.querySelector('.user-menu');
    if (userMenu) {
        userMenu.remove();
    }
}



// Export for module use
if (typeof module !== 'undefined' && module.exports) {
    module.exports = AuthManager;
}