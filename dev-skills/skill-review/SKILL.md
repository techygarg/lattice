---
name: skill-review
description: "Deep behavioral audit of a Lattice skill — proposes 3 review personas relevant to the skill, runs independent scenario analysis from each persona's perspective, then merges only the high-confidence, practical findings into a severity-ordered gap report with proposed fixes. Structural validation (conventions, cross-references) is skill-validate's job — this skill finds gaps that would realistically surface when someone actually uses the skill: missing scenario handling, ambiguous instructions, silent failure cases, and behavioral inconsistencies. Filters out theoretical edge cases, low-likelihood speculation, and findings owned by other skills. Use after writing or significantly changing any skill, or when the user says 'review this skill', 'deep review', 'does this skill work', 'find gaps in this skill', 'stress test this skill', 'review from different angles', or 'skill review'. Standalone — does not call other skills."
---

# Skill Review

**Core responsibility:** Find real behavioral gaps in a Lattice skill by reviewing it through three independent personas. Each persona sees the skill with different eyes, cares about different things, and may surface different gaps. The combined findings should be more practical and complete than any single review.

**Input:** One skill path or skill name.

**Output:** A unified findings report — only the high-confidence, practical gaps from all three personas, merged, deduplicated, pruned, and ordered by severity — with proposed fixes.

**Review standard:** Prefer omission over speculation. Only report findings you are highly confident would surface in normal use, belong to this skill's responsibility, and would materially improve outcomes if fixed. A valid review may conclude that no material practical gaps remain.

**How to verify this skill did its job:**
- Every reported finding is grounded in a realistic scenario and tied to specific evidence in the skill
- Zero findings is acceptable if no high-confidence practical gaps remain
- Every gap has a specific proposed fix, not just a flag
- Overlapping findings from multiple personas are merged into one entry with a note that multiple perspectives agree
- Multiple personas agreeing raises confidence only after the finding survives the practicality filter
- The final report is ordered: critical gaps first, warnings second, observations last — or explicitly says no material practical gaps were found
- After fixes are applied, a second run of this skill on the same skill file shows no high-confidence practical gaps

---

## Step 1: Read the skill

Read the full SKILL.md and all referenced files (defaults.md, template.md, references/).

Form a clear understanding of:
- What the skill claims to do and who uses it
- What it produces (documents, reports, code, changes)
- What its inputs are and what states they can be in
- Where it sits in the Lattice pipeline (upstream / downstream connections)

If the skill is composed by molecules, consumes refiner output, or depends on other skills, read the relevant upstream/downstream files too. Review against actual runtime usage, not an imagined standalone use case.

---

## Step 2: Propose 3 review personas

Based on what the skill does and who it serves, propose 3 personas whose perspectives would surface the most useful gaps.

**Persona selection logic:**

| If the skill... | Consider personas like... |
|---|---|
| Is a molecule used by product/BA people | Senior PM, Business Analyst, Lead Developer consuming the output |
| Is an atom enforcing code quality | Code reviewer, Junior developer following the rules, Architect checking for structural gaps |
| Is a refiner configuring standards | Team lead setting standards, New team member onboarding, AI assistant consuming the standards doc |
| Is a dev-tool skill (forge, validator, sync) | Lattice maintainer, First-time skill creator, Experienced developer new to Lattice |
| Spans product + technical audiences | One product persona, one practitioner persona, one technical persona |

Present 3 proposed personas with a one-line rationale for each:

