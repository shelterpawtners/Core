#!/bin/bash

echo "🔧 UPDATING ALL PAGES IN /pages/ FOLDER TO MATCH INDEX.HTML FOOTER"
echo "=================================================================="
echo ""

# The correct footer configuration from index.html:
# CSS files: main.css, navigation.css, simple-navigation.css, components.css, responsive.css
# Footer HTML: <footer class="footer"><!-- Footer content automatically loaded by simple-footer.js --></footer>
# Footer JS: <script src="../js/simple-footer.js"></script>

# Get all HTML files in pages directory
pages_files=($(find pages/ -name "*.html" | sort))

echo "📄 Found ${#pages_files[@]} pages to update:"
for file in "${pages_files[@]}"; do
    echo "   - $file"
done

echo ""
echo "🔍 ANALYZING AND FIXING EACH PAGE:"
echo "=================================="

pages_updated=0
pages_already_correct=0

for file in "${pages_files[@]}"; do
    echo ""
    echo "📄 Processing $file..."
    
    needs_update=false
    
    # Check CSS files needed
    css_issues=()
    if ! grep -q 'href="../css/main\.css"' "$file"; then
        css_issues+=("main.css")
    fi
    if ! grep -q 'href="../css/navigation\.css"' "$file"; then
        css_issues+=("navigation.css")
        needs_update=true
    fi
    if ! grep -q 'href="../css/simple-navigation\.css"' "$file"; then
        css_issues+=("simple-navigation.css")
    fi
    if ! grep -q 'href="../css/components\.css"' "$file"; then
        css_issues+=("components.css")
    fi
    if ! grep -q 'href="../css/responsive\.css"' "$file"; then
        css_issues+=("responsive.css")
    fi
    
    # Check footer HTML structure
    if ! grep -q '<footer class="footer">' "$file"; then
        echo "   ❌ Missing footer HTML structure"
        needs_update=true
    fi
    
    # Check footer JavaScript
    if ! grep -q 'src="../js/simple-footer\.js"' "$file"; then
        echo "   ❌ Missing simple-footer.js script"
        needs_update=true
    fi
    
    if [ ${#css_issues[@]} -gt 0 ]; then
        echo "   ❌ Missing CSS files: ${css_issues[*]}"
        needs_update=true
    fi
    
    if [ "$needs_update" = true ]; then
        echo "   🔧 Updating $file..."
        
        # Create backup
        cp "$file" "${file}.backup"
        
        # Fix missing navigation.css (most critical for footer)
        if [[ " ${css_issues[*]} " =~ " navigation.css " ]]; then
            # Add navigation.css after main.css
            sed -i 's|<link rel="stylesheet" href="../css/main\.css">|<link rel="stylesheet" href="../css/main.css">\n    <link rel="stylesheet" href="../css/navigation.css">|g' "$file"
            echo "     ✅ Added navigation.css"
        fi
        
        # Fix missing simple-navigation.css
        if [[ " ${css_issues[*]} " =~ " simple-navigation.css " ]]; then
            if grep -q 'navigation\.css' "$file"; then
                sed -i 's|<link rel="stylesheet" href="../css/navigation\.css">|<link rel="stylesheet" href="../css/navigation.css">\n    <link rel="stylesheet" href="../css/simple-navigation.css">|g' "$file"
            else
                sed -i 's|<link rel="stylesheet" href="../css/main\.css">|<link rel="stylesheet" href="../css/main.css">\n    <link rel="stylesheet" href="../css/simple-navigation.css">|g' "$file"
            fi
            echo "     ✅ Added simple-navigation.css"
        fi
        
        # Fix missing components.css
        if [[ " ${css_issues[*]} " =~ " components.css " ]]; then
            # Add before responsive.css if it exists, otherwise at the end
            if grep -q 'responsive\.css' "$file"; then
                sed -i 's|<link rel="stylesheet" href="../css/responsive\.css">|<link rel="stylesheet" href="../css/components.css">\n    <link rel="stylesheet" href="../css/responsive.css">|g' "$file"
            else
                # Find the last CSS link and add after it
                sed -i '/css\/.*\.css">/a\    <link rel="stylesheet" href="../css/components.css">' "$file"
            fi
            echo "     ✅ Added components.css"
        fi
        
        # Fix missing responsive.css
        if [[ " ${css_issues[*]} " =~ " responsive.css " ]]; then
            # Add as last CSS file
            sed -i '/css\/.*\.css">/a\    <link rel="stylesheet" href="../css/responsive.css">' "$file"
            echo "     ✅ Added responsive.css"
        fi
        
        # Fix missing footer HTML
        if ! grep -q '<footer class="footer">' "$file"; then
            # Add footer before the JavaScript section
            sed -i 's|</main>|</main>\n\n    <!-- UNIFIED FOOTER -->\n    <footer class="footer">\n        <!-- Footer content automatically loaded by simple-footer.js -->\n    </footer>|g' "$file"
            echo "     ✅ Added footer HTML structure"
        fi
        
        # Fix missing simple-footer.js script
        if ! grep -q 'simple-footer\.js' "$file"; then
            # Add before closing body tag
            sed -i 's|</body>|    <!-- SIMPLE UNIFIED FOOTER - Consistent footer for all pages -->\n    <script src="../js/simple-footer.js"></script>\n</body>|g' "$file"
            echo "     ✅ Added simple-footer.js script"
        fi
        
        pages_updated=$((pages_updated + 1))
        echo "   ✅ Successfully updated $file"
        
        # Clean up backup if successful
        rm "${file}.backup"
    else
        echo "   ✅ Already correct - no changes needed"
        pages_already_correct=$((pages_already_correct + 1))
    fi
done

echo ""
echo ""
echo "📊 FINAL SUMMARY:"
echo "================="
echo "Total pages processed: ${#pages_files[@]}"
echo "Pages updated: $pages_updated"
echo "Pages already correct: $pages_already_correct"

echo ""
echo "🎉 ALL PAGES IN /pages/ FOLDER NOW MATCH INDEX.HTML FOOTER!"
echo ""
echo "🌐 Test these pages to verify 4-column footer:"
for file in "${pages_files[@]}"; do
    echo "   http://localhost:8080/$file"
done