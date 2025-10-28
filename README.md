# Shelter Pawtners - Core Website

The digital backbone for post-adoption success, connecting shelter-adopted pets with lifetime support through our revolutionary Shelter Card program.

## 🌐 Live Preview

**View the website at:** https://shelterpawtners.github.io/Core/

The website is automatically deployed to GitHub Pages whenever changes are pushed to the `main` branch.

## 📋 About This Site

Shelter Pawtners is a static HTML website featuring:
- Modern glass-morphism design
- Full ADA compliance and accessibility
- Responsive mobile-first layout
- Comprehensive post-adoption support for shelter pets

## 🚀 GitHub Pages Setup

This repository is configured to automatically deploy to GitHub Pages using GitHub Actions.

### How It Works

1. When code is pushed to the `main` branch, a GitHub Actions workflow automatically triggers
2. The workflow builds and deploys the static site to GitHub Pages
3. The site becomes available at: https://shelterpawtners.github.io/Core/

### Manual Deployment

You can also manually trigger a deployment:
1. Go to the "Actions" tab in this repository
2. Select "Deploy to GitHub Pages" workflow
3. Click "Run workflow" button
4. Select the branch and click "Run workflow"

### First-Time Setup Requirements

If this is a new repository, you'll need to enable GitHub Pages:

1. Go to repository **Settings**
2. Navigate to **Pages** (in the left sidebar under "Code and automation")
3. Under **Source**, select **GitHub Actions** (not "Deploy from a branch")
4. Save the changes

Once enabled, the workflow will automatically deploy the site on the next push to `main`.

## 📁 Project Structure

```
/
├── index.html              # Homepage
├── pages/                  # Additional pages
│   ├── about.html
│   ├── how-it-works.html
│   ├── register.html
│   └── ...
├── css/                    # Stylesheets
│   ├── main.css
│   ├── navigation.css
│   ├── components.css
│   └── responsive.css
├── js/                     # JavaScript files
├── admin/                  # Admin pages
└── .github/
    └── workflows/
        └── deploy-pages.yml  # GitHub Pages deployment workflow

```

## 🛠️ Local Development

To preview the site locally:

1. Clone the repository:
   ```bash
   git clone https://github.com/shelterpawtners/Core.git
   cd Core
   ```

2. Open `index.html` in a web browser, or use a local server:
   ```bash
   # Using Python 3
   python -m http.server 8000
   
   # Using Node.js (if you have http-server installed)
   npx http-server
   ```

3. Navigate to `http://localhost:8000` in your browser

## 🔧 Making Changes

1. Make your changes to HTML, CSS, or JS files
2. Test locally
3. Commit and push to the `main` branch
4. The site will automatically update on GitHub Pages within a few minutes

## 📝 Contributing

When making changes:
- Maintain the glass-morphism design system
- Ensure ADA compliance (WCAG AAA standards)
- Test on mobile devices
- Keep the mission-focused messaging

## 📄 License

© 2024 Shelter Pawtners. All rights reserved.
