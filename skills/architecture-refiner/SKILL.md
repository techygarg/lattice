---
name: architecture-refiner
description: "Facilitate a structured conversation to define architecture principles for a repository. Supports multiple architecture styles: clean architecture (default), hexagonal / ports & adapters, modular monolith, or custom. Produces a formal architecture document that the corresponding atom will use. Use when setting up a new project, defining architecture standards, or when the user says 'setup architecture', 'define layers', 'architecture principles', 'help me define my architecture', 'hexagonal architecture', 'modular monolith', 'ports and adapters', or 'define my architecture style'."
---

# Architecture Refiner

## Step 0: Style Selection

Before anything else, ask the user which architecture style their team uses:

"What architecture style does your team use?

1. **Clean Architecture** (default) — layers (Domain, Application, Interface, Infrastructure), dependency inversion, command/query separation
2. **Hexagonal / Ports & Adapters** — core domain surrounded by ports, adapters on the outside
3. **Modular Monolith** — vertical slices, each module owns its own layers
4. **Custom / Define from scratch** — you describe the layers and rules"

**Branching:**

- **Option 1** → proceed to the clean architecture flow below (existing interview). Template: `./assets/template-clean-arch.md`. Output: `.lattice/standards/architecture.md`. Config key: `paths.architecture`. No `architecture_mode` key needed (defaults to `clean`).
- **Options 2–4** → proceed to the generic architecture flow. Template: `./assets/template-generic.md`. Output: `.lattice/standards/architecture.md`. Config key: `paths.architecture`. Additionally, set `architecture_mode: custom` in `.lattice/config.yaml`.

The rest of this document describes the **clean architecture flow** (Option 1). For the **generic flow** (Options 2–4), read `./assets/template-generic.md` and follow its `<!-- INTERVIEW GUIDANCE: -->` comments. The facilitation approach, conversation style, output assembly, and document quality checks below apply to both flows — substitute the appropriate template, output path, and config key.

## What This Produces

**For clean architecture (Option 1):**

- **Output**: `.lattice/standards/architecture.md` (or custom path from `.lattice/config.yaml` → `paths.architecture`)
- **Two modes**:
  - **Overlay** (`mode: overlay`): A slim document containing only sections that differ from the defaults. The architecture atom reads its embedded clean-architecture defaults first, then applies this document's sections on top. This is the expected common case.
  - **Override** (`mode: override`): A comprehensive standalone document that fully replaces the atom's embedded defaults. For teams that want to define clean architecture from scratch.
- **Default mode**: Overlay -- produces only what the user wants to change
- **Config key**: `paths.architecture` in `.lattice/config.yaml`
- **Template**: Read `./assets/template-clean-arch.md` for the full document structure, default content, and interview guidance comments

**For other styles (Options 2–4):**

- **Output**: `.lattice/standards/architecture.md` (or custom path from `.lattice/config.yaml` → `paths.architecture`)
- **Mode**: Always `override` — there are no embedded defaults to overlay onto for non-clean-architecture styles
- **Config key**: `paths.architecture` in `.lattice/config.yaml`
- **Additional config**: Sets `architecture_mode: custom` in `.lattice/config.yaml`
- **Template**: Read `./assets/template-generic.md` for the document structure and interview guidance comments

## Before You Begin

### Check for existing documents

Before starting the interview, check whether a custom document already exists:

1. Read `.lattice/config.yaml` — check `paths.architecture`.
2. If the relevant path exists (based on the style selected in Step 0), read that file. Ask the user:
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

- **"I agree with everything"** → No custom document needed. Tell the user: "The embedded defaults are already active and match your preferences. No custom document is needed — the architecture atom will use the clean-architecture defaults automatically."
- **"I agree except one section"** → Overlay mode, interview that one section only.
- **"We use CQRS"** → Overlay §3.2 + §4 (they are coupled — CQRS changes the service pattern which changes both flows).
- **"We don't use Providers"** → Overlay §3.4 + §4.2 + §4.3 + §6 (Provider removal ripples through query flow and validation).
- **"We have extra layers"** → Overlay §1 + §2 + §3 (new layers need responsibilities, dependency placement, and per-layer rules).

## Section-by-Section Interview Guide

Read `./assets/template-clean-arch.md` (for clean architecture) or `./assets/template-generic.md` (for other styles) and follow the `<!-- INTERVIEW GUIDANCE: -->` comments for each section. Those comments contain the specific questions to ask, probing questions, and what is customizable vs fixed.

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
6. Section headings must match `clean-architecture-defaults.md` exactly (the atom matches sections by heading)
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

1. If `.lattice/config.yaml` exists and has `paths.architecture`, use that path.
2. Otherwise, default to `.lattice/standards/architecture.md`.

This is the same for all styles — both clean architecture customizations and other styles write to `paths.architecture`.

**Write the document:**
1. Create `.lattice/standards/` directory (and `.lattice/` parent) if it does not exist.
2. Write the document to the determined path.

**Update config:**

For clean architecture (Option 1):
1. If `.lattice/config.yaml` does not exist, create it with:
   ```yaml
   paths:
     architecture: .lattice/standards/architecture.md
   ```
2. If `.lattice/config.yaml` exists but has no `paths.architecture`, add the key. Preserve all existing content.
3. If `.lattice/config.yaml` exists and already has the key, no config change needed.

For other styles (Options 2–4):
1. If `.lattice/config.yaml` does not exist, create it with:
   ```yaml
   paths:
     architecture: .lattice/standards/architecture.md
   architecture_mode: custom
   ```
2. If `.lattice/config.yaml` exists, add or update:
   - `paths.architecture` pointing to the output path
   - `architecture_mode: custom`
   - Preserve all existing content.

**Confirm to user:**

For clean architecture:
"Your architecture document has been written to `[PATH]` in **[overlay|override]** mode. The architecture atom will now use it [on top of the clean-architecture defaults | instead of the clean-architecture defaults]."

For other styles:
"Your architecture document has been written to `[PATH]` with `architecture_mode: custom`. The architecture atom will use it as your project's sole architecture standard."

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

### Generic flow checks (Options 2–4)

- [ ] Document has `mode: override` in frontmatter
- [ ] Sections §1 through §7 are present (§8 Ambiguity Signals is optional, plus any new sections)
- [ ] Layer names are consistent throughout all sections
- [ ] Dependency diagram (§2) matches the layer table (§1)
- [ ] §6 (Validation Checklist) contains at least 3 concrete, verifiable checks
- [ ] §7 (Anti-Patterns) contains at least 3 anti-patterns with symptom and fix
- [ ] No `<!-- INTERVIEW GUIDANCE: -->` comments remain
- [ ] Document is readable as a standalone specification
- [ ] Config has `architecture_mode: custom` set

### Both modes (all flows)

- [ ] Frontmatter is valid YAML with correct mode value
- [ ] Document is well-formatted markdown
- [ ] Config file (`.lattice/config.yaml`) is correctly updated
- [ ] Output path exists and is writable
