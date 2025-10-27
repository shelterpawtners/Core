/**
 * SHELTER PAWTNERS - CENTRALIZED NAVIGATION COMPONENT
 * This file contains the unified navigation structure that all pages use
 * Ensures 100% consistency across the entire website
 */

class ShelterPawtnersNavigation {
    constructor() {
        this.isAuthenticated = false;
        this.currentPage = this.getCurrentPage();
        this.init();
    }

    /**
     * Get the current page identifier from the URL
     */
    getCurrentPage() {
        const path = window.location.pathname;
        const page = path.split('/').pop().replace('.html', '') || 'index';
        return page;
    }

    /**
     * Initialize the navigation system
     */
    init() {
        this.checkAuthState();
        const header = document.querySelector('.header');
        if (header) {
            header.innerHTML = this.getNavigationHTML();
            this.attachEventListeners();
            this.setupMobileMenu();
        }
    }

    /**
     * Setup mobile menu toggle functionality
     */
    setupMobileMenu() {
        const navToggle = document.querySelector('.nav-toggle');
        const mobileNav = document.querySelector('.mobile-nav');
        
        if (navToggle && mobileNav) {
            navToggle.addEventListener('click', () => {
                const isActive = navToggle.classList.contains('active');
                
                if (isActive) {
                    navToggle.classList.remove('active');
                    mobileNav.classList.remove('active');
                    navToggle.setAttribute('aria-expanded', 'false');
                } else {
                    navToggle.classList.add('active');
                    mobileNav.classList.add('active');
                    navToggle.setAttribute('aria-expanded', 'true');
                }
            });
        }
    }    /**
     * Check authentication state (placeholder - replace with real auth check)
     */
    checkAuthState() {
        // TODO: Replace with actual authentication check
        // For now, check localStorage or session storage
        this.isAuthenticated = localStorage.getItem('userAuthenticated') === 'true';
        
        // For demo purposes, authenticated pages should show as authenticated
        const authPages = ['dashboard', 'my-pets', 'profile', 'sheltercard'];
        if (authPages.includes(this.currentPage)) {
            this.isAuthenticated = true;
        }
    }

    /**
     * Generate the complete navigation HTML structure
     */
    getNavigationHTML() {
        const basePath = this.getBasePath();
        
        return `
            <div class="container">
                <div class="header-content">
                    <!-- Logo and Navigation on Same Line -->
                    <a href="${basePath}index.html" class="logo">
                        <span class="logo-text">🐾 Shelter Pawtners</span>
                    </a>
                    
                    <!-- Desktop Navigation - Same Line as Logo -->
                    <nav class="nav desktop-nav" aria-label="Main navigation">
                        <ul class="nav-menu" role="menubar">
                            ${this.getHowItWorksDropdown(basePath)}
                            ${this.getShelterCARDLink(basePath)}
                            ${this.getVetsLink(basePath)}
                            ${this.getSheltersLink(basePath)}
                            ${this.getPartnersLink(basePath)}
                            ${this.getAuthSection(basePath)}
                        </ul>
                    </nav>
                    
                    <!-- Mobile Menu Toggle -->
                    <button class="nav-toggle" aria-label="Toggle navigation" aria-expanded="false">
                        <span class="hamburger"></span>
                    </button>
                </div>
                
                <!-- Mobile Navigation - Hidden by Default -->
                <nav id="mobile-navigation" class="nav mobile-nav" aria-label="Mobile navigation">
                    <ul class="nav-menu mobile-menu" role="menubar">
                        ${this.getHowItWorksDropdown(basePath)}
                        ${this.getShelterCARDLink(basePath)}
                        ${this.getVetsLink(basePath)}
                        ${this.getSheltersLink(basePath)}
                        ${this.getPartnersLink(basePath)}
                        ${this.getAuthSection(basePath)}
                    </ul>
                </nav>
            </div>
        `;
    }

    /**
     * Determine the base path for links based on current location
     */
    getBasePath() {
        const path = window.location.pathname;
        if (path.includes('/pages/')) {
            return '../';
        }
        return './';
    }

