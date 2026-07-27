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

**Main document**:

1. Check `.lattice/config.yaml` for `paths.operational_learnings`
2. If found, use that file path
3. If not, use default `.lattice/learnings/operational-learnings.md`

**Archive document** — the sink for long-form narrative moved out of the main document:

1. Check `.lattice/config.yaml` for `paths.operational_learnings_archive`
2. If found, use that file path
3. If not, default to `operational-learnings-archive.md` as a sibling of the resolved main document — a custom main path carries the archive with it
4. Resolve lazily. **STOP: do not create the archive until something is actually being moved into it.**

**STOP: never read the archive during Load Behavior.** Archived narrative is retrieval-on-demand, on a specific question. Loading it back into session context defeats the reason it was moved.

**Backward compatibility**: If default path not found, check these legacy paths in order:
- `.lattice/learnings.md` — flat file at root
- `.lattice/learnings/review-insights.md` — prior naming convention

If found, offer migration to canonical path and format. If user declines, read as flat input. **STOP: do not write to it.**

**Declined-migration fallback** — where writes go when a legacy file is in use:

1. Writes go to the canonical path resolved above, never to the legacy file. Create file and directory if absent.
2. The legacy file is read-only for the whole session — Load reads it, dedup reads it, nothing writes it.
3. Dedup (Harvest Step 5) checks BOTH the canonical file and the declined legacy file. **STOP: skipping the legacy file here re-captures patterns the user already has.**
4. Health assessment (Harvest Step 6) sizes both files together — the user pays context for both.
5. **STOP: do not re-offer migration in the same session.** Declined once is declined until the user raises it.

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

5. **Write confirmed entries only.** Write to the resolved main document — with a declined legacy file in play, that is the canonical path, never the legacy file (see Config Resolution). Dedup against existing entries in the main document and in any declined legacy file (update with recurrence note if same pattern exists). Create file/dir if needed.

6. **Assess health — size first, count second.** What this protects is context-window tokens: every composing molecule loads this document at session start, so the team pays bytes, not bullets. Ten sprawling entries cost more than forty tight ones. Size is the primary signal; counts are secondary.

   Take the main document's size on disk — already read for dedup in Step 5, no extra cost. Size unavailable? Approximate as total entries × average entry length. Add any declined legacy file (see Config Resolution).

   | Signal | Soft — flag | Hard — STOP |
   |---|---|---|
   | **Document size** (primary) | ~40KB | ~80KB |
   | **Entries in one category** (secondary) | ~10 | ~20 |
   | **Total entries** (secondary) | ~35 | ~70 |

   **Soft threshold — flag only.** Any signal crosses its soft column → note in one line: "Operational learnings is at [size] — say 'tighten learnings' to run Tighten standalone." Pattern recurred 4+ times → note it as a promotion candidate the same way. **STOP: do not run Tighten in this session** — flag only, never act.

   **Hard threshold — a sequencing gate on you, not a question for the user.** Any signal crosses its hard column → the main document comes back under its soft threshold before the molecule closes. Do it now, in this session:

   1. Take the longest entries in the main document — the ones carrying narrative, incident retelling, or a reasoning trail.
   2. Move that narrative to the archive document (path per Config Resolution, format per Tighten Behavior Step 2). Keep rule + discriminator in the main document with a back-reference.
   3. Re-measure. Still over soft → repeat on the next-longest entries.
   4. Report in one line: "Moved narrative from [N] entries to [archive path] — main document [old size] → [new size]."

   **STOP: relocation only — never deletion, consolidation, or promotion.** Moving narrative to the archive loses nothing, so it needs no approval. Dropping or merging an entry does, and stays a per-candidate judgment call the user makes in Tighten.

   **STOP: do not ask permission and do not wait for the user.** Harvest is not a confirmation gate — this is a step you finish before the molecule moves on, the same way Harvest itself runs before the molecule's closing recommendation.

   **STOP: do not run Tighten here either.** After relocating, if the document is still dense with overlapping entries, flag Tighten as due exactly as the soft threshold does.

## Tighten Behavior

Invoked standalone only — Harvest may flag that tightening is due, but never launches it.

1. Read full document.
2. Identify candidates:

   | Candidate | Signal | Disposition |
   |---|---|---|
   | **Consolidation** | Same pattern, different words, across entries | Merge into one entry |
   | **Noise** | One-off, never recurred | Remove |
   | **Promotion** | Recurred 4+ times | Suggest the relevant refiner — it has become a rule |
   | **Stale** | Project has changed, entry no longer describes it | Remove |
   | **Archive** | Entry runs past the two-line format — carries narrative, incident detail, or a reasoning trail | Move the narrative to the archive document; keep rule + discriminator in the main document |

   **Archive is the destination for length, not for irrelevance.** An entry still earning its place but too long to sit in a document loaded every session belongs in the archive, not the noise pile — removing it loses the reasoning, archiving keeps it retrievable.

   **Archive entry format** — same category headings as the main document:

   ```markdown
   ## [Category]

   ### YYYY-MM-DD [context] Pattern
   [Narrative: what happened, what was tried, what the debate was, why it resolved this way.]
   ```

   The main document keeps the standard bullet plus a back-reference:

   `- YYYY-MM-DD [context] Pattern — actionable takeaway ([detail](operational-learnings-archive.md#anchor))`

   **STOP: the main-document bullet must stand alone without the archive.** Rule plus discriminator — what to do, and the condition that tells a reader it applies to them. A bullet that only makes sense after opening the archive is not tightened, just truncated.

3. Present each candidate individually — consolidation, noise, promotion, staleness, and archiving are different judgment calls. Accept / edit / reject per candidate, not as one batch.
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

## Standalone Invocation

When invoked directly — not composed by a molecule — match the user's phrase to exactly one behavior. **STOP: if ambiguous, ask — never guess.**

| User says | Run |
|---|---|
| "tighten learnings", "compress learnings", "clean up learnings", "/learning-harvest tighten learnings" | Tighten Behavior |
| "harvest learnings", "capture this pattern", "log this learning" | Harvest Behavior |
| "what have we learned", "load learnings", bare "operational learnings" with no verb | Load Behavior |

**STOP: if the phrase doesn't clearly map to one row, ask** — "Load recent entries, harvest something new, or tighten the document?" — before running anything.
