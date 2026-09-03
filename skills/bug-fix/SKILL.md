---
name: bug-fix
description: "Investigate, reproduce, and safely fix a bug with regression protection. Composes context, diagnosis, architecture, code quality, and testing guardrails into a reproduce-first repair workflow. Use when the user says 'fix this bug', 'debug this', 'investigate this failure', 'patch this regression', 'repair this issue', or 'why is this broken'."
---

# Bug Fix

## Required Skills

Load these skills based on bug scope:

1. `framework:knowledge-priming` -- Load project context so the diagnosis grounds in the real codebase. (always)
2. `framework:context-anchoring` -- Find and load the feature's context doc; capture diagnosis and repair decisions in it. (always)
3. `framework:learning-harvest` -- Load prior operational learnings at session start; harvest new ones at session end. (always)
4. `framework:collaborative-judgment` -- Surface hypotheses and repair trade-offs as structured options instead of silently assuming. (always)
5. `framework:clean-code` -- Keep the fix focused, readable, and free of drive-by changes. (always)
6. `framework:test-quality` -- Regression tests, characterization baseline, assertion quality. (always)
7. `framework:architecture` -- Layer placement and dependency direction. (conditional: layer placement is in question — Steps 2/4/5)
8. `framework:domain-driven-design` -- Domain invariants and aggregate behavior. (conditional: domain invariants involved — Steps 2/5)
9. `framework:secure-coding` -- Trust bounds and sensitive data handling. (conditional: trust boundary crossed — Steps 2/5)

## Workflow

### Step 1: Establish Bug Context

Start from the failure, not from a proposed fix.

- Gather the **observed behavior**, the **expected behavior**, the **reproduction path**, and any evidence: failing test, error message, stack trace, log excerpt, request payload, recent change.
- Run `framework:learning-harvest` Load behavior. Focus hint: "bug investigation — focus: reliability, quality signals".
- Run `framework:context-anchoring` Document Discovery to check for an existing context doc covering the affected feature/module:
  - **Found** → Load behavior. Honor every logged decision and constraint as an active commitment while diagnosing. An open investigation of this same bug is already logged in it → confirm with the user whether to resume that investigation or start fresh.
  - **Not found** → Proceed from the bug report and the current code. Do not block diagnosis on a missing context doc.

End the step by summarizing the bug in one sentence:

> "Observed X, expected Y, reproducible via Z."

**STOP:** If you cannot yet state the bug that clearly, gather more evidence before proposing any code changes.

### Step 2: Reproduce and Localize

**Primary discipline**: never present a fix for a bug you have not reproduced.

Reproduce the failure using the strongest evidence available, in this order:

1. **Existing failing automated test** -- best case; use it as the regression guard.
2. **New failing automated test** -- preferred when no test exists yet.
3. **Executable reproduction path** -- command, request sequence, or deterministic manual flow when automation is not yet possible.

Localize the issue before editing:

- **Which layer is the likely source?** Use the layer definitions from `framework:architecture` to identify which architectural layer the defect originates in.
- **Production bug or test bug?** Sometimes the code is correct and the test or fixture is wrong.
- **Failure symptom or root cause?** The crashing line is often downstream of the real defect.
- **Does the bug cross a trust boundary?** If yes, `framework:secure-coding` applies to the fix (Step 5).
- **Does it involve domain invariants or aggregate behavior?** If yes, `framework:domain-driven-design` applies to the fix (Step 5).
- **Will the likely fix touch multiple layers or dependency flow?** If yes, `framework:architecture` applies to the fix (Steps 4–5).

If multiple plausible root causes remain, use `framework:collaborative-judgment` to present the leading hypotheses and what evidence would distinguish them.

Before writing any regression test, state the root-cause hypothesis explicitly via `framework:collaborative-judgment`:

> "The bug is caused by [X]. When [C holds], the correct outcome should be [P].
> We confirm this by writing a test that is red before the fix and green after."

If the user identifies a flaw in the hypothesis, revise it before writing tests.

End the step with an explicit bug contract:

> **C (bug condition):** [exact input/state triggering the bug]
> **P (fix postcondition):** [what correct behavior looks like when C holds]
> **Preserved:** [what must remain identical for all inputs outside C]

**STOP:** If you cannot state all three, keep localizing before writing tests.

**Persistence check** — now that the bug is reproduced and localized, decide whether to persist the investigation:

- Investigation is complex, involves multiple hypotheses, or is likely to span multiple sessions → ask whether the user wants to persist the diagnosis and repair decisions.
- A relevant context doc exists → enrich it in Step 7.
- None exists and the user wants persistence → propose creating one; confirm the doc name per `framework:context-anchoring`, then use it as the source of truth.
- The user declines persistence, or the bug is narrow and local → continue in non-persistent mode. The repair workflow still applies; decisions remain in-session.

### Step 3: Add Regression Protection First

**Phase A — Bug-Condition Tests (must start RED)**

