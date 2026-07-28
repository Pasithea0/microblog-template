#!/bin/bash
# CI build script for microblog
# Installs SVG renderer and builds Jekyll in production mode
# so social media thumbnails are auto-generated.
#
# Usage on Cloudflare Pages:
#   Set build command to: bash build.sh
#
# Usage on GitHub Actions (via .github/workflows/pages.yml):
#   bash build.sh --trace --baseurl "/my-repo"

set -e

echo ":: Installing SVG renderer for thumbnail generation..."
apt-get update -qq && apt-get install -y -qq librsvg2-bin

echo ":: Building Jekyll site (production)..."
JEKYLL_ENV=production bundle exec jekyll build "$@"

echo ":: Build complete"
