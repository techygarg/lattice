#!/usr/bin/env bash
set -euo pipefail

LATTICE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN_DIR="$LATTICE_DIR/plugins/lattice"

rm -rf "$PLUGIN_DIR/skills"

"$LATTICE_DIR/tools/install.sh" "$PLUGIN_DIR/skills"

echo ""
echo "Built Codex plugin at $PLUGIN_DIR"
