# Troubleshooting

Every failure mode encountered building real hero videos, with the root cause and fix. Read this when something isn't working — chances are it's already here.

## The render hangs forever (no frames captured)

**Symptom**: `node export/render.js` starts, waits past `__ready` detection, then sits with 0 frames in the `frames/` directory. Chromium processes pile up.

**Root cause**: the GSAP timeline was constructed in a playing state, then you called `.pause()` from the render script. Headless Chrome stops ticking paint on a paused tab and `page.screenshot()` hangs waiting for a frame that never comes.

**Fix**: detect render mode via URL query param and construct the timeline paused from the start.

```js
const params = new URLSearchParams(location.search);
const renderMode = params.has('render');
const tl = gsap.timeline({
  paused: renderMode,    // <-- construct paused, never call .pause() later
  repeat: renderMode ? 0 : -1,
  // ...
});
```

Then render.js points at `file://…/demo/index.html?render=1` — the timeline is paused, Playwright seeks it frame by frame, and `page.screenshot()` returns immediately.

## Every frame is identical (the animation doesn't advance)

**Symptom**: all captured PNGs show frame 0. The loop runs but `__timeline.seek()` doesn't take effect.

**Root causes, in order of likelihood**:

1. **`window.__timeline` isn't exposed** — check the HTML script assigns it BEFORE setting `window.__ready = true`.
2. **Seek is suppressing events** — `timeline.seek(t, true)` suppresses callbacks (label changes, text swaps). Use `timeline.seek(t, false)` or `timeline.seek(t)`.
3. **The page isn't fully loaded** — add `await page.waitForTimeout(250)` after `waitForFunction(__ready)` to let fonts + CSS settle.

## Screenshot is blank or half-rendered

**Symptom**: early frames are all-white; later frames show partial content.

**Root cause**: Fonts hadn't finished loading when rendering started. Text reflows mid-capture.

**Fix**: await `document.fonts.ready` before setting `window.__ready = true`:

```js
function start() {
  buildTimeline();
  window.__ready = true;
}

if (document.readyState === 'complete') {
  document.fonts.ready.then(start);   // <-- critical
} else {
  window.addEventListener('load', () => document.fonts.ready.then(start));
}
```

Also load fonts via `<link>` tags at the top of `<head>`, not via CSS `@import` (slower).

## Content is clipped / only part of the card shows

**Symptom**: transcript has 4 lines but only 3 render. Card body looks emptier than expected. Summary bullets get cut off.

**Root cause**: you stacked views as `flex: 1` siblings inside a flex-column container. Every view takes `1/N` of the available height — even views with `opacity: 0`. Content that doesn't fit in that 1/N slot gets clipped by `overflow: hidden` on the card.

**Fix**: stack views with `position: absolute; inset: 0;` inside a relative-positioned `card-body`. Every view gets the FULL body area, only opacity controls visibility.

```html
<div class="card-main">
  <div class="main-header">…</div>
  <div class="card-body">
    <div class="view view-a">…</div>
    <div class="view view-b">…</div>
    <div class="view view-c">…</div>
  </div>
</div>
```

```css
.card-body { position: relative; flex: 1; min-height: 0; }
.view      { position: absolute; inset: 0; opacity: 0; display: flex; flex-direction: column; }
```

## Cursor lands 50px off the button it's supposed to click

**Symptom**: the cursor hovers above / below / beside the target button. Click animation fires on empty space.

**Root cause**: hard-coded pixel coordinates for the cursor's destination. The actual button position depends on text content, font metrics, padding, and whatever else — you can't eyeball it.

**Fix**: measure the target at runtime using `getBoundingClientRect()` relative to the stage origin.

```js
function measureTargets() {
  const stage = document.getElementById('stage');
  const stageRect = stage.getBoundingClientRect();
  function center(el) {
    const r = el.getBoundingClientRect();
    return {
      x: r.left - stageRect.left + r.width / 2,
      y: r.top - stageRect.top + r.height / 2,
    };
  }
  window.__targets = {
    btn: center(document.getElementById('my-button'))
  };
}
```

Then in the timeline, offset by `(-4, -3)` so the cursor SVG's tip (not its top-left corner) lands on the center:

```js
tl.to('#cursor', { x: target.x - 4, y: target.y - 3, duration: 1.0 }, 6.0);
```

**If the target container animates in** (e.g. email card slides in before you click its send button), the starting position differs from the final. Re-measure after the container's entrance completes:

```js
tl.call(() => {
  const stage = document.getElementById('stage').getBoundingClientRect();
  const btn = document.getElementById('send-btn').getBoundingClientRect();
  window.__targets.send = {
    x: btn.left - stage.left + btn.width/2,
    y: btn.top  - stage.top  + btn.height/2
  };
}, null, 26.35);

// Then use function syntax in the tween so GSAP re-reads at tween-start
tl.to('#cursor', {
  x: () => window.__targets.send.x - 4,
  y: () => window.__targets.send.y - 3,
  duration: 0.95
}, 26.50);
```

