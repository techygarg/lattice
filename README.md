# Lattice

Composable AI skills that teach assistants structured thinking -- design-first, context-aware, and architecture-guided.

## What is Lattice?

AI coding assistants are fast -- but fast without discipline means jumping straight to code, silently making design decisions, forgetting constraints mid-conversation, and producing output that nobody reviewed against real engineering standards.

Lattice addresses this with two layers working together. The **base framework** embeds battle-tested engineering disciplines -- Clean Architecture, Domain-Driven Design, design-first methodology, secure coding, and more -- as composable skills organized in three tiers (atoms, molecules, refiners). The **living context layer** (the `.ai/` folder) accumulates project-specific standards, feature decisions, review insights, and health trends -- growing richer with every feature cycle.

The base framework provides the rails: design before code, validate structure as you build, enforce domain boundaries while modeling. The living context layer makes those rails project-specific: your architecture standards, your coding conventions, your accumulated learnings. Together they create AI that self-improves -- after a few cycles, atoms aren't applying generic rules, they're applying *your* rules, informed by *your* history.

## The Three Tiers

Lattice organizes skills into three tiers, each solving a different problem:

**Atoms** are single-principle guardrails. Each atom teaches one discipline -- clean code, secure coding, DDD -- and applies its validation checks inline during generation. Atoms are the building blocks that molecules compose.

**Molecules** are multi-step workflows that compose atoms into end-to-end processes. A molecule orchestrates which atoms apply, when, and in what order -- so you get design-first thinking, architectural validation, and code quality checks without manually invoking each one.

**Refiners** are optional. Every atom ships with sensible defaults that work out of the box. If you want to tailor those defaults -- enhance a section, adjust thresholds, or add project-specific rules -- refiners guide you through it via a structured interview, producing `.ai/` config files that atoms pick up automatically. You can also edit those config files directly. Refiners are a convenience, not a requirement.

|               | Purpose                              | Standalone? | Composes others? | Produces artifacts?         |
|---------------|--------------------------------------|-------------|------------------|-----------------------------|
| **Atoms**     | Single-principle guardrails          | Yes         | No               | No (inline checks)          |
| **Molecules** | Multi-step workflows                 | Yes         | Yes (atoms)      | Yes (blueprints, reviews)   |
| **Refiners**  | Optional config customization        | Yes         | No               | Yes (`.ai/` config files)   |

## Skill Inventory

### Atoms (8)

| Skill | What it does |
|-------|-------------|
| **clean-code** | Enforces function focus, naming clarity, complexity management, error handling, and self-documenting style |
| **clean-architecture** | Validates layer responsibilities, dependency direction, command/query flow separation |
| **domain-driven-design** | Enforces aggregate design, value objects over primitives, entity identity rules, bounded context boundaries |
| **secure-coding** | Applies trust boundary awareness, input validation, injection prevention, secrets management |
| **test-quality** | Enforces AAA structure, one behavior per test, assertion quality, test isolation, meaningful naming |
| **knowledge-priming** | Loads project-specific context (tech stack, architecture, conventions) so all skills operate with awareness of the real project |
| **design-first** | Guides structured design through 5 progressive levels (Capabilities, Components, Interactions, Contracts, Implementation) |
| **context-anchoring** | Manages per-feature living documents that capture decisions and reasoning across sessions |

### Molecules (4)

| Skill | What it does | Atoms composed |
|-------|-------------|----------------|
| **lattice-init** | Guided setup -- scans the project, detects existing config, suggests refiners in priority order, creates `.ai/config.yaml` | knowledge-priming |
| **design-blueprint** | Runs a complete design workflow -- from context through progressive design levels to an approved blueprint | knowledge-priming, context-anchoring, design-first, clean-architecture, domain-driven-design |
| **code-forge** | Generates implementation from an approved blueprint or verbal requirements using inside-out layer ordering | knowledge-priming, context-anchoring, clean-architecture, clean-code, domain-driven-design, secure-coding, test-quality |
| **review** | Performs a structured, delta-scoped code review with severity-ordered findings. Supports optional process config via review-refiner | knowledge-priming (always), clean-code (always), clean-architecture, domain-driven-design, secure-coding, test-quality (conditional) |

### Refiners (5)

| Skill | What it produces |
|-------|-----------------|
| **architecture-refiner** | `.ai/standards/clean-architecture.md` -- project-specific clean architecture principles for the clean-architecture atom |
| **ddd-refiner** | `.ai/standards/ddd-principles.md` -- project-specific DDD guardrails for the domain-driven-design atom |
| **clean-code-refiner** | `.ai/standards/clean-code.md` -- project-specific coding standards for the clean-code atom |
| **knowledge-priming-refiner** | `.ai/standards/knowledge-base.md` -- project identity, tech stack, directory layout, and trusted sources |
| **review-refiner** | `.ai/standards/review-standards.md` -- project-specific review process configuration for the review molecule |

