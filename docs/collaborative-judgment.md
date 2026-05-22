# Collaborative Judgment: Design Rationale

Why Lattice needs a cross-cutting protocol that teaches the AI when to ask, what not to ask, and how to ask efficiently.

## The Problem: Silent Assumptions

AI coding assistants face genuine ambiguity constantly — a borderline SRP call, a debatable layer placement, an arguable aggregate boundary. Without guidance, the AI resolves these silently. It picks one option and presents it as the only possibility. The user never knows a decision was made on their behalf.

The damage is subtle but cumulative. Five silent micro-assumptions produce code that feels "off" but the user can't articulate why. Undoing a woven-in assumption costs far more than making an informed choice upfront.

This is the gap collaborative-judgment fills: **give the AI the intelligence to recognize when it's genuinely uncertain or under-grounded and surface that uncertainty to the user instead of guessing.**

## What Intelligence This Atom Adds

### When to ask (and when not to)

Most decisions are NOT ambiguous. The AI should decide autonomously when the rule is clear (an 80-line function doing 5 things violates SRP — fix it), when the project already has a documented preference (that is not ambiguity — it is documented intent), or when the stakes are low (variable naming, formatting — just pick one).

Surface a decision only when all three are true: multiple valid approaches exist, no project context resolves it, and the choice has meaningful consequences.

The confidence test: "I considered two or more approaches and neither is clearly better given this project's documented context." If true → surface. If false → decide and move on. An AI that asks about everything is as useless as one that asks about nothing.

But not all uncertainty is a judgment call. Sometimes the issue is a **knowledge gap**: the AI cannot cite the source for a project-specific claim, is about to fill a local gap with generic prior, sees active sources that conflict, or knows one missing fact would collapse the decision. In those cases the right move is not to invent Option A / Option B. The right move is to inspect available evidence first, then ask a targeted clarification if the gap remains.

### Batching

When the AI does need to ask, it should not interrupt for every single question:

- **During implementation**: batch per component — surface all judgment calls together before presenting the code.
- **During design**: surface immediately — each design level constrains the next.
- **During review**: note uncertainty inline with both interpretations.
- **During missing/conflicting grounding**: surface immediately when the next step depends on the unresolved fact. Do not batch a blocker just to preserve flow.

Escalation signal: if a single component produces more than 3 judgment calls, the project needs clearer standards, not more questions. Suggest running the relevant refiner instead.

## A Cross-Cutting Protocol

Collaborative-judgment is not like the other atoms. Code-quality atoms apply to specific code — clean-code checks functions, DDD checks domain entities, secure-coding checks trust boundaries. Collaborative-judgment is a **cross-cutting protocol** loaded into the AI's context so that every other atom can link back to it through their embedded signals. It governs how any ambiguity — regardless of which atom surfaced it — gets presented, batched, and resolved.

### How atoms link back

Each code-quality atom carries two small embedded pieces that connect to this protocol:

1. **The checklist header instruction**: *"If a check is a judgment call with multiple valid approaches (see Ambiguity Signals), flag it — present your options and reasoning rather than silently choosing."* This tells the AI: when you hit a gray area during verification, do not silently resolve it.

2. **The Ambiguity Signals section**: domain-specific gray areas where that atom's checks tend to produce judgment calls — borderline SRP in clean-code, layer placement in architecture, aggregate boundaries in DDD, trust boundary scope in secure-coding.

These two pieces form the **detection layer** — each atom knows its own gray areas and tells the AI to flag them. Collaborative-judgment provides the **resolution layer** — how to present, when to batch, how to resolve. The molecule loads both into one context window; the AI applies them as an integrated whole.

## Runtime Flow

What happens when a user invokes `/code-forge`:

```
Step 1: AI reads code-forge → loads all referenced atoms into context

Step 2: AI holds ALL instructions in one context window
        ┌─────────────────────────────────────────────┐
        │  code-forge workflow                        │
        │  collaborative-judgment protocol            │
        │  clean-code checklist + ambiguity signals   │
        │  architecture checklist + signals           │
        │  DDD checklist + signals (if domain code)   │
        └─────────────────────────────────────────────┘

Step 3: Generate component (creative pass)

Step 4: Run Self-Validation Checklists (verification pass)
        ├─ Clearly fails         → fix silently
        ├─ Clearly passes        → move on
        ├─ Judgment call         → recognized from Ambiguity Signals
        │                         → checklist header says "flag it"
        │                         → collected for batched presentation
        └─ Missing/conflicting
           grounding             → inspect evidence first
                                 → if still unresolved, ask targeted clarification

Step 5: Present
        ├─ Zero flagged      → code with compliance note
        ├─ 1+ judgment calls → "Decision needed: [question]
        │                      Checked: [sources]. Missing/conflicting: [fact]
        │                      Option A: ... Option B: ...
        │                      I lean toward [X] because [reason]."
        └─ Knowledge gap     → "Clarification needed: [missing fact]
                               Checked: [sources]
                               Need from you: [targeted question]"

Step 6: User resolves → AI applies → continues
```

## Example

A user invokes `/code-forge` to implement an Order domain entity.

**Without collaborative-judgment**: The AI generates `OrderValidationService`, places it in the application layer, and moves on. It considered the domain layer but silently chose application because "services that coordinate multiple objects" sounded like application-layer work. The user reviews 200 lines of code and eventually realizes validation logic should have been in the domain.

**With collaborative-judgment**: The AI runs the architecture checklist. Check 5 (LAYER PLACEMENT) triggers — architecture's Ambiguity Signals flags "logic that coordinates domain objects but also contains business rules" as a judgment call. At the component checkpoint:

> **Decision needed**: Where should `OrderValidationService` live?
>
> - **Option A: Domain service** — keeps validation rules with the domain; risk of domain services becoming a dumping ground
> - **Option B: Application service** — keeps domain lean; risk of business rules leaking outside domain
>
> I lean toward **domain service** because the validation rules (order amount limits, product availability) are domain invariants, not orchestration logic. But this depends on your team's convention.

The user says "domain service." The AI applies the choice, suggests enriching the context doc, and continues. Total cost: 10 seconds. Value: the user's architecture, not the AI's guess.

## The Flywheel Connection

1. AI encounters ambiguity → surfaces to user → user decides
2. Decision captured in context anchor doc (per-feature persistence)
3. Next time same question arises for this feature → context doc has the answer → no ask
4. If the pattern recurs across features → candidate for knowledge base or refiner-produced standard
5. Once in standards → atom checklist has a clear answer → no ambiguity → no ask

**The atom makes itself less necessary over time.** It teaches the project to be more specific, which makes the AI more autonomous, which makes the human more productive.
