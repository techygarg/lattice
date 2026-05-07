# Plan Transformation: Design Rationale

Why Lattice's transformation molecule exists, what it does, and what to expect when you use it.

> **Audience**: Teams with existing codebases who want to understand the transformation hypothesis and what the planning experience will feel like before they start.

---

## The Problem: Greenfield Tools Applied to Legacy Realities

Every molecule in Lattice before `plan-transformation` assumes a greenfield or targeted context. `design-blueprint` designs new features. `code-forge` implements from an approved design. `refactor-safely` improves a specific, bounded piece of code. `bug-fix` repairs a known defect.

Teams with *existing* codebases — the majority of teams doing serious engineering — have no structured path. They inherit a codebase with architectural drift, unclear layer boundaries, domain logic scattered across the wrong places, and dependencies flowing in every direction. They know it needs fixing. They do not know where to start, in what order to proceed, or how to avoid making things worse while trying to make them better.

The typical outcome is one of three failure modes:
- **Big bang rewrite** — attempt to rebuild everything at once. Usually abandoned halfway, leaving a codebase worse than before with a half-finished new structure grafted onto the old one.
- **Inconsistent cleanup** — each developer improves their own area toward their own mental model of the target. No shared direction. The codebase becomes a patchwork of different architectural styles.
- **Paralysis** — the transformation feels too large to start and never starts.

`plan-transformation` is the molecule for this situation.

---

## The Hypothesis

> **Architectural problems cannot be fixed without first being agreed upon.**

Most transformation efforts fail not because the execution was technically flawed, but because the team never reached genuine shared understanding of two things: where the architecture actually is today, and where it should be.

Individual developers hold different mental models of the codebase. The AI holds a model assembled from reading code without team context. The tech lead holds a model that includes intent and history invisible in the code itself. Without a structured process to reconcile these models, every transformation decision is made in partial information.

The hypothesis is: if a team can produce a single document that accurately captures the agreed current architecture and the agreed target architecture — with the rationale for every structural choice — the execution becomes a mechanical process of crossing the gap. The hardest part of transformation is not the code changes. It is reaching genuine, written agreement on the destination.

`plan-transformation` is designed to produce that agreement.

---

## The Philosophy

Four principles shape how this molecule is designed.

### 1. Architecture first. Principles follow.

The molecule focuses exclusively on structure: layers, dependency direction, module boundaries, bounded contexts. It does not plan clean code improvements, test coverage, naming conventions, or security hardening.

This is deliberate. When architecture is wrong — layers tangled, dependencies flowing incorrectly, domain logic mixed with infrastructure — no amount of clean code improvement can fix the system. You cannot safely refactor what you cannot reason about structurally.

Clean code, domain modeling, testing quality, and security posture are all execution concerns. They apply naturally when code is written or moved using `code-forge` and `refactor-safely`. Planning should not touch them. A plan that tries to schedule naming improvements alongside layer restructuring has misunderstood the problem.

### 2. Planning is a conversation, not a report.

The molecule does not generate a transformation plan and hand it to the team. It conducts a structured conversation that ends in written agreement.

The AI scans the codebase, forms views, and presents them — but explicitly as proposals that require human validation. The team corrects, enriches, and challenges. The AI updates. Only when both parties agree does the conversation advance to the next phase.

This matters because the AI's read of the codebase is structurally accurate but contextually incomplete. It can see that a `services/` directory mixes business logic and database access. It cannot see that the team intentionally kept them together because a full extraction was attempted six months ago and abandoned for a specific reason. Without that context, the plan would be technically correct and practically wrong.

The plan document is the proof of shared understanding, not an AI output. It should read as if the team wrote it — because the team agreed to every word.

### 3. Minimum viable target.

The most common transformation failure is designing a to-be architecture that is more complex than the team can realistically reach.

Looking at a messy codebase, teams over-correct. Full hexagonal architecture. Strict DDD with explicit aggregates and domain events. Every possible boundary made explicit. The resulting plan looks impressive but cannot be executed incrementally — it only pays off at the very end, after months of work, with no visible improvement along the way. Teams lose confidence and stop.

The right target architecture is the simplest structure that resolves the actual stated pain. Not the most elegant architecture conceivable. The test: does each transformation slice leave the system measurably better than before? If yes, the target is right. If the system only improves after every slice is complete, the target is too ambitious.

### 4. The plan is a hypothesis, not a specification.

