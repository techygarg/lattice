---
name: learning-harvest
description: "Manage the operational learnings lifecycle — load prior learnings to inform current work, harvest new patterns worth preserving, and keep the document tight over time. Provides a protocol for accumulating actionable patterns from practice that complement standards and defaults. Use when a workflow session completes and produced insights worth persisting, when starting a session that should benefit from prior patterns, or when the user says 'harvest learnings', 'what have we learned', 'capture this pattern', 'tighten learnings', 'compress learnings', or 'operational learnings'."
---
# Learning Harvest

## Scope Boundary

Operational learnings are NOT rules. They are what you learn while applying rules.

| Standards (refiner output, atom defaults) | Operational Learnings (this document) |
|---|---|
| "Domain layer must not import from infrastructure" | "When adding a new aggregate, we keep forgetting to define the repository interface first — design interface before implementation" |
| "Functions should have single responsibility" | "Service classes that start small grow past 500 lines within 3 features — split by command type proactively at ~200 lines" |
| "Value objects must validate in constructor" | "Date range VOs without explicit inclusive/exclusive documentation cause boundary bugs every time — document semantics alongside validation" |

**The standard is the rule. The operational learning is what we discovered while applying the rule on this project.**

If an entry reads like a rule that should always be followed, it belongs in a standards document (run the relevant refiner). If it reads like "here's what we keep learning the hard way" or "here's an approach that keeps working for us" — it belongs here.

Patterns that recur frequently may graduate to standards via a refiner. That promotion path is part of the Tighten behavior.

## Config Resolution

1. Check `.lattice/config.yaml` for `paths.operational_learnings`.
2. If set and the file exists at that path → use it.
3. If set but no file exists there → tell the user which configured path is missing, then use the default `.lattice/learnings/operational-learnings.md`.
4. If not set → use the default `.lattice/learnings/operational-learnings.md`.

**Backward compatibility**: If default path not found, check these legacy paths in order:
- `.lattice/learnings.md` — flat file at root
- `.lattice/learnings/review-insights.md` — prior naming convention

If found, offer migration to canonical path and format. If user declines, read as flat input. **STOP: do not write to it.**

## Document Structure

```markdown
# Operational Learnings

Experiential patterns from practice. Complements standards (what should be) with experience (what we keep learning).

## Design Patterns
<!-- Decomposition, architecture choices, scope decisions that proved good or bad -->

## Implementation Craft
<!-- Coding approaches, library gotchas, design-to-reality gaps -->

## Quality Signals
<!-- Recurring quality issues that keep appearing despite rules -->

## Reliability
<!-- Bug root causes, failure modes, fragile areas, boundary condition gaps -->

## Structural Health
<!-- Architectural drift, debt accumulation, coupling issues, migration lessons -->
```

**Entry format**: `- YYYY-MM-DD [context] Pattern — actionable takeaway`

- `context`: type of session (e.g., "design", "implementation", "review", "bug fix", "refactoring"). Not a feature name — learnings are cross-cutting.
- Each entry ONE bullet, max 2 lines, scannable in under 10 seconds.

## Load Behavior

Invoked at session start. Composing workflow passes a **focus hint** (relevant categories).

1. Resolve file path per Config Resolution.
2. If file not found — "No operational learnings yet." Continue. Non-blocking.
3. If found — surface relevant entries (3-5 most recent from matching categories) as brief context. Treat as soft guidance, not hard constraints.

**Active monitoring**: Once loaded, maintain a **silent harvest queue** throughout the session. When a decision or trade-off passes the cross-cutting test below, add it to the queue. **STOP: do not prompt immediately.**

**Cross-cutting test** — a candidate must pass BOTH before queuing:
1. It names a pattern or approach, not a feature-specific fact.
2. A developer on a completely different feature could apply it without knowing this feature's context.

**STOP: if either fails, skip entirely — do not queue.**

Before queuing, check against entries loaded at session start. If the same pattern already exists — skip.

**When to surface:** Surface the queue as a single batch when EITHER condition is true — not at every level or layer:
- Queue reaches 3 candidates, OR
- A major phase completes (all design levels done, a full implementation layer done)

**STOP: do not surface at every individual level approval or component completion** — that is over-prompting. Once surfaced, clear the queue. Anything remaining at session end goes to Harvest.

