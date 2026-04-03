# How Lattice Works

This document explains the composability model behind Lattice -- why three tiers exist, how each tier works, and how they fit together.

## The Composability Model

Lattice solves three distinct problems, each with its own tier:

1. **Atoms** solve the guardrail problem: how do you ensure generated code follows a specific principle (clean code, DDD, security) without the AI forgetting halfway through?
2. **Molecules** solve the orchestration problem: how do you run a multi-step workflow (design → implement → review) that applies the right guardrails at the right time?
3. **Refiners** solve the customization problem (optionally): how do you tailor atom defaults or molecule behavior to your project's specific standards without editing the skill's source?

Each tier builds on the one below it. Molecules compose atoms. Refiners optionally configure atoms or molecule behavior -- skills work out of the box without them. The separation means atoms stay generic and reusable, molecules stay focused on workflow, and project-specific decisions live in config files -- not hardcoded in skill definitions.

## The Two Layers

The three tiers described above are one half of Lattice -- the **base framework**. Atoms, molecules, and refiners are static, composable engineering skills. They ship with the framework, they encode principles and workflows, and they work the same way on every project. The base framework is the skeleton -- structurally correct, portable, and stable.

The second half is the **living context layer**: the `.ai/` folder. Standards produced by refiners, feature context documents, accumulated review insights, and health logs -- all project-specific, all growing with every feature cycle. The living context layer is the muscle -- it strengthens with use, adapts to the work you do, and makes the base framework increasingly capable.

The two layers interact through a read/write loop. The base framework *reads* from the context layer: atoms load project-specific standards, code-forge, refactor-safely, and bug-fix load past learnings, knowledge-priming loads the project's identity. The pipeline *writes* to the context layer: refiners produce standards documents, design-blueprint and code-forge create and enrich context documents, refactor-safely records approved structural decisions, bug-fix records root cause and repair decisions, and review captures insights and logs health summaries. Each cycle enriches the next.

The payoff compounds over time. After a few feature cycles, atoms aren't applying generic rules -- they're applying *your* rules, informed by *your* review history. Code-forge doesn't repeat mistakes that review already caught. Standards grow more precise as refiners are re-run. Health logs reveal trends across features, not just snapshots. The base framework never changes, but the context layer makes it smarter with every use.

## Atoms in Depth

### What they are

Each atom is a single-concern skill file that teaches one engineering principle. It contains the principle's rules, a self-validation checklist (with imperative STOP-and-verify language), an active anti-pattern scan (checkbox format), and a config resolution mechanism. Atoms do not produce artifacts -- they apply their checks during post-generation verification, the same way a skilled developer reviews their own code before presenting it.

### How they work

When an atom is active, it provides two verification tools: a **Self-Validation Checklist** (numbered, labeled checks with imperative STOP language) and an **Active Anti-Pattern Scan** (checkbox format for scanning output). These are used by molecules such as code-forge, refactor-safely, and bug-fix during their verification passes — after generating, reshaping, or repairing code, the AI runs the relevant atom checklists against its output and fixes violations before presenting. This two-pass model (generate, then verify) is more reliable than simultaneous generation and validation.

### Always vs conditional atoms

Not every atom applies to every piece of code. The distinction matters for both standalone use and molecule composition:

**Always apply:**
- **clean-code** -- Every piece of code benefits from SRP, clear naming, managed complexity, and proper error handling.
- **clean-architecture** -- Every file lives in a layer, and every dependency has a direction. Structural rules apply universally.
- **knowledge-priming** -- Project context (tech stack, architecture, conventions) is always relevant. Without it, the AI defaults to generic assumptions.
- **collaborative-judgment** -- Genuine judgment calls should be surfaced with options, not silently resolved. Composed by molecules alongside other atoms.

**Conditionally apply:**
- **domain-driven-design** -- Only when touching domain layer code. A controller or infrastructure adapter does not need aggregate boundary checks.
- **secure-coding** -- Only when code crosses trust boundaries: HTTP handlers, database queries, external API calls, file I/O, user input processing.
- **test-quality** -- Only when writing test code. AAA structure and test isolation do not apply to production code.

