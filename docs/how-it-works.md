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
| collaborative-judgment | `/collaborative-judgment` | Surfaces genuine judgment calls with structured options instead of silently assuming |
| requirement-quality | `/requirement-quality` | Feature specification quality — completeness, scenario structure, AC verifiability, independence, and implementation slice quality |

### Molecules — invoke to run a full workflow

| Skill | Command | What it does |
|-------|---------|-------------|
| lattice-init | `/lattice-init` | Guided setup — scans project, detects config, suggests refiners, creates `.lattice/config.yaml` |
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
- **collaborative-judgment** -- Genuine judgment calls should be surfaced with options, not silently resolved. Composed by molecules alongside other atoms.

**Conditionally apply:**
- **domain-driven-design** -- Only when touching domain layer code. A controller or infrastructure adapter does not need aggregate boundary checks.
- **secure-coding** -- Only when code crosses trust boundaries: HTTP handlers, database queries, external API calls, file I/O, user input processing.
- **test-quality** -- Only when writing test code. AAA structure and test isolation do not apply to production code.
- **requirement-quality** -- Only when writing or validating feature specifications. Composed by `requirement-forge`; can also be invoked standalone to validate a hand-written spec.

### The special ones

Four atoms serve different purposes than the code-quality atoms:

- **knowledge-priming** is a context atom. It loads the project's identity -- tech stack, architecture overview, directory layout, trusted sources, and conventions -- so that all other skills operate with awareness of what the project actually is. Without it, the AI defaults to "the average of the internet." Unlike quality atoms, it has no embedded defaults -- every project's identity is unique. The knowledge base document is created by the `knowledge-priming-refiner` or written by hand.
- **design-first** is a methodology atom, not a code quality atom. It guides structured thinking through 5 progressive levels (Capabilities → Components → Interactions → Contracts → Implementation) before any code is written. It prevents the AI from jumping straight to implementation.
- **context-anchoring** is a persistence mechanism. It manages per-feature living documents that capture decisions, constraints, and reasoning across sessions. It solves the problem of AI context decay -- by message 30+, early decisions get contradicted unless they are written down.
- **collaborative-judgment** is an ambiguity protocol. It ensures the AI surfaces genuine judgment calls with structured options instead of silently assuming. Each code-quality atom defines its own Ambiguity Signals (domain-specific gray areas); this atom defines how to present, batch, and resolve them. It becomes less active as the project's standards grow more specific. See [docs/collaborative-judgment.md](collaborative-judgment.md) for the full design rationale.

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

### lattice-init

Guided setup experience that bridges the gap between installing Lattice and getting first value.

**Composes**: knowledge-priming

**How it works**:
1. **Scan the project**: Detects language/framework, directory structure, and existing `.lattice/` state.
2. **Present findings**: Shows a concise setup status -- what exists, what is missing.
3. **Guided setup**: Suggests refiners in priority order (knowledge-priming first, then architecture, DDD, clean-code). For each gap, the user can run the refiner, skip it, or skip all remaining.
4. **Next steps**: Presents the design-to-review workflow so the user knows what to do next.

Run once per project. If Lattice is already fully configured, acknowledges it and shows the workflow.

### requirement-forge

Collaboratively forges feature specifications as a senior PM + BA pair. This is the upstream molecule in the pipeline — it produces the feature specs that `design-blueprint` consumes.

**Composes**: requirement-quality (always), knowledge-priming (conditional: when a codebase exists), collaborative-judgment (always)

**Two modes**: collaborative (default) — confirmation gate at each phase; autonomous — drafts everything silently, then presents the complete output for review.

**How it works**:
1. **Standards check**: Triggers `requirement-quality` atom, which loads `paths.requirement_standards` via config resolution (overlay/override/defaults). If no standards doc exists, states active defaults explicitly so the user knows what will govern the session, and recommends running `requirement-forge-refiner` as a one-time setup.
2. **Session resume**: Scans `.lattice/requirements/` for existing documents. Classifies feature files as structurally incomplete (missing sections), quality-suspect (present but firing an atom anti-pattern), or complete. Surfaces each issue per file — user decides to fix, skip, or continue. Provides explicit re-entry points: add features to existing epic → Step 4; create new epic → Step 3; update a spec → Step 5.
3. **Intake**: Opens with a single question asking whether existing material (PRDs, feature files, Jira exports, Confluence pages) exists before assuming blank-slate. If material is provided (file paths, pasted text, links), reads silently, checks for wrong granularity (ACs masquerading as features, epics masquerading as features) and contradictions (surfaces each conflict for user resolution before including in the hypothesis). In listening mode, prompts for a verbal description. Does not advance until the synthesis is confirmed. Single-feature fast path: if synthesis reveals only 1–3 features, offers to spec them directly without forcing a full epic pipeline.
4. **Epic definition**: Proposes an epic list with descriptions and scope boundaries. Challenges epics that are too narrow or too broad. For large products (4+ epics or 15+ features), proposes a session focus to keep work tractable. Confirmation gate before feature breakdown begins.
5. **Feature discovery (per epic)**: Proposes the feature breakdown per epic. Actively challenges misclassified items at this step — technical tasks, micro-behaviors (single ACs), and cross-epic features are flagged before the atom checklist runs. Confirmation gate per epic.
6. **Feature spec (per feature)**: Two-level spec — frame (dependencies, problem statement, scope, boundary conditions) confirmed before scenarios. Scenarios specced one at a time in implementation order; failure paths explicitly probed after the first success scenario. Implementation slices proposed after all scenarios confirmed. `requirement-quality` Self-Validation Checklist and Anti-Pattern Scan run before writing each file — violations fixed, ambiguity signals surfaced via `collaborative-judgment`.
7. **Write apex index**: Writes `.lattice/requirements/index.md` with epic/feature glossary, status, priority, and dependency table.

