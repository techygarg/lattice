---
name: refactor-safely
description: "Restructure existing code safely without changing externally observable behavior. Composes context, design, architecture, code quality, and testing guardrails into a characterization-first refactoring workflow. Use when the user says 'refactor this', 'clean this up', 'untangle this module', 'move this to the right layer', 'simplify this code', or 'improve this structure'."
---
# Refactor Safely

## Required Skills

Load these skills based on refactor scope (see Steps 3, 5, 6 for conditional use):

1. `framework:knowledge-priming` -- Load project context (tech stack, architecture, conventions) so refactor fits real project not generic patterns (always)
2. `framework:context-anchoring` -- Load existing feature context doc when available, capture approved refactor plan, preservation rules, structural decisions for future sessions (always)
3. `framework:collaborative-judgment` -- Surface meaningful trade-offs in structure, seams, migration sequence instead of silently choosing path (always)
4. `framework:clean-code` -- Improve readability, responsibility boundaries, local code craft while preventing scope creep and wrong abstractions (always)
5. `framework:test-quality` -- Lock current behavior with characterization tests, keep safety net reliable throughout refactor (always)
6. `framework:design-first` -- Use progressive design selectively for significant structural changes so target structure agreed before editing code (conditional)
7. `framework:architecture` -- Validate layer placement, dependency direction, correct structural boundaries (conditional)
8. `framework:domain-driven-design` -- Validate domain behavior, aggregate boundaries, movement of business rules into correct domain objects (conditional)
9. `framework:secure-coding` -- Preserve validation, authorization, trust-boundary protections, safe data handling when refactor touches security-sensitive code (conditional)

## Workflow

### Step 1: Establish Refactor Context

Start from **current pain**, not preferred abstraction.

- Identify target area: module, service, aggregate, endpoint path, subsystem
- Clarify **why** refactor needed: mixed responsibilities, duplication, wrong-layer logic, coupling, poor testability, unreadable control flow
- Clarify what user expects to improve: simpler structure, correct layer placement, smaller units, clearer domain behavior, easier testing, safer extension points
- If `.lattice/learnings/review-insights.md` exists, read it. Recurring review findings often identify exactly which structural mistakes should be corrected
- Use `framework:context-anchoring` Document Discovery to check for existing context doc for affected feature/module
  - **If found** → Load it (context-anchoring Load behavior). Honor existing decisions and constraints as active commitments while planning refactor
  - **If not found** → Proceed from conversation and current code. Don't block planning on missing context

End step, summarize intent one sentence:

> "Refactor X to improve Y while preserving Z."

If can't state improvement target and preservation target that clearly yet, continue clarifying before planning changes.

**Optional persistence check**:

- If refactor substantial, risky, or likely span multiple sessions, ask whether user wants persist approved plan
- If relevant context doc already exists and user wants persistence → load and update it
- If no relevant doc exists and user wants persistence → propose creating one, confirm doc name per `framework:context-anchoring`, then use as source of truth for approved plan
- If user doesn't want persistence or refactor small and local → continue in non-persistent mode. Approval gates still apply; plan simply remains in-session

### Step 2: Define Preservation Boundaries

Refactoring changes structure, **not behavior**. Make preservation contract explicit before proposing structural edits.

List behaviors that must remain unchanged:

- Public API contracts and response shapes
- Domain invariants and state transitions
- Persistence semantics and side effects
- Event emission and integration behavior
- Authorization and security posture
- Error behavior where externally visible
- Performance or operational characteristics if part of current contract

Also list explicit **out-of-scope changes**:

- New features
- Schema changes
- Contract changes
- Intentional behavior changes
- Unrelated cleanup outside approved area

This step defines refactor's safety boundary. If desired outcome requires changing preserved behavior, stop and discuss whether task actually bug fix, feature, or broader redesign.

### Step 3: Propose High-Level Structural Plan

**Zero Refactor Rule**: no structural code changes until user approves target structure and transition plan.

For small refactors, plan may be brief. For larger ones, use `framework:design-first` selectively:

- Start at **Level 2 (Components)** to define target responsibilities and boundaries
- Use **Level 3 (Interactions)** when data flow or dependency direction will change
- Use **Level 4 (Contracts)** when internal interfaces or seams need formalized
- Don't use Level 1 (Capabilities) unless user-facing scope actually changing

Present:

- **Current structural problems** -- what wrong with current shape
- **Target structure** -- what components, classes, functions should exist after refactor
- **Movement plan** -- what logic moves where
- **Preservation boundaries** -- what will stay behaviorally unchanged
- **Out-of-scope items** -- what will not be changed this pass

End step with explicit gate:

> "Does this refactor plan look correct? Should I proceed to Step 4: characterization tests?"

Don't write refactor code until user explicitly approves.

If persistence enabled, use `framework:context-anchoring` Enrich behavior to capture approved preservation boundaries, target structure, movement plan, out-of-scope items. Don't proceed to Step 4 until plan written.