*"For [skill-name], I'd review from these three perspectives:*
*1. [Persona A] — because [why this skill matters to them / what they'd be looking for]*
*2. [Persona B] — because [different angle this persona brings]*
*3. [Persona C] — because [third angle, ideally the consumer of the skill's output]*

*Want to use these, swap any out, or add your own?"*

Wait for the user to confirm or adjust before proceeding.

**Do NOT proceed to Step 3 until personas are agreed.**

---

## Step 3: Persona analysis (run all three independently)

For each persona in sequence, fully inhabit that perspective. Forget the other personas while you are in one.

### For each persona, run this analysis:

**3a — Scenario generation**

Generate the smallest realistic set of scenarios needed to stress this skill (typically 4–6; do not force all scenario types). Consider:
- The ideal case (everything is as the skill expects)
- First-time use (no existing setup, no prior knowledge)
- Resuming interrupted work (some output already exists)
- Minimal input (user provides as little as possible)
- Maximal / complex input (large scope, many items, messy material)
- The "wrong" input (material at the wrong granularity, the wrong format, a misunderstood concept)
- Declining the recommended path (user skips a suggestion and wants to proceed differently)
- Conflicting inputs (two sources that say different things)

Use only the scenarios that genuinely apply to this skill. Skip any case that does not fit. Better 4 relevant scenarios with real findings than 8 forced scenarios with speculative ones.

For each chosen scenario, follow the skill's instructions literally. Treat silence as a gap only if ALL are true:
- The scenario is realistic in normal use
- The decision belongs to this skill rather than another skill or pipeline stage
- The missing guidance would likely cause a real failure, confusion, or drift

If any of these are false, do not record a finding.

**3b — Persona-specific concerns**

Use these as attention prompts, not finding quotas. They help you notice classes of problems; they do not guarantee that a real finding exists.

Each persona has things they care about that others might miss:

- **A practitioner or user persona** asks: "Is this skill telling me what to do at every decision point? Or am I guessing?" May surface: gaps in decision guidance, missing error handling, ambiguous instructions.
- **A quality or standards persona** asks: "Are the rules here enforceable? Can I tell pass from fail?" May surface: vague criteria, missing boundary conditions, rules that contradict each other.
- **A technical or architectural persona** asks: "Does this compose correctly? Does it stay in its lane?" May surface: missing cross-references, scope bleed, broken upstream/downstream handoffs, missing resume logic.
- **A product or output persona** asks: "Is what this produces actually useful?" May surface: incomplete outputs, missing connections to the next pipeline step, unexplained results.
- **A new-user persona** asks: "Would I know what to do without reading the whole framework?" May surface: assumed knowledge, missing context, jargon without definition.
- **A maintainer persona** asks: "Will this skill drift or break as Lattice grows?" May surface: hardcoded lists that will become stale, missing dynamic inventory reads, tightly coupled assumptions.

**3c — Record findings for this persona**

Before recording any finding, run this filter:

1. **Evidence** — Can you point to the exact line, section, or instruction causing the problem?
2. **Practicality** — Would this likely happen in a real session with a real user?
3. **Ownership** — Is the reviewed skill actually responsible for preventing or handling it?
4. **Materiality** — Would fixing it materially improve outcomes?
5. **Confidence** — Are you at least 90% confident this is a real gap?

If any answer is "no", drop the finding. Mere possibility is not enough.

Format each finding:
```
[Persona: {name}]
Scenario: {which realistic scenario surfaced this}
Evidence: {exact line/section/instruction that supports the gap}
Type: CRITICAL | WARNING | OBSERVATION
Gap: {what the skill is silent about or handles incorrectly — specific}
Fix: {specific addition or change to the SKILL.md — exact enough to write}
Confidence: {90%+ and why}
```

---

## Step 4: Merge and deduplicate

After all three personas have completed their analysis:

1. **Collect** all findings across all three personas
2. **Merge** findings that describe the same gap from different angles — combine into one entry, note which personas agree: `(Found by: Persona A, Persona C)`
3. **Deduplicate** — if two findings are about the same issue, keep the most specific one and note the overlap
4. **Prune** using this filter:
   - **Practicality**: would this happen in normal use?
   - **Predictability**: is it likely enough to recur, not a stacked chain of unlikely events?
   - **Ownership**: is the reviewed skill actually responsible?
   - **Materiality**: would fixing it materially improve outcomes?
   - Mere possibility is insufficient — discard purely theoretical findings
5. **Reassess confidence** — multiple personas agreeing raises confidence only after pruning; agreement alone does not make a finding real
6. **Order** by severity: CRITICAL first, then WARNING, then OBSERVATION
7. **Count** totals: how many retained critical gaps, warnings, observations; how many were corroborated by multiple personas

---

## Step 5: Present the unified report

Severity definitions:
- **CRITICAL** — likely in normal use and materially blocks, misdirects, or invalidates the skill's intended outcome
- **WARNING** — practical issue likely to cause confusion, inconsistency, drift, or degraded output
- **OBSERVATION** — real but lower-impact improvement; omit if speculative, trivial, or unlikely

Do not force every severity bucket to be non-empty. It is valid to report zero observations, zero warnings, or no findings at all.

```
## Skill Review — {skill-name}
Personas: {Persona A} | {Persona B} | {Persona C}

If no retained findings remain after pruning:

No material practical gaps found. The skill appears ready for use as written.

Otherwise present:

### Critical Gaps (must fix before using this skill)

GAP-1: {gap title}
Found by: {Persona A, Persona C}
Scenario: {which scenario surfaced it}
Evidence: {exact line/section/instruction}
Problem: {what the skill is silent about or handles incorrectly}
Fix: {specific change}
Confidence: {90%+ and why}

GAP-2: ...

### Warnings (should fix — will cause confusion or inconsistency)

WARN-1: ...

### Observations (consider — not blocking)

OBS-1: ...

---
Summary: {N} critical, {M} warnings, {P} observations
Highest-confidence findings (after pruning and corroboration): GAP-1, WARN-2
Recommended fix order: [ordered list]
```

If findings remain, ask: *"Which findings should I fix? Recommend starting with the critical gaps — especially those that are both practical and corroborated."*

If no findings remain, state that no fixes are recommended and stop.

---

## Step 6: Apply agreed fixes

For each confirmed fix:
- Make the minimal change that addresses the gap — do not rewrite surrounding content
- After each edit, state: what changed, which gap it closes, which persona(s) raised it
- Do not fix warnings or observations unless the user explicitly asks

After all fixes: present a brief closure summary — gaps closed, gaps deferred, what a second run of this skill would likely find.
