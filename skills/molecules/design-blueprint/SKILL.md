---
name: design-blueprint
description: "Run a complete design workflow -- from establishing context through 5 progressive design levels to an approved blueprint. Composes context anchoring, design-first methodology, clean architecture, and DDD into a unified process. Handles both new features (create context doc) and resuming existing work (load context doc). Use when starting a design, planning architecture, or when the user says 'design a feature', 'blueprint', 'start designing', 'plan the architecture', or 'let's design before coding'."
---

# Design Blueprint

## Required Skills

Read and apply these skills in order:

1. `framework:knowledge-priming` -- Load project context (tech stack, architecture, conventions) to ground all design decisions in the real project
2. `framework:context-anchoring` -- Create or load the feature's context anchor document
3. `framework:collaborative-judgment` -- Surface genuine design judgment calls with structured options instead of silently assuming (always)
4. `framework:design-first` -- Walk through 5 progressive design levels
5. `framework:clean-architecture` -- Apply structural rules at Component and Interaction levels
6. `framework:domain-driven-design` -- Apply domain modeling at Component, Interaction, and Contract levels

## Workflow

### Step 1: Establish Context

Use `framework:context-anchoring` to set up the feature's living document.

- **Document Discovery**: Check for an existing context anchor document for the feature (scan the context base directory, match by feature name or frontmatter).
- **If exists** → Load (context-anchoring Load behavior). Present the structured acknowledgment -- feature name, decision count, open questions, constraints. Resume at the last design checkpoint recorded in the document.
- **If not** → Create (context-anchoring Create behavior). New feature document from template. Confirm the feature name, summary, and requirement doc link with the user before creating.

### Step 2: Walk the Design Levels

Drive through `framework:design-first`'s 5 levels sequentially. At each level, present the design output, get user approval, then **persist the approved output into the context anchor document before advancing**. The context document is the blueprint -- if it is not written down, it does not exist.

**The enrichment rule**: After the user approves each level, use `framework:context-anchoring` Enrich behavior to write the following into the context document:

1. The **approved level output** itself (capabilities list, component diagram, interaction flows, or contracts) -- captured as a **clean, structured summary** under a dedicated section for that level. Use the same format as the level's presentation: numbered list for Level 1, component table + diagram for Level 2, sequence/flow for Level 3, typed interfaces for Level 4.
2. Any **decisions made** during the level discussion -- choices, reasoning, alternatives rejected.
3. Any **constraints identified** -- non-negotiable boundaries that emerged.
4. Any **open questions** that surfaced but remain unresolved.

Do NOT advance to the next level until the current level's output is persisted. The context document must be the single source of truth at every stage.

When applying architectural atoms at each level, use `framework:collaborative-judgment` to surface genuine design judgment calls immediately — do not batch during design, as each level constrains the next.

Apply architectural atoms at the levels where they add value:

**Level 1 (Capabilities)**:
- Present the capabilities list per `framework:design-first`.
- On approval → Enrich context document with the approved capabilities under a `## Design: Level 1 -- Capabilities` section.

**Level 2 (Components)**:
- Apply `framework:clean-architecture` -- validate layer assignments, dependency direction, component boundaries. Each component should map to a clear architectural layer.
- Apply `framework:domain-driven-design` -- identify aggregates, entities, value objects. Determine which components live in the domain layer and which are infrastructure.
- On approval → Enrich context document with the approved component list, layer assignments, and diagram under a `## Design: Level 2 -- Components` section. Log architectural decisions (layer choices, DDD classifications) in the Decisions Log.

**Level 3 (Interactions)**:
- Apply `framework:clean-architecture` -- validate command/query flows and boundary crossing. State-changing operations should flow through domain before reaching repositories; read operations use providers.
- Apply `framework:domain-driven-design` -- define aggregate interactions, domain events. Cross-aggregate communication should use domain events for eventual consistency.
- On approval → Enrich context document with the approved interaction flows (sequence diagrams, data flow descriptions) under a `## Design: Level 3 -- Interactions` section. Log flow decisions in the Decisions Log.

**Level 4 (Contracts)**:
- Apply `framework:domain-driven-design` -- define repository interfaces, value object types, aggregate root boundaries. Contracts should reflect the tactical patterns agreed at earlier levels.
- On approval → Enrich context document with the approved interfaces and type definitions under a `## Design: Level 4 -- Contracts` section. Log contract decisions in the Decisions Log.

### Step 3: Finalize Blueprint

After Level 4 (Contracts) is approved and persisted:

- **Verify completeness**: The context document must now contain all four design level sections (Capabilities, Components, Interactions, Contracts) plus every decision made during the design process. If any level output is missing from the document, enrich it now before proceeding.
- **Write the design summary**: Use `framework:context-anchoring` Enrich to add a `## Design Summary` section to the context document containing:
  - Components and their layer assignments
  - Key contracts and interfaces
  - Architectural constraints
  - Domain model decisions (if applicable)
  - Open questions resolved during design
  - Design status: **Approved -- ready for implementation**
- **Log the completion decision**: Add a decision entry to the Decisions Log: "Design approved at Level 4. Blueprint is complete and ready for implementation."
- Present the summary to the user as confirmation.
- The design is complete. Do NOT proceed to Level 5 (Implementation) -- that is a separate concern handled by the `framework:code-forge` molecule or an equivalent implementation skill.
- Suggest the user invoke `/code-forge` when ready to begin coding against the approved blueprint.