    /**
     * Generate How It Works dropdown HTML
     */
    getHowItWorksDropdown(basePath) {
        const isActive = ['how-it-works', 'about', 'contact', 'faq'].includes(this.currentPage);
        const activeClass = isActive ? ' active' : '';
        
        return `
            <li class="nav-item has-dropdown${activeClass}" role="none">
                <a href="${basePath}pages/how-it-works.html" class="nav-link" role="menuitem" aria-haspopup="true">How It Works</a>
                <ul class="dropdown-menu" role="menu">
                    <li role="none">
                        <a href="${basePath}pages/how-it-works.html" 
                           class="dropdown-link${this.currentPage === 'how-it-works' ? ' active' : ''}" 
                           role="menuitem"
                           ${this.currentPage === 'how-it-works' ? 'aria-current="page"' : ''}>
                           How It Works
                        </a>
                    </li>
                    <li role="none">
                        <a href="${basePath}pages/about.html" 
                           class="dropdown-link${this.currentPage === 'about' ? ' active' : ''}" 
                           role="menuitem"
                           ${this.currentPage === 'about' ? 'aria-current="page"' : ''}>
                           About Us
                        </a>
                    </li>
                    <li role="none">
                        <a href="${basePath}pages/contact.html" 
                           class="dropdown-link${this.currentPage === 'contact' ? ' active' : ''}" 
                           role="menuitem"
                           ${this.currentPage === 'contact' ? 'aria-current="page"' : ''}>
                           Contact
                        </a>
                    </li>
                    <li role="none">
                        <a href="${basePath}pages/faq.html" 
                           class="dropdown-link${this.currentPage === 'faq' ? ' active' : ''}" 
                           role="menuitem"
                           ${this.currentPage === 'faq' ? 'aria-current="page"' : ''}>
                           FAQ
                        </a>
                    </li>
                </ul>
            </li>
        `;
    }

    /**
     * Generate ShelterCARD link HTML
     */
    getShelterCARDLink(basePath) {
        const activeClass = this.currentPage === 'sheltercard' ? ' active' : '';
        const ariaCurrent = this.currentPage === 'sheltercard' ? ' aria-current="page"' : '';
        
        return `
            <li class="nav-item${activeClass}" role="none">
                <a href="${basePath}pages/sheltercard.html" class="nav-link" role="menuitem"${ariaCurrent}>ShelterCARD</a>
            </li>
        `;
    }

    /**
     * Generate Vets link HTML
     */
    getVetsLink(basePath) {
        const activeClass = this.currentPage === 'vets' ? ' active' : '';
        const ariaCurrent = this.currentPage === 'vets' ? ' aria-current="page"' : '';
        
        return `
            <li class="nav-item${activeClass}" role="none">
                <a href="${basePath}pages/vets.html" class="nav-link" role="menuitem"${ariaCurrent}>Vets</a>
            </li>
        `;
    }

    /**
     * Generate Shelters link HTML
     */
    getSheltersLink(basePath) {
        const activeClass = this.currentPage === 'shelters' ? ' active' : '';
        const ariaCurrent = this.currentPage === 'shelters' ? ' aria-current="page"' : '';
        
        return `
            <li class="nav-item${activeClass}" role="none">
                <a href="${basePath}pages/shelters.html" class="nav-link" role="menuitem"${ariaCurrent}>Shelters</a>
            </li>
        `;
    }

    /**
     * Generate Partners link HTML
     */
    getPartnersLink(basePath) {
        const activeClass = this.currentPage === 'businesses' ? ' active' : '';
        const ariaCurrent = this.currentPage === 'businesses' ? ' aria-current="page"' : '';
        
        return `
            <li class="nav-item${activeClass}" role="none">
                <a href="${basePath}pages/businesses.html" class="nav-link" role="menuitem"${ariaCurrent}>Partners</a>
            </li>
        `;
    }

    /**
     * Generate authentication section (My Account dropdown or Sign In)
     */
    getAuthSection(basePath) {
        if (this.isAuthenticated) {
            return this.getMyAccountDropdown(basePath);
        } else {
            return this.getSignInButton(basePath);
        }
    }

