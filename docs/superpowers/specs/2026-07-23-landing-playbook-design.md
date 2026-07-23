# landing-pages — design spec

Date: 2026-07-23
Status: approved direction (repo created and pushed by owner); draft content under review

## Goal

Package the owner's landing-page / demo-building knowledge into a public GitHub
repo (github.com/alibekn6/landing-pages) so other developers can reproduce the
workflow. People keep asking "how do you make these demos" — this repo is the
answer.

## Decisions made

- **Format:** repo-pack — curated Claude Code skills + a written methodology.
- **Language:** English.
- **Workflow capture:** Claude drafts the playbook from analyzing the owner's
  installed skills; the owner corrects it.
- **Approach:** playbook-first. The core artifact is PLAYBOOK.md (the process);
  skills are the attached toolkit.

## Repo structure

```
landing-pages/
├── README.md          # pitch, quick start, skill table by category
├── PLAYBOOK.md        # methodology: brief → direction → foundation →
│                      # structure → build → motion → polish
├── skills/            # flat dirs, one per skill (only after ownership check)
├── install.sh         # copies skills/* into ~/.claude/skills/
├── ATTRIBUTION.md     # origin/credit table for every skill
└── LICENSE            # MIT for original content; upstream notices preserved
```

## Skill curation (3 categories)

- **Core (install for everyone):** frontend-design, high-end-visual-design,
  better-typography, better-colors, better-ui
- **Styles (pick per project):** apple-design, minimalist-ui,
  industrial-brutalist-ui, gpt-taste, design-taste-frontend
- **Motion & polish:** landing-hero-animation, gsap, animate, delight, polish,
  redesign-existing-projects

## Licensing gate (blocking)

Most skill files carry no license/author metadata. Before any skill file is
committed/pushed publicly, the owner marks each one in ATTRIBUTION.md as:
- **mine** → include the files
- **third-party w/ redistributable license** (e.g. frontend-design, Apache 2.0)
  → include with attribution preserved
- **third-party, no license / unknown** → do NOT include files; link to source

Until that pass, skills/ stays out of git history.

## Out of scope (for now)

- Claude Code plugin/marketplace format (possible later layer)
- Russian README translation
- Example/demo landing page in the repo
