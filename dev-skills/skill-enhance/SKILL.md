---
name: skill-enhance
description: "Full enhancement pipeline for an existing Lattice skill — rewrites a molecule or atom to modern-capable-model grade: restores degraded grammar, deduplicates, hardens gates and branching to one-unambiguous-action precision, verifies zero behavioral loss against a pre-capture diff, then runs the combined QA gate (skill-review, skill-tighten, skill-validate) and an independent fresh-context verifier, fixing everything found. Consumer-first: optimized for first-time open-source users on fresh repos with minimal .lattice/ setup, running capable models. Use when the user says 'enhance this skill', 'upgrade this molecule', 'modernize this skill', 'optimize this skill', 'make this skill production grade', 'full enhancement', 'polish this molecule like design-blueprint', or names a molecule/atom to overhaul. For gap-finding only use skill-review; for conventions only use skill-validate — this skill runs the whole loop end to end."
---

# Skill Enhance

**Core responsibility:** Take one existing Lattice skill from current state to modern-capable-model grade through a fixed pipeline: baseline → dependency map (background agent) → precision rewrite with guaranteed behavior preservation → combined three-skill QA → independent verification. The skill being enhanced must end up smaller-or-equal in redundancy, fully grammatical, convention-complete, and provably non-regressive. Organizing objective: **deterministic execution** — every sentence has exactly one reading, every reachable state exactly one action, every cross-file reference literally true. Acceptance test: two different capable models reading any sentence would act identically on it.

**Input:** One skill path or name (any tier). Molecules are the primary case.

**Output:** Edited files + close-out report.

**STOP: NEVER commit, push, stash, checkout, reset, or run `build-codex-plugin.sh`. Working tree only — surface install/mirror commands for the user instead.**

**How to verify this skill did its job:**
- Pre-capture git diff exists; every preserved behavior in it is confirmed present after rewrite
- QA trio re-run returns no critical gaps, CLEAN or tightened-only results, and PASS
- Independent verifier reports zero real defects
- Scenario walk leaves no branch with two possible readings

## Step 1: Scope and baseline

1. Read PROJECT.md (single source of truth for conventions) and the target SKILL.md in full.
2. Classify: tier (atom / molecule / refiner); if molecule, its type per PROJECT.md — **generative** (`code-forge`, `refactor-safely`, `bug-fix`) or **planning/interactive** (`design-blueprint`, `architecture-compass`). This governs every later rule: never transplant confirmation gates into generative molecules, never strip them from planning ones.
3. **STOP: capture the full git diff of target + likely-touched files BEFORE any edit**, written to a temp file whose path you will hand to the Step 5 verifier. This baseline is the preservation oracle for Steps 3-5. Without it, "did we drop anything?" is unanswerable.

## Step 2: Dependency map (background agent)

Spawn ONE background Explore agent — do not read serially in the main thread. It maps:

1. Every `framework:{atom}` reference: real behavior/mode names each atom actually exposes, plus line counts.
2. Sibling molecules feeding and consuming this one: exact handoff contracts — frontmatter fields, status values, `.lattice/{subfolder}` paths, section names each side greps for.
3. Where the target's phases/levels are actually defined (own body vs referenced atom).
4. Inventory of telegraphic damage: sentences missing articles/verbs ("ground decisions real project").

## Step 3: Rewrite (main thread, after map returns)

Apply in order:

1. **Grammar restoration** — every sentence complete. Telegraphic phrasing is ambiguity risk precisely at STOP/gate semantics.
2. **Deduplicate** — same rule twice in different words → keep the sharpest once. Cut trailing rationale ("this ensures…", "without this…") EXCEPT consequences load-bearing at the exact action point — flag every deliberate keep in the report.
3. **Precision pass** — hard gates get `**STOP:**` prefixes; targeted questions replace generic approval language; every conditional branch (missing doc, unreadable path, external reference, absent config, outputs created by older skill versions missing newer fields) resolves to exactly ONE action; expected-not-error paths marked as such.
4. **Scenario walk your own rewrite**: fresh start / interrupted session / partial output / minimal input / maximal input / entry-and-resume edges (including partial entry points and legacy docs without new markers). Derive the state space from upstream contracts first — enumerate every status value, mode name, and doc-presence combination the upstream defines, and give each a defined outcome here. Close every gap where two readings survive.
5. **Preservation check against the Step 1 baseline** — nothing dropped, renamed, or weakened.
6. **Contract alignment** — verify every referenced behavior name, section heading, table schema, config key, and status value against the live atom files; fix mismatches even when pre-existing. Composition must interlock literally, not approximately.
7. **Convention restoration** — always/conditional qualifiers on Required Skills, collaborative-judgment fallback wording in Ambiguity Signals, trigger phrases in description, description consistent with body.
8. If the skill repurposes a code-generation atom in another mode: give that atom a compact named mode section. Never improvise inline; never inline atom content into a molecule.

## Step 4: Combined QA gate (strict order)

Run on every touched file:

1. **skill-review** — fix criticals and warnings; list observations for the user decision.
2. **skill-tighten** — full T1-T6 sweep, apply.
3. **skill-validate** — fix error-level findings directly; report warnings without applying.

Iterate until all three return clean/pass. Re-run any skill whose inputs a later fix changed.

## Step 5: Independent verification (background agent)

Spawn ONE fresh general-purpose verifier that re-derives correctness WITHOUT trusting the diff author:

- Semantic-preservation checklist from the Step 1 baseline
- Internal-consistency scenario walk (Step 3.4 scenarios, independently)
- Contract checks against the real consumer files — grep them, cite lines
- Hedge/degraded-grammar grep across touched files
- Frontmatter YAML validity, name/folder match

Fix everything it finds. Then: behavior-affecting fixes → re-run the affected Step 4 tools; single-line narrowing fixes → self-check against the loaded T1-T6/validator patterns instead of a full re-run.

## Step 6: Close-out report

Report: files changed with before→after line counts; findings per QA tool and how each closed; deliberate keeps flagged; residual validator warnings listed untouched; and these commands surfaced for the user (not run):

```bash
./tools/install.sh <your-tool>/skills/   # smoke-test the skill loads
./tools/build-codex-plugin.sh            # refresh Codex mirror before committing
```
