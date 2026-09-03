# Requirements Layout Migration

Read this file only when Step 3 of `lattice-init` has confirmed the user wants to migrate a legacy `.lattice/requirements/index.md` to the sharded layout. Follow these steps in order. This is a one-time, mechanical transform — no interview, no content judgment beyond the ambiguous-split case in Step 3 below.

## 1. Detect the plan

Read `.lattice/requirements/index.md`. For each `### [Epic Name]` section found, record: epic name, description (the paragraph before the feature table), and every feature row in its table.

For each feature row found, also open that feature's file and read its own `epic:` frontmatter. Record any disagreement between that value and the epic section the row was found under in the old index — do not resolve it here, just record it for Step 2.

## 2. Present the plan

Show the user:
- Epics detected, and the new file each will become (`.lattice/requirements/epics/{epic-slug}.md`)
- That `index.md` will be rewritten to the thin apex form
- That every feature file's `## Links` → `Epic index:` line will be repointed from `../index.md` to `../epics/{epic-slug}.md`
- That `.lattice/config.yaml` will gain `requirements_layout: sharded`
- **Any epic-placement disagreements found in Step 1** — for each, name the feature, its own `epic:` frontmatter value, and the epic section it was filed under in the old index. **STOP: ask the user to resolve each explicitly** — keep the feature file's `epic:` value (file it under that epic instead), or update the feature file's `epic:` to match its old placement. Do not guess or silently prefer one over the other.

**STOP: do not write anything until the user confirms this plan, including every epic-placement disagreement.**

## 3. Create epic files

For each detected epic, write `.lattice/requirements/epics/{epic-slug}.md` using the epic file template in `requirement-forge`'s `references/output-templates.md` — header (name, description, no `status:` field) plus the feature table seeded from the rows just extracted, using each feature's *resolved* epic assignment from Step 2. Keep only feature name and one-line summary in the table — drop any Status/Priority/Depends On values from the old rows; those fields live solely in each feature file's own frontmatter, untouched by this migration. Wrap the table in the generated-section boundary comments.

If the old `index.md` had a `## Source Materials` or `## Deferred Items` section whose content is scoped to one epic, move it into that epic's file. **STOP: if content spans multiple epics or the split is ambiguous, ask the user rather than guessing.**

## 4. Rewrite the apex index

Rewrite `.lattice/requirements/index.md` to the thin apex form (see `requirement-forge`'s `references/output-templates.md`): Definitions, Glossary if present, and a generated epic-list table pointing at the new epic files.

## 5. Fix back-links

For every file under `.lattice/requirements/features/`, update `## Links` → `Epic index:` to point at `../epics/{epic-slug}.md` instead of `../index.md`. For any feature where Step 2's disagreement resolution chose to update the feature's own `epic:` frontmatter, apply that change now — this is the one content edit beyond the link line, and only happens where the user explicitly confirmed it.

## 6. Write the config marker

Add `requirements_layout: sharded` to `.lattice/config.yaml`. Create the file if it does not exist; preserve all existing keys if it does.

## 7. Confirm

Summarize what changed: epics created, `index.md` rewritten, feature files repointed, config updated. No feature file's own content was modified beyond the one `Epic index:` link line — except where Step 2 surfaced an epic-placement disagreement and the user chose to update a feature's `epic:` frontmatter; list any such files explicitly here.
