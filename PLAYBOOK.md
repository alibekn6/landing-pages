# The Landing Page Playbook

How I go from a one-line brief to a landing page (or product demo) that people
ask about. The process is a fixed sequence of passes, each powered by a Claude
Code skill. Skills without process produce pretty fragments; process without
skills produces generic pages. You need both.

**The short version:**

1. Never start with code. Start with audience, use case, and brand personality.
2. Commit to ONE extreme aesthetic direction. Timid design reads as AI slop.
3. Build the foundation first: a modular type scale and an OKLCH palette.
4. Structure the page before styling sections. Hero headline: two lines, max.
5. Build with a style skill driving, not from memory.
6. Motion pass and polish pass are separate steps, in that order, at the end.
7. Run the anti-slop checklist before calling anything done.

---

## Step 0 — The context gate

Do not design anything until you can answer three questions:

- **Who is the audience?** (developers? founders? enterprise buyers?)
- **What is the use case?** (convert? explain? impress at a demo day?)
- **What is the brand personality?** (clinical? warm? tactical? luxurious?)

The `frontend-design` skill enforces this as a hard gate, and it is right to.
Every generic AI-looking page I have seen skipped this step. If the client or
brief can't answer, decide yourself and write it down — but never infer it
silently from the codebase.

## Step 1 — Pick a direction and commit

One project, one direction, dialed to 11. Half-committed aesthetics are the #1
AI tell. Pick the style skill that matches the feel you want:

| You want it to feel like…                | Skill                     | Signature moves                                                        |
| ---------------------------------------- | ------------------------- | ---------------------------------------------------------------------- |
| A calm, premium document (Notion, Linear) | `minimalist-ui`           | Warm monochrome, editorial serif headlines, flat 1px-border bento      |
| A $150k agency build                      | `high-end-visual-design`  | Glass / editorial-luxury / soft-structuralism archetypes, double-bezel cards |
| An award-site motion showcase             | `gpt-taste`               | AIDA structure, pinned + scrubbed GSAP scroll, inline images in headings |
| A machine manual / tactical HUD           | `industrial-brutalist-ui` | Swiss print or CRT telemetry, zero border-radius, hazard red           |
| Whatever the brief actually needs (default) | `design-taste-frontend` | Reads the brief, picks a real design system, brutal anti-slop pre-flight |
| An Apple product                          | `apple-design`            | Springs over transitions, gesture physics, interruptible motion        |

Two situational extras: `image-to-code` when image generation is available
(generate the design as images first, then implement them faithfully), and
`stitch-design-taste` when driving Google Stitch.

## Step 2 — Foundation: type and color before anything else

**Typography** (skills: `better-typography`, `frontend-design`):

- One modular scale, one ratio: 1.25, 1.333, or 1.5. Fluid sizes via `clamp()`.
- Never Inter/Roboto/Open Sans/Arial. My swaps: Instrument Sans, Plus Jakarta
  Sans, Outfit, Geist, Satoshi; editorial serif accents from Newsreader or
  Instrument Serif when the direction calls for it.
- Headings: line-height ~1.1, tracking around −0.02em. Body: 1.5–1.6, neutral
  tracking, measure capped at 65ch.
- `text-wrap: balance` on headings, `pretty` on descriptions.
- `font-synthesis: none`, `.woff2` only, real weights (a variable font with a
  650 weight beats faked bold).

**Color** (skill: `better-colors`):

- OKLCH only. Every neutral is tinted with the brand hue at chroma 0.01 —
  `oklch(95% 0.01 250)` instead of dead gray.
- Never pure `#000` or `#fff`. Dark surfaces start at `oklch(15%…)`.
- Palettes are generated, not hand-picked: spread lightness evenly across
  steps, keep the same chroma *percentage* (not absolute chroma) across hues.
- Fix contrast with lightness alone; chroma and hue barely move the needle.
- Dark mode is derived by reversing the lightness ramp, not designed twice.

**Spacing:** a 4pt base scale (4/8/12/16/24/32/48/64/96). Any 13px gap that is
not on the scale will read as sloppy at squint distance.

## Step 3 — Structure the page

I structure marketing pages as AIDA (skill: `gpt-taste`): nav → Attention
(hero) → Interest (proof, bento) → Desire (deep-dive, motion) → Action (CTA).

Hero discipline (the section everyone gets wrong):

- Headline fits in **two lines** in a wide container (`clamp(3rem, 5vw, 5.5rem)`
  in a `max-w-5xl`+). Four wrapped lines is a failed hero.
- Subtext ≤ 20 words. At most 4 text elements total. One primary CTA.
- The logo wall goes *under* the hero, not in it.

Layout variety rules (skill: `design-taste-frontend`):

- At least 4 different layout families across 8 sections; max 2 consecutive
  zig-zags; never three identical feature cards in a row.
- Bento grids have exactly as many cells as items (`grid-flow-dense`, no gaps,
  3–5 intentional cards, not 8 filler ones).
- Eyebrow labels are rationed: no more than ⌈sections/3⌉ on the whole page.
- Section padding is macro: `py-24` to `py-40`. Double your instinct.

## Step 4 — Build

Let the chosen style skill drive the actual markup; don't code from memory.
Techniques that consistently earn "how did you make this":

