---
name: ddd-refiner
description: "Facilitate a structured conversation to define DDD guardrails for domain design within a repository. Produces a formal ddd-principles.md document that the domain-driven-design atom will use as its override. Use when setting up domain design principles, defining aggregate rules, or when the user says 'setup DDD', 'define domain rules', 'DDD principles', or 'help me define my domain patterns'."
---

# DDD Refiner

## What This Produces

- **Output**: `.lattice/standards/ddd-principles.md` (or custom path from `.lattice/config.yaml` → `paths.ddd_principles`)
- **Two modes**:
  - **Overlay** (`mode: overlay`): A slim document containing only sections that differ from the defaults. The domain-driven-design atom reads its embedded defaults first, then applies this document's sections on top. This is the expected common case.
  - **Override** (`mode: override`): A comprehensive standalone document that fully replaces the atom's embedded defaults. For teams with fundamentally different domain modeling principles.
- **Default mode**: Overlay -- produces only what the user wants to change
- **Config key**: `paths.ddd_principles` in `.lattice/config.yaml`
- **Template**: Read `./assets/template.md` for the full document structure, default content, and interview guidance comments

## Scope Clarification

This skill defines the *rules of domain crafting*, not the domain model itself. The domain model evolves through features; this document defines the guardrails. It covers DDD tactical patterns only -- not strategic DDD (no context mapping, no microservice topology, no bounded context integration).

## Before You Begin

### Check for existing documents

Before starting the interview, check whether a custom document already exists:

1. Read `.lattice/config.yaml` -- does `paths.ddd_principles` point to a file?
2. If yes, read that file. Ask the user:
   - "You already have a custom DDD principles document. Would you like to **revise** it (update specific sections), **start fresh** (new interview), or **add to it** (add new sections)?"
   - Revise: Load the existing document, walk through only the sections the user wants to change, and update in place.
   - Start fresh: Proceed with the full interview flow below.
   - Add to it: Skip to the "New Sections" part of the interview.
3. If no config or no existing document, proceed with the full interview flow.

### Scan the repository

Look for signals that inform the conversation:

- **Domain folder**: Does a `domain/` (or `core/`, `model/`) folder exist? What's inside it?
- **Existing aggregates**: Are there entities, value objects, aggregate roots? How are they structured?
- **Anemic patterns**: Are entities data holders or do they have behavior?
- **Identity patterns**: Typed IDs, raw UUIDs, database-generated IDs?
- **Event patterns**: Are domain events used? What naming convention?
- **Architecture docs**: Any existing DDD documentation, ADRs, domain glossaries?

Share relevant findings with the user at the start: "I noticed your project already has [X patterns]. I'll use that as context."

If the project is new with no code, proceed with pure defaults as the starting point.

## Choosing the Mode

The first decision in the conversation. Present the three options:

"How would you like to define your DDD principles?

1. **Customize specific sections** (overlay) -- Keep the defaults and change only what differs for your project. This produces a slim document. Most teams choose this.
2. **Define everything from scratch** (override) -- Walk through all sections and produce a comprehensive standalone document.
3. **Add project-specific sections only** (overlay with additions) -- Keep all defaults as-is and add new sections for your team's specific rules (e.g., ubiquitous language glossary, bounded context boundaries).

The defaults cover standard DDD tactical patterns well. Option 1 is recommended unless your domain modeling approach is fundamentally different."

Map the choice:
- Options 1 and 3 → `mode: overlay`
- Option 2 → `mode: override`

## Facilitation Approach

### Conversation style

- **One section at a time.** Do not dump all questions at once. Walk through the template sequentially.
- **Defaults-first.** For each section, briefly summarize the default, then ask if it matches. Do not read the entire default verbatim -- summarize the key points and ask.
- **Record decisions, not discussion.** The output document reads as a specification, not meeting notes. "We discussed X and decided Y" is wrong. "Y" is right.
- **Probe, don't interrogate.** Use the probing questions in the template guidance comments as follow-ups when the user's answer is ambiguous, not as a checklist.

### For overlay mode

This should be fast. Many sections will be "keep as-is."

1. Present each section's default briefly (a 2-3 sentence summary, not full content).
2. Ask: "Does this match your project, or would you like to change it?"
3. If the user says it matches → skip it (section will NOT appear in the output).
4. If the user wants changes → dive into that section, discuss the specifics, record the changes.
5. At the end, ask: "Any sections you'd like to add that aren't in the defaults?" (e.g., ubiquitous language glossary, bounded context scope).
6. Only sections the user changed or added appear in the output document.

### For override mode

This is thorough. Every section gets attention and appears in the output.

1. Walk through every section in full detail.
2. User confirms, modifies, or replaces each section.
3. All sections appear in the output -- defaults for unchanged ones, user's version for changed ones.

### Common scenarios

- **"I agree with everything"** → No custom document needed. Tell the user: "The embedded defaults are already active and match your preferences. No custom document is needed -- the domain-driven-design atom will use the defaults automatically."
- **"I agree except one section"** → Overlay mode, interview that one section only.
- **"We have anemic entities and want to fix that"** → Overlay §2 (entity patterns, anemic anti-pattern is inline) + §9 (entity checks).
- **"We don't use domain events yet"** → Overlay §5 (domain events) with simplified approach or removal note. Also check §1 (cross-aggregate coordination, anti-pattern is inline).
- **"Our aggregates are too big"** → Overlay §1 (aggregate design, god aggregate anti-pattern is inline) + §8 (decomposition guide).
- **"We want to add a ubiquitous language glossary"** → Overlay with new §10 only.

