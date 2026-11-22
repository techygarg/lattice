---
name: collaborative-judgment
description: "Protocol for handling ambiguous decisions and missing/conflicting knowledge during code generation, design, and review. Ensures AI surfaces genuine judgment calls with structured options and stops on hallucination risk instead of silently assuming. Use when a decision has multiple valid approaches, when facts are missing or contradictory, when the user asks 'what should we do here?', 'is this a judgment call?', 'should I ask about this?', 'am I guessing here?', 'what are the tradeoffs?', or when deciding between two reasonable architectural or design options. Also composed by molecules to define how judgment calls and clarification requests are surfaced and resolved."
---
# Collaborative Judgment

## When to Decide vs When to Ask

Most decisions are NOT ambiguous. The AI decides on its own when:

- **The rule is clear.** An 80-line function doing 5 things violates SRP. A domain entity importing the database breaks the dependency rule. Fix it.
- **The project has a documented preference.** The knowledge base, refiner docs, or context anchor specify the choice -- follow it. That is not ambiguity; it is documented intent.
- **The impact is low.** Variable naming, import order, test data -- choose and move on.
- **Grounding is solid.** You can point to a source: user instruction, inspected code/artifact, failing test/log, knowledge base, refiner doc, context anchor. Never take a repo-specific fact from memory alone.

Surface a decision only when ALL three are true:

1. **Multiple valid approaches** -- a genuine fork between reasonable options.
2. **No active context resolves it** -- user instruction, inspected code/artifacts, current evidence, knowledge base, refiner docs, and context anchor have all been checked. Still unresolved.
3. **Consequences are meaningful** -- affects architecture, behavior, or maintainability. Not cosmetic.

**Confidence test**: "I considered two or more approaches, and neither is clearly better given this project's context." True → surface. False → decide and move on.

**Default to deciding -- but only when grounded.** Grounded autonomy ≠ guessing. **STOP:** If the evidence is thin, missing, or conflicting, do not silently choose.

Stop and inspect / ask when ANY signal fires:

1. **No grounding** -- you cannot cite a source for a project-specific claim.
2. **Generic priors filling a local gap** -- you are about to assume a file path, API shape, config key, data contract, naming convention, or workflow because "projects usually do X."
3. **A missing fact collapses the answer** -- one unresolved fact would make one option clearly right or wrong.
4. **Conflicting sources** -- user instruction, code, docs, tests, logs, or context docs disagree.
5. **Unfalsifiable assumption** -- you cannot say what evidence would prove the current assumption wrong.

If any signal fires, do not invent options just to fit this protocol. Inspect the available evidence first. If it stays unresolved, ask a targeted clarification.

**STOP:** Conflicting active sources — surface the contradiction and ask. Never pick a winner silently.

## Presentation Format

Two formats:

### A. Decision needed

Use when multiple **grounded** options remain:

> **Decision needed**: [one-line description of what's being decided]
>
> Checked: [sources]. Missing/conflicting: [fact]
>
> - **Option A**: [approach] — [1-line pro], [1-line con]
> - **Option B**: [approach] — [1-line pro], [1-line con]
>
> I lean toward **[option]** because [one sentence of reasoning].

Two options is the norm. Three is the maximum. No essays.

### B. Clarification needed

Use when the issue is missing/conflicting knowledge, not balanced options:

> **Clarification needed**: [missing fact or contradiction]
>
> Checked: [sources]
> Missing/conflicting: [exact fact]
> Need from you: [1–3 targeted questions or a requested artifact]
> Why it matters: [one sentence]

No fabricated options. Ask only for facts that materially change direction. If the answer is available in the inspected repo/docs/tests, inspect first -- ask the user only when the gap remains.

## Batching

Do not interrupt for every judgment call. Collect and surface at natural checkpoints:

- **During implementation** (code-forge): batch per component. Surface all judgment calls for a component together before presenting its code.
- **During design** (design-blueprint): surface immediately. Each design level constrains the next -- batching risks cascading misalignment.
- **During review** (review): note uncertainty inline in the report, with both interpretations.
- **Standalone / freeform**: batch per logical task segment. Surface all judgment calls once the feature scope is clear -- not one at a time.
- **Knowledge gap / conflicting evidence**: surface immediately when the next step depends on the missing fact. Do not batch a blocker just to preserve flow.

**Escalation signal**: a single component producing more than 3 judgment calls means the project needs clearer standards. Suggest running the relevant refiner instead of asking about each one individually.

## Resolution

When the user resolves a judgment call or clarification:

1. **Apply immediately** -- implement the choice in the current context.
2. **Treat it as a commitment** -- the chosen option, clarified fact, or conflict resolution is not revisited silently later in the session.
3. **Suggest persistence** -- if the decision applies to similar future situations, suggest capturing it via `framework:context-anchoring` (per-feature) or recommend running the relevant refiner (project-wide).

## Diminishing Rule

This protocol becomes less active as the project matures:

- **First feature**: more judgment calls (no documented preferences yet).
- **After running refiners**: fewer (project standards are documented).
- **After several features**: rare (context docs and learnings cover most cases).
