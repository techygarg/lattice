---
name: refactor-safely
description: "Restructure existing code safely without changing externally observable behavior. Composes context, design, architecture, code quality, and testing guardrails into a characterization-first refactoring workflow. Use when the user says 'refactor this', 'clean this up', 'untangle this module', 'move this to the right layer', 'simplify this code', or 'improve this structure'."
---

# Refactor Safely

## Required Skills

Load and apply these skills based on the refactor's scope (see Steps 3, 5, and 6 for conditional usage):

1. `framework:knowledge-priming` -- Load project context (tech stack, architecture, conventions) so the refactor fits the real project rather than generic patterns (always loaded)
2. `framework:context-anchoring` -- Load an existing feature context document when available and capture the approved refactor plan, preservation rules, and structural decisions for future sessions (always loaded)
3. `framework:collaborative-judgment` -- Surface meaningful trade-offs in structure, seams, and migration sequence instead of silently choosing a path (always loaded)
4. `framework:clean-code` -- Improve readability, responsibility boundaries, and local code craft while preventing scope creep and wrong abstractions (always loaded)
5. `framework:test-quality` -- Lock current behavior with characterization tests and keep the safety net reliable throughout the refactor (always loaded)
6. `framework:design-first` -- Use progressive design selectively for significant structural changes so the target structure is agreed before editing code (conditional)
7. `framework:clean-architecture` -- Validate layer placement, dependency direction, command/query flow, and correct structural boundaries (conditional)
8. `framework:domain-driven-design` -- Validate domain behavior, aggregate boundaries, and movement of business rules into the correct domain objects (conditional)
9. `framework:secure-coding` -- Preserve validation, authorization, trust-boundary protections, and safe data handling when the refactor touches security-sensitive code (conditional)

## Workflow

### Step 1: Establish Refactor Context

Start from the **current pain**, not from a preferred abstraction.

- Identify the target area: module, service, aggregate, endpoint path, or subsystem
- Clarify **why** the refactor is needed: mixed responsibilities, duplication, wrong-layer logic, coupling, poor testability, or unreadable control flow
- Clarify what the user expects to improve: simpler structure, correct layer placement, smaller units, clearer domain behavior, easier testing, or safer extension points
- If `.ai/learnings/review-insights.md` exists, read it. Recurring review findings often identify exactly which structural mistakes should be corrected
- Use `framework:context-anchoring` Document Discovery to check for an existing context document for the affected feature or module
  - **If found** → Load it (context-anchoring Load behavior). Honor existing decisions and constraints as active commitments while planning the refactor
  - **If not found** → Proceed from the conversation and current code. Do not block planning on missing context

At the end of this step, summarize the intent in one sentence:

> "Refactor X to improve Y while preserving Z."

If you cannot state the improvement target and the preservation target that clearly yet, continue clarifying before planning changes.

**Optional persistence check**:

- If the refactor is substantial, risky, or likely to span multiple sessions, ask whether the user wants to persist the approved plan
- If a relevant context document already exists and the user wants persistence → load and update it
- If no relevant document exists and the user wants persistence → propose creating one, confirm the document name per `framework:context-anchoring`, then use it as the source of truth for the approved plan
- If the user does not want persistence or the refactor is small and local → continue in non-persistent mode. Approval gates still apply; the plan simply remains in-session

### Step 2: Define Preservation Boundaries

Refactoring changes structure, **not behavior**. Make the preservation contract explicit before proposing structural edits.

List the behaviors that must remain unchanged:

- Public API contracts and response shapes
- Domain invariants and state transitions
- Persistence semantics and side effects
- Event emission and integration behavior
- Authorization and security posture
- Error behavior where externally visible
- Performance or operational characteristics if they are part of the current contract

Also list explicit **out-of-scope changes**:

- New features
- Schema changes
- Contract changes
- Intentional behavior changes
- Unrelated cleanup outside the approved area

This step defines the refactor's safety boundary. If the desired outcome requires changing preserved behavior, stop and discuss whether the task is actually a bug fix, a feature, or a broader redesign.

### Step 3: Propose the High-Level Structural Plan

**Zero Refactor Rule**: no structural code changes until the user approves the target structure and transition plan.

For small refactors, the plan may be brief. For larger ones, use `framework:design-first` selectively:

- Start at **Level 2 (Components)** to define the target responsibilities and boundaries
- Use **Level 3 (Interactions)** when data flow or dependency direction will change
- Use **Level 4 (Contracts)** when internal interfaces or seams need to be formalized
- Do **not** use Level 1 (Capabilities) unless the user-facing scope is actually changing

Present:

- **Current structural problems** -- what is wrong with the current shape
- **Target structure** -- what components, classes, or functions should exist after the refactor
- **Movement plan** -- what logic moves where
- **Preservation boundaries** -- what will stay behaviorally unchanged
- **Out-of-scope items** -- what will not be changed in this pass

End this step with an explicit gate:

> "Does this refactor plan look correct? Should I proceed to Step 4: characterization tests?"

Do not write refactor code until the user explicitly approves.

