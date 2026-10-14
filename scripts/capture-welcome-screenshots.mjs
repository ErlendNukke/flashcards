import { chromium, devices } from 'playwright';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { randomUUID } from 'crypto';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const outDir = join(root, 'docs/screenshots');
const webBase = process.env.WEB_BASE_URL || 'http://localhost:8088';
const deviceId = randomUUID();

const browser = await chromium.launch({ args: ['--enable-unsafe-swiftshader'] });

async function captureSignedOut(name, contextOptions) {
  const context = await browser.newContext({ ...contextOptions, baseURL: webBase });
  const page = await context.newPage();
  await page.addInitScript((id) => {
    localStorage.setItem('flutter.flashcards_device_id', JSON.stringify(id));
    localStorage.removeItem('flutter.flashcards_token');
    localStorage.removeItem('flutter.flashcards_user');
  }, deviceId);
  await page.goto('/', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(10000);
  await page.getByRole('button', { name: 'Sign up' }).waitFor({ timeout: 120_000 });
  await page.waitForTimeout(400);
  await page.screenshot({ path: join(outDir, name), fullPage: true });
  await context.close();
}

await captureSignedOut('welcome-mobile.png', devices['iPhone 13']);
await captureSignedOut('welcome-desktop.png', {
  viewport: { width: 1280, height: 800 },
  userAgent: devices['Desktop Chrome'].userAgent,
});

await browser.close();
console.log('Welcome screenshots saved to', outDir);
