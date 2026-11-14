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
5. `framework:design-first` -- Owns the 5-level methodology. Its Entry Assessment, Complexity Calibration, Simplicity Check, and Level Completion Protocol govern Step 2. (Step 2)
6. `framework:architecture` -- Validate components, layers, dependency direction, and boundary rules (design mode). (Levels 2-4)
7. `framework:domain-driven-design` -- Model aggregates, entities, value objects, events, and contracts (design mode). (Levels 2-4, conditional: the design has domain-layer components)

**Where this workflow overrides its atoms** — on these points the text here wins over the atom's own wording:

- **Confirmations** (context-anchoring): the user's request, the Create confirmation, and each gate are the confirmations the atom asks for. Load an exact match for the feature the user named without asking. Do not ask again before writing what a gate just approved — the `[Entry]` row, level sections and their decisions, the Design Summary, `status`. Decisions made mid-level are written at that level's Persist; do not suggest or confirm enrichment separately.
- **Requirement doc** (context-anchoring's "do not modify it"): this workflow edits a local requirement doc in exactly three places — the constraint change and the back-link in Step 1, and the drift lines in Step 3. Only the Step 3 lines need a confirmation.
- **Learnings queue** (learning-harvest): do not surface the queue when the last level is approved — the Step 3 Harvest follows immediately.
- **Level 4 question and Mid-level exit** (design-first): replaced by Step 2's Gate and Early exit rules. This workflow never offers Level 5 and never writes code.

<!-- include: additional-instructions -->

## Workflow

### Step 1: Establish Context

1. Run `framework:learning-harvest` Load behavior. Focus hint: "design session — focus: design patterns, reliability, structural health".
2. Set up the feature's living doc with `framework:context-anchoring`:
   - **Discover**: run context-anchoring Document Discovery — scan the context base directory (per the atom's Config Resolution) for an existing anchor doc matching the feature name or frontmatter.
   - **Found** → Load behavior. Present the structured acknowledgment: feature name, status, decision count, open questions, constraints. Then run the resume check below.
   - **Not found** → Create behavior. Confirm the feature name, summary, requirement doc link, and path with the user in one message before creating. Resume point: Step 2 — the Entry Assessment sets the entry level.

3. **Resume check** (when a doc was found) — derive the resume point from the doc itself; the first matching row wins. Finish sub-steps 4–5 before going there, unless the row says stop. **STOP:** Never re-walk agreed work.

   | Doc state | Resume point |
   |---|---|
   | `status: complete` | Closed — the feature is implemented; never reopen this doc. The user wants new scope or a change → Create a new context doc named for the change, and name this doc in its one-line summary. Otherwise say so and stop. |
   | `status: approved` | Finished. The user asked to change the design, or `## Open Questions` holds a `[for design]` entry from code-forge → Step 2's Regression rule, from the earliest level the change touches. Otherwise say so and stop; suggest `/code-forge`. |
   | No section starting `## Design: Level` | Step 2. An `[Entry]` row exists → enter at that level without asking again. Otherwise the Entry Assessment (and its spec rule) sets the entry level. |
   | A level at or after the entry level is missing or marked stale | Summarize the approved levels briefly, then Step 2 at the first such level. A stale level is re-presented for confirmation, not redesigned. |
   | Every level from entry through Level 4 persisted, none stale | Step 3. |

   The entry level is the `[Entry]` Decisions Log row; older docs without one → treat entry as Level 1.

4. **Requirement constraints**: read `requirement_doc` from the context doc frontmatter.
   - Absent → skip.
   - Local path, unreadable → STOP: "Requirement doc not found at `[path]`. Verify before continuing."
   - Local path, readable → read it and extract `## Technical Constraints`. Treat as non-negotiable — same authority as architecture rules. Surface to the user before the first level is presented. Its `## Scenarios` still carries requirement-forge's in-progress line (`*(In progress — scenarios not yet confirmed.)*`) → add one line, and do not stop: "The linked spec is still being written — its scenarios are not yet confirmed, so Level 1 may change."
   - External reference (URL, ticket ID, or other non-local-path identifier) → resolve via a connected MCP tool if one can. If none is connected or the fetch returns nothing — expected, not an error — ask the user to paste the current constraints, once per session (context-anchoring Load may already have asked; reuse that answer). Write pasted constraints into the context doc's `## Constraints`, marked `(from [reference], pasted YYYY-MM-DD)`. Already recorded there → show them and ask only whether anything changed.
   - Either path resolved to the spec itself by reading or fetching it → Step 2's spec rule applies. A paste never counts — it cannot be re-read next session.
   - Conflict during design → surface via `framework:collaborative-judgment`. The user decides; record the change back in the requirement doc's `## Technical Constraints` if local, or in the Decisions Log if external — this molecule never writes to an external system.

5. **Write the back-link**: if `requirement_doc` resolved to a readable local file, add to its `## Links` section (create it at the end if missing): `- Design: [{context-doc-filename}]({path from the requirement doc to this context doc})`. Several context docs may link one requirement (e.g. one per platform) — one line each. One discrete file edit; skip if this context doc's link is already present; replace the template's `- Design:` placeholder bullet if it is still there.

### Step 2: Walk the Design Levels

Run design-first's Entry Assessment first: state the proposed entry level from its Complexity Calibration table and wait for confirmation. When the spec rule below applies, its offer is the Entry Assessment question — ask once. Record the level actually entered as a Decisions Log row: Decision `[Entry] Start at Level N (name)`, Reasoning: the rationale. For each level before N that the spec rule does not cover, save `## Design: Level M -- {Name}` as one line: `Not walked — implicitly agreed at entry: [what the Entry Assessment stated as assumed].` If key use cases or success criteria are unclear, surface them via `framework:collaborative-judgment` before producing the first level output.

**Spec as Level 1**: when the context doc has no `## Design: Level` section yet and `requirement_doc` resolved to the spec itself, the spec is Level 1. Do not re-validate it — spec quality belongs to requirement-forge.
- Propose entry at Level 2 or the calibrated level, whichever is later, and offer: "Level 1 comes from the linked spec. Starting at Level [N]. Want a capabilities walk-through first?" **STOP — do NOT advance until the user answers.**
- User wants the walk-through → enter at Level 1, using the spec as input.
- Otherwise, save `## Design: Level 1 -- Capabilities` as one line: `Taken from [{spec-file}]({path from this context doc to the spec}). Not re-walked.` — compute the relative path from the actual locations of both files; an external spec gets its reference instead. Do not copy the spec.

Drive the levels sequentially from the confirmed entry level through Level 4 via `framework:design-first`. Complexity Calibration sets how deep each level goes; it never removes a gate or skips persistence.

**Gate (every level)** — follow design-first's Level Completion Protocol: present the level output with its targeted gating question, then **STOP — do NOT advance until the user explicitly confirms**, not on silence, not on ambiguity. At Level 4 ask instead: "Does this Level 4 (Contracts) look correct? Approving it lets me finalize the blueprint and mark the design approved." Never offer Level 5.

**Persist (after every approval — or, when a config line removed the gate, once the level is presented — before advancing)** — use `framework:context-anchoring` Enrich to write into the context doc:
1. The approved output in full — the artifact, not the discussion — under `## Design: Level N -- {Name}`, same format as presented (numbered list L1; component table with layer and existing-module mapping + diagram L2; sequence/flow L3; typed interfaces L4). Present and persist diagrams as Mermaid.
2. One Decisions Log row per decision: Decision `[Level N] Chose X`, Reasoning `Y`, Alternatives Considered `Z`.
3. Constraints identified during the discussion (non-negotiable boundaries that emerged).
4. Open questions surfaced but unresolved.
5. Detail the user gave for a later level (design-first's out-of-level input), under `## Open Questions` as `[for Level N] …`; remove each when its level is approved.

**STOP:** Do not present the next level until these writes are done.

**Judgment calls**: when applying architectural atoms at any level, surface genuine design judgment calls immediately via `framework:collaborative-judgment` — never batch them to the end of a level.

**Evidence rule (Level 2)**: before presenting components, quickly explore the codebase and map each proposed component to the existing modules/packages it extends, wraps, or modifies — or mark it `new`. Present the mapping with the components. Never invent a parallel structure that ignores what exists.

**Architecture fit (Level 2)**: when no `paths.architecture` document is configured and that exploration shows existing code that is not organized in the default layers, the design follows the code. Say so once: "No architecture document configured — this design follows the existing structure, not the clean-architecture defaults. Run `/architecture-refiner` to record it." Log it as a `[Level 2]` decision, give each component its place in the existing structure, and apply the architecture checks only where they do not contradict that structure. An empty repository has nothing to follow — the defaults apply. `framework:architecture` resolved no rules at all (custom mode, no document) → surface its message once, continue without architecture validation, and note the gap in the Design Summary.

Level-specific applications:

- **Level 1 (Capabilities)**: numbered user-facing capabilities, max 5, no technical detail (per design-first).
- **Level 2 (Components)**: challenge each component before approving — does it need to exist? One known implementation, one caller, or an unconfirmed problem → inline it or defer. Then validate in design mode: `framework:architecture` (layer mapping, dependency direction, boundary clarity) and, when the design has domain-layer components — business concepts with state and rules — `framework:domain-driven-design` (aggregates, entities, value objects; domain vs infrastructure placement). None → say once: "No domain model in this design — DDD checks skipped."
- **Level 3 (Interactions)**: `framework:architecture` — data flows follow the loaded patterns; boundary-crossing rules respected. `framework:domain-driven-design` (when it applies) — cross-aggregate communication uses domain events / eventual consistency.
- **Level 4 (Contracts)**: `framework:domain-driven-design` (when it applies) — repository interfaces, value object types, aggregate root boundaries reflecting the tactical choices from earlier levels. `framework:architecture` — boundary-data rules and interface ownership respected. Every Level 3 interaction maps to at least one interface.

**Regression rule**: if the user reopens an approved level, first set `status: draft` when it is `approved` (discrete file edit) and log a `[Reopen] Level N` decision with the reason. Then re-run that level's gate. On re-approval, replace that level's section and mark every downstream persisted level section stale (first line under its heading: "stale — pending re-approval after Level N change"). Re-present each stale level for confirmation and remove its marker before Step 3. The reopen came from a `[for design]` entry → remove that entry from `## Open Questions` once the reopened level is re-approved. **STOP:** Never leave contradictory approved sections in the doc.

**Early exit**: if the user wants to stop, or says "just build it" / "skip to code", do not refuse, and do NOT implement — this molecule never writes code. Name the tradeoff the way design-first's Mid-level exit does ("Skipping Level [N] means [what hasn't been aligned]"). Persist whatever was approved, plus any judgment call the user resolved for the level in progress, and leave `status` as `draft`. Then hand off: "Run `/code-forge` — it will ask before building on a draft design." A partial doc is a valid outcome.

### Step 3: Finalize Blueprint

After Level 4 is approved and persisted, and no level section is marked stale:

1. **Verify completeness and consistency**: the context doc must contain all four level sections — walked, or the one-line placeholder for a level taken from the spec or not walked — plus every decision made during the design. Enrich anything missing now. Then check, skipping a check when either level it names is a placeholder:
   - Every Level 3 interaction maps to at least one Level 4 interface.
   - Every Level 4 interface is owned by exactly one Level 2 component (a shared type is owned by its defining component).
   Fix any gap through the affected level's gate — never silently.

2. **Check requirement spec drift**: read `requirement_doc` from the context doc frontmatter.
   - Absent → note in Design Summary: "No requirement doc — drift check skipped."
   - Local path, unreadable → STOP: "Requirement doc not found at `[path]`. Verify before continuing." (A broken local path is an error.)
   - External reference, unresolvable (no connected MCP tool, or the fetch returns nothing), and no pasted constraints recorded in `## Constraints` → do not STOP — expected, not broken. Ask the user to paste current constraints/scenarios if a comparison is wanted, or note in Design Summary: "Requirement doc is external and unavailable this session — drift check skipped."
   - Resolved (local file read, external fetch succeeded, or constraints the user pasted — this session, or recorded in `## Constraints`) → compare L4 contracts against Scenarios/ACs and `## Technical Constraints`. Present each divergence as `[field/behavior] — changed from [X] to [Y]. Reason: [from Decisions Log]`, or "L4 consistent with requirement spec — no overrides" if none. Local requirement doc → ask: *"Record this in the requirement doc?"* External → do not ask; record the findings in the Design Summary — this molecule never writes to an external system.
   - **STOP: do not write to `requirement_doc` until confirmed.** Confirmed → write each finding into the requirement doc's `## Links` section as `- Design override ({context-doc-filename}): [field/behavior] — changed from [X] to [Y]. Reason: [...]`, or `- Design alignment ({context-doc-filename}): L4 consistent with requirement spec — no overrides.` if none; replace the template's placeholder bullet and any earlier override or alignment lines from this context doc — including lines with no filename, written by an earlier version, when this is the only context doc the spec links. Declined → record the findings in the Design Summary and note "Not written to the requirement doc."

3. **Write the design summary**: use `framework:context-anchoring` Enrich to add a `## Design Summary` section (replace an existing one) containing components and layer assignments, key contracts and interfaces, architectural constraints, domain model decisions (if applicable), and open questions resolved during design.

4. **Set approved status**: write `status: approved` into the context doc frontmatter. **STOP: discrete file edit — not prose.** Without it, code-forge stops and asks before proceeding. **STOP: never write status to `requirement_doc`** — the requirement's status belongs to whoever manages it (a human, or an external system); this molecule manages only its own context doc.

5. Log the completion decision: "Design approved at Level 4. Status set to approved — ready for implementation." Present the summary to the user as confirmation.

6. **Harvest learnings**: run `framework:learning-harvest` Harvest behavior. Session context: "design session — architectural decomposition and contract definition". Synthesize and propose cross-cutting patterns from this session — decomposition approaches, architectural trade-offs, scope decisions that could inform future designs. The user confirms what enters the document. **STOP: run this before the next bullet — do not jump straight to the `/code-forge` suggestion.**

7. Design complete. Do NOT proceed to Level 5 (Implementation). Suggest the user invoke `/code-forge` when ready to begin coding against the approved design.
