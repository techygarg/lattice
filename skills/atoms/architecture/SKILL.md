---
name: architecture
description: "Enforce architectural rules when generating or modifying code. Defaults to clean architecture; supports any architecture style via the architecture-refiner. Validates layer responsibilities, dependency direction, and structural constraints using the loaded architecture rules. Use when generating code, reviewing architecture, creating new files, or when the user mentions 'architecture', 'layers', 'structure', 'dependency rules', 'hexagonal architecture', 'ports and adapters', 'modular monolith', or 'onion architecture'. Also use when reviewing generated code for structural compliance."
---

# Architecture

## Config Resolution

Skill support two mode: **clean architecture** (default) and **custom architecture** (team-define). Mode determine which rule load.

**Step 1 — Determine mode:**

1. Read `.lattice/config.yaml` in repo root
2. Check `architecture_mode` key
   - If `architecture_mode: custom` → **custom mode**
   - If absent, or other value → **clean architecture mode** (default)

**Step 2 — Load enforce rule:**

- **Clean architecture mode** → Read `./references/clean-architecture.md` for enforce instruction (Self-Validation Checklist, Anti-Pattern Scan, Ambiguity Signals, structural principles)
- **Custom mode** → Read `./references/custom-architecture.md` for enforce instruction

**Step 3 — Load architecture content:**

- **Clean architecture mode:**
  1. Check `paths.architecture` in `.lattice/config.yaml` for custom doc
  2. If found, read doc and check YAML frontmatter for `mode`:
     - **`mode: overlay`**: Read `./references/clean-architecture-defaults.md` first, then apply custom doc section on top. Section match by heading — custom section replace matching default, new section append.
     - **`mode: override`**: Custom doc take full precedence. Must be comprehensive.
  3. If no custom doc → read `./references/clean-architecture-defaults.md`

- **Custom mode:**
  1. Check `paths.architecture` in `.lattice/config.yaml` for team architecture doc
  2. If found → read it. Sole reference — no default.
  3. If not found → surface: "No architecture document found. Run `/architecture-refiner` and select your architecture style to define your team's standards."

**Step 4 — Language adaptation:**

If `paths.language_idioms` exist in config, read **"Dependency Management"** section and adapt dependency direction enforcement to language idioms (e.g., Go interface-at-consumer, Java DI containers, Rust trait bounds). Language idioms take precedence over pseudocode defaults.

## Universal Structural Checks

STOP after generate each component. Regardless mode, verify universal principle before proceed:

1. **LAYER PLACEMENT**: Each class/module in correct layer per loaded doc?
2. **DEPENDENCY DIRECTION**: All source dependency follow direction rule in loaded doc?
3. **BOUNDARY DATA**: Data cross layer use pattern describe in loaded doc?
4. **SINGLE LAYER**: Each class belong exactly one layer? No span multiple concern across layer.

Then read **style-specific Self-Validation Checklist** and **Anti-Pattern Scan** from loaded enforce rule (clean-architecture.md or custom-architecture.md) and apply.