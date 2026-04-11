---
name: bug-fix
description: "Investigate, reproduce, and safely fix a bug with regression protection. Composes context, diagnosis, architecture, code quality, and testing guardrails into a reproduce-first repair workflow. Use when the user says 'fix this bug', 'debug this', 'investigate this failure', 'patch this regression', 'repair this issue', or 'why is this broken'."
---

# Bug Fix

## Required Skills

Load these skills based on bug scope (see Steps 2 and 5 for when):

1. `framework:knowledge-priming` -- Load project context (tech stack, architecture, conventions) so fix match real project (always)
2. `framework:context-anchoring` -- Load existing feature context doc when available, capture root cause + repair decisions for future (always)
3. `framework:collaborative-judgment` -- Surface meaningful repair trade-offs instead of silent patch choice (always)
4. `framework:clean-code` -- Keep fix focused, readable, minimal scope (always)
5. `framework:test-quality` -- Create + validate failing regression test that proves bug exists + fix works (always)
6. `framework:architecture` -- Validate layer placement, dependency direction, correct repair location (conditional)
7. `framework:domain-driven-design` -- Validate invariants, aggregate boundaries, domain behavior when bug involves domain logic (conditional)
8. `framework:secure-coding` -- Validate trust boundaries, input handling, authorization, injection safety when bug touches security-sensitive code (conditional)

## Workflow

### Step 1: Establish Bug Context

Start from failure, not proposed fix.

- Gather **observed behavior**, **expected behavior**, **reproduction path**, any evidence: failing test, error message, stack trace, log excerpt, request payload, recent change.
- If `.lattice/learnings/review-insights.md` exists, read it. Recurring review patterns often point to likely defect classes.
- Use `framework:context-anchoring` Document Discovery to check for existing context doc for affected feature/module.
  - **If found** → Load it (context-anchoring Load behavior). Honor logged decisions + constraints as active commitments while diagnosing.
  - **If not found** → Proceed from bug report + current code. Don't block diagnosis on missing context.

End this step, summarize bug one sentence:

> "Observed X, expected Y, reproducible via Z."

If can't state bug clearly yet, keep gathering evidence before proposing code changes.

### Step 2: Reproduce and Localize

**Primary discipline**: don't present fix for bug you haven't reproduced.

Reproduce failure using strongest evidence available, this order:

1. **Existing failing automated test** -- best case; use as regression guard
2. **New failing automated test** -- preferred when no test exists yet
3. **Executable reproduction path** -- command, request sequence, deterministic manual flow when automation not yet possible

Localize issue before editing:

- **Which layer likely source?** Use layer definitions from `framework:architecture` to identify which architectural layer defect originates in
- **Production bug or test bug?** Sometimes code correct, test/fixture wrong
- **Failure symptom or root cause?** Crashing line often downstream of real defect
- **Bug cross trust boundary?** If yes, plan load `framework:secure-coding`
- **Involve domain invariants or aggregate behavior?** If yes, plan load `framework:domain-driven-design`
- **Likely fix touch multiple layers or dependency flow?** If yes, plan load `framework:architecture`

If multiple plausible root causes remain, use `framework:collaborative-judgment` to present leading hypotheses + what evidence would distinguish. Don't guess and patch speculatively.

Before writing regression test, state root cause hypothesis explicitly, use `framework:collaborative-judgment` to surface:

> "Bug caused by [X]. When [C holds], correct outcome should be [P].
>  Confirm this by writing test that red before fix, green after."

If user identifies flaw in hypothesis, revise before writing tests.

End step with explicit bug contract:

> **C (bug condition):** [exact input/state triggering bug]
> **P (fix postcondition):** [what correct behavior looks like when C holds]
> **Preserved:** [what must remain identical for all inputs outside C]

If can't state all three, keep localizing before writing tests.

**Optional persistence check**: Now that bug reproduced + localized, decide whether persist investigation:

- If investigation complex, involves multiple hypotheses, likely span multiple sessions, ask if user wants persist diagnosis + repair decisions
- If relevant context doc exists → plan enrich in Step 7
- If none exists + user wants persistence → propose creating one, confirm doc name per `framework:context-anchoring`, use as source of truth
- If user doesn't want persistence or bug narrow + local → continue non-persistent mode. Repair workflow still applies; decisions remain in-session

