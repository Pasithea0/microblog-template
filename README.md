![](/assets/thumbnails/site-thumbnail.png)

# Pasithea0's Microblog Template

This site is built with [Jekyll](https://jekyllrb.com/) and uses a simple, clean design focused on readability. The content is written in Markdown and automatically compiled into web pages. It takes (a lot of) inspiration from [stephango.com](https://stephango.com/) with some modifications and my own design touch.

Preview: https://pasithea0.github.io/microblog-template/

## Features:

- Markdown content with support for images, quotes, and lists. Designed to support Obsidian-style fontmatter and attachments
- Auto-generated thumbnails for social media sharing (generated during CI build)
- Reading time calculation for each post
- Tag-based topic pages
- Responsive design for mobile and desktop
- Static site generation for GitHub Pages / Cloudflare Pages

## Getting Started

### Prerequisites

- Ruby (with gem)
- pnpm

### Installation

1. Install Jekyll and Bundler:
   ```bash
   gem install jekyll bundler
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

### Development

Start the development server with live reload:
```bash
pnpm run dev
```

The site will be available at `http://localhost:4000`

### Deploying

Thumbnails are auto-generated during CI — no local steps needed.

1. Push your changes to GitHub:
   ```bash
   git add -A
   git commit -m "your message"
   git push
   ```

2. GitHub Actions builds the site, generates thumbnails, and deploys to Pages automatically.

Or point Cloudflare Pages at your repo — it runs the same Jekyll build with `JEKYLL_ENV=production` and generates thumbnails on its own.

### Available Scripts

- `pnpm run dev` - Start development server with live reload
- `pnpm run build` - Build the site for production
- `pnpm run serve` - Start a simple server (without live reload)
- `pnpm run clean` - Clean the build directory and thumbnails
- `pnpm run generate-thumbnails` - Manually generate thumbnails (only needed for local testing)

### Thumbnail Generation

Thumbnails are **automatically generated** during your CI build (GitHub Pages or Cloudflare Pages) when you push your changes. The build sets `JEKYLL_ENV=production`, which triggers the SVG thumbnail generator and converts them to PNG using `rsvg-convert` (installed via `librsvg2-bin` on the CI runner).

No local ImageMagick, no separate command, no manual steps.

If you want to preview thumbnails locally, you can run:

```bash
JEKYLL_ENV=production bundle exec jekyll build --config _config.yml,_config.thumbnails.yml
```

Start by adding `thumb.png` and `favicon.ico` to the assets folder. The favicon will be converted to PNG automatically.

### Adding Content

Start by editing `_config.yml` to set your site's title, description, and other settings.

- **Long-form writings**: Create new files in `_writing/` with `layout: post` in the fontmater
- **Microblog posts**: Create new files in `_microblog/` with `layout: micro` in the fontmater
- **Requirements**: All notes require a date fontmater. For example: `created: 2025-09-05`. These options are avaliable and the date priority is: updated > created > published
- **Attachments**: Add all attachments/image to `assets/attachments/`, link them in the post with `![[/attachments/{filename}]]` syntax
- **Pages**: Create HTML or Markdown files in the root directory
- **Styles**: Add CSS files to `assets/css/`, randomize options are in `default.html`
- **Layouts**: Create new layouts in `_layouts/`

### Bonus Features
- robots.txt and RSL standard to reject AI scraping/indexing
- PGP page to share your public key
- Two separate RSS feeds for long-form writings and microblog posts
- Multiple CSS styles, including a Minecraft theme
- Email button that acts as a "comment" button, linking to the current post
