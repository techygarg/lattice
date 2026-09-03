---
name: requirement-forge-refiner
description: "Facilitate a structured conversation to define requirement standards for a project — epic and feature definitions, scenario structure, AC format, priority notation, status workflow, and naming conventions. Produces a formal requirement-standards.md that the requirement-quality atom reads via config resolution, customising its embedded defaults for the team's product process. Use when setting up a new project, defining product standards, or when the user says 'set up requirement standards', 'define feature standards', 'configure requirement forge', 'define how features should be structured', or 'requirement forge refiner'."
---

# Requirement Forge Refiner

## What This Produces

- **Output**: `.lattice/standards/requirement-standards.md` (or custom path from `.lattice/config.yaml` → `paths.requirement_standards`)
- **Two modes**:
  - **Overlay** (`mode: overlay`): A slim document containing only sections that differ from the built-in defaults. The `requirement-quality` atom reads its embedded `defaults.md` first, then applies this document's sections on top. This is the expected common case.
  - **Override** (`mode: override`): A comprehensive standalone document that fully replaces the atom's embedded defaults. For teams whose product process differs fundamentally from the defaults.
- **Default mode**: Overlay — produces only what the team wants to change
- **Config key**: `paths.requirement_standards` in `.lattice/config.yaml`
- **Consumed by**: `requirement-quality` atom (via config resolution) → `requirement-forge` molecule (composes the atom)
- **Template**: Read `./assets/template.md` for the full document structure, default content, and interview guidance comments

## Scope Clarification

This refiner defines how requirements are *structured and expressed* for this project. It does not define:

