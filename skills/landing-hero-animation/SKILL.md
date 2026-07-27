---
name: landing-hero-animation
description: Generate pixel-perfect, brand-accurate product demo / hero animation videos (MP4 + WebM) to embed on landing pages. Build as HTML + CSS + GSAP timeline, render via Playwright headless Chrome, encode with ffmpeg. Use whenever the user wants a hero video, product walkthrough video, feature demo clip, onboarding GIF, landing-page animation, interactive product storyboard, or any "UI in motion" video — even if they don't explicitly say "skill." Also use when the user describes a multi-scene storyboard with timings, wants a seamless loop, or references tools like Linear/Granola/Arc/Framer-quality landing animations. Do NOT use for photorealistic/cinematic video (use an AI video API like Higgsfield or Runway instead) — this skill is for deterministic UI motion only.
---

# Landing Hero Animation

Builds embeddable product-demo videos for landing pages. The output is a real MP4 (+ WebM) captured frame-by-frame from a coded HTML/CSS/GSAP animation — so colors, typography, timings, and motion are exact. No AI video guessing.

## When to use this skill

Use for: landing hero videos, feature showcase clips, product walkthrough demos, onboarding animations, "how it works" sequences, interactive UI storyboards, Linear/Granola/Arc-style landing motion, or any user request for a "short video explaining what the product does."

Do NOT use for: photorealistic scenes, film-style cinematography, brand hero films with people/environments. Those belong to AI video APIs (Higgsfield, Runway, Kling). This skill renders DOM — it does UI motion perfectly and photorealism not at all.

## Core principle — why HTML, not AI video

Product demos are *UI in motion*: cards, typography, progress bars, cursors, transitions. AI video models render photography, not interfaces — they produce garbled text, wrong hex colors, and drifting layouts. A coded animation:
- Gets pixel-perfect brand tokens (exact `#5B9AFF`, exact `Instrument Serif`)
- Animates at an honest 60 fps via `requestAnimationFrame`-driven tweens
- Produces deterministic output (re-rendering a million times gives the same result)
- Embeds on the landing page as a live DOM component OR exports as MP4

The tradeoff: you write real animation code. GSAP makes this tractable — one timeline, labeled scenes, declarative tweens.

## Prerequisites

Check and install if missing. See `references/installation.md` for detailed per-OS instructions.

```bash
# macOS (one-shot)
brew install ffmpeg node
# Linux (Debian/Ubuntu)
sudo apt install ffmpeg nodejs npm
```

Node ≥ 18. ffmpeg ≥ 6 (for libvpx-vp9 and libx264). Verify:

```bash
node --version && ffmpeg -version | head -1
```

Playwright is installed per-project in the setup step below.

## Workflow

### 1. Gather requirements from the user

