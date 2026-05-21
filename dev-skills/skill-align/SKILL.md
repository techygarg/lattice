---
name: skill-align
description: "Audit and fix all Lattice documentation, README, docs/, GitHub issue templates, and CLAUDE.md to ensure they are fully aligned with the current skill inventory. Documentation drift is the most common source of user confusion in Lattice — a skill exists in the codebase but not in the docs, or a renamed skill leaves a stale reference in the bug report template. If you've made any change to skills/ and haven't run this, run it now. Use when the user says 'align docs', 'audit docs', 'update documentation', 'skill align', 'check docs are in sync', 'audit skill inventory', 'ensure docs are aligned', 'are the docs up to date', or 'what needs updating'. Standalone — does not call other skills."
---

# Lattice Sync

**Core responsibility:** Keep every public-facing document in sync with the actual skill inventory. The skills directory is the source of truth — all documents derive from it.

**Input:** None required. Reads the live state of `skills/` and all documentation on every run. Optionally: a specific skill name or tier to focus the audit.

**Output:**
- A findings report listing every gap as `[GAP]`, `[STALE]`, or `[WRONG]` with file and description
- All found gaps fixed in-place across: `README.md`, `docs/how-it-works.md`, `docs/configuration.md`, `docs/practical-guide.md`, `CLAUDE.md`, `.github/ISSUE_TEMPLATE/bug_report.yml`
- A final clean confirmation: "No gaps found" or a list of what was changed

**How to verify this skill did its job:**
```bash
grep -rn "requirements atom\|framework:requirements\b" \
  docs/ README.md CLAUDE.md .github/ skills/ \
  --include="*.md" --include="*.yml"
```
Any result from this grep means the sync is incomplete. A clean run returns no output.

Also verify: every skill in `skills/` appears in the bug_report.yml dropdown and the how-it-works.md inventory tables.

## When to run

- After creating any new atom, molecule, or refiner
- After renaming or removing a skill
- After changing a skill's config key, consumed-by relationships, or output path
- When a user suspects docs are out of date

## Phase 1 — Build the live inventory

Read the skills directory tree. Do NOT assume you already know the inventory — always read from files.

```bash
find skills/ -name "SKILL.md" | sort
```

For each SKILL.md found, extract:
- `name:` field (frontmatter)
- `tier:` inferred from path (`atoms/`, `molecules/`, `refiners/`)
- Config key: grep for `paths\.\w+` in the file
- Consumes: grep for `framework:` references (molecules only)
- Produces: grep for `.lattice/standards/` path (refiners only)
- Output subfolder: grep for `.lattice/\w+/` paths (molecules only)

Build a structured inventory:
```
atoms:    [name, config_key, has_refiner, has_defaults_md]
molecules: [name, composes[], output_subfolder]
refiners:  [name, config_key, produces_path, consumed_by_atom]
```

Read `references/audit-checklist.md` for the complete per-document audit rules before starting Phase 2.

---

## Phase 2 — Audit each document

Work through every document in this order. For each, apply the checks in `references/audit-checklist.md`. Log every finding as:

```
[GAP]    file:line — description of what is missing or wrong
[STALE]  file:line — description of what refers to something that no longer exists
[WRONG]  file:line — description of a relationship (consumed-by, produces) that is incorrect
```

Documents to audit:
1. `docs/how-it-works.md`
2. `docs/configuration.md`
3. `docs/practical-guide.md`
4. `README.md`
5. `CLAUDE.md`
6. `.github/ISSUE_TEMPLATE/bug_report.yml`
7. `.github/ISSUE_TEMPLATE/skill_request.yml` *(generic — only check if skill-specific examples are present)*
8. `.github/ISSUE_TEMPLATE/documentation.yml` *(generic — only check if skill names appear)*
9. `knowledge-base/requirement-forge-requirements.md` *(if exists — check it matches current skill names)*

Present a consolidated findings report before making any changes:

```
## Lattice Sync — Findings

### docs/how-it-works.md
[GAP] Atoms table missing: requirement-quality
[STALE] Refiners in Depth: requirement-forge-refiner consumed-by says "molecule" but should say "requirement-quality atom"

### .github/ISSUE_TEMPLATE/bug_report.yml
[GAP] Skill dropdown missing: requirement-quality (atom)

Total: N gaps, M stale references, P wrong relationships
```

Ask: *"Ready to apply all fixes? Or are there any findings you want to skip?"*

---

## Phase 3 — Fix

Apply every agreed fix. For each document, make all changes in a single edit pass — do not make multiple passes over the same file.

After all fixes are applied, run one final verification grep to confirm no old references remain:

```bash
# Check for stale atom names or wrong consumed-by text
grep -rn "<old-name>\|consumed.*molecule\|consumed.*wrong" \
  docs/ README.md CLAUDE.md .github/ --include="*.md" --include="*.yml"
```

If the grep returns results, fix them before declaring done.

---

## Phase 4 — Deploy (optional)

If the user wants to push the updated skills to their AI tool's skills directory:

```bash
./tools/install.sh /path/to/your/skills/folder
```

Ask the user for the target path if not provided. Default for Claude Code: `~/.claude/skills/`.

---

## Key relationships to always verify

The most error-prone relationship in Lattice documentation is the refiner → atom → molecule chain. Documents frequently drift to say a refiner is "consumed by the molecule" when it's actually consumed by an atom that the molecule composes.

For every refiner in the live inventory, derive the correct relationship dynamically:
1. Read the refiner's SKILL.md — find which atom it says consumes it (look for "consumed by" or "reads this document")
2. Read that atom's Config Resolution — confirm it reads the same `paths.{key}`
3. Read the molecule that composes that atom — confirm the chain is complete
4. If any document says the refiner is consumed by the molecule directly (not the atom), flag `[WRONG]`

Exception: `review-refiner` is consumed by the `review` molecule directly — it configures the molecule's workflow, not an atom. This is the only correct molecule-direct consumption in the current framework.

---

## Known `.lattice/` subfolders

Every molecule that writes living documents must use a named subfolder. If a new molecule is found that writes to `.lattice/` and its subfolder is not in this list, flag it for addition to `CLAUDE.md`:

- `standards/` — refiner outputs
- `context/` — feature anchor docs (context-anchoring atom)
- `learnings/` — review insights
- `reviews/` — review log
- `transform/` — plan-transformation output
- `requirements/` — requirement-forge output

---

## What good looks like

The sync is complete when:
- Every skill in `skills/` appears in the `docs/how-it-works.md` inventory tables
- Every refiner has a correct entry in `docs/configuration.md` paths table with the right consumed-by atom
- Every molecule appears in `bug_report.yml` skill dropdown
- Every atom appears in `bug_report.yml` skill dropdown
- Every refiner appears in `bug_report.yml` skill dropdown
- `CLAUDE.md` known subfolders list covers every `.lattice/` output directory
- No document contains a skill name that no longer exists in `skills/`
- The pipeline descriptions in `README.md` and `docs/how-it-works.md` use current molecule names in the right order

See `references/audit-checklist.md` for the exhaustive per-document rules.
