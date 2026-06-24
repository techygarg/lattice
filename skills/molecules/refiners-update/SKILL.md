---
name: refiners-update
description: "Update existing Lattice standards after a significant change — the update-mode counterpart to lattice-init. Scans .lattice/standards/, asks what changed, and routes each affected standard to its refiner's revise mode, recording a git-native change note. Use when the user says 'update refiners', 'refiners update', 'our standards changed', 'update our standards', 'the architecture changed, update the standards', 'we switched languages, update the standards', 'revise standards after a big change', or 're-run the refiners'."
---

# Refiners Update

The update-mode counterpart to `lattice-init`. Where `lattice-init` detects *missing* standards and routes you to refiners to **create** them, this molecule detects *existing* standards and routes you to each refiner's **revise** mode to update them after a significant change — then records what changed and why.

It orchestrates the refiners; it never reimplements their interviews. Versioning is git-native: history lives in commits, and each revised document gets a one-line change note. No version numbers are introduced.

## Required Skills

Read, apply:

1. `framework:knowledge-priming` -- Load project context. Understand what the project is and how the code has drifted from the current standards (always).

## What This Does (and does not)

- **Does**: coordinate revising one or more *existing* standards documents after a change, and append a change note to each.
- **Does not**: create standards that do not exist yet (that is `lattice-init` + the relevant refiner), reimplement any refiner's interview, or introduce version numbers.

If the change requires a standard that does not exist yet (e.g. the team just adopted DDD but there is no `ddd-principles.md`), that is **creation** — direct the user to `/lattice-init` or the relevant refiner to create it, and note it in the summary.

## Refiner → standards document map

| Standards doc (in `.lattice/standards/`) | Refiner to revise it | Config key |
|---|---|---|
| `knowledge-base.md` | `/knowledge-priming-refiner` | `paths.knowledge_base` |
| `language-idioms.md` | `/language-idioms-refiner` | `paths.language_idioms` |
| `architecture.md` | `/architecture-refiner` | `paths.architecture` |
| `ddd-principles.md` | `/ddd-refiner` | `paths.ddd_principles` |
| `clean-code.md` | `/clean-code-refiner` | `paths.clean_code` |
| `review-standards.md` | `/review-refiner` | `paths.review_standards` |
| `requirement-standards.md` | `/requirement-forge-refiner` | `paths.requirement_standards` |

> **Maintainer note:** This table mirrors the refiner inventory. When a refiner is added or removed, update this table (and `lattice-init`'s refiner list). `skill-align` flags inventory drift across docs.

## Workflow

### Step 1: Scan existing standards

Read `.lattice/config.yaml`. For each row in the map above, resolve the path (use the config key's value if set, otherwise the default `.lattice/standards/{file}`) and check whether the document exists. For each existing document, read its footer to note the current `mode` (overlay/override) and any prior "Last updated" line.

Present the result:

```
## Current Standards
- knowledge-base.md:      [exists (overlay, last updated 2026-05-02) / not found]
- language-idioms.md:     [exists / not found]
- architecture.md:        [exists / not found]
- ddd-principles.md:      [exists / not found]
- clean-code.md:          [exists / not found]
- review-standards.md:    [exists / not found]
- requirement-standards.md: [exists / not found]
```

**STOP: If no `.lattice/config.yaml` exists, or no standards documents are found:** there is nothing to update. Tell the user: "No existing standards found. Run `/lattice-init` to create them first." Do not proceed.

### Step 2: Capture what changed

Ask the user what changed and why — in one or two sentences. This is the trigger. It becomes the change note recorded on each revised document and drives which standards are affected.

Prompt with the common change types if the user is unsure:
- Architecture shift (new layer, moved to CQRS, dropped a pattern)
- Language or framework change
- New or revised domain rules (aggregates, invariants)
- New review or quality policy
- Project identity / stack / directory layout change
- A learning that should become a standing rule

### Step 3: Map the change to affected standards

From the trigger, propose which existing standards are likely affected and why. Present the proposed set with reasoning; do not silently decide the scope.

| Change type | Likely-affected standards |
|---|---|
| Architecture shift | `architecture.md`; `review-standards.md` if it gates on architecture rules |
| Language / framework change | `language-idioms.md`; `clean-code.md` if limits are language-specific |
| Domain rules | `ddd-principles.md`; `architecture.md` if the domain layer's placement changed |
| Review / quality policy | `review-standards.md`; `clean-code.md` |
| Project identity / stack / layout | `knowledge-base.md` |
| Requirement / spec policy | `requirement-standards.md` |
| A learning promoted to a standing rule | whichever standard the rule belongs to — `clean-code.md`, `review-standards.md`, or `architecture.md` |

Ask the user to confirm or adjust the set before proceeding. Only documents that actually exist (from Step 1) are eligible — for anything that should change but does not exist yet, follow the creation note above.

### Step 4: Revise each affected standard

**Execution model:** You — the AI running this molecule — drive each revision yourself: load and apply the refiner skill's revise flow as part of this molecule's execution, then return here to append the change note before moving to the next standard. Do not hand control back to the user and end your turn between revising and noting — the change note is this molecule's responsibility and must be written while you still hold control. (If a refiner is instead run as a separate session, the note will be missed — re-invoke `/refiners-update` afterward; its idempotent re-scan re-detects the revised document so the note still gets recorded.)

For each confirmed standard, in the order it appears in the map:

1. Offer the choice: **Revise now**, **Skip**, or **Skip all remaining**.
2. On **Revise now**: apply the corresponding refiner's **revise** path — its own "Check for existing documents → Revise" flow, which loads the existing document and updates only the sections the change touched. Reference and apply the refiner skill; do not copy its interview here. Tell the user: "Applying `{refiner}` in revise mode to update `{doc}`."
3. When the refiner's revision completes and control returns here, append (or update) the change note as the final footer line, preserving the existing footer:

   ```
   > _Last updated: {YYYY-MM-DD} — {one-line reason from Step 2}_
   ```

   Use the current date. If a prior "Last updated" line exists, replace it with the new one.
4. On **Skip**: move to the next standard. On **Skip all remaining**: jump to Step 5.

### Step 5: Summary

Report:

```
## Standards Updated
- [doc]: revised — [one-line reason]
- [doc]: skipped
- [doc]: needs creation — run /{refiner} (did not exist)
```

Remind the user:
- History is git-native — there are no version numbers. The change note carries the "why"; `git log` carries the "when".
- Commit the revised standards together with a message that names the change (e.g. `chore(standards): revise architecture + review after move to CQRS`).

## Session behavior

This molecule is idempotent and re-runnable. It owns no living document of its own — every invocation re-scans the current state in Step 1, so running it again after a partial pass simply re-detects what exists and what changed. There is no partial-session document to resume.
