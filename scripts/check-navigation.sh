#!/bin/bash

# Script to check and report navigation consistency across ALL pages
echo "🔍 NAVIGATION CONSISTENCY CHECK"
echo "================================"

# Pages to check
declare -A pages=(
    ["index.html"]="root"
    ["pages/about.html"]="pages"
    ["pages/how-it-works.html"]="pages"
    ["pages/contact.html"]="pages"
    ["pages/faq.html"]="pages"
    ["pages/sheltercard.html"]="pages"
    ["pages/dashboard.html"]="pages"
    ["pages/my-pets.html"]="pages"
    ["pages/businesses.html"]="pages"
    ["pages/pet-owners.html"]="pages"
    ["pages/vets.html"]="pages"
    ["pages/shelters.html"]="pages"
    ["pages/privacy.html"]="pages"
    ["pages/terms.html"]="pages"
    ["pages/login.html"]="pages"
    ["pages/register.html"]="pages"
    ["pages/profile.html"]="pages"
)

echo ""
echo "📊 CSS CHECK - Should all use simple-navigation.css:"
echo "------------------------------------------------"

for page in "${!pages[@]}"; do
    if [ -f "$page" ]; then
        if grep -q "simple-navigation.css" "$page"; then
            echo "✅ $page - Uses simple-navigation.css"
        else
            echo "❌ $page - Still uses old navigation.css"
        fi
    else
        echo "⚠️  $page - File not found"
    fi
done

echo ""
echo "📊 JS CHECK - Should all use simple-navigation.js:"
echo "-----------------------------------------------"

for page in "${!pages[@]}"; do
    if [ -f "$page" ]; then
        if grep -q "simple-navigation.js" "$page"; then
            echo "✅ $page - Uses simple-navigation.js"
        else
            echo "❌ $page - Missing or uses old navigation.js"
        fi
    else
        echo "⚠️  $page - File not found"
    fi
done

echo ""
echo "📊 HEADER CHECK - Should all use clean header:"
echo "--------------------------------------------"

for page in "${!pages[@]}"; do
    if [ -f "$page" ]; then
        if grep -q "Navigation automatically loaded by simple-navigation.js" "$page"; then
            echo "✅ $page - Uses clean header template"
        else
            echo "❌ $page - Still has manual navigation HTML"
        fi
    else
        echo "⚠️  $page - File not found"
    fi
done

echo ""
echo "🎯 SUMMARY:"
echo "----------"
inconsistent_count=0
total_count=0

for page in "${!pages[@]}"; do
    if [ -f "$page" ]; then
        total_count=$((total_count + 1))
        if ! grep -q "simple-navigation.css" "$page" || ! grep -q "simple-navigation.js" "$page"; then
            inconsistent_count=$((inconsistent_count + 1))
        fi
    fi
done

consistent_count=$((total_count - inconsistent_count))
echo "✅ Consistent pages: $consistent_count/$total_count"
echo "❌ Need updating: $inconsistent_count/$total_count"

if [ $inconsistent_count -eq 0 ]; then
    echo "🎉 ALL PAGES ARE CONSISTENT!"
else
    echo "⚠️  Some pages still need updating"
fi