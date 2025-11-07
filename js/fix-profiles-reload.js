/**
 * DEBUG: Profiles Page Reload Investigation
 * This file helps identify why the profiles page reloads unexpectedly
 */

// Check for multiple event listeners
console.log('=== PROFILES PAGE DEBUG ===');
console.log('Current page:', window.location.pathname);
console.log('DOM loaded:', document.readyState);

// Monitor navigation events
window.addEventListener('beforeunload', (e) => {
    console.log('Page is about to unload from profiles.html');
    console.trace('Unload stack trace');
});

// Check for duplicate navigation initialization
let navInitCount = 0;
const originalNavInit = window.SimpleUnifiedNavigation;

// Monitor for multiple script loads
document.addEventListener('DOMContentLoaded', () => {
    console.log('DOMContentLoaded fired on profiles page');
    
    // Check for script duplication
    const scripts = document.querySelectorAll('script[src*="simple-navigation.js"]');
    if (scripts.length > 1) {
        console.warn('⚠️ Multiple simple-navigation.js scripts detected:', scripts.length);
    }
    
    // Check for event listener conflicts  
    const profilesLinks = document.querySelectorAll('a[href*="profiles.html"]');
    console.log('Found profiles links:', profilesLinks.length);
    
    profilesLinks.forEach((link, index) => {
        link.addEventListener('click', (e) => {
            console.log(`Profiles link ${index} clicked:`, e.target.href);
        });
    });
});

// Export for debugging
window.debugProfiles = {
    checkScripts: () => {
        const scripts = Array.from(document.querySelectorAll('script'));
        console.log('All scripts:', scripts.map(s => s.src || s.textContent.substring(0, 50)));
    },
    checkEventListeners: () => {
        console.log('Event listeners on window:', getEventListeners ? getEventListeners(window) : 'getEventListeners not available');
    }
};