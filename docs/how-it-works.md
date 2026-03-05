# How Lattice Works

This document explains the composability model behind Lattice -- why three tiers exist, how each tier works, and how they fit together.

## The Composability Model

Lattice solves three distinct problems, each with its own tier:

1. **Atoms** solve the guardrail problem: how do you ensure generated code follows a specific principle (clean code, DDD, security) without the AI forgetting halfway through?
2. **Molecules** solve the orchestration problem: how do you run a multi-step workflow (design → implement → review) that applies the right guardrails at the right time?
3. **Refiners** solve the customization problem (optionally): how do you tailor atom behavior to your project's specific standards without editing the atom's source?

Each tier builds on the one below it. Molecules compose atoms. Refiners optionally configure atoms -- atoms work out of the box without them. The separation means atoms stay generic and reusable, molecules stay focused on workflow, and project-specific decisions live in config files -- not hardcoded in skill definitions.

## Atoms in Depth

### What they are

Each atom is a single-concern skill file that teaches one engineering principle. It contains the principle's rules, a self-validation checklist (with imperative STOP-and-verify language), an active anti-pattern scan (checkbox format), and a config resolution mechanism. Atoms do not produce artifacts -- they apply their checks during post-generation verification, the same way a skilled developer reviews their own code before presenting it.

### How they work

When an atom is active, it provides two verification tools: a **Self-Validation Checklist** (numbered, labeled checks with imperative STOP language) and an **Active Anti-Pattern Scan** (checkbox format for scanning output). These are used by code-forge's post-generation verification pass — after generating each component, the AI runs the relevant atom checklists against its output and fixes violations before presenting. This two-pass model (generate, then verify) is more reliable than simultaneous generation and validation.

### Always vs conditional atoms

Not every atom applies to every piece of code. The distinction matters for both standalone use and molecule composition:

**Always apply:**
- **clean-code** -- Every piece of code benefits from SRP, clear naming, managed complexity, and proper error handling.
- **clean-architecture** -- Every file lives in a layer, and every dependency has a direction. Structural rules apply universally.
- **knowledge-priming** -- Project context (tech stack, architecture, conventions) is always relevant. Without it, the AI defaults to generic assumptions.

**Conditionally apply:**
- **domain-driven-design** -- Only when touching domain layer code. A controller or infrastructure adapter does not need aggregate boundary checks.
- **secure-coding** -- Only when code crosses trust boundaries: HTTP handlers, database queries, external API calls, file I/O, user input processing.
- **test-quality** -- Only when writing test code. AAA structure and test isolation do not apply to production code.

### The special ones

Three atoms serve different purposes than the code-quality atoms:

- **knowledge-priming** is a context atom. It loads the project's identity -- tech stack, architecture overview, directory layout, trusted sources, and conventions -- so that all other skills operate with awareness of what the project actually is. Without it, the AI defaults to "the average of the internet." Unlike quality atoms, it has no embedded defaults -- every project's identity is unique. The knowledge base document is created by the `knowledge-priming-refiner` or written by hand.
- **design-first** is a methodology atom, not a code quality atom. It guides structured thinking through 5 progressive levels (Capabilities → Components → Interactions → Contracts → Implementation) before any code is written. It prevents the AI from jumping straight to implementation.
- **context-anchoring** is a persistence mechanism. It manages per-feature living documents that capture decisions, constraints, and reasoning across sessions. It solves the problem of AI context decay -- by message 30+, early decisions get contradicted unless they are written down.

### Config resolution

Every code-quality atom supports project-specific customization through the same resolution mechanism:

1. Look for `.ai/config.yaml` in the repository root
2. Check for the atom's config key (e.g., `paths.clean_code`, `paths.clean_architecture`)
3. If a custom document exists at that path, check its YAML frontmatter for `mode`:
   - **`mode: overlay`**: Read the atom's embedded defaults first, then apply the custom document's sections on top. Sections are matched by heading -- custom sections replace matching defaults, new sections are appended.
   - **`mode: override`** (or no mode specified): The custom document takes full precedence. It must be comprehensive.
4. If no config exists, use the atom's embedded `./references/defaults.md`

This means atoms work out of the box with opinionated defaults. Customization is opt-in, not required.

## Molecules in Depth

### What they are

Molecules are orchestrated multi-step workflows. Each molecule composes multiple atoms, applying them at the right stage of the workflow. Molecules reference atoms -- they do not duplicate atom content.

### design-blueprint

A complete design workflow that produces an approved blueprint before any code is written.

**Composes**: knowledge-priming, context-anchoring, design-first, clean-architecture, domain-driven-design

