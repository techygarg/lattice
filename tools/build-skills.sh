#!/usr/bin/env bash
set -euo pipefail

LATTICE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

rm -rf "$LATTICE_DIR/skills"

"$LATTICE_DIR/tools/install.sh" "$LATTICE_DIR/skills"

echo ""
echo "Rebuilt $LATTICE_DIR/skills from source/ — shared by every host plugin (Claude Code, Cursor, Codex, Grok, Kimi)."
