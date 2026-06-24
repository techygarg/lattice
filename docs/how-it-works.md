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

The second half is the **living context layer**: the `.lattice/` folder. Standards produced by refiners, feature context documents, accumulated review insights, and health logs -- all project-specific, all growing with every feature cycle. The living context layer is the muscle -- it strengthens with use, adapts to the work you do, and makes the base framework increasingly capable.

The two layers interact through a read/write loop. The base framework *reads* from the context layer: atoms load project-specific standards, code-forge, refactor-safely, and bug-fix load past learnings, knowledge-priming loads the project's identity. The pipeline *writes* to the context layer: refiners produce standards documents, design-blueprint and code-forge create and enrich context documents, refactor-safely records approved structural decisions, bug-fix records root cause and repair decisions, and review captures insights and logs health summaries. Each cycle enriches the next.

The payoff compounds over time. After a few feature cycles, atoms aren't applying generic rules -- they're applying *your* rules, informed by *your* review history. Code-forge doesn't repeat mistakes that review already caught. Standards grow more precise as refiners are re-run. Health logs reveal trends across features, not just snapshots. The base framework never changes, but the context layer makes it smarter with every use.

## Skill Inventory

All skills and their invocation commands. Invoke any skill in your AI tool's chat by typing the command.

### Atoms — invoke directly or composed by molecules

| Skill | Command | What it enforces |
|-------|---------|-----------------|
| clean-code | `/clean-code` | Function focus, naming clarity, complexity management, error handling, self-documenting style |
| architecture | `/architecture` | Layer responsibilities, dependency direction, structural rules. Defaults to clean architecture; supports any style via architecture-refiner |
| domain-driven-design | `/domain-driven-design` | Aggregate design, value objects over primitives, entity identity rules, bounded context boundaries |
| secure-coding | `/secure-coding` | Trust boundary awareness, input validation, injection prevention, secrets management |
| test-quality | `/test-quality` | AAA structure, one behavior per test, assertion quality, test isolation, meaningful naming |
| knowledge-priming | `/knowledge-priming` | Loads project-specific context (tech stack, architecture, conventions) so all skills operate with project awareness |
| design-first | `/design-first` | Structured design through 5 progressive levels before any code is written |
| context-anchoring | `/context-anchoring` | Per-feature living documents that capture decisions and reasoning across sessions |
| collaborative-judgment | `/collaborative-judgment` | Surfaces genuine judgment calls or missing/conflicting knowledge instead of silently assuming |
| learning-harvest | `/learning-harvest` | Manages operational learnings lifecycle — load prior patterns, harvest new experiential insights, keep the document tight |
| requirement-quality | `/requirement-quality` | Feature specification quality — completeness, scenario structure, AC verifiability, independence, and implementation slice quality |

### Molecules — invoke to run a full workflow

| Skill | Command | What it does |
|-------|---------|-------------|
| lattice-init | `/lattice-init` | Guided setup — scans project, detects config, suggests refiners, creates `.lattice/config.yaml` |
| refiners-update | `/refiners-update` | Update-mode counterpart to lattice-init — scans existing standards, captures what changed, routes each affected one to its refiner's revise mode, records a git-native change note |
| requirement-forge | `/requirement-forge` | Collaborative feature specification as a senior PM + BA pair — produces epic/feature hierarchy in `.lattice/requirements/` as direct input to design-blueprint |
| design-blueprint | `/design-blueprint` | Complete design workflow through 5 levels, produces an approved blueprint before any code is written |
| code-forge | `/code-forge` | Implements from an approved blueprint or verbal requirements using inside-out layer ordering |
| refactor-safely | `/refactor-safely` | Restructures existing code without changing observable behavior; uses characterization tests as safety net |
| bug-fix | `/bug-fix` | Investigates, reproduces with a failing test, then applies minimal safe repair |
| review | `/review` | Structured delta-scoped code review with severity-ordered findings; captures learnings for future sessions |
| architecture-compass | `/architecture-compass` | Architectural thinking partner for existing repositories — scans codebase, runs structured interview, agrees current state and recommended direction, produces insights document |

