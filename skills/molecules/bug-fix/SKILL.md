---
name: bug-fix
description: "Investigate, reproduce, and safely fix a bug with regression protection. Composes context, diagnosis, architecture, code quality, and testing guardrails into a reproduce-first repair workflow. Use when the user says 'fix this bug', 'debug this', 'investigate this failure', 'patch this regression', 'repair this issue', or 'why is this broken'."
---

# Bug Fix

## Required Skills

Load and apply these skills based on the bug's scope (see Steps 2 and 5 for conditional loading):

1. `framework:knowledge-priming` -- Load project context (tech stack, architecture, conventions) so the diagnosis and fix match the real project (always loaded)
2. `framework:context-anchoring` -- Load an existing feature context document when available and capture root cause and repair decisions for future sessions (always loaded)
3. `framework:collaborative-judgment` -- Surface meaningful repair trade-offs instead of silently choosing a patch strategy (always loaded)
4. `framework:clean-code` -- Keep the fix focused, readable, and minimal in scope (always loaded)
5. `framework:test-quality` -- Create and validate the failing regression test that proves the bug exists and the fix works (always loaded)
6. `framework:architecture` -- Validate layer placement, dependency direction, and correct repair location (conditional)
7. `framework:domain-driven-design` -- Validate invariants, aggregate boundaries, and domain behavior when the bug involves domain logic (conditional)
   → Skip if `disable.domain_driven_design: true` in `.ai/config.yaml`
8. `framework:secure-coding` -- Validate trust boundaries, input handling, authorization, and injection safety when the bug touches security-sensitive code (conditional)

## Workflow

### Disable Check

Read `.ai/config.yaml`. If `disable.domain_driven_design: true` → skip `framework:domain-driven-design` for the entire workflow. No replacement atom.

### Step 1: Establish Bug Context

Start from the failure, not from a proposed fix.

- Gather the **observed behavior**, **expected behavior**, **reproduction path**, and any available evidence: failing test, error message, stack trace, log excerpt, request payload, or recent change.
- If `.ai/learnings/review-insights.md` exists, read it. Recurring review patterns often point directly to likely defect classes.
- Use `framework:context-anchoring` Document Discovery to check for an existing context document for the affected feature or module.
  - **If found** → Load it (context-anchoring Load behavior). Honor logged decisions and constraints as active commitments while diagnosing the issue.
  - **If not found** → Proceed from the bug report and current code. Do not block diagnosis on missing context.

At the end of this step, summarize the bug in one sentence:

> "Observed X, expected Y, reproducible via Z."

If you cannot state the bug that clearly yet, continue gathering evidence before proposing code changes.

### Step 2: Reproduce and Localize

**Primary discipline**: do not present a fix for a bug you have not reproduced.

Reproduce the failure using the strongest evidence available, in this order:

1. **Existing failing automated test** -- best case; use it as the regression guard
2. **New failing automated test** -- preferred when no test exists yet
3. **Executable reproduction path** -- a command, request sequence, or deterministic manual flow when automation is not yet possible

Localize the issue before editing:

- **Which layer is the likely source?** Use the layer definitions from `framework:architecture` to identify which architectural layer the defect originates in
- **Is this a production bug or a test bug?** Sometimes the code is correct and the test or fixture is wrong
- **Is the failure a symptom or the root cause?** The crashing line is often downstream of the real defect
- **Does the bug cross a trust boundary?** If yes, plan to load `framework:secure-coding`
- **Does it involve domain invariants or aggregate behavior?** If yes, plan to load `framework:domain-driven-design`
- **Does the likely fix touch multiple layers or dependency flow?** If yes, plan to load `framework:architecture`

If multiple plausible root causes remain, use `framework:collaborative-judgment` to present the leading hypotheses and what evidence would distinguish them. Do not guess and patch speculatively.

Before writing the regression test, state the root cause hypothesis explicitly and use `framework:collaborative-judgment` to surface it:

> "The bug is caused by [X]. When [C holds], the correct outcome should be [P].
>  I will confirm this by writing a test that is red before the fix and green after."

If the user identifies a flaw in the hypothesis, revise it before writing tests.

End this step with an explicit bug contract:

> **C (bug condition):** [exact input/state that triggers the bug]
> **P (fix postcondition):** [what correct behavior looks like when C holds]
> **Preserved:** [what must remain identical for all inputs outside C]

If you cannot state all three, continue localizing before writing tests.

**Optional persistence check**: Now that the bug is reproduced and localized, decide whether to persist the investigation:

- If the investigation is complex, involves multiple hypotheses, or is likely to span multiple sessions, ask whether the user wants to persist the diagnosis and repair decisions
- If a relevant context document already exists → plan to enrich it in Step 7
- If none exists and the user wants persistence → propose creating one, confirm the document name per `framework:context-anchoring`, then use it as the source of truth
- If the user does not want persistence or the bug is narrow and local → continue in non-persistent mode. The repair workflow still applies; decisions remain in-session

