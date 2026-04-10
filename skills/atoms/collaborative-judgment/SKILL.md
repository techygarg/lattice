---
name: collaborative-judgment
description: "Protocol for handling ambiguous decisions during code generation, design, and review. Ensures AI surfaces genuine judgment calls with structured options instead of silently assuming. Use when a decision has multiple valid approaches, when the user asks 'what should we do here?', 'is this a judgment call?', 'should I ask about this?', 'what are the tradeoffs?', or when deciding between two reasonable architectural or design options. Also composed by molecules to define how judgment calls are surfaced and resolved."
---
# Collaborative Judgment

## Problem

AI resolve ambiguity silent. User never know decision made. Silent micro-assumption make code feel "off". Undo woven assumption cost more than upfront choice.

## When Decide vs When Ask

Most decision NOT ambiguous. AI decide when:

- **Rule clear.** 80-line function doing 5 things violate SRP. Domain entity import database break dependency rule. Fix.
- **Project documented preference.** Knowledge base, refiner docs, context anchor specify choice -- follow. Not ambiguity, documented intent.
- **Low-impact.** Variable naming, import order, test data -- choose, move on.

Surface decision only when ALL three true:

1. **Multiple valid approach** -- genuine fork between reasonable options.
2. **No project context resolve** -- knowledge base, refiner docs, context anchor silent.
3. **Meaningful consequences** -- affect architecture, behavior, maintainability. Not cosmetic.

**Confidence test**: "Considered two+ approaches, neither clearly better given project context." True → surface. False → decide, move on.

**Err side of deciding.** Confident AI occasionally disputable > uncertain AI ask everything. Ask only when genuinely torn, consequences matter.

## Presentation Format

When surface judgment call:

> **Decision needed**: [one-line description of what's being decided]
>
> - **Option A**: [approach] — [1-line pro], [1-line con]
> - **Option B**: [approach] — [1-line pro], [1-line con]
>
> I lean toward **[option]** because [one sentence of reasoning].

Two options norm. Three maximum. No essays.

## Batching

Not interrupt every judgment call. Collect, surface at natural checkpoints:

- **During implementation** (code-forge): batch per component. Surface all judgment call for component together before present code.
- **During design** (design-blueprint): surface immediately. Each design level constrain next -- batching risk cascading misalignment.
- **During review** (review): note uncertainty inline in report with both interpretations.
- **Standalone / freeform**: batch per logical task segment. Surface all judgment call when feature scope clear -- not one at time.

**Escalation signal**: Single component produce >3 judgment calls, project need clearer standards. Suggest run relevant refiner instead ask each individually.

## Resolution

When user resolve judgment call:

1. **Apply immediately** -- implement choice in current context.
2. **Treat as commitment** -- not revisit same decision later in session.
3. **Suggest persistence** -- if decision apply similar future situations, suggest capture via `framework:context-anchoring` (per-feature) or recommend run relevant refiner (project-wide).

## Diminishing Rule

Protocol become less active as project mature:

- **First feature**: more judgment calls (no documented preferences yet).
- **After run refiners**: fewer (project standards documented).
- **After several features**: rare (context docs, learnings cover most cases).

Well-configured project see almost no judgment calls. If AI still ask frequently after multiple features, standards documents need improvement. Example: aggregate boundary questions keep surface, DDD defaults document may not define sizing heuristic -- run domain-driven-design refiner capture team preference, eliminate question permanently.