### Step 3: Add Regression Protection First

**Phase A — Bug-Condition Tests (must start RED)**

- Write smallest failing test that fires when C holds
- Prefer lowest-level test reproducing real failure without losing signal
- Name test for broken behavior, not implementation detail
- Assert correct expected outcome (postcondition P), not just absence of failure
- Apply `framework:test-quality` inline
- Run against unfixed code, confirm RED
  - If green before fix, bug condition hypothesis wrong — stop, re-localize

**Stopping rule**:

- If can't create stable failing automated test, pause, explain why before making code changes
- Record closest executable reproduction you have
- Don't present speculative fix as "complete" without automated reproducer unless user explicitly accepts limitation
- If bug can't be tested directly due to tight coupling/deep integration, introduce minimum structural seam needed to make testable (method extraction, parameter injection, interface boundary). Not refactor — prerequisite for regression protection. Apply `framework:clean-code` inline, keep seam minimal.

**Phase B — Preservation Baseline (must stay GREEN)**

- Identify existing tests covering behavior outside C
- If important adjacent behavior has no test coverage, add at most 2-3 targeted characterization tests
- Confirm all preservation baseline tests green before applying fix
- These tests must remain green through every change in Step 5 — any flip to red means fix has side effects; stop, narrow scope

### Step 4: Choose the Minimal Safe Fix

Separate **repair strategy** from code change itself.

Before editing, decide:

- What **root cause**?
- What **smallest safe change** correcting it?
- What layer **right repair location**?
- Does issue require **local patch** or **small structural correction**?

Default to smallest safe fix restoring correct behavior **without architectural backsliding**.

Guardrails:

- Apply `framework:architecture` layering rules when choosing repair location — don't patch in outer layer when rule belongs inward
- Don't widen task into unrelated cleanup
- Don't delete/weaken failing test just to make suite green
- If real fix requires contract/design change beyond narrow repair, stop, discuss scope explicitly
- Don't add guard clauses, null checks, defensive handling for inputs outside C — code path for correct inputs must be byte-for-byte identical before + after fix.

If multiple valid repair strategies with meaningful trade-offs, present using `framework:collaborative-judgment` before proceeding.

### Step 5: Implement the Fix

Always apply:

- `framework:clean-code` -- keep delta focused, readable, easy to reason about
- `framework:test-quality` -- maintain regression test + any nearby supporting tests

Conditionally apply based on localized root cause:

- **If fix changes layer responsibilities, dependency direction, architectural flow** → Apply `framework:architecture`
- **If fix changes domain behavior, invariants, aggregate boundaries, value objects** → Apply `framework:domain-driven-design`
- **If fix touches input validation, authorization, queries, external boundaries, sensitive data** → Apply `framework:secure-coding`

After implementing fix, before presenting:

1. Re-run regression test, confirm now green
2. Run applicable atom self-validation checklists against changed code
3. Run applicable anti-pattern scans
4. Fix any violations before presenting result

### Step 6: Verify Non-Regression

Verify repair three levels:

1. **Fix proof** -- regression test that was red before fix now green. Asserts correct outcome, not just absence of original failure.
2. **Preservation proof** -- tests covering behavior adjacent to bug still pass. If preservation baseline tests added in Step 3, must remain green. Any flip from green to red means fix has side effects — stop, narrow scope before continuing.
3. **Structural confidence** -- fix didn't introduce wrong-layer workaround, dependency violation, weakened security posture

When reporting completion, explicit about verification scope:

- What was re-run
- What now passes
- What not verified + why

If fix narrow + confidence high, say so briefly. If verification partial, say so clearly.

### Step 7: Capture Root Cause and Close the Loop

Use `framework:context-anchoring` Enrich behavior to preserve important parts of repair:

- Bug summary: observed vs expected behavior
- Root cause: what actually failed + where
- Repair decision: why this fix chosen over alternatives
- Protection added: regression test or executable reproducer now guarding behavior
- Key files changed: path + purpose

If no context doc exists + fix exposed non-trivial design/domain lesson, suggest creating one.

After fix complete, recommend `/review` when change:

- touches multiple layers
- changes security-sensitive code
- changes domain behavior
- introduces non-trivial structural correction

`/review` provides independent pass on repair, can capture broader learnings for future work.