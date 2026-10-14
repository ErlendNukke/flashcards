import { chromium } from 'playwright';
import { writeFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const webDir = join(root, 'mobile/web');
const out = join(root, 'docs/screenshots/app-icon-web.png');

const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="theme-color" content="#3E26A9" />
  <title>Flashcards icons</title>
  <style>
    body { font-family: system-ui, sans-serif; margin: 24px; background: #f5f3ff; color: #1f1235; }
    h1 { font-size: 1.25rem; margin-bottom: 16px; }
    .row { display: flex; gap: 24px; align-items: flex-end; flex-wrap: wrap; }
    figure { margin: 0; text-align: center; }
    figcaption { margin-top: 8px; font-size: 0.85rem; color: #4b5563; }
    img { display: block; border-radius: 16px; box-shadow: 0 8px 24px rgba(62,38,169,0.25); }
    .favicon { border-radius: 6px; box-shadow: none; }
  </style>
</head>
<body>
  <h1>Flashcards — web manifest &amp; favicon</h1>
  <div class="row">
    <figure>
      <img src="icons/Icon-512.png" width="192" height="192" alt="PWA icon 512" />
      <figcaption>PWA 192 (from 512)</figcaption>
    </figure>
    <figure>
      <img src="favicon.png" width="48" height="48" class="favicon" alt="Favicon" />
      <figcaption>favicon.png</figcaption>
    </figure>
    <figure>
      <img src="apple-touch-icon.png" width="120" height="120" alt="Apple touch icon" />
      <figcaption>apple-touch-icon</figcaption>
    </figure>
  </div>
</body>
</html>`;

writeFileSync(join(webDir, 'icon-preview.html'), html);

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 390, height: 520 } });
await page.goto(`file://${join(webDir, 'icon-preview.html')}`);
await page.screenshot({ path: out, fullPage: true });
await browser.close();
console.log('Saved', out);
