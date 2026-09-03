# Lattice

Composable AI skills framework — three tiers (atoms, molecules, refiners) that teach
AI assistants structured thinking. Skills are markdown files with no runtime or build step.

## Repository Structure

```
source/
├── atoms/{skill-name}/SKILL.md              # Single-principle guardrails (11 skills)
│   └── references/defaults.md               # Embedded defaults for config resolution
├── molecules/{skill-name}/SKILL.md           # Multi-step workflows composing atoms (9 skills)
└── refiners/{skill-name}/SKILL.md            # Guided interviews producing .lattice/ config (7 skills)
    └── assets/template*.md                   # Output template(s) with interview guidance
skills/                                        # Generated, flat (no tier subfolders), git-tracked. The single
                                                # distribution folder every host plugin manifest points at.
docs/                                          # roles documented in full under Documentation Conventions below
├── how-it-works.md
├── configuration.md
├── framework-intelligence.md
├── collaborative-judgment.md
├── practical-guide.md
├── architecture-compass.md
├── plugins.md
└── agents/
    └── verification.md
knowledge-base/                               # design workspace; don't read until asked explicitly
tools/
├── install.sh                                # Copies all skills flattened into the provided skills directory
└── build-skills.sh                           # Regenerates the shared root skills/ from source/
agents/
└── verifier.md                               # Claude Code subagent: runs .lattice/verification.yaml stages, returns a JSON verdict
scripts/
└── run-verification.sh                       # Deterministic verification runner — host-independent, the portable core
.claude-plugin/, .cursor-plugin/, .codex-plugin/, .grok-plugin/, .kimi-plugin/
                                               # Thin per-host manifests only (plugin.json + marketplace.json).
                                               # None contain their own copy of skills — every one points at the
                                               # shared root skills/ folder (explicitly via a "skills" field, or
                                               # implicitly via default auto-discovery).
                                               # .kimi-plugin/ is EXPERIMENTAL: Moonshot's own docs are
                                               # inconsistent on the real plugin.json/marketplace.json schema
                                               # (filename, skills field, marketplace model all disputed across
                                               # their own sources as of 2026-09). Don't treat it as verified
                                               # until confirmed against a single authoritative Moonshot doc.
plugin.json                                    # Root Agent Plugins 1.0 manifest (agent-plugins.org) — the open,
                                               # vendor-neutral standard's own fixed location, separate from the
                                               # per-host dot-folders above. Auto-discovers skills/ with no
                                               # "skills" field at all; see docs/plugins.md for adopter status.
```

## Host Portability

Lattice ships to multiple AI coding tools (Claude Code, Cursor, Codex, Grok, Kimi, more planned) from one shared root `skills/` folder — no per-host copy. Every host-specific `.{host}-plugin/` folder at repo root is a thin manifest (`plugin.json` + `marketplace.json`, no nested skill files); each one's marketplace source/path resolves to the repo root, so `"skills": "./skills/"` (or default auto-discovery, for hosts that support it) always finds the same generated folder. Adding a new host is: add `.{host}-plugin/plugin.json` pointing at `./skills/`, following the shape of an existing one. The root `plugin.json` is a separate thing — the fixed manifest location defined by the open [Agent Plugins 1.0](https://agent-plugins.org) standard, auto-discovered by any conformant client without any per-host folder at all. See `docs/plugins.md` for the full adopter-status table. Split every runtime component into:

- **Portable core** — pure files + bash (e.g. `scripts/run-verification.sh`, the `.lattice/verification.yaml` contract). Ships identically to every host. No host-specific env vars, paths, or tool names inside it.
- **Host adapters** — trigger surfaces translated per host: Claude Code auto-discovery dirs (`agents/` at repo root) are Claude Code conventions, not cross-host standards; Codex/Grok/Kimi equivalents come from their own manifest folders. Never place shared behavior only in an adapter (this is why the verifier's done-gate installs as a marked block in the consumer's own instruction file via `/lattice-init` — project infrastructure, never wired into lattice skills).
- **Graceful degradation** — capabilities degrade, they don't break. The verification suite must work on any host that can run shell and read files; subagent-based context isolation (Claude Code) is an optimization, never a requirement.