### Step 3: Add Regression Protection First

**Phase A — Bug-Condition Tests (must start RED)**

- Write the smallest failing test that fires when C holds
- Prefer the lowest-level test that reproduces the real failure without losing signal
- Name the test for the broken behavior, not the implementation detail
- Assert the correct expected outcome (postcondition P), not just the absence of failure
- Apply `framework:test-quality` inline
- Run it against unfixed code and confirm it is RED
  - If it is green before the fix, the bug condition hypothesis is wrong — stop and re-localize

**Stopping rule**:

- If you cannot create a stable failing automated test, pause and explain why before making code changes
- Record the closest executable reproduction you do have
- Do not present a speculative fix as "complete" without an automated reproducer unless the user explicitly accepts that limitation
- If the bug cannot be tested directly due to tight coupling or deep integration, introduce the minimum structural seam needed to make it testable (method extraction, parameter injection, interface boundary). This is not a refactor — it is a prerequisite for regression protection. Apply `framework:clean-code` inline and keep the seam minimal.

**Phase B — Preservation Baseline (must stay GREEN)**

- Identify existing tests that already cover behavior outside C
- If important adjacent behavior has no test coverage, add at most 2-3 targeted characterization tests
- Confirm all preservation baseline tests are green before applying any fix
- These tests must remain green through every change in Step 5 — any flip to red means the fix has side effects; stop and narrow scope

### Step 4: Choose the Minimal Safe Fix

Separate the **repair strategy** from the code change itself.

Before editing, decide:

- What is the **root cause**?
- What is the **smallest safe change** that corrects it?
- What layer is the **right repair location**?
- Does the issue require a **local patch** or a **small structural correction**?

Default to the smallest safe fix that restores correct behavior **without architectural backsliding**.

Guardrails:

- Apply `framework:architecture` layering rules when choosing repair location — do not patch in an outer layer when the rule belongs inward
- Do not widen the task into unrelated cleanup
- Do not delete or weaken the failing test just to make the suite green
- If a real fix requires a contract or design change beyond a narrow repair, stop and discuss the scope explicitly
- Do not add guard clauses, null checks, or defensive handling for inputs outside C — the code path for correct inputs must be byte-for-byte identical before and after the fix.

If there are multiple valid repair strategies with meaningful trade-offs, present them using `framework:collaborative-judgment` before proceeding.

### Step 5: Implement the Fix

Always apply:

- `framework:clean-code` -- keep the delta focused, readable, and easy to reason about
- `framework:test-quality` -- maintain the regression test and any nearby supporting tests

Conditionally apply based on the localized root cause:

- **If the fix changes layer responsibilities, dependency direction, or architectural flow** → Apply `framework:architecture`
- **If the fix changes domain behavior, invariants, aggregate boundaries, or value objects** → Apply `framework:domain-driven-design`
- **If the fix touches input validation, authorization, queries, external boundaries, or sensitive data** → Apply `framework:secure-coding`

After implementing the fix and before presenting it:

1. Re-run the regression test and confirm it is now green
2. Run the applicable atom self-validation checklists against the changed code
3. Run the applicable anti-pattern scans
4. Fix any violations before presenting the result

### Step 6: Verify Non-Regression

Verify the repair at three levels:

1. **Fix proof** -- the regression test that was red before the fix is now green. It asserts the correct outcome, not just the absence of the original failure.
2. **Preservation proof** -- tests covering behavior adjacent to the bug still pass. If preservation baseline tests were added in Step 3, they must remain green. Any flip from green to red means the fix has side effects — stop and narrow the scope before continuing.
3. **Structural confidence** -- the fix did not introduce a wrong-layer workaround, dependency violation, or weakened security posture

When reporting completion, be explicit about verification scope:

- What was re-run
- What now passes
- What was not verified and why

If the fix is narrow and confidence is high, say so briefly. If verification is partial, say so clearly.

### Step 7: Capture Root Cause and Close the Loop

Use `framework:context-anchoring` Enrich behavior to preserve the important parts of the repair:

- Bug summary: observed vs expected behavior
- Root cause: what actually failed and where
- Repair decision: why this fix was chosen over alternatives
- Protection added: the regression test or executable reproducer that now guards the behavior
- Key files changed: path and purpose

If no context document exists and the fix exposed a non-trivial design or domain lesson, suggest creating one.

After the fix is complete, recommend `/review` when the change:

- touches multiple layers
- changes security-sensitive code
- changes domain behavior
- introduces a non-trivial structural correction

`/review` provides an independent pass on the repair and can capture broader learnings for future work.
