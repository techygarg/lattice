---
name: refactor-safely
description: "Restructure existing code safely without changing externally observable behavior. Composes context, design, architecture, code quality, and testing guardrails into a characterization-first refactoring workflow. Use when the user says 'refactor this', 'clean this up', 'untangle this module', 'move this to the right layer', 'simplify this code', or 'improve this structure'."
---
# Refactor Safely

## Required Skills

Load these skills based on refactor scope (see Steps 3, 5, 6 for conditional use):

1. `framework:knowledge-priming` -- Load project context so the refactor grounds in the real codebase. (always)
2. `framework:context-anchoring` -- Find and load the feature's context doc; capture approved plans and decisions in it. (always)
3. `framework:learning-harvest` -- Load prior operational learnings at session start; harvest new ones at session end. (always)
4. `framework:collaborative-judgment` -- Surface trade-offs in structure, seams, and migration sequence instead of silently assuming. (always)
5. `framework:clean-code` -- Readability, responsibility boundaries, local craft. (always)
6. `framework:test-quality` -- Characterization tests and the safety net. (always)
7. `framework:design-first` -- Target-structure planning for significant structural changes. (conditional: Step 3)
8. `framework:architecture` -- Layer placement and dependency direction. (conditional: responsibilities move across layers in Steps 5/6)
9. `framework:domain-driven-design` -- Aggregate boundaries and domain behavior. (conditional: domain rules move or sharpen in Step 6)
10. `framework:secure-coding` -- Trust bounds, authorization, sensitive data handling. (conditional: security-sensitive code touched in Step 6)

## Workflow

### Step 1: Establish Refactor Context

Start from the current pain, not from a preferred abstraction.

- Identify the target area: a module, service, aggregate, endpoint path, or subsystem.
- Clarify why the refactor is needed: mixed responsibilities, duplication, wrong-layer logic, coupling, poor testability, or unreadable control flow.
- Clarify what the user expects to improve: simpler structure, correct layer placement, smaller units, clearer domain behavior, easier testing, or safer extension points.
- Run `framework:learning-harvest` Load behavior. Focus hint: "refactoring session — focus: structural health, quality signals".
- Run `framework:context-anchoring` Document Discovery to check for an existing context doc covering the affected feature/module:
  - **Found** → Load behavior. Honor every logged decision and constraint as an active commitment while planning the refactor. The doc already contains an approved refactor plan (preservation boundaries + target structure) → confirm it still matches the user's intent, then resume at Step 4 unless the user wants to revisit the plan first.
  - **Not found** → Proceed from the conversation and the current code. Do not block planning on a missing context doc.

End the step by summarizing the intent in one sentence:

> "Refactor X to improve Y while preserving Z."

**STOP:** If you cannot state both the improvement target and the preservation target that clearly, continue clarifying with the user before planning any changes.

**Persistence check**:

- Refactor is substantial, risky, or likely to span multiple sessions → ask whether the user wants to persist an approved plan.
- A relevant context doc already exists and the user wants persistence → use it and update it.
- No relevant doc exists and the user wants persistence → propose creating one; confirm the doc name per `framework:context-anchoring`, then use it as the source of truth for the approved plan.
- The user declines persistence, or the refactor is small and local → continue in non-persistent mode. Approval gates still apply; the plan simply stays in-session.

### Step 2: Define Preservation Boundaries

Refactoring changes structure, **not behavior**. Make the preservation contract explicit before proposing any structural edits.

List the behaviors that must remain unchanged:

- Public API contracts and response shapes
- Domain invariants and state transitions
- Persistence semantics and side effects
- Event emission and integration behavior
- Authorization and security posture
- Error behavior wherever externally visible
- Performance or operational characteristics, if part of the current contract

Also list explicit **out-of-scope changes**:

- New features
- Schema changes
- Contract changes
- Intentional behavior changes
- Unrelated cleanup outside the approved area

If the desired outcome requires changing preserved behavior, stop and discuss what the task actually is — a bug fix (`/bug-fix`), a feature change (`/design-blueprint`), or a broader redesign. **STOP:** Never proceed as a refactor after making one of those determinations.

### Step 3: Propose High-Level Structural Plan

**Zero Refactor Rule**: make no structural code changes until the user approves both the target structure and the transition plan.

For small refactors the plan may be brief. For larger ones, use `framework:design-first` selectively:

- Start at **Level 2 (Components)** to define target responsibilities and boundaries.
- Use **Level 3 (Interactions)** when data flow or dependency direction will change.
- Use **Level 4 (Contracts)** when internal interfaces or seams need to be formalized.
- Skip Level 1 (Capabilities) unless the user-facing scope is actually changing.

Present:

- **Current structural problems** -- what is wrong with the current shape
- **Target structure** -- which components, classes, and functions should exist after the refactor
- **Movement plan** -- what logic moves where
- **Preservation boundaries** -- what will stay behaviorally unchanged
- **Out-of-scope items** -- what will not be changed in this pass

End the step with an explicit gate:

> "Does this refactor plan look correct? Should I proceed to Step 4: characterization tests?"

**STOP:** Do not write any refactoring code until the user explicitly approves this plan.

If persistence is enabled, use `framework:context-anchoring` Enrich to capture the approved preservation boundaries, target structure, movement plan, and out-of-scope items. **STOP:** When persistence is enabled, do not proceed to Step 4 until the approved plan is written.

### Step 4: Add Characterization Protection First

Before changing any structure, lock in current behavior with tests.

