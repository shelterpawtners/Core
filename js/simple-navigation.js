/**
 * SIMPLE UNIFIED NAVIGATION
 * Single navigation for all pages - logo and links on same line
 */

class SimpleUnifiedNavigation {
    constructor() {
        this.isAuthenticated = false;
        this.currentPage = this.getCurrentPage();
        this.init();
    }

    /**
     * Get current page name from URL
     */
    getCurrentPage() {
        const path = window.location.pathname;
        const filename = path.split('/').pop();
        return filename.replace('.html', '') || 'index';
    }

    /**
     * Check if user is authenticated
     */
    checkAuthState() {
        // Check multiple sources for authentication state
        // 1. localStorage flag
        const localStorageAuth = localStorage.getItem('userAuthenticated') === 'true';
        
        // 2. sessionStorage flag  
        const sessionStorageAuth = sessionStorage.getItem('userAuthenticated') === 'true';
        
        // 3. Check if we're on authenticated pages (these should show My Account)
        const authPages = ['dashboard', 'my-pets', 'profile'];
        const onAuthPage = authPages.includes(this.currentPage);
        
        // 4. Check for authentication cookie or token
        const hasAuthCookie = document.cookie.includes('auth_token') || document.cookie.includes('user_session');
        
        // User is authenticated if any of these conditions are true
        this.isAuthenticated = localStorageAuth || sessionStorageAuth || onAuthPage || hasAuthCookie;
        
        // For demo purposes: if visiting authenticated pages, assume user is logged in
        if (onAuthPage) {
            this.isAuthenticated = true;
            // Set localStorage to maintain auth state across pages
            localStorage.setItem('userAuthenticated', 'true');
        }
    }

    /**
     * Get base path for links
     */
    getBasePath() {
        const path = window.location.pathname;
        return path.includes('/pages/') ? '../' : '';
    }

    /**
     * Generate navigation HTML - Logo and links on SAME LINE
     */
    getNavigationHTML() {
        const basePath = this.getBasePath();
        
        return `
            <div class="container">
                <div class="header-content">
                    <!-- Logo -->
                    <a href="${basePath}index.html" class="logo">
                        <span class="logo-text">🐾 Shelter Pawtners</span>
                    </a>
                    
                    <!-- Desktop Navigation - Same Line -->
                    <nav class="nav desktop-nav">
                        <ul class="nav-menu">
                            <li class="nav-item nav-dropdown">
                                <button class="nav-link dropdown-toggle">
                                    How It Works <span class="dropdown-arrow">▼</span>
                                </button>
                                <ul class="dropdown-menu">
                                    <li><a href="${basePath}pages/how-it-works.html" class="dropdown-link">How It Works</a></li>
                                    <li><a href="${basePath}pages/about.html" class="dropdown-link">About Us</a></li>
                                    <li><a href="${basePath}pages/contact.html" class="dropdown-link">Contact</a></li>
                                    <li><a href="${basePath}pages/faq.html" class="dropdown-link">FAQ</a></li>
                                </ul>
                            </li>
                            <li class="nav-item">
                                <a href="${basePath}pages/sheltercard.html" class="nav-link">ShelterCARD</a>
                            </li>
                            <li class="nav-item">
                                <a href="${basePath}pages/vets.html" class="nav-link">Vets</a>
                            </li>
                            <li class="nav-item">
                                <a href="${basePath}pages/shelters.html" class="nav-link">Shelters</a>
                            </li>
                            <li class="nav-item">
                                <a href="${basePath}pages/businesses.html" class="nav-link">Partners</a>
                            </li>
                            ${this.getAuthSection(basePath)}
                        </ul>
                    </nav>
                    
                    <!-- Mobile Menu Toggle -->
                    <button class="nav-toggle">
                        <span class="hamburger"></span>
                        <span class="hamburger"></span>
                        <span class="hamburger"></span>
                    </button>
                </div>
                
                <!-- Mobile Navigation -->
                <nav class="mobile-nav">
                    <ul class="nav-menu">
                        <li><a href="${basePath}pages/how-it-works.html" class="nav-link">How It Works</a></li>
                        <li><a href="${basePath}pages/about.html" class="nav-link">About Us</a></li>
                        <li><a href="${basePath}pages/contact.html" class="nav-link">Contact</a></li>
                        <li><a href="${basePath}pages/sheltercard.html" class="nav-link">ShelterCARD</a></li>
                        <li><a href="${basePath}pages/vets.html" class="nav-link">Vets</a></li>
                        <li><a href="${basePath}pages/shelters.html" class="nav-link">Shelters</a></li>
                        <li><a href="${basePath}pages/businesses.html" class="nav-link">Partners</a></li>
                        ${this.isAuthenticated 
                            ? '<li><a href="' + basePath + 'pages/dashboard.html" class="nav-link">My Account</a></li>'
                            : '<li><a href="' + basePath + 'pages/login.html" class="nav-link">Sign In</a></li>'
                        }
                    </ul>
                </nav>
            </div>
        `;
    }