Any reference to a host-provided path (e.g. `CLAUDE_PLUGIN_ROOT`) must sit in an explicit fallback chain whose last link is host-independent (the vendored copy `.lattice/scripts/run-verification.sh`, written by `/lattice-init`, then the development checkout). Naming avoids "harness" — in agentic-system vocabulary that word means the runtime scaffolding around a model, not a test runner.

## Skill Conventions

### All skills

- YAML frontmatter with `name` (lowercase-hyphenated) and `description` (include trigger phrases)
- Skill folder names match the `name` field: `clean-code`, `architecture`, `domain-driven-design`, `design-blueprint`
- Config keys in .lattice/config.yaml use snake_case: `paths.clean_code`, `paths.architecture`, `paths.ddd_principles`

### Atoms (source/atoms/)

- Teach ONE engineering principle with embedded guardrails
- Section order: Config Resolution → Self-Validation Checklist → Active Anti-Pattern Scan → principle content
- Self-Validation Checklist: numbered, labeled, imperative STOP language ("STOP and verify ALL...")
- Anti-Pattern Scan: checkbox format ("[ ] God Function: ...")
- Code-quality atoms have references/defaults.md and Ambiguity Signals sections; special atoms (knowledge-priming, design-first, context-anchoring, collaborative-judgment, learning-harvest) do not
- The `architecture` atom is unified: sub-skills for clean architecture (default) and other styles; resolves `paths.architecture` with embedded defaults plus overlay/override from the team's document (see the atom's Config Resolution)
- Canonical example: source/atoms/clean-code/SKILL.md

#### Atom quality conventions
- Config Resolution must handle missing file at configured path: warn user, name the path, fall back to defaults
- Overlay heading matching is exact and case-sensitive; unmatched custom sections append after defaults, never silently discarded
- Ambiguity Signals pattern: "flag it — present options and reasoning; if `framework:collaborative-judgment` is loaded, use it" — never bare "use collaborative-judgment" with no fallback behavior
- Checklist must produce explicit pass output when all checks clear: "Passes [atom-name]. [next step]."

### Molecules (source/molecules/)

- Compose atoms via "Required Skills" section listing framework:{atom-name}
- Numbered workflow steps; never inline atom content — reference and apply atoms
- Canonical example: source/molecules/code-forge/SKILL.md

Two distinct molecule types — apply the right conventions for each:

**Generative molecules** (`code-forge`, `refactor-safely`, `bug-fix`) — produce code or targeted artifacts. Flow is mostly linear. Pause only on genuine judgment calls via `framework:collaborative-judgment`.

**Planning/interactive molecules** (`design-blueprint`, `architecture-compass`) — produce living documents through structured agreement. Each phase must have an explicit confirmation gate before advancing. Must check for an existing output document at Step 1 and resume from the earliest incomplete step if found. Can exit early with a partial document as a valid outcome.

#### Confirmation gate pattern (planning molecules only)

At each agreement checkpoint:
1. Present the phase output
2. Ask a specific question — not "does this look good?" but a targeted prompt (e.g., "Does this map accurately reflect how the codebase is structured today? What's missing or wrong?")
3. **Use explicit gate language: "Do NOT advance to Step N until the user explicitly confirms."**

Without the gate language, AI sessions run straight through all steps without pausing. The specific question earns the pause; the hard gate enforces it. Both are required — neither alone is sufficient.

### Refiners (source/refiners/)

- Guided interview producing .lattice/standards/{output}.md
- assets/template.md contains `<!-- INTERVIEW GUIDANCE: -->` comments (stripped in output)
- Support overlay (default, slim doc) and override (comprehensive replacement) modes
- Canonical example: source/refiners/architecture-refiner/SKILL.md

## Documentation Conventions

Nine docs with distinct, non-overlapping roles:

- **README.md** — Landing page: what Lattice is, skill inventory tables, getting started
- **docs/how-it-works.md** — Technical reference: composability, config resolution, pipeline, .lattice/ folder
- **docs/configuration.md** — Config reference: every .lattice/config.yaml key, produced by, consumed by, merge modes
- **docs/framework-intelligence.md** — Design rationale: two-pass model, verification hierarchy, flywheel, AI compliance
- **docs/collaborative-judgment.md** — Design rationale: why AI should ask on judgment calls or missing grounding, runtime flow, architectural insight
- **docs/practical-guide.md** — Scenario-driven Q&A: getting started, workflow, transformation, team usage, troubleshooting
- **docs/architecture-compass.md** — Architectural thinking partner: why it exists, philosophy, what to expect, key design decisions
- **docs/plugins.md** — Host/plugin reference: source/ → skills/ generation step, per-host manifest status table, how to add a new host
- **docs/agents/verification.md** — Design rationale for the verifier subagent + runner: cost model, file-not-stdout philosophy, how to enable the done-gate manually or automatically per project

Cross-reference via links. Never duplicate content across docs.

## Key Patterns

- **Collaborative judgment**: atoms flag ambiguous checks; molecules wire in the presentation protocol; the AI integrates both in one context window
- **Two-pass model**: generate then verify (never simultaneously)
- **Config resolution**: .lattice/config.yaml → paths key → custom doc (overlay/override) → defaults.md
- **Overlay vs override**: overlay applies custom sections on top of defaults (matched by heading); override fully replaces
- **STOP language + numbered constraints**: creates cognitive boundaries for AI compliance
- **Checkbox anti-patterns**: triggers AI completion behavior
- **.lattice/ folder structure**: all persistent outputs in subfolders, only config.yaml at root. Known subfolders: `standards/` (refiner outputs), `context/` (feature anchor docs), `learnings/` (operational learnings managed by learning-harvest atom), `reviews/` (review log), `insights/` (architecture-compass output), `requirements/` (epic/feature specs produced by requirement-forge). New molecules that produce living documents must write into an existing or new named subfolder — never at the `.lattice/` root.
- **Session resume pattern** (planning molecules only, see Molecules section above): check for an existing living document at Step 1; if found, resume from the earliest incomplete step rather than restarting.

## Anti-Patterns

- Duplicating atom content inside molecules — reference atoms, never inline their rules
- Generic language ("apply best practices") — be specific and imperative
- Mixing doc concerns (rationale in how-it-works, mechanics in framework-intelligence)
- Skills without trigger phrases in the description field
- Putting coding guidelines in knowledge-priming (belongs in clean-code atom)
- Adding confirmation gates to generative molecules — gates belong only in planning molecules
- Scoping execution concerns (clean code, test quality, security, naming) inside planning molecules — these apply automatically during execution via code-forge and refactor-safely
- Writing transformation slices that contain non-structural items (naming, test coverage, code style) — slices must map to structural deltas only
- Skipping the session resume check in planning molecules — always check for an existing living document before starting fresh
- Using `context-anchoring` in molecules that own their own living document structure — `context-anchoring` is scoped to feature dev context docs (design-blueprint, code-forge, refactor-safely, bug-fix). Molecules with distinct doc structures (architecture-compass, requirement-forge) manage session persistence natively via Step 1 resume logic

## Testing Changes

After modifying any skill in `source/`:

```bash
./tools/install.sh /path/to/your-ai-tool/skills/
```

Copies all 27 skills (flattened) into the provided skills directory. Pass the skills folder of whichever AI tool you are using (e.g. `.claude/skills/`, `.cursor/skills/`, `.codex/skills/`). Verify the skill loads correctly.

Also regenerate the shared, git-tracked distribution folder before committing:

```bash
./tools/build-skills.sh
```

This refreshes root `skills/` (the flat folder every host plugin manifest — Claude Code, Cursor, Codex, Grok, Kimi — points at) from `source/`. If you have Codex's `plugin-creator` skill installed locally, also validate the packaged manifest — path varies per install, typically `~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py .`; skip this if you don't have it, it's optional local tooling, not a repo dependency.

When editing this file, update `CLAUDE.md` and `AGENTS.md` only if their pointer text needs to change — do not duplicate convention content into those files.
