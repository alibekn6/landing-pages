#!/usr/bin/env bash
#
# Encode the PNG frames captured by render.js into H.264 MP4 and VP9 WebM.
# Run from the project root:
#   bash export/encode.sh
#
# Outputs:
#   out/hero.mp4   — H.264 (universal, iOS + Safari + all browsers)
#   out/hero.webm  — VP9   (smaller at similar quality, served as <source> fallback)

set -euo pipefail

OUT_NAME="${OUT_NAME:-hero}"
FPS="${FPS:-60}"

# Verify the first frame exists — fail early if render.js didn't run
if [ ! -f "export/frames/0000.png" ]; then
  echo "Error: no frames found in export/frames/. Run 'node export/render.js' first." >&2
  exit 1
fi

# Verify ffmpeg is installed
if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "Error: ffmpeg not found. Install it:" >&2
  echo "  macOS:  brew install ffmpeg" >&2
  echo "  Linux:  sudo apt install ffmpeg" >&2
  exit 1
fi

mkdir -p out

# ───── H.264 MP4 (primary) ─────
# -pix_fmt yuv420p      required for iOS + Safari playback
# -movflags +faststart  puts the moov atom at the front of the file so it streams-starts
# -crf 18               near-visually-lossless; raise to 22–24 for smaller files
# -preset slow          better compression at the cost of encode time (quick on a modern laptop)
ffmpeg -y \
  -framerate "$FPS" \
  -i export/frames/%04d.png \
  -c:v libx264 \
  -pix_fmt yuv420p \
  -crf 18 \
  -preset slow \
  -movflags +faststart \
  "out/${OUT_NAME}.mp4"

# ───── VP9 WebM (secondary) ─────
# -crf 30 -b:v 0        constant-quality mode; 30 is a good quality/size point
# -row-mt 1             multi-threaded row encoding (faster on multi-core)
ffmpeg -y \
  -framerate "$FPS" \
  -i export/frames/%04d.png \
  -c:v libvpx-vp9 \
  -crf 30 \
  -b:v 0 \
  -row-mt 1 \
  "out/${OUT_NAME}.webm"

echo ""
echo "Output files:"
ls -lh "out/${OUT_NAME}.mp4" "out/${OUT_NAME}.webm"
