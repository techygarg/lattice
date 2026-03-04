---
name: architecture-crafter
description: "Facilitate a structured conversation to define clean architecture principles for a repository. Produces a formal clean-architecture.md document that the clean-architecture atom will use as its override. Use when setting up a new project, defining architecture standards, or when the user says 'setup architecture', 'define layers', 'architecture principles', or 'help me define my architecture'."
---

# Architecture Crafter

## What This Produces

- **Output**: `.ai/clean-architecture.md` (or custom path from `.ai/config.yaml` → `paths.clean_architecture`)
- **Two modes**:
  - **Overlay** (`mode: overlay`): A slim document containing only sections that differ from the defaults. The clean-architecture atom reads its embedded defaults first, then applies this document's sections on top. This is the expected common case.
  - **Override** (`mode: override`): A comprehensive standalone document that fully replaces the atom's embedded defaults. For teams with fundamentally different architecture.
- **Default mode**: Overlay -- produces only what the user wants to change
- **Config key**: `paths.clean_architecture` in `.ai/config.yaml`
- **Template**: Read `./assets/template.md` for the full document structure, default content, and interview guidance comments

## Before You Begin

### Check for existing documents

Before starting the interview, check whether a custom document already exists:

1. Read `.ai/config.yaml` — does `paths.clean_architecture` point to a file?
2. If yes, read that file. Ask the user:
   - "You already have a custom architecture document. Would you like to **revise** it (update specific sections), **start fresh** (new interview), or **add to it** (add new sections)?"
   - Revise: Load the existing document, walk through only the sections the user wants to change, and update in place.
   - Start fresh: Proceed with the full interview flow below.
   - Add to it: Skip to the "New Sections" part of the interview.
3. If no config or no existing document, proceed with the full interview flow.

### Scan the repository

Look for signals that inform the conversation:

- **Directory structure**: Does `src/` (or equivalent) already have layers? What are they named?
- **Existing patterns**: Are there existing controllers, services, repositories, providers? What naming conventions are in use?
- **DI patterns**: Is there a DI container, manual injection, or framework-provided injection?
- **Architecture docs**: Any existing architecture documentation (ADRs, README sections)?
- **Framework**: What framework is in use? (NestJS, Spring, Django, etc.) This affects naming conventions and common patterns.

Share relevant findings with the user at the start: "I noticed your project already has [X structure]. I'll use that as context."

If the project is new with no code, proceed with pure defaults as the starting point.

## Choosing the Mode

The first decision in the conversation. Present the three options:

"How would you like to define your architecture principles?

1. **Customize specific sections** (overlay) — Keep the defaults and change only what differs for your project. This produces a slim document. Most teams choose this.
2. **Define everything from scratch** (override) — Walk through all sections and produce a comprehensive standalone document.
3. **Add project-specific sections only** (overlay with additions) — Keep all defaults as-is and add new sections for your team's specific rules.

The defaults cover standard clean architecture well. Option 1 is recommended unless your architecture is fundamentally different."

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
5. At the end, ask: "Any sections you'd like to add that aren't in the defaults?" (e.g., naming conventions, framework-specific rules).
6. Only sections the user changed or added appear in the output document.

### For override mode

This is thorough. Every section gets attention and appears in the output.

1. Walk through every section in full detail.
2. User confirms, modifies, or replaces each section.
3. All sections appear in the output -- defaults for unchanged ones, user's version for changed ones.

### Common scenarios

- **"I agree with everything"** → No custom document needed. Tell the user: "The embedded defaults are already active and match your preferences. No custom document is needed — the clean-architecture atom will use the defaults automatically."
- **"I agree except one section"** → Overlay mode, interview that one section only.
- **"We use CQRS"** → Overlay §3.2 + §4 (they are coupled — CQRS changes the service pattern which changes both flows).
- **"We don't use Providers"** → Overlay §3.4 + §4.2 + §4.3 + §6 (Provider removal ripples through query flow and validation).
- **"We have extra layers"** → Overlay §1 + §2 + §3 (new layers need responsibilities, dependency placement, and per-layer rules).

## Section-by-Section Interview Guide

Read `./assets/template.md` and follow the `<!-- INTERVIEW GUIDANCE: -->` comments for each section. Those comments contain the specific questions to ask, probing questions, and what is customizable vs fixed.

