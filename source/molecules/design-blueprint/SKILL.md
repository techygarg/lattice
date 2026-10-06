---
name: design-blueprint
description: "Run a complete design workflow -- from establishing context through four progressive design levels (Capabilities, Components, Interactions, Contracts) to an approved blueprint. Composes knowledge-priming, context-anchoring, learning-harvest, collaborative-judgment, design-first, architecture, and domain-driven-design into one process. Handles both new features (create context doc) and resuming existing work (load context doc). Level 5 (Implementation) is delegated to code-forge. Use when starting a design, planning architecture, or when the user says 'design a feature', 'blueprint', 'start designing', 'plan the architecture', or 'let's design before coding'."
---

# Design Blueprint

## Required Skills

Read and apply in order before Step 1:

1. `framework:knowledge-priming` -- Load the project knowledge base so every decision grounds in the real project. (always)
2. `framework:context-anchoring` -- Create or load the feature's living context doc (Create / Load / Enrich behaviors). (always)
3. `framework:learning-harvest` -- Load prior operational learnings at session start; harvest new ones at session end. (always)
4. `framework:collaborative-judgment` -- Surface genuine judgment calls as structured options instead of silently assuming. (always)
5. `framework:lattice-store` -- Resolve where living documents live; derive the store from an out-of-repo requirement doc. (always)
6. `framework:design-first` -- Owns the 5-level methodology. Its Entry Assessment, Complexity Calibration, Simplicity Check, and Level Completion Protocol govern Step 2. (Step 2)
7. `framework:architecture` -- Validate components, layers, dependency direction, and boundary rules (design mode). (Levels 2-4)
8. `framework:domain-driven-design` -- Model aggregates, entities, value objects, events, and contracts (design mode). (Levels 2-4)

## Workflow

### Step 1: Establish Context

1. **Derive the store**: if the user supplied a requirement doc, run `framework:lattice-store` Derive Behavior before anything else — it decides where learnings and context docs live for this session.
2. Run `framework:learning-harvest` Load behavior. Focus hint: "design session — focus: design patterns, reliability, structural health".
3. Set up the feature's living doc with `framework:context-anchoring`:
   - **Discover**: scan `<context_base>` (resolved via `framework:lattice-store`) for an existing anchor doc matching the feature name or frontmatter.
   - **Found** → Load behavior. Present the structured acknowledgment: feature name, status, decision count, open questions, constraints. Then run the resume check below.
   - **Not found** → Create behavior. Confirm the feature name, summary, and requirement doc link with the user before creating. Then begin Step 2 — the Entry Assessment sets the entry level.

4. **Resume check** (when a doc was found) — derive the earliest incomplete step from the doc itself. **STOP:** Never re-walk agreed work:
   - `status: approved` → design is finished. Say so and stop; suggest `/code-forge`.
   - No sections starting `## Design: Level` → begin Step 2 — the Entry Assessment (and its spec rule) sets the entry level.
   - Some levels persisted → summarize the approved levels briefly, then resume at the first missing level at or after the recorded entry level (the `[Entry]` Decisions Log entry; older docs without one → treat entry as Level 1).
   - Every level from entry through Level 4 persisted, but no `## Design Summary`, or `status` ≠ `approved` → go directly to Step 3.

5. **Requirement constraints**: read `requirement_doc` from the context doc frontmatter.
   - Absent → skip.
   - Local path, unreadable → STOP: "Requirement doc not found at `[path]`. Verify before continuing."
   - Local path, readable → read it and extract `## Technical Constraints`. Treat as non-negotiable — same authority as architecture rules. Surface to the user before the first level is presented.
   - External reference (URL, ticket ID, or other non-local-path identifier) → resolve via a connected MCP tool if one can. If none is connected or the fetch returns nothing, ask the user to paste the current constraints — expected, not an error.
   - Either path resolved to the spec itself (not pasted constraints only) → Step 2's spec rule applies.
   - Conflict during design → surface via `framework:collaborative-judgment`. The user decides; record the change back in the requirement doc's `## Technical Constraints` if local, or in the Decisions Log if external — this molecule never writes to an external system.

6. **Write the back-link**: if `requirement_doc` resolved to a readable local file under `<requirements_base>features/` (resolved via `framework:lattice-store`), add to its `## Links` section: `- Design: [{feature-name}.md](<link>)`, where `<link>` is the path from the feature file's directory (`<requirements_base>features/`) to `<context_base>{feature-name}.md` — relative when both are in the same repo, absolute otherwise. Default layout → `../../context/{feature-name}.md`. **STOP: verify the link resolves to the context doc from the feature file's directory before writing it.** One discrete file edit; skip if the link is already present.

### Step 2: Walk the Design Levels

Run design-first's Entry Assessment first: state the proposed entry level from its Complexity Calibration table and wait for confirmation. Record the confirmed entry level as the first Decisions Log entry: `[Entry] Start at Level N (name) — rationale.` If key use cases or success criteria are unclear, surface them via `framework:collaborative-judgment` before producing the first level output.

**Spec as Level 1**: when the context doc has no `## Design: Level` section yet and `requirement_doc` resolved to the spec itself, the spec is Level 1. Do not re-validate it — spec quality belongs to requirement-forge.
- Propose entry at Level 2 or the calibrated level, whichever is later, and offer: "Level 1 comes from the linked spec. Starting at Level [N]. Want a capabilities walk-through first?" **STOP — do NOT advance until the user answers.**
- User wants the walk-through → enter at Level 1, using the spec as input.
- Otherwise, save `## Design: Level 1 -- Capabilities` as one line: `Taken from [{spec-file}](../requirements/features/{spec-file}). Not re-walked.` — the link is relative to the context doc; an external spec gets its reference instead. Do not copy the spec.