    /**
     * Generate My Account dropdown for authenticated users
     */
    getMyAccountDropdown(basePath) {
        const isAccountPage = ['dashboard', 'my-pets', 'sheltercard', 'profile'].includes(this.currentPage);
        const activeClass = isAccountPage ? ' active' : '';
        
        return `
            <li class="nav-item has-dropdown nav-auth-only${activeClass}" role="none">
                <a href="${basePath}pages/dashboard.html" class="nav-link" role="menuitem" aria-haspopup="true">My Account</a>
                <ul class="dropdown-menu" role="menu">
                    <li role="none">
                        <a href="${basePath}pages/dashboard.html" 
                           class="dropdown-link${this.currentPage === 'dashboard' ? ' active' : ''}" 
                           role="menuitem"
                           ${this.currentPage === 'dashboard' ? 'aria-current="page"' : ''}>
                           Dashboard
                        </a>
                    </li>
                    <li role="none">
                        <a href="${basePath}pages/my-pets.html" 
                           class="dropdown-link${this.currentPage === 'my-pets' ? ' active' : ''}" 
                           role="menuitem"
                           ${this.currentPage === 'my-pets' ? 'aria-current="page"' : ''}>
                           My Pets
                        </a>
                    </li>
                    <li role="none">
                        <a href="${basePath}pages/sheltercard.html" 
                           class="dropdown-link${this.currentPage === 'sheltercard' ? ' active' : ''}" 
                           role="menuitem"
                           ${this.currentPage === 'sheltercard' ? 'aria-current="page"' : ''}>
                           ShelterCARD
                        </a>
                    </li>
                    <li role="none">
                        <a href="${basePath}pages/profile.html" 
                           class="dropdown-link${this.currentPage === 'profile' ? ' active' : ''}" 
                           role="menuitem"
                           ${this.currentPage === 'profile' ? 'aria-current="page"' : ''}>
                           Profile
                        </a>
                    </li>
                    <li role="none">
                        <a href="#" class="dropdown-link" role="menuitem" onclick="ShelterPawtnersNavigation.signOut()">Sign Out</a>
                    </li>
                </ul>
            </li>
        `;
    }

    /**
     * Generate Sign In button for unauthenticated users
     */
    getSignInButton(basePath) {
        return `
            <li class="nav-item nav-public-only" role="none">
                <a href="${basePath}pages/signin.html" class="nav-link nav-cta" role="menuitem">Sign In</a>
            </li>
        `;
    }

    /**
     * Render the navigation into the header element
     */
    renderNavigation() {
        const header = document.querySelector('header.header');
        if (header) {
            header.innerHTML = this.getNavigationHTML();
        }
    }

    /**
     * Attach event listeners for mobile menu and dropdowns
     */
    attachEventListeners() {
        // Mobile menu toggle
        const navToggle = document.querySelector('.nav-toggle');
        const navMenu = document.querySelector('.nav-menu');
        
        if (navToggle && navMenu) {
            navToggle.addEventListener('click', () => {
                const isExpanded = navToggle.getAttribute('aria-expanded') === 'true';
                navToggle.setAttribute('aria-expanded', !isExpanded);
                navMenu.classList.toggle('active');
            });
        }

        // Dropdown behavior for desktop
        const dropdownItems = document.querySelectorAll('.nav-item.has-dropdown');
        dropdownItems.forEach(item => {
            const link = item.querySelector('.nav-link');
            const dropdown = item.querySelector('.dropdown-menu');
            
            if (link && dropdown) {
                // Desktop hover behavior
                item.addEventListener('mouseenter', () => {
                    dropdown.classList.add('active');
                });
                
                item.addEventListener('mouseleave', () => {
                    dropdown.classList.remove('active');
                });

                // Mobile click behavior
                link.addEventListener('click', (e) => {
                    if (window.innerWidth <= 768) {
                        e.preventDefault();
                        dropdown.classList.toggle('active');
                    }
                });
            }
        });
    }

    /**
     * Sign out functionality
     */
    static signOut() {
        localStorage.removeItem('userAuthenticated');
        window.location.href = '/index.html';
    }

    /**
     * Manual authentication toggle for testing
     */
    static toggleAuth() {
        const isAuth = localStorage.getItem('userAuthenticated') === 'true';
        localStorage.setItem('userAuthenticated', !isAuth);
        window.location.reload();
    }
}

// Initialize navigation when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.shelterPawtnersNavigation = new ShelterPawtnersNavigation();
});

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ShelterPawtnersNavigation;
}