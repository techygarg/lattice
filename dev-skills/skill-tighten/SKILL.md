---
name: skill-tighten
description: "Audit any Lattice SKILL.md for language compliance — removes rationale prose, converts soft language to imperatives, adds STOP: gates on hard rules, and cuts redundant repetition. Complements skill-review (which finds behavioral gaps) by fixing phrasing that causes agents to skip or underweight instructions at runtime. Use after writing or significantly changing any skill, or when the user says 'tighten this skill', 'clean up the language', 'make this more effective', 'reduce the bloat', 'tighten the language', or 'skill tighten'. Standalone — does not call other skills."
---

# Skill Tighten

**Core responsibility:** Fix language that causes agents to skip or underweight instructions. Not behavioral gaps — that is `skill-review`'s job. Only phrasing: rationale prose, soft language, missing enforcement signals, redundant repetition.

**Input:** One or more of:
- A file path: `skills/atoms/clean-code/SKILL.md`
- A skill name: `clean-code` (resolves to the correct path automatically)
- A tier: `atoms` (tightens all skills in that tier)
- No argument: tightens all skills across all tiers

**Output:** Edited files + a report per skill:
```
## skill-tighten — {skill-name}
Lines: {before} → {after}
Changes:
1. {what changed} — {one-line reason}
2. ...
Result: TIGHTENED ({N} changes) | CLEAN (no changes needed)
```

**How to verify this skill did its job:**
- Every cut section had zero commands — only rationale
- Every softened phrase was "consider / think about / you may want to / it is recommended"
- Every added STOP: was on a hard rule that previously had no enforcement signal
- No rule, gate, checklist item, or branching logic was removed
- Re-running after edits returns CLEAN

---

## Step 1: Read the skill

Read the full SKILL.md. Also read all sibling files: `references/defaults.md`, `references/methodology-detail.md`, `assets/template.md`, or any file referenced by a `Read` instruction in the skill body.

Do not edit yet — complete the full audit first.

---

## Step 2: Apply the tighten checklist

For each item, scan the entire file. Mark every instance found — do not stop at the first.

### T1 — Non-actionable sections

Sections that explain why the skill exists, describe the problem, or narrate context without issuing a single command. Cut the entire section. Preserve the pointer to a referenced file if one exists.

Patterns that always qualify:
- Section titled "Core Principle", "Purpose", "Problem", "Background", "Why This Matters", "How It Is Used", "Integration with Other Skills"
- Opening paragraph before a numbered list that restates what the numbered list will do
- Closing paragraph after a gate that explains what happens if the gate were skipped

**Pass:** Section contains at least one imperative instruction (do, read, write, verify, check, apply, stop, flag).
**Fail:** Section contains only declarative statements, rationale, or scope commentary.

### T2 — Soft language

Words and phrases that agents treat as optional:

| Pattern | Replace with |
|---|---|
| `consider X` | `X` (imperative) or remove |
| `think about X` | remove |
| `you may want to X` | remove |
| `it is recommended to X` | `X` |
| `should` (as soft suggestion) | `must` or remove |
| `try to X` | `X` |
| `where possible, X` | `X` or remove |

**Pass:** Instruction is an imperative verb with no hedging qualifier.
**Fail:** Instruction contains any of the patterns above.

### T3 — Missing STOP: gates

Hard rules that must not be skipped — gates on advancing to next steps, checklist preambles, non-negotiable constraints — stated as bold prose without a `**STOP:**` prefix.

**Pass:** Hard gate reads `**STOP:**` as the first token of its line or sentence.
**Fail:** Hard gate is phrased as "Do NOT...", "Never...", "Always verify...", "Must not..." without the STOP: prefix.

Add `**STOP:**` prefix. Do not rewrite the instruction itself.

### T4 — Redundant repetition

The same point stated twice in different words. Keep the sharper version; cut the other.

Patterns:
- Section heading restated in the section's opening sentence
- Instruction followed by a sentence explaining what the instruction means
- Rationale sentence after a clear gate ("Without this, X would happen")
- Same rule in two adjacent bullets

**Pass:** Each statement appears once in its sharpest form.
**Fail:** Two sentences convey the same instruction or the same constraint.

### T5 — Table column bloat

Columns whose content explains why a trigger exists, rather than being the trigger.

Common offenders: columns titled "Why", "Reason", "Rationale", "Because", "Notes" in a table whose other columns already encode the actionable information.

**Pass:** Every column in the table is actionable — the agent does something with it.
**Fail:** A column contains only explanatory prose the agent reads but cannot act on.

Drop the column. Do not drop the row.

### T6 — Trailing rationale sentences

Sentences appended to a clear instruction that explain why the instruction exists. The instruction is already sufficient — the explanation adds tokens without adding compliance.

Patterns:
- "Without this, agents will X"
- "This ensures that X"
- "This is because X"
- "X is important because Y"
- Any sentence beginning with "This" that follows a complete imperative

**Pass:** Instruction ends at the action. No trailing explanation.
**Fail:** Instruction is followed by a sentence that begins with "This", "Without", "Because", or restates the consequence of not following the instruction.

---

## Step 3: Make edits

Apply all findings. Edits in order of checklist item (T1 first, T6 last) — structural cuts before phrasing fixes.

Rules:
- Cut sections entirely when T1 applies — do not rephrase them
- Add `**STOP:**` as a prefix — do not rewrite the surrounding instruction
- Do not remove checklist items, branching logic, gates, or output format specifications
- Do not restructure sections — targeted cuts and additions only
- If a T1 section contains one buried imperative, extract that line and discard the section wrapper

---

## Step 4: Report

After all edits:

```
## skill-tighten — {skill-name}
Lines: {before} → {after} ({delta})
Files changed: SKILL.md [, defaults.md, ...]

Changes:
1. [T1] Cut "{section name}" — no commands, pure rationale
2. [T3] Added STOP: to "{rule}" — was bold prose, now enforced gate
3. [T5] Dropped "Reason" column from {table name} — rationale, not instruction
...

Result: TIGHTENED ({N} changes)
```

If no changes needed:
```
Result: CLEAN — no language compliance issues found
```