Drive the levels sequentially from the confirmed entry level through Level 4 via `framework:design-first`. Complexity Calibration sets how deep each level goes; it never removes a gate or skips persistence.

**Gate (every level)** — follow design-first's Level Completion Protocol: present the level output with its targeted gating question, then **STOP — do NOT advance until the user explicitly confirms**, not on silence, not on ambiguity.

**Persist (after every approval, before advancing)** — use `framework:context-anchoring` Enrich to write into the context doc:
1. The approved output as a clean structured summary under `## Design: Level N -- {Name}`, same format as presented (numbered list L1; component table + diagram L2; sequence/flow L3; typed interfaces L4). Persist diagrams as Mermaid.
2. One Decisions Log entry per decision: `[Level N] Chose X because Y. Rejected: Z.`
3. Constraints identified during the discussion (non-negotiable boundaries that emerged).
4. Open questions surfaced but unresolved.

**STOP:** Do not present the next level until these writes are done.

**Judgment calls**: when applying architectural atoms at any level, surface genuine design judgment calls immediately via `framework:collaborative-judgment` — never batch them to the end of a level.

**Evidence rule (Level 2)**: before presenting components, quickly explore the codebase and map each proposed component to the existing modules/packages it extends, wraps, or modifies — or mark it `new`. Present the mapping with the components. Never invent a parallel structure that ignores what exists.

Level-specific applications:

- **Level 1 (Capabilities)**: numbered user-facing capabilities, max 5, no technical detail (per design-first).
- **Level 2 (Components)**: challenge each component before approving — does it need to exist? One known implementation, one caller, or an unconfirmed problem → inline it or defer. Then validate in design mode: `framework:architecture` (layer mapping, dependency direction, boundary clarity) and `framework:domain-driven-design` (aggregates, entities, value objects; domain vs infrastructure placement).
- **Level 3 (Interactions)**: `framework:architecture` — data flows follow the loaded patterns; boundary-crossing rules respected. `framework:domain-driven-design` — cross-aggregate communication uses domain events / eventual consistency.
- **Level 4 (Contracts)**: `framework:domain-driven-design` — repository interfaces, value object types, aggregate root boundaries reflecting the tactical choices from earlier levels. `framework:architecture` — boundary-data rules and interface ownership respected. Every Level 3 interaction maps to at least one interface.

**Regression rule**: if the user reopens an approved level, re-run that level's gate. On re-approval, mark every downstream persisted level section stale ("stale — pending re-approval after Level N change") and re-present them for confirmation before Step 3. **STOP:** Never leave contradictory approved sections in the doc.

**Early exit**: if the user wants to stop or shortcut the design, follow design-first's Mid-level exit. Persist whatever was approved and leave `status` as `draft` — a partial doc is a valid outcome.

### Step 3: Finalize Blueprint

After Level 4 is approved and persisted:

1. **Verify completeness and consistency**: the context doc must contain all four level sections plus every decision made during the design. Enrich anything missing now. Then check:
   - Every Level 3 interaction maps to at least one Level 4 interface.
   - Every Level 4 interface is owned by exactly one Level 2 component (a shared type is owned by its defining component).
   Fix any gap through the affected level's gate — never silently.

2. **Check requirement spec drift**: read `requirement_doc` from the context doc frontmatter.
   - Absent → note in Design Summary: "No requirement doc — drift check skipped."
   - Local path, unreadable → STOP: "Requirement doc not found at `[path]`. Verify before continuing." (A broken local path is an error.)
   - External reference, unresolvable (no connected MCP tool, or the fetch returns nothing) → do not STOP — expected, not broken. Ask the user to paste current constraints/scenarios if a comparison is wanted, or note in Design Summary: "Requirement doc is external and unavailable this session — drift check skipped."
   - Resolved (local file read, external fetch succeeded, or user pasted constraints) → compare L4 contracts against Scenarios/ACs and `## Technical Constraints`. Present each divergence as `[field/behavior] — changed from [X] to [Y]. Reason: [from Decisions Log]`, or "L4 consistent with requirement spec — no overrides" if none. Ask: *"Record this in the requirement doc?"*
   - **STOP: do not write to `requirement_doc` until confirmed.** Confirmed and local → write each finding into the requirement doc's `## Links` section as `- Design override: [field/behavior] — changed from [X] to [Y]. Reason: [...]`, or `- Design alignment: L4 consistent with requirement spec — no overrides.` if none. Confirmed and external → this molecule never writes to an external system; record the findings in the Design Summary instead. Declined → note in Design Summary: "Drift check results not written to requirement doc — see Decisions Log."

3. **Write the design summary**: use `framework:context-anchoring` Enrich to add a `## Design Summary` section containing components and layer assignments, key contracts and interfaces, architectural constraints, domain model decisions (if applicable), and open questions resolved during design.

4. **Set approved status**: write `status: approved` into the context doc frontmatter. **STOP: discrete file edit — not prose.** Without it, code-forge will not proceed. **STOP: never write status to `requirement_doc`** — the requirement's status belongs to whoever manages it (a human, or an external system); this molecule manages only its own context doc.

5. Log the completion decision: "Design approved at Level 4. Status set to approved — ready for implementation." Present the summary to the user as confirmation.

6. **Harvest learnings**: run `framework:learning-harvest` Harvest behavior. Session context: "design session — architectural decomposition and contract definition". Synthesize and propose cross-cutting patterns from this session — decomposition approaches, architectural trade-offs, scope decisions that could inform future designs. The user confirms what enters the document. **STOP: run this before the next bullet — do not jump straight to the `/code-forge` suggestion.**

7. Design complete. Do NOT proceed to Level 5 (Implementation). Suggest the user invoke `/code-forge` when ready to begin coding against the approved design.
