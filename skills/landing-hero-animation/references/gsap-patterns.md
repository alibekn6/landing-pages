# GSAP Timeline Patterns

Idioms for the most common animation patterns in hero demo videos. Copy-adapt these rather than inventing from scratch — they're battle-tested against the headless-Chrome rendering pipeline.

## Table of contents

1. [Timeline construction (with render-mode toggle)](#timeline-construction)
2. [View crossfades (one visible at a time)](#view-crossfades)
3. [Label swaps between scenes](#label-swaps)
4. [Text typing reveal via clip-path](#text-typing-reveal)
5. [Cursor choreography (move + click)](#cursor-choreography)
6. [Camera zoom toward an element](#camera-zoom)
7. [Staggered entrance for lists](#staggered-entrance)
8. [Progress bar fill](#progress-bar-fill)
9. [Speaker-label strike-through + rename](#strike-through-rename)
10. [Live pulsing / EQ bars](#pulsing-eq-bars)
11. [Waveform / SVG path animation](#waveform-path)
12. [Loop reset at end of timeline](#loop-reset)

---

## Timeline construction

Always construct the timeline in the correct state for render vs. live. This single pattern prevents the #1 rendering bug (page.screenshot hangs on paused timelines).

```js
function buildTimeline() {
  const params = new URLSearchParams(location.search);
  const renderMode = params.has('render');
  const tl = gsap.timeline({
    repeat: renderMode ? 0 : -1,        // loop live, single pass for render
    repeatDelay: renderMode ? 0 : 0.8,
    paused: renderMode,                  // CRITICAL: start paused in render mode
    defaults: { ease: 'power3.out' }
  });
  window.__timeline = tl;
  return tl;
}
```

**Why**: If you create a playing timeline and call `.pause()` later, headless Chrome stops ticking paint on that tab. `page.screenshot()` hangs forever. Always construct with `paused: true` when `?render=1`.

---

## View crossfades

Scenes often share a container (e.g. a main card) but show different content. Stack the views with absolute positioning and control visibility via opacity.

```html
<div class="card-body">
  <div class="view" id="view-intro">…scene 1 content…</div>
  <div class="view" id="view-transcript">…scene 2 content…</div>
  <div class="view" id="view-summary">…scene 3 content…</div>
</div>
```

```css
.card-body { position: relative; flex: 1; min-height: 0; }
.view      { position: absolute; inset: 0; opacity: 0; display: flex; flex-direction: column; }
```

```js
// Scene 1 → Scene 2
tl.to('#view-intro',      { opacity: 0, duration: 0.4 }, 3.0);
tl.to('#view-transcript', { opacity: 1, duration: 0.4 }, 3.3);

// Scene 2 → Scene 3
tl.to('#view-transcript', { opacity: 0, duration: 0.4 }, 8.0);
tl.to('#view-summary',    { opacity: 1, duration: 0.4 }, 8.3);
```

**Why absolute, not flex**: if views are `flex: 1` siblings, each takes `1/N` of the available height even when opacity 0, and content gets clipped. Absolute stacking gives every view the full body area.

---

## Label swaps

Header label changes per scene. Don't overlap the old and new text — fade out, swap content, fade in.

```js
// Fade old out
tl.to('#main-label', { opacity: 0, y: -6, duration: 0.22, ease: 'power2.in' }, 3.0);
// Change text mid-crossfade
tl.call(() => {
  document.getElementById('main-label').textContent = 'Transcribing';
}, null, 3.22);
// Fade new in from below
tl.fromTo('#main-label',
  { opacity: 0, y: 8 },
  { opacity: 1, y: 0, duration: 0.4, ease: 'power3.out' },
  3.22
);
```

---

## Text typing reveal

Fake the typing effect with `clip-path: inset(0 100% 0 0) → inset(0 0% 0 0)`. Reveals left-to-right without character splitting.

```css
.line-text { clip-path: inset(0 100% 0 0); }
```

```js
// One line, fast
tl.to('.line:nth-child(1) .line-text',
  { clipPath: 'inset(0 0% 0 0)', duration: 0.5, ease: 'none' },
  4.0);

// Multiple lines, staggered like they're being typed one by one
tl.to('.line:nth-child(1) .line-text', { clipPath: 'inset(0 0% 0 0)', duration: 0.5, ease: 'none' }, 4.0);
tl.to('.line:nth-child(2) .line-text', { clipPath: 'inset(0 0% 0 0)', duration: 0.5, ease: 'none' }, 4.3);
tl.to('.line:nth-child(3) .line-text', { clipPath: 'inset(0 0% 0 0)', duration: 0.5, ease: 'none' }, 4.6);
```

For a whole paragraph reveal (2–3 lines of flowing prose), use a longer duration:

```js
tl.to('#paragraph', { clipPath: 'inset(0 0% 0 0)', duration: 2.4, ease: 'power1.inOut' }, 22.0);
```

**Easing tip**: `none` feels like real typing. `power1.inOut` feels like a slow scan, good for long paragraphs.

---

## Cursor choreography

Move a cursor element toward a target and click. Measure the target's position at runtime — never hard-code coordinates.

```js
// At page init, measure the target button (done once, after fonts load)
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
    cta: center(document.getElementById('cta-button'))
  };
}
```

```js
// In the timeline: move to target, click
const cta = window.__targets.cta;

// Cursor starts off-stage bottom-right
gsap.set('#cursor', { x: 1820, y: 1000 });
tl.to('#cursor', { opacity: 1, duration: 0.25 }, 6.0);

// Glide to target. Offset by (-4, -3) so the cursor TIP lands on center,
// not the cursor's top-left corner.
tl.to('#cursor',
  { x: cta.x - 4, y: cta.y - 3, duration: 1.0, ease: 'power2.inOut' },
  6.05);

// Hover lift on the button as cursor approaches
tl.to('#cta-button',
  { scale: 1.05, boxShadow: '0 8px 24px rgba(0,0,0,0.18)', duration: 0.35 },
  6.75);

// Click press (button + cursor both dip)
tl.to('#cta-button', { scale: 0.94, duration: 0.10 }, 7.10);
tl.to('#cursor',     { scale: 0.82, duration: 0.10 }, 7.10);

// Release
tl.to('#cta-button', { scale: 1.05, duration: 0.16 }, 7.20);
tl.to('#cursor',     { scale: 1.00, duration: 0.16 }, 7.20);
```

**If the target container animates in**: re-measure after it settles. The final position of a button inside a card that slides in from the right will differ from its starting position.

```js
tl.call(() => {
  const r = document.getElementById('cta-button').getBoundingClientRect();
  const s = document.getElementById('stage').getBoundingClientRect();
  window.__targets.cta = { x: r.left - s.left + r.width/2, y: r.top - s.top + r.height/2 };
}, null, 6.0);

// Then use a function in the tween so GSAP re-reads at tween-start
tl.to('#cursor', {
  x: () => window.__targets.cta.x - 4,
  y: () => window.__targets.cta.y - 3,
  duration: 1.0, ease: 'power2.inOut'
}, 6.2);
```

---

## Camera zoom

The "getting closer" effect — zoom the whole stage toward a target element so the click moment feels intentional.

```js
const target = window.__targets.cta;

// Set transform-origin to the target's center BEFORE zooming
tl.set('#stage', { transformOrigin: `${target.x}px ${target.y}px` }, 6.0);
tl.to('#stage', { scale: 1.04, duration: 0.9, ease: 'power2.out' }, 6.2);

// …click happens here…

// Zoom back out after the click
tl.to('#stage', { scale: 1.0, duration: 0.5, ease: 'power2.inOut' }, 7.4);
```

Scale range: `1.02–1.08`. Anything beyond 1.1 feels jarring.

---

## Staggered entrance

For a row of pills, cards, or task items, let GSAP's `stagger` do the work.

```js
tl.to('.source', {
  opacity: 1, y: 0, scale: 1,
  duration: 0.7, ease: 'power3.out',
  stagger: 0.10  // 100ms between each element
}, 0.1);
```

For a `back.out` easing that feels like items popping in:

```js
tl.fromTo('.avatar-dot',
  { opacity: 0, scale: 0.5 },
  { opacity: 1, scale: 1, duration: 0.35, stagger: 0.08, ease: 'back.out(1.8)' },
  5.0);
```

---

## Progress bar fill

Animate the `width` property from a starting percentage to the target. Use `ease: 'none'` for a linear progress-bar feel.

```js
tl.to('#progress-fill', { width: '40%', duration: 0.85, ease: 'power2.out' }, 1.9);
tl.to('#progress-fill', { width: '75%', duration: 1.6, ease: 'none' }, 2.85);
tl.to('#progress-fill', { width: '100%', duration: 0.4, ease: 'power2.out' }, 6.8);
```

---

## Strike-through rename

For renaming a label (e.g. "S1" → "Aidar") with a strike-through animation:

```html
<span class="label">
  <span class="old">S1</span>
  <span class="new" style="position:absolute; top:0; left:0; opacity:0;">Aidar</span>
  <span class="strike" style="position:absolute; left:0; top:50%; height:2.5px; width:0%; background:#5B9AFF;"></span>
</span>
```

```js
// Strike draws over "S1"
tl.to('.label .strike', { width: '120%', duration: 0.50, ease: 'power3.out' }, 17.2);

// "S1" fades out as "Aidar" rises in (crossfade)
tl.to('.label .old',    { opacity: 0, y: -8, duration: 0.32 }, 17.95);
tl.to('.label .new',    { opacity: 1, y:  0, duration: 0.45, ease: 'power3.out' }, 18.05);

// Strike fades out after the rename
tl.to('.label .strike', { opacity: 0, duration: 0.35, ease: 'power2.in' }, 18.25);
```

Pair with a zoom-in on the line being renamed (see camera zoom) so the moment lands.

---

## Pulsing EQ bars

Waveform bars with randomized height pulses — simulates live audio.

```css
.waveform { display: flex; gap: 6px; height: 140px; }
.waveform .bar { flex: 1; background: var(--accent); border-radius: 3px; min-height: 6px; }
```

```js
const waveformAnim = gsap.to('.waveform .bar', {
  scaleY:  () => 0.35 + Math.random() * 0.95,
  opacity: () => 0.55 + Math.random() * 0.45,
  duration: () => 0.20 + Math.random() * 0.30,
  ease: 'sine.inOut',
  yoyo: true,
  repeat: -1,
  stagger: { amount: 0.4, from: 'random' },
  paused: true                    // start paused so we control when it begins
});

// In the main timeline, kick it off via .call:
tl.call(() => waveformAnim.play(),  null, 2.7);

// Later, pause it (e.g. when recording stops):
tl.call(() => waveformAnim.pause(), null, 7.2);
```

Set `transform-origin: 50% 50%` on `.bar` so scale grows from the vertical center, not the top.

---

## Waveform (static SVG)

For a scrubber/timeline waveform that doesn't animate, use an SVG path with a sine-y wiggle:

```html
<svg viewBox="0 0 800 36" preserveAspectRatio="none">
  <path d="M0,18 Q10,12 20,18 T40,18 T60,18 …"
        stroke="#5B9AFF" stroke-width="1.2" fill="none"/>
</svg>
```

Use `preserveAspectRatio="none"` to stretch the waveform to the container width (crisp at any scrubber length).

---

## Loop reset

Infinite loops only feel seamless if the final frame matches the initial frame. At the end of the timeline, reset any state that was mutated.

```js
tl.call(() => {
  // Text content that was swapped during the timeline
  document.getElementById('main-label').textContent = 'Intro';
  document.querySelectorAll('.correction').forEach(el => { el.textContent = el.dataset.wrong; });

  // Infinite sub-tweens (pulsing, rotation) that were started by .call
  waveformAnim.pause();  waveformAnim.progress(0);
  spinnerRot.pause();    spinnerRot.progress(0);

  // Static elements that were modified
  gsap.set('.source', { borderColor: '#E7E7EC', boxShadow: 'none' });
  gsap.set('.label .new', { opacity: 0 });
  gsap.set('.label .old', { opacity: 1 });
  gsap.set('.strike', { width: '0%', opacity: 1 });
}, null, TOTAL_DURATION);

tl.to({}, { duration: 0.01 }, TOTAL_DURATION);  // anchor the end
```

If the animation is one-shot (like a 30s product video on a landing page), you don't need this. If it loops (hero banner that replays indefinitely), you do.

---

## Scene cheatsheet

For a typical product-demo scene, the rhythm is:

```
0.0s  element fades in        (entry, 0.3–0.6s)
0.5s  holds                   (pause, 0.2–0.4s)
0.8s  the-thing-happens       (action, 0.5–1.2s)
2.0s  settles                 (resolution, 0.2–0.5s)
2.5s  cross-fade to next view (transition, 0.3–0.5s)
```

Under 2s per scene → feels rushed. Over 5s → feels padded. 2.5–4s is the sweet spot for most moments.