- **Double-bezel cards** (`high-end-visual-design`): outer shell `bg-white/5`,
  `ring-1`, `p-1.5–2`, `rounded-[2rem]`; inner core with its own background and
  a concentric radius (`calc(2rem - 0.375rem)`). Concentric radius everywhere:
  outer radius = inner radius + padding.
- **Button-in-button CTAs**: pill button with the trailing `↗` in its own
  small circle flush against the inner padding.
- Scroll entrances via `IntersectionObserver` (never `scroll` listeners):
  `translate-y-16 blur-md opacity-0` → clear, 600–800ms, staggered
  `calc(var(--i) * 80ms)`.
- `min-h-[100dvh]`, never `h-screen` (iOS Safari).
- Real content: no "John Doe", no "Acme", no 99.99%, no lorem. Real logos from
  Simple Icons; images generated or `picsum.photos/seed/...` with a CSS filter
  treatment — never gray placeholder divs.

## Step 5 — Motion pass

Motion is a separate pass over a finished page (skills: `animate`, `gsap`,
`apple-design`), not something sprinkled while building:

- Plan **one signature hero moment**, then a feedback layer (hovers, presses),
  then transitions, then delight. One orchestrated experience, not confetti.
- Durations by purpose: 100–150ms feedback, 200–300ms state change, 300–500ms
  layout, 500–800ms entrances. Exits at ~75% of the enter duration.
- Easing tokens: quart `cubic-bezier(0.25,1,0.5,1)`, quint `(0.22,1,0.36,1)`,
  expo `(0.16,1,0.3,1)`. Never bounce or elastic. For gesture-driven UI,
  springs with damping ~0.8–1.0 and response 0.3–0.4s (`apple-design`).
- Animate `transform`/`opacity` only. `will-change` only after you see jank.
- GSAP for scroll choreography: timelines with labels, `stagger`, ScrollTrigger
  pinning/scrubbing. Prefer `autoAlpha` over `opacity`.
- `prefers-reduced-motion` support is not optional.

## Step 6 — The hero demo video (the demo-day secret)

The thing people actually ask about. Instead of screen-recording the product,
I *code* the demo as an HTML/CSS/GSAP animation and render it to video
(skill: `landing-hero-animation`):

1. Write a scene-by-scene storyboard with exact timings (2–4s per scene:
   entry → hold → action → resolution → transition).
2. Build it as ONE labeled `gsap.timeline()` on a fixed 1920×1080 stage, with
   brand tokens copied verbatim from the real repo — exact hex, exact fonts.
3. Iterate in the browser (this is 70% of the work), then render frame-by-frame
   with Playwright headless Chrome and encode with ffmpeg to MP4 + WebM.
4. Make the last frame visually equal the first so it loops seamlessly.

Result: a pixel-perfect, deterministic product video — no cropped screen
recordings, no compression artifacts, retina-sharp at 4K.

## Step 7 — Final polish

Last pass before shipping (skills: `polish`, `better-ui`, `delight`):

- Every interactive element has all its states: default, hover, focus, active,
  disabled, loading, error, success.
- Concentric radii, optical alignment (icon-side padding = text-side − 2px),
  press feedback at `scale(0.96)`, hit areas ≥ 44×44px.
- Shadows as 3 layered rings at 4–8% opacity instead of gray borders; dark
  mode collapses to a single `oklch(1 0 0 / 0.08)` ring.
- Typography sweep: no widows, no sub-16px inputs on mobile, tabular numbers
  on anything that changes.
- Strip console.logs and dead code. WCAG AA contrast. No layout shift.

For existing projects that need this treatment retroactively, run
`redesign-existing-projects`: it fixes in priority order (fonts → color →
states → layout → components → empty/loading states) without rewriting the
stack.

---

## The anti-slop checklist

The consolidated "never ship this" list, distilled from every skill in the
pack. If any of these are true, the page reads as AI-generated:

- Inter/Roboto/system fonts as the display face
- Purple→blue gradients, neon glow on dark, gradient text
- Pure `#000` background, gray text on colored backgrounds
- Three equal feature cards; three-tower pricing; cards inside cards
- Hero headline wrapping to 4+ lines in a narrow container
- Eyebrow labels above every section ("SECTION 01", "ABOUT US")
- "Elevate", "Seamless", "Unleash", "Empower", "Delve"
- John Doe, Acme Corp, Lorem Ipsum, 99.99%, round fake metrics
- Bounce/elastic easing; animations on width/height/top/left
- `window.addEventListener('scroll')`; `h-screen`; `z-[9999]`
- Placeholder gray boxes where images should be
- Missing hover/focus/loading/empty states
- No `prefers-reduced-motion` handling

## Skill cheat sheet

| Stage          | Invoke                                              |
| -------------- | --------------------------------------------------- |
| Direction      | `design-taste-frontend` (default) or a style skill  |
| Type system    | `better-typography`                                 |
| Palette        | `better-colors`                                     |
| Build          | `frontend-design` + chosen style skill              |
| Motion         | `animate`, `gsap`, `apple-design`                   |
| Demo video     | `landing-hero-animation`                            |
| Polish         | `polish`, `better-ui`, `delight`                    |
| Retrofit       | `redesign-existing-projects`                        |