### The special ones

Four atoms serve different purposes than the code-quality atoms:

- **knowledge-priming** is a context atom. It loads the project's identity -- tech stack, architecture overview, directory layout, trusted sources, and conventions -- so that all other skills operate with awareness of what the project actually is. Without it, the AI defaults to "the average of the internet." Unlike quality atoms, it has no embedded defaults -- every project's identity is unique. The knowledge base document is created by the `knowledge-priming-refiner` or written by hand.
- **design-first** is a methodology atom, not a code quality atom. It guides structured thinking through 5 progressive levels (Capabilities → Components → Interactions → Contracts → Implementation) before any code is written. It prevents the AI from jumping straight to implementation.
- **context-anchoring** is a persistence mechanism. It manages per-feature living documents that capture decisions, constraints, and reasoning across sessions. It solves the problem of AI context decay -- by message 30+, early decisions get contradicted unless they are written down.
- **collaborative-judgment** is an ambiguity protocol. It ensures the AI surfaces genuine judgment calls with structured options instead of silently assuming. Each code-quality atom defines its own Ambiguity Signals (domain-specific gray areas); this atom defines how to present, batch, and resolve them. It becomes less active as the project's standards grow more specific. See [docs/collaborative-judgment.md](collaborative-judgment.md) for the full design rationale.

### Config resolution

Every code-quality atom supports project-specific customization through the same resolution mechanism:

1. Look for `.ai/config.yaml` in the repository root
2. Check for the atom's config key (e.g., `paths.clean_code`, `paths.clean_architecture`)
3. If a custom document exists at that path, check its YAML frontmatter for `mode`:
   - **`mode: overlay`** (default, recommended): Read the atom's embedded defaults first, then apply the custom document's sections on top. Sections are matched by heading -- custom sections replace matching defaults, new sections are appended. You can also add entirely new sections (e.g., language-specific idioms, team-specific rules) that do not exist in the defaults.
   - **`mode: override`**: The custom document fully replaces the atom's defaults. Use this when your standards are fundamentally different and you want complete control.
4. If no config exists, use the atom's embedded `./references/defaults.md`

Atoms work out of the box with opinionated defaults. Customization is opt-in, not required. Most teams use overlay -- the defaults are good starting points, and typically only a few sections need adjustment.

**Two paths to customization**: Run a refiner (guided interview that generates the standards document) or edit the standards document in `.ai/standards/` directly. Both produce the same result: a file the atom picks up through config resolution. Re-run a refiner or edit the file whenever your standards evolve.

See [docs/configuration.md](configuration.md) for the complete list of valid config keys and what each one does.

## Molecules in Depth

### What they are

Molecules are orchestrated multi-step workflows. Each molecule composes multiple atoms, applying them at the right stage of the workflow. Molecules reference atoms -- they do not duplicate atom content.

### lattice-init

Guided setup experience that bridges the gap between installing Lattice and getting first value.

**Composes**: knowledge-priming

**How it works**:
1. **Scan the project**: Detects language/framework, directory structure, and existing `.ai/` state.
2. **Present findings**: Shows a concise setup status -- what exists, what is missing.
3. **Guided setup**: Suggests refiners in priority order (knowledge-priming first, then architecture, DDD, clean-code). For each gap, the user can run the refiner, skip it, or skip all remaining.
4. **Next steps**: Presents the design-to-review workflow so the user knows what to do next.

Run once per project. If Lattice is already fully configured, acknowledges it and shows the workflow.

### design-blueprint

A complete design workflow that produces an approved blueprint before any code is written.

**Composes**: knowledge-priming, context-anchoring, collaborative-judgment, design-first, clean-architecture, domain-driven-design

**How it works**:
1. **Establish context**: Uses context-anchoring to create or load the feature's living document.
2. **Walk design levels**: Drives through design-first's 5 levels sequentially. At Levels 2-4, applies clean-architecture (layer assignments, dependency direction) and domain-driven-design (aggregate identification, entity/value object classification).
3. **Persist at each level**: After the user approves each level, the approved output is written to the context document. The context document *is* the blueprint.
4. **Finalize**: Writes a design summary with component list, layer assignments, contracts, and a "ready for implementation" marker.

