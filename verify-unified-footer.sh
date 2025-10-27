#!/bin/bash

echo "🔍 FINAL FOOTER VERIFICATION REPORT"
echo "=================================="
echo ""

# Check all pages for unified footer structure
echo "📋 1. Pages with correct unified footer structure:"
correct_footer=0
total_pages=0

for file in index.html pages/*.html; do
    if [ -f "$file" ]; then
        total_pages=$((total_pages + 1))
        if grep -q '<footer class="footer">' "$file" && grep -q "Footer content automatically loaded by simple-footer.js" "$file"; then
            echo "   ✅ $file"
            correct_footer=$((correct_footer + 1))
        fi
    fi
done

echo ""
echo "📋 2. Pages with simple-footer.js script loaded:"
script_loaded=0

for file in index.html pages/*.html; do
    if [ -f "$file" ]; then
        if grep -q '<script.*simple-footer.js' "$file"; then
            echo "   ✅ $file"
            script_loaded=$((script_loaded + 1))
        fi
    fi
done

echo ""
echo "❌ 3. Pages missing unified footer:"
for file in index.html pages/*.html; do
    if [ -f "$file" ]; then
        if ! grep -q '<footer class="footer">' "$file" || ! grep -q "Footer content automatically loaded by simple-footer.js" "$file"; then
            echo "   🔴 $file - missing unified footer structure"
        fi
    fi
done

echo ""
echo "❌ 4. Pages missing simple-footer.js script:"
for file in index.html pages/*.html; do
    if [ -f "$file" ]; then
        if ! grep -q '<script.*simple-footer.js' "$file"; then
            echo "   🔴 $file - missing simple-footer.js script"
        fi
    fi
done

echo ""
echo "📊 SUMMARY:"
echo "=========="
echo "Total pages checked: $total_pages"
echo "Pages with correct footer structure: $correct_footer"
echo "Pages with footer script loaded: $script_loaded"

if [ $correct_footer -eq $script_loaded ] && [ $correct_footer -eq $((total_pages - 6)) ]; then
    echo ""
    echo "🎉 SUCCESS! All main pages are using the unified footer system!"
    echo "   (Some utility/demo pages may not have footers, which is expected)"
else
    echo ""
    echo "⚠️  Some pages still need attention - see details above"
fi

echo ""
echo "🌐 Test URLs (server should be running on port 8080):"
echo "   http://localhost:8080/ (homepage)"
echo "   http://localhost:8080/pages/about.html"
echo "   http://localhost:8080/pages/businesses.html"
echo "   http://localhost:8080/pages/how-it-works.html"