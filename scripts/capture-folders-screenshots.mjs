import { chromium, devices } from 'playwright';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { randomUUID } from 'crypto';
import { writeFileSync } from 'fs';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const outDir = join(root, 'docs/screenshots');
const apiBase = 'http://localhost:8080';
const deviceId = process.env.SCREENSHOT_DEVICE_ID || randomUUID();
const username = `folders_${deviceId.replace(/-/g, '').slice(0, 8)}`;
const password = 'password123shot';
writeFileSync('/tmp/folders_device_id', deviceId);

async function authHeaders() {
  const registerRes = await fetch(`${apiBase}/api/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'X-Device-Id': deviceId },
    body: JSON.stringify({ username, password }),
  });
  if (!registerRes.ok) throw new Error(`register ${registerRes.status} ${await registerRes.text()}`);
  const { token } = await registerRes.json();
  return { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' };
}

async function seed() {
  const headers = await authHeaders();
  const post = async (path, body) => {
    const r = await fetch(`${apiBase}${path}`, { method: 'POST', headers, body: JSON.stringify(body) });
    if (!r.ok) throw new Error(`${path} ${r.status} ${await r.text()}`);
    return r.json();
  };
  const bio = await post('/api/folders', { name: 'Biology' });
  const chem = await post('/api/folders', { name: 'Chemistry' });
  await post('/api/cards', { question: 'What is photosynthesis?', answer: 'Light to chemical energy.', folderId: bio.id });
  await post('/api/cards', { question: 'Cell powerhouse?', answer: 'Mitochondria', folderId: bio.id });
  await post('/api/cards', { question: 'H2O formula?', answer: 'Water', folderId: chem.id });
  await post('/api/cards', { question: 'NaCl?', answer: 'Salt', folderId: chem.id });
  return { username, password };
}

const credentials = await seed();

const iPhone = devices['iPhone 13'];
const browser = await chromium.launch({ args: ['--enable-unsafe-swiftshader'] });
const context = await browser.newContext({ ...iPhone, baseURL: 'http://localhost:8088' });
const page = await context.newPage();

await page.addInitScript((id) => {
  localStorage.setItem('flutter.flashcards_device_id', JSON.stringify(id));
  localStorage.removeItem('flutter.flashcards_token');
  localStorage.removeItem('flutter.flashcards_user');
}, deviceId);

await page.goto('/', { waitUntil: 'domcontentloaded' });
await page.getByLabel('Username').fill(credentials.username);
await page.getByLabel('Password').fill(credentials.password);
await page.getByRole('button', { name: 'Log in' }).click();
await page.waitForTimeout(8000);
await page.getByRole('button', { name: /Biology/ }).waitFor({ timeout: 120_000 });
await page.waitForTimeout(500);
await page.screenshot({ path: join(outDir, 'folder-list.png'), fullPage: true });

await page.getByRole('button', { name: /Biology/ }).click();
await page.getByRole('button', { name: /Study/ }).waitFor({ timeout: 30_000 });
await page.screenshot({ path: join(outDir, 'folder-inside.png'), fullPage: true });

await page.getByRole('button', { name: 'New card' }).click();
await page.getByText('Folder').waitFor();
await page.screenshot({ path: join(outDir, 'card-form-folder.png'), fullPage: true });
await page.getByRole('button', { name: 'Back' }).click();

await page.getByText('Select').click();
await page.getByRole('button', { name: /What is photosynthesis/ }).click();
await page.getByRole('button', { name: /Cell powerhouse/ }).click();
await page.screenshot({ path: join(outDir, 'card-selection.png'), fullPage: true });
await page.getByText('Cancel').click();

await page.getByRole('button', { name: /Study/ }).click();
await page.waitForTimeout(1000);
await page.getByRole('checkbox', { name: 'Shuffle' }).click();
await page.waitForTimeout(400);
await page.screenshot({ path: join(outDir, 'study-shuffle.png'), fullPage: true });

await browser.close();
console.log('Screenshots saved to', outDir);
