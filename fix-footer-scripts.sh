#!/bin/bash

# Fix missing simple-footer.js script tags on all pages
# This ensures all pages load the unified footer system

echo "🔧 Adding missing simple-footer.js script tags..."

# Pages that need the script tag added
pages_to_fix=(
    "pages/about.html"
    "pages/businesses.html" 
    "pages/contact.html"
    "pages/create-pet.html"
    "pages/dashboard.html"
    "pages/faq.html"
    "pages/how-it-works.html"
    "pages/login.html"
    "pages/my-pets.html"
    "pages/owners.html"
    "pages/pet-owners.html"
    "pages/privacy.html"
    "pages/profiles.html"
    "pages/register.html"
    "pages/services.html"
    "pages/shelters.html"
    "pages/terms.html"
    "pages/vets.html"
)

# Add the script tag before closing body tag on each page
for page in "${pages_to_fix[@]}"; do
    if [ -f "$page" ]; then
        echo "📄 Updating $page..."
        
        # Check if script tag already exists (actual tag, not comment)
        if ! grep -q '<script.*simple-footer.js' "$page"; then
            # Add the script tag before </body>
            sed -i 's|</body>|    <!-- SIMPLE UNIFIED FOOTER - Consistent footer for all pages -->\n    <script src="../js/simple-footer.js"></script>\n</body>|g' "$page"
            echo "   ✅ Added simple-footer.js script tag to $page"
        else
            echo "   🔄 Script tag already exists in $page"
        fi
    else
        echo "   ❌ File not found: $page"
    fi
done

echo ""
echo "🎉 Footer script fix complete!"
echo ""
echo "📋 Verification: Pages with simple-footer.js script tags:"
grep -l '<script.*simple-footer.js' pages/*.html index.html | sort