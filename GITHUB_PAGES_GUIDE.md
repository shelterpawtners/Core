# GitHub Pages Setup Guide for Shelter Pawtners

This guide explains how to preview and deploy the Shelter Pawtners website using GitHub Pages.

## 🌐 Quick Access

**Live Website:** https://shelterpawtners.github.io/Core/

## 📖 What is GitHub Pages?

GitHub Pages is a free hosting service provided by GitHub that allows you to host static websites directly from a GitHub repository. It's perfect for our static HTML website!

## ✅ Initial Setup (One-Time Configuration)

If this is the first time setting up GitHub Pages for this repository, follow these steps:

### Step 1: Enable GitHub Pages

1. Navigate to your repository on GitHub: https://github.com/shelterpawtners/Core
2. Click on **Settings** (in the top repository menu)
3. In the left sidebar, scroll down and click on **Pages** (under "Code and automation")
4. Under **Build and deployment**:
   - **Source:** Select **GitHub Actions** (NOT "Deploy from a branch")
   - This allows our custom workflow to handle deployment
5. Save changes

### Step 2: Verify Workflow Permissions

1. Still in **Settings**, click on **Actions** → **General** (in the left sidebar)
2. Scroll down to **Workflow permissions**
3. Ensure **"Read and write permissions"** is selected
4. Check the box for **"Allow GitHub Actions to create and approve pull requests"**
5. Click **Save**

### Step 3: Trigger First Deployment

After setup, trigger a deployment by either:

**Option A: Push a change to main branch**
```bash
git checkout main
git commit --allow-empty -m "Trigger GitHub Pages deployment"
git push origin main
```

**Option B: Manual workflow trigger**
1. Go to the **Actions** tab in your repository
2. Click on **"Deploy to GitHub Pages"** workflow in the left sidebar
3. Click **"Run workflow"** button (top right)
4. Select `main` branch
5. Click the green **"Run workflow"** button

### Step 4: Wait for Deployment

1. Go to the **Actions** tab
2. You'll see a workflow run in progress
3. Wait for it to complete (usually 1-2 minutes)
4. Once complete, your site will be live!

## 🔄 How Automatic Deployment Works

After initial setup, the website automatically deploys when:

1. **Any code is pushed to the `main` branch**
   - The workflow in `.github/workflows/deploy-pages.yml` triggers automatically
   - GitHub Actions builds and deploys the site
   - Changes appear on the live site within 1-2 minutes

2. **Manual trigger**
   - You can manually run the workflow from the Actions tab anytime

## 🔍 Monitoring Deployments

### Check Deployment Status

1. Go to **Actions** tab in your repository
2. Look for recent workflow runs
3. Green checkmark ✓ = successful deployment
4. Red X ✗ = failed deployment (click for details)

### View Deployment History

1. Go to repository **Settings** → **Pages**
2. You'll see deployment history and status
3. Current URL is displayed at the top

## 🐛 Troubleshooting

### Issue: "404 - Page Not Found"

**Solution:**
- Verify GitHub Pages is enabled in Settings → Pages
- Check that Source is set to "GitHub Actions"
- Ensure the workflow has run successfully (check Actions tab)
- Wait a few minutes after deployment completes

### Issue: Workflow Fails with Permission Error

**Solution:**
- Go to Settings → Actions → General
- Under "Workflow permissions", select "Read and write permissions"
- Re-run the workflow

### Issue: Site Shows Old Content

**Solution:**
- Hard refresh your browser: `Ctrl + F5` (Windows) or `Cmd + Shift + R` (Mac)
- Check the Actions tab to ensure latest workflow completed
- GitHub Pages can take 1-2 minutes to update after deployment

### Issue: CSS/JS Not Loading

**Solution:**
- Ensure all file paths in HTML are relative (not absolute)
- Check that `css/` and `js/` folders are in the repository
- Verify workflow successfully uploaded all files

## 📁 What Gets Deployed?

The workflow deploys everything from the repository root, including:
- `index.html` (homepage)
- `pages/` directory (all subpages)
- `css/` directory (stylesheets)
- `js/` directory (JavaScript files)
- `admin/` directory (admin pages)
- Any other files in the repository

Files excluded (via `.gitignore`):
- `.DS_Store` and other OS files
- Editor configuration files
- Temporary files
- `node_modules/` (if added later)

## 🔗 Accessing Different Pages

Once deployed, pages are accessible at:

- **Homepage:** https://shelterpawtners.github.io/Core/
- **About Page:** https://shelterpawtners.github.io/Core/pages/about.html
- **How It Works:** https://shelterpawtners.github.io/Core/pages/how-it-works.html
- **Registration:** https://shelterpawtners.github.io/Core/pages/register.html
- **Admin:** https://shelterpawtners.github.io/Core/admin/

## 🛠️ Local Testing Before Deployment

Always test locally before pushing to main:

```bash
# Using Python
python -m http.server 8000

# Using Node.js
npx http-server

# Using PHP
php -S localhost:8000
```

Then visit `http://localhost:8000` in your browser.

## 📊 Workflow File Explanation

The deployment is handled by `.github/workflows/deploy-pages.yml`:

```yaml
# Triggers on push to main or manual dispatch
on:
  push:
    branches: ["main"]
  workflow_dispatch:

# Two jobs: build and deploy
jobs:
  build:
    # Uploads the entire repository as an artifact
    
  deploy:
    # Deploys the artifact to GitHub Pages
```

## 🎯 Best Practices

1. **Test locally first** - Don't push broken code to main
2. **Use feature branches** - Make changes in branches, test, then merge to main
3. **Monitor Actions** - Check that deployments succeed
4. **Clear browser cache** - If you don't see changes, try hard refresh
5. **Check mobile** - GitHub Pages works great for responsive testing

## 💡 Tips

- **Custom Domain:** You can configure a custom domain in Settings → Pages
- **HTTPS:** GitHub Pages automatically provides HTTPS
- **Speed:** Deployments typically take 1-2 minutes
- **Free:** GitHub Pages is completely free for public repositories
- **Limits:** 1GB site size limit, 100GB bandwidth/month (soft limit)

## 📞 Need Help?

If you're still having issues:

1. Check the [GitHub Pages documentation](https://docs.github.com/pages)
2. Review the Actions workflow logs for error messages
3. Ensure all file paths are correct and relative
4. Verify that required files (index.html, css/, js/) exist

## 🎉 Success!

Once everything is set up, you'll have:
- ✅ Automatic deployments on every push to main
- ✅ Live website accessible to anyone
- ✅ Free hosting with HTTPS
- ✅ Easy updates - just push to main!

---

**Ready to deploy?** Just push your changes to the `main` branch and watch the magic happen! ✨
