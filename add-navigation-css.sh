#!/bin/bash

# Fix missing navigation.css links that contain footer styles
echo "🔧 Adding navigation.css to pages that only have simple-navigation.css..."

# Find pages that have simple-navigation.css but NOT navigation.css
pages_to_fix=()

for file in pages/*.html index.html; do
    if [ -f "$file" ]; then
        # Check if it has simple-navigation.css but NOT navigation.css
        if grep -q 'simple-navigation\.css' "$file" && ! grep -q '".*navigation\.css"' "$file"; then
            pages_to_fix+=("$file")
        fi
    fi
done

echo "Pages needing navigation.css added: ${#pages_to_fix[@]}"

for page in "${pages_to_fix[@]}"; do
    echo "📄 Updating $page..."
    
    # Add navigation.css after main.css
    sed -i 's|<link rel="stylesheet" href="\.\./css/main\.css">|<link rel="stylesheet" href="../css/main.css">\n    <link rel="stylesheet" href="../css/navigation.css">|g' "$page"
    
    # For index.html (different path)
    sed -i 's|<link rel="stylesheet" href="css/main\.css">|<link rel="stylesheet" href="css/main.css">\n    <link rel="stylesheet" href="css/navigation.css">|g' "$page"
    
    echo "   ✅ Added navigation.css to $page"
done

echo ""
echo "🎉 CSS fix complete!"
echo ""
echo "📋 Verification - Pages now with both CSS files:"
for file in pages/*.html index.html; do
    if [ -f "$file" ]; then
        if grep -q 'navigation\.css' "$file" && grep -q 'simple-navigation\.css' "$file"; then
            echo "   ✅ $file"
        elif grep -q 'navigation\.css' "$file"; then
            echo "   🔵 $file (navigation.css only)"
        else
            echo "   ❌ $file (missing navigation.css)"
        fi
    fi
done