## MP4 won't play on iPhone / Safari

**Symptom**: video plays on desktop Chrome/Firefox but shows a broken video icon on iOS Safari.

**Root cause**: ffmpeg encoded with a pixel format iOS doesn't support, or didn't put the `moov` atom at the front of the file so Safari can't start playing until the full file downloads.

**Fix**: ensure these two ffmpeg flags are present:

```bash
ffmpeg -y -framerate 60 -i frames/%04d.png \
  -c:v libx264 \
  -pix_fmt yuv420p \          # <-- iOS-compatible pixel format
  -crf 18 -preset slow \
  -movflags +faststart \      # <-- moov atom at start for streaming
  out/hero.mp4
```

## File size is huge

**Symptom**: an 8-second 4K video is 20+ MB. Unacceptable for landing page.

**Root causes + fixes**:

- **CRF too low**: CRF 18 is near-lossless. Bump to CRF 22–24 for much smaller files at imperceptibly lower quality.
- **Encoding 4K when 1080p is enough**: landing videos usually display in a ~1200px container. 1080p is plenty. Set `deviceScaleFactor: 1` in Playwright.
- **Encoding at 60fps when 30fps is enough**: for UI motion that's mostly fades + slides, 30fps looks nearly identical and halves file size. Change FPS constant in render.js and the `-framerate` flag in encode.sh.
- **Not using WebM**: VP9 is ~40% smaller than H.264 at the same quality. Use it as the primary source with `<video>`:

```html
<video autoplay muted loop playsinline>
  <source src="/hero.webm" type="video/webm">
  <source src="/hero.mp4" type="video/mp4">
</video>
```

Safari will fall back to MP4; Chrome/Firefox use WebM.

## Text has a subtle flicker during typing reveal

**Symptom**: characters flicker in/out during a clip-path reveal, especially on thin stroke weights.

**Root cause**: sub-pixel rounding in the clip-path at render time.

**Fix**: use `ease: 'none'` for clip-path tweens (linear progress = no sub-pixel lurches) and ensure the element has `will-change: clip-path` or `transform`:

```js
tl.to('.line-text', {
  clipPath: 'inset(0 0% 0 0)',
  duration: 0.5,
  ease: 'none'
}, 4.0);
```

```css
.line-text {
  clip-path: inset(0 100% 0 0);
  will-change: clip-path;
}
```

## Loop is jarring / noticeable jump

**Symptom**: live-preview loop replays but frame N visually differs from frame 0 — the jump is jarring.

**Fix**: at the end of the timeline, fade or reset to match frame 0's state. The simplest seamless loop is to fade everything back to empty:

```js
// Frame 0: card opacity 0, everything hidden
// Frame N-1: card opacity 1, transcript full, etc.
// Add a final fade at frame N to match frame 0:

tl.to('#card-main', { opacity: 0, duration: 0.3 }, DURATION - 0.3);
tl.call(() => {
  // Also reset any mutated text content
  document.getElementById('main-label').textContent = 'Listening';
  // ...
}, null, DURATION);
```

Better: add a `repeatDelay: 0.8` so there's a breath between loops, making the restart feel intentional.

## Render works on local machine but CI fails

**Symptom**: `node export/render.js` works on your laptop but hangs or times out on GitHub Actions / Linux CI.

**Root causes**:
- Chromium dependencies missing → `sudo apt install -y libnss3 libatk-bridge2.0-0 libcups2 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxrandr2 libgbm1 libpango-1.0-0 libcairo2 libasound2`
- Or simpler: `npx playwright install --with-deps chromium` installs Chromium AND its system dependencies in one command
- No DISPLAY and some Linux builds need Xvfb: `xvfb-run node export/render.js`

## The animation looks fine but doesn't "land" visually

Less a bug, more a critique. If the video feels flat despite correct mechanics:

- **Scenes are too short**: below 2s per scene, the viewer can't register what happened. Extend holds.
- **Easing is wrong**: `linear` everywhere feels robotic; `power3.out` everywhere feels samey. Vary: `power2.out` for entries, `power3.inOut` for transitions, `back.out(1.5)` for popping-in items, `none` for progress bars and typing.
- **No camera zoom on key moments**: a subtle `scale: 1 → 1.03` on the stage toward the clicked button makes the click moment land. Without it, clicks feel invisible.
- **Everything at the same scale**: hierarchy of size matters. Labels 56px, body 24-28px, meta/mono 13-16px. If everything is 20px, nothing is special.

Read `gsap-patterns.md` for the idioms that fix these.