### Refiners — invoke to produce project-specific standards

| Skill | Command | Produces |
|-------|---------|---------|
| knowledge-priming-refiner | `/knowledge-priming-refiner` | `.lattice/standards/knowledge-base.md` |
| language-idioms-refiner | `/language-idioms-refiner` | `.lattice/standards/language-idioms.md` |
| architecture-refiner | `/architecture-refiner` | `.lattice/standards/architecture.md` |
| ddd-refiner | `/ddd-refiner` | `.lattice/standards/ddd-principles.md` |
| clean-code-refiner | `/clean-code-refiner` | `.lattice/standards/clean-code.md` |
| review-refiner | `/review-refiner` | `.lattice/standards/review-standards.md` |
| requirement-forge-refiner | `/requirement-forge-refiner` | `.lattice/standards/requirement-standards.md` |

---

## Atoms in Depth

### What they are

Each atom is a single-concern skill file that teaches one engineering principle. It contains the principle's rules, a self-validation checklist (with imperative STOP-and-verify language), an active anti-pattern scan (checkbox format), and a config resolution mechanism. Atoms do not produce artifacts -- they apply their checks during post-generation verification, the same way a skilled developer reviews their own code before presenting it.

### How they work

When an atom is active, it provides two verification tools: a **Self-Validation Checklist** (numbered, labeled checks with imperative STOP language) and an **Active Anti-Pattern Scan** (checkbox format for scanning output). These are used by molecules such as code-forge, refactor-safely, and bug-fix during their verification passes — after generating, reshaping, or repairing code, the AI runs the relevant atom checklists against its output and fixes violations before presenting. This two-pass model (generate, then verify) is more reliable than simultaneous generation and validation.

### Always vs conditional atoms

Not every atom applies to every piece of code. The distinction matters for both standalone use and molecule composition:

**Always apply:**
- **clean-code** -- Every piece of code benefits from SRP, clear naming, managed complexity, and proper error handling.
- **architecture** -- Defaults to clean architecture (layers, dependency direction) but supports any architectural style you document. Structural rules apply universally.
- **knowledge-priming** -- Project context (tech stack, architecture, conventions) is always relevant. Without it, the AI defaults to generic assumptions.
- **learning-harvest** -- Operational learnings from past sessions inform current work; new experiential patterns are proposed for user curation at session end.
- **collaborative-judgment** -- Genuine judgment calls and under-grounded uncertainty should be surfaced, not silently resolved. Composed by molecules alongside other atoms.

**Conditionally apply:**
- **domain-driven-design** -- Only when touching domain layer code. A controller or infrastructure adapter does not need aggregate boundary checks.
- **secure-coding** -- Only when code crosses trust boundaries: HTTP handlers, database queries, external API calls, file I/O, user input processing.
- **test-quality** -- Only when writing test code. AAA structure and test isolation do not apply to production code.
- **requirement-quality** -- Only when writing or validating feature specifications. Composed by `requirement-forge`; can also be invoked standalone to validate a hand-written spec.

### The special ones

Five atoms serve different purposes than the code-quality atoms:

- **knowledge-priming** is a context atom. It loads the project's identity -- tech stack, architecture overview, directory layout, trusted sources, and conventions -- so that all other skills operate with awareness of what the project actually is. Without it, the AI defaults to "the average of the internet." Unlike quality atoms, it has no embedded defaults -- every project's identity is unique. The knowledge base document is created by the `knowledge-priming-refiner` or written by hand.
- **design-first** is a methodology atom, not a code quality atom. It guides structured thinking through 5 progressive levels (Capabilities → Components → Interactions → Contracts → Implementation) before any code is written. It prevents the AI from jumping straight to implementation.
- **context-anchoring** is a persistence mechanism. It manages per-feature living documents that capture decisions, constraints, and reasoning across sessions. It solves the problem of AI context decay -- by message 30+, early decisions get contradicted unless they are written down.
- **learning-harvest** is an experiential knowledge mechanism. It manages the operational learnings lifecycle -- a single cross-cutting document of patterns discovered while doing the work. Unlike standards (rules defined upfront), operational learnings capture what the team keeps learning the hard way or what approaches keep proving effective. The AI proposes; the user confirms what enters the document. Complements context-anchoring (per-feature decisions) with project-wide experiential patterns.
- **collaborative-judgment** is an ambiguity protocol. It ensures the AI surfaces genuine judgment calls with structured options and stops on missing/conflicting grounding instead of silently assuming. Each code-quality atom defines its own Ambiguity Signals (domain-specific gray areas); this atom defines how to present, batch, clarify, and resolve them. It becomes less active as the project's standards grow more specific. See [docs/collaborative-judgment.md](collaborative-judgment.md) for the full design rationale.