No transformation plan survives contact with the codebase fully intact. Hidden coupling surfaces during execution. Domain assumptions that seemed clear in a planning session turn out to be contested. Early slices reveal information that changes the understanding of later ones.

A plan that presents itself as authoritative will be abandoned the first time reality diverges from it. A plan that explicitly presents itself as the best current understanding — expected to be refined — will be updated and trusted.

The plan document states this explicitly. The target architecture is a hypothesis. The slice backlog is a living document. Both evolve as execution reveals new information.

---

## What to Expect

### Phase 1: The silent scan (you wait, AI reads)

The molecule begins by reading the codebase without asking any questions. This is intentional. An AI that asks obvious questions before doing any analysis destroys trust. The scan is what makes the subsequent interview sharp and targeted rather than generic.

The AI does not read the entire codebase. It reads strategically: the directory tree, dependency manifests, any existing architecture documentation, a sample of import patterns to understand dependency flows, entry points, interface definitions, and one representative file per top-level module. In practice this means 15–25 targeted reads on most codebases — enough to form a reliable architectural hypothesis without exhausting context.

Before analysing flows, the AI performs an archaeology pass: identifying dead code candidates, duplicate functionality that would need reconciling, implicit coupling through shared state or globals, and hidden integration points that might not be visible in normal code paths.

After the scan, the AI holds a hypothesis about what the architecture actually is, where the most significant violations are, and — critically — whether the problems represent architectural *drift* (a sound original intention eroded over time) or architectural *mismatch* (a pattern that was wrong for the domain from the start). These require different treatments.

### Phase 2: The interview (targeted questions only)

The scan is followed by a short interview — in practice 5–7 questions, never more than 10. The questions are adaptive: only what the code cannot tell.

Typical questions cover: the core domain of the application, which areas cause the most pain, whether any modules are intentionally off-limits, delivery constraints during migration, and — critically — whether the team has attempted a transformation before and what stopped it.

That last question is the most important one in the interview. Previous failed transformation attempts reveal specific blockers — technical, organisational, or political — that will stop this attempt too unless the plan explicitly accounts for them.

The interview also asks about areas the team understands poorly. Low-understanding zones are high-risk transformation areas. The plan document flags them explicitly. Transforming code that nobody fully understands is where behaviour gets accidentally changed.

### Phase 3: Current state agreement (slow down here)

After the scan and interview, the AI presents its architectural read of the codebase as a structured snapshot: the current layer structure, a dependency flow diagram showing violations, an inventory of what each module actually owns versus what it should own, and the key structural pain points with specific named evidence.

This is the first agreement checkpoint. The team is expected to challenge, correct, and add context. The AI updates the map. This conversation continues until both parties explicitly agree the map is accurate.

Do not rush this step. The current state map is the foundation of everything that follows. A target architecture designed against an inaccurate current state map will produce a gap analysis full of phantom problems and missing real ones.

What often emerges here: things the team had always assumed were intentional design decisions turn out to be drift. Things the team assumed were accidental drift turn out to be intentional. The AI's structural read surfaces these mismatches and the team resolves them.

### Phase 4: Target architecture co-design (the creative phase)

Once current state is agreed, the AI proposes a target architecture — not a generic clean architecture template, but a structure tailored to what was actually found.

The approach here depends on the drift/mismatch determination from the scan. If the codebase shows **architectural drift** from a sound original intent, the target proposal focuses on restoring that intent: "here is what this was always trying to be." If the codebase shows **architectural mismatch** — the original pattern was wrong for the domain from the start — the proposal designs fresh from the domain up.

The proposal includes: an architecture style with rationale, layer definitions and ownership rules, explicit dependency direction rules (with the key inversion — domain has zero dependency on infrastructure — stated as a hard rule), a target architecture diagram, and an annotated folder tree showing what the target repository structure will look like.

When the domain has multiple distinct business capabilities with different rates of change or different team ownership, the proposal includes a bounded context map showing where the domain seams should be drawn. When the domain is simpler, bounded context design is omitted — DDD at the planning level is strategic only.

This is a negotiation, not a presentation. The team shapes the proposal. The AI refines. The session can end here — with agreed current and target states written in the plan document — and the slice backlog can be built in a follow-up session. Reaching architectural agreement is itself a valuable outcome, even without an execution plan.

### Phase 5: The execution plan

With both states agreed, the AI derives the gap analysis (what must change, what should change, what is intentionally deferred, what should not be touched) and proposes a migration approach.

