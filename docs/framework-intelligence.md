# Framework Intelligence

How Lattice's base framework and living context layer create intelligence through feedback loops, verification passes, and AI compliance techniques.

> **Audience**: Framework consumers and contributors who want to understand *why* things are designed this way, not just *what* to do.

---

## 1. The Two-Pass Generation Model

**Problem**: Asking AI to generate and validate simultaneously is unreliable — like asking a writer to write and proofread in the same pass. The creative task (generating code) and the analytical task (checking compliance) compete for attention, and one always suffers.

**Solution**: Generate first, then verify — two distinct cognitive tasks executed sequentially.

**How it works in Lattice**: Code-forge generates a component, then runs atom checklists against the output before presenting it to the user.

```
┌──────────┐    ┌──────────┐    ┌──────────┐
│ Generate │───→│  Verify  │───→│ Present  │
│component │    │ vs atoms │    │ to user  │
└──────────┘    └──────────┘    └──────────┘
   Creative        Analytical      Only after
     task            task            clean
```

This separation matters because AI models follow instructions more reliably when given one clear task at a time. "Write this function" followed by "Now check these 10 rules" outperforms "Write this function while following these 10 rules."

---

## 2. The Verification Hierarchy

Three levels of verification, each catching different classes of issues:

```
Level 1: Component      ──→  Per-component atom checklists
                               (clean-code, DDD, secure-coding)
                                 ↓ all components done
Level 2: Cross-Component ──→  Architectural coherence
                               + learnings check
                                 ↓ implementation complete
Level 3: Review          ──→  Independent assessment
                               + insight capture + health log
```

**Level 1 — Component** (code-forge Step 3): "Did I write this piece well?" Run atom self-validation checklists against every function and class in the component. Catches: SRP violations, naming issues, missing validation, primitive obsession, security gaps.

**Level 2 — Cross-Component** (code-forge Step 4): "Does everything fit together?" Verify dependency direction, interaction flows, security boundaries, and adherence to the approved blueprint. Catches: wrong dependency direction, leaking abstractions, missing integration points, recurring patterns flagged in learnings.

**Level 3 — Review** (separate invocation): "Independent quality assessment." Fresh eyes on the delta with no generation bias. Catches: issues the generator is blind to, cross-cutting concerns, patterns that only emerge when viewing the whole.

Why three levels: Same reason human teams have self-review, then peer review, then QA. Each level catches what the previous one misses. The cost of these checks is low — a few seconds of AI thinking. The cost of missing an issue compounds with every subsequent component built on top of it.

---

## 3. The Learning Flywheel

The flywheel is the central mechanism of the living context layer -- the engine that turns review findings into institutional memory and feeds them back into generation.

**Problem**: Without feedback loops, the same mistakes repeat across features. Review finds "anemic domain models" in Payment, then again in User, then again in Order. Each review starts from zero.

**Solution**: Review findings persist as learnings. Code-forge loads learnings at session start. The framework gets smarter with use.

```
┌────────────────┐     ┌─────────────┐     ┌──────────────────┐
│   code-forge   │────→│   review    │────→│ .lattice/learnings/   │
│ loads learnings│     │ finds issues│     │ review-insights.md│
└───────┬────────┘     └─────────────┘     └────────┬─────────┘
        │                                           │
        └────────────── feeds back ─────────────────┘
```

**Format discipline**: Each insight is one bullet point — date, feature, pattern, fix. Capped at ~50 entries. Concise enough for AI to scan in seconds, specific enough to act on.

```
- 2026-03-05 [Payment]: Domain services doing repository work — push data access behind repository interfaces
- 2026-03-05 [Payment]: Missing validation in value object constructors — validate in constructor, not caller
- 2026-03-10 [User]: Anemic entities with only getters — push behavior into entity methods
```

Why this matters: Institutional memory that survives across features and sessions. A team's coding standards aren't just what's written in a style guide — they're the accumulated lessons from past reviews. The flywheel captures that for AI-assisted development.

---

## 4. Project Health Visibility

**Problem**: No way to answer "Is Lattice actually helping? Are we getting better over time?"

**Solution**: The review molecule appends structured summaries to `.lattice/reviews/review-log.md` after each review.

```
## 2026-03-05 — Payment endpoint
- **Scope**: 8 files, 3 layers (domain, application, interface)
- **Atoms**: clean-code, architecture, DDD, secure-coding
- **Result**: 0 critical, 2 warning, 3 suggestion
- **Key findings**: Missing input validation on PaymentAmount; domain service doing repository work
- **Strengths**: Clean aggregate boundaries, proper value objects
```

What trends reveal over time:
- Which atoms catch the most issues (where the team needs to improve)
- Whether certain anti-patterns recur (learnings aren't being absorbed)
- Whether code quality improves (fewer findings per review)
- Which layers have the most issues (where to focus training)

Rolling window of 15-20 entries prevents bloat. Older entries get a one-line summary in a "History" section.

---

## 5. AI Compliance Techniques

The challenge: Atoms are markdown — AI can read them but also ignore them. There's no compiler, no linter, no gate. Compliance depends on prompt engineering techniques that make it harder for the AI to skip steps.

**Technique 1 — Imperative language with cognitive boundaries**

"STOP and verify ALL of the following" beats "apply these checks as you write." The word STOP creates a cognitive boundary — a clear transition from generation mode to verification mode.

**Technique 2 — Numbered, labeled constraints**

LLMs follow numbered lists more reliably than prose. `1. SINGLE RESPONSIBILITY:` is harder to skip than a paragraph about single responsibility. The label serves as both a check name and a mental anchor.

**Technique 3 — Active anti-pattern scans**

Instead of "here are bad patterns to avoid" (passive reference), use "Scan your output for these patterns: [ ] God function [ ] Primitive obsession" (active checklist). The checkbox format triggers completion behavior — the AI wants to check each box.

**Technique 4 — Show your work**

Requiring AI to report what it checked forces it to actually run through the list. Silent compliance is unreliable; visible compliance is accountable. When checks pass, a brief note suffices. When checks fail, the AI must show what it found and how it fixed it.

**Technique 5 — Separation of concerns**

Creative task (generation) and analytical task (validation) in separate passes. This is Technique 1 at the architectural level — the two-pass model described in Section 1.

---

## 6. The `.lattice/` Folder as Institutional Memory

The `.lattice/` folder is where the living context layer takes physical form -- standards, context documents, learnings, and health logs, each with a distinct lifecycle. See [how-it-works: The .lattice/ Folder](how-it-works.md#the-lattice-folder) for the folder structure and lifecycle details.

---

## 7. End-to-End Flow

Each tool in the pipeline both consumes and produces persistent artifacts -- this is the compounding cycle that makes Lattice improve with use. Design-blueprint produces the context document; code-forge consumes and enriches it; review produces learnings and health logs; those learnings feed back into the next code-forge session. The base framework never changes between feature cycles, but the living context layer grows richer with each one -- standards become more precise, learnings capture more patterns, health logs reveal longer trends.

See [how-it-works: The Pipeline](how-it-works.md#the-design-to-code-pipeline) for the detailed stage-by-stage flow.
