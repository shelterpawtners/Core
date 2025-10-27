/**
 * SIMPLE UNIFIED FOOTER
 * Single footer for all pages - consistent compact 4-column layout
 */

class SimpleUnifiedFooter {
    constructor() {
        this.init();
    }

    /**
     * Get base path for links
     */
    getBasePath() {
        const path = window.location.pathname;
        return path.includes('/pages/') ? '../' : '';
    }

    /**
     * Generate footer HTML - Consistent 4-column layout
     */
    getFooterHTML() {
        const basePath = this.getBasePath();
        
        return `
            <div class="footer-container">
                <div class="footer-content">
                    <div class="footer-section">
                        <h3>🐾 About Shelter Pawtners</h3>
                        <p>The digital backbone for post-adoption success, connecting shelter-adopted pets with lifetime support.</p>
                        <div class="footer-social">
                            <a href="#" class="social-link" aria-label="Facebook">📘</a>
                            <a href="#" class="social-link" aria-label="Twitter">🐦</a>
                            <a href="#" class="social-link" aria-label="Instagram">📷</a>
                            <a href="#" class="social-link" aria-label="LinkedIn">💼</a>
                        </div>
                    </div>
                    
                    <div class="footer-section">
                        <h3>🔗 Quick Links</h3>
                        <ul class="footer-links">
                            <li><a href="${basePath}pages/about.html" class="footer-link">About Us</a></li>
                            <li><a href="${basePath}pages/how-it-works.html" class="footer-link">How It Works</a></li>
                            <li><a href="${basePath}pages/contact.html" class="footer-link">Contact</a></li>
                            <li><a href="${basePath}pages/faq.html" class="footer-link">FAQ</a></li>
                        </ul>
                    </div>
                    
                    <div class="footer-section">
                        <h3>👥 Community</h3>
                        <ul class="footer-links">
                            <li><a href="${basePath}pages/pet-owners.html" class="footer-link">Pet Parents</a></li>
                            <li><a href="${basePath}pages/businesses.html" class="footer-link">Businesses</a></li>
                            <li><a href="${basePath}pages/shelters.html" class="footer-link">Shelters</a></li>
                            <li><a href="${basePath}pages/vets.html" class="footer-link">Veterinarians</a></li>
                        </ul>
                    </div>
                    
                    <div class="footer-section">
                        <h3>📄 Legal & Support</h3>
                        <ul class="footer-links">
                            <li><a href="${basePath}pages/privacy.html" class="footer-link">Privacy Policy</a></li>
                            <li><a href="${basePath}pages/terms.html" class="footer-link">Terms of Service</a></li>
                            <li><a href="${basePath}pages/contact.html" class="footer-link">Support</a></li>
                            <li><a href="${basePath}pages/sheltercard.html" class="footer-link">ShelterCARD</a></li>
                        </ul>
                    </div>
                </div>
                
                <div class="footer-bottom">
                    <div class="footer-bottom-content">
                        <p>&copy; 2025 Shelter Pawtners. All rights reserved.</p>
                        <ul class="footer-legal">
                            <li><a href="${basePath}pages/privacy.html" class="footer-link">Privacy</a></li>
                            <li><a href="${basePath}pages/terms.html" class="footer-link">Terms</a></li>
                        </ul>
                    </div>
                </div>
            </div>
        `;
    }

    /**
     * Initialize footer
     */
    init() {
        const footer = document.querySelector('.footer');
        if (footer) {
            footer.innerHTML = this.getFooterHTML();
        }
    }
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    new SimpleUnifiedFooter();
});