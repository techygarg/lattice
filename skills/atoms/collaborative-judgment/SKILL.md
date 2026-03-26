---
name: collaborative-judgment
description: "Protocol for handling ambiguous decisions during code generation, design, and review. Ensures AI surfaces genuine judgment calls with structured options instead of silently assuming. Use when a decision has multiple valid approaches, when the user asks 'what should we do here?', 'is this a judgment call?', 'should I ask about this?', 'what are the tradeoffs?', or when deciding between two reasonable architectural or design options. Also composed by molecules to define how judgment calls are surfaced and resolved."
---

# Collaborative Judgment

## The Problem

AI coding assistants resolve ambiguity silently. When a checklist result could go either way -- a borderline SRP call, a debatable layer placement, an arguable aggregate boundary -- the AI picks one option and presents it as the only possibility. The user never knows a decision was made on their behalf.

The damage is subtle but cumulative. Five silent micro-assumptions produce code that feels "off" but the user can't articulate why. Undoing a woven-in assumption costs more than making an informed choice upfront.

## When To Decide vs When To Ask

Most decisions are NOT ambiguous. The AI should decide autonomously when:

- **The rule is clear.** An 80-line function doing 5 things violates SRP. A domain entity importing a database client breaks the dependency rule. Fix it.
- **The project has documented a preference.** If the knowledge base, refiner-produced docs, or context anchor already specify a choice -- follow it. That is not ambiguity; it is documented intent.
- **The decision is low-impact.** Variable naming between two reasonable options, import ordering, test data values -- choose and move on.

Surface a decision only when ALL three are true:

1. **Multiple valid approaches exist** -- not a clear violation, but a genuine fork between reasonable options.
2. **No project context resolves it** -- knowledge base, refiner docs, and context anchor are silent on this.
3. **The choice has meaningful consequences** -- it affects architecture, behavior, or maintainability. Not cosmetic.

**The confidence test**: "I considered two or more approaches and neither is clearly better given this project's documented context." If true → surface. If false → decide and move on.

**Err on the side of deciding.** A confident AI that occasionally makes a disputable choice is more useful than an uncertain AI that asks about everything. Ask only when genuinely torn and the consequences matter.

## Presentation Format

When surfacing a judgment call:

> **Decision needed**: [one-line description of what's being decided]
>
> - **Option A**: [approach] — [1-line pro], [1-line con]
> - **Option B**: [approach] — [1-line pro], [1-line con]
>
> I lean toward **[option]** because [one sentence of reasoning].

Two options is the norm. Three maximum. No essays -- the user needs to make a quick call, not read a thesis.

## Batching

Do not interrupt for every judgment call. Collect and surface at natural checkpoints:

- **During implementation** (code-forge): batch per component. Surface all judgment calls for a component together before presenting the code.
- **During design** (design-blueprint): surface immediately. Each design level constrains the next -- batching risks cascading misalignment.
- **During review** (review): note uncertainty inline in the report with both interpretations.
- **Standalone / freeform**: batch per logical task segment. If the user is discussing a feature, surface all judgment calls when the feature's scope is clear -- not one at a time as they arise.

**Escalation signal**: If a single component produces more than 3 judgment calls, the project needs clearer standards. Suggest running the relevant refiner rather than asking about each one individually.

## Resolution

When the user resolves a judgment call:

1. **Apply immediately** -- implement their choice in the current context.
2. **Treat as a commitment** -- do not revisit the same decision later in the session.
3. **Suggest persistence** -- if the decision would apply to similar future situations, suggest capturing it via `framework:context-anchoring` (per-feature) or recommend running the relevant refiner (project-wide).

## The Diminishing Rule

This protocol becomes less active as the project matures:

- **First feature**: more judgment calls (no documented preferences yet).
- **After running refiners**: fewer (project standards are documented).
- **After several features**: rare (context docs and learnings cover most cases).

A well-configured project should see almost no judgment calls. If the AI is still asking frequently after multiple features, the standards documents need improvement. For example: if aggregate boundary questions keep surfacing, the DDD defaults document may not define a sizing heuristic -- run the domain-driven-design refiner to capture the team's preference and eliminate the question permanently.