### Config resolution

Every code-quality atom supports project-specific customization through the same resolution mechanism:

1. Look for `.lattice/config.yaml` in the repository root
2. Check for the atom's config key (e.g., `paths.clean_code`, `paths.architecture`)
3. If a custom document exists at that path, check its YAML frontmatter for `mode`:
   - **`mode: overlay`** (default, recommended): Read the atom's embedded defaults first, then apply the custom document's sections on top. Sections are matched by heading -- custom sections replace matching defaults, new sections are appended. You can also add entirely new sections (e.g., language-specific idioms, team-specific rules) that do not exist in the defaults.
   - **`mode: override`**: The custom document fully replaces the atom's defaults. Use this when your standards are fundamentally different and you want complete control.
4. If no config exists, use the atom's embedded `./references/defaults.md`
5. **Language adaptation**: If `paths.language_idioms` exists, the atom reads the specific section(s) it needs from the language idioms document and adapts its pseudocode defaults to the project's language. Each atom declares which sections it references (e.g., clean-code reads "Error Handling", "Naming Conventions", etc.). Language idioms take precedence over pseudocode patterns where they conflict. See [docs/configuration.md](configuration.md) for the `language_idioms` key.

The full resolution order is: **defaults → language idioms (if present) → custom overlay (if present)**.

Atoms work out of the box with opinionated defaults. Customization is opt-in, not required. Most teams use overlay -- the defaults are good starting points, and typically only a few sections need adjustment.

**Two paths to customization**: Run a refiner (guided interview that generates the standards document) or edit the standards document in `.lattice/standards/` directly. Both produce the same result: a file the atom picks up through config resolution. Re-run a refiner or edit the file whenever your standards evolve.

See [docs/configuration.md](configuration.md) for the complete list of valid config keys and what each one does.

## Molecules in Depth

### What they are

Molecules are orchestrated multi-step workflows. Each molecule composes multiple atoms, applying them at the right stage of the workflow. Molecules reference atoms -- they do not duplicate atom content.

### Shared pattern: lifecycle molecules

Five molecules share a common session infrastructure: **design-blueprint**, **code-forge**, **bug-fix**, **refactor-safely**, and **review**.

**Always composed** (every session): knowledge-priming, context-anchoring, learning-harvest, collaborative-judgment

**Session lifecycle**:
1. Load operational learnings at session start (learning-harvest Load)
2. Load or create feature context (context-anchoring)
3. Do the molecule-specific work with quality atoms applied as relevant
4. Enrich context with decisions (context-anchoring Enrich)
5. Propose cross-cutting learnings for user confirmation (learning-harvest Harvest)

**Quality atoms** (loaded conditionally based on what the session touches): architecture, clean-code, domain-driven-design, secure-coding, test-quality

Individual descriptions below focus only on what distinguishes each molecule.

---

### lattice-init

Guided setup — bridges installing Lattice and getting first value. Run once per project.

**Composes**: knowledge-priming

Scans the project, presents setup status, suggests refiners in priority order (knowledge-priming first), then shows the design-to-review workflow.

### refiners-update

Update-mode counterpart to `lattice-init` — revises existing standards after a significant change (architecture shift, language switch, new domain rules). Re-runnable; owns no living document.

