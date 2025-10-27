#!/bin/bash

# Script to update navigation on ALL pages
# This replaces old navigation with simple-navigation system

echo "🔄 Updating navigation on ALL pages..."

# List of pages to update
pages=(
    "pages/contact.html"
    "pages/sheltercard.html" 
    "pages/dashboard.html"
    "pages/my-pets.html"
    "pages/businesses.html"
    "pages/pet-owners.html"
    "pages/vets.html"
    "pages/shelters.html"
    "pages/privacy.html"
    "pages/terms.html"
    "pages/login.html"
    "pages/register.html"
)

for page in "${pages[@]}"; do
    if [ -f "$page" ]; then
        echo "✅ Updating $page..."
        
        # Update CSS - replace navigation.css with simple-navigation.css
        sed -i 's|css/navigation.css|css/simple-navigation.css|g' "$page"
        sed -i 's|../css/navigation.css|../css/simple-navigation.css|g' "$page"
        
        # Update JavaScript - replace navigation.js with simple-navigation.js
        sed -i 's|js/navigation.js|js/simple-navigation.js|g' "$page"
        sed -i 's|../js/navigation.js|../js/simple-navigation.js|g' "$page"
        
        echo "   📝 Updated CSS and JS references"
    else
        echo "⚠️  $page not found, skipping..."
    fi
done

echo "🎉 Navigation update complete!"
echo ""
echo "📋 Manual header replacement still needed for pages with complex navigation"
echo "🔗 All pages now use: css/simple-navigation.css and js/simple-navigation.js"