// Converts SVG thumbnails to PNG using @resvg/resvg-js
// Used as a fallback on platforms without rsvg-convert (e.g. Cloudflare Pages)
import { Resvg } from '@resvg/resvg-js';
import { readFileSync, writeFileSync, readdirSync, statSync, existsSync, mkdirSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';

const rootDir = process.cwd();
const thumbDir = join(rootDir, 'assets', 'thumbnails');
const siteThumbDir = join(rootDir, '_site', 'assets', 'thumbnails');

let files;
try {
  files = readdirSync(thumbDir).filter(f => f.endsWith('.svg'));
} catch {
  console.log('  (no thumbnails directory, skipping)');
  process.exit(0);
}

if (files.length === 0) {
  console.log('  (no SVG thumbnails found, skipping)');
  process.exit(0);
}

// Ensure _site thumbnails directory exists
if (!existsSync(siteThumbDir)) {
  try {
    mkdirSync(siteThumbDir, { recursive: true });
  } catch {
    // _site might not exist yet if this runs before a full build
  }
}

let converted = 0;
for (const file of files) {
  const svgPath = join(thumbDir, file);
  const pngName = file.replace(/\.svg$/, '.png');
  const pngPath = join(thumbDir, pngName);
  const sitePngPath = join(siteThumbDir, pngName);

  // Skip if PNG already exists and is newer than the SVG
  try {
    const svgStat = statSync(svgPath);
    const pngStat = statSync(pngPath);
    if (pngStat.mtimeMs >= svgStat.mtimeMs) {
      continue; // PNG is up to date
    }
  } catch {
    // PNG doesn't exist yet, convert
  }

  try {
    const svg = readFileSync(svgPath);
    const resvg = new Resvg(svg, {
      fitTo: { mode: 'width', value: 1200 },
      background: '#2d4a2d',
    });
    const png = resvg.render().asPng();

    // Write to source (for subsequent builds / local dev)
    writeFileSync(pngPath, png);

    // Write to _site output (for this deploy — Jekyll already finalized _site)
    try {
      writeFileSync(sitePngPath, png);
    } catch {
      // _site dir might not be writable or exist
    }

    console.log(`  ✓ ${file} → ${pngName}`);
    converted++;
  } catch (err) {
    console.error(`  ✗ ${file}: ${err.message}`);
  }
}

if (converted === 0) {
  console.log('  (all thumbnails up to date)');
}
