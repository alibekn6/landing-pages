# landing-pages

People keep asking how I make my landing pages and demos. This repo is the
answer: the exact workflow I use, plus the Claude Code skills that power it.

**Start here → [PLAYBOOK.md](PLAYBOOK.md)** — the full process from brief to
shipped page, including the hero-demo-video pipeline.

## Quick start

1. Install [Claude Code](https://claude.com/claude-code).
2. Clone this repo and run `./install.sh` — it copies every skill from
   `skills/` into `~/.claude/skills/`.
3. Open a new Claude Code session in your project and follow the
   [playbook](PLAYBOOK.md). The skills activate automatically when relevant,
   or invoke them by name.

For the hero-video pipeline you additionally need Node.js ≥ 18, ffmpeg ≥ 6,
and Playwright (chromium).

## The skills

> ⚠️ The `skills/` directory is being populated as the attribution pass
> completes — see [ATTRIBUTION.md](ATTRIBUTION.md). Skills whose origin I
> can't verify are linked to their source instead of vendored.

**Core — install all of these, whatever you're building:**

| Skill | What it does |
| --- | --- |
| `frontend-design` | Art-direction gate + full design system rules (type, color, space, motion, interaction). Apache 2.0, based on Anthropic's skill. |
| `high-end-visual-design` | The "$150k agency" build style: archetype variance, double-bezel cards, signature easing. |
| `better-typography` | 19-principle typography rulebook, from font choice to smart punctuation. |
| `better-colors` | OKLCH-only color: palette generation, APCA contrast, derived dark mode. |
| `better-ui` | 13 design-engineering micro-details: concentric radii, optical alignment, shadow recipes, hit areas. |

**Styles — pick one per project:**

| Skill | The feel it produces |
| --- | --- |
| `design-taste-frontend` | Contextual anti-slop default: reads the brief, picks a real design system. |
| `minimalist-ui` | Calm premium document: warm monochrome, serif headlines, flat bento. |
| `gpt-taste` | Award-site energy: AIDA structure, pinned/scrubbed GSAP scroll. |
| `industrial-brutalist-ui` | Swiss print / tactical CRT telemetry, zero border-radius. |
| `apple-design` | Apple-grade physical feel: springs, gestures, interruptible motion. |

**Motion & polish — the passes that separate good from great:**

| Skill | When |
| --- | --- |
| `animate` | Motion pass over a finished feature. |
| `gsap` | GSAP API reference for timelines, stagger, ScrollTrigger. |
| `landing-hero-animation` | Code a product demo as HTML/GSAP, render to pixel-perfect MP4/WebM. |
| `delight` | Personality pass: success states, empty states, easter eggs. |
| `polish` | Final quality sweep: states, alignment, contrast, code hygiene. |
| `redesign-existing-projects` | Retrofit premium quality onto an existing site without a rewrite. |

## Why a playbook and not just skills?

Skills are rules; the playbook is sequencing. Running `polish` before the
structure is right, or picking motion before typography, produces the same
generic output everyone else gets. The order of passes — context → direction →
foundation → structure → build → motion → polish — is the actual answer to
"how do you make these".

## License

Original content (playbook, docs, scripts) is MIT. Individual skills carry
their own licenses and credits — see [ATTRIBUTION.md](ATTRIBUTION.md).
