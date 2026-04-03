#!/usr/bin/env bash
set -euo pipefail

LATTICE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SOURCE="$LATTICE_DIR/skills"

usage() {
  cat <<EOF
Usage: ./tools/install.sh <target-skills-dir>

Copies all Lattice skills into <target-skills-dir>, flattening the
atoms/molecules/refiners structure so your AI tool can discover them.

The target is the skills directory of your AI tool, for example:
  Claude Code:  ~/.claude/skills/  or  /path/to/project/.claude/skills/
  Cursor:       /path/to/project/.cursor/skills/
  Any other:    /absolute/path/to/your/skills/folder/

Examples:
  ./tools/install.sh ~/.claude/skills
  ./tools/install.sh /path/to/my-app/.claude/skills
  ./tools/install.sh /path/to/my-app/.cursor/skills
EOF
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

DEST="$1"

mkdir -p "$DEST"

DEST="$(cd "$DEST" && pwd)"

count=0
for tier in atoms molecules refiners; do
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