The blueprint stops at Level 4 (Contracts). It does not proceed to Level 5 (Implementation) -- that is code-forge's job.

### code-forge

Generates implementation from an approved blueprint or verbal requirements.

**Composes**: knowledge-priming (always), context-anchoring (always), collaborative-judgment (always), clean-architecture (always), clean-code (always), domain-driven-design (conditional: domain layer), secure-coding (conditional: trust boundaries), test-quality (always when writing tests)

**How it works**:
1. **Load context**: Loads learnings from `.ai/learnings/review-insights.md` (if they exist) to avoid repeating past mistakes. Uses context-anchoring to find and load the feature's blueprint. If none exists, works from verbal requirements -- all atom guardrails still apply.
2. **Plan implementation order**: Classifies components into architectural layers and plans an inside-out build order: Domain → Infrastructure → Application → Interface. Each layer's dependencies already exist when it is built.
3. **Implement per component**: Generates code and tests together. After generating each component, runs a post-generation verification pass — atom self-validation checklists and anti-pattern scans — fixing violations before presenting. Applies clean-code and clean-architecture to all code. Applies DDD only to domain layer code. Applies secure-coding only at trust boundaries.
4. **Cross-component verification**: Checks architectural coherence — interaction flows match the blueprint, dependency direction is correct, no unplanned components, and past learnings don't recur.
5. **Enrich context**: Captures implementation decisions in the living document. Recommends running `/review` before considering the feature complete.

The user chooses a review mode: layer-by-layer (recommended), full autonomy, or component-by-component.

### bug-fix

Investigates, reproduces, and safely fixes a bug with regression protection. This is the defect-driven counterpart to code-forge: it starts from a failing behavior instead of a new requirement.

**Composes**: knowledge-priming (always), context-anchoring (always), collaborative-judgment (always), clean-code (always), test-quality (always), clean-architecture (conditional), domain-driven-design (conditional), secure-coding (conditional)

**How it works**:
1. **Establish bug context**: Loads review learnings if they exist, then uses context-anchoring to load the relevant feature context when available. Clarifies observed vs expected behavior before touching code.
2. **Reproduce and localize**: Requires a failing reproduction before repair — preferably an automated test, otherwise the closest executable reproduction path. Classifies the likely source layer and loads only the atoms relevant to the suspected root cause.
3. **Protect with a regression test**: Converts the reproduction into the smallest failing automated test that faithfully captures the bug. This is the workflow's primary differentiator.
4. **Implement the minimal safe fix**: Repairs the root cause with clean-code always-on and architecture/DDD/security checks loaded only when the defect touches those dimensions.
5. **Verify and capture**: Confirms the regression test is green, checks nearby behavior for non-regression, then records root cause and repair rationale in the living context. Recommends `/review` for larger or riskier fixes.

### refactor-safely

Restructures existing code without changing externally observable behavior. This is the preservation-driven counterpart to code-forge: it starts from structural pain in existing code and requires agreement on the target structure before any refactor edits are made.

**Composes**: knowledge-priming (always), context-anchoring (always), collaborative-judgment (always), clean-code (always), test-quality (always), design-first (conditional), clean-architecture (conditional), domain-driven-design (conditional), secure-coding (conditional)

**How it works**:
1. **Establish refactor context**: Clarifies the current pain, desired structural improvement, and the behavior that must remain unchanged. Loads prior learnings and relevant context documents when available.
2. **Define preservation boundaries and target structure**: Makes the behavioral contract explicit, then proposes the high-level structural plan. For significant refactors, uses design-first selectively at Levels 2-4. No code changes happen until this plan is approved.
3. **Protect with characterization tests**: Locks current behavior with tests strong enough to detect drift during the refactor. This is the workflow's primary differentiator.
4. **Refactor in approved slices**: Applies the structural changes in small, reviewable steps, keeping the characterization tests green and loading architecture/DDD/security atoms only when the refactor touches those concerns.
5. **Verify and capture**: Confirms both behavior preservation and structural improvement, then records the approved target structure, migration choices, and deferred debt in the living context. Recommends `/review` for broad or risky refactors.

