#!/usr/bin/env bash
set -euo pipefail

LATTICE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SOURCE="$LATTICE_DIR/source"
SHARED_DIR="$SKILLS_SOURCE/shared"
INCLUDE_PATTERN='^<!-- include: [a-z0-9-]+ -->$'

# Replace each `<!-- include: {name} -->` line in an installed SKILL.md with
# source/shared/{name}.md, substituting __SKILL_KEY__ with the skill's config key
# (folder name, hyphens -> underscores). Fails on a missing snippet.
expand_includes() {
  local file="$1" key="$2" tmp
  grep -Eq "$INCLUDE_PATTERN" "$file" || return 0
  tmp="$file.tmp"
  if ! awk -v shared="$SHARED_DIR" -v key="$key" -v pattern="$INCLUDE_PATTERN" '
    $0 ~ pattern {
      path = shared "/" $3 ".md"
      if ((getline line < path) <= 0) { print "error: missing snippet " path > "/dev/stderr"; exit 1 }
      do { gsub(/__SKILL_KEY__/, key, line); print line } while ((getline line < path) > 0)
      close(path)
      next
    }
    { print }
  ' "$file" > "$tmp"; then
    rm -f "$tmp"
    echo "error: include expansion failed in $file" >&2
    exit 1
  fi
  cat "$tmp" > "$file"
  rm -f "$tmp"
}

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
      rm -rf "${DEST:?}/$skill_name"
    else
      echo "  add:    $skill_name"
    fi

    cp -R "$skill_dir" "$DEST/$skill_name"
    expand_includes "$DEST/$skill_name/SKILL.md" "${skill_name//-/_}"
    count=$((count + 1))
  done
done

echo ""
echo "Installed $count skills into $DEST"