The output is a `.lattice/requirements/` folder that `design-blueprint` can consume directly — the "requirement doc link" in each feature's context anchor document points here.

### design-blueprint

A complete design workflow that produces an approved blueprint before any code is written.

**Composes**: knowledge-priming, context-anchoring, collaborative-judgment, design-first, architecture, domain-driven-design

**How it works**:
1. **Establish context**: Uses context-anchoring to create or load the feature's living document.
2. **Walk design levels**: Drives through design-first's 5 levels sequentially. At Levels 2-4, applies architecture (layer assignments, dependency direction) and domain-driven-design (aggregate identification, entity/value object classification).
3. **Persist at each level**: After the user approves each level, the approved output is written to the context document. The context document *is* the blueprint.
4. **Finalize**: Writes a design summary with component list, layer assignments, contracts, and a "ready for implementation" marker.

The blueprint stops at Level 4 (Contracts). It does not proceed to Level 5 (Implementation) -- that is code-forge's job.

### code-forge

Generates implementation from an approved blueprint or verbal requirements.

**Composes**: knowledge-priming (always), context-anchoring (always), collaborative-judgment (always), architecture (always), clean-code (always), domain-driven-design (conditional: domain layer), secure-coding (conditional: trust boundaries), test-quality (always when writing tests)

**How it works**:
1. **Load context**: Loads learnings from `.lattice/learnings/review-insights.md` (if they exist) to avoid repeating past mistakes. Uses context-anchoring to find and load the feature's blueprint. If none exists, works from verbal requirements -- all atom guardrails still apply.
2. **Plan implementation order**: Classifies components into architectural layers and plans an inside-out build order: Domain → Infrastructure → Application → Interface. Each layer's dependencies already exist when it is built.
3. **Implement per component**: Generates code and tests together. After generating each component, runs a post-generation verification pass — atom self-validation checklists and anti-pattern scans — fixing violations before presenting. Applies clean-code and architecture to all code. Applies DDD only to domain layer code. Applies secure-coding only at trust boundaries.
4. **Cross-component verification**: Checks architectural coherence — interaction flows match the blueprint, dependency direction is correct, no unplanned components, and past learnings don't recur.
5. **Enrich context**: Captures implementation decisions in the living document. Recommends running `/review` before considering the feature complete.

The user chooses a review mode: layer-by-layer (recommended), full autonomy, or component-by-component.

### bug-fix

Investigates, reproduces, and safely fixes a bug with regression protection. This is the defect-driven counterpart to code-forge: it starts from a failing behavior instead of a new requirement.

**Composes**: knowledge-priming (always), context-anchoring (always), collaborative-judgment (always), clean-code (always), test-quality (always), architecture (conditional), domain-driven-design (conditional), secure-coding (conditional)

**How it works**:
1. **Establish bug context**: Loads review learnings if they exist, then uses context-anchoring to load the relevant feature context when available. Clarifies observed vs expected behavior before touching code.
2. **Reproduce and localize**: Requires a failing reproduction before repair — preferably an automated test, otherwise the closest executable reproduction path. Classifies the likely source layer and loads only the atoms relevant to the suspected root cause.
3. **Protect with a regression test**: Converts the reproduction into the smallest failing automated test that faithfully captures the bug. This is the workflow's primary differentiator.
4. **Implement the minimal safe fix**: Repairs the root cause with clean-code always-on and architecture/DDD/security checks loaded only when the defect touches those dimensions.
5. **Verify and capture**: Confirms the regression test is green, checks nearby behavior for non-regression, then records root cause and repair rationale in the living context. Recommends `/review` for larger or riskier fixes.

### refactor-safely

Restructures existing code without changing externally observable behavior. This is the preservation-driven counterpart to code-forge: it starts from structural pain in existing code and requires agreement on the target structure before any refactor edits are made.

