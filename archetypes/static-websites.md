=== CONTEXT ===
Static website archetype for GitHub Pages deployment using Zola SSG.
Zero hosting costs with CDN distribution included.

=== OBJECTIVE ===
Create fast, SEO-optimized static website with automated deployment.
Success metrics:
□ <1s page load time
□ 100 Lighthouse performance score
□ Zero hosting costs
□ Automated deploy on push to main

=== TECHNICAL STACK ===
Static Site Generator:
- Zola (Rust-based, single binary)
- Markdown content files
- Tera templates

Hosting:
- GitHub Pages (free tier)
- Custom domain support
- Automatic HTTPS

Build Process:
- GitHub Actions on push
- Build, test, deploy pipeline
- Branch protection for main

=== PROJECT STRUCTURE ===
```
/
├── config.toml         # Zola configuration
├── content/           # Markdown pages/posts
├── static/            # Assets (images, css, js)
├── templates/         # Tera HTML templates
├── sass/             # SCSS stylesheets
└── .github/
    └── workflows/
        └── deploy.yml # Build & deploy action
```

=== GITHUB ACTION ===
```yaml
name: Deploy to GitHub Pages
on:
  push:
    branches: [main]

jobs:
  build-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build site
        run: |
          wget -q -O zola.tar.gz [zola-url]
          tar xzf zola.tar.gz
          ./zola build
      
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./public
```

=== CONFIGURATION ===
config.toml essentials:
```toml
base_url = "https://[username].github.io/[repo]"
compile_sass = true
build_search_index = true
minify_html = true

[extra]
# Custom variables
```

=== CONTENT STRUCTURE ===
Page Format:
```markdown
+++
title = "Page Title"
date = 2024-01-01
[taxonomies]
tags = ["tag1", "tag2"]
+++

Page content in markdown...
```

=== CONSTRAINTS ===
⛔ NEVER commit generated files
⛔ NEVER use external build services
⛔ NEVER exceed GitHub Pages limits (1GB)
✅ ALWAYS optimize images before commit
✅ ALWAYS test builds locally first
✅ ALWAYS use relative URLs for assets

=== VALIDATION CHECKLIST ===
□ Zola builds without errors
□ All links validated (no 404s)
□ Images optimized (<100KB each)
□ GitHub Action configured
□ Custom domain setup (if needed)