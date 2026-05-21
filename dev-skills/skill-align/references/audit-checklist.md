# Lattice Sync — Per-Document Audit Checklist

For each document, apply the checks listed. Every `[ ]` item is a potential finding.

---

## 1. `docs/how-it-works.md`

### Atoms table (§ Skill Inventory → Atoms)

For every atom in the live inventory:
- [ ] Row exists with correct `name` and `/name` command
- [ ] `What it enforces` description is accurate and current
- [ ] No rows exist for atoms that have been removed

### Molecules table (§ Skill Inventory → Molecules)

For every molecule in the live inventory:
- [ ] Row exists with correct `name` and `/name` command
- [ ] `What it does` description reflects current behavior (especially after workflow changes)
- [ ] No rows exist for molecules that have been removed

### Refiners table (§ Skill Inventory → Refiners)

For every refiner in the live inventory:
- [ ] Row exists with correct `name` and `/name` command
- [ ] `Produces` path is correct and matches what the refiner actually writes
- [ ] No rows exist for refiners that have been removed

### Always vs Conditional atoms (§ Atoms in Depth)

- [ ] Every conditional atom is listed with its condition correctly stated
- [ ] No atom is listed that has been removed
- [ ] `requirement-quality` listed as conditional (applies during requirement-forge / spec validation)

### Molecules in Depth

For every molecule in the live inventory:
- [ ] Has a dedicated `### <molecule-name>` section
- [ ] `Composes:` list matches the molecule's `Required Skills` section accurately
- [ ] `How it works` steps reflect the current workflow (not an outdated version)
- [ ] No section exists for a removed molecule

### Refiners in Depth table

For every refiner:
- [ ] Row exists
- [ ] `Consumed by` correctly names the **atom** (not molecule) for refiners that target atoms
- [ ] Exception: `review-refiner` → consumed by `review` molecule directly (correct)
- [ ] Exception: (none currently — all others go atom → molecule)

### `.lattice/` folder Structure section

- [ ] `standards/` lists all current refiner output files
- [ ] All known subfolders are listed (`requirements/`, `transform/`, `context/`, `learnings/`, `reviews/`, `standards/`)
- [ ] Subfolder Lifecycles table has a row for every subfolder

### Pipeline section

- [ ] All pipeline paths use current molecule names
- [ ] Full pipeline includes `requirement-forge` as optional upstream step
- [ ] `plan-transformation` path is present for codebase transformation

---

## 2. `docs/configuration.md`

### File structure YAML example

- [ ] Every `paths.*` key used by any atom or refiner appears in the YAML block
- [ ] No key in the YAML block refers to a removed skill

### `paths` Keys table

For every refiner in the live inventory:
- [ ] Row exists with correct `Key` (snake_case)
- [ ] `Purpose` description is accurate
- [ ] `Produced by` names the correct refiner
- [ ] `Default path` is correct (`.lattice/standards/<name>.md`)
- [ ] `Consumed by` correctly names the atom (not the molecule) — except `review_standards` which names the `review` molecule
- [ ] `Mode` is correct (`overlay` vs `override` vs `standalone`)

Special case — `requirement_standards`:
- [ ] `Consumed by`: "`requirement-quality` atom" (NOT "requirement-forge molecule")
- [ ] `Mode`: `overlay (recommended)`

---

## 3. `docs/practical-guide.md`

### Contents list

- [ ] Every `## Section` heading in the document appears in the Contents list
- [ ] No Contents entry points to a section that doesn't exist

### Requirements section

- [ ] Covers: when to use requirement-forge vs design-blueprint
- [ ] Covers: output structure (index.md + features/)
- [ ] Covers: what a scenario is
- [ ] Covers: refiner optional / defaults communicated
- [ ] Covers: handling existing PRDs / unstructured material
- [ ] Covers: interrupted session / resume behavior
- [ ] Covers: single-feature fast path

### Workflow section

- [ ] `/design-blueprint` Q&A mentions requirement-forge as an upstream option

### Getting Started section

- [ ] `.lattice/` folder description mentions `requirements/` subfolder

### Troubleshooting section

- [ ] No references to removed skills or old skill names

---

## 4. `README.md`

### Pipeline description

- [ ] Pipeline text names `requirement-forge` as the upstream step
- [ ] Pipeline uses current molecule names in correct order

### Getting Started steps

- [ ] Step for `/requirement-forge` present (marked optional but recommended)
- [ ] Step numbers are sequential and correct after any additions

### The Three Tiers table

- [ ] No stale skill names appear in tier descriptions
- [ ] Atoms row description is accurate given the current atom inventory

---

## 5. `CLAUDE.md`

### Known subfolders list (Key Patterns section)

- [ ] `requirements/` listed with description "epic/feature specs produced by requirement-forge"
- [ ] `transform/` listed
- [ ] All other known subfolders present

### Skill Conventions section

- [ ] If a new tier convention was established, it's documented
- [ ] No references to skills that no longer exist

### Repository Structure section

- [ ] Molecule count is accurate
- [ ] Refiner count is accurate
- [ ] Atom count is accurate

---

## 6. `.github/ISSUE_TEMPLATE/bug_report.yml`

### Skill dropdown options

The dropdown must contain every skill in the live inventory, grouped by tier, in this format:
- `<name> (atom)` — for atoms
- `<name> (molecule)` — for molecules
- `<name> (refiner)` — for refiners

Checks — derive expected entries from the live inventory built in Phase 1, not from any hardcoded list:
- [ ] For every atom name in the live inventory: `<name> (atom)` entry exists in the dropdown
- [ ] For every molecule name in the live inventory: `<name> (molecule)` entry exists in the dropdown
- [ ] For every refiner name in the live inventory: `<name> (refiner)` entry exists in the dropdown
- [ ] No entries exist in the dropdown for skills not present in the live inventory (stale entries)
- [ ] `Other / unsure` option is present as the first option

Do NOT compare against a hardcoded list. Compare against the inventory you built in Phase 1 by reading `skills/`. That inventory is always current.

---

## 7. `.github/ISSUE_TEMPLATE/skill_request.yml`

This is a generic form. Only check if skill-specific names appear:
- [ ] If any specific skill names are referenced as examples, verify they still exist

---

## 8. `.github/ISSUE_TEMPLATE/documentation.yml`

This is a generic form. Only check:
- [ ] If specific doc file names are listed in dropdowns, verify those files still exist

---

## 9. `knowledge-base/` files

For any requirements docs in `knowledge-base/`:
- [ ] Skill names referenced match current inventory names (e.g., `requirement-quality` not `requirements`)
- [ ] Status fields are current

---

## Cross-cutting checks (run after all individual document checks)

### Name consistency

For every skill:
- [ ] Folder name == `name:` frontmatter field (e.g., folder `requirement-quality/` → `name: requirement-quality`)
- [ ] All documents use the same canonical name (no mix of `requirement-quality` and `requirements`)

### Config key consistency

For every refiner:
- [ ] The config key used in the refiner SKILL.md matches the key in `docs/configuration.md`
- [ ] The key follows snake_case convention

### Required Skills consistency (molecules)

For each `Required Skills` entry in a molecule:
- [ ] The referenced atom (`framework:<name>`) exists in `skills/atoms/<name>/`
- [ ] The atom is described accurately (always/conditional)

### Stale reference scan

```bash
# Run this to surface any remaining stale references after fixes
grep -rn "requirements atom\|framework:requirements\b\|consumed.*requirement-forge molecule" \
  docs/ README.md CLAUDE.md .github/ skills/ \
  --include="*.md" --include="*.yml" 2>/dev/null
```

Any result from this grep is a `[STALE]` finding.
