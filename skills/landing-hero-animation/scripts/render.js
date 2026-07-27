/**
 * Playwright frame capture for landing-hero-animation.
 *
 * Usage:
 *   node export/render.js
 *
 * Must be run from the project root. Paths below are relative to that.
 *
 * Tune DURATION_SECONDS to match your timeline's total length.
 * Tune DEVICE_SCALE_FACTOR:
 *   1 = 1080p output (1920×1080)
 *   2 = 4K output (3840×2160)
 */

import { chromium } from 'playwright';
import { mkdirSync, readdirSync, rmSync, existsSync } from 'node:fs';
import { join } from 'node:path';

// ──────────────────────────────────────────────────────────────
// Configuration — adjust to your project
// ──────────────────────────────────────────────────────────────

const HTML_URL             = 'file://' + process.cwd() + '/demo/index.html?render=1';
const FRAMES_DIR           = 'export/frames';
const FPS                  = 60;
const DURATION_SECONDS     = 8.0;                            // ← total timeline length in seconds
const TOTAL_FRAMES         = Math.round(DURATION_SECONDS * FPS);
const VIEWPORT             = { width: 1920, height: 1080 };
const DEVICE_SCALE_FACTOR  = 2;                              // 1 = 1080p, 2 = 4K

// ──────────────────────────────────────────────────────────────

async function main() {
  const start = Date.now();

  // Ensure frames dir exists and is empty
  if (existsSync(FRAMES_DIR)) {
    for (const f of readdirSync(FRAMES_DIR)) {
      if (f.endsWith('.png')) rmSync(join(FRAMES_DIR, f), { force: true });
    }
  } else {
    mkdirSync(FRAMES_DIR, { recursive: true });
  }

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: VIEWPORT,
    deviceScaleFactor: DEVICE_SCALE_FACTOR,
  });
  const page = await context.newPage();

  await page.goto(HTML_URL);

  // Wait for window.__ready (set by the HTML once fonts load + timeline builds)
  await page.waitForFunction(() => window.__ready === true, null, { timeout: 30000 });
  await page.waitForTimeout(250); // Let fonts + CSS settle one more tick

  for (let i = 0; i < TOTAL_FRAMES; i++) {
    const t = i / FPS;

    // Seek + force layout. DO NOT use requestAnimationFrame to wait —
    // it doesn't fire reliably on a paused page in headless Chrome.
    await page.evaluate((seconds) => {
      window.__timeline.seek(seconds, false);
      void document.body.offsetHeight; // force style recalc + layout
    }, t);

    const path = `${FRAMES_DIR}/${String(i).padStart(4, '0')}.png`;
    await page.screenshot({ path, omitBackground: false });

    if ((i + 1) % 30 === 0) {
      console.log(`[${i + 1}/${TOTAL_FRAMES}] captured (t=${t.toFixed(2)}s)`);
    }
  }

  await browser.close();

  const elapsed = ((Date.now() - start) / 1000).toFixed(2);
  console.log(`Done. Captured ${TOTAL_FRAMES} frames in ${elapsed}s.`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