## The Pipeline

Lattice skills form a design-to-code lifecycle:

```
  lattice-init          design-blueprint             code-forge                review
  ─────────────────     ─────────────────            ─────────────────         ─────────────────
  Guided setup          Design before coding         Implement from blueprint  Audit the delta
  ┌─────────────────┐   ┌─────────────────┐          ┌─────────────────┐       ┌─────────────────┐
  │ Scan project    │   │ Level 1: Caps   │          │ Plan layers     │       │ Classify delta  │
  │ Detect config   │   │ Level 2: Comps  │          │ Inside-out build│       │ Load atoms      │
  │ Suggest refiners│──▶│ Level 3: Flow   │──────▶   │ Code + tests    │──────▶│ Run checklists  │
  │ Create .ai/     │   │ Level 4: API    │          │ Cross-component │       │ Severity report  │
  │ config          │   │                 │          │ verify          │       │                 │
  │                 │   │ Approved        │          │                 │       │                 │
  │                 │   │ Blueprint       │          │                 │       │                 │
  └─────────────────┘   └─────────────────┘          └─────────────────┘       └─────────────────┘
  One-time project      Persists to context doc      Honors blueprint          Conditional atoms
  setup
```

**Init** (one-time): `/lattice-init` scans the project and walks through refiner setup. **Design**: `design-blueprint` walks through progressive design levels and persists the approved blueprint. **Implement**: `code-forge` builds inside-out from the blueprint (or from verbal requirements). **Review**: `review` audits the delta, loading only the atoms relevant to what changed.

Each stage both consumes and produces artifacts in `.ai/` -- the pipeline is the engine that grows the living context layer.

Context anchoring ties sessions together -- the context document created during design carries decisions forward into implementation and review.

## Getting Started

1. **Install skills into your project**: Lattice will be available as a proper plugin. For local testing after cloning the repo, use the install script to copy skills into your project:
   ```bash
   git clone <lattice-repo-url>
   cd lattice
   ./tools/install.sh /path/to/your-project/skill-folder
   ```
   This copies all 17 skills (flattened) into `<project>/.claude/skills/` where Claude Code can discover them.

2. **Run `/lattice-init`** (recommended): Guided setup experience -- scans your project, suggests which refiners to run, and creates the `.ai/config.yaml`. This is the fastest path from install to first value.

3. **Or customize manually** (optional): Atoms ship with opinionated defaults that work immediately. If you prefer to set up manually instead of using `/lattice-init`, you have two paths:
   - **Run a refiner** -- a guided interview that produces the config file for you:
     ```
     /architecture-refiner       # Tailor layer structure and dependency rules
     /ddd-refiner                # Tailor domain modeling guardrails
     /clean-code-refiner         # Tailor coding standards and thresholds
     /knowledge-priming-refiner  # Capture project identity and tech stack
     /review-refiner             # Customize the review process (atom loading, severity, report format)
     ```
   - **Edit directly** -- create or modify standards documents in `.ai/standards/` by hand (see [how-it-works](docs/how-it-works.md#customizing-atom-defaults) for the format).

   Refiners support enhancing specific sections (overlay mode), adding new sections, or replacing defaults entirely (override mode). Re-run a refiner or edit the config file whenever your standards evolve.

4. **Design a feature**: Invoke `/design-blueprint` to walk through progressive design levels before writing code.

5. **Implement**: Invoke `/code-forge` to generate implementation from the approved blueprint.

6. **Review**: Invoke `/review` to audit code changes against the relevant quality atoms.

Atoms also work standalone -- they activate automatically based on what you're doing (writing domain code triggers DDD, handling user input triggers secure-coding, etc.).

### The `.ai/` folder

The `.ai/` folder is Lattice's living context layer -- the second half of the architecture. It stores all project-specific artifacts that grow with every feature cycle:

```
.ai/
├── config.yaml      # Central config (only file at root)
├── standards/       # Refiner-produced customization docs
│   └── review-standards.md  # (optional) Review process config
├── context/         # Per-feature living documents
├── learnings/       # Accumulated review insights (fed back into code-forge)
└── reviews/         # Review log for project health visibility
```

All persistent outputs go into subfolders — never `.ai/` root except `config.yaml`. See [docs/how-it-works.md](docs/how-it-works.md#the-ai-folder) for lifecycle details.

## Learn More

See [docs/how-it-works.md](docs/how-it-works.md) for the conceptual deep dive -- how atoms compose, how config resolution works, and how the tiers differ.

## License

MIT