**Composes**: knowledge-priming

Scans `.lattice/standards/` for existing refiner outputs, captures what changed, then routes each affected standard to its refiner's revise mode and records a git-native `Last updated` change note. Does not create missing standards — that stays with `lattice-init`.

### requirement-forge

Collaborative feature specification as a senior PM + BA pair. Upstream in the pipeline — produces specs that `design-blueprint` consumes.

**Composes**: requirement-quality (always), knowledge-priming (conditional), collaborative-judgment (always)

**Two modes**: collaborative (confirmation gates per phase) or autonomous (drafts everything, then presents).

**Workflow**: Standards check → session resume → intake (existing material or verbal) → epic definition → feature discovery per epic → feature spec per feature (frame confirmed before scenarios) → write apex index. Output: `.lattice/requirements/` folder feeding directly into design-blueprint.

### design-blueprint

Produces an approved blueprint before any code is written.

**Unique atoms**: design-first, architecture, domain-driven-design

**What distinguishes it**: Drives through design-first's 5 progressive levels. At Levels 2-4, applies architecture (layer assignments, dependency direction) and DDD (aggregate identification, entity/value object classification). Each level is persisted to the context document after user approval — the context document *is* the blueprint. Stops at Level 4 (Contracts). Hands off to code-forge.

### code-forge

Generates implementation from an approved blueprint or verbal requirements.

**Unique atoms**: architecture (always), clean-code (always), domain-driven-design (conditional: domain layer), secure-coding (conditional: trust boundaries), test-quality (always when writing tests)

**What distinguishes it**:
- Plans an inside-out build order (Domain → Infrastructure → Application → Interface)
- Generates code and tests together per component
- Post-generation verification: runs atom self-validation checklists and anti-pattern scans, fixes violations before presenting
- Cross-component verification: architectural coherence, dependency direction, no unplanned scope, past learnings don't recur
- User chooses review mode: layer-by-layer (recommended), full autonomy, or component-by-component
- Recommends `/review` on completion

### bug-fix

Investigate, reproduce, and safely fix a bug with regression protection. Starts from a failing behavior, not a new requirement.

**Unique atoms**: clean-code (always), test-quality (always), architecture/DDD/secure-coding (conditional on root cause)

**What distinguishes it**:
- Requires a failing reproduction before repair (automated test preferred)
- Localizes root cause before editing — classifies source layer, loads only relevant atoms
- Smallest failing test that captures the bug — this is the workflow's primary differentiator
- Minimal safe fix without architectural backsliding
- Verification: regression test green, preservation baseline intact, no side effects
- Recommends `/review` for larger fixes

### refactor-safely

Restructure existing code without changing observable behavior. Starts from structural pain, requires agreed target structure before any edits.

**Unique atoms**: clean-code (always), test-quality (always), design-first (conditional: significant structural changes), architecture/DDD/secure-coding (conditional)

**What distinguishes it**:
- Zero Refactor Rule: no structural code changes until user approves target structure
- Characterization tests lock current behavior first — this is the workflow's primary differentiator
- For significant refactors, uses design-first selectively at Levels 2-4
- Refactors in small green steps: each slice keeps characterization tests passing
- Deviation rule: pause immediately if approved plan becomes unsafe
- Recommends `/review` for broad refactors

### architecture-compass

Architectural thinking partner for existing repositories. Orients by agreeing current state and recommended direction — does not execute transformation.

**Composes**: knowledge-priming (always), architecture (always), domain-driven-design (conditional: strategic only), collaborative-judgment (always)

**Scoped to one repository, module, or folder.**

**Workflow**:
1. Load or resume from existing `.lattice/insights/architecture.md`
2. Silent codebase scan (15-25 targeted reads, archaeology pass)
3. Four-act interview: Burning Platform, History, Vision, Guardrails
4. Current architecture agreement (Mermaid diagram, explicit confirmation gate)
5. Recommended direction (minimum viable, explicit confirmation gate, valid stopping point)
6. Gap assessment and 2-3 first moves with success criteria
7. Write `.lattice/insights/architecture.md`