Ask explicitly (don't guess):
- **Product / concept** — what the video is about, in 1–3 sentences
- **Storyboard** — scene-by-scene with timings, or "you decide the breakdown"
- **Brand tokens** — background, text, accent colors (hex), font families, any logo mark. If the user has a landing repo, check `tailwind.config.*`, `src/styles/globals.css`, or `:root` CSS custom properties and *confirm* — never infer tokens silently.
- **Duration** — 8s for a teaser, 15–25s for standard, 30–40s for full product tour
- **Format** — MP4 only, or MP4 + WebM, or also a live React component
- **Resolution** — 1080p is fine for landing embed; bump to 4K (`deviceScaleFactor: 2`) for retina-crisp and when the video is shown large

### 2. Brainstorm scenes

The storyboard drives everything. Write scene-by-scene with exact timings:

```
0.0–2.2  Sources       — user picks input (mic, upload, etc.)
2.2–5.0  Listening     — waveform animates, timer counts up
5.0–7.2  Stop          — cursor clicks Stop button
7.2–10.5 Processing    — steps tick off, progress bar fills
...
```

Include pauses (0.3–0.6s holds between scenes) so the viewer can register what happened. "Rushed" is the #1 cause of a demo that feels like noise.

### 3. Scaffold the project

```
project-root/
├── demo/
│   └── index.html              # single file, GSAP from CDN
├── export/
│   ├── render.js               # Playwright frame capture
│   ├── encode.sh               # ffmpeg
│   └── package.json            # playwright dep
├── out/                        # MP4 + WebM land here (gitignored)
└── .gitignore                  # ignore out/, export/frames/, export/node_modules/
```

Copy the starter files from this skill's `assets/` and `scripts/` directories:
- `assets/template.html` → `demo/index.html`
- `scripts/render.js` → `export/render.js`
- `scripts/encode.sh` → `export/encode.sh`
- `scripts/package.json.template` → `export/package.json`

Then install Playwright:
```bash
cd export && npm install && npx playwright install chromium
```

### 4. Build the HTML animation

Open `demo/index.html` and:

1. Replace the CSS custom properties in `:root` with the user's brand tokens
2. Replace the HTML body with your scene structure (source pills, main card, views, etc.)
3. Write the GSAP timeline in the script block — one `gsap.timeline()` with all scenes labeled

The template already handles the two non-obvious pieces you'd otherwise get wrong:
- `?render=1` query param → timeline starts paused (required for frame capture — see troubleshooting)
- Exposes `window.__timeline` and `window.__ready` (required for Playwright)

See `references/gsap-patterns.md` for timeline patterns (view crossfades, character-typing via clip-path, cursor choreography, camera zoom). Read this BEFORE writing the timeline — it teaches idioms that prevent common mistakes.

### 5. Iterate in the browser

Preview live-reload style:
```bash
python3 -m http.server 8000 --directory demo
# open http://localhost:8000/
```

Watch it loop 2–3 times. Fix:
- Timing (scenes feel rushed or dragging)
- Easings (motion feels linear / snappy / off)
- Layout (content clipped, too much free space, elements overflow)

~70% of total effort lives here. Only proceed to render once the live preview is correct.

### 6. Render to MP4

```bash
cd project-root
node export/render.js     # captures 480/1800/2280+ PNG frames
bash export/encode.sh     # produces out/hero.mp4 + .webm
open out/hero.mp4
```

At 60 fps: 8s = 480 frames, 30s = 1800 frames, 38s = 2280 frames. Render time is roughly 5× video length at 1920×1080, ~8–10× at 4K.

## Rules that prevent the most common mistakes

Read `references/troubleshooting.md` for full explanations. The short version:

1. **Start the GSAP timeline paused via constructor option for render mode** — never call `timeline.pause()` after playing. Headless Chrome stops ticking paint on a paused timeline, which makes `page.screenshot()` hang forever. Detect render mode via URL query param (`?render=1`).

2. **Don't use `requestAnimationFrame` to wait for a frame in Playwright** — rAF doesn't fire reliably on a paused page in headless mode. Use `page.waitForTimeout(8)` after forcing a layout flush (`void document.body.offsetHeight`).

3. **Stack views with `position: absolute; inset: 0;`** inside a shared `.card-body` container. If you use `flex: 1` siblings, every view takes 1/Nth of the card height whether visible or not — content gets clipped and you waste screen space.

4. **Measure cursor targets at runtime.** Hard-coding `(x, y)` for button clicks is fragile and almost always wrong by 30–80 pixels. Use `getBoundingClientRect()` relative to the stage origin, run once after fonts load. Re-measure if a container animates in (the button's final position differs from its starting one).

5. **Camera "get closer" effect for click moments.** Set `transform-origin` on the stage to the target element's center, then tween `scale` 1 → 1.03–1.08 over ~0.7s. Combined with a hover scale on the button (`1 → 1.05`), this makes click moments land.

6. **Stage dimensions are fixed pixels; responsive is a CSS transform.** Use `.stage { width: 1920px; height: 1080px; }` and a media query that scales the whole stage via `transform: scale(calc(100vw / 1920))` for preview at smaller viewports. Playwright renders at exactly 1920×1080 so nothing is scaled in the export.

7. **For 4K output**, set `deviceScaleFactor: 2` in the Playwright context. You don't need to change the HTML — the DOM stays at 1920×1080 logical, Playwright takes 3840×2160 screenshots.

8. **Reset state at the end of the timeline** if the animation is meant to loop (live preview). Infinite loop only looks seamless if `t = duration` visually equals `t = 0`.

## Scene structure — the template that works

Every well-pacing demo follows this pattern:

| Moment | Duration | Purpose |
|--------|----------|---------|
| Entry | 0.3–0.7s | Element fades in with slight translate or scale |
| Hold | 0.2–0.5s | Let the viewer register what appeared |
| Action | 0.5–1.5s | The actual motion the scene exists to show |
| Resolution | 0.3–0.6s | Result lands, subtle settle |
| Transition | 0.3–0.5s | Crossfade to next scene |

Short scenes feel rushed. Long scenes feel padded. 2–4 seconds is the sweet spot.

## Brand token intake — the shortcut

If the user points at their landing repo, look for:
- `tailwind.config.*` — `theme.extend.colors`
- `src/app/globals.css` or `src/styles/*.css` — `:root { --<token>: <value>; }`
- `src/components/` — any existing Card/Button component for shadow + border-radius conventions

Match them verbatim. Never approximate hex codes ("close to #5B9AFF" is a design smell). Fonts: load the exact Google Font or self-hosted asset the landing uses.

## Output spec

- **MP4**: H.264, yuv420p, CRF 18, preset slow, `+faststart` flag — universally playable, small file, good quality
- **WebM**: VP9, CRF 30, `b:v 0`, row-mt — smaller than MP4 at similar quality; serve both via `<video>` `<source>` tags

Sizes at 1080p: ~500 KB for 8s, ~2 MB for 30s. At 4K: ~2 MB for 8s, ~5 MB for 30s.

## Troubleshooting quick reference

| Symptom | Fix |
|---------|-----|
| Playwright hangs at frame 0 | Timeline wasn't paused from construction → add `paused: true` to `gsap.timeline()` when `?render=1` |
| Screenshots all identical | `window.__timeline.seek()` not being called → check the render script |
| Some content clipped / missing | Views stacking via `flex: 1` → switch to `position: absolute; inset: 0;` |
| Cursor lands 50px off target | Hard-coded coords → use `getBoundingClientRect()` at runtime |
| Text garbled / wrong font | Font not loaded before render → await `document.fonts.ready` before setting `window.__ready = true` |
| MP4 won't play on iOS | Missing `yuv420p` + `+faststart` in ffmpeg args |

Full detail in `references/troubleshooting.md`.

## References

- `references/installation.md` — ffmpeg, Node, Playwright per-OS install
- `references/gsap-patterns.md` — timeline idioms (view swaps, typing reveal, cursor choreography, camera zoom, loop reset)
- `references/troubleshooting.md` — every footgun encountered in production, explained
- `assets/template.html` — boilerplate HTML with render-mode toggle, CSS token structure, and a 2-scene starter timeline
- `scripts/render.js` — Playwright capture (480+ frames, force layout, progress logs)
- `scripts/encode.sh` — ffmpeg H.264 + VP9 encoder
- `scripts/package.json.template` — minimal Node package for the export pipeline
