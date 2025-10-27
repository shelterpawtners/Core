#!/bin/bash

# Update Footer System - Replace all footer HTML with unified system
echo "🔄 Updating all pages to use unified footer system..."

# Define the new footer template (just the footer tag, content loaded by JS)
NEW_FOOTER='    <!-- UNIFIED FOOTER -->
    <footer class="footer">
        <!-- Footer content automatically loaded by simple-footer.js -->
    </footer>'

# Array of files to update
FILES=(
    "index.html"
    "pages/about.html"
    "pages/businesses.html"
    "pages/contact.html"
    "pages/how-it-works.html"
    "pages/pet-owners.html"
    "pages/privacy.html"
    "pages/terms.html"
    "pages/sheltercard.html"
    "pages/vets.html"
    "pages/shelters.html"
    "pages/faq.html"
    "pages/dashboard.html"
    "pages/my-pets.html"
    "pages/profile.html"
    "pages/create-pet.html"
    "pages/login.html"
    "pages/register.html"
    "pages/eligibility-check.html"
    "pages/profiles.html"
    "admin/eligibility-applications.html"
)

# Function to update footer in a file
update_footer() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "📝 Updating footer in: $file"
        
        # Create a temporary file
        temp_file=$(mktemp)
        
        # Process the file line by line
        in_footer=false
        while IFS= read -r line; do
            if [[ $line =~ \<footer.*class=\"footer\" ]]; then
                # Start of footer - replace with new footer
                echo "$NEW_FOOTER" >> "$temp_file"
                in_footer=true
            elif [[ $line =~ \</footer\> ]] && [ "$in_footer" = true ]; then
                # End of footer - already included in NEW_FOOTER, skip this line
                in_footer=false
            elif [ "$in_footer" = false ]; then
                # Not in footer section, keep the line
                echo "$line" >> "$temp_file"
            fi
            # If in_footer is true, we skip the line (removing old footer content)
        done < "$file"
        
        # Replace original file with updated content
        mv "$temp_file" "$file"
        
        # Add footer script if not already present
        if ! grep -q "simple-footer.js" "$file"; then
            echo "📜 Adding footer script to: $file"
            # Insert before closing </body> tag
            sed -i 's|</body>|    <script src="js/simple-footer.js"></script>\n</body>|' "$file"
            
            # Fix path for pages in subdirectory
            if [[ $file == pages/* ]]; then
                sed -i 's|src="js/simple-footer.js"|src="../js/simple-footer.js"|' "$file"
            fi
        fi
        
        echo "✅ Updated: $file"
    else
        echo "⚠️  File not found: $file"
    fi
}

# Update all files
for file in "${FILES[@]}"; do
    update_footer "$file"
done

echo ""
echo "🎉 Footer unification complete!"
echo ""
echo "📋 Summary:"
echo "✅ All pages now use unified footer system"
echo "✅ Footer content managed in js/simple-footer.js"
echo "✅ Consistent 4-column compact layout"
echo "✅ Easy to update - edit once, applies everywhere"
echo ""
echo "🧪 Test the unified footer:"
echo "   • Check index.html"
echo "   • Check pages/sheltercard.html" 
echo "   • Check pages/about.html"
echo "   • All should have identical footer layout"