### review

Structured delta-scoped code review. Loads quality atoms conditionally based on what changed.

**Unique atoms**: clean-code (always), architecture/DDD/secure-coding/test-quality (conditional on delta)

**Config**: Optionally reads `.lattice/standards/review-standards.md` (from review-refiner) to customize atom loading, severity classification, report format, scope rules. Boundary: *what an atom checks* → atom's refiner; *how the review process works* → review-refiner.

**What distinguishes it**:
- Delta-scoped: only reviews what changed, not entire codebase
- Conditional atom loading: analyzes which layers/domains/boundaries the delta touches
- Two-pass validation per atom: checklist (hard rules) then anti-pattern scan (smells)
- Severity-ordered report (critical → warning → suggestion) with concrete fixes
- Every review ends with "what's done well"
- Logs structured summary to `.lattice/reviews/review-log.md` for project health trends

See [Refiners in Depth](#refiners-in-depth) below for what each refiner produces and which atom or molecule it targets.

## Refiners in Depth

Refiners are optional. Atoms work with opinionated embedded defaults out of the box. Run a refiner when you want to tailor those defaults to your project. Each refiner runs a guided interview and writes a standards document to `.lattice/standards/` — the atom reads that document on every subsequent invocation via config resolution.

| Refiner | Produces | Consumed by |
|---------|----------|-------------|
| **knowledge-priming-refiner** | `.lattice/standards/knowledge-base.md` — project identity, tech stack, directory layout, trusted sources, conventions | All atoms and molecules (via knowledge-priming atom) |
| **language-idioms-refiner** | `.lattice/standards/language-idioms.md` — language-specific error handling, type system, naming, testing, DI patterns | clean-code, architecture, domain-driven-design, test-quality, secure-coding |
| **architecture-refiner** | `.lattice/standards/architecture.md` — layer structure and dependency rules. Supports clean architecture (default), hexagonal, modular monolith, or any custom style | architecture atom |
| **ddd-refiner** | `.lattice/standards/ddd-principles.md` — aggregate design, value object rules, bounded context constraints tailored to your domain | domain-driven-design atom |
| **clean-code-refiner** | `.lattice/standards/clean-code.md` — team-specific coding standards, thresholds, and conventions | clean-code atom |
| **review-refiner** | `.lattice/standards/review-standards.md` — atom loading rules, severity classification, report format, scope rules for the review molecule | review molecule |
| **requirement-forge-refiner** | `.lattice/standards/requirement-standards.md` — epic/feature definitions, scenario structure, AC format, priority notation, status workflow, naming conventions tailored to the team's product process | `requirement-quality` atom (via config resolution); atom is composed by `requirement-forge` molecule |

> **No refiner for test-quality and secure-coding** — these atoms have strong embedded defaults that work well for most teams. To customize them, write `.lattice/standards/test-quality.md` or `.lattice/standards/secure-coding.md` by hand and point to them via `paths.test_quality` / `paths.secure_coding` in `.lattice/config.yaml`.

**Two paths to a standards document**: Run the refiner (guided interview → file created for you) or write the file directly in `.lattice/standards/`. Both produce the same result — the atom only cares about the document, not how it was created. Re-run a refiner or edit the file whenever your standards evolve.

See [docs/configuration.md](configuration.md) for the complete list of `.lattice/config.yaml` keys that wire these documents to their atoms.

## The Design-to-Code Pipeline

There are two common entry paths:

```
Planned feature work (full pipeline):
  lattice-init → requirement-forge → design-blueprint → code-forge → review

Planned feature work (design already clear):
  lattice-init → design-blueprint → code-forge → review

Refactor-driven work:
  refactor-safely → review

Defect-driven work:
  bug-fix → review

Architectural orientation (existing codebase):
  architecture-compass → refactor-safely / design-blueprint / code-forge (per first move)
```

Feature work starts from requirements and produces an approved blueprint before implementation. `requirement-forge` is optional but recommended when the feature scope or problem is not yet fully clear — it produces structured feature specs that `design-blueprint` consumes directly. Refactor work starts from structural pain and produces an approved target structure plus characterization tests before code reshaping begins. Bug work starts from a failing behavior and produces a failing reproduction before the repair. All paths converge on review for an independent quality pass.

Each stage both consumes and produces artifacts in `.lattice/` -- the pipeline is the engine that grows the living context layer. Context anchoring ties the stages together: the context document created during design carries the approved blueprint into implementation, captures approved refactor plans and bug root causes, informs review, and restores full context in any future session.

The context document lifecycle is: **Create** (new feature) → **Load** (resume work) → **Enrich** (capture decisions). All three behaviors require explicit user confirmation -- the AI proposes, the user disposes.

## The `.lattice/` Folder

The `.lattice/` folder is the living context layer described earlier -- the project's AI-specific memory that grows with every feature cycle. All persistent artifacts produced by the framework live here, organized into subfolders with distinct lifecycles.

### Structure

```
.lattice/
├── config.yaml              # Central config (only file at root)
├── standards/               # Refiner-produced customization documents
│   ├── knowledge-base.md
│   ├── clean-code.md
│   ├── architecture.md
│   ├── ddd-principles.md
│   ├── review-standards.md
│   └── requirement-standards.md
├── requirements/            # Feature specs produced by requirement-forge
│   ├── index.md             # Epic/feature apex index
│   └── features/
│       └── <feature>.md
├── context/                 # Per-feature living documents
│   └── <feature>.md
├── learnings/               # Operational learnings managed by learning-harvest atom
│   └── operational-learnings.md
├── reviews/                 # Review log for project health
│   └── review-log.md
└── insights/                # Architectural insights produced by architecture-compass
    └── architecture.md
```

### Subfolder Lifecycles

| Subfolder | Purpose | Lifecycle |
|-----------|---------|-----------|
| `standards/` | Refiner-produced customization docs consumed by atoms via config resolution | Stable — set once during project setup, rarely changed |
| `requirements/` | Epic/feature specs produced by requirement-forge. `index.md` is the apex; `features/` holds per-feature files | Per cycle — created when features are specced, updated when specs evolve. Feeds design-blueprint. |
| `context/` | Per-feature living documents managed by context-anchoring | Per feature — created when feature starts, enriched during design and implementation |
| `learnings/` | Operational learnings managed by `learning-harvest` atom — accumulated patterns from design, implementation, review, and repair sessions. Loaded at session start, harvested at session end. | Append-only with self-regulating tightening — atom proposes consolidation when document grows dense |
| `reviews/` | Review log entries for project health visibility | Rolling window — capped at ~20 entries, older entries summarized |
| `insights/` | Architectural insights document produced by architecture-compass | One per project — updated as direction evolves |

### Convention

**Rule**: All persistent artifacts go into subfolders. Never place files directly in `.lattice/` root except `config.yaml`.

This convention ensures the folder stays organized as the framework adds new capabilities. Every new output type gets its own subfolder with a clear lifecycle.

## How Atoms, Molecules, and Refiners Differ

| Dimension | Atoms | Molecules | Refiners |
|-----------|-------|-----------|----------|
| **Purpose** | Teach one principle | Orchestrate a workflow | Optionally customize atom defaults |
| **Invocation** | Auto-activate based on context, or invoked by molecules | User invokes explicitly (e.g., `/design-blueprint`) | User invokes when customization is needed (e.g., `/architecture-refiner`) |
| **Artifacts produced** | None (inline checks) | Blueprints, reviews, context documents | `.lattice/` config files |
| **Composes others?** | No | Yes (composes atoms) | No |
| **Configured by refiners?** | Yes (via `.lattice/` config files) | review molecule supports config via review-refiner | N/A |
| **Frequency of use** | Every generation (automatic) | Per feature, bug, or review | As needed -- when standards are first set or evolve |
| **Required?** | Yes (core guardrails) | No (but recommended for structured workflows) | No (atoms work with built-in defaults) |
| **Works standalone?** | Yes | Yes | Yes |
