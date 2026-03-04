#!/usr/bin/env bash
set -euo pipefail

LATTICE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SOURCE="$LATTICE_DIR/skills"

usage() {
  cat <<EOF
Usage: ./tools/install.sh <target-project-path>

Copies all Lattice skills into <target-project-path>/.claude/skills/,
flattening the atoms/molecules/crafters structure so Claude Code can
discover them.

Example:
  ./tools/install.sh ~/projects/my-app
  ./tools/install.sh .                    # install into current directory
EOF
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

TARGET="$1"

if [ ! -d "$TARGET" ]; then
  echo "Error: '$TARGET' is not a directory."
  exit 1
fi

TARGET="$(cd "$TARGET" && pwd)"
DEST="$TARGET/.claude/skills"

mkdir -p "$DEST"

count=0
for tier in atoms molecules crafters; do
  tier_dir="$SKILLS_SOURCE/$tier"
  [ -d "$tier_dir" ] || continue

  for skill_dir in "$tier_dir"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"

    if [ -d "$DEST/$skill_name" ]; then
      echo "  update: $skill_name"
      rm -rf "$DEST/$skill_name"
    else
      echo "  add:    $skill_name"
    fi

    cp -R "$skill_dir" "$DEST/$skill_name"
    count=$((count + 1))
  done
done

echo ""
echo "Installed $count skills into $DEST"
