#!/usr/bin/env bash
set -euo pipefail

LATTICE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN_DIR="$LATTICE_DIR/plugins/lattice"

rm -rf "$PLUGIN_DIR/skills" "$PLUGIN_DIR/scripts"

"$LATTICE_DIR/tools/install.sh" "$PLUGIN_DIR/skills"

mkdir -p "$PLUGIN_DIR/scripts"
cp "$LATTICE_DIR/scripts/run-verification.sh" "$PLUGIN_DIR/scripts/run-verification.sh"

echo ""
echo "Built Codex plugin at $PLUGIN_DIR"