### Cross-section dependency table

Decisions in early sections affect later sections. When a user changes an early section, flag the dependent sections:

| Decision in | Affects | How |
|-------------|---------|-----|
| §1 — Layer names | All sections | Names must be consistent everywhere |
| §1 — Extra layers | §2 (diagram), §3 (per-layer rules) | New layers need dependency placement and rules |
| §3.2 — Service pattern (unified vs CQRS) | §4.1, §4.2 | CQRS uses separate handlers instead of unified service |
| §3.4 — Provider pattern (yes/no) | §4.2, §4.3, §6 | No Provider → reads go through Repository; comparison table and checklist change |

When a dependency is triggered, inform the user: "Since you changed [X], we should also review [Y] — it's affected by that decision."

### Overlay-specific section flow

For each of the 6 default sections:

1. Summarize the section's key points in 2-3 sentences.
2. Ask: "Does this match your project?"
3. **Yes** → Move to the next section. This section will not appear in the output.
4. **No** → Dive into the section details using the template guidance. Produce the user's version.
5. After all 6 sections, ask about new sections.

### Override-specific section flow

For each of the 6 default sections:

1. Present the section's full content.
2. Ask: "Does this work as-is, or would you like to modify it?"
3. **As-is** → Include the default content in the output unchanged.
4. **Modify** → Discuss changes, produce the modified version.
5. After all 6 sections, ask about new sections.
6. All sections go in the output.

## Output Assembly

### For overlay mode

1. YAML frontmatter: `mode: overlay`
2. Overlay preamble text (from template)
3. Table of contents listing only the included sections
4. Only the sections the user changed or added
5. Each section must be self-contained — it is a complete replacement of that section in defaults. Do not write diffs or partial sections.
6. Section headings must match `defaults.md` exactly (the atom matches sections by heading)
7. New sections (§7+) are included after the default sections
8. Footer with project name, date, mode

### For override mode

1. YAML frontmatter: `mode: override`
2. Override preamble text (from template)
3. Full table of contents (all 6+ sections)
4. All sections: defaults for unchanged, user's version for changed, new sections at the end
5. Footer with project name, date, mode

### For both modes

Strip all `<!-- INTERVIEW GUIDANCE: -->` comments from the output. The final document is a clean specification.

**Determine output path:**
1. If `.ai/config.yaml` exists and has `paths.clean_architecture`, use that path.
2. Otherwise, default to `.ai/clean-architecture.md`.

**Write the document:**
1. Create `.ai/` directory if it does not exist.
2. Write the document to the determined path.

**Update config:**
1. If `.ai/config.yaml` does not exist, create it with:
   ```yaml
   paths:
     clean_architecture: .ai/clean-architecture.md
   ```
2. If `.ai/config.yaml` exists but has no `paths.clean_architecture`, add the key. Preserve all existing content.
3. If `.ai/config.yaml` exists and already has the key, no config change needed.

**Confirm to user:**
"Your architecture document has been written to `[PATH]` in **[overlay|override]** mode. The clean-architecture atom will now use it [on top of the defaults | instead of the defaults]."

## Document Quality Checks

Before writing the final document, verify:

### Overlay mode checks

- [ ] Each included section is self-contained and complete (not a diff or partial section)
- [ ] Section headings match `defaults.md` exactly (for section matching by the atom)
- [ ] No `<!-- INTERVIEW GUIDANCE: -->` comments remain
- [ ] Frontmatter has `mode: overlay`
- [ ] Only changed/added sections are included — unchanged sections are omitted

### Override mode checks

- [ ] Every section from the template is present (§1 through §6, plus any new sections)
- [ ] Layer names are consistent throughout all sections
- [ ] Dependency diagram (§2) matches the layer table (§1)
- [ ] Code examples use pseudocode (language-agnostic, same style as defaults.md)
- [ ] Validation checklist (§6) is consistent with the rules defined in §3 and §4
- [ ] No `<!-- INTERVIEW GUIDANCE: -->` comments remain
- [ ] Frontmatter has `mode: override`
- [ ] Document is readable as a standalone specification

### Both modes

- [ ] Frontmatter is valid YAML with correct mode value
- [ ] Document is well-formatted markdown
- [ ] Config file (`.ai/config.yaml`) is correctly updated
- [ ] Output path exists and is writable
