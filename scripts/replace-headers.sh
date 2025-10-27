#!/bin/bash

# Script to replace complex navigation headers with clean template

echo "🔄 Updating headers with manual navigation HTML..."

# List of files that need header replacement based on check results
files=(
    "index.html"
    "pages/login.html"
    "pages/terms.html"
    "pages/shelters.html"
    "pages/sheltercard.html"
    "pages/pet-owners.html"
    "pages/my-pets.html"
    "pages/privacy.html"
    "pages/vets.html"
    "pages/register.html"
    "pages/dashboard.html"
    "pages/businesses.html"
    "pages/profile.html"
)

# Clean header template to insert
clean_header='    <!-- CLEAN NAVIGATION - Same on ALL pages -->
    <header class="header">
        <!-- Navigation automatically loaded by simple-navigation.js -->
    </header>'

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ Processing $file..."
        
        # Create a temporary file to work with
        temp_file=$(mktemp)
        
        # Flag to track if we're inside a header section
        inside_header=false
        header_start_line=""
        
        # Read the file line by line
        while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ "$line" =~ "<header" ]]; then
                inside_header=true
                header_start_line="$line"
                continue
            elif [[ "$line" =~ "</header>" ]] && [ "$inside_header" = true ]; then
                # End of header found, insert clean header
                echo "$clean_header" >> "$temp_file"
                inside_header=false
                continue
            elif [ "$inside_header" = false ]; then
                # We're outside header, keep the line
                echo "$line" >> "$temp_file"
            fi
            # If inside_header=true, we skip the line (don't write it)
        done < "$file"
        
        # Replace original file with temp file
        mv "$temp_file" "$file"
        
        echo "   📝 Updated header in $file"
    else
        echo "⚠️  $file not found, skipping..."
    fi
done

echo ""
echo "🎉 Header replacement complete!"
echo "📋 All pages should now use the clean header template"