- Identify existing tests that already protect preserved behavior.
- Strengthen existing tests that are too implementation-coupled or too vague to serve as guardrails.
- Add **characterization tests** for important behaviors that are currently implicit.
- Prefer the lowest-level test that faithfully captures each preserved behavior without missing important integration effects.
- Characterization tests must describe the **current observable behavior**, not the intended refactored shape.
- Apply `framework:test-quality` inline while writing them.
- Run the safety net where the environment allows. If tests cannot be executed here, say so explicitly — the safety net then counts as unverified, and the stopping rule below applies.

**Stopping rule**:

- An important preserved behavior is not protected by tests → pause and make that gap explicit before refactoring.
- **STOP:** Do not start structural edits without a believable safety net unless the user explicitly accepts the risk.
- Green characterization tests are the baseline for the refactor. Anything red before the first structural change must be resolved first, or the task re-scoped.

End the step with an explicit gate:

> "Characterization tests in place and passing. Ready to discuss refactor strategy and pacing?"

**STOP:** Do not proceed to strategy selection until the safety net is verified green — or the user has explicitly accepted an unverified safety net per the stopping rule above.

### Step 5: Choose Refactor Strategy and Pacing

With the high-level plan approved and the safety net green, choose the implementation approach.

Preferred strategies:

- **Extract and redirect** -- extract focused units, route callers gradually.
- **Introduce seam, then migrate** -- add an interface or boundary, then move behavior behind it.
- **Move behavior inward** -- shift business rules from outer layers into the appropriate inner layer per `framework:architecture`.
- **Split and collapse** -- separate unrelated responsibilities, then remove the old mixed path.

Ask the user to choose a pacing mode:

> "How would you like to review the refactor?"
> 1. **Slice-by-slice** (recommended) -- refactor one safe slice at a time, pausing after each slice. Best for risky legacy code.
> 2. **Layer-by-layer** -- complete the refactor for one structural layer or concern, then pause for review. Best for broader architectural cleanup.
> 3. **Full autonomy** -- execute the approved refactor end-to-end and present the complete result at the end. Best for tightly scoped, low-risk refactors. (Still pause immediately if any slice reveals the approved plan unsafe or invalid — see the Deviation Rule in Step 6.)

Default to **slice-by-slice** when the user expresses no preference.

### Step 6: Refactor in Small Green Steps

Implement only within the approved preservation boundaries and the approved target structure.

For each slice:

1. Make one structural improvement from the approved plan.
2. Re-run the relevant characterization tests.
   - Any characterization test goes red → **stop immediately**. Do not start the next slice. Fix the regression or revert the slice before continuing.
3. Apply the applicable atom Self-Validation Checklists.
4. Run the applicable Active Anti-Pattern Scans.
5. Fix violations before presenting the slice.
6. Collect judgment calls for the slice via `framework:collaborative-judgment` and surface them before presenting the slice's code. Do not interrupt mid-slice unless the approved plan becomes unsafe or invalid.

Always apply:

- `framework:clean-code` -- better boundaries, simpler control flow, smaller focused units, clearer naming.
- `framework:test-quality` -- maintain strong characterization tests and nearby supporting tests.

Conditionally apply:

- Responsibilities move across layers or dependency direction changes → apply `framework:architecture`.
- Business rules, aggregates, value objects, or domain behavior move or sharpen → apply `framework:domain-driven-design`.
- Trust boundaries, authorization, validation, queries, or sensitive data handling are touched → apply `framework:secure-coding`.

**Deviation rule**: if the implementation reveals the approved plan incomplete, unsafe, or requiring changes to preserved behavior → **STOP:** pause immediately and discuss before continuing.

### Step 7: Verify Preservation and Structural Improvement

The refactor succeeds only if **both** are true:

1. **Behavior preserved**
2. **Structure measurably better**

Verify preservation:

- Characterization tests still pass.
- No unintended outward behavior changed.
- Preserved contracts remain intact.
- Security posture not weakened.

Verify structural improvement:

- Responsibilities clearer.
- Dependency direction improved, or at least no worse.
- Duplication or entanglement reduced.
- Testability and readability improved.
- Old paths and temporary scaffolding removed once migration is complete.

When reporting completion, be explicit about both sides:

- What behavior was preserved and how it was verified.
- What structural improvement was achieved.
- What was intentionally deferred to a later refactor.

### Step 8: Capture Decisions and Remaining Debt

Use `framework:context-anchoring` Enrich to preserve the important parts of the refactor:

- Refactor scope: what area changed.
- Preservation boundaries: what was explicitly kept stable.
- Target structure: what shape was approved.
- Strategy chosen: why this migration path was selected over the alternatives.
- Key files changed: path + role in the doc's Key Files table (skip a path already listed).
- Deferred debt: what remains and why it was intentionally left for later.

No context doc exists and the refactor involved non-trivial structural reasoning → suggest creating one so the decisions are not lost across sessions.

**Harvest learnings**: run `framework:learning-harvest` Harvest behavior. Session context: "refactoring session — structural restructuring and debt resolution". Synthesize and propose cross-cutting patterns from this session — structural debt that accumulated, migration strategies that worked, characterization test gaps discovered. The user confirms what enters the document. **STOP: run this before recommending `/review` below.**

After the refactor is complete, recommend `/review` when the change:

- touches multiple layers
- changes domain boundaries
- changes security-sensitive code
- leaves temporary migration scaffolding behind
- is large enough that an independent quality pass would add confidence