    /**
     * Get authentication section
     */
    getAuthSection(basePath) {
        if (this.isAuthenticated) {
            return `
                <li class="nav-item nav-dropdown">
                    <button class="nav-link dropdown-toggle">
                        My Account <span class="dropdown-arrow">▼</span>
                    </button>
                    <ul class="dropdown-menu">
                        <li><a href="${basePath}pages/dashboard.html" class="dropdown-link">Dashboard</a></li>
                        <li><a href="${basePath}pages/my-pets.html" class="dropdown-link">My Pets</a></li>
                        <li><a href="${basePath}pages/profile.html" class="dropdown-link">Profile</a></li>
                        <li><button class="dropdown-link" onclick="logout()">Sign Out</button></li>
                    </ul>
                </li>
            `;
        } else {
            return `
                <li class="nav-item">
                    <a href="${basePath}pages/login.html" class="nav-link btn-secondary">Sign In</a>
                </li>
            `;
        }
    }

    /**
     * Setup mobile menu toggle
     */
    setupMobileMenu() {
        const toggle = document.querySelector('.nav-toggle');
        const mobileNav = document.querySelector('.mobile-nav');
        
        if (toggle && mobileNav) {
            toggle.addEventListener('click', () => {
                toggle.classList.toggle('active');
                mobileNav.classList.toggle('active');
            });
        }
    }

    /**
     * Setup dropdown functionality
     */
    setupDropdowns() {
        const dropdowns = document.querySelectorAll('.nav-dropdown');
        
        dropdowns.forEach(dropdown => {
            const toggle = dropdown.querySelector('.dropdown-toggle');
            const menu = dropdown.querySelector('.dropdown-menu');
            
            if (toggle && menu) {
                toggle.addEventListener('click', (e) => {
                    e.preventDefault();
                    dropdown.classList.toggle('active');
                });
                
                // Close on outside click
                document.addEventListener('click', (e) => {
                    if (!dropdown.contains(e.target)) {
                        dropdown.classList.remove('active');
                    }
                });
            }
        });
    }

    /**
     * Initialize navigation
     */
    init() {
        this.checkAuthState();
        const header = document.querySelector('.header');
        if (header) {
            header.innerHTML = this.getNavigationHTML();
            this.setupMobileMenu();
            this.setupDropdowns();
            this.setupAuthHandlers();
        }
    }

    /**
     * Setup authentication-related handlers
     */
    setupAuthHandlers() {
        // Add global logout function
        window.logout = () => {
            // Clear authentication state
            localStorage.removeItem('userAuthenticated');
            sessionStorage.removeItem('userAuthenticated');
            
            // Clear any auth cookies
            document.cookie = 'auth_token=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
            document.cookie = 'user_session=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
            
            // Redirect to homepage
            window.location.href = this.getBasePath() + 'index.html';
        };
    }
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    new SimpleUnifiedNavigation();
});