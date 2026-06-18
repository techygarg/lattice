---
name: learning-harvest
description: "Manage the operational learnings lifecycle — load prior learnings to inform current work, harvest new patterns worth preserving, and keep the document tight over time. Provides a protocol for accumulating actionable patterns from practice that complement standards and defaults. Use when a workflow session completes and produced insights worth persisting, when starting a session that should benefit from prior patterns, or when the user says 'harvest learnings', 'what have we learned', 'capture this pattern', 'tighten learnings', or 'operational learnings'."
---
# Learning Harvest

## Purpose

Standards define how a team intends to work. Operational learnings capture what the team discovers while doing the work — experiential knowledge that only emerges from practice.

This atom helps the user curate a single living document of cross-cutting project patterns. The AI synthesizes and proposes; the user decides what enters. Every entry is user-confirmed. Not a log. Not a report. Not auto-generated. A user-curated collection of experiential patterns.

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

1. Check `.lattice/config.yaml` for `paths.operational_learnings`
2. If found, use that file path
3. If not, use default `.lattice/learnings/operational-learnings.md`

**Backward compatibility**: If default path not found, check these legacy paths in order:
- `.lattice/learnings.md` — flat file at root
- `.lattice/learnings/review-insights.md` — prior naming convention

If found, offer migration to canonical path and format. If user declines, read as flat input but do not write to it.

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

**Active monitoring**: Once loaded, maintain a **silent harvest queue** throughout the session. When a decision or trade-off passes the cross-cutting test below, add it to the queue — do not prompt immediately.

**Cross-cutting test** — a candidate must pass BOTH before queuing:
1. It names a pattern or approach, not a feature-specific fact.
2. A developer on a completely different feature could apply it without knowing this feature's context.

If either fails — skip entirely, do not queue.

Before queuing, check against entries loaded at session start. If the same pattern already exists — skip.

**When to surface:** Surface the queue as a single batch when EITHER condition is true — not at every level or layer:
- Queue reaches 3 candidates, OR
- A major phase completes (all design levels done, a full implementation layer done)

Do not surface at every individual level approval or component completion — that is over-prompting. Once surfaced, clear the queue. Anything remaining at session end goes to Harvest.

> "I noted [N] potential harvest candidates — worth a quick review?"

**Mid-session interrupt** (rare exception): surface a single pattern immediately, outside the queue, only when it would be impossible to reconstruct by session end — a live debate that resolved unexpectedly, a library gotcha caught mid-implementation. If in doubt, queue instead.

Session-end Harvest is the primary mechanism. The queue exists to avoid losing patterns, not to generate prompts.

## Harvest Behavior

Invoked at session end. Composing workflow passes a **session context** (what kind of work happened).

**Governing principle:** The atom NEVER writes autonomously. Session-end Harvest is the primary capture event — mid-session prompting is the exception. Quality over frequency: one well-timed suggestion the user confirms is worth more than five prompts they dismiss.

**Steps**:

1. **Drain the queue.** Collect all candidates from active monitoring queue plus any new ones surfaced by reviewing session decisions and outcomes. Each candidate must have passed the cross-cutting test (active monitoring) or pass it now.

2. **Propose as a batch.** Present queued candidates together — not one per message:

   > Harvest candidates from this session:
   > 1. [Category] — [pattern in one line]
   > 2. [Category] — [pattern in one line]
   >
   > Accept, edit, add your own, or skip entirely.

   Empty queue and nothing new found? Say so in one line and stop — do not force output.

3. **Filter — apply before writing confirmed entries.** For each entry the user accepts:

   | Filter | Fail if... |
   |--------|------------|
   | **Evidence** | No concrete session event — just prior knowledge |
   | **Cross-cutting** | Specific to this feature's domain, won't recur |
   | **Actionable** | Requires this conversation's context to understand |
   | **Recurrence** | No structural reason it will happen again |

   Filter fails on a confirmed entry? Tell the user which filter — offer to reword. Do not silently drop.

4. **User decides.** Accept, edit, reject, add their own, or skip all. Do NOT argue for rejected entries.

5. **Write confirmed entries only.** Dedup against existing entries (update with recurrence note if same pattern exists). Create file/dir if needed.

6. **Assess health.** If document growing dense or entries overlap: suggest Tighten. If pattern recurred 4+ times: suggest promoting to standards. User decides — never auto-prune.

## Tighten Behavior

Triggered during Harvest (when bloat detected) or invoked standalone.

1. Read full document.
2. Identify: consolidation opportunities (same pattern, different words), noise (one-off, never recurred), promotion candidates (recurred 4+ times — suggest refiner), stale entries (project has changed).
3. Present proposals to user. Apply only what user confirms.

## Self-Validation Checklist

Before writing any entry, verify ALL. If any fails, do not write.

1. **User confirmed** — STOP: Explicit user approval for every entry. No exceptions.
2. **Evidence grounded** — STOP: Produced by a specific session event, not prior knowledge.
3. **Experiential, not prescriptive** — STOP: Reads like "what we learned" not "what the rule should be." If it's a rule, it belongs in standards via a refiner.
4. **Cross-cutting** — STOP: Applies beyond this feature. Feature-specific decisions belong in context anchor doc.
5. **Actionable standalone** — STOP: a developer on a different feature can act on this without this conversation's context. Confidence level is not a gate — the user decides if it is worth capturing.
6. **Not redundant** — STOP: Not already in standards, atom defaults, or existing learnings. At most, add recurrence note.
7. **Concise** — STOP: Scannable in 10 seconds. Two lines max.

## Integration with Other Skills

Workflows invoke **Load** at session start (with focus hint) and **Harvest** at session end (with session context). The atom never references specific workflows — it applies the protocol uniformly to whatever composes it.

Relationship to other infrastructure atoms:
- `context-anchoring` — per-feature decisions (specific). This atom — cross-feature patterns (general).
- `knowledge-priming` — project identity (static). This atom — accumulated experience (growing).
- `collaborative-judgment` — surfaces decisions in-session. This atom — preserves patterns across sessions.
