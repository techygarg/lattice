# Requirements Layout Migration

Read this file only when Step 3 of `lattice-init` has confirmed the user wants to migrate a legacy `.lattice/requirements/index.md` to the sharded layout. Follow these steps in order. This is a one-time, mechanical transform — no interview, no content judgment beyond the ambiguous-split case in Step 3 below.

## 1. Detect the plan

Read `.lattice/requirements/index.md`. For each `### [Epic Name]` section found, record: epic name, description (the paragraph before the feature table), and every feature row in its table.

## 2. Present the plan

Show the user:
- Epics detected, and the new file each will become (`.lattice/requirements/epics/{epic-slug}.md`)
- That `index.md` will be rewritten to the thin apex form
- That every feature file's `## Links` → `Epic index:` line will be repointed from `../index.md` to `../epics/{epic-slug}.md`
- That `.lattice/config.yaml` will gain `requirements_layout: sharded`

**STOP: do not write anything until the user confirms this plan.**

## 3. Create epic files

For each detected epic, write `.lattice/requirements/epics/{epic-slug}.md` using the epic file template in `requirement-forge`'s `references/output-templates.md` — header (name, description) plus the feature table seeded from the rows just extracted, wrapped in the generated-section boundary comments.

If the old `index.md` had a `## Source Materials` or `## Deferred Items` section whose content is scoped to one epic, move it into that epic's file. **STOP: if content spans multiple epics or the split is ambiguous, ask the user rather than guessing.**

## 4. Rewrite the apex index

Rewrite `.lattice/requirements/index.md` to the thin apex form (see `requirement-forge`'s `references/output-templates.md`): Definitions, Glossary if present, and a generated epic-list table pointing at the new epic files.

## 5. Fix back-links

For every file under `.lattice/requirements/features/`, update `## Links` → `Epic index:` to point at `../epics/{epic-slug}.md` instead of `../index.md`.

## 6. Write the config marker

Add `requirements_layout: sharded` to `.lattice/config.yaml`. Create the file if it does not exist; preserve all existing keys if it does.

## 7. Confirm

Summarize what changed: epics created, `index.md` rewritten, feature files repointed, config updated. No feature file's own content was modified beyond the one `Epic index:` link line.
