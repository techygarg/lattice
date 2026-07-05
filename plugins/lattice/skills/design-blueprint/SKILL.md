---
name: design-blueprint
description: "Run a complete design workflow -- from establishing context through 5 progressive design levels to an approved blueprint. Composes context anchoring, design-first methodology, architecture, and DDD into a unified process. Handles both new features (create context doc) and resuming existing work (load context doc). Use when starting a design, planning architecture, or when the user says 'design a feature', 'blueprint', 'start designing', 'plan the architecture', or 'let's design before coding'."
---

# Design Blueprint

## Required Skills

Read apply skills order:

1. `framework:knowledge-priming` -- Load project context (tech stack, architecture, conventions) ground decisions real project
2. `framework:context-anchoring` -- Create or load feature context anchor doc
3. `framework:learning-harvest` -- Load prior operational learnings inform design; harvest new patterns at session end (always)
4. `framework:collaborative-judgment` -- Surface real design judgment calls structured options instead silent assuming (always)
5. `framework:design-first` -- Walk through 5 progressive design levels
6. `framework:architecture` -- Apply structural rules Component and Interaction levels
7. `framework:domain-driven-design` -- Apply domain modeling Component, Interaction, Contract levels

## Workflow

### Step 1: Establish Context

Use `framework:learning-harvest` Load behavior. Focus hint: "design session — focus: design patterns, reliability, structural health".

Use `framework:context-anchoring` set up feature living doc.

- **Document Discovery**: Check existing context anchor doc feature (scan context base directory, match by feature name or frontmatter).
- **If exists** → Load (context-anchoring Load behavior). Present structured acknowledgment -- feature name, status, decision count, open questions, constraints. Resume last design checkpoint recorded doc.
- **If not** → Create (context-anchoring Create behavior). New feature doc from template. Confirm feature name, summary, requirement doc link with user before creating.

**Load requirement constraints**: Read `requirement_doc` from context doc frontmatter.
- Null/absent → skip.
- Local path → read it. Extract `## Technical Constraints`. Treat as non-negotiable — same authority as architecture rules. Surface to user before Level 1.
- External reference (URL, ticket ID, or other non-local-path identifier) → if a connected MCP tool can resolve it, fetch and extract constraints the same way. If no MCP tool is connected or the fetch returns nothing, ask the user to paste the current constraints directly — expected, not an error.
- Conflict during design → surface via `framework:collaborative-judgment`. User decides; record any change back in requirement doc `## Technical Constraints` if it is a local file. If external, record the change in the context doc's Decisions Log instead — this molecule never writes back to an external system.

**Write the back-link**: If `requirement_doc` resolved to a readable local file at `.lattice/requirements/features/{feature-name}.md`, write into its `## Links` section: `- Design: [{feature-name}.md](../../context/{feature-name}.md)`. Discrete file edit, done once — skip if the link is already present.

### Step 2: Walk the Design Levels

If key use cases or success criteria unclear now, use `framework:collaborative-judgment` surface what needs answering before starting Level 1.

Drive through `framework:design-first` 5 levels sequentially. Each level, present design output, get user approval, then **persist approved output into context anchor doc before advancing**.

**Enrichment rule**: After user approves each level, use `framework:context-anchoring` Enrich behavior write following into context doc:

1. **Approved level output** itself (capabilities list, component diagram, interaction flows, or contracts) -- captured as **clean, structured summary** under dedicated section that level. Use same format as level presentation: numbered list Level 1, component table + diagram Level 2, sequence/flow Level 3, typed interfaces Level 4.
2. **Decisions made** during level discussion -- choices, reasoning, alternatives rejected.
3. **Constraints identified** -- non-negotiable boundaries emerged.
4. **Open questions** surfaced but remain unresolved.

NOT advance next level until current level output persisted.

When applying architectural atoms each level, use `framework:collaborative-judgment` surface real design judgment calls immediately — not batch during design.

Apply architectural atoms levels where add value:

**Level 1 (Capabilities)**:
- Present capabilities list per `framework:design-first`.
- On approval → Enrich context doc with approved capabilities under `## Design: Level 1 -- Capabilities` section.

**Level 2 (Components)**:
- **Challenge each component before approving: does it need to exist?** An abstraction with one known implementation, a layer with one caller, or a component solving a problem that isn't confirmed yet — inline or defer it. Add complexity only when the design explicitly justifies it.
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

- **Check requirement spec drift**: Read `requirement_doc` from context doc frontmatter.
  - Null/absent → skip. Note in Design Summary: "No requirement doc — drift check skipped."
  - Local path, unreadable → STOP: "Requirement doc not found at `[path]`. Verify before continuing." (a broken local path is an error)
  - External reference, unresolvable (no connected MCP tool, or the fetch returns nothing) → do not STOP — this is expected, not broken. Ask the user to paste current constraints/scenarios if a comparison is wanted, or note in Design Summary: "Requirement doc is external and unavailable this session — drift check skipped."
  - Resolved (local file read, external reference fetched, or user pasted constraints) → compare L4 contracts against Scenarios/ACs and `## Technical Constraints`. Present findings: each divergence as `[field/behavior] — changed from [X] to [Y]. Reason: [from Decisions Log]`, or "L4 consistent with requirement spec — no overrides" if none. Ask: *"Record this in the requirement doc?"*
  - **STOP: do not write to `requirement_doc` until confirmed.** Confirmed and local → write each as `- Design override: [field/behavior] — changed from [X] to [Y]. Reason: [...]`, or `- Design alignment: L4 consistent with requirement spec — no overrides.` if none. Confirmed and external → this molecule never writes to an external system; note the findings in Design Summary instead. Declined → note in Design Summary instead: "Drift check results not written to requirement doc — see Decisions Log."
  - **STOP: Do not set `status: approved` until this check is complete.**

- **Write design summary**: Use `framework:context-anchoring` Enrich add `## Design Summary` section to context doc containing:
  - Components and layer assignments
  - Key contracts and interfaces
  - Architectural constraints
  - Domain model decisions (if applicable)
  - Open questions resolved during design
- **Set approved status**: Write `status: approved` to context doc frontmatter. **STOP: discrete file edit — not prose.** Without this, code-forge will not proceed.

  **STOP: do not write status to `requirement_doc`.** The feature file's status is owned by whoever manages the requirement — a human, or an external system it may live in. This molecule manages its own context doc only.
- **Log completion decision**: Add decision entry Decisions Log: "Design approved at Level 4. Status set to approved — ready for implementation."
- Present summary user as confirmation.
- Design complete. NOT proceed Level 5 (Implementation).
- **Harvest learnings.** Use `framework:learning-harvest` Harvest behavior. Session context: "design session — architectural decomposition and contract definition". Synthesize and propose cross-cutting patterns from this session — decomposition approaches, architectural trade-offs, scope decisions that could inform future designs. User confirms what enters the document. **STOP: run this before the next bullet — do not jump straight to the `/code-forge` suggestion.**
- Suggest user invoke `/code-forge` when ready begin coding against the approved design.