- What to build (that is the requirement-forge molecule's job)
- Architecture or technical design (that is the architecture-refiner's job)
- Domain modeling patterns (that is the ddd-refiner's job)

The standards produced here answer: what is an epic, what is a feature, what is a scenario, how are ACs written, how are features named and prioritized. These are the rules the `requirement-quality` atom enforces — the molecule composes the atom and inherits those rules automatically.

## Before You Begin

### Check for an existing standards document

1. Read `.lattice/config.yaml` — check `paths.requirement_standards`.
2. If the path exists, read that file. Ask the user:
   - "You already have a requirement standards document. Would you like to **revise** it (update specific sections), **start fresh** (new interview), or **add to it** (add new sections)?"
   - Revise: load the existing document, walk through only the sections the user wants to change, update in place.
   - Start fresh: proceed with the full interview flow below.
   - Add to it: skip to the "New Sections" part of the interview.
3. If no config or no existing document, proceed with the full interview.

### Ask two orienting questions first

Before the formal interview, ask:

1. "Does your team already have a way of writing requirements — any existing PRDs, Confluence templates, or Jira conventions I should be aware of?"
2. "Is there a specific product domain or terminology I should know before we define the standards?"

These two questions are the only free-form listening before the structured interview begins. Synthesize what you hear and carry it forward — do not ask follow-up questions at this stage.

## Choosing the Mode

Present the three options:

"How would you like to define your requirement standards?

1. **Customize specific sections** (overlay) — Keep the built-in defaults and change only what differs for your project. This produces a slim document. Most teams choose this.
2. **Define everything from scratch** (override) — Walk through all sections and produce a comprehensive standalone document.
3. **Add project-specific sections only** (overlay with additions) — Keep all defaults as-is and add new sections, such as domain terminology or custom status workflows.

The built-in defaults cover standard product spec practices well. Option 1 is recommended unless your team's conventions are fundamentally different."

Map the choice:
- Options 1 and 3 → `mode: overlay`
- Option 2 → `mode: override`

## Facilitation Approach

### Conversation style

- **One section at a time.** Do not present all questions at once. Walk through the template sequentially.
- **Defaults-first.** For each section, briefly summarize the default, then ask if it matches. Do not read defaults verbatim — summarize key points and ask.
- **Propose, don't just ask.** When the user's answer is ambiguous, propose the most reasonable interpretation and ask them to confirm or correct. "It sounds like you want MoSCoW priorities — so 'Must', 'Should', 'Could', 'Won't'. Is that right?"
- **Record decisions, not discussion.** The output document reads as a specification. "We discussed X and decided Y" is wrong. "Y" is right.
- **Challenge weak definitions.** If the user defines a "feature" so broadly it would encompass an entire epic, push back: "That scope sounds like an epic — a feature should be independently designable in one design-blueprint session. Can we tighten the definition?"

### For overlay mode

This should be fast. Many sections will be "keep as-is."

1. Present each section's default in 2–3 sentences.
2. Ask: "Does this match your project, or would you like to change it?"
3. If matches → skip it (section will NOT appear in the output).
4. If changes wanted → discuss specifics, record the changes.
5. After all sections, ask: "Anything to add that isn't covered — domain-specific terminology, custom fields, team conventions?"
6. Only changed or added sections appear in the output document.

### For override mode

Every section gets attention and appears in the output.

1. Walk through every section in full detail.
2. User confirms, modifies, or replaces each section.
3. All sections appear in the output.

### Common scenarios

- **"I agree with everything"** → No custom document needed. "The embedded defaults are already active. No custom document is needed — requirement-forge will use the defaults automatically."
- **"We use MoSCoW priorities"** → Overlay §6 only.
- **"We call them 'use cases' not 'scenarios'"** → Overlay §4 (rename + update any description that references "scenario").
- **"We have a longer status workflow"** → Overlay §7.
- **"We have domain-specific terms that should be consistent"** → Overlay with additions — add §10 Domain Terminology.
- **"Our features tend to be larger"** → Overlay §2 and §4 — adjust the size signals and max scenario count.

## Section-by-Section Interview Guide

Read `./assets/template.md` and follow the `<!-- INTERVIEW GUIDANCE: -->` comments for each section. Those comments contain specific questions, probing questions, and what is customizable vs. fixed.

### Cross-section dependency table

| Decision in | Affects | How |
|---|---|---|
| §2 — Feature size definition | §4 scenario count | Larger features tolerate more scenarios; tighter features need a lower cap |
| §4 — Scenario nomenclature | §8 naming conventions | If "scenario" is renamed, naming conventions must use the new term |
| §4 — Max scenarios per feature | §2 feature definition | These two must be consistent — the split signal in §2 should align with the cap in §4 |
| §5 — AC format | §4 scenario structure | AC format determines what each scenario's criteria look like |
| §6 — Priority notation | feature file frontmatter | Priority field format used in every generated feature file |
| §7 — Status workflow | feature file frontmatter | Status field used in every generated feature file |
| §8 — Naming conventions | all file generation | Feature file names and display names generated by the molecule |

When a dependency is triggered, inform the user: "Since you changed [X], we should also review [Y] — it's affected by that decision."

### Overlay-specific section flow

For each of the 9 default sections:

1. Summarize the section's key points in 2–3 sentences.
2. Ask: "Does this match your project?"
3. **Yes** → Move to the next section. This section will not appear in the output.
4. **No** → Dive into the details using the template guidance. Produce the user's version.
5. After all 9 sections, ask about additions.

### Override-specific section flow

For each of the 9 default sections:

1. Present the section's full content.
2. Ask: "Does this work as-is, or would you like to modify it?"
3. **As-is** → Include the default content unchanged.
4. **Modify** → Discuss changes, produce the modified version.
5. All sections go in the output.

## Output Assembly

### For overlay mode

1. YAML frontmatter: `mode: overlay`
2. Overlay preamble (from template)
3. Table of contents listing only included sections
4. Only the sections the user changed or added — each must be self-contained and complete
5. Section headings must match `template.md` exactly (the molecule matches sections by heading)
6. New sections (§10+) included after the default sections
7. Footer with project name, date, mode

### For override mode

1. YAML frontmatter: `mode: override`
2. Override preamble (from template)
3. Full table of contents (all 9+ sections)
4. All sections: defaults for unchanged, user's version for changed, new sections at end
5. Footer with project name, date, mode

### For both modes

Strip all `<!-- INTERVIEW GUIDANCE: -->` comments from the output. The final document is a clean specification.

**Determine output path:**
1. If `.lattice/config.yaml` exists and has `paths.requirement_standards`, use that path.
2. Otherwise, default to `.lattice/standards/requirement-standards.md`.

**Write the document:**
1. Create `.lattice/standards/` directory (and `.lattice/` parent) if it does not exist.
2. Write the document to the determined path.

**Update config:**
1. If `.lattice/config.yaml` does not exist, create it with:
   ```yaml
   paths:
     requirement_standards: .lattice/standards/requirement-standards.md
   ```
2. If `.lattice/config.yaml` exists but has no `paths.requirement_standards`, add the key. Preserve all existing content.
3. If the key already exists, no config change needed.

**Confirm to user:**
"Your requirement standards have been written to `[PATH]` in **[overlay|override]** mode. The requirement-forge molecule will now use these standards and will not re-ask structural questions covered here."

## Document Quality Checks

Before writing the final document, verify:

### Overlay mode checks

- [ ] Each included section is self-contained and complete (not a diff or partial section)
- [ ] Section headings match `template.md` exactly
- [ ] No `<!-- INTERVIEW GUIDANCE: -->` comments remain
- [ ] Frontmatter has `mode: overlay`
- [ ] Only changed or added sections are included

### Override mode checks

- [ ] All 9 default sections are present (plus any additions)
- [ ] §2 feature size signal is consistent with §4 max scenario count
- [ ] §4 scenario nomenclature is consistent with §8 naming conventions
- [ ] §5 AC format is consistent with how §4 describes scenario criteria
- [ ] §6 priority values and §7 status values match the frontmatter field descriptions in §8
- [ ] No `<!-- INTERVIEW GUIDANCE: -->` comments remain
- [ ] Frontmatter has `mode: override`
- [ ] Document is readable as a standalone specification

### Both modes

- [ ] Frontmatter is valid YAML with correct mode value
- [ ] Document is well-formatted markdown
- [ ] Config file (`.lattice/config.yaml`) is correctly updated
- [ ] Output path exists and is writable
