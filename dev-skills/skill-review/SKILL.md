---
name: skill-review
description: "Deep behavioral audit of a Lattice skill — proposes 3 review personas relevant to the skill, runs a full independent scenario analysis from each persona's perspective, merges all findings into a unified severity-ordered gap report, and proposes fixes. Structural validation (conventions, cross-references) is skill-validate's job — this skill finds the gaps that only emerge when someone actually uses the skill: missing scenario handling, ambiguous instructions, silent failure cases, and behavioral inconsistencies. Use after writing or significantly changing any skill, or when the user says 'review this skill', 'deep review', 'does this skill work', 'find gaps in this skill', 'stress test this skill', 'review from different angles', or 'skill review'. Standalone — does not call other skills."
---

# Skill Review

**Core responsibility:** Find behavioral gaps in a Lattice skill by reviewing it through three independent personas. Each persona sees the skill with different eyes, cares about different things, and finds different gaps. The combined findings are more complete than any single review.

**Input:** One skill path or skill name.

**Output:** A unified findings report — all gaps from all three personas merged, deduplicated, and ordered by severity — with proposed fixes.

**How to verify this skill did its job:**
- Every persona produced at least one finding (if all three say "looks fine", the review was not deep enough)
- Every gap has a specific proposed fix, not just a flag
- Overlapping findings from multiple personas are merged into one entry with a note that multiple perspectives agree
- The final report is ordered: critical gaps first, warnings second, observations last
- After fixes are applied, a second run of this skill on the same skill file shows no critical gaps

---

## Step 1: Read the skill

Read the full SKILL.md and all referenced files (defaults.md, template.md, references/).

Form a clear understanding of:
- What the skill claims to do and who uses it
- What it produces (documents, reports, code, changes)
- What its inputs are and what states they can be in
- Where it sits in the Lattice pipeline (upstream / downstream connections)

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

Generate 6–8 scenarios this persona would realistically encounter. Cover:
- The ideal case (everything is as the skill expects)
- First-time use (no existing setup, no prior knowledge)
- Resuming interrupted work (some output already exists)
- Minimal input (user provides as little as possible)
- Maximal / complex input (large scope, many items, messy material)
- The "wrong" input (material at the wrong granularity, the wrong format, a misunderstood concept)
- Declining the recommended path (user skips a suggestion and wants to proceed differently)
- Conflicting inputs (two sources that say different things)

For each scenario, follow the skill's instructions literally. Where the skill gives no guidance, that is a gap.

**3b — Persona-specific concerns**

Each persona has things they care about that others might miss:

- **A practitioner or user persona** asks: "Is this skill telling me what to do at every decision point? Or am I guessing?" Finds: gaps in decision guidance, missing error handling, ambiguous instructions.
- **A quality or standards persona** asks: "Are the rules here enforceable? Can I tell pass from fail?" Finds: vague criteria, missing boundary conditions, rules that contradict each other.
- **A technical or architectural persona** asks: "Does this compose correctly? Does it stay in its lane?" Finds: missing cross-references, scope bleed, broken upstream/downstream handoffs, missing resume logic.
- **A product or output persona** asks: "Is what this produces actually useful?" Finds: incomplete outputs, missing connections to the next pipeline step, unexplained results.
- **A new-user persona** asks: "Would I know what to do without reading the whole framework?" Finds: assumed knowledge, missing context, jargon without definition.
- **A maintainer persona** asks: "Will this skill drift or break as Lattice grows?" Finds: hardcoded lists that will become stale, missing dynamic inventory reads, tightly coupled assumptions.

**3c — Record findings for this persona**

Format each finding:
```
[Persona: {name}]
Scenario: {which scenario surfaced this}
Type: CRITICAL | WARNING | OBSERVATION
Gap: {what the skill is silent about or handles incorrectly — specific}
Fix: {specific addition or change to the SKILL.md — exact enough to write}
```

---

## Step 4: Merge and deduplicate

After all three personas have completed their analysis:

1. **Collect** all findings across all three personas
2. **Merge** findings that describe the same gap from different angles — combine into one entry, note which personas agree: `(Found by: Persona A, Persona C)`
3. **Deduplicate** — if two findings are about the same issue, keep the most specific one and note the overlap
4. **Order** by severity: CRITICAL first, then WARNING, then OBSERVATION
5. **Count** totals: how many critical gaps, warnings, observations; how many were found by multiple personas (these are the highest-confidence findings)

---

## Step 5: Present the unified report

```
## Skill Review — {skill-name}
Personas: {Persona A} | {Persona B} | {Persona C}

### Critical Gaps (must fix before using this skill)

GAP-1: {gap title}
Found by: {Persona A, Persona C}
Scenario: {which scenario surfaced it}
Problem: {what the skill is silent about or handles incorrectly}
Fix: {specific change}

GAP-2: ...

### Warnings (should fix — will cause confusion or inconsistency)

WARN-1: ...

### Observations (consider — not blocking)

OBS-1: ...

---
Summary: {N} critical, {M} warnings, {P} observations
Highest-confidence findings (multiple personas agree): GAP-1, WARN-2
Recommended fix order: [ordered list]
```

Ask: *"Which findings should I fix? Recommend starting with the critical gaps — especially those multiple personas agree on."*

---

## Step 6: Apply agreed fixes

For each confirmed fix:
- Make the minimal change that addresses the gap — do not rewrite surrounding content
- After each edit, state: what changed, which gap it closes, which persona(s) raised it
- Do not fix warnings or observations unless the user explicitly asks

After all fixes: present a brief closure summary — gaps closed, gaps deferred, what a second run of this skill would likely find.
