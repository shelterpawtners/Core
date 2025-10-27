#!/bin/bash

# Find and fix pages with old footer content instead of unified system
echo "🔍 Searching for pages with old footer content..."

# Search for old footer patterns
echo ""
echo "📋 Checking for old footer patterns:"

# Find files with old footer content
OLD_FOOTER_FILES=()

# Check for "Solutions" section (old footer pattern)
echo "   🔸 Checking for 'Solutions' sections..."
for file in index.html pages/*.html admin/*.html; do
    if [ -f "$file" ] && grep -q "Solutions" "$file"; then
        echo "   ❌ Found 'Solutions' in: $file"
        OLD_FOOTER_FILES+=("$file")
    fi
done

# Check for "Audiences" section (old footer pattern)
echo "   🔸 Checking for 'Audiences' sections..."
for file in index.html pages/*.html admin/*.html; do
    if [ -f "$file" ] && grep -q "Audiences" "$file"; then
        echo "   ❌ Found 'Audiences' in: $file"
        OLD_FOOTER_FILES+=("$file")
    fi
done

# Check for "Organization" section (old footer pattern)
echo "   🔸 Checking for 'Organization' sections..."
for file in index.html pages/*.html admin/*.html; do
    if [ -f "$file" ] && grep -q "Organization" "$file"; then
        echo "   ❌ Found 'Organization' in: $file"
        OLD_FOOTER_FILES+=("$file")
    fi
done

# Remove duplicates
OLD_FOOTER_FILES=($(printf "%s\n" "${OLD_FOOTER_FILES[@]}" | sort -u))

echo ""
if [ ${#OLD_FOOTER_FILES[@]} -eq 0 ]; then
    echo "✅ No old footer content found!"
else
    echo "⚠️  Found ${#OLD_FOOTER_FILES[@]} files with old footer content:"
    for file in "${OLD_FOOTER_FILES[@]}"; do
        echo "   📄 $file"
    done
    
    echo ""
    echo "🔧 Fixing files with old footer content..."
    
    for file in "${OLD_FOOTER_FILES[@]}"; do
        echo "📝 Processing: $file"
        
        # Create backup
        cp "$file" "$file.backup-$(date +%s)"
        
        # Replace old footer content with unified footer
        # Create temporary file
        temp_file=$(mktemp)
        
        # Process the file - remove everything between <footer> and </footer> and replace with unified footer
        in_footer=false
        while IFS= read -r line; do
            if [[ $line =~ \<footer.*class=\"footer\" ]]; then
                # Start of footer - replace with unified footer
                echo "    <!-- UNIFIED FOOTER -->" >> "$temp_file"
                echo "    <footer class=\"footer\">" >> "$temp_file"
                echo "        <!-- Footer content automatically loaded by simple-footer.js -->" >> "$temp_file"
                echo "    </footer>" >> "$temp_file"
                in_footer=true
            elif [[ $line =~ \</footer\> ]] && [ "$in_footer" = true ]; then
                # End of footer - already added unified footer above
                in_footer=false
            elif [ "$in_footer" = false ]; then
                # Not in footer section, keep the line
                echo "$line" >> "$temp_file"
            fi
            # If in_footer is true, we skip the line (removing old footer content)
        done < "$file"
        
        # Replace original with processed file
        mv "$temp_file" "$file"
        
        # Ensure footer script is present
        if [[ $file == pages/* ]] || [[ $file == admin/* ]]; then
            script_path="../js/simple-footer.js"
        else
            script_path="js/simple-footer.js"
        fi
        
        if ! grep -q "simple-footer.js" "$file"; then
            echo "   📜 Adding footer script to: $file"
            sed -i "s|</body>|    <!-- SIMPLE UNIFIED FOOTER - Consistent footer for all pages -->\n    <script src=\"$script_path\"></script>\n</body>|" "$file"
        fi
        
        echo "   ✅ Fixed: $file"
    done
fi

echo ""
echo "🎉 Footer cleanup complete!"
echo ""
echo "🧪 Test these pages to verify unified footer:"
echo "   • http://localhost:8080/index.html"
echo "   • http://localhost:8080/pages/sheltercard.html"
echo "   • http://localhost:8080/pages/about.html"
echo ""
echo "Expected footer sections:"
echo "   1. 🐾 About Shelter Pawtners"
echo "   2. 🔗 Quick Links" 
echo "   3. 👥 Community"
echo "   4. 📄 Legal & Support"