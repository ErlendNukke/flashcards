import { chromium, devices } from 'playwright';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const deviceId = readFileSync('/tmp/flash_device_id', 'utf8').trim();
const outDir = join(dirname(fileURLToPath(import.meta.url)), '../docs/screenshots');

const iPhone = devices['iPhone 13'];

const browser = await chromium.launch({
  args: ['--enable-unsafe-swiftshader'],
});
const context = await browser.newContext({
  ...iPhone,
  baseURL: 'http://localhost:8088',
});
const page = await context.newPage();

await page.addInitScript((id) => {
  localStorage.setItem('flutter.flashcards_device_id', JSON.stringify(id));
}, deviceId);

await page.goto('/', { waitUntil: 'domcontentloaded' });
const studyButton = page.getByRole('button', { name: /Study deck/ });
await studyButton.waitFor({ state: 'visible', timeout: 120_000 });

await page.screenshot({ path: join(outDir, 'deck-list.png'), fullPage: true });

await studyButton.click();
await page.waitForTimeout(800);
await page.screenshot({ path: join(outDir, 'card-front.png'), fullPage: true });

await page.mouse.click(195, 400);
await page.waitForTimeout(600);
await page.screenshot({ path: join(outDir, 'card-back.png'), fullPage: true });

await browser.close();
console.log('Screenshots saved to docs/screenshots');
