# Plugins

Lattice ships as a plugin to multiple AI coding tools from one shared skill set. This is the reference for how that works and how to add a new host.

## How it works

- `source/` is the canonical, tiered skill tree (`atoms/`, `molecules/`, `refiners/`) — where skills are authored. See [how-it-works.md](how-it-works.md) for the skill mechanics themselves.
- `skills/` is generated, flat (no tier subfolders), and git-tracked — the single distribution folder every host manifest points at. Regenerate it after any change under `source/`:
  ```bash
  ./tools/build-skills.sh
  ```
- Every host gets a thin manifest only — `plugin.json` (plus `marketplace.json` where the host needs a separate file to register the plugin for its install flow) — never its own copy of the skills.

## Supported hosts

| Host | Manifest | Status |
|---|---|---|
| Claude Code | `.claude-plugin/plugin.json` + `marketplace.json` | Confirmed against official schema |
| Cursor | `.cursor-plugin/plugin.json` + `marketplace.json` | Confirmed against official schema |
| Codex | `.codex-plugin/plugin.json`, registered via `.agents/plugins/marketplace.json` | Confirmed against official schema |
| Grok Build | `.grok-plugin/plugin.json` + `marketplace.json` | Confirmed against official schema — remote `source.sha` in `marketplace.json` must be set to a real commit SHA at release time; currently a placeholder |
| Kimi (Moonshot) | `.kimi-plugin/plugin.json` + `marketplace.json` | Experimental — Moonshot's own docs disagree on the real schema across their own sources; treat as unverified until confirmed against one authoritative doc |
| [Agent Plugins 1.0](https://agent-plugins.org) | root `plugin.json` | Open, vendor-neutral standard (TSC: Amazon, Cursor, Microsoft, OpenAI, Vercel). Any conformant client auto-discovers skills straight from the existing root `skills/` folder — zero extra wiring, no `"skills"` field even needed. Shipped in Codex CLI, Cursor (additive, alongside its native manifest), VS Code / GitHub Copilot, and Kiro as of 2026-09. Claude Code does not support it yet. |

Install instructions per host are in the [README](../README.md#getting-started) — this table is the reference for what's registered and why, not a how-to.

## Adding a new host

Most hosts follow the same shape: a thin `.{host}-plugin/plugin.json` pointing at `./skills/` (or auto-discovering it, if the host supports that), plus a `marketplace.json` if the host needs a separate file to register the plugin for its install flow. Copy the closest existing example — `.grok-plugin/` and `.kimi-plugin/` are the simplest — and adapt the field names to that host's documented schema. Verify against the host's *own* docs, not just by pattern-matching an existing folder: schemas genuinely diverge between hosts, sometimes even between two of a single vendor's own doc pages (see Kimi above).

Never give a new host its own copy of the skills. If a host can't auto-discover or point at the shared `skills/` folder at all, that's a sign it doesn't fit this pattern — flag it rather than force it.
