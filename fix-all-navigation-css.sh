#!/bin/bash

# Fix all pages missing navigation.css by adding it after main.css
echo "🔧 Adding navigation.css to all pages with simple-navigation.css but missing navigation.css..."

pages_fixed=0
pages_checked=0

# Check all HTML files
for file in pages/*.html index.html; do
    if [ -f "$file" ]; then
        pages_checked=$((pages_checked + 1))
        
        # Check if it has simple-navigation.css but NOT navigation.css
        if grep -q 'simple-navigation\.css' "$file" && ! grep -q 'href=".*navigation\.css"' "$file"; then
            echo "📄 Fixing $file..."
            
            # For pages/ files (relative path ../css/)
            if [[ "$file" == pages/* ]]; then
                sed -i 's|<link rel="stylesheet" href="../css/main\.css">|<link rel="stylesheet" href="../css/main.css">\n    <link rel="stylesheet" href="../css/navigation.css">|g' "$file"
            else
                # For index.html (relative path css/)
                sed -i 's|<link rel="stylesheet" href="css/main\.css">|<link rel="stylesheet" href="css/main.css">\n    <link rel="stylesheet" href="css/navigation.css">|g' "$file"
            fi
            
            pages_fixed=$((pages_fixed + 1))
            echo "   ✅ Added navigation.css to $file"
        fi
    fi
done

echo ""
echo "🎉 CSS fix complete!"
echo "   📊 Pages checked: $pages_checked"
echo "   🔧 Pages fixed: $pages_fixed"

echo ""
echo "📋 Final verification - All pages should now have footer styles:"
for file in pages/*.html index.html; do
    if [ -f "$file" ]; then
        if grep -q 'navigation\.css' "$file"; then
            echo "   ✅ $file - Has navigation.css (4-column footer)"
        else
            echo "   ❌ $file - Missing navigation.css (will be vertical)"
        fi
    fi
done

echo ""
echo "🌐 Test the footer layout on these pages:"
echo "   http://localhost:8080/ (homepage)"
echo "   http://localhost:8080/pages/about.html"
echo "   http://localhost:8080/pages/businesses.html"
echo "   http://localhost:8080/pages/how-it-works.html"
echo "   http://localhost:8080/pages/pet-owners.html"