![](/assets/thumbnails/site-thumbnail.png)

# Pasithea0's Microblog Template

This site is built with [Jekyll](https://jekyllrb.com/) and uses a simple, clean design focused on readability. The content is written in Markdown and automatically compiled into web pages. It takes (a lot of) inspiration from [stephango.com](https://stephango.com/) with some modifications and my own design touch.

Preview: https://pasithea0.github.io/microblog-template/

## Features:

- Markdown content with support for images, quotes, and lists. Designed to support Obsidian-style fontmatter and attachments
- Auto-generated thumbnails for social media sharing
- Reading time calculation for each post
- Tag-based topic pages
- Responsive design for mobile and desktop
- Static site generation for GitHub Pages

## Getting Started

### Prerequisites

- Ruby (with gem)
- pnpm
- ImageMagick (for thumbnail generation)

### Installation

1. Install Jekyll and Bundler:
   ```bash
   gem install jekyll bundler
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Install ImageMagick (required for thumbnail generation):
   ```bash
   # macOS
   brew install imagemagick
   
   # Ubuntu/Debian
   sudo apt-get install imagemagick
   
   # Windows (using Chocolatey)
   choco install imagemagick
   ```

### Development

Start the development server with live reload:
```bash
pnpm run dev
```

The site will be available at `http://localhost:4000`

### Available Scripts

- `pnpm run dev` - Start development server with live reload
- `pnpm run build` - Build the site for production
- `pnpm run serve` - Start a simple server (without live reload)
- `pnpm run clean` - Clean the build directory and thumbnails
- `pnpm run generate-thumbnails` - Generate PNG thumbnails for social media sharing

### Thumbnail Generation

**Important**: Thumbnails MUST be generated manually on your device before deployment. The build process no longer automatically generates thumbnails.

Start by adding `thumb.png` and `favicon.ico` to the assets folder. the favicon will be converted to png automatically.

To generate thumbnails for your posts:

1. Ensure ImageMagick is installed (see Prerequisites)
2. Run the thumbnail generation command:
   ```bash
   pnpm run generate-thumbnails
   ```
3. This will create both SVG and PNG versions of thumbnails in `assets/thumbnails/`:
   - Individual post thumbnails: `{post-slug}.svg` and `{post-slug}.png`
   - Site thumbnail: `site-thumbnail.svg` and `site-thumbnail.png` (used for home page and other non-post pages)
4. The PNG versions are used for social media sharing (iMessage, Twitter, etc.)

**Note**: Thumbnails are only generated in production mode (`JEKYLL_ENV=production`) to ensure proper image encoding and conversion.

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