**How it works**:
1. **Establish context**: Uses context-anchoring to create or load the feature's living document.
2. **Walk design levels**: Drives through design-first's 5 levels sequentially. At Levels 2-4, applies clean-architecture (layer assignments, dependency direction) and domain-driven-design (aggregate identification, entity/value object classification).
3. **Persist at each level**: After the user approves each level, the approved output is written to the context document. The context document *is* the blueprint.
4. **Finalize**: Writes a design summary with component list, layer assignments, contracts, and a "ready for implementation" marker.

The blueprint stops at Level 4 (Contracts). It does not proceed to Level 5 (Implementation) -- that is code-forge's job.

### code-forge

Generates implementation from an approved blueprint or verbal requirements.

**Composes**: knowledge-priming (always), context-anchoring (always), clean-architecture (always), clean-code (always), domain-driven-design (conditional: domain layer), secure-coding (conditional: trust boundaries), test-quality (always when writing tests)

**How it works**:
1. **Load context**: Loads learnings from `.ai/learnings/review-insights.md` (if they exist) to avoid repeating past mistakes. Uses context-anchoring to find and load the feature's blueprint. If none exists, works from verbal requirements -- all atom guardrails still apply.
2. **Plan implementation order**: Classifies components into architectural layers and plans an inside-out build order: Domain → Infrastructure → Application → Interface. Each layer's dependencies already exist when it is built.
3. **Implement per component**: Generates code and tests together. After generating each component, runs a post-generation verification pass — atom self-validation checklists and anti-pattern scans — fixing violations before presenting. Applies clean-code and clean-architecture to all code. Applies DDD only to domain layer code. Applies secure-coding only at trust boundaries.
4. **Cross-component verification**: Checks architectural coherence — interaction flows match the blueprint, dependency direction is correct, no unplanned components, and past learnings don't recur.
5. **Enrich context**: Captures implementation decisions in the living document. Recommends running `/review` before considering the feature complete.

The user chooses a review mode: layer-by-layer (recommended), full autonomy, or component-by-component.

### review

A structured, delta-scoped code review that loads atoms conditionally based on what changed.

**Composes**: knowledge-priming (always), clean-code (always), clean-architecture (conditional), domain-driven-design (conditional), secure-coding (conditional), test-quality (conditional)

