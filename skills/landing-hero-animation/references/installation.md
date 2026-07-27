# Installation

The pipeline needs three things: **ffmpeg**, **Node.js**, and **Playwright with Chromium**.

## macOS

```bash
# 1. ffmpeg (for encoding frames into MP4/WebM)
brew install ffmpeg

# 2. Node.js (Playwright and the render script run on Node)
brew install node

# 3. Verify
node --version    # should be v18 or newer
ffmpeg -version | head -1
```

If you don't have Homebrew, install it first: https://brew.sh

## Linux (Debian/Ubuntu)

```bash
sudo apt update
sudo apt install -y ffmpeg nodejs npm

# If the apt Node is too old (Ubuntu LTS often has Node 16 or 18), install a recent one via NodeSource:
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Verify
node --version
ffmpeg -version | head -1
```

## Linux (Fedora/RHEL)

```bash
sudo dnf install -y ffmpeg nodejs
# If ffmpeg isn't available in the default repos, enable RPM Fusion:
# https://rpmfusion.org/Configuration
```

## Windows

Preferred: use WSL2 (Windows Subsystem for Linux) and follow the Linux steps above. The render script uses POSIX conventions that work best in WSL.

Native Windows (not recommended but possible):
- ffmpeg: download from https://www.gyan.dev/ffmpeg/builds/ and add to PATH
- Node.js: https://nodejs.org/en/download
- Adjust paths in `render.js` (use backslashes or forward slashes consistently)
- Replace `bash encode.sh` with a PowerShell equivalent

## Playwright (per-project)

Once Node is installed, Playwright is installed per project:

```bash
cd <project-root>/export
npm install
npx playwright install chromium
```

This downloads a Chromium binary into `~/Library/Caches/ms-playwright/` (macOS) or `~/.cache/ms-playwright/` (Linux). ~200 MB. Only the first run downloads; subsequent projects reuse the cache.

## Verify the full pipeline

After installation, verify everything works:

```bash
# Create a tiny test HTML
mkdir -p test-render/demo test-render/export test-render/out
cat > test-render/demo/index.html <<'EOF'
<!doctype html><html><head><script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/gsap.min.js"></script></head>
<body style="margin:0;background:white;">
<div id="box" style="width:200px;height:200px;background:#5B9AFF;margin:100px;"></div>
<script>
const tl = gsap.timeline({ paused: true });
tl.to('#box', { x: 600, duration: 2 });
window.__timeline = tl;
window.__ready = true;
</script>
</body></html>
EOF

# Copy render.js + encode.sh into test-render/export and run
# Expected: out/hero.mp4 with a blue box sliding right
```

If this works end-to-end, the real pipeline will work too.

## Common install failures

- **`brew install ffmpeg` hangs for 20 minutes** — it's compiling from source. Be patient or use `brew install --cask --no-quarantine ffmpeg` for a pre-built bottle if available.
- **`npx playwright install chromium` fails on corporate network** — proxy issue. Set `HTTPS_PROXY` env var or ask IT for Playwright's mirror.
- **`ffmpeg: libvpx-vp9 not found`** — your ffmpeg was compiled without VP9 support. On macOS `brew install ffmpeg` always includes it. On Linux check `ffmpeg -codecs | grep vp9`. If missing, install the full ffmpeg build (not a minimal/headless variant).
- **`ffmpeg: libx264 not found`** — same story. Universal builds include H.264.
