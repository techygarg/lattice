---
name: architecture
description: "Enforce architectural rules when generating or modifying code. Defaults to clean architecture; supports any architecture style via the architecture-refiner. Validates layer responsibilities, dependency direction, and structural constraints using the loaded architecture rules. Use when generating code, reviewing architecture, creating new files, or when the user mentions 'architecture', 'layers', 'structure', 'dependency rules', 'hexagonal architecture', 'ports and adapters', 'modular monolith', or 'onion architecture'. Also use when reviewing generated code for structural compliance."
---

# Architecture

## Config Resolution

This skill supports two architecture modes: **clean architecture** (default) and **custom architecture** (team-defined). The mode determines which enforcement rules are loaded.

**Step 1 — Determine the mode:**

1. Read `.ai/config.yaml` in the repository root
2. Check the `architecture_mode` key
   - If `architecture_mode: custom` → **custom mode**
   - If absent, or any other value → **clean architecture mode** (default)

**Step 2 — Load enforcement rules:**

- **Clean architecture mode** → Read `./references/clean-architecture.md` for enforcement instructions (Self-Validation Checklist, Anti-Pattern Scan, Ambiguity Signals, structural principles)
- **Custom mode** → Read `./references/custom-architecture.md` for enforcement instructions

**Step 3 — Load architecture content:**

- **Clean architecture mode:**
  1. Check `paths.architecture` in `.ai/config.yaml` for a custom document
  2. If found, read the document and check its YAML frontmatter for `mode`:
     - **`mode: overlay`**: Read `./references/clean-architecture-defaults.md` first, then apply the custom document's sections on top. Sections are matched by heading — custom sections replace matching defaults, new sections are appended.
     - **`mode: override`**: The custom document takes full precedence. It must be comprehensive.
  3. If no custom document → read `./references/clean-architecture-defaults.md`

- **Custom mode:**
  1. Check `paths.architecture` in `.ai/config.yaml` for the team's architecture document
  2. If found → read it. It is the sole reference — there are no defaults.
  3. If not found → surface: "No architecture document found. Run `/architecture-refiner` and select your architecture style to define your team's standards."

## Universal Structural Checks

STOP after generating each component. Regardless of architecture mode, verify these universal structural principles before proceeding:

1. **LAYER PLACEMENT**: Is each class or module in the correct layer as defined by the loaded architecture document?
2. **DEPENDENCY DIRECTION**: Do all source code dependencies follow the direction rules in the loaded architecture document?
3. **BOUNDARY DATA**: Does data crossing layer boundaries use the patterns described in the loaded architecture document?
4. **SINGLE LAYER**: Does each class belong to exactly one architectural layer? No class should span multiple concerns across layers.

Then read the **style-specific Self-Validation Checklist** and **Anti-Pattern Scan** from the loaded enforcement rules (clean-architecture.md or custom-architecture.md) and apply them.
