# Architecture Compass: Design Rationale

Why this molecule exists, what it does, and what to expect when you use it.

> **Audience**: Teams with existing codebases who want to understand the architectural compass concept and what a session will feel like before they start.

---

## The Problem: No Structured Starting Point for Existing Codebases

Every other Lattice molecule assumes a greenfield or targeted context. `design-blueprint` designs new features. `code-forge` implements from an approved design. `refactor-safely` improves a specific bounded piece of code.

Teams with *existing* codebases — the majority of teams doing serious engineering — have no structured starting point. They inherit a codebase with architectural drift, unclear layer boundaries, and dependencies flowing in wrong directions. They know something is wrong. They do not know specifically what, why, or where to begin without making things worse.

The typical outcome is one of three failure modes:
- **Starting without shared direction** — each developer improves their own area toward their own mental model of the target. No agreement. The codebase becomes a patchwork of different architectural styles.
- **Starting in the wrong place** — diving into execution before understanding the problem well enough. Months of work that turns out not to address the actual pain.
- **Not starting at all** — the problem feels too large and undefined to act on.

`architecture-compass` is the molecule for this situation.

---

## What It Is — and Is Not

**A compass does not take you anywhere. It shows you where you are and points you in the right direction.**

`architecture-compass` is an architectural thinking partner. It helps a team understand their codebase, agree on its current architectural state, and agree on a recommended direction — scoped to one repository, module, or folder.

It does not:
- Execute any transformation
- Move or rewrite any code
- Produce execution slices, epics, or stories
- Plan multi-team or organisation-level changes
- Audit clean code, naming, or test coverage (execution concerns)

What it produces: `.lattice/insights/architecture.md` — a shareable insights document that captures what was found, what was agreed, and what to do first.

---

## The Hypothesis

> **Architectural clarity before action prevents months of wasted effort.**

Most architectural improvement efforts fail not because the execution was technically flawed, but because the team never reached genuine shared understanding of two things: where the architecture actually is today, and what direction it should move.

Individual developers hold different mental models. The AI holds a model assembled from code without team context. The tech lead holds a model that includes intent and history invisible in the code. Without a structured process to reconcile these, every improvement decision is made in partial information.

The hypothesis: if a team can produce a single document that accurately captures the agreed current architecture and the agreed recommended direction — with the rationale for every structural choice — improvement work becomes confident and coordinated. The hardest part is not the code changes. It is reaching genuine written agreement on the destination.

`architecture-compass` is designed to produce that agreement.

---

## The Philosophy

### 1. Orientation before action

The molecule focuses on understanding and agreeing — not on planning execution. Once the team has a shared architectural map and agreed direction, they use existing molecules (`refactor-safely`, `design-blueprint`, `code-forge`) to act.

### 2. The scan earns the right to ask questions

The AI reads the codebase before asking anything. Questions asked before analysis feel generic and waste the team's time. The scan is what makes the interview sharp and targeted — 5–7 questions informed by actual findings, not a generic discovery form.

### 3. The interview is the most valuable phase

The scan reveals the structural facts. The interview reveals the human context: why the team is doing this, what pain they experience every week, what they tried before, what success looks like to them. That context is what separates a generic architectural recommendation from one the team will actually follow.

Act 3 of the interview — the Vision — is the most important. "What would you be able to do after this that you cannot do today?" is an architectural question, not a soft one. The answer shapes the entire recommended direction.

### 4. Minimum viable direction

The recommended direction is the simplest architectural structure that resolves the stated pain. Not the most elegant architecture possible. The test: can the team take the first move this week? A direction that only pays off after six months of work is the wrong direction.

### 5. The output listens

The insights document should feel like it listened. It references what the team said in the interview. The recommended direction explicitly responds to the stated pain. The first moves reflect the stated constraints. A generic architectural report that ignores the conversation delivers no value over a textbook.

---

## What to Expect

### Phase 1: The silent scan

The molecule begins by reading the codebase without asking questions. It reads strategically — directory tree, dependency manifests, architecture documents, import patterns via grep, entry points, interfaces, one representative file per module. Around 15–25 targeted reads on most codebases.

Before analysing flows, it performs an archaeology pass: dead code candidates, duplicate functionality, implicit coupling through shared state, and hidden integration points not obvious in normal code paths.

After the scan, it holds a hypothesis about what the architecture actually is and — critically — whether the problems represent **architectural drift** (a sound original intention eroded over time) or **architectural mismatch** (the wrong pattern for the domain from the start). These require different recommended directions.

