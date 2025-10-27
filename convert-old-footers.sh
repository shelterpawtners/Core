#!/bin/bash

# Fix pages that still have old footer HTML instead of unified footer structure
echo "🔧 Converting remaining old footers to unified footer system..."

# List of pages that need footer structure fixes
pages_with_old_footers=(
    "pages/partner-offers.html"
    "pages/pet-details.html"
)

for page in "${pages_with_old_footers[@]}"; do
    if [ -f "$page" ]; then
        echo "📄 Converting $page..."
        
        # Create a backup
        cp "$page" "${page}.backup"
        
        # Remove the old footer content between <footer class="footer"> and </footer>
        # and replace with unified footer structure
        awk '
        /<footer class="footer">/ {
            print $0
            print "        <!-- Footer content automatically loaded by simple-footer.js -->"
            # Skip all lines until we find </footer>
            while (getline > 0 && $0 !~ /<\/footer>/) {
                # Skip these lines
            }
            print "    </footer>"
            next
        }
        { print }
        ' "${page}.backup" > "$page"
        
        echo "   ✅ Converted $page footer to unified system"
        
        # Also ensure it has the script tag
        if ! grep -q '<script.*simple-footer.js' "$page"; then
            sed -i 's|</body>|    <!-- SIMPLE UNIFIED FOOTER - Consistent footer for all pages -->\n    <script src="../js/simple-footer.js"></script>\n</body>|g' "$page"
            echo "   ✅ Added simple-footer.js script tag to $page"
        fi
        
        rm "${page}.backup"
    else
        echo "   ❌ File not found: $page"
    fi
done

echo ""
echo "🎉 Footer conversion complete!"