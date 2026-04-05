---
name: review-refiner
description: "Facilitate a structured conversation to customize how the review molecule works -- atom loading rules, severity classification, report format, scope rules, insight capture, and health logging. Produces a formal review-standards.md document that the review molecule will use as its process configuration. Use when the user says 'customize review', 'configure review', 'review preferences', 'review settings', 'change review process', or 'set up review'."
---

# Review Refiner

## What This Produces

- **Output**: `.ai/standards/review-standards.md` (or custom path from `.ai/config.yaml` → `paths.review_standards`)
- **Two modes**:
  - **Overlay** (`mode: overlay`): A slim document containing only sections that differ from the defaults. The review molecule reads its embedded defaults first, then applies this document's sections on top. This is the expected common case.
  - **Override** (`mode: override`): A comprehensive standalone document that fully replaces the molecule's embedded defaults. For teams with fundamentally different review processes.
- **Default mode**: Overlay -- produces only what the user wants to change
- **Config key**: `paths.review_standards` in `.ai/config.yaml`
- **Consumed by**: The review molecule (NOT an atom -- this is the first molecule-level config)
- **Template**: Read `./assets/template.md` for the full document structure, default content, and interview guidance comments

### Scope Clarification

This refiner configures the review *process* -- how the review molecule orchestrates atom output. It does NOT configure what atoms check for.

| Belongs here (process orchestration) | Belongs in atom refiners (quality standards) |
|---------------------------------------|----------------------------------------------|
| Which atoms load and when | What checks an atom runs |
| Severity level definitions | What constitutes a violation |
| Report format and grouping | Checklist items and anti-patterns |
| Delta scope rules | Layer definitions, naming rules |
| Insight capture preferences | Domain modeling rules |
| Health log format | Security check thresholds |
| Custom review dimensions | Atom-specific validation logic |

If a user asks about changing what an atom checks for, redirect them to the appropriate atom refiner (architecture-refiner, clean-code-refiner, ddd-refiner).

## Before You Begin

### Check for existing documents

Before starting the interview, check whether a custom document already exists:

1. Read `.ai/config.yaml` — does `paths.review_standards` point to a file?
2. If yes, read that file. Ask the user:
   - "You already have a review standards document. Would you like to **revise** it (update specific sections), **start fresh** (new interview), or **add to it** (add new sections)?"
   - Revise: Load the existing document, walk through only the sections the user wants to change, and update in place.
   - Start fresh: Proceed with the full interview flow below.
   - Add to it: Skip to the sections the user wants to add (e.g., custom dimensions).
3. If no config or no existing document, proceed with the full interview flow.

### Scan for context

Look for signals that inform the conversation:

- **Existing review history**: Check `.ai/reviews/review-log.md` — what atoms have been loading? What severity patterns exist? Are there recurring findings?
- **Existing learnings**: Check `.ai/learnings/review-insights.md` — what patterns has the review captured? Is the file growing large (near pruning threshold)?
- **Project structure**: What does the codebase look like? Are there directories that should be excluded or always-scanned?
- **Existing atom refiners**: Which atom refiners have been run? (Check `.ai/config.yaml` for `paths.architecture`, `paths.clean_code`, `paths.ddd_principles`) This tells you which atoms the team cares about.

Share relevant findings with the user at the start: "I looked at your review history and noticed [patterns]. I'll use that as context for our conversation."

If the project is new with no review history, proceed with defaults as the starting point.

## Choosing the Mode

The first decision in the conversation. Present the three options:

"How would you like to configure your review process?

1. **Customize specific sections** (overlay) — Keep the defaults and change only what differs for your project. This produces a slim document. Most teams choose this.
2. **Define everything from scratch** (override) — Walk through all sections and produce a comprehensive standalone document.
3. **Add project-specific sections only** (overlay with additions) — Keep all defaults as-is and add new sections for your team's specific rules (e.g., custom review dimensions).

The defaults cover a solid review workflow. Option 1 is recommended unless your review process needs to be fundamentally different."

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
5. At the end, ask: "Any additional review process preferences you'd like to add?" (e.g., custom dimensions, extra report sections).
6. Only sections the user changed or added appear in the output document.

### For override mode

This is thorough. Every section gets attention and appears in the output.

1. Walk through every section in full detail.
2. User confirms, modifies, or replaces each section.
3. All sections appear in the output -- defaults for unchanged ones, user's version for changed ones.

### Common scenarios

- **"I agree with everything"** → No custom document needed. Tell the user: "The embedded defaults are already active and match your preferences. No custom document is needed — the review molecule will use the defaults automatically."
- **"I want security checks on every review"** → Overlay §1 only: move `secure-coding` from conditional to always-loaded.
- **"I want stricter severity for security findings"** → Overlay §1 + §2 (atom loading is coupled with per-atom severity overrides).
- **"We want to exclude generated code from reviews"** → Overlay §4 only: add directory exclusion.
- **"We want performance checks in reviews"** → Overlay §7 only: add a Performance Patterns custom dimension.
- **"We want a different report format"** → Overlay §3 only: adjust grouping, format, or toggle "What's done well."
- **"Our insights file is getting too big"** → Overlay §5 only: adjust pruning threshold or add categorization.