## Section-by-Section Interview Guide

Read `./assets/template.md` and follow the `<!-- INTERVIEW GUIDANCE: -->` comments for each section. Those comments contain the specific questions to ask, probing questions, and what is customizable vs fixed.

### Cross-section dependency table

Decisions in early sections affect later sections. When a user changes an early section, flag the dependent sections:

| Decision in | Affects | How |
|-------------|---------|-----|
| §1 — Aggregate boundaries | §6 (repositories), §5 (events), §8 (decomposition) | One repo per aggregate root; events for cross-aggregate coordination |
| §1 — Sizing thresholds | §8 (decomposition triggers) | Custom thresholds change decomposition warning signals |
| §2 — Entity identity strategy | §3 (typed ID value objects), §6 (repository signatures) | Typed IDs must be value objects; repository findById uses typed IDs |
| §3 — Value object catalog | §2 (entity fields) | New value objects appear in entity definitions |
| §5 — Event patterns | §1 (cross-aggregate coordination) | Events are the mechanism for cross-aggregate consistency |
| §6 — Repository patterns | §1 (aggregate root identification) | Only roots get repositories |

When a dependency is triggered, inform the user: "Since you changed [X], we should also review [Y] -- it's affected by that decision."

### Overlay-specific section flow

For each of the 9 sections:

1. Summarize the section's key points in 2-3 sentences.
2. Ask: "Does this match your project?"
3. **Yes** → Move to the next section. This section will not appear in the output.
4. **No** → Dive into the section details using the template guidance. Produce the user's version.
5. After all 9 sections, ask about new sections.

### Override-specific section flow

For each of the 9 sections:

1. Present the section's full content.
2. Ask: "Does this work as-is, or would you like to modify it?"
3. **As-is** → Include the default content in the output unchanged.
4. **Modify** → Discuss changes, produce the modified version.
5. After all 9 sections, ask about new sections.
6. All sections go in the output.

## Output Assembly

### For overlay mode

1. YAML frontmatter: `mode: overlay`
2. Overlay preamble text (from template)
3. Table of contents listing only the included sections
4. Only the sections the user changed or added
5. Each section must be self-contained -- it is a complete replacement of that section in defaults. Do not write diffs or partial sections.
6. Section headings must match `defaults.md` exactly (the atom matches sections by heading)
7. New sections (§10+) are included after the default sections
8. Footer with project name, date, mode

### For override mode

1. YAML frontmatter: `mode: override`
2. Override preamble text (from template)
3. Full table of contents (all 10+ sections)
4. All sections: defaults for unchanged, user's version for changed, new sections at the end
5. Footer with project name, date, mode

### For both modes

Strip all `<!-- INTERVIEW GUIDANCE: -->` comments from the output. The final document is a clean specification.

**Determine output path:**
1. If `.lattice/config.yaml` exists and has `paths.ddd_principles`, use that path.
2. Otherwise, default to `.lattice/standards/ddd-principles.md`.

**Write the document:**
1. Create `.lattice/standards/` directory (and `.lattice/` parent) if it does not exist.
2. Write the document to the determined path.

**Update config:**
1. If `.lattice/config.yaml` does not exist, create it with:
   ```yaml
   paths:
     ddd_principles: .lattice/standards/ddd-principles.md
   ```
2. If `.lattice/config.yaml` exists but has no `paths.ddd_principles`, add the key. Preserve all existing content.
3. If `.lattice/config.yaml` exists and already has the key, no config change needed.

**Confirm to user:**
"Your DDD principles document has been written to `[PATH]` in **[overlay|override]** mode. The domain-driven-design atom will now use it [on top of the defaults | instead of the defaults]."

## Document Quality Checks

Before writing the final document, verify:

### Overlay mode checks

- [ ] Each included section is self-contained and complete (not a diff or partial section)
- [ ] Section headings match `defaults.md` exactly (for section matching by the atom)
- [ ] No `<!-- INTERVIEW GUIDANCE: -->` comments remain
- [ ] Frontmatter has `mode: overlay`
- [ ] Only changed/added sections are included -- unchanged sections are omitted

### Override mode checks

- [ ] Every section from the template is present (§1 through §9, plus any new sections)
- [ ] Terminology is consistent throughout all sections
- [ ] Code examples use pseudocode (language-agnostic, same style as defaults.md)
- [ ] Validation checklist (§9) is consistent with the rules defined in §1 through §7
- [ ] Inline anti-pattern warnings align with the patterns defined in their respective sections
- [ ] No `<!-- INTERVIEW GUIDANCE: -->` comments remain
- [ ] Frontmatter has `mode: override`
- [ ] Document is readable as a standalone specification

### Both modes

- [ ] Frontmatter is valid YAML with correct mode value
- [ ] Document is well-formatted markdown
- [ ] Config file (`.lattice/config.yaml`) is correctly updated
- [ ] Output path exists and is writable