### review

A structured, delta-scoped code review that loads atoms conditionally based on what changed. Supports optional process configuration via the review-refiner.

**Composes**: knowledge-priming (always), collaborative-judgment (always), clean-code (always), clean-architecture (conditional), domain-driven-design (conditional), secure-coding (conditional), test-quality (conditional)

**Config**: Optionally reads `.ai/standards/review-standards.md` (produced by the review-refiner or written by hand) to customize atom loading rules, severity classification, report format, scope rules, insight capture, and health logging. When no review-standards document exists, all defaults apply — identical behavior to a review without config. The boundary: if it changes *what an atom checks for*, it belongs in that atom's refiner; if it changes *how the review process works*, it belongs in the review-refiner.

**How it works**:
1. **Identify the delta**: Determines the set of changed files (PR, commit, or specified files).
2. **Classify and load**: Analyzes which layers, domains, and boundaries the delta touches. Loads only the relevant atoms -- a change to a single value object does not trigger the security checklist.
3. **Run targeted validation**: For each loaded atom, runs two passes: the validation checklist (hard rules) and the anti-pattern scan (smell-level issues).
4. **Produce report**: Findings are severity-ordered (critical → warning → suggestion) with specific file locations and concrete fixes. Summary mode by default; full mode on request. Every review ends with a "what's done well" observation.
5. **Capture insights and log**: Appends recurring patterns to `.ai/learnings/review-insights.md` (fed back into code-forge's next session) and logs a structured summary to `.ai/reviews/review-log.md` (project health visibility).

See the [refiner inventory](../README.md#refiners-5) for what each refiner produces and which atom or molecule each one targets.

## The Design-to-Code Pipeline

There are two common entry paths:

```
Planned feature work:
  lattice-init → design-blueprint → code-forge → review

Refactor-driven work:
  refactor-safely → review

Defect-driven work:
  bug-fix → review
```

Feature work starts from requirements and produces an approved blueprint before implementation. Refactor work starts from structural pain and produces an approved target structure plus characterization tests before code reshaping begins. Bug work starts from a failing behavior and produces a failing reproduction before the repair. All paths converge on review for an independent quality pass.

Each stage both consumes and produces artifacts in `.ai/` -- the pipeline is the engine that grows the living context layer. Context anchoring ties the stages together: the context document created during design carries the approved blueprint into implementation, captures approved refactor plans and bug root causes, informs review, and restores full context in any future session.

The context document lifecycle is: **Create** (new feature) → **Load** (resume work) → **Enrich** (capture decisions). All three behaviors require explicit user confirmation -- the AI proposes, the user disposes.

## The `.ai/` Folder

The `.ai/` folder is the living context layer described earlier -- the project's AI-specific memory that grows with every feature cycle. All persistent artifacts produced by the framework live here, organized into subfolders with distinct lifecycles.

### Structure

```
.ai/
├── config.yaml          # Central config (only file at root)
├── standards/           # Refiner-produced customization documents
│   ├── knowledge-base.md
│   ├── clean-code.md
│   ├── clean-architecture.md
│   ├── ddd-principles.md
│   └── review-standards.md
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
| `learnings/` | Accumulated review insights loaded by code-forge, refactor-safely, and bug-fix at session start | Append-only with pruning — capped at ~50 entries |
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
| **Configured by refiners?** | Yes (via `.ai/` config files) | review molecule supports config via review-refiner | N/A |
| **Frequency of use** | Every generation (automatic) | Per feature, bug, or review | As needed -- when standards are first set or evolve |
| **Required?** | Yes (core guardrails) | No (but recommended for structured workflows) | No (atoms work with built-in defaults) |
| **Works standalone?** | Yes | Yes | Yes |
