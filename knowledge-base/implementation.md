# Skills Framework: Implementation Blueprint

> The source-of-truth document for building the composable AI skills framework as a standalone publishable plugin. Every decision here traces back to our [strategy.md](strategy.md) discussions and is informed by deep analysis of three leading open-source repositories.

**Author**: Rahul Garg, Principal Engineer, ThoughtWorks
**Status**: Ready for implementation
**Last Updated**: 2026-02-26

---

## Table of Contents

1. [Competitive Landscape & What We Borrow](#1-competitive-landscape--what-we-borrow)
2. [Repository Structure](#2-repository-structure)
3. [Skill Format Specification](#3-skill-format-specification)
4. [Atom Specifications](#4-atom-specifications)
5. [Molecule Specifications](#5-molecule-specifications)
6. [Crafter Specifications](#6-crafter-specifications)
7. [Configuration Schema](#7-configuration-schema)
8. [Plugin Infrastructure](#8-plugin-infrastructure)
9. [Context Injection: Automatic DDD Activation](#9-context-injection-automatic-ddd-activation)
10. [Skill Development Methodology](#10-skill-development-methodology-using-anthropics-skill-creator)
11. [Implementation Phases](#11-implementation-phases)
12. [Key Design Decisions](#12-key-design-decisions)
13. [Future Scope](#13-future-scope)

---

## 1. Competitive Landscape & What We Borrow

Three repositories define the current state of AI skill frameworks. We analyzed each deeply and cherry-picked the best patterns from all three rather than forking any single one.

### 1.1 Superpowers (67k stars)

**Repository**: https://github.com/obra/superpowers

**What it is**: A process-oriented skills framework and software development methodology. Skills teach AI *how to think* through workflows (brainstorm -> plan -> implement -> review), not just *what to produce*. 15 skills covering TDD, debugging, planning, code review, and git worktrees.

**What we borrow**:

- **Plugin infrastructure**: `.claude-plugin/plugin.json`, `.cursor-plugin/plugin.json`, `.codex/`, `.opencode/` -- proven multi-platform packaging that we adopt directly.
- **Hooks system**: `hooks/hooks.json` with `SessionStart` matcher for auto-injecting context at session start. We use this for knowledge priming injection.
- **Commands directory**: `commands/*.md` as thin wrappers that invoke skills. We use this pattern for our molecule entry points.
- **Namespace cross-references**: `superpowers:skill-name` pattern for referencing skills. We adopt `framework:skill-name` for molecule-to-atom references, which avoids personal skill override conflicts.
- **Skill resolution**: `lib/skills-core.js` with `findSkillsInDir()` (recursive, max depth 3), `extractFrontmatter()`, and `resolveSkillPath()`. This validates that our hybrid subdirectory layout works with recursive discovery.
- **Philosophy alignment**: Process-oriented, not task-oriented. Skills are mandatory workflows, not suggestions. This matches our strategy.

**What we don't take**: Their specific skills (brainstorming, TDD, etc.) and their implicit workflow chains. Our atom/molecule layering provides explicit, formal composition that Superpowers lacks.

### 1.2 Compound Engineering (9.7k stars)

**Repository**: https://github.com/EveryInc/compound-engineering-plugin

**What it is**: A Claude Code plugin with a structured Plan -> Work -> Review -> Compound workflow. 29 specialized agents, 22 commands, 20 skills. The key innovation is the **multi-tool CLI converter** that takes Claude Code as the canonical format and converts to Cursor, Copilot, Gemini, Codex, OpenCode, and 5 other tools.

**What we borrow**:

- **Multi-tool CLI concept** (future scope): Their Bun/TypeScript CLI (`src/converters/claude-to-*.ts`) that converts Claude plugin format to 10+ targets. We plan to adopt this pattern for our adapter layer expansion beyond Cursor.
- **Knowledge compounding pattern**: `docs/solutions/` as a flywheel where learnings from each engineering cycle feed back into future work. This is the blueprint for our future Retrospective Capture atom.
- **Convention-based discovery**: Agents, commands, and skills are discovered by filesystem convention, not listed in `plugin.json`. We adopt this approach.

**What we don't take**: Their 29 specialized agents and the Plan -> Work -> Review -> Compound workflow. Our workflow is different (prime -> design -> implement with architecture guardrails). Their CLI complexity is deferred to future scope.

### 1.3 Anthropic Skills (80k stars)

**Repository**: https://github.com/anthropics/skills

**What it is**: Anthropic's official skills repository and the reference implementation of the Agent Skills specification (agentskills.io). Contains domain-specific skills (PDF, DOCX, PPTX, MCP builder, web testing) plus the critical `skill-creator` meta-skill.

**What we borrow**:

- **Agent Skills spec as our format standard**: YAML frontmatter (`name`, `description`), progressive disclosure (metadata -> body -> resources), skill anatomy (`SKILL.md` + `references/` + `scripts/` + `assets/`). Every skill we build follows this spec for maximum ecosystem compatibility.
- **`skill-creator` as our development harness**: A 480-line meta-skill backed by grading agents (`agents/grader.md`, `agents/comparator.md`, `agents/analyzer.md`), benchmark scripts (`scripts/aggregate_benchmark.py`), a visual eval viewer (`eval-viewer/generate_review.py`), and a description optimization loop (`scripts/run_loop.py`). We mandate its use for building and testing every skill in our framework.
- **Skill writing principles**: "Explain why, not heavy-handed MUSTs", "pushy descriptions" for better triggering, "generalize don't overfit", "keep lean -- every token competes for context window space".
- **Progressive disclosure patterns**: Complex skills (like `docx` with 20+ scripts) show how to use `references/` and `scripts/` for depth while keeping `SKILL.md` under 500 lines.

**What we don't take**: Their domain-specific skills (PDF, DOCX, etc.). Our framework is about process and architecture, not document processing.

### 1.4 Why Cherry-Pick, Not Fork

No single repository maps to our framework:

- **Superpowers** has its brainstorm -> TDD -> review workflow baked deeply into its skills. Stripping it is more work than building clean.
- **Compound Engineering** is oriented around a specific Plan -> Work -> Review -> Compound cycle with 29 specialized agents. The infrastructure is entangled with the content.
- **Anthropic Skills** provides the format standard and development tooling, but has no process-oriented skills, no composition mechanism, and no plugin infrastructure beyond Claude Code.

Our framework has unique concepts that none of them have:

- Formal atom/molecule/crafter layering with explicit composition
- `.ai/config.yaml` for per-project customization with override paths
- Automatic context injection (DDD auto-activation when touching domain code)
- Architecture guardrails (Clean Architecture + DDD as first-class skills)
- Context anchoring across sessions (decision capture with living feature docs)

Cherry-picking lets us take the best infrastructure from each without inheriting their baggage.

---

## 2. Repository Structure

A standalone repository, structured as a Claude Code and Cursor plugin. Skills use a **hybrid subdirectory layout** -- `skills/atoms/`, `skills/molecules/`, `skills/crafters/` -- so the atom/molecule/crafter architecture is visible at the filesystem level while remaining plugin-compatible (recursive discovery within `skills/` still finds every `SKILL.md`).

```
ai-skills-framework/
├── .claude-plugin/
│   ├── plugin.json                  # Plugin manifest (name, version, description)
│   └── marketplace.json             # Marketplace listing for Claude Code
├── .cursor-plugin/
│   └── plugin.json                  # Cursor plugin manifest (skills, commands, hooks paths)
├── skills/
│   ├── atoms/                       # Foundational, tool-agnostic, single-purpose skills
│   │   ├── knowledge-priming/
│   │   │   ├── SKILL.md
│   │   │   └── references/
│   │   │       └── knowledge-base-template.md
│   │   ├── design-first/
│   │   │   ├── SKILL.md
│   │   │   └── references/
│   │   │       └── methodology-detail.md
│   │   ├── decision-capture/
│   │   │   ├── SKILL.md
│   │   │   └── assets/
│   │   │       └── feature-doc-template.md
│   │   ├── clean-architecture/
│   │   │   ├── SKILL.md
│   │   │   └── references/
│   │   │       └── defaults.md
│   │   ├── domain-driven-design/
│   │   │   ├── SKILL.md
│   │   │   └── references/
│   │   │       └── defaults.md
│   │   ├── secure-coding/
│   │   │   ├── SKILL.md
│   │   │   └── references/
│   │   │       └── defaults.md
│   │   └── test-quality/
│   │       ├── SKILL.md
│   │       └── references/
│   │           └── defaults.md
│   ├── molecules/                   # Composite workflows that compose atoms
│   │   ├── start-feature/
│   │   │   └── SKILL.md
│   │   ├── continue-feature/
│   │   │   └── SKILL.md
│   │   ├── design-with-ddd/
│   │   │   └── SKILL.md
│   │   └── implement/
│   │       └── SKILL.md
│   └── crafters/                    # Setup-phase facilitative skills that produce documents
│       ├── architecture-crafter/
│       │   ├── SKILL.md
│       │   └── assets/
│       │       └── template.md
│       └── ddd-crafter/
│           ├── SKILL.md
│           └── assets/
│               └── template.md
├── agents/                           # Specialized agent personas
│   └── (future: reviewer, etc.)
├── commands/                         # User-facing entry points (thin wrappers)
│   ├── start.md                     # -> start-feature molecule
│   ├── continue.md                  # -> continue-feature molecule
│   ├── design.md                    # -> design-with-ddd molecule
│   ├── implement.md                 # -> implement molecule
│   ├── setup-architecture.md        # -> architecture-crafter
│   └── setup-ddd.md                 # -> ddd-crafter
├── hooks/
│   └── hooks.json                   # SessionStart hook for knowledge priming injection
├── scaffold/                         # Reference .ai/ folder for consumer repos
│   └── .ai/
│       ├── config.yaml              # Reference config with all defaults
│       └── feature-docs/
│           └── .gitkeep
├── docs/
│   └── implementation.md            # THIS document
├── LICENSE
└── README.md
```

### Structural Design Decisions

**Hybrid subdirectory layout**: `skills/atoms/`, `skills/molecules/`, `skills/crafters/` makes the architecture self-documenting. A new contributor opening the repo instantly sees the taxonomy -- which skills are building blocks, which are compositions, which are setup tools. Plugin discovery still works because both Claude Code and Superpowers' `findSkillsInDir()` scan recursively (depth 3+). The path `skills/atoms/knowledge-priming/SKILL.md` uses 3 levels of the depth budget, which is within limits.

**Anthropic standard subdirectory names**: Supporting files use `references/`, `scripts/`, `assets/` -- the names specified by the Agent Skills spec. This ensures compatibility with any tooling built around the spec.

**Superpowers-style root directories**: `commands/`, `hooks/`, `agents/` live at the repo root, not nested under skills. This follows the proven Superpowers pattern and keeps the skill directory focused on skill content.

**Marketplace packaging**: `.claude-plugin/` and `.cursor-plugin/` at the repo root enable marketplace distribution for both Claude Code and Cursor from day one.

**Scalability**: New atoms, molecules, and crafters each have a natural home. Adding a `skills/atoms/test-quality/` or `skills/crafters/knowledge-base-crafter/` requires no structural changes.

---

## 3. Skill Format Specification

All skills follow the **Anthropic Agent Skills specification** (agentskills.io) with framework-specific extensions. This ensures ecosystem compatibility while supporting our unique composition patterns.

### 3.1 Frontmatter (Required)

```yaml
---
name: skill-name
description: "What this skill does AND when to use it. Be pushy."
---
```

**Field rules**:

- `name`: 1-64 characters, lowercase letters, numbers, and hyphens only. No leading/trailing hyphens, no consecutive hyphens. Must match the parent directory name.
- `description`: 1-1024 characters. Written in third person. Must include both WHAT the skill does and WHEN it should trigger.

**Description authoring guidance** (from Anthropic `skill-creator`):

Skills have a tendency to "under-trigger" -- to not activate when they would be useful. To combat this, descriptions should be "pushy". Instead of:

> "Helps with architecture decisions."

Write:

> "Enforce clean architecture structural rules when generating or modifying code. Validates layer responsibilities, dependency direction, and structural constraints. Use when generating code, reviewing architecture, creating new files, or when the user mentions 'architecture', 'layers', 'structure', 'controllers', 'services', 'repositories', or 'dependency rules'."

The second version lists specific trigger phrases that a real user would say. The description optimization loop in Section 10 will further tune these for accuracy.

### 3.2 Progressive Disclosure (Three Levels)

Skills use a three-level loading system that balances context window cost against capability:

1. **Metadata** (name + description, ~100 words) -- always in context, used for triggering decisions
2. **SKILL.md body** (<500 lines ideal) -- loaded when the skill activates
3. **Bundled resources** (`references/`, `scripts/`, `assets/`) -- loaded on demand, unlimited size

The constraint is the context window. Metadata for all installed skills is always present (~100 words each). When a skill triggers, its SKILL.md body enters context. Reference files are only read when the skill's instructions say to read them. This layered approach lets us ship rich defaults without overwhelming the context.

### 3.3 Skill Anatomy

```
skill-name/
├── SKILL.md              # Required -- core instructions (<500 lines)
└── Bundled Resources      # Optional
    ├── references/        # Docs loaded into context on demand
    │                      #   - defaults.md (embedded opinionated defaults)
    │                      #   - methodology-detail.md (expanded examples)
    ├── scripts/           # Executable code for deterministic tasks
    │                      #   - validate.py, scaffold.sh (future)
    └── assets/            # Templates and scaffolds
                           #   - feature-doc-template.md, crafter template
```

**When to use each subdirectory**:

- `references/`: Content the AI reads into context when needed. Defaults, detailed methodology, extended examples. Use when the SKILL.md body would exceed 500 lines without this content.
- `scripts/`: Code the AI executes. Validation scripts, scaffolding scripts. Use for deterministic, repetitive tasks where reliability matters more than flexibility.
- `assets/`: Files used in output generation. Templates that get copied and filled, scaffolds for new documents. Use for artifacts that the skill produces.

### 3.4 Cross-Reference Pattern

Skills reference other skills using a namespace convention borrowed from Superpowers:

- `framework:knowledge-priming` -- reference a specific skill by namespace. The `framework:` prefix ensures the framework's skill is used, not a personal skill with the same name.
- `@references/defaults.md` or `./references/defaults.md` -- reference a file within the same skill directory.

Molecules use cross-references to compose atoms:

```markdown
## Required Skills
Read and apply these skills:
1. `framework:knowledge-priming` -- Load project context first
2. `framework:design-first` -- Then guide through 5-level design
3. `framework:decision-capture` -- Capture decisions at each level
```

### 3.5 Writing Principles

These principles come directly from Anthropic's `skill-creator` and are mandatory for all skills in our framework:

1. **Explain why, not heavy-handed MUSTs**. LLMs are smart. They have good theory of mind. When given reasoning, they go beyond rote instruction-following. If you find yourself writing ALWAYS or NEVER in all caps, reframe -- explain the reasoning so the model understands why the constraint is important. That's a more humane, powerful, and effective approach.

2. **Keep lean**. Every token competes for context window space. The default assumption is that the agent is already very smart. Challenge each piece of information: "Does the agent really need this explanation?" "Can I assume the agent knows this?" "Does this paragraph justify its token cost?"

3. **Generalize, don't overfit**. Skills are used across many different prompts by many different users. If a fix works only for your test cases, it's useless. Rather than fiddly, overfitty changes, try branching out with different metaphors or recommending different patterns.

4. **Progressive disclosure**. Put essentials in SKILL.md, depth in reference files. For large reference files (>300 lines), include a table of contents. Keep references one level deep -- link directly from SKILL.md, don't nest references within references.

### 3.6 Framework-Specific Extensions

Each **atom** SKILL.md includes a standardized "Config Resolution" section. This is our unique mechanism for layered overrides -- not present in any of the reference repositories:

```markdown
## Config Resolution

This skill supports project-specific overrides. Resolution order:

1. Look for `.ai/config.yaml` in the repository root
2. If found, check `paths.<key>` for a custom document path
3. If the custom path exists, read that document -- it takes precedence
4. If no config, no path, or path not found, read `./references/defaults.md`

The defaults ship with this skill and represent opinionated best practices.
They work out of the box for any project. Override only when your team has
specific standards that differ from the defaults.
```

**Molecules** do not have Config Resolution -- they delegate to their constituent atoms.

**Crafters** do not have Config Resolution -- they produce the documents that atoms later consume via Config Resolution.

---

## 4. Atom Specifications

Atoms are the foundational layer. Each is a single-purpose, tool-agnostic skill that can be used independently or composed into molecules. Six atoms ship in v1.

### 4.1 Knowledge Priming

**Purpose**: Prime the AI with project-specific context before any work begins.

**Existing source material**:
- `prompts/developer.md` (the existing prompt)
- `ai-techniques/demo-kit/1-knowledge-priming/cucumber-playwright-knowledge-base.md` (reference knowledge base with 7-section anatomy)
- `blogs/martin-fowler/02-onboarding-context-for-coding-assistants.md` (the conceptual foundation)

**Frontmatter**:

```yaml
---
name: knowledge-priming
description: "Prime the AI with project-specific context before any coding work. Creates and loads knowledge base documents covering architecture, tech stack, curated sources, conventions, and anti-patterns. Use when starting a coding session, onboarding to a project, or when the AI needs project context. Use this skill whenever the user mentions 'prime', 'onboard', 'context', 'knowledge base', or starts a new session."
---
```

**SKILL.md body outline**:

1. **Config Resolution** -- read knowledge base path from `.ai/config.yaml` at `paths.knowledge_base`, fall back to prompting user
2. **Metaphor** -- "Imagine you are a new developer joining my team. This document is the onboarding session."
3. **7-Section Anatomy** -- the knowledge base must cover:
   - Architecture Overview (big picture, major components, how they interact)
   - Tech Stack and Versions (specific version numbers -- APIs change between versions)
   - Curated Knowledge Sources (official docs, vetted blogs, internal references the team trusts)
   - Project Structure (directory layout, where things live)
   - Naming Conventions (how the team names things)
   - Code Examples (the "right way" patterns)
   - Anti-Patterns (explicitly banned patterns with reasons)
4. **Behavioral rules** -- prioritize documented patterns over training data; if there's a conflict, trust the knowledge base; cite which resource influenced decisions
5. **Acknowledgment format** -- confirm what was loaded, key constraints honored

**Reference files**:

- `references/knowledge-base-template.md` -- A blank 7-section template with section headings, guidance comments, and example entries. Used when a project doesn't have a knowledge base yet.

**Config key**: `paths.knowledge_base` (default: `.ai/knowledge-base.md`)

---

### 4.2 Design-First (Progressive Design Facilitation)

**Purpose**: Guide structured design thinking through 5 progressive levels before any code is written.

**Existing source material**:
- `prompts/architect.md` (the existing prompt)
- `ai-techniques/demo-kit/2-design-first/design-first-methodology.md` (the 5-level methodology)
- `blogs/martin-fowler/03-design-first-collaboration.md` (the conceptual foundation)

**Frontmatter**:

```yaml
---
name: design-first
description: "Guide structured design thinking through 5 progressive levels before any code is written. Levels: Capabilities, Components, Interactions, Contracts, Implementation. Use when building new features, refactoring significant code, designing modules, or when the user says 'design this', 'architect this', or 'let's think before coding'. Do not use for quick fixes, bug patches, or simple CRUD operations."
---
```

**SKILL.md body outline**:

1. **The 5 Levels**:
   - Level 1: CAPABILITIES (The "What") -- numbered list of user-facing outcomes, max 5
   - Level 2: COMPONENTS (The "Who") -- major building blocks, ASCII/Mermaid diagram, 3-5 components with single responsibility
   - Level 3: INTERACTIONS (The "How They Talk") -- sequence diagram or numbered flow, focus on WHAT data passes, not HOW processed
   - Level 4: CONTRACTS (The "Interface Definitions") -- TypeScript interfaces, method signatures, JSDoc. No implementation logic.
   - Level 5: IMPLEMENTATION (The "Code") -- only after explicit approval of Level 4
2. **Level completion protocol** -- at the end of each level, ask: "Does this Level [N] look correct? Should I proceed to Level [N+1]?"
3. **Zero implementation rule** -- if you catch yourself writing function bodies before Level 5 is approved, STOP. This is the most important rule because it prevents the AI's tendency to collapse design and implementation into one step.
4. **Challenge requirements** -- if something seems over-engineered, propose a simpler alternative. Simpler is better.
5. **Decision capture integration** -- invoke `framework:decision-capture` to log decisions made at each level

**Reference files**:

- `references/methodology-detail.md` -- expanded examples for each level (the visual comparison example, sequence diagram examples, interface definition examples from the existing methodology doc)

---

### 4.3 Decision Capture

**Purpose**: Maintain living feature documents that capture decisions, constraints, and progress across AI sessions.

**Existing source material**:
- `prompts/load-context.md` and `prompts/update-context.md` (the existing prompts)
- `ai-techniques/demo-kit/4-context-anchoring/context-anchoring-guide.md` (the methodology)
- `ai-techniques/demo-kit/4-context-anchoring/feature-doc-template.md` (the template)
- `blogs/05-context-problem.md` (the conceptual foundation)

**Frontmatter**:

```yaml
---
name: decision-capture
description: "Maintain living feature documents that capture decisions, constraints, and progress across AI sessions. Handles both loading existing context and updating documents with new decisions. Use when starting a session on an existing feature, making technical decisions, resolving questions, or when context needs to persist across sessions. Use this skill whenever the user mentions 'load context', 'update context', 'feature doc', 'decisions', 'continue where we left off', or 'what did we decide'."
---
```

**SKILL.md body outline**:

1. **The problem** -- AI has no persistent memory. Context decay is real: by message 30+, early decisions get contradicted, naming becomes inconsistent, the "why" is lost. Feature documents solve this.
2. **Load Context behavior**:
   - Read the feature document provided by the user
   - Acknowledge status, key decisions, constraints, open questions
   - Honor all logged decisions -- never contradict without explicit discussion
   - Respect constraints as non-negotiable
   - Flag open questions when work touches an unresolved item
3. **Update Context behavior**:
   - Add decisions with DATE, REASON, and ALTERNATIVES REJECTED
   - Resolve open questions -- mark resolved, add answer
   - Update status when phase changes
   - Maintain consistent formatting with existing entries
   - Never remove existing content unless explicitly asked
4. **Config Resolution** -- read feature docs path from `.ai/config.yaml` at `paths.feature_docs`
5. **Output formats** -- acknowledgment format for loading, change summary format for updating

**Asset files**:

- `assets/feature-doc-template.md` -- Feature document template with sections: Status, Capabilities, Decisions Log (table), Constraints, Open Questions, Related Files, Session Notes

**Config key**: `paths.feature_docs` (default: `.ai/feature-docs/`)

---

### 4.4 Clean Architecture

**Purpose**: Enforce clean architecture structural rules when generating or modifying code.

**No existing source material** -- this is a new skill built from first principles.

**Frontmatter**:

```yaml
---
name: clean-architecture
description: "Enforce clean architecture structural rules when generating or modifying code. Validates layer responsibilities, dependency direction, and structural constraints. Use when generating code, reviewing architecture, creating new files, or when the user mentions 'architecture', 'layers', 'structure', 'controllers', 'services', 'repositories', or 'dependency rules'. Also use when reviewing generated code for structural compliance."
---
```

**SKILL.md body outline**:

1. **Config Resolution** -- check for `.ai/clean-architecture.md` at `paths.clean_architecture`, fall back to `./references/defaults.md`
2. **Core principle** -- clean architecture is about STRUCTURE. It defines where code lives, which layers exist, and which direction dependencies flow. It is distinct from DDD (which is about crafting domain logic within the domain layer).
3. **Layer definitions** -- present the loaded architecture document's layer definitions. If using defaults:
   - **Controllers/Handlers**: HTTP/gRPC/CLI entry points. No business logic. Delegate to services.
   - **Application Services**: Orchestrate use cases. Call domain objects, coordinate infrastructure. No domain logic.
   - **Domain**: Business rules, entities, value objects, domain services. No infrastructure dependencies.
   - **Infrastructure/Repositories**: Database, external APIs, file system. Implement interfaces defined in domain.
4. **Dependency rules** -- outer layers depend on inner layers, never the reverse. Domain has zero outward dependencies. Infrastructure implements domain interfaces.
5. **Structural validation checklist** -- when generating or reviewing code, check:
   - Is business logic in the domain layer (not controllers or infrastructure)?
   - Does each class have a single reason to change?
   - Do outer layers depend on abstractions (interfaces), not implementations?
   - Is I/O isolated in infrastructure?
6. **Anti-patterns with examples** -- business logic in controllers, domain depending on infrastructure, god classes, direct concrete dependencies

**Reference files**:

- `references/defaults.md` -- The embedded opinionated defaults. This is the full document that ships with the skill and is used when no user override exists. Contents:
  - 4-layer structure with responsibilities table
  - Dependency direction diagram (ASCII)
  - Per-layer rules: what belongs here, what doesn't, common violations
  - Example violations with fixes (code snippets showing wrong vs right)
  - Validation checklist (reusable after code generation)

**Config key**: `paths.clean_architecture` (default: `.ai/clean-architecture.md`)

---

### 4.5 Domain-Driven Design

**Purpose**: Apply DDD tactical patterns when working with domain code.

**No existing source material** -- this is a new skill built from first principles.

**Frontmatter**:

```yaml
---
name: domain-driven-design
description: "Apply DDD tactical patterns when working with domain code. Enforces aggregate design, value objects over primitives, entity identity rules, and bounded context boundaries. Use when creating or modifying domain models, designing aggregates, working in the domain folder, or when the user mentions 'domain', 'aggregate', 'value object', 'entity', 'bounded context', or 'DDD'. This skill auto-activates when code changes touch the configured domain folder."
---
```

**SKILL.md body outline**:

1. **Config Resolution** -- check for `.ai/ddd-principles.md` at `paths.ddd_principles`, fall back to `./references/defaults.md`
2. **Scope statement** -- this skill operates within a single repository, for a single bounded context (e.g., one API -- Order, User, Pricing). It is not about whole-system DDD mapping across multiple services.
3. **Core tactical patterns** -- present the loaded DDD document's patterns. If using defaults:
   - **Aggregate**: Consistency boundary. Only the aggregate root is externally accessible. Reference other aggregates by ID, not object reference. One transaction per aggregate.
   - **Entity**: Has identity that persists through state changes. Equality based on identity, not attributes.
   - **Value Object**: Defined by attributes, not identity. Immutable. Use instead of primitives (Money, not BigDecimal; Email, not String; OrderId, not UUID).
   - **Domain Event**: Something that happened in the domain that domain experts care about. Named in past tense. Carries the data needed to describe what happened.
   - **Repository**: One per aggregate root. Interface defined in domain layer, implementation in infrastructure. Returns domain objects, not DTOs.
4. **Design decision guidance**:
   - When to use entity vs value object (identity matters? -> entity. Defined by attributes? -> value object)
   - Aggregate boundary rules (what must be consistent together? -> same aggregate. Can tolerate eventual consistency? -> separate aggregates)
   - Value objects over primitives (every time you see a raw string, number, or UUID representing a domain concept, consider wrapping it)
5. **Validation checklist for domain code**:
   - Are aggregates cohesive and appropriately sized?
   - Are value objects used instead of primitives for domain concepts?
   - Are domain events raised for state changes that other parts of the system care about?
   - Does the domain layer have zero infrastructure dependencies?
6. **Anti-patterns**:
   - Anemic domain model (entities with only getters/setters, all logic in services)
   - Primitive obsession (raw strings for Email, Money, OrderId)
   - Large aggregates (trying to make everything consistent in one transaction)
   - Leaking domain logic (business rules in controllers, services, or infrastructure)

**Reference files**:

- `references/defaults.md` -- The embedded opinionated defaults. Contents:
  - Aggregate design rules with examples
  - Entity vs Value Object decision flowchart
  - Value object catalog (common domain concepts that should be value objects)
  - Domain event patterns (naming, payload, when to raise)
  - Repository pattern rules
  - Anti-pattern catalog with code examples (wrong vs right)

**Config key**: `paths.ddd_principles` (default: `.ai/ddd-principles.md`)

**Special behavior**: This atom is designed to be auto-injected when code changes touch the configured `domain_folder` (see Section 9).

---

### 4.6 Quality Reasoning

**Purpose**: Evaluate code against engineering principles that go beyond syntax and linting.

**Existing source material**:
- `prompts/review.md` (the existing prompt)
- `ai-techniques/demo-kit/3-sensible-defaults/sensible-defaults-guide.md` (the 5-category principle set with examples)

**Frontmatter**:

*`quality-reasoning` has been replaced by two focused atoms: `secure-coding` and `test-quality`. The remaining categories (ARCH-\*, ERR-\*, CLARITY-\*) are covered by `clean-architecture` and `clean-code`. A `review` molecule composes all atoms' validation checklists into a standalone review workflow.*
4. **Review process** -- check each of the 5 categories, flag violations with severity + principle ID + specific issue + suggested fix
5. **Output formats**:
   - Summary mode (top 5 critical issues, one-line each)
   - Full review mode (summary table, what's done well, optional recommendations)

**Reference files**:

- `references/defaults.md` -- The 5-category principle set with examples:
  - `ARCH-*` (architectural discipline): layer violations, god classes, direct dependencies
  - `TEST-*` (test quality): one behavior per test, explicit assertions, tests own their data
  - `SEC-*` (security thinking): trust no input, auth != authz, no secrets in logs
  - `ERR-*` (error handling): specific catches, context in logs, fail fast
  - `CLARITY-*` (code clarity): no magic, why not what, explicit over clever

**Config key**: `paths.quality_principles` (default: `.ai/quality-principles.md`)

---

## 5. Molecule Specifications

Molecules are composite workflows that compose atoms. Each molecule SKILL.md lists its required atoms using the `framework:` namespace prefix and provides orchestration logic that sequences them.

### 5.1 Start Feature

**Purpose**: Begin new feature work with full project context and structured design thinking.

```yaml
---
name: start-feature
description: "Begin new feature work with full project context and structured design thinking. Combines knowledge priming, design-first methodology, and decision capture into a single workflow. Use when starting a new feature, beginning a new task, or when the user says 'let's start', 'new feature', 'begin work on', or 'start a feature'."
---
```

**Composed atoms**: `framework:knowledge-priming` -> `framework:design-first` -> `framework:decision-capture`

**Workflow**:

1. **Prime** -- read and apply `framework:knowledge-priming`. Load the project's knowledge base. Acknowledge the tech stack, conventions, and constraints.
2. **Create feature doc** -- using `framework:decision-capture`, create a new feature document from the template. Set status to "Discovery".
3. **Design** -- read and apply `framework:design-first`. Begin the 5-level design process. At each level, capture decisions in the feature doc using `framework:decision-capture`.
4. **Checkpoint** -- after Level 4 (Contracts) is approved, update the feature doc status to "Design Complete" and present options: proceed to implementation, or pause.

**Transition to implementation**: When the user approves Level 5, invoke `framework:code-forge` molecule (or suggest the user run the `/code-forge` command).

---

### 5.2 Continue Feature

**Purpose**: Resume work on an existing feature across session boundaries without losing context.

```yaml
---
name: continue-feature
description: "Resume work on an existing feature across session boundaries without losing context. Loads the feature document and restores all prior decisions and constraints. Use when continuing work, resuming a feature, starting a new session on existing work, or when the user says 'continue', 'resume', 'pick up where we left off', or 'load my feature'."
---
```

**Composed atoms**: `framework:decision-capture` (load mode) -> `framework:design-first` (resume from checkpoint)

**Workflow**:

1. **Load context** -- read and apply `framework:decision-capture` in load mode. Read the feature document, acknowledge all decisions, constraints, and open questions.
2. **Determine checkpoint** -- from the feature doc's status and decisions log, identify where work left off (which design level, which implementation task).
3. **Resume** -- if in design phase, resume `framework:design-first` at the current level. If in implementation phase, resume `framework:code-forge`.
4. **Continue capturing** -- all new decisions are captured in the feature doc immediately.

---

### 5.3 Design with DDD

**Purpose**: Run the design-first methodology with DDD tactical patterns infused at each level.

```yaml
---
name: design-with-ddd
description: "Run the design-first methodology with DDD tactical patterns infused at each level. Use when designing domain-heavy features, modeling aggregates, or when the user says 'design with DDD', 'domain design', 'model this domain', or 'design the domain for'."
---
```

**Composed atoms**: `framework:domain-driven-design` + `framework:design-first` + `framework:decision-capture`

**Workflow**:

1. **Load DDD principles** -- read and apply `framework:domain-driven-design`. Load the project's DDD guardrails (from config or defaults).
2. **Design with DDD lens** -- run `framework:design-first` with DDD patterns infused at each level:
   - Level 1 (Capabilities): identify domain concepts and bounded context scope
   - Level 2 (Components): identify aggregates, entities, value objects
   - Level 3 (Interactions): define aggregate interactions, domain events
   - Level 4 (Contracts): define aggregate interfaces, repository interfaces, value object definitions
   - Level 5 (Implementation): implement with DDD patterns
3. **Capture domain decisions** -- use `framework:decision-capture` to log domain modeling decisions (aggregate boundaries, value object choices, event definitions)

---

### 5.4 Code Forge

**Purpose**: Generate implementation code from an approved design blueprint or verbal requirements, composing context anchoring, clean architecture, clean code, DDD, security, and test quality into an inside-out implementation workflow.

```yaml
---
name: code-forge
description: "Generate implementation code from an approved design blueprint or verbal requirements. Composes context anchoring, clean architecture, clean code, DDD, security, and test quality into an inside-out implementation workflow. Use when moving from design to code, implementing approved contracts, or when the user says 'implement', 'code this', 'build it', 'forge the code', or 'generate the code'."
---
```

**Composed atoms** (6): `framework:context-anchoring` (load + enrich) + `framework:clean-architecture` + `framework:clean-code` + `framework:domain-driven-design` (conditional: domain folder) + `framework:secure-coding` (conditional: boundary-crossing code) + `framework:test-quality`

**Workflow** (5 steps):

1. **Establish implementation context** -- use `framework:context-anchoring` Document Discovery to check for an existing context anchor document. If found, load it and honor all decisions/constraints. If not found, nudge the user ("Do you have a design document?") and accept either answer -- all atom guardrails apply regardless.
2. **Plan implementation order** -- with blueprint: extract component list and layer assignments from context doc. Without blueprint: classify components into layers using `framework:clean-architecture`, present for user approval. In both cases, plan inside-out order (domain → infrastructure → application → interface) and classify each operation as command or query flow. Confirm with user before writing code.
3. **Implement per component** -- for each component in planned order, generate code + tests together. Place in correct layer (`clean-architecture`), apply `clean-code` self-validation (10 inline checks), write tests using `test-quality` self-validation (7 checks). Conditional: apply `domain-driven-design` checks for domain layer, `secure-coding` checks for trust boundaries. With blueprint: verify component fulfills Level 4 contract. Present each component to user before moving to next.
4. **Cross-component verification** -- with blueprint: verify interaction flows match Level 3 design. For all cases: enforce the Zero Implementation Rule (no unplanned components/interactions/contracts). Final security scan across component boundaries.
5. **Enrich context** -- throughout Steps 3-4, use `framework:context-anchoring` Enrich behavior to capture key files, implementation decisions, library choices, and resolved open questions. If no context doc exists and significant decisions were made, suggest creating one.

---

## 6. Crafter Specifications

Crafters are setup-phase skills that facilitate structured conversations to produce documents. They run rarely -- during initial project setup or when principles need to be (re)defined. Their design is inspired by Anthropic's `skill-creator` pattern: interview the user, produce a formal artifact.

### 6.1 Architecture Crafter

**Purpose**: Facilitate a structured conversation to define clean architecture principles for a repository.

```yaml
---
name: architecture-crafter
description: "Facilitate a structured conversation to define clean architecture principles for a repository. Produces a formal clean-architecture.md document that the clean-architecture atom will use as its override. Use when setting up a new project, defining architecture standards, or when the user says 'setup architecture', 'define layers', 'architecture principles', or 'help me define my architecture'."
---
```

**SKILL.md body outline**:

1. **What this produces** -- a `clean-architecture.md` document that will be saved to the path configured in `.ai/config.yaml` (default: `.ai/clean-architecture.md`). Once produced, the `framework:clean-architecture` atom will use this document instead of its embedded defaults.
2. **Facilitation flow** -- guide the user through structured questions. For each section of the template, present the question, show an example answer from the defaults, and ask the user to confirm, modify, or provide their own answer.
3. **Template-driven** -- read `./assets/template.md` which contains the sections and guiding questions.
4. **Output** -- write the final document to the configured path and update `.ai/config.yaml` if needed.

**Asset files**:

- `assets/template.md` -- Facilitative template with sections:
  1. **Layer Definitions** -- "What layers does your codebase use? Here's a common 4-layer structure: [show default]. Does this match your project, or do you use different layers?"
  2. **Dependency Rules** -- "Which direction should dependencies flow? The standard rule is outer -> inner. Do you have any exceptions?"
  3. **Allowed Patterns** -- "Which architectural patterns does your team endorse? (e.g., Repository pattern, CQRS, Event Sourcing, Mediator)"
  4. **Banned Patterns** -- "Are there patterns explicitly forbidden in your codebase? (e.g., Active Record, Service Locator, direct database access from controllers)"
  5. **Validation Rules** -- "What should AI check when generating code? Here are common rules: [show defaults]. Add any project-specific rules."

---

### 6.2 DDD Crafter

**Purpose**: Facilitate a structured conversation to define DDD guardrails for domain design.

```yaml
---
name: ddd-crafter
description: "Facilitate a structured conversation to define DDD guardrails for domain design within a repository. Produces a formal ddd-principles.md document that the domain-driven-design atom will use as its override. Use when setting up domain design principles, defining aggregate rules, or when the user says 'setup DDD', 'define domain rules', 'DDD principles', or 'help me define my domain patterns'."
---
```

**SKILL.md body outline**:

1. **What this produces** -- a `ddd-principles.md` document saved to the configured path (default: `.ai/ddd-principles.md`). The `framework:domain-driven-design` atom will use this as its override.
2. **Scope clarification** -- this defines the *rules of crafting* the domain, not the domain model itself. The domain evolves through features; this document defines the guardrails.
3. **Facilitation flow** -- same pattern as Architecture Crafter: structured questions, example answers from defaults, user confirmation or modification.
4. **Output** -- write document and update config.

**Asset files**:

- `assets/template.md` -- Facilitative template with sections:
  1. **Aggregate Design Rules** -- "How do you think about aggregate boundaries? Here's the default approach: [show]. What's your consistency strategy?"
  2. **Value Object Strategy** -- "Which domain concepts should be value objects instead of primitives? Here are common ones: [Money, Email, OrderId]. What concepts in your domain deserve value objects?"
  3. **Entity Rules** -- "How do you handle entity identity and lifecycle? Default: [show]. Any project-specific rules?"
  4. **Domain Events** -- "When should domain events be raised? Default naming convention: [past tense, e.g., OrderPlaced]. What events matter in your domain?"
  5. **Bounded Context Scope** -- "What's the scope of this bounded context? What's in, what's out?"
  6. **Anti-patterns** -- "What domain patterns are explicitly forbidden in your codebase? Default list: [anemic domain, primitive obsession, large aggregates]. Add any project-specific anti-patterns."

**Template quality is critical**: The crafter template's ability to ask the right questions is the key quality lever. A sloppy facilitation produces a sloppy document, which produces sloppy architectural guidance downstream. The templates should be iterated using `skill-creator`'s eval loop with realistic user responses.

---

## 7. Configuration Schema

The `.ai/config.yaml` file is the single source of truth for framework configuration in a consumer's repository. It lives at the repository root under `.ai/`.

### 7.1 Full Schema

```yaml
# .ai/config.yaml -- AI Skills Framework Configuration
# All paths are relative to the repository root.
# All fields are optional. Defaults are shown in comments.

version: 1

# Document paths -- where the framework looks for project-specific documents
paths:
  knowledge_base: .ai/knowledge-base.md          # 7-section priming document
  clean_architecture: .ai/clean-architecture.md   # CA principles (from crafter or manual)
  ddd_principles: .ai/ddd-principles.md           # DDD guardrails (from crafter or manual)
  quality_principles: .ai/quality-principles.md   # Quality reasoning principles
  feature_docs: .ai/feature-docs/                 # Directory for feature documents
  domain_folder: src/domain/                      # Folder that triggers auto-DDD injection

# Skill configuration
skills:
  enabled:                     # Which atoms are active (all enabled by default)
    - knowledge-priming
    - design-first
    - decision-capture
    - clean-architecture
    - domain-driven-design
    - secure-coding
    - test-quality
```

### 7.2 Resolution Rules

1. **Config file absent**: All paths default to the `.ai/` convention. All skills enabled. The framework works out of the box with zero configuration.
2. **Config file present, path missing**: Fall back to the default path for that field.
3. **Config file present, path specified, file not found**: Fall back to the skill's embedded `references/defaults.md`. No error -- this is expected when a crafter hasn't been run yet.
4. **Config file present, path specified, file found**: Use the user's document. It takes full precedence over embedded defaults.

### 7.3 Override Hierarchy

```
User's document (via config path)  →  takes precedence
         ↓ (if not found)
Skill's embedded defaults (references/defaults.md)  →  always available
```

This is the "convention over configuration" principle: good defaults out of the box, escape hatches for advanced users.

### 7.4 The `.ai/` Folder Ecosystem

The `scaffold/` directory in the framework repository contains a reference `.ai/` folder that consumers can copy into their repos:

```
.ai/
├── config.yaml              # Framework configuration
├── knowledge-base.md        # Created by user or knowledge-base-crafter (future)
├── clean-architecture.md    # Created by architecture-crafter or manually
├── ddd-principles.md        # Created by ddd-crafter or manually
├── quality-principles.md    # Created manually (future crafter)
└── feature-docs/            # Living feature documents
    ├── user-registration.md
    ├── payment-integration.md
    └── ...
```

Each document has a different update frequency:
- **config.yaml**: Rarely changes (project setup)
- **knowledge-base.md**: Updated when stack, conventions, or sources change
- **clean-architecture.md**: Rarely changes (principles are stable)
- **ddd-principles.md**: Rarely changes (domain guardrails are stable)
- **feature-docs/**: Updated frequently (per feature, per session)

---

## 8. Plugin Infrastructure

### 8.1 Claude Code Plugin

**File**: `.claude-plugin/plugin.json`

```json
{
  "name": "ai-skills-framework",
  "version": "0.1.0",
  "description": "Composable AI collaboration framework with Clean Architecture and DDD guardrails. Process-oriented skills that teach AI how to think, not just what to produce.",
  "author": "Rahul Garg"
}
```

**File**: `.claude-plugin/marketplace.json`

```json
{
  "name": "ai-skills-marketplace",
  "owner": {
    "name": "Rahul Garg",
    "url": "https://github.com/rahulgarg"
  },
  "metadata": {
    "description": "Composable AI skills framework",
    "version": "1.0.0"
  },
  "plugins": [
    {
      "name": "ai-skills-framework",
      "description": "Process-oriented AI collaboration with Clean Architecture and DDD guardrails",
      "version": "0.1.0",
      "source": "./"
    }
  ]
}
```

Skills, commands, and hooks are discovered by convention (filesystem scanning), not listed explicitly in `plugin.json`. This follows the Superpowers and Compound Engineering pattern.

### 8.2 Cursor Plugin

**File**: `.cursor-plugin/plugin.json`

```json
{
  "name": "ai-skills-framework",
  "displayName": "AI Skills Framework",
  "skills": "./skills/",
  "commands": "./commands/",
  "hooks": "./hooks/hooks.json"
}
```

Cursor's plugin system scans the `skills/` directory recursively for `SKILL.md` files, making our hybrid subdirectory layout (`skills/atoms/`, `skills/molecules/`, `skills/crafters/`) fully compatible.

### 8.3 Session Start Hook

**File**: `hooks/hooks.json`

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "session-start",
            "async": false
          }
        ]
      }
    ]
  }
}
```

The session-start hook runs when the AI session starts or resumes. It:

1. Checks for `.ai/config.yaml` in the current repository
2. If found, reads `paths.knowledge_base` and loads the knowledge base
3. Outputs the knowledge base content as additional context for the session
4. Announces that the framework is active and lists available commands

This borrows directly from the Superpowers pattern where `using-superpowers` is injected at session start.

### 8.4 Commands

Each command is a thin `.md` wrapper with YAML frontmatter that invokes a molecule or crafter skill:

**Example**: `commands/start.md`

```markdown
---
name: start
description: Begin new feature work with full project context and structured design
argument-hint: "[feature description or requirement]"
---

Invoke and follow the instructions in skill: framework:start-feature

The user wants to start working on a new feature. Follow the start-feature workflow.
```

**Command inventory**:

| Command | Invokes | Purpose |
|---------|---------|---------|
| `/start` | `framework:start-feature` molecule | Begin new feature with full context, design, and decision capture |
| `/continue` | `framework:continue-feature` molecule | Resume existing feature work across sessions |
| `/design` | `framework:design-with-ddd` molecule | Domain-focused design session with DDD patterns |
| `/code-forge` | `framework:code-forge` molecule | Code generation with architecture and DDD guardrails |
| `/setup-architecture` | `framework:architecture-crafter` | Define clean architecture principles for the repo |
| `/setup-ddd` | `framework:ddd-crafter` | Define DDD guardrails for the repo |

---

## 9. Context Injection: Automatic DDD Activation

When AI touches code in the configured `domain_folder`, the DDD skill is automatically part of the context without explicit user invocation. This is our unique mechanism -- no reference repository has this.

### 9.1 The Flow

1. Design-First reaches Level 4 (Contracts) -- decisions captured in feature doc
2. User approves -- moves to implementation (Level 5)
3. The implement molecule generates code
4. **If** the implementation touches files in the configured `domain_folder` -- DDD principles are auto-injected
5. AI applies DDD guardrails (value objects over primitives, aggregate boundaries, etc.) without explicit user action

### 9.2 Implementation: Cursor

For Cursor, this is implemented as a `.cursor/rules/` rule file with glob matching. The framework ships a reference rule that consumers copy to their repos:

**File** (in `scaffold/`): `.cursor/rules/ddd-auto-inject.mdc`

```markdown
---
description: Auto-inject DDD principles when editing domain code
globs: "**/domain/**"
alwaysApply: false
---

When modifying files in this directory, read and apply the framework:domain-driven-design skill.
Load DDD principles from .ai/config.yaml paths.ddd_principles or the skill's embedded defaults.
Ensure all domain code follows aggregate, entity, and value object patterns.
```

The `globs` pattern is configurable -- consumers change `**/domain/**` to match their domain folder convention (e.g., `**/core/**`, `**/model/**`).

### 9.3 Implementation: Claude Code

For Claude Code, the implement molecule includes a file-path check:

```markdown
## DDD Auto-Injection

Before generating code, check the target file path:
1. Read `paths.domain_folder` from `.ai/config.yaml` (default: `src/domain/`)
2. If any generated file will be placed in or under the domain folder:
   - Read and apply `framework:domain-driven-design`
   - Apply DDD guardrails to ALL code in the domain folder
3. For files outside the domain folder:
   - Apply clean architecture structural rules only
   - DDD is not required (but may be referenced)
```

---

## 10. Skill Development Methodology: Using Anthropic's `skill-creator`

Every skill in our framework -- atom, molecule, and crafter -- will be developed using Anthropic's [`skill-creator`](https://github.com/anthropics/skills/tree/main/skills/skill-creator) as the development harness. **This is not optional. It is the quality gate for shipping skills.**

### 10.1 Why This Matters

Anthropic's `skill-creator` is a 480-line meta-skill backed by:

- **Grading agents** (`agents/grader.md`) -- evaluate skill outputs against expectations with evidence-cited verdicts
- **Blind comparison** (`agents/comparator.md`) -- A/B test between skill versions without bias
- **Analysis agents** (`agents/analyzer.md`) -- explain why one version beats another
- **Benchmark scripts** (`scripts/aggregate_benchmark.py`) -- quantitative pass rates with mean/stddev
- **Visual eval viewer** (`eval-viewer/generate_review.py`) -- HTML interface for qualitative review
- **Description optimizer** (`scripts/run_loop.py`) -- automated loop that tunes descriptions for triggering accuracy

Without this toolchain, we're writing skills by gut feel. With it, we have empirical evidence that each skill improves AI behavior.

### 10.2 Setup

Install the `skill-creator` from Anthropic's marketplace:

```
/plugin marketplace add anthropics/skills
/plugin install example-skills@anthropic-agent-skills
```

This makes `skill-creator` available in Claude Code. When activated, it guides the entire skill development lifecycle.

### 10.3 Development Process for Each Skill

**Step 1: Capture intent**

Tell `skill-creator` what we're building. For example:

> "I want to create a skill that enforces clean architecture structural rules when the AI generates or modifies code. It should validate layer responsibilities, dependency direction, and structural constraints. It needs to support project-specific overrides via a config file."

The `skill-creator` will interview us about edge cases, input/output formats, success criteria, and dependencies.

**Step 2: Draft the SKILL.md**

Based on the interview, `skill-creator` drafts the SKILL.md following the anatomy in Section 3. We refine it to match our framework's format spec -- adding the Config Resolution section, ensuring cross-references use the `framework:` namespace, keeping under 500 lines.

**Step 3: Create test cases**

Create 2-3 realistic test prompts for each skill. These should be things a real user would actually say -- not abstract requests:

- **Atoms**: "I need to set up the architecture for my new Node.js API" (clean-architecture), "Design the order domain for our e-commerce service" (DDD), "Review this pull request for quality issues" (review molecule), "Secure this endpoint" (secure-coding), "Write tests for this service" (test-quality)
- **Molecules**: "Let's start working on the user registration feature" (start-feature), "Continue where we left off on the payment integration" (continue-feature)
- **Crafters**: "Help me define the architecture principles for this repo" (architecture-crafter)

Save test cases to `evals/evals.json`:

```json
{
  "skill_name": "clean-architecture",
  "evals": [
    {
      "id": 1,
      "prompt": "I'm building a new Node.js API for managing inventory. Set up the architecture for me.",
      "expected_output": "Code generated follows 4-layer structure with correct dependency direction",
      "expectations": [
        "Generated code has separate layers (controller, service, domain, repository)",
        "Business logic is in the domain layer, not controllers",
        "Infrastructure implements domain interfaces"
      ]
    }
  ]
}
```

**Step 4: Run evaluations**

Use `skill-creator`'s eval loop:

1. Spawn with-skill and without-skill (baseline) runs in parallel
2. Grade outputs using the grader agent (checks each expectation with evidence)
3. Aggregate benchmark data (pass rates, timing, token usage)
4. Generate the visual reviewer for qualitative inspection
5. Review both quantitative (pass rates) and qualitative (actual output quality) results

**Step 5: Iterate**

Based on eval feedback, improve the skill:

- **Generalize from failures** -- if the skill fails on one test case, don't add a narrow fix. Understand *why* it failed and address the root cause.
- **Explain the why** -- if the model isn't following an instruction, don't add MUST in all caps. Instead, explain *why* the instruction matters. The model will follow reasoning better than commands.
- **Keep lean** -- if a section isn't pulling its weight (model would do the right thing without it), remove it.
- **Move depth to references** -- if SKILL.md is approaching 500 lines, move detailed examples and edge cases to `references/`.

Repeat until:
- Pass rate on eval prompts exceeds 80%
- With-skill performance clearly beats baseline (without-skill)
- Behavior is consistent across different prompts

**Step 6: Optimize description**

After the skill content is stable, run the description optimization loop:

```bash
python -m scripts.run_loop \
  --eval-set evals/trigger-eval.json \
  --skill-path skills/atoms/<skill-name> \
  --model <current-model-id> \
  --max-iterations 5 \
  --verbose
```

This creates 20 eval queries (10 should-trigger, 10 should-not-trigger), splits into train/test sets, and iterates on the description to maximize triggering accuracy. The result is a description that reliably activates the skill when needed and stays quiet when it shouldn't.

### 10.4 Quality Bar

A skill is ready to ship when:

- Pass rate on eval prompts exceeds 80% (with clear improvement over baseline)
- Description triggers correctly on realistic prompts (validated by optimization loop)
- SKILL.md is under 500 lines with progressive disclosure to `references/`
- Config resolution works (embedded defaults load when no user override exists)
- Cross-references to other skills resolve correctly
- Writing follows the principles in Section 3.5 (explain why, keep lean, generalize)

---

## 11. Implementation Phases

### Phase 1: Foundation (Weeks 1-2)

**Goal**: Standalone repository with plugin infrastructure and the first 3 atoms.

- Initialize the repository with the directory structure from Section 2
- Create `.claude-plugin/plugin.json` and `.cursor-plugin/plugin.json` (Section 8)
- Create `hooks/hooks.json` with the session-start hook (Section 8.3)
- Define `.ai/config.yaml` schema and create `scaffold/.ai/` reference folder (Section 7)
- Install Anthropic's `skill-creator` as the development harness (Section 10.2)
- Build the 3 technique atoms by refining existing proto-implementations:
  - `knowledge-priming` -- from `prompts/developer.md` + knowledge base anatomy
  - `design-first` -- from `prompts/architect.md` + design-first methodology
  - `decision-capture` -- from `prompts/load-context.md` + `prompts/update-context.md` + context anchoring guide
- For each atom: draft with skill-creator -> create 2-3 test prompts -> run eval loop -> optimize description
- Create the session-start hook command that loads knowledge priming

### Phase 2: Architecture Atoms (Weeks 3-4)

**Goal**: The 3 new architecture-focused atoms with embedded defaults.

- Build `clean-architecture` atom:
  - Write `SKILL.md` with Config Resolution and structural rules
  - Write `references/defaults.md` with the full 4-layer opinionated defaults
  - Draft with skill-creator -> test -> eval -> optimize
- Build `domain-driven-design` atom:
  - Write `SKILL.md` with Config Resolution, tactical patterns, and validation checklist
  - Write `references/defaults.md` with aggregate rules, value object guidance, anti-patterns
  - Draft with skill-creator -> test -> eval -> optimize
- Build `secure-coding` atom:
  - Write `SKILL.md` with trust boundaries, injection prevention, secrets management
  - Write `references/defaults.md` with OWASP reference, before/after patterns
  - Draft with skill-creator -> test -> eval -> optimize
- Build `test-quality` atom:
  - Write `SKILL.md` with AAA structure, isolation, assertions, naming
  - Write `references/defaults.md` with test patterns, builders, pyramid guidance
  - Draft with skill-creator -> test -> eval -> optimize

### Phase 3: Crafters (Week 5)

**Goal**: Setup-phase skills that produce architecture and DDD documents.

- Build `architecture-crafter`:
  - Write `SKILL.md` with facilitation flow
  - Write `assets/template.md` with structured questions and example answers
  - Test conversation flow with skill-creator eval loop (use realistic user responses as test prompts)
- Build `ddd-crafter`:
  - Write `SKILL.md` with facilitation flow
  - Write `assets/template.md` with structured questions and example answers
  - Test conversation flow with skill-creator eval loop
- Validate that crafters produce well-formatted documents that the corresponding atoms can consume via Config Resolution

### Phase 4: Molecules & Commands (Week 6)

**Goal**: Composite workflows and user-facing entry points.

- Build all 4 molecules:
  - `start-feature` -- compose knowledge-priming + design-first + decision-capture
  - `continue-feature` -- compose decision-capture (load) + design-first (resume)
  - `design-with-ddd` -- compose domain-driven-design + design-first + decision-capture
  - `code-forge` -- compose context-anchoring + clean-architecture + clean-code + domain-driven-design (conditional) + secure-coding (conditional) + test-quality
  - `review` -- compose clean-code + clean-architecture (conditional) + domain-driven-design (conditional) + secure-coding (conditional) + test-quality (conditional)
- Create all 6 commands as thin wrappers (Section 8.4)
- Eval molecules end-to-end: does the `/start` command produce a feature doc with captured decisions? Does `/code-forge` generate code in the correct layers?

### Phase 5: Integration & Polish (Week 7)

**Goal**: Complete, tested, publishable plugin.

- Implement auto-DDD context injection:
  - Create reference Cursor rule (`scaffold/.cursor/rules/ddd-auto-inject.mdc`)
  - Add file-path check logic to the code-forge molecule
- End-to-end workflow testing:
  - Full cycle: `/setup-architecture` -> `/setup-ddd` -> `/start` -> design levels 1-5 -> `/code-forge` -> `/continue` in new session
  - Verify config resolution at each step
  - Verify feature doc persistence across sessions
- Write README.md with:
  - Installation instructions (Claude Code + Cursor)
  - Quick start guide
  - Full command reference
  - Architecture explanation (atoms, molecules, crafters)
- Prepare for marketplace submission

---

## 12. Key Design Decisions

| Decision | Rationale | Informed By |
|----------|-----------|-------------|
| Cherry-pick, don't fork | Our unique concepts (atoms/molecules/crafters, config overrides, architecture guardrails) don't map to any single repo. Cherry-picking lets us take the best from each without inheriting baggage. | Deep analysis of Superpowers, Compound Engineering, and Anthropic Skills |
| Anthropic Agent Skills spec for format | The official standard. Ecosystem compatibility, progressive disclosure, supported by skill-creator toolchain. | Anthropic skills repo (80k stars) + agentskills.io spec |
| Hybrid subdirectory layout | `skills/atoms/`, `skills/molecules/`, `skills/crafters/` makes the architecture self-documenting at the filesystem level while remaining plugin-compatible through recursive discovery. Scales cleanly with future atoms/molecules/crafters. | Tradeoff analysis of 5 layout options; recursive discovery verified against Superpowers' `findSkillsInDir()` |
| Anthropic skill-creator as mandatory development harness | Ensures every skill is empirically tested (not vibes), descriptions are optimized for triggering accuracy, and quality bar is met before shipping. No other approach provides grading agents, benchmarks, and description optimization. | skill-creator analysis (480 lines, eval agents, benchmark scripts, description optimizer) |
| Superpowers-style hooks + commands | Proven infrastructure for session bootstrap and user-facing entry points. Hooks enable auto-injection (knowledge priming at session start). Commands provide clean user interface to molecules. | Superpowers hooks.json, commands/ pattern |
| Pushy descriptions | Anthropic's research shows skills under-trigger. Explicit trigger phrases and contexts in descriptions improve activation rates. The description optimization loop validates this empirically. | skill-creator guidance: "make descriptions a little bit pushy" |
| Explain why over heavy MUSTs | LLMs respond better to reasoning than rigid commands. Skills that explain *why* an instruction matters produce more generalizable, higher-quality behavior than skills that just demand compliance. | skill-creator writing principles: "use theory of mind", "explain the why" |
| `references/` for embedded defaults | Follows Anthropic's standard subdirectory naming. Enables progressive disclosure (defaults are loaded only when the skill activates, not always in context). Keeps SKILL.md lean. | Anthropic skill anatomy (references/ for docs, scripts/ for code, assets/ for templates) |
| `framework:skill-name` namespace | Molecule-to-atom references use namespace prefix to ensure the framework's skill is invoked, not a user's personal skill with the same name. Prevents override conflicts. | Superpowers `superpowers:skill-name` pattern |
| Config-driven overrides with `.ai/config.yaml` | No reference repository has per-project configuration with override paths. This is our unique contribution. Enables teams to customize every aspect (architecture rules, DDD patterns, quality principles) without modifying the framework. Convention over configuration: works out of the box, overridable for advanced users. | Our strategy.md discussions |
| Knowledge compounding deferred to future scope | Compound Engineering's `docs/solutions/` flywheel pattern is proven for capturing learnings. But building it before the core framework is stable adds complexity without immediate value. Ship core first, add flywheel later. | Compound Engineering analysis |

---

## 13. Future Scope

These items are explicitly deferred. They are important but not essential for v1 of the framework.

| Item | Description | Blueprint |
|------|-------------|-----------|
| **Retrospective Capture atom** | Mechanism for harvesting learnings from AI sessions: prompts that worked, patterns that emerged, anti-patterns discovered. Feeds back into all other atoms. | Model after Compound Engineering's `docs/solutions/` pattern -- categorized solution docs with YAML frontmatter, searchable during planning |
| **Multi-tool CLI converter** | Convert our Claude Code canonical format to Cursor, Copilot, Gemini, Codex, OpenCode, and other tools. | Model after Compound Engineering's Bun/TypeScript CLI (`src/converters/claude-to-*.ts`). One converter per target, convention-based discovery |
| **Knowledge Base Crafter** | Template-guided creation of knowledge priming documents. Same facilitative pattern as Architecture and DDD crafters. | Follow the crafter pattern from Section 6 with a 7-section template |
| **Init Experience** | First-5-minutes onboarding for new plugin users. Auto-detect project, suggest setup steps. | Critical for adoption. Could be a molecule: detect project -> suggest `/setup-architecture` -> suggest `/setup-ddd` -> create config |
| **Review Workflow** | ~~Separate post-implementation review step.~~ **Implemented** as the `review` molecule composing all atoms' validation checklists. | Molecule: clean-code + clean-architecture + domain-driven-design + secure-coding + test-quality (conditional loading based on delta) |
| **Skill-Level Selector** | Beginner/intermediate/expert modes. Different levels of explanation and hand-holding. | Config key in `.ai/config.yaml`: `skill_level: intermediate`. Each atom adjusts verbosity based on level. Start with intermediate, add others if demand emerges |
| **Context Window Optimization** | Summaries vs full docs depending on task size and context budget. | Address after first-pass validation. Could use token counting to decide whether to load full defaults or a summary |
| **Config Schema Validation** | Formal JSON schema for `.ai/config.yaml` with error reporting. | Write a JSON schema, add a validation script to `scripts/` |
| **Template Refinement** | Evolve crafter templates based on usage patterns. Generic quotient in templates. | Track which template questions produce the most useful answers. Simplify or expand based on real-world usage |
| **Flywheel / Learning Loop** | Systematic mechanism for learnings to flow back into atoms. Design once the system is running and producing data. | Requires retrospective capture atom first. Then: capture -> analyze -> update defaults -> validate improvement |

---

## Appendix A: Reference Repositories

| Repository | Stars | Key Contribution to Our Framework | URL |
|-----------|-------|----------------------------------|-----|
| Superpowers | 67k | Plugin infrastructure, hooks, commands, namespace cross-references, process-oriented philosophy | https://github.com/obra/superpowers |
| Compound Engineering | 9.7k | Multi-tool CLI concept, knowledge compounding flywheel, convention-based discovery | https://github.com/EveryInc/compound-engineering-plugin |
| Anthropic Skills | 80k | Agent Skills spec, skill-creator development harness, progressive disclosure, writing principles | https://github.com/anthropics/skills |

## Appendix B: Relationship to Strategy Document

This implementation blueprint translates every decision from [strategy.md](strategy.md) into actionable specifications:

| Strategy Concept | Implementation Section |
|-----------------|----------------------|
| Three Foundational Techniques | Atoms 4.1-4.3 (knowledge-priming, design-first, decision-capture) |
| Atoms, Molecules, Adapters architecture | Sections 2 (structure), 4 (atoms), 5 (molecules), 8 (commands as adapters) |
| Atom Inventory | Section 4 (6 atom specifications) |
| Molecule Inventory | Section 5 (4 molecule specifications) |
| Clean Architecture vs DDD | Atoms 4.4-4.5 (separate skills, shared contract) |
| Configuration & Document Location | Section 7 (config schema, `.ai/` folder) |
| Override Mechanism | Section 3.6 (Config Resolution) and Section 7.2 (resolution rules) |
| Crafter Skills | Section 6 (architecture-crafter, ddd-crafter) |
| Context Injection | Section 9 (automatic DDD activation) |
| Per-Feature Workflow | Molecules 5.1-5.4 (start, continue, design, implement) |
| Key Design Decisions | Section 12 (expanded with implementation rationale) |
| Future Scope | Section 13 (with blueprints from reference repos) |

---

*This document is the source of truth for implementing the AI Skills Framework. It evolves as implementation progresses and decisions are refined.*

*Last updated: 2026-02-26*
