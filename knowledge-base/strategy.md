# Skills Framework: Strategy & Hypothesis

> A composable, customizable, tool-agnostic AI collaboration framework backed by three compounding techniques — Knowledge Priming, Design-First, and Context Anchoring — with Clean Architecture and DDD guardrails layered on top. Target: publishable as a plugin, starting with Cursor/Claude, structured to scale to Copilot and others.

---

## 1. The Three Foundational Techniques

Three techniques form the backbone. Each solves a distinct problem in the human–AI collaboration lifecycle:

| Technique | Problem It Solves | When It Acts |
|-----------|-------------------|--------------|
| **Knowledge Priming** | AI defaults to "the average of the internet" | Before work — onboarding |
| **Design-First** | AI collapses design + implementation into one step | During work — the thinking process |
| **Context Anchoring** | AI forgets decisions as conversations grow | Across sessions — memory persistence |

These techniques **compound**: priming feeds design-first, design-first produces artifacts that anchoring preserves, anchoring feeds the next priming. It is a cycle, not a menu.

**Reference blogs**: `blogs/martin-fowler/02-onboarding-context-for-coding-assistants.md`, `blogs/martin-fowler/03-design-first-collaboration.md`, `blogs/05-context-problem.md`

---

## 2. Architecture: Atoms, Molecules, Adapters

Three layers, from reusable foundations to user-facing entry points.

```
┌─────────────────────────────────────────────────┐
│  ADAPTERS (Tool-Specific)                       │
│  Cursor: .cursor/commands/   Claude: /commands  │
│  Copilot: .github/prompts/                      │
│  ─ Thin wrappers, invoke molecules ─            │
├─────────────────────────────────────────────────┤
│  MOLECULES (Composite Workflows)                │
│  Start Feature │ Continue Feature │ Implement   │
│  Design w/ DDD │ (future: Review, Init)         │
│  ─ Compose atoms for a workflow ─               │
├─────────────────────────────────────────────────┤
│  ATOMS (Foundational Skills — Tool-Agnostic)    │
│  Knowledge Priming │ Design-First │ Decision    │
│  Clean Architecture │ DDD │ Quality Reasoning   │
│  (future: Retrospective Capture)                │
│  ─ Each has: embedded defaults + override path ─│
├─────────────────────────────────────────────────┤
│  .ai/ (Config + Documents)                      │
│  config.yaml │ knowledge-base.md │ ca-doc.md    │
│  ddd-doc.md │ feature-docs/ │ ...               │
│  ─ Single source of truth, version-controlled ─ │
├─────────────────────────────────────────────────┤
│  CRAFTERS (Setup Phase — One-time)              │
│  Architectural Crafter │ DDD Crafter            │
│  (future: Knowledge Base Crafter)               │
│  ─ Facilitative conversation → produce docs ─   │
└─────────────────────────────────────────────────┘
```

---

## 3. Atom Inventory

| Atom | Responsibility |
|------|----------------|
| **Knowledge Base Authoring** | Create a priming document (7-section anatomy: architecture overview, tech stack, curated sources, project structure, naming conventions, code examples, anti-patterns) |
| **Progressive Design Facilitation** | 5-level methodology: Capabilities → Components → Interactions → Contracts → Implementation. No code until Level 5 approved. |
| **Decision Capture** | Record what, why, and what-not in living feature docs. Update immediately. Persist across sessions. |
| **Clean Architecture** | Structure the repository: controllers → services → domain → repositories. Enforce dependency rules. Validate generated code against structural constraints. |
| **Domain-Driven Design (DDD)** | Craft the domain: aggregates, bounded contexts, value objects, entities. Guardrails for domain design within a designated folder. |
| **Quality Reasoning** | Evaluate code against sensible defaults and principles (not just syntax/linting). |
| **Retrospective Capture** *(future)* | Harvest learnings after sessions: prompts that worked, patterns that emerged, anti-patterns discovered. Feeds back into all other atoms. |

---

## 4. Molecule Inventory

| Molecule | Atoms Composed | Purpose |
|----------|----------------|---------|
| **Start a Feature** | Knowledge Priming + Design-First + Decision Capture | Begin new work with full context and structured design |
| **Continue a Feature** | Load Context (anchoring) + Resume from checkpoint | Cross session boundaries without losing decisions |
| **Design with DDD** | DDD + Progressive Design Facilitation | Domain modeling infused into each design level |
| **Implement** | Developer practices + Clean Architecture + DDD (when touching domain folder) | Code generation with structural and domain guardrails |

Molecule implementation is **tool-specific**: Cursor gets its adapter, Copilot gets its adapter, Claude gets its adapter. They internally invoke the same atoms. Some duplication at this layer is acceptable and expected.

---

## 5. Clean Architecture vs DDD: Two Separate Skills

- **Clean Architecture**: About **structure**. Controllers use services; services orchestrate domain; domain is passed to repositories. Provides structural design and validates generated code against structural rules.
- **DDD**: About **crafting the domain**. Aggregates, bounded contexts, value objects over primitives, entities. Lives in a specific folder (e.g. `domain/`, `src/domain/`).

**Scope**: Single repository. One API (Order, User, Pricing) — the DDD implementation within that repo. Not whole-system DDD mapping.

**Shared contract**: Clean Architecture provides the structural envelope. DDD provides the domain-crafting rules within the domain folder. The rest of the codebase is a mix of Clean Architecture, DDD, and normal developer practices.

---

## 6. Configuration & Document Location

### .ai/ Folder Standard

