/**
 * Integration check: release web build — welcome → login → home (not stuck on login).
 * Requires API on API_BASE_URL and static web on WEB_BASE_URL.
 */
import { chromium, devices } from 'playwright';
import { randomUUID } from 'crypto';

const apiBase = process.env.API_BASE_URL || 'http://localhost:8080';
const webBase = process.env.WEB_BASE_URL || 'http://localhost:8088';
const deviceId = randomUUID();
const username = `verify_${deviceId.replace(/-/g, '').slice(0, 10)}`;
const password = 'password123verify';

const registerRes = await fetch(`${apiBase}/api/auth/register`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json', 'X-Device-Id': deviceId },
  body: JSON.stringify({ username, password }),
});
if (!registerRes.ok) {
  console.error('register failed', registerRes.status, await registerRes.text());
  process.exit(1);
}

const browser = await chromium.launch({ args: ['--enable-unsafe-swiftshader'] });
const context = await browser.newContext({ ...devices['iPhone 13'], baseURL: webBase });
const page = await context.newPage();

await page.addInitScript((id) => {
  localStorage.setItem('flutter.flashcards_device_id', JSON.stringify(id));
  localStorage.removeItem('flutter.flashcards_token');
  localStorage.removeItem('flutter.flashcards_user');
}, deviceId);

await page.goto('/', { waitUntil: 'domcontentloaded' });
await page.getByRole('button', { name: 'Sign up' }).waitFor({ timeout: 120_000 });

await page.getByRole('button', { name: 'Log in' }).click();
await page.getByLabel('Username').fill(username);
await page.getByLabel('Password').fill(password);
await page.getByRole('button', { name: 'Log in' }).click();

await page.waitForTimeout(3000);
const stillOnLogin = await page.getByText('Welcome back').isVisible().catch(() => false);
if (stillOnLogin) {
  console.error('Still on login screen after successful auth');
  process.exit(1);
}
await page.getByRole('button', { name: /New folder/ }).waitFor({ timeout: 120_000 });

await browser.close();
console.log('OK: login flow reaches home on release web build');
