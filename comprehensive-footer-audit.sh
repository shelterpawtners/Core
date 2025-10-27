#!/bin/bash

echo "🔍 COMPREHENSIVE SITE-WIDE FOOTER AUDIT"
echo "======================================="
echo ""

# Find all HTML files
html_files=$(find . -name "*.html" -not -path "./.*" | sort)
total_files=0
has_navigation_css=0
has_simple_footer_js=0
needs_navigation_css=0
needs_footer_js=0

echo "📄 DETAILED PAGE ANALYSIS:"
echo "-------------------------"

for file in $html_files; do
    total_files=$((total_files + 1))
    echo ""
    echo "📄 $file:"
    
    # Check for navigation.css
    if grep -q 'navigation\.css' "$file"; then
        echo "   ✅ Has navigation.css (footer styles)"
        has_navigation_css=$((has_navigation_css + 1))
    else
        echo "   ❌ Missing navigation.css (footer styles)"
        needs_navigation_css=$((needs_navigation_css + 1))
    fi
    
    # Check for simple-footer.js
    if grep -q 'simple-footer\.js' "$file"; then
        echo "   ✅ Has simple-footer.js (footer content)"
        has_simple_footer_js=$((has_simple_footer_js + 1))
    else
        echo "   ❌ Missing simple-footer.js (footer content)"
        needs_footer_js=$((needs_footer_js + 1))
    fi
    
    # Check if it has footer HTML structure
    if grep -q '<footer class="footer">' "$file"; then
        echo "   ✅ Has footer HTML structure"
    else
        echo "   ⚠️  Missing footer HTML structure"
    fi
done

echo ""
echo ""
echo "📊 SUMMARY STATISTICS:"
echo "====================="
echo "Total HTML files found: $total_files"
echo "Pages with navigation.css: $has_navigation_css"
echo "Pages with simple-footer.js: $has_simple_footer_js"
echo "Pages needing navigation.css: $needs_navigation_css"
echo "Pages needing simple-footer.js: $needs_footer_js"

echo ""
echo "🎯 PAGES NEEDING FIXES:"
echo "======================="

if [ $needs_navigation_css -gt 0 ]; then
    echo ""
    echo "❌ Pages missing navigation.css (will have vertical footer):"
    for file in $html_files; do
        if ! grep -q 'navigation\.css' "$file"; then
            echo "   - $file"
        fi
    done
fi

if [ $needs_footer_js -gt 0 ]; then
    echo ""
    echo "❌ Pages missing simple-footer.js (will have empty footer):"
    for file in $html_files; do
        if ! grep -q 'simple-footer\.js' "$file"; then
            echo "   - $file"
        fi
    done
fi

echo ""
echo "🎉 STATUS:"
if [ $needs_navigation_css -eq 0 ] && [ $needs_footer_js -eq 0 ]; then
    echo "✅ ALL PAGES HAVE PROPER FOOTER SETUP!"
else
    echo "⚠️  $((needs_navigation_css + needs_footer_js)) pages need updates"
fi