- **Default location**: `.ai/` at repository root
- **Config file**: `.ai/config.yaml` — single source of truth (paths, enabled skills, document references)
- **Custom paths**: Skills allow user-specified paths; config overrides defaults

### Document Ecosystem

| Document | Purpose | Lives At |
|----------|---------|----------|
| Config | Framework settings, paths, overrides | `.ai/config.yaml` |
| Knowledge Base | Stack, versions, conventions, curated sources | `.ai/knowledge-base.md` (or custom) |
| Clean Architecture | Structural rules, layer responsibilities, dependency direction | `.ai/clean-architecture.md` (or custom) |
| DDD Principles | Domain guardrails: aggregates, value objects, bounded contexts | `.ai/ddd-principles.md` (or custom) |
| Feature Docs | Living decision logs per feature | `.ai/feature-docs/` (or custom) |

### Override Mechanism (Layered Pattern)

Each skill ships with **embedded opinionated defaults** (our baseline). If the user has produced their own document (via crafter or manually), the config points to it and the override takes precedence. Cold-start works out of the box — no setup required for basic usage.

### Relationship Between Documents

Knowledge Base (priming) covers repo-level concerns — stack, versions, conventions. It **references** CA and DDD docs rather than duplicating them. Three documents, three distinct concerns, three different update frequencies.

---

## 7. Crafter Skills (Setup Phase)

For the initial phase when documents don't exist yet:

| Crafter | Produces | Mechanism |
|---------|----------|-----------|
| **Architectural Crafter** | Clean Architecture principles document | Facilitative conversation using predefined template → formal document written to configured location |
| **DDD Crafter** | DDD principles document (guardrails for domain design) | Same: template-guided conversation → formal document |
| **Knowledge Base Crafter** *(future)* | Priming document | Same pattern |

These are **not regular activities**. They run during repository setup or when principles need to be (re)defined.

**DDD document scope**: Guardrails for domain design — how to think about aggregates, bounded contexts, value objects. It defines the *rules of crafting*, not the evolving domain model itself.

**Template quality is critical**: A sloppy facilitation produces a sloppy document, which produces sloppy guidance downstream. The template's ability to ask the right questions is the key quality lever.

---

## 8. Context Injection: Automatic DDD Activation

When AI touches code in the domain folder, the DDD skill is **automatically** part of the context. No manual invocation needed.

**Flow**:
1. Design-First reaches Level 4 (Contracts) → decisions captured in feature doc
2. User approves → moves to implementation (Level 5)
3. Developer/Implement skill generates code
4. **If** the implementation touches the domain folder → DDD principles are auto-injected
5. AI applies DDD guardrails (value objects over primitives, aggregate boundaries, etc.) without explicit user action

---

## 9. Per-Feature Workflow

```
[Setup Phase — One-time or rare]
  Crafter Skills → Produce CA doc, DDD doc → Stored in .ai/ (or custom path)

[Per-Feature Workflow]
  1. Load Knowledge (priming) + Load Context (feature doc, if continuing)
  2. Design-First (Levels 1–4) → Update feature doc with decisions
  3. Approve Level 5 → Implement
  4. Implement: applies CA structure; auto-injects DDD when editing domain folder
  5. Context Anchoring: update feature doc as new decisions are made
```

---

## 10. Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **One skill level (intermediate)** | Avoids premature complexity. Ship one level done well. Add beginner/expert later if needed. |
| **Skills ship opinionated, everything overridable** | Convention over configuration. Good defaults out of the box, escape hatches for advanced users. |
| **Tool-agnostic atoms, tool-specific adapters** | Atoms are portable markdown. Adapters are a thin wrapper layer with expected duplication per tool. |
| **Start with one tool, then expand** | Ship for Cursor/Claude first. Learn. Structure supports later expansion to Copilot and others. |
| **Validation is inline, not a separate workflow step** | Skills loaded with CA/DDD instructions self-enforce compliance. Separate review process is a later concern. |
| **First-pass acceptance over optimization** | Load what's needed to get it right the first time. Optimize context window budget later. |

---

## 11. Future Scope

| Item | Notes |
|------|-------|
| **Flywheel / Retrospective Capture** | Mechanism for learnings to flow back into atoms. Design once the system is running. |
| **Init Experience** | First-5-minutes onboarding for new plugin users. Critical for adoption. |
| **Review Workflow** | Separate post-implementation review step using Quality Reasoning atom. |
| **Skill-Level Selector** | Beginner/expert modes if demand emerges. |
| **Context Window Optimization** | Summaries vs full docs depending on task. Address after first-pass validation. |
| **Knowledge Base Crafter** | Template-guided creation of priming docs (same pattern as CA/DDD crafters). |
| **Template Refinement** | Generic quotient in crafter templates; evolve over time based on usage. |
| **Config Schema** | Exact `.ai/config.yaml` schema definition. |

---

## 12. What Makes This Different

Most open-source AI skill/prompt collections are flat prompt libraries — isolated recipes for individual tasks. This framework is different in three ways:

1. **Process-oriented, not task-oriented.** Skills teach AI *how to think* (cognitive sequencing, framing, persistence), not just *what to produce*.
2. **Composable.** Atoms combine into Molecules. The same DDD atom works inside "Design with DDD" and inside "Implement." Skills are building blocks, not monoliths.
3. **Compounding.** The three techniques form a cycle where each makes the others more effective. This is the thesis: AI collaboration improves not through better prompts, but through better *process*.

---

*Last updated: 2026-02-28 | Living document — evolves with design discussions*
