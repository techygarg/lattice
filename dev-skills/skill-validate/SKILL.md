---
name: skill-validate
description: "Validate any Lattice SKILL.md against all tier conventions — atoms, molecules, and refiners. Catches structural errors, broken cross-references, and convention violations before they reach the repo. If you just wrote or modified a Lattice skill file and haven't run this yet, run it now — manual review consistently misses the same categories of errors this skill is specifically designed to catch. Use when the user says 'validate this skill', 'check this skill', 'does this follow conventions', 'review this skill file', 'check my SKILL.md', or 'skill validate'. Reports PASS/FAIL with specific file-and-section findings and actionable fixes. Standalone — does not call other skills."
---

# Skill Validator

**Core responsibility:** Verify that a SKILL.md is structurally correct, follows all Lattice tier conventions, and composes correctly with the rest of the framework.

**Input:** One or more of:
- A file path: `skills/atoms/clean-code/SKILL.md`
- A skill name: `clean-code` (resolves to the correct path automatically)
- A tier: `atoms` (validates all skills in that tier)
- No argument: validates all skills across all three tiers (count derived from `skills/` at runtime — never hardcoded)

**Output:** A findings report per skill:
```
## Skill Validator — {skill-name}
Tier: {atom | molecule | refiner}

### Structural          PASS / FAIL — specific findings
### Tier conventions    PASS / FAIL — specific findings
### Cross-references    PASS / FAIL — specific findings
### Three-angle review  PASS / WARN / FAIL per lens

Result: PASS | FAIL (N errors, M warnings)
```

**How to verify this skill did its job:**
- Every finding references a specific file and section (no vague "missing content" — says exactly what is missing and where)
- FAIL findings have an actionable fix, not just a description of the problem
- The report distinguishes errors (must fix) from warnings (judgment calls)
- After "fix mode" is applied, re-running the validator returns PASS

Validates one or more Lattice SKILL.md files against all conventions. Always reads conventions from `CLAUDE.md` — never from memory.

## Step 1: Load conventions

Read `CLAUDE.md` — Skill Conventions section. This is the source of truth. Do not rely on memory.

Read `references/convention-rules.md` for the detailed per-tier checklist.

## Step 2: Run structural checks (all tiers)

For every SKILL.md being validated:

```
[ ] Frontmatter: name field present, lowercase-hyphenated
[ ] Frontmatter: description field present and non-empty
[ ] Frontmatter: description contains trigger phrases (what the user would type)
[ ] Folder name matches name field exactly
[ ] No inline atom content in molecules (no duplicating what framework:{atom} already provides)
```

## Step 3: Run tier-specific checks

Read `references/convention-rules.md` for the full per-tier checklist. Apply the relevant section based on tier (determined from file path: atoms/, molecules/, refiners/).

## Step 4: Run cross-reference checks

For every `framework:{atom-name}` reference in a molecule:
```bash
ls skills/atoms/{atom-name}/SKILL.md 2>/dev/null || echo "BROKEN REF: framework:{atom-name}"
```

For every `paths.{key}` config key referenced in a refiner or atom:
- Check it appears in `docs/configuration.md` paths table

For every `.lattice/{subfolder}/` path referenced in a molecule:
- Check that subfolder is in the known subfolders list in `CLAUDE.md`

## Step 5: Three-angle structural review

These three lenses are fixed — they match the three stakeholder types who depend on Lattice skills working correctly. This is a structural review (does the skill follow conventions?), not a behavioral review (does it work in practice?) — use `skill-review` for the latter.

Each lens asks a different question:

**Product Owner lens** — "Will this produce the right output for its users?"
- If a molecule: does the output document structure (from the SKILL.md template) give a PO a clear picture of what was produced?
- If an atom: are the quality checks grounded in real user need, not just technical form?
- If a refiner: does the produced standards document solve the configuration problem the user has?

**Business Analyst / Practitioner lens** — "Are the rules complete and enforceable?"
- Are checklists specific enough to have a clear pass/fail for each item?
- Are anti-patterns named with a fix, not just a symptom?
- Are ambiguity signals genuinely ambiguous, or are they just gaps in the rules?
- For molecules: are all practical scenarios handled (fresh start, existing material, interrupted session, single-item request)?

**Technical Lead lens** — "Does this compose correctly with the rest of the framework?"
- Do atom references (`framework:{name}`) resolve to real skills?
- Do config keys follow snake_case and match what's in configuration.md?
- Does the molecule write to a named `.lattice/` subfolder (never root)?
- For planning molecules: is the session resume check present at Step 1?
- For generative molecules: are there no confirmation gates?

## Step 6: Report

Format findings as:

```
## Skill Validator — {skill-name}
Tier: {atom | molecule | refiner}

### Structural
PASS — all structural checks clean

### Tier conventions
FAIL — [Atom] Self-Validation Checklist missing STOP language on check 3
FAIL — [Molecule] Planning molecule Step 2 has no confirmation gate

### Cross-references
PASS — all framework: references resolve

### Three-angle review
[PO]   PASS
[BA]   WARN — Scenario: no guidance for interrupted session (resume behavior)
[Tech] FAIL — .lattice/myoutput/ is not in CLAUDE.md known subfolders list

---
Result: FAIL (2 errors, 1 warning)
Fix errors before writing to the repo. Warnings are judgment calls.
```

Distinguish errors (must fix) from warnings (should consider).

## Step 7: Fix mode (optional)

If the user says "fix it" or "apply fixes" — apply all error-level findings directly to the files. Re-run validation after fixes. Do not fix warnings without asking which ones to apply.
