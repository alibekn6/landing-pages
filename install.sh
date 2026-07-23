#!/usr/bin/env bash
set -euo pipefail

# Installs every skill in ./skills into ~/.claude/skills for Claude Code.
# Override the destination with CLAUDE_SKILLS_DIR.

SKILLS_SRC="$(cd "$(dirname "$0")/skills" 2>/dev/null && pwd || true)"
SKILLS_DST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

if [ -z "$SKILLS_SRC" ] || [ ! -d "$SKILLS_SRC" ]; then
  echo "No skills/ directory found next to install.sh — nothing to install."
  exit 1
fi

mkdir -p "$SKILLS_DST"

installed=0
skipped=0
for dir in "$SKILLS_SRC"/*/; do
  name="$(basename "$dir")"
  if [ -e "$SKILLS_DST/$name" ]; then
    echo "skip  $name (already exists in $SKILLS_DST)"
    skipped=$((skipped + 1))
  else
    cp -R "$dir" "$SKILLS_DST/$name"
    echo "add   $name"
    installed=$((installed + 1))
  fi
done

echo
echo "Installed $installed skill(s), skipped $skipped existing."
echo "Start a new Claude Code session to pick them up."