> "I noted [N] potential harvest candidates — worth a quick review?"

**Mid-session interrupt** (rare exception): surface a single pattern immediately, outside the queue, only when it would be impossible to reconstruct by session end — a live debate that resolved unexpectedly, a library gotcha caught mid-implementation. If in doubt, queue instead.

Session-end Harvest is the primary mechanism.

## Harvest Behavior

Invoked at session end. Composing workflow passes a **session context** (what kind of work happened).

**Governing principle: STOP: the atom never writes autonomously.** Session-end Harvest is the primary capture event — mid-session prompting is the exception.

**Steps**:

1. **Drain the queue.** Collect all candidates from active monitoring queue plus any new ones surfaced by reviewing session decisions and outcomes. Each candidate must have passed the cross-cutting test (active monitoring) or pass it now.

2. **Propose as a batch.** Present queued candidates together — not one per message:

   > Harvest candidates from this session:
   > 1. [Category] — [pattern in one line]
   > 2. [Category] — [pattern in one line]
   >
   > Accept, edit, add your own, or skip entirely.

   Empty queue and nothing new found? Say so in one line. **STOP: do not force output.**

3. **Filter — apply before writing confirmed entries.** For each entry the user accepts:

   | Filter | Fail if... |
   |--------|------------|
   | **Evidence** | No concrete session event — just prior knowledge |
   | **Cross-cutting** | Specific to this feature's domain, won't recur |
   | **Actionable** | Requires this conversation's context to understand |
   | **Recurrence** | No structural reason it will happen again |

   Filter fails on a confirmed entry? Tell the user which filter — offer to reword. **STOP: do not silently drop.**

4. **User decides.** Accept, edit, reject, add their own, or skip all. **STOP: do NOT argue for rejected entries.**

5. **Write confirmed entries only.** Dedup against existing entries (update with a recurrence note if the same pattern exists). Create the file and directory if needed.

6. **Assess health.** Count entries per category and total (already read for dedup in Step 5). Any category exceeds ~10 entries, or total exceeds ~35 → note in one line: "Operational learnings is growing dense — say 'tighten learnings' to run Tighten standalone." Pattern recurred 4+ times → note it as a promotion candidate the same way. **STOP: do not run Tighten in this session** — flag only, never act.

## Tighten Behavior

Invoked standalone only — Harvest may flag that tightening is due, but never launches it.

1. Read full document.
2. Identify: consolidation opportunities (same pattern, different words), noise (one-off, never recurred), promotion candidates (recurred 4+ times — suggest refiner), stale entries (project has changed).
3. Present each candidate individually — consolidation, noise, promotion, and staleness are different judgment calls. Accept / edit / reject per candidate, not as one batch.
4. Apply only what user confirms.

## Self-Validation Checklist

Before writing any entry, verify ALL. **STOP: if any fails, do not write.**

1. **User confirmed** — STOP: Explicit user approval for every entry. No exceptions.
2. **Evidence grounded** — STOP: Produced by a specific session event, not prior knowledge.
3. **Experiential, not prescriptive** — STOP: Reads like "what we learned" not "what the rule should be." If it's a rule, it belongs in standards via a refiner.
4. **Cross-cutting** — STOP: Applies beyond this feature. Feature-specific decisions belong in context anchor doc.
5. **Actionable standalone** — STOP: a developer on a different feature can act on this without this conversation's context. Confidence level is not a gate — the user decides if it is worth capturing.
6. **Not redundant** — STOP: Not already in standards, atom defaults, or existing learnings. At most, add recurrence note.
7. **Concise** — STOP: Scannable in 10 seconds. Two lines max.

All checks pass on an entry → write it.

## Standalone Invocation

When invoked directly — not composed by a molecule — match the user's phrase to exactly one behavior. **STOP: if ambiguous, ask — never guess.**

| User says | Run |
|---|---|
| "tighten learnings", "compress learnings", "clean up learnings", "/learning-harvest tighten learnings" | Tighten Behavior |
| "harvest learnings", "capture this pattern", "log this learning" | Harvest Behavior |
| "what have we learned", "load learnings", bare "operational learnings" with no verb | Load Behavior |

**STOP: if the phrase doesn't clearly map to one row, ask** — "Load recent entries, harvest something new, or tighten the document?" — before running anything.
