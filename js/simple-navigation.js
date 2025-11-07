/**
 * SIMPLE UNIFIED NAVIGATION
 * Single navigation for all pages - logo and links on same line
 */

class SimpleUnifiedNavigation {
    constructor() {
        this.isAuthenticated = false;
        this.currentPage = this.getCurrentPage();
        // Attempt to correct URLs missing .html or wrong case as early as possible
        this.fixPathIssuesInUrl();
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
     * Check if current user is an admin by checking user_type in user_profiles
     */
    async checkAdminStatus() {
        try {
            console.log('[Admin Check] Starting admin status check...');
            if (!this.isAuthenticated) {
                console.log('[Admin Check] User not authenticated');
                return false;
            }
            
            // Create Supabase client if it doesn't exist
            let client = null;
            
            if (typeof supabaseClient !== 'undefined') {
                client = supabaseClient;
            } else if (typeof supabase !== 'undefined' && typeof SUPABASE_CONFIG !== 'undefined') {
                // Create client using global Supabase library and config
                client = supabase.createClient(SUPABASE_CONFIG.url, SUPABASE_CONFIG.anonKey);
            } else {
                // Fallback: check if we can access window.supabaseClient
                if (window.supabaseClient) {
                    client = window.supabaseClient;
                } else {
                    // No Supabase available, return false
                    console.log('[Admin Check] Supabase not available for admin check');
                    return false;
                }
            }
            
            const { data: { session }, error } = await client.auth.getSession();
            if (error || !session) {
                console.log('[Admin Check] No session found');
                return false;
            }
            
            console.log('[Admin Check] User ID:', session.user.id);
            
            // Check user_type in user_profiles table
            const { data: profile, error: profileError } = await client
                .from('user_profiles')
                .select('user_type')
                .eq('id', session.user.id)
                .maybeSingle();
            
            console.log('[Admin Check] Profile:', profile);
            console.log('[Admin Check] Error:', profileError);
            
            const isAdmin = !profileError && profile && profile.user_type === 'admin';
            console.log('[Admin Check] Is Admin:', isAdmin);
            
            return isAdmin;
        } catch (error) {
            console.error('[Admin Check] Error:', error);
            return false;
        }
    }

    /**
     * Check if user is authenticated
     */
    async checkAuthState() {
        // Check multiple sources for authentication state
        // 1. localStorage flag
        const localStorageAuth = localStorage.getItem('userAuthenticated') === 'true';
        
        // 2. sessionStorage flag  
        const sessionStorageAuth = sessionStorage.getItem('userAuthenticated') === 'true';
        
        // 3. Check if we're on authenticated pages (these should show My Account)
        const authPages = ['dashboard', 'my-pets', 'profile', 'account'];
        const onAuthPage = authPages.includes(this.currentPage);
        
        // 4. Check for authentication cookie or token
        const hasAuthCookie = document.cookie.includes('auth_token') || document.cookie.includes('user_session');
        
        // 5. Try to check Supabase session if available
        let supabaseAuth = false;
        try {
            if (typeof supabase !== 'undefined' && typeof SUPABASE_CONFIG !== 'undefined') {
                const client = supabase.createClient(SUPABASE_CONFIG.url, SUPABASE_CONFIG.anonKey);
                const { data: { session } } = await client.auth.getSession();
                supabaseAuth = session !== null;
            } else if (typeof supabaseClient !== 'undefined') {
                const { data: { session } } = await supabaseClient.auth.getSession();
                supabaseAuth = session !== null;
            } else if (window.supabaseClient) {
                const { data: { session } } = await window.supabaseClient.auth.getSession();
                supabaseAuth = session !== null;
            }
        } catch (error) {
            console.log('Supabase auth check failed:', error.message);
        }
        
        // User is authenticated if any of these conditions are true
        this.isAuthenticated = localStorageAuth || sessionStorageAuth || onAuthPage || hasAuthCookie || supabaseAuth;
        
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
    async getNavigationHTML() {
        const basePath = this.getBasePath();
        
        return `
            <div class="container">
                <div class="header-content">
                    <!-- Logo -->
                    <a href="${basePath}index.html" class="logo">
                        <img src="${basePath}pages/Images/SPlogo-small.png" alt="Shelter Pawtners Logo" class="logo-image">
                        <span class="logo-text">Shelter Pawtners</span>
                    </a>
                    
                    <!-- Desktop Navigation - Same Line -->
                    <nav class="nav desktop-nav">
                        <ul class="nav-menu">
                            <li class="nav-item">
                                <a href="${basePath}pages/profiles.html" class="nav-link">Pet Profiles</a>
                            </li>
                            <li class="nav-item">
                                <a href="${basePath}pages/sheltercard.html" class="nav-link">ShelterCARD</a>
                            </li>
                            <li class="nav-item nav-dropdown">
                                <button class="nav-link dropdown-toggle">
                                    Data Platform <span class="dropdown-arrow">▼</span>
                                </button>
                                <ul class="dropdown-menu">
                                    <li><a href="${basePath}pages/shelters.html" class="dropdown-link">Shelters</a></li>
                                    <li><a href="${basePath}pages/pet-owners.html" class="dropdown-link">Adopters</a></li>
                                    <li><a href="${basePath}pages/vets.html" class="dropdown-link">Vets</a></li>
                                    <li><a href="${basePath}pages/businesses.html" class="dropdown-link">Partners</a></li>
                                    <li><a href="${basePath}pages/partner-offers.html" class="dropdown-link">Partner Offers</a></li>
                                    <li><a href="${basePath}pages/partner-signup.html" class="dropdown-link">🐾 Join Network</a></li>
                                </ul>
                            </li>
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
                            ${await this.getAuthSection(basePath)}
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
                        <li class="nav-item">
                            <a href="${basePath}pages/profiles.html" class="nav-link">Pet Profiles</a>
                        </li>
                        <li class="nav-item">
                            <a href="${basePath}pages/sheltercard.html" class="nav-link">ShelterCARD</a>
                        </li>
                        <li class="nav-item nav-dropdown mobile-dropdown">
                            <button class="nav-link dropdown-toggle">
                                Data Platform <span class="dropdown-arrow">▼</span>
                            </button>
                            <ul class="dropdown-menu mobile-submenu">
                                <li><a href="${basePath}pages/shelters.html" class="dropdown-link">Shelters</a></li>
                                <li><a href="${basePath}pages/pet-owners.html" class="dropdown-link">Adopters</a></li>
                                <li><a href="${basePath}pages/vets.html" class="dropdown-link">Vets</a></li>
                                <li><a href="${basePath}pages/businesses.html" class="dropdown-link">Partners</a></li>
                                <li><a href="${basePath}pages/partner-offers.html" class="dropdown-link">Partner Offers</a></li>
                                <li><a href="${basePath}pages/partner-signup.html" class="dropdown-link">🐾 Join Network</a></li>
                            </ul>
                        </li>
                        <li class="nav-item nav-dropdown mobile-dropdown">
                            <button class="nav-link dropdown-toggle">
                                How It Works <span class="dropdown-arrow">▼</span>
                            </button>
                            <ul class="dropdown-menu mobile-submenu">
                                <li><a href="${basePath}pages/how-it-works.html" class="dropdown-link">How It Works</a></li>
                                <li><a href="${basePath}pages/about.html" class="dropdown-link">About Us</a></li>
                                <li><a href="${basePath}pages/contact.html" class="dropdown-link">Contact</a></li>
                                <li><a href="${basePath}pages/faq.html" class="dropdown-link">FAQ</a></li>
                            </ul>
                        </li>
                        ${await this.getMobileAuthSection(basePath)}
                    </ul>
                </nav>
            </div>
        `;
    }

    /**
     * Get authentication section for desktop
     */
    async getAuthSection(basePath) {
        if (this.isAuthenticated) {
            const isAdmin = await this.checkAdminStatus();
            console.log('[Navigation] Building auth section - isAdmin:', isAdmin);
            const adminButton = isAdmin ? `
                <li class="nav-item">
                    <a href="${basePath}admin/user-management.html" class="nav-link admin-button" style="
                        background: linear-gradient(135deg, #8B5CF6, #06B6D4);
                        color: white;
                        padding: 0.5rem 1rem;
                        border-radius: 8px;
                        font-size: 0.85rem;
                        font-weight: 600;
                        box-shadow: 0 2px 8px rgba(139, 92, 246, 0.3);
                        transition: all 0.3s ease;
                        margin-left: 0.5rem;
                    ">⚡ Admin</a>
                </li>
            ` : '';
            
            console.log('[Navigation] Admin button HTML:', adminButton ? 'Generated' : 'Not generated');
            
            return `
                <li class="nav-item nav-dropdown">
                    <button class="nav-link dropdown-toggle">
                        My Account <span class="dropdown-arrow">▼</span>
                    </button>
                    <ul class="dropdown-menu">
                        <li><a href="${basePath}pages/dashboard.html" class="dropdown-link">Dashboard</a></li>
                        <li><a href="${basePath}pages/my-pets.html" class="dropdown-link">My Pets</a></li>
                        <li><a href="${basePath}pages/account.html" class="dropdown-link">Account</a></li>
                        <li><button class="dropdown-link" onclick="logout()">Sign Out</button></li>
                    </ul>
                </li>
                ${adminButton}
            `;
        } else {
            return `
                <li class="nav-item">
                    <a href="${basePath}pages/login.html" class="nav-link btn-signin">Sign In</a>
                </li>
            `;
        }
    }

    /**
     * Get authentication section for mobile
     */
    async getMobileAuthSection(basePath) {
        if (this.isAuthenticated) {
            const isAdmin = await this.checkAdminStatus();
            const adminLink = isAdmin ? `<li><a href="${basePath}admin/user-management.html" class="dropdown-link" style="color: #8B5CF6; font-weight: 600;">⚡ Admin</a></li>` : '';
            
            return `
                <li class="nav-item nav-dropdown mobile-dropdown">
                    <button class="nav-link dropdown-toggle">
                        My Account <span class="dropdown-arrow">▼</span>
                    </button>
                    <ul class="dropdown-menu mobile-submenu">
                        <li><a href="${basePath}pages/dashboard.html" class="dropdown-link">Dashboard</a></li>
                        <li><a href="${basePath}pages/my-pets.html" class="dropdown-link">My Pets</a></li>
                        <li><a href="${basePath}pages/account.html" class="dropdown-link">Account</a></li>
                        ${adminLink}
                        <li><button class="dropdown-link" onclick="logout()">Sign Out</button></li>
                    </ul>
                </li>
            `;
        } else {
            return `
                <li class="nav-item">
                    <a href="${basePath}pages/login.html" class="nav-link">Sign In</a>
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
     * Setup dropdown functionality for both desktop and mobile
     */
    setupDropdowns() {
        const dropdowns = document.querySelectorAll('.nav-dropdown');
        
        dropdowns.forEach(dropdown => {
            const toggle = dropdown.querySelector('.dropdown-toggle');
            const menu = dropdown.querySelector('.dropdown-menu');
            
            if (toggle && menu) {
                toggle.addEventListener('click', (e) => {
                    e.preventDefault();
                    e.stopPropagation();
                    
                    // Close other dropdowns first
                    dropdowns.forEach(otherDropdown => {
                        if (otherDropdown !== dropdown) {
                            otherDropdown.classList.remove('active');
                        }
                    });
                    
                    // Toggle current dropdown
                    dropdown.classList.toggle('active');
                });
                
                // Prevent menu from closing when clicking inside it
                menu.addEventListener('click', (e) => {
                    e.stopPropagation();
                });
            }
        });
        
        // Close dropdowns on outside click
        document.addEventListener('click', (e) => {
            if (!e.target.closest('.nav-dropdown')) {
                dropdowns.forEach(dropdown => {
                    dropdown.classList.remove('active');
                });
            }
        });
        
        // Close dropdowns when clicking mobile menu links
        const mobileLinks = document.querySelectorAll('.mobile-nav .dropdown-link');
        mobileLinks.forEach(link => {
            link.addEventListener('click', () => {
                // Close the mobile menu after clicking a link
                setTimeout(() => {
                    const mobileNav = document.querySelector('.mobile-nav');
                    const toggle = document.querySelector('.nav-toggle');
                    if (mobileNav && toggle) {
                        mobileNav.classList.remove('active');
                        toggle.classList.remove('active');
                    }
                }, 100);
            });
        });
    }

    /**
     * Initialize navigation
     */
    async init() {
        await this.checkAuthState();
        const header = document.querySelector('.header');
        if (header) {
            header.innerHTML = await this.getNavigationHTML();
            this.setupMobileMenu();
            this.setupDropdowns();
            this.setupAuthHandlers();
            this.setupLinkAutoFix();
            this.registerServiceWorker();
            
            // Mark page as loaded immediately - no delay needed
            document.body.classList.add('loaded');
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

        // Fix profiles page reload issue
        this.setupProfilesPageFix();
    }

    /**
     * If a user lands on /pages/foo (no extension) or /foo, redirect to .html variant
     */
    fixPathIssuesInUrl() {
        try {
            const loc = window.location;
            let path = loc.pathname;

            // Ignore root and assets directories
            const ignoredPrefixes = ['/css', '/js', '/assets', '/images', '/img', '/static'];
            if (path === '/' || ignoredPrefixes.some(p => path.startsWith(p))) return;

            // Normalize trailing slash (e.g., /pages/about/ -> /pages/about)
            if (path.endsWith('/') && path.length > 1) {
                path = path.slice(0, -1);
            }

            const last = path.split('/').pop();
            const hasExtension = last.includes('.');
            const dir = path.slice(0, path.lastIndexOf('/') + 1);
            let file = last;
            let changed = false;
            
            // Ensure .html
            if (!hasExtension && file.length > 0) {
                file = file + '.html';
                changed = true;
            }
            
            // Lowercase filename to match our filesystem
            if (/[A-Z]/.test(file)) {
                file = file.toLowerCase();
                changed = true;
            }

            // Also lowercase directory portion for our routes
            let newDir = dir;
            if (/[A-Z]/.test(dir)) {
                newDir = dir.toLowerCase();
                changed = true;
            }

            // Only apply to likely page routes
            const likelyPage = newDir.startsWith('/pages/') || newDir.startsWith('/admin/') || (newDir.split('/').length === 2);

            if (changed && file.length > 0 && likelyPage) {
                const target = newDir + file + loc.search + loc.hash;
                // Use replace so back button doesn't keep the wrong URL
                loc.replace(target);
            }
        } catch (e) {
            console.warn('Route fix skipped:', e);
        }
    }

    /**
     * Intercept same-origin links without .html and fix them before navigation
     */
    setupLinkAutoFix() {
        const isSameOrigin = (url) => {
            try {
                const u = new URL(url, window.location.origin);
                return u.origin === window.location.origin;
            } catch { return false; }
        };

        const needsFix = (pathname) => {
            if (!pathname) return false;
            if (pathname === '/') return false;
            const ignored = ['/css', '/js', '/assets', '/images', '/img', '/static'];
            if (ignored.some(p => pathname.startsWith(p))) return false;
            // Normalize trailing slash
            if (pathname.endsWith('/') && pathname.length > 1) pathname = pathname.slice(0, -1);
            const last = pathname.split('/').pop();
            const hasDot = last.includes('.');
            const likelyPage = pathname.startsWith('/pages/') || pathname.startsWith('/admin/') || (pathname.split('/').length === 2);
            const hasUpper = /[A-Z]/.test(last) || /[A-Z]/.test(pathname.slice(0, pathname.lastIndexOf('/') + 1));
            return ( (!hasDot && last.length > 0) || hasUpper ) && likelyPage;
        };

        // Update existing anchor hrefs in the DOM
        const anchors = document.querySelectorAll('a[href]');
        anchors.forEach(a => {
            const href = a.getAttribute('href');
            if (!href || href.startsWith('#') || href.startsWith('mailto:') || href.startsWith('tel:')) return;
            const u = new URL(href, window.location.origin);
            if (isSameOrigin(u.href) && needsFix(u.pathname)) {
                // Build fixed path: lowercase dir and file, ensure .html
                let pathname = u.pathname.replace(/\/$/, '');
                const dir = pathname.slice(0, pathname.lastIndexOf('/') + 1).toLowerCase();
                let file = pathname.split('/').pop();
                if (!file.includes('.')) file += '.html';
                file = file.toLowerCase();
                const fixed = dir + file + (u.search || '') + (u.hash || '');
                a.setAttribute('href', fixed);
            }
        });

        // Safety net: capture clicks and fix on the fly
        document.addEventListener('click', (e) => {
            const link = e.target.closest('a[href]');
            if (!link) return;
            const href = link.getAttribute('href');
            if (!href || href.startsWith('#') || href.startsWith('mailto:') || href.startsWith('tel:')) return;
            const u = new URL(href, window.location.origin);
            if (isSameOrigin(u.href) && needsFix(u.pathname)) {
                e.preventDefault();
                let pathname = u.pathname.replace(/\/$/, '');
                const dir = pathname.slice(0, pathname.lastIndexOf('/') + 1).toLowerCase();
                let file = pathname.split('/').pop();
                if (!file.includes('.')) file += '.html';
                file = file.toLowerCase();
                const target = dir + file + (u.search || '') + (u.hash || '');
                window.location.href = target;
            }
        }, true);
    }

    /**
     * Register a service worker to handle direct-typed URLs and provide redirects
     */
    registerServiceWorker() {
        try {
            if ('serviceWorker' in navigator) {
                navigator.serviceWorker.register('/sw.js').catch(err => {
                    console.warn('SW registration failed:', err);
                });
            }
        } catch (e) {
            console.warn('SW not available:', e);
        }
    }

    /**
     * Fix profiles page reloading issue
     */
    setupProfilesPageFix() {
        // Prevent profiles page from reloading when already on profiles page
        const profilesLinks = document.querySelectorAll('a[href*="profiles.html"]');
        profilesLinks.forEach(link => {
            link.addEventListener('click', (e) => {
                const currentPath = window.location.pathname;
                const targetPath = new URL(link.href).pathname;
                
                // If we're already on profiles page and clicking profiles link, prevent reload
                if (currentPath.includes('profiles.html') && targetPath.includes('profiles.html')) {
                    e.preventDefault();
                    console.log('🚫 Prevented profiles page reload - already on profiles page');
                    return false;
                }
            });
        });
    }
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    new SimpleUnifiedNavigation();
});