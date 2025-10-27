#!/bin/bash

# Check and Fix Footer Scripts - Ensure all pages reference simple-footer.js
echo "🔍 Checking all pages for unified footer script..."

# Array of files to check
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

# Counters
total_files=0
missing_script=0
fixed_files=0

# Function to check and fix footer script in a file
check_and_fix_footer() {
    local file="$1"
    if [ -f "$file" ]; then
        total_files=$((total_files + 1))
        
        # Check if file has the footer script
        if ! grep -q "simple-footer.js" "$file"; then
            echo "❌ Missing footer script: $file"
            missing_script=$((missing_script + 1))
            
            # Determine correct path based on file location
            if [[ $file == pages/* ]] || [[ $file == admin/* ]]; then
                script_path="../js/simple-footer.js"
            else
                script_path="js/simple-footer.js"
            fi
            
            # Add footer script before closing </body> tag
            if grep -q "</body>" "$file"; then
                # Create backup
                cp "$file" "$file.backup"
                
                # Add footer script
                sed -i "s|</body>|    <!-- SIMPLE UNIFIED FOOTER - Consistent footer for all pages -->\n    <script src=\"$script_path\"></script>\n</body>|" "$file"
                
                echo "✅ Added footer script to: $file"
                fixed_files=$((fixed_files + 1))
            else
                echo "⚠️  No </body> tag found in: $file"
            fi
        else
            echo "✅ Footer script found: $file"
        fi
    else
        echo "⚠️  File not found: $file"
    fi
}

# Check all files
for file in "${FILES[@]}"; do
    check_and_fix_footer "$file"
done

echo ""
echo "📊 Footer Script Check Summary:"
echo "   📁 Total files checked: $total_files"
echo "   ❌ Files missing footer script: $missing_script"
echo "   ✅ Files fixed: $fixed_files"
echo ""

if [ $missing_script -eq 0 ]; then
    echo "🎉 All pages have unified footer script!"
else
    echo "🔄 Fixed $fixed_files files with missing footer scripts"
fi

echo ""
echo "🧪 Test unified footer system:"
echo "   • http://localhost:8080/index.html"
echo "   • http://localhost:8080/pages/about.html"  
echo "   • http://localhost:8080/pages/sheltercard.html"
echo "   • All should have identical 4-column footer"