- Write the smallest failing test that fires when C holds.
- Prefer the lowest-level test that reproduces the real failure without losing signal.
- Name the test for the broken behavior, not the implementation detail.
- Assert the correct expected outcome (postcondition P), not just the absence of failure.
- Apply `framework:test-quality` inline while writing it.
- Run it against the unfixed code where the environment allows, and confirm RED. If tests cannot be executed here, say so explicitly — the reproducer then counts as unverified, and the limitations below apply.
  - Green before any fix → the bug-condition hypothesis is wrong. **STOP:** Do not proceed — return to Step 2 and re-localize.

**Stopping rule**:

- **STOP:** If no stable failing automated test can be created or executed, explain why before making any code changes.
- Record the closest executable reproduction you have.
- **STOP:** Never present a speculative fix as complete without an automated reproducer unless the user explicitly accepts the limitation.
- The bug cannot be tested directly because of tight coupling or deep integration → introduce the minimum structural seam needed to make it testable (method extraction, parameter injection, interface boundary). This is not refactoring — it is a prerequisite for regression protection. Apply `framework:clean-code` inline and keep the seam minimal.

**Phase B — Preservation Baseline (must stay GREEN)**

- Identify existing tests covering behavior outside C.
- Important adjacent behavior has no coverage → add at most 2–3 targeted characterization tests.
- Confirm every preservation-baseline test is green before applying the fix.
- These tests must remain green through every change in Step 5 — any flip to red means the fix has side effects; stop and narrow the scope.

### Step 4: Choose the Minimal Safe Fix

Separate the **repair strategy** from the code change itself.

Before editing, decide:

- What is the **root cause**?
- What is the **smallest safe change** that corrects it?
- Which layer is the **right repair location**?
- Does the issue require a **local patch** or a **small structural correction**?

Default to the smallest safe fix that restores correct behavior **without architectural backsliding**.

Guardrails:

- Apply `framework:architecture` layering rules when choosing the repair location — do not patch in an outer layer when the rule belongs inward.
- Do not widen the task into unrelated cleanup.
- Do not delete or weaken the failing test just to make the suite green.
- A real fix requires a contract or design change beyond the narrow repair → stop and discuss scope explicitly; if the user agrees the scope is a design change, route to `/design-blueprint`.
- Do not add guard clauses, null checks, or defensive handling for inputs outside C — the code path for correct inputs must be byte-for-byte identical before and after the fix.

Multiple valid repair strategies exist with meaningful trade-offs → present them using `framework:collaborative-judgment` before proceeding.

### Step 5: Implement the Fix

Always apply:

- `framework:clean-code` -- keep the delta focused, readable, and easy to reason about.
- `framework:test-quality` -- maintain the regression test and any nearby supporting tests.

Conditionally apply, based on the localized root cause:

- Fix changes layer responsibilities, dependency direction, or architectural flow → apply `framework:architecture`.
- Fix changes domain behavior, invariants, aggregate boundaries, or value objects → apply `framework:domain-driven-design`.
- Fix touches input validation, authorization, queries, external boundaries, or sensitive data → apply `framework:secure-coding`.

After implementing the fix, before presenting:

1. Re-run the regression test and confirm it is now green. Tests cannot execute in this environment → state that explicitly; never imply the test passed unrun.
2. Run the applicable atoms' Self-Validation Checklist sections against the changed code.
3. Run the applicable atoms' Active Anti-Pattern Scan checklists.
4. Fix violations before presenting the result.

### Step 6: Verify Non-Regression

Verify the repair on three levels:

1. **Fix proof** -- the regression test that was red before the fix is now green, asserting the correct outcome rather than just the absence of the original failure.
2. **Preservation proof** -- tests covering behavior adjacent to the bug still pass. Preservation-baseline tests added in Step 3 must remain green. Any flip from green to red means the fix has side effects — stop and narrow the scope before continuing.
3. **Structural confidence** -- the fix introduced no wrong-layer workaround, no dependency violation, no weakened security posture.

When reporting completion, be explicit about the verification scope:

- What was re-run.
- What now passes.
- What was not verified, and why.

If the fix is narrow and confidence is high, say so briefly. If verification is partial, say so clearly.

### Step 7: Capture Root Cause and Close the Loop

If a context doc is active (persistence accepted in Step 2), use `framework:context-anchoring` Enrich to preserve the important parts of the repair. In non-persistent mode, skip to the harvest below:

- Bug summary: observed vs expected behavior.
- Root cause: what actually failed, and where.
- Repair decision: why this fix was chosen over the alternatives.
- Protection added: the regression test or executable reproducer now guarding the behavior.
- Key files changed: path + role in the doc's Key Files table (skip a path already listed).

No context doc exists and the fix exposed a non-trivial design or domain lesson → suggest creating one so the lesson survives the session.

**Harvest learnings**: run `framework:learning-harvest` Harvest behavior. Session context: "bug investigation — root cause diagnosis and repair". Synthesize and propose cross-cutting patterns from this session — root-cause categories, failure modes likely to recur elsewhere, boundary-condition gaps. The user confirms what enters the document. **STOP: run this before recommending `/review` below.**

After the fix is complete, recommend `/review` when the change:

- touches multiple layers
- changes security-sensitive code
- changes domain behavior
- introduces a non-trivial structural correction