If persistence is enabled, use `framework:context-anchoring` Enrich behavior to capture the approved preservation boundaries, target structure, movement plan, and out-of-scope items. Do not proceed to Step 4 until the plan is written.

### Step 4: Add Characterization Protection First

Before changing structure, lock current behavior with tests.

- Identify existing tests that already protect the preserved behavior
- Strengthen weak tests if they are too implementation-coupled or too vague to serve as guardrails
- Add **characterization tests** for important behaviors that are currently implicit
- Prefer the **lowest-level test** that faithfully captures the preserved behavior without missing important integration effects
- Characterization tests must describe **current observable behavior**, not the intended refactored shape
- Apply `framework:test-quality` inline: AAA structure, one behavior per test, specific assertions, isolated setup

**Stopping rule**:

- If important preserved behavior is not protected by tests, pause and make that gap explicit before refactoring
- Do not start structural edits without a believable safety net unless the user explicitly accepts the risk
- Green characterization tests are the baseline for the refactor; if they are red before the first structural change, resolve that first or re-scope the task

This step is the workflow's differentiator: the refactor is not considered safe until current behavior is executable and guarded.

End this step with an explicit gate:

> "Characterization tests are in place and passing. Ready to discuss refactor strategy and pacing?"

Do not proceed to strategy selection until the safety net is verified green.

### Step 5: Choose Refactor Strategy and Pacing

After the user approves the high-level plan and the safety net is in place, choose the implementation approach.

Preferred strategies:

- **Extract and redirect** -- extract focused units, route callers gradually
- **Introduce seam, then migrate** -- add an interface or boundary, then move behavior behind it
- **Move behavior inward** -- shift business rules from controllers/services into domain objects
- **Split and collapse** -- separate unrelated responsibilities, then remove the old mixed path

Preferred pacing:

> "How would you like to review the refactor?"
> 1. **Slice-by-slice** (recommended) -- I'll refactor one safe slice at a time and pause after each slice. Best for risky legacy code.
> 2. **Layer-by-layer** -- I'll complete the refactor for one structural layer or concern, then pause for review. Best for broader architectural cleanup.
> 3. **Full autonomy** -- I'll execute the approved refactor end-to-end and present the complete result at the end. Best for tightly scoped, low-risk refactors.

Default to **slice-by-slice** if the user does not express a preference.

### Step 6: Refactor in Small Green Steps

Implement only within the approved preservation boundaries and target structure.

For each slice:

1. Make one structural improvement from the approved plan
2. Re-run the relevant characterization tests
   - If any characterization test goes red, **stop immediately**. Do not proceed to the next slice. Fix the regression or revert the slice before continuing.
3. Apply the applicable atom self-validation checklists
4. Run the applicable anti-pattern scans
5. Fix violations before presenting the slice
6. Collect judgment calls for the slice using `framework:collaborative-judgment` and surface them before presenting the slice's code. Do not interrupt mid-slice unless the approved plan becomes unsafe or invalid.

Always apply:

- `framework:clean-code` -- better boundaries, simpler control flow, smaller focused units, clearer naming
- `framework:test-quality` -- maintain strong characterization tests and nearby supporting tests

Conditionally apply:

- **If responsibilities move across layers or dependency direction changes** → Apply `framework:clean-architecture`
- **If business rules, aggregates, value objects, or domain behavior move or sharpen** → Apply `framework:domain-driven-design`
- **If trust boundaries, authz, validation, queries, or sensitive data handling are touched** → Apply `framework:secure-coding`

**Deviation rule**:

- If implementation reveals that the approved refactor plan is incomplete, unsafe, or would require changing preserved behavior, pause immediately and discuss before continuing

### Step 7: Verify Preservation and Structural Improvement

The refactor succeeds only if **both** of these are true:

1. **Behavior is preserved**
2. **Structure is measurably better**

Verify preservation:

- Characterization tests still pass
- No intended outward behavior changed
- Preserved contracts remain intact
- Security posture is not weakened

Verify structural improvement:

- Responsibilities are clearer
- Dependency direction is improved or at least no worse
- Duplication or entanglement is reduced
- Testability and readability are improved
- Old paths or temporary scaffolding are removed when the migration is complete

When reporting completion, be explicit about both:

- What behavior was preserved and how it was verified
- What structural improvement was achieved
- What was intentionally deferred for a later refactor

### Step 8: Capture Decisions and Remaining Debt

Use `framework:context-anchoring` Enrich behavior to preserve the important parts of the refactor:

- Refactor scope: what area was changed
- Preservation boundaries: what was explicitly kept stable
- Target structure: what shape was approved
- Strategy chosen: why this migration path was selected over alternatives
- Key files changed: path and purpose
- Deferred debt: what remains and why it was intentionally left for later

If no context document exists and the refactor involved non-trivial structural reasoning, suggest creating one so the decisions are not lost across sessions.

After the refactor is complete, recommend `/review` when the change:

- touches multiple layers
- changes domain boundaries
- changes security-sensitive code
- leaves temporary migration scaffolding
- was large enough that an independent quality pass would add confidence

`/review` provides an independent pass on the refactor and can capture broader structural learnings for future work.
