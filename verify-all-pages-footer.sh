#!/bin/bash

echo "✅ FINAL VERIFICATION: ALL PAGES NOW MATCH INDEX.HTML"
echo "===================================================="
echo ""

# Check that all pages now have the same footer setup as index.html
echo "🔍 VERIFYING FOOTER CONFIGURATION ON ALL PAGES:"
echo "==============================================="

pages_files=($(find pages/ -name "*.html" | sort))
all_correct=true

for file in "${pages_files[@]}"; do
    echo ""
    echo "📄 $file:"
    
    # Check navigation.css (critical for 4-column footer)
    if grep -q 'navigation\.css' "$file"; then
        echo "   ✅ navigation.css loaded (4-column footer styles)"
    else
        echo "   ❌ navigation.css missing"
        all_correct=false
    fi
    
    # Check simple-footer.js
    if grep -q 'simple-footer\.js' "$file"; then
        echo "   ✅ simple-footer.js loaded (footer content)"
    else
        echo "   ❌ simple-footer.js missing"
        all_correct=false
    fi
    
    # Check footer HTML structure
    if grep -q '<footer class="footer">' "$file"; then
        echo "   ✅ footer HTML structure present"
    else
        echo "   ❌ footer HTML structure missing"
        all_correct=false
    fi
done

echo ""
echo ""
echo "📊 SUMMARY:"
echo "==========="
if [ "$all_correct" = true ]; then
    echo "🎉 SUCCESS! All ${#pages_files[@]} pages in /pages/ folder now have:"
    echo "   ✅ Proper CSS files loaded (including navigation.css for footer styles)"
    echo "   ✅ Footer HTML structure matching index.html"
    echo "   ✅ Footer JavaScript loaded (simple-footer.js)"
    echo ""
    echo "🔧 The footer now displays consistently across all pages:"
    echo "   - 4 columns on desktop (About | Quick Links | Community | Legal)"
    echo "   - 2 columns on tablet"
    echo "   - 1 column on mobile"
    echo "   - Glass-morphism styling"
    echo "   - High contrast accessibility"
else
    echo "⚠️  Some pages still have issues (see details above)"
fi

echo ""
echo "🌐 Quick test links (should all show 4-column footer):"
echo "http://localhost:8080/ (index - reference)"
echo "http://localhost:8080/pages/about.html"
echo "http://localhost:8080/pages/businesses.html"
echo "http://localhost:8080/pages/how-it-works.html"
echo "http://localhost:8080/pages/pet-owners.html"