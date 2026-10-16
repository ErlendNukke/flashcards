/**
 * Measures frame times while scrolling the welcome page (release web).
 * Chrome iPhone emulation + CPU throttling; wheel events on Flutter canvas.
 */
import { chromium, devices } from 'playwright';
import { writeFileSync, mkdirSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const webBase = process.env.WEB_BASE_URL || 'http://localhost:8088';
const cpuThrottle = Number(process.env.CPU_THROTTLE_RATE || '4');
const outFile = process.env.PROFILE_OUT || '';

const browser = await chromium.launch({
  headless: true,
  args: ['--enable-unsafe-swiftshader'],
});
const context = await browser.newContext({
  ...devices['iPhone 13'],
  baseURL: webBase,
});
const page = await context.newPage();
const cdp = await context.newCDPSession(page);
await cdp.send('Emulation.setCPUThrottlingRate', { rate: cpuThrottle });

await page.addInitScript(() => {
  localStorage.setItem('flutter.flashcards_device_id', JSON.stringify('profile-device'));
  localStorage.removeItem('flutter.flashcards_token');
  localStorage.removeItem('flutter.flashcards_user');
});

await page.goto('/', { waitUntil: 'domcontentloaded' });
await page.getByRole('button', { name: 'Sign up' }).waitFor({ timeout: 120_000 });
await page.waitForTimeout(1500);

const sampleMs = Number(process.env.PROFILE_DURATION_MS || '4000');

const [stats] = await Promise.all([
  page.evaluate(async (duration) => {
    const deltas = [];
    let last = performance.now();
    const end = last + duration;
    while (performance.now() < end) {
      await new Promise((r) => requestAnimationFrame(r));
      const now = performance.now();
      deltas.push(now - last);
      last = now;
    }
    const sorted = deltas.filter((d) => d > 0 && d < 200).sort((a, b) => a - b);
    const sum = sorted.reduce((a, b) => a + b, 0);
    const median = sorted[Math.floor(sorted.length / 2)] ?? 0;
    const p95 = sorted[Math.floor(sorted.length * 0.95)] ?? 0;
    const over16 = sorted.filter((d) => d > 16.7).length;
    return {
      sampleCount: sorted.length,
      avgFrameMs: sorted.length ? sum / sorted.length : 0,
      medianFrameMs: median,
      p95FrameMs: p95,
      framesOver16ms: over16,
      framesOver16Pct: sorted.length ? (over16 / sorted.length) * 100 : 0,
      estimatedFps: median > 0 ? 1000 / median : 0,
    };
  }, sampleMs),
  (async () => {
    const steps = Math.ceil(sampleMs / 32);
    for (let i = 0; i < steps; i++) {
      await page.mouse.wheel(0, i % 2 === 0 ? 48 : -40);
      await page.waitForTimeout(16);
    }
  })(),
]);

const renderer = await page
  .evaluate(() => {
    const builds = window._flutter?.buildConfig?.builds;
    if (builds?.length) {
      return builds.map((b) => `${b.compileTarget}/${b.renderer}`).join(',');
    }
    return 'unknown';
  })
  .catch(() => 'unknown');

await browser.close();

const result = {
  label: process.env.PROFILE_LABEL || 'run',
  cpuThrottleRate: cpuThrottle,
  device: 'iPhone 13 emulation (Playwright)',
  rendererHint: renderer,
  sampleDurationMs: sampleMs,
  ...stats,
};

const json = JSON.stringify(result, null, 2);
console.log(json);
if (outFile) {
  mkdirSync(dirname(outFile), { recursive: true });
  writeFileSync(outFile, json);
}