The approach choice is explicit and justified. The four options — strangler fig, layer-by-layer, bounded-context-by-bounded-context, and hybrid — each suit different situations. Strangler fig when the system must stay deployable; layer-by-layer when seams are weak and layering is the primary goal; bounded-context-by-bounded-context when domain complexity drives the transformation. Each choice has explicit sequencing constraints and an adapter removal strategy — adapters without removal conditions become permanent.

The slice backlog follows from the strategy. Each slice maps to one structural move. Each slice includes an explicit statement of what the system can still do after the slice completes. If that question cannot be answered, the slice is too large and must be split.

---

## The Output: `.lattice/transform/plan.md`

The plan document is a living document with a defined structure:

```
Codebase Identity        — language, framework, constraints
Archaeology Findings     — dead code, duplicates, hidden coupling, quick wins
Domain Map               — core domain, bounded contexts, seams
Current Architecture     — agreed map with dependency diagram
Target Architecture      — agreed target with diagram, folder tree, dependency rules
Gap Analysis             — must / should / defer / leave alone
Transformation Strategy  — approach, sequencing, parallel tracks, adapter plan
Slice Backlog            — ordered slices with scope, pre-conditions, risk, success criteria
Progress Log             — updated as slices complete
```

The plan document has two jobs. First, it is the **record of agreement** from the planning session — the proof that both human and AI reached genuine shared understanding before any code changed. Second, it is the **briefing document for future sessions** — complete enough that a new AI session, or a new team member, can read it alone and know exactly what was decided, what has been done, and what to do next. No re-briefing required.

The document explicitly states that the target architecture is the best current understanding and will be refined as execution reveals new information. This is not a weakness — it is what makes the document trustworthy over time.

---

## What the Transformation Will Feel Like

A few things to be prepared for:

**The scan will find things you did not expect.** Dead code you thought was in use. Duplicate implementations of the same concept that grew independently. Circular dependencies that no one knew existed. Outbound calls to external systems in places that seem wrong. This is normal. The archaeology pass surfaces what static code review misses.

**The current state agreement will take longer than you expect.** Expect to spend real time here. Some of what the AI marks as violations will be intentional. Some of what the team thinks is intentional will turn out to be drift. Resolving this is the work of the session, not a formality.

**The target architecture proposal will be simpler than you want.** The molecule is designed to propose the minimum viable target — the simplest structure that resolves the stated pain. If you came in expecting a full hexagonal + DDD + CQRS architecture, the proposal may feel underwhelming. This is the right tradeoff. An achievable target beats a beautiful one that stalls at slice 3.

**The plan document will be wrong in some ways.** This is by design. It is the best understanding at the moment of writing. Early execution slices will reveal hidden coupling, contested assumptions, and structural surprises that change later slices. Update the plan when this happens — that is what the Progress Log is for.

**Execution uses different molecules.** `plan-transformation` produces a plan; it does not execute it. Each slice in the backlog is executed using existing molecules: `refactor-safely` for moving existing code while preserving behaviour, `code-forge` for writing new code in the new structure. Those molecules apply clean code, DDD, testing, and security principles automatically — which is why the plan document does not need to address them.

---

## Key Design Decisions

**Why no current repository structure tree in the output?**
The current codebase is already there — it is its own artifact. Duplicating the folder tree into the plan document adds length without insight. The current architecture *diagram* is kept because it shows dependency flows and violations in a way that browsing the codebase does not. The target repository *tree* is kept because it shows something that does not exist yet.

**Why strategic DDD only?**
Tactical DDD patterns — aggregates, value objects, domain events — belong to execution. They emerge when `code-forge` implements each slice. Including them in the plan makes the plan brittle: a specific aggregate boundary agreed in planning will be wrong by the time that slice executes, because the understanding of the domain sharpens during execution. Bounded contexts and domain seams, by contrast, are stable enough to plan around.

**Why is the interview limited to 5–7 questions?**
Every question asked before the AI shares its scan findings imposes friction. A team that is asked 10 questions before seeing any analysis will disengage. The scan is what earns the right to ask questions. The questions are then surgical — only what the scan could not answer — not a generic discovery checklist.

**Why is the plan a hypothesis?**
Because pretending otherwise causes plans to be abandoned. When the first execution slice reveals something that contradicts the plan, a team that believes the plan is authoritative will either ignore the new information (wrong) or feel the plan has failed and stop using it (also wrong). A plan explicitly framed as a hypothesis gets updated. An updated plan is a working plan.
