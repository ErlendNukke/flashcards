import { chromium, devices } from 'playwright';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { randomUUID } from 'crypto';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const outDir = join(root, 'docs/screenshots');
const apiBase = process.env.API_BASE_URL || 'http://localhost:8080';
const webBase = process.env.WEB_BASE_URL || 'http://localhost:8088';
const deviceId = process.env.SCREENSHOT_DEVICE_ID || randomUUID();
const username = `icons_${deviceId.replace(/-/g, '').slice(0, 8)}`;
const password = 'password123shot';

async function registerAndSeed() {
  const registerRes = await fetch(`${apiBase}/api/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'X-Device-Id': deviceId },
    body: JSON.stringify({ username, password }),
  });
  if (!registerRes.ok) {
    throw new Error(`register ${registerRes.status} ${await registerRes.text()}`);
  }
  const body = await registerRes.json();
  const token = body.token;
  const user = body.user;
  const auth = { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' };
  await fetch(`${apiBase}/api/folders`, {
    method: 'POST',
    headers: auth,
    body: JSON.stringify({ name: 'Biology' }),
  });
  return { token, user };
}

const session = await registerAndSeed();

const iPhone = devices['iPhone 13'];
const browser = await chromium.launch({ args: ['--enable-unsafe-swiftshader'] });
const context = await browser.newContext({ ...iPhone, baseURL: webBase });
const page = await context.newPage();

await page.addInitScript(
  ({ id, token, user }) => {
    localStorage.setItem('flutter.flashcards_device_id', JSON.stringify(id));
    localStorage.setItem('flutter.flashcards_token', JSON.stringify(token));
    localStorage.setItem('flutter.flashcards_user', JSON.stringify(JSON.stringify(user)));
  },
  { id: deviceId, token: session.token, user: session.user },
);

await page.goto('/', { waitUntil: 'domcontentloaded' });
await page.waitForTimeout(10000);
await page.getByRole('button', { name: /New folder/ }).waitFor({ timeout: 120_000 });
await page.screenshot({ path: join(outDir, 'web-new-folder-fab.png'), fullPage: true });

await page.getByRole('button', { name: /Biology/ }).click();
await page.getByRole('button', { name: /New card/ }).waitFor({ timeout: 60_000 });
await page.screenshot({ path: join(outDir, 'web-new-card-fab.png'), fullPage: true });

await browser.close();
console.log('Screenshots saved to', outDir);
