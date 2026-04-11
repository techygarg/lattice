---
name: design-blueprint
description: "Run a complete design workflow -- from establishing context through 5 progressive design levels to an approved blueprint. Composes context anchoring, design-first methodology, architecture, and DDD into a unified process. Handles both new features (create context doc) and resuming existing work (load context doc). Use when starting a design, planning architecture, or when the user says 'design a feature', 'blueprint', 'start designing', 'plan the architecture', or 'let's design before coding'."
---

# Design Blueprint

## Required Skills

Read apply skills order:

1. `framework:knowledge-priming` -- Load project context (tech stack, architecture, conventions) ground decisions real project
2. `framework:context-anchoring` -- Create or load feature context anchor doc
3. `framework:collaborative-judgment` -- Surface real design judgment calls structured options instead silent assuming (always)
4. `framework:design-first` -- Walk through 5 progressive design levels
5. `framework:architecture` -- Apply structural rules Component and Interaction levels
6. `framework:domain-driven-design` -- Apply domain modeling Component, Interaction, Contract levels

## Workflow

### Step 1: Establish Context

Use `framework:context-anchoring` set up feature living doc.

- **Document Discovery**: Check existing context anchor doc feature (scan context base directory, match by feature name or frontmatter).
- **If exists** → Load (context-anchoring Load behavior). Present structured acknowledgment -- feature name, decision count, open questions, constraints. Resume last design checkpoint recorded doc.
- **If not** → Create (context-anchoring Create behavior). New feature doc from template. Confirm feature name, summary, requirement doc link with user before creating.

### Step 2: Walk the Design Levels

If key use cases or success criteria unclear now, use `framework:collaborative-judgment` surface what needs answering before starting Level 1.

Drive through `framework:design-first` 5 levels sequentially. Each level, present design output, get user approval, then **persist approved output into context anchor doc before advancing**. Context doc is blueprint -- if not written down, not exist.

**Enrichment rule**: After user approves each level, use `framework:context-anchoring` Enrich behavior write following into context doc:

1. **Approved level output** itself (capabilities list, component diagram, interaction flows, or contracts) -- captured as **clean, structured summary** under dedicated section that level. Use same format as level presentation: numbered list Level 1, component table + diagram Level 2, sequence/flow Level 3, typed interfaces Level 4.
2. **Decisions made** during level discussion -- choices, reasoning, alternatives rejected.
3. **Constraints identified** -- non-negotiable boundaries emerged.
4. **Open questions** surfaced but remain unresolved.

NOT advance next level until current level output persisted. Context doc must be single source truth every stage.

When applying architectural atoms each level, use `framework:collaborative-judgment` surface real design judgment calls immediately — not batch during design, each level constrains next.

Apply architectural atoms levels where add value:

**Level 1 (Capabilities)**:
- Present capabilities list per `framework:design-first`.
- On approval → Enrich context doc with approved capabilities under `## Design: Level 1 -- Capabilities` section.

**Level 2 (Components)**:
- Apply `framework:architecture` -- validate each component maps defined architectural layer, dependencies follow loaded architecture rules, component boundaries clear.
- Apply `framework:domain-driven-design` -- identify aggregates, entities, value objects. Determine which components live domain layer which infrastructure.
- On approval → Enrich context doc with approved component list, layer assignments, diagram under `## Design: Level 2 -- Components` section. Log architectural decisions (layer choices, DDD classifications) Decisions Log.

**Level 3 (Interactions)**:
- Apply `framework:architecture` -- validate data flows follow patterns defined loaded architecture doc and boundary crossing rules respected.
- Apply `framework:domain-driven-design` -- define aggregate interactions, domain events. Cross-aggregate communication should use domain events eventual consistency.
- On approval → Enrich context doc with approved interaction flows (sequence diagrams, data flow descriptions) under `## Design: Level 3 -- Interactions` section. Log flow decisions Decisions Log.

**Level 4 (Contracts)**:
- Apply `framework:domain-driven-design` -- define repository interfaces, value object types, aggregate root boundaries. Contracts should reflect tactical patterns agreed earlier levels.
- Apply `framework:architecture` -- validate contracts respect boundary-data rules and interface ownership per loaded architecture doc.
- On approval → Enrich context doc with approved interfaces and type definitions under `## Design: Level 4 -- Contracts` section. Log contract decisions Decisions Log.

### Step 3: Finalize Blueprint

After Level 4 (Contracts) approved and persisted:

- **Verify completeness**: Context doc must now contain all four design level sections (Capabilities, Components, Interactions, Contracts) plus every decision made during design process. If any level output missing from doc, enrich now before proceeding.
- **Write design summary**: Use `framework:context-anchoring` Enrich add `## Design Summary` section to context doc containing:
  - Components and layer assignments
  - Key contracts and interfaces
  - Architectural constraints
  - Domain model decisions (if applicable)
  - Open questions resolved during design
  - Design status: **Approved -- ready for implementation**
- **Log completion decision**: Add decision entry Decisions Log: "Design approved at Level 4. Blueprint complete ready for implementation."
- Present summary user as confirmation.
- Design complete. NOT proceed Level 5 (Implementation) -- that separate concern handled by `framework:code-forge` molecule or equivalent implementation skill.
- Suggest user invoke `/code-forge` when ready begin coding against approved blueprint.