### Phase 2: The four-act interview

A short, adaptive interview — 5–7 questions in practice:

- **Act 1 — Burning Platform**: What finally made you act? What pain does the team feel every week?
- **Act 2 — History**: How did you get here? What was tried before and what stopped it?
- **Act 3 — Vision**: What would you be able to do after this work that you cannot do today?
- **Act 4 — Guardrails**: What is off-limits? What external contracts are not visible in the code?

The most important question is Act 3. "We want to onboard new devs in 2 weeks" points toward explicit layers and clear module ownership. "We want teams to work independently" points toward bounded contexts. "We want to stop shipping bugs when touching unrelated code" points toward strict dependency inversion. The vision answer IS an architectural input.

### Phase 3: Current architecture agreement

The AI presents its architectural read as a structured map: current layer structure, dependency flow diagram (showing violations), module inventory, and key structural pain points with specific named evidence.

This is the first agreement checkpoint. The team corrects, enriches, or confirms. The session does not advance until both parties agree the map is accurate.

What often emerges: things the team assumed were intentional turn out to be drift. Things they assumed were accidental turn out to be intentional. The AI's structural read surfaces these mismatches and the team resolves them.

### Phase 4: Recommended direction

Once current state is agreed, the AI proposes a recommended architectural direction — not a generic clean architecture template, but a structure tailored to what was found and what the team said in the interview.

The approach depends on the drift/mismatch determination. Drift → restore the original intent ("here is what this was always trying to be"). Mismatch → design fresh from the domain up.

The proposal includes a target architecture diagram and an annotated folder tree showing what the target structure looks like.

This is a negotiation. The team shapes the proposal. The AI refines. The session can end here — current and target states agreed in the insights document — and the next steps can be planned later.

### Phase 5: Gap assessment and first moves

With both states agreed, the AI derives what must change, what should change, what to defer, and what to leave alone — structural items only, no clean code or test coverage items.

The session closes with **first moves**: the 2–3 most important structural decisions to make next, each tagged with which molecule to use (`/refactor-safely` for structural moves, `/design-blueprint` → `/code-forge` for new structures).

---

## The Output: `.lattice/insights/architecture.md`

A progressive insights document with a defined structure:

```
Session Status        — phase checkpoint table, honest about what stage was reached
Repository Identity   — language, framework, scope boundary, constraints
Why We're Doing This  — the burning platform, from the interview
Archaeology Findings  — quick wins, risks, dead code, hidden coupling
Domain Map            — core domain, seams, bounded contexts (if applicable)
Current Architecture  — agreed map with Mermaid diagram
Recommended Direction — agreed target with diagram, folder tree, dependency rules
Gap Assessment        — must / should / defer / leave alone
First Moves           — 2–3 structural decisions with molecule guidance
```

The document has two layers:

**Layer 1 — What we found** (from scan + interview, no agreement needed). Always present. A team that has never written down "why we're doing this" and "what we tried before" has already gotten something real.

**Layer 2 — What we agreed** (only when each gate was passed). Fills in progressively. The session status table shows exactly where the conversation reached.

The document is complete enough that a new AI session or new team member can read it and understand exactly what was found, agreed, and next. No re-briefing required.

---

## What the Output Enables

```
First Moves section → each move uses:

  Structural move (move existing code)
    └─ /refactor-safely

  New structure (new layer, new interface, new boundary)
    └─ /design-blueprint (enters at Level 4, from first move description)
         └─ /code-forge

  Verify each move
    └─ /review
```

The compass orients. The other molecules move.

---

## Key Design Decisions

**Why scope to repository / module / folder — not organisation?**
An organisation transformation involves politics, budgets, multiple teams, leadership alignment — variables an AI molecule cannot meaningfully address. A repository transformation is concrete, verifiable, and completable. Keeping the scope tight keeps the output actionable.

**Why first moves instead of a full slice backlog?**
A full backlog implies execution planning. This molecule produces orientation, not execution plans. First moves give the team enough to act without over-prescribing a path that will change as they learn. The backlog emerges naturally as first moves complete and understanding deepens.

**Why strategic DDD only?**
Tactical patterns — aggregates, value objects, domain events — belong to execution. Including them in an insights document makes it brittle. Bounded contexts and domain seams are stable enough to agree on at the planning level.

**Why the interview before the current state presentation?**
The interview primes the AI with human context before it presents findings. Without it, the AI would present a structurally accurate but contextually empty map. Knowing the team's pain, history, and vision changes which violations are highlighted and how the map is framed.