### Step 4: Add Characterization Protection First

Before changing structure, lock current behavior with tests.

- Identify existing tests that already protect preserved behavior
- Strengthen weak tests if too implementation-coupled or too vague to serve as guardrails
- Add **characterization tests** for important behaviors currently implicit
- Prefer **lowest-level test** that faithfully captures preserved behavior without missing important integration effects
- Characterization tests must describe **current observable behavior**, not intended refactored shape
- Apply `framework:test-quality` inline

**Stopping rule**:

- If important preserved behavior not protected by tests, pause and make that gap explicit before refactoring
- Don't start structural edits without believable safety net unless user explicitly accepts risk
- Green characterization tests are baseline for refactor; if red before first structural change, resolve that first or re-scope task

This step workflow's differentiator: refactor not considered safe until current behavior executable and guarded.

End step with explicit gate:

> "Characterization tests in place and passing. Ready to discuss refactor strategy and pacing?"

Don't proceed to strategy selection until safety net verified green.

### Step 5: Choose Refactor Strategy and Pacing

After user approves high-level plan and safety net in place, choose implementation approach.

Preferred strategies:

- **Extract and redirect** -- extract focused units, route callers gradually
- **Introduce seam, then migrate** -- add interface or boundary, then move behavior behind it
- **Move behavior inward** -- shift business rules from outer layers into appropriate inner layer per `framework:architecture`
- **Split and collapse** -- separate unrelated responsibilities, then remove old mixed path

Preferred pacing:

> "How would you like review refactor?"
> 1. **Slice-by-slice** (recommended) -- Refactor one safe slice at time, pause after each slice. Best for risky legacy code.
> 2. **Layer-by-layer** -- Complete refactor for one structural layer or concern, then pause for review. Best for broader architectural cleanup.
> 3. **Full autonomy** -- Execute approved refactor end-to-end, present complete result at end. Best for tightly scoped, low-risk refactors. (Still pause if slice reveals approved plan unsafe or invalid — see Step 6 Deviation Rule.)

Default to **slice-by-slice** if user doesn't express preference.

### Step 6: Refactor in Small Green Steps

Implement only within approved preservation boundaries and target structure.

For each slice:

1. Make one structural improvement from approved plan
2. Re-run relevant characterization tests
   - If any characterization test goes red, **stop immediately**. Don't proceed to next slice. Fix regression or revert slice before continuing.
3. Apply applicable atom self-validation checklists
4. Run applicable anti-pattern scans
5. Fix violations before presenting slice
6. Collect judgment calls for slice using `framework:collaborative-judgment`, surface them before presenting slice's code. Don't interrupt mid-slice unless approved plan becomes unsafe or invalid.

Always apply:

- `framework:clean-code` -- better boundaries, simpler control flow, smaller focused units, clearer naming
- `framework:test-quality` -- maintain strong characterization tests and nearby supporting tests

Conditionally apply:

- **If responsibilities move across layers or dependency direction changes** → Apply `framework:architecture`
- **If business rules, aggregates, value objects, or domain behavior move or sharpen** → Apply `framework:domain-driven-design`
- **If trust boundaries, authz, validation, queries, or sensitive data handling touched** → Apply `framework:secure-coding`

**Deviation rule**:

- If implementation reveals approved refactor plan incomplete, unsafe, or would require changing preserved behavior, pause immediately and discuss before continuing

### Step 7: Verify Preservation and Structural Improvement

Refactor succeeds only if **both** true:

1. **Behavior preserved**
2. **Structure measurably better**

Verify preservation:

- Characterization tests still pass
- No intended outward behavior changed
- Preserved contracts remain intact
- Security posture not weakened

Verify structural improvement:

- Responsibilities clearer
- Dependency direction improved or at least no worse
- Duplication or entanglement reduced
- Testability and readability improved
- Old paths or temporary scaffolding removed when migration complete

When reporting completion, be explicit about both:

- What behavior preserved and how verified
- What structural improvement achieved
- What intentionally deferred for later refactor

### Step 8: Capture Decisions and Remaining Debt

Use `framework:context-anchoring` Enrich behavior to preserve important parts of refactor:

- Refactor scope: what area changed
- Preservation boundaries: what explicitly kept stable
- Target structure: what shape approved
- Strategy chosen: why this migration path selected over alternatives
- Key files changed: path and purpose
- Deferred debt: what remains and why intentionally left for later

If no context doc exists and refactor involved non-trivial structural reasoning, suggest creating one so decisions not lost across sessions.

After refactor complete, recommend `/review` when change:

- touches multiple layers
- changes domain boundaries
- changes security-sensitive code
- leaves temporary migration scaffolding
- large enough that independent quality pass would add confidence

`/review` provides independent pass on refactor, can capture broader structural learnings for future work.