**How it works**:
1. **Identify the delta**: Determines the set of changed files (PR, commit, or specified files).
2. **Classify and load**: Analyzes which layers, domains, and boundaries the delta touches. Loads only the relevant atoms -- a change to a single value object does not trigger the security checklist.
3. **Run targeted validation**: For each loaded atom, runs two passes: the validation checklist (hard rules) and the anti-pattern scan (smell-level issues).
4. **Produce report**: Findings are severity-ordered (critical → warning → suggestion) with specific file locations and concrete fixes. Summary mode by default; full mode on request. Every review ends with a "what's done well" observation.
5. **Capture insights and log**: Appends recurring patterns to `.ai/learnings/review-insights.md` (fed back into code-forge's next session) and logs a structured summary to `.ai/reviews/review-log.md` (project health visibility).

## Customizing Atom Defaults

Every atom ships with opinionated defaults (in `./references/defaults.md`) that work out of the box. Customization is entirely optional -- you only need it when your project's standards differ from the defaults.

### Two paths to customization

When you do want to customize, you have two equivalent paths:

1. **Run a refiner** -- a guided interview that asks about your standards and generates the standards document for you. Useful when you are not sure what to change or want a structured walkthrough.
2. **Edit the standards document directly** -- create or modify the file in `.ai/standards/` by hand. Useful when you know exactly what you want to change.

Both paths produce the same result: a standards document in `.ai/standards/` that the atom picks up through its config resolution mechanism (via `paths` in `.ai/config.yaml`). There is no difference in how the atom consumes the file regardless of how it was created.

### Overlay, override, and adding new sections

The config file's YAML frontmatter controls how the atom uses it:

- **Overlay** (default, recommended): The atom reads its embedded defaults first, then applies the custom document's sections on top. Only include sections you want to change or add -- everything else stays at defaults. You can also add entirely new sections (e.g., language-specific idioms, team-specific rules) that do not exist in the defaults.
- **Override**: The custom document fully replaces the atom's defaults. Use this when your standards are fundamentally different and you want complete control.

Most teams use overlay -- the defaults are good starting points, and typically only a few sections need adjustment.

### When to customize

Customization is not a one-time setup task. You might customize when:

- Starting a new project and your team's standards differ from the defaults
- Adopting a new pattern or convention mid-project
- Tightening or relaxing thresholds as the codebase matures
- Adding project-specific rules that the defaults do not cover

Re-run a refiner or edit the standards document whenever your standards evolve.

### What each refiner produces

| Refiner | Output file | Target atom | What it captures |
|---------|------------|-------------|-----------------|
| **architecture-refiner** | `.ai/standards/clean-architecture.md` | clean-architecture | Layer definitions, dependency rules, command/query flow patterns, service patterns |
| **ddd-refiner** | `.ai/standards/ddd-principles.md` | domain-driven-design | Aggregate design rules, entity/value object patterns, domain event conventions, repository patterns |
| **clean-code-refiner** | `.ai/standards/clean-code.md` | clean-code | Function size thresholds, complexity limits, naming conventions, error handling strategy |
| **knowledge-priming-refiner** | `.ai/standards/knowledge-base.md` | knowledge-priming | Architecture overview, tech stack with versions, trusted doc sources, project structure, conventions |

The knowledge-priming-refiner completes the pattern -- like the other refiners, its output is consumed by a matching atom (knowledge-priming) through config resolution. The knowledge-priming atom loads the document and makes it available as ambient project context for all skills and molecules.

## The Design-to-Code Pipeline

### Customize (optional)

If your project's standards differ from the atom defaults, tailor them by running a refiner or editing the standards documents in `.ai/standards/` directly. Atoms work out of the box without this step. Come back and customize whenever your standards evolve.

### Design

Invoke `design-blueprint` to create an approved blueprint for a feature. The molecule walks through progressive design levels, applying architectural and domain modeling atoms at each level. Every approved level is persisted to a context anchor document -- the blueprint is durable, not ephemeral.

### Implement

Invoke `code-forge` to build from the blueprint. The molecule loads the context document, plans an inside-out implementation order, and generates code with tests. Each component gets exactly the atom guardrails it needs based on its layer and purpose. Implementation decisions are captured back into the context document.

### Review

Invoke `review` to audit the delta. The molecule classifies what changed, loads only the relevant atoms, and runs targeted validation. Findings are severity-ordered with specific locations and fixes.

### Context anchoring ties it together

The context anchor document is the thread that connects these stages. Created during design, it carries the approved blueprint into implementation. Enriched during implementation, it captures decisions that inform review. Loaded in any future session, it restores the full context of what was decided and why.

The document lifecycle is: **Create** (new feature) → **Load** (resume work) → **Enrich** (capture decisions). All three behaviors require explicit user confirmation -- the AI proposes, the user disposes.

## The `.ai/` Folder

The `.ai/` folder is the project's AI-specific memory. All persistent artifacts produced by the framework live here, organized into subfolders with distinct lifecycles.

### Structure

```
.ai/
├── config.yaml          # Central config (only file at root)
├── standards/           # Refiner-produced customization documents
│   ├── knowledge-base.md
│   ├── clean-code.md
│   ├── clean-architecture.md
│   └── ddd-principles.md
├── context/             # Per-feature living documents
│   └── <feature>.md
├── learnings/           # Accumulated review insights
│   └── review-insights.md
└── reviews/             # Review log for project health
    └── review-log.md
```

### Subfolder Lifecycles

| Subfolder | Purpose | Lifecycle |
|-----------|---------|-----------|
| `standards/` | Refiner-produced customization docs consumed by atoms via config resolution | Stable — set once during project setup, rarely changed |
| `context/` | Per-feature living documents managed by context-anchoring | Per feature — created when feature starts, enriched during design and implementation |
| `learnings/` | Accumulated review insights loaded by code-forge at session start | Append-only with pruning — capped at ~50 entries |
| `reviews/` | Review log entries for project health visibility | Rolling window — capped at ~20 entries, older entries summarized |

### Convention

**Rule**: All persistent artifacts go into subfolders. Never place files directly in `.ai/` root except `config.yaml`.

This convention ensures the folder stays organized as the framework adds new capabilities. Every new output type gets its own subfolder with a clear lifecycle.

## How Atoms, Molecules, and Refiners Differ

| Dimension | Atoms | Molecules | Refiners |
|-----------|-------|-----------|----------|
| **Purpose** | Teach one principle | Orchestrate a workflow | Optionally customize atom defaults |
| **Invocation** | Auto-activate based on context, or invoked by molecules | User invokes explicitly (e.g., `/design-blueprint`) | User invokes when customization is needed (e.g., `/architecture-refiner`) |
| **Artifacts produced** | None (inline checks) | Blueprints, reviews, context documents | `.ai/` config files |
| **Composes others?** | No | Yes (composes atoms) | No |
| **Configured by refiners?** | Yes (via `.ai/` config files) | No (molecules have no config) | N/A |
| **Frequency of use** | Every generation (automatic) | Per feature or per review | As needed -- when standards are first set or evolve |
| **Required?** | Yes (core guardrails) | No (but recommended for structured workflows) | No (atoms work with built-in defaults) |
| **Works standalone?** | Yes | Yes | Yes |
