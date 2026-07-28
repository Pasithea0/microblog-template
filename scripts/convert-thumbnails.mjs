// Converts SVG thumbnails to PNG using @resvg/resvg-js
// Used as a fallback on platforms without rsvg-convert (e.g. Cloudflare Pages)
import { Resvg } from '@resvg/resvg-js';
import { readFileSync, writeFileSync, readdirSync, statSync } from 'node:fs';
import { join } from 'node:path';

const thumbDir = join(process.cwd(), 'assets', 'thumbnails');

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

let converted = 0;
for (const file of files) {
  const svgPath = join(thumbDir, file);
  const pngPath = join(thumbDir, file.replace(/\.svg$/, '.png'));

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
    writeFileSync(pngPath, png);
    console.log(`  ✓ ${file} → ${file.replace(/\.svg$/, '.png')}`);
    converted++;
  } catch (err) {
    console.error(`  ✗ ${file}: ${err.message}`);
  }
}

if (converted === 0) {
  console.log('  (all thumbnails up to date)');
}
