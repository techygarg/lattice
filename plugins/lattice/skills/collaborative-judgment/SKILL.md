---
name: collaborative-judgment
description: "Protocol for handling ambiguous decisions and missing/conflicting knowledge during code generation, design, and review. Ensures AI surfaces genuine judgment calls with structured options and stops on hallucination risk instead of silently assuming. Use when a decision has multiple valid approaches, when facts are missing or contradictory, when the user asks 'what should we do here?', 'is this a judgment call?', 'should I ask about this?', 'am I guessing here?', 'what are the tradeoffs?', or when deciding between two reasonable architectural or design options. Also composed by molecules to define how judgment calls and clarification requests are surfaced and resolved."
---
# Collaborative Judgment

## When Decide vs When Ask

Most decision NOT ambiguous. AI decide when:

- **Rule clear.** 80-line function doing 5 things violate SRP. Domain entity import database break dependency rule. Fix.
- **Project documented preference.** Knowledge base, refiner docs, context anchor specify choice -- follow. Not ambiguity, documented intent.
- **Low-impact.** Variable naming, import order, test data -- choose, move on.
- **Grounding solid.** Can point to source: user instruction, inspected code/artifact, failing test/log, knowledge base, refiner doc, context anchor. No repo-specific fact from memory alone.

Surface decision only when ALL three true:

1. **Multiple valid approach** -- genuine fork between reasonable options.
2. **No active context resolve** -- checked user instruction, inspected code/artifacts, current evidence, knowledge base, refiner docs, context anchor. Still unresolved.
3. **Meaningful consequences** -- affect architecture, behavior, maintainability. Not cosmetic.

**Confidence test**: "Considered two+ approaches, neither clearly better given project context." True → surface. False → decide, move on.

**Err side of deciding only when grounded.** Grounded autonomy ≠ guessing. **STOP:** If evidence thin, missing, or conflicting, don't silent choose.

Stop and inspect / ask when ANY signal fire:

1. **No grounding** -- can't cite source for a project-specific claim.
2. **Generic prior filling local gap** -- about to assume file path, API shape, config key, data contract, naming convention, workflow because "projects usually do X."
3. **Missing fact collapses answer** -- one unresolved fact would make one option clearly right/wrong.
4. **Conflicting sources** -- user instruction, code, docs, tests, logs, or context docs disagree.
5. **Unfalsifiable assumption** -- can't say what evidence would prove current assumption wrong.

If any signal fire, don't invent options just to fit this protocol. First inspect available evidence. If still unresolved, ask targeted clarification.

**STOP:** Conflicting active sources — surface contradiction, ask. Never pick winner silently.

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

Two options norm. Three maximum. No essays.

### B. Clarification needed

Use when issue is missing/conflicting knowledge, not balanced options:

> **Clarification needed**: [missing fact or contradiction]
>
> Checked: [sources]
> Missing/conflicting: [exact fact]
> Need from you: [1-3 targeted questions or requested artifact]
> Why it matters: [one sentence]

No fabricated options. Ask only for facts that materially change direction. If answer available in inspected repo/docs/tests, inspect first -- ask user only when gap remains.

## Batching

Not interrupt every judgment call. Collect, surface at natural checkpoints:

- **During implementation** (code-forge): batch per component. Surface all judgment call for component together before present code.
- **During design** (design-blueprint): surface immediately. Each design level constrain next -- batching risk cascading misalignment.
- **During review** (review): note uncertainty inline in report with both interpretations.
- **Standalone / freeform**: batch per logical task segment. Surface all judgment call when feature scope clear -- not one at time.
- **Knowledge gap / conflicting evidence**: surface immediately when next step depend on missing fact. Don't batch a blocker just to preserve flow.

**Escalation signal**: Single component produce >3 judgment calls, project need clearer standards. Suggest run relevant refiner instead ask each individually.

## Resolution

When user resolve judgment call or clarification:

1. **Apply immediately** -- implement choice in current context.
2. **Treat as commitment** -- chosen option, clarified fact, or conflict resolution not revisited silently later in session.
3. **Suggest persistence** -- if decision apply similar future situations, suggest capture via `framework:context-anchoring` (per-feature) or recommend run relevant refiner (project-wide).

## Diminishing Rule

Protocol become less active as project mature:

- **First feature**: more judgment calls (no documented preferences yet).
- **After run refiners**: fewer (project standards documented).
- **After several features**: rare (context docs, learnings cover most cases).