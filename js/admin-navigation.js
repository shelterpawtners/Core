// Admin Navigation JavaScript for Shelter Pawtners
// Populates navigation menus for admin pages

document.addEventListener('DOMContentLoaded', function() {
    populateAdminNavigation();
    setupMobileMenu();
});

function populateAdminNavigation() {
    // Ensure header content uses the same max-width container as public header
    const headerContent = document.querySelector('.header .header-content');
    if (headerContent && !headerContent.classList.contains('container')) {
        headerContent.classList.add('container');
    }

    // Navigation items for admin pages (keep unique admin links)
    const navItems = [
        { href: '../index.html', text: 'Home', title: 'Back to main site' },
        { href: 'eligibility-applications.html', text: 'Applications', title: 'Eligibility Applications' },
        { href: 'partner-management.html', text: 'Partners', title: 'Partner Management' },
        { href: 'user-management.html', text: 'Users', title: 'User Management' }
    ];

    // Populate desktop navigation to match simple-navigation structure/classes
    const desktopNav = document.querySelector('.desktop-nav');
    if (desktopNav) {
        // Ensure same base class used by public nav for styling
        desktopNav.classList.add('nav');

        const navHTML = `
            <ul class="nav-menu">
                ${navItems.map(item => `
                    <li class="nav-item"><a href="${item.href}" title="${item.title}" class="nav-link">${item.text}</a></li>
                `).join('')}
                <li class="nav-item"><a href="#" class="nav-link" onclick="handleLogout()">Sign Out</a></li>
            </ul>
        `;
        desktopNav.innerHTML = navHTML;
    }

    // Populate mobile navigation to match simple-navigation structure/classes
    const mobileNav = document.querySelector('.mobile-nav');
    if (mobileNav) {
        // Ensure same base class used by public mobile nav for styling
        mobileNav.classList.add('nav');

        const navHTML = `
            <ul class="nav-menu">
                ${navItems.map(item => `
                    <li class="nav-item"><a href="${item.href}" title="${item.title}" class="nav-link">${item.text}</a></li>
                `).join('')}
                <li class="nav-item"><a href="#" class="nav-link" onclick="handleLogout()">Sign Out</a></li>
            </ul>
        `;
        mobileNav.innerHTML = navHTML;
    }
}

    // Handle logout
    function handleLogout() {
        // Clear authentication state
        localStorage.removeItem('userAuthenticated');
        sessionStorage.removeItem('userAuthenticated');
        localStorage.removeItem('shelterpawtner_user');
    
        // Clear any auth cookies
        document.cookie = 'auth_token=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
        document.cookie = 'user_session=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
    
        // Sign out from Supabase if available
        if (typeof supabaseClient !== 'undefined' && supabaseClient.auth) {
            supabaseClient.auth.signOut().then(() => {
                window.location.href = '../index.html';
            }).catch(() => {
                window.location.href = '../index.html';
            });
        } else {
            window.location.href = '../index.html';
        }
    }

function setupMobileMenu() {
    const navToggle = document.querySelector('.nav-toggle');
    const mobileNav = document.querySelector('.mobile-nav');
    
    if (navToggle && mobileNav) {
        navToggle.addEventListener('click', function() {
            const isExpanded = navToggle.getAttribute('aria-expanded') === 'true';
            navToggle.setAttribute('aria-expanded', String(!isExpanded));
            // Match public nav behavior
            navToggle.classList.toggle('active');
            mobileNav.classList.toggle('active');
        });

        // Close mobile menu when clicking outside
        document.addEventListener('click', function(event) {
            if (!navToggle.contains(event.target) && !mobileNav.contains(event.target)) {
                if (mobileNav.classList.contains('active')) {
                    navToggle.click();
                }
            }
        });

        // Close mobile menu when clicking on a link
        const mobileLinks = mobileNav.querySelectorAll('a');
        mobileLinks.forEach(link => {
            link.addEventListener('click', function() {
                if (mobileNav.classList.contains('active')) {
                    navToggle.click();
                }
            });
        });
    }
}

// Add smooth scrolling for anchor links
document.addEventListener('click', function(e) {
    const link = e.target.closest('a[href^="#"]');
    if (link) {
        e.preventDefault();
        const targetId = link.getAttribute('href');
        const targetElement = document.querySelector(targetId);
        
        if (targetElement) {
            targetElement.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    }
});

// Add active state to current page link
function highlightCurrentPage() {
    const currentPath = window.location.pathname;
    const navLinks = document.querySelectorAll('.desktop-nav a, .mobile-nav a');
    
    navLinks.forEach(link => {
        const linkPath = new URL(link.href).pathname;
        if (linkPath === currentPath) {
            link.classList.add('active');
        }
    });
}

// Initialize highlighting when DOM is loaded
document.addEventListener('DOMContentLoaded', highlightCurrentPage);