import { chromium, devices } from 'playwright';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { randomUUID } from 'crypto';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const outDir = join(root, 'docs/screenshots');
const apiBase = 'http://localhost:8080';
const webBase = 'http://localhost:8088';
const deviceId = process.env.SCREENSHOT_DEVICE_ID || randomUUID();
const username = process.env.SCREENSHOT_USERNAME || `shot_${deviceId.replace(/-/g, '').slice(0, 10)}`;
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
  const post = async (path, payload) => {
    const r = await fetch(`${apiBase}${path}`, { method: 'POST', headers: auth, body: JSON.stringify(payload) });
    if (!r.ok) throw new Error(`${path} ${r.status} ${await r.text()}`);
    return r.json();
  };
  const bio = await post('/api/folders', { name: 'Biology' });
  await post('/api/cards', {
    question: 'What is photosynthesis?',
    answer: 'Light to chemical energy.',
    folderId: bio.id,
  });
  return { token, user, username: user.username };
}

const session = await registerAndSeed();

const iPhone = devices['iPhone 13'];
const browser = await chromium.launch({ args: ['--enable-unsafe-swiftshader'] });
const context = await browser.newContext({ ...iPhone, baseURL: webBase });

async function primeStorage(page, { loggedIn }) {
  await page.addInitScript(
    ({ id, loggedIn, token, user }) => {
      localStorage.setItem('flutter.flashcards_device_id', JSON.stringify(id));
      if (loggedIn) {
        localStorage.setItem('flutter.flashcards_token', JSON.stringify(token));
        localStorage.setItem('flutter.flashcards_user', JSON.stringify(JSON.stringify(user)));
      } else {
        localStorage.removeItem('flutter.flashcards_token');
        localStorage.removeItem('flutter.flashcards_user');
      }
    },
    {
      id: deviceId,
      loggedIn,
      token: session.token,
      user: session.user,
    },
  );
}

const loginPage = await context.newPage();
await primeStorage(loginPage, { loggedIn: false });
await loginPage.goto('/', { waitUntil: 'domcontentloaded' });
await loginPage.waitForTimeout(10000);
await loginPage.getByRole('button', { name: 'Log in' }).waitFor({ timeout: 120_000 });
await loginPage.screenshot({ path: join(outDir, 'auth-login.png'), fullPage: true });

await loginPage.getByRole('button', { name: 'Create an account' }).click();
await loginPage.getByText('Create your account').waitFor({ timeout: 30_000 });
await loginPage.screenshot({ path: join(outDir, 'auth-sign-up.png'), fullPage: true });
await loginPage.close();

const homePage = await context.newPage();
await primeStorage(homePage, { loggedIn: true });
await homePage.goto('/', { waitUntil: 'domcontentloaded' });
await homePage.waitForTimeout(10000);
await homePage.getByRole('button', { name: /Biology/ }).waitFor({ timeout: 120_000 });
await homePage.waitForTimeout(500);
await homePage.screenshot({ path: join(outDir, 'auth-folder-list.png'), fullPage: true });

await browser.close();
console.log('Screenshots saved to', outDir);