**Composes**: knowledge-priming (always), context-anchoring (always), collaborative-judgment (always), clean-code (always), test-quality (always), design-first (conditional), architecture (conditional), domain-driven-design (conditional), secure-coding (conditional)

**How it works**:
1. **Establish refactor context**: Clarifies the current pain, desired structural improvement, and the behavior that must remain unchanged. Loads prior learnings and relevant context documents when available.
2. **Define preservation boundaries and target structure**: Makes the behavioral contract explicit, then proposes the high-level structural plan. For significant refactors, uses design-first selectively at Levels 2-4. No code changes happen until this plan is approved.
3. **Protect with characterization tests**: Locks current behavior with tests strong enough to detect drift during the refactor. This is the workflow's primary differentiator.
4. **Refactor in approved slices**: Applies the structural changes in small, reviewable steps, keeping the characterization tests green and loading architecture/DDD/security atoms only when the refactor touches those concerns.
5. **Verify and capture**: Confirms both behavior preservation and structural improvement, then records the approved target structure, migration choices, and deferred debt in the living context. Recommends `/review` for broad or risky refactors.

### architecture-compass

An architectural thinking partner for existing repositories. Orients a team by agreeing on the current architectural state and a recommended direction — before any code changes begin.

**Composes**: knowledge-priming (always), architecture (always), domain-driven-design (conditional: strategic only, when domain complexity warrants), collaborative-judgment (always)

**Scoped to one repository, module, or folder.** Does not execute transformation — it orients.

**How it works**:
1. **Load or resume**: Checks for an existing `.lattice/insights/architecture.md`. If found, reads the Session Status table and resumes from the earliest incomplete phase. If not, starts fresh.
2. **Silent scan**: Reads the codebase strategically (15–25 targeted reads). Performs an archaeology pass (dead code, duplicates, hidden coupling) and identifies seams and their viability. Forms a hypothesis: is the problem architectural drift (eroded intent) or architectural mismatch (wrong pattern for the domain)?
3. **Four-act interview**: Runs a short, adaptive interview informed by the scan. Acts: Burning Platform (why now), History (how you got here, what failed), Vision (what you want to be able to do), Guardrails (what cannot change). Vision answers are architectural inputs — they directly shape the recommended direction.
4. **Current architecture agreement**: Presents the scan findings as a structured map with a Mermaid diagram. Asks the team to correct or confirm. Does not advance until explicitly agreed.
5. **Recommended direction**: Proposes a target architectural direction tailored to this codebase — not a generic template. Includes a target diagram, annotated folder tree, and (when applicable) a bounded context map. Minimum viable direction principle: proposes the simplest structure that resolves the stated pain. Does not advance until explicitly agreed. Valid stopping point — session can end here.
6. **Gap assessment and first moves**: Derives the structural delta (must change / should change / defer / leave alone) and identifies 2–3 first moves with molecule guidance and success criteria.
7. **Write insights document**: Produces `.lattice/insights/architecture.md` — a progressive document that builds as the session advances. Complete enough that a future session or new team member can resume without re-briefing.

### review

A structured, delta-scoped code review that loads atoms conditionally based on what changed. Supports optional process configuration via the review-refiner.

**Composes**: knowledge-priming (always), collaborative-judgment (always), clean-code (always), architecture (conditional), domain-driven-design (conditional), secure-coding (conditional), test-quality (conditional)

**Config**: Optionally reads `.lattice/standards/review-standards.md` (produced by the review-refiner or written by hand) to customize atom loading rules, severity classification, report format, scope rules, insight capture, and health logging. When no review-standards document exists, all defaults apply — identical behavior to a review without config. The boundary: if it changes *what an atom checks for*, it belongs in that atom's refiner; if it changes *how the review process works*, it belongs in the review-refiner.

**How it works**:
1. **Identify the delta**: Determines the set of changed files (PR, commit, or specified files).
2. **Classify and load**: Analyzes which layers, domains, and boundaries the delta touches. Loads only the relevant atoms -- a change to a single value object does not trigger the security checklist.
3. **Run targeted validation**: For each loaded atom, runs two passes: the validation checklist (hard rules) and the anti-pattern scan (smell-level issues).
4. **Produce report**: Findings are severity-ordered (critical → warning → suggestion) with specific file locations and concrete fixes. Summary mode by default; full mode on request. Every review ends with a "what's done well" observation.
5. **Capture insights and log**: Appends recurring patterns to `.lattice/learnings/review-insights.md` (fed back into code-forge's next session) and logs a structured summary to `.lattice/reviews/review-log.md` (project health visibility).

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
├── learnings/               # Accumulated review insights
│   └── review-insights.md
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
| `learnings/` | Accumulated review insights loaded by code-forge, refactor-safely, and bug-fix at session start | Append-only with pruning — capped at ~50 entries |
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