## Section-by-Section Interview Guide

Read `./assets/template.md` and follow the `<!-- INTERVIEW GUIDANCE: -->` comments for each section. Those comments contain the specific questions to ask, probing questions, and what is customizable vs fixed.

### Cross-section dependency table

Decisions in early sections affect later sections. When a user changes an early section, flag the dependent sections:

| Decision in | Affects | How |
|-------------|---------|-----|
| §1 Atom Loading | §2, §3, §5, §6 | Per-atom severity overrides reference atom names; report sections map to loaded atoms; insight categories follow atoms; log atom names must match |
| §2 Severity | §3, §5, §6, §7 | Report ordering follows severity levels; capture criteria reference severity; log counts use severity names; custom dimensions need severity assignment |
| §4 Scope Rules | §1, §7 | Expanded scope may trigger more conditional atoms; custom dimensions follow scope rules |
| §7 Custom Dimensions | §2, §3 | Custom dimensions contribute findings needing severity classification and report placement |

When a dependency is triggered, inform the user: "Since you changed [X], we should also review [Y] — it's affected by that decision."

### Overlay-specific section flow

For each of the 7 default sections:

1. Summarize the section's key points in 2-3 sentences.
2. Ask: "Does this match your project?"
3. **Yes** → Move to the next section. This section will not appear in the output.
4. **No** → Dive into the section details using the template guidance. Produce the user's version.
5. After all 7 sections, ask about new sections.
6. Only sections the user changed or added appear in the output document.

### Override-specific section flow

For each of the 7 default sections:

1. Present the section's full content.
2. Ask: "Does this work as-is, or would you like to modify it?"
3. **As-is** → Include the default content in the output unchanged.
4. **Modify** → Discuss changes, produce the modified version.
5. After all 7 sections, ask about new sections.
6. All sections go in the output.

## Output Assembly

### For overlay mode

1. YAML frontmatter: `mode: overlay`
2. Overlay preamble text (from template)
3. Table of contents listing only the included sections
4. Only the sections the user changed or added
5. Each section must be self-contained — it is a complete replacement of that section in defaults. Do not write diffs or partial sections.
6. Section headings must match the template exactly (the review molecule matches sections by heading)
7. New sections (§8+) are included after the default sections
8. Footer with project name, date, mode

### For override mode

1. YAML frontmatter: `mode: override`
2. Override preamble text (from template)
3. Full table of contents (all 7+ sections)
4. All sections: defaults for unchanged, user's version for changed, new sections at the end
5. Footer with project name, date, mode

### For both modes

Strip all `<!-- INTERVIEW GUIDANCE: -->` comments from the output. The final document is a clean specification.

**Determine output path:**
1. If `.ai/config.yaml` exists and has `paths.review_standards`, use that path.
2. Otherwise, default to `.ai/standards/review-standards.md`.

**Write the document:**
1. Create `.ai/standards/` directory (and `.ai/` parent) if it does not exist.
2. Write the document to the determined path.

**Update config:**
1. If `.ai/config.yaml` does not exist, create it with:
   ```yaml
   paths:
     review_standards: .ai/standards/review-standards.md
   ```
2. If `.ai/config.yaml` exists but has no `paths.review_standards`, add the key. Preserve all existing content.
3. If `.ai/config.yaml` exists and already has the key, no config change needed.

**Confirm to user:**
"Your review standards document has been written to `[PATH]` in **[overlay|override]** mode. The review molecule will now use it [on top of the defaults | instead of the defaults] when running reviews."

## Document Quality Checks

Before writing the final document, verify:

### Overlay mode checks

- [ ] Each included section is self-contained and complete (not a diff or partial section)
- [ ] Section headings match the template exactly (for section matching by the review molecule)
- [ ] No `<!-- INTERVIEW GUIDANCE: -->` comments remain
- [ ] Frontmatter has `mode: overlay`
- [ ] Only changed/added sections are included — unchanged sections are omitted
- [ ] Per-atom severity overrides reference atoms that are actually loadable (§1 ↔ §2 consistency)
- [ ] Custom dimension severity levels exist in §2's severity list (§7 ↔ §2 consistency)

### Override mode checks

- [ ] Every section from the template is present (§1 through §7, plus any new sections)
- [ ] Severity levels are consistent throughout all sections
- [ ] Per-atom overrides reference valid atom names
- [ ] Custom dimensions use severity levels defined in §2
- [ ] Report preferences reference valid grouping strategies
- [ ] No `<!-- INTERVIEW GUIDANCE: -->` comments remain
- [ ] Frontmatter has `mode: override`
- [ ] Document is readable as a standalone specification

### Both modes

- [ ] Frontmatter is valid YAML with correct mode value
- [ ] Document is well-formatted markdown
- [ ] Config file (`.ai/config.yaml`) is correctly updated
- [ ] Output path exists and is writable
- [ ] Cross-section dependencies are consistent (atom names, severity levels, categories)
