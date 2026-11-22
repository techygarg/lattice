---
name: clean-code-refiner
description: "Facilitate a structured conversation to define clean code principles for a repository. Produces a formal clean-code.md document that the clean-code atom will use as its override. Use when setting up coding standards, defining code quality rules, or when the user says 'setup clean code', 'define coding standards', 'code quality principles', 'coding guidelines', or 'help me define my code standards'."
---

# Clean Code Refiner

## What This Produces

- **Output**: `.lattice/standards/clean-code.md` (or custom path from `.lattice/config.yaml` -> `paths.clean_code`)
- **Two modes**:
  - **Overlay** (`mode: overlay`): A slim document containing only sections that differ from the defaults. The clean-code atom reads its embedded defaults first, then applies this document's sections on top. This is the expected common case.
  - **Override** (`mode: override`): A comprehensive standalone document that fully replaces the atom's embedded defaults. For teams with fundamentally different coding standards.
- **Default mode**: Overlay -- produces only what the user wants to change
- **Config key**: `paths.clean_code` in `.lattice/config.yaml`
- **Template**: Read `./assets/template.md` for the full document structure, default content, and interview guidance comments

## Scope Clarification

This skill defines the *rules of code craftsmanship* -- how individual functions, classes, and modules should be written. It does not define architecture (that is the architecture-refiner) or domain modeling (that is the ddd-refiner). The boundaries:

- **Clean code** -- function size, naming, complexity, error handling, testability, abstraction discipline
- **Clean architecture** -- layers, dependency direction, command/query flows, structural placement
- **DDD** -- aggregates, entities, value objects, domain events, repository patterns

## Before You Begin

### Check for existing documents

Before starting the interview, check whether a custom document already exists:

1. Read `.lattice/config.yaml` -- does `paths.clean_code` point to a file?
2. If yes, read that file. Ask the user:
   - "You already have a custom clean code document. Would you like to **revise** it (update specific sections), **start fresh** (new interview), or **add to it** (add new sections)?"
   - Revise: Load the existing document, walk through only the sections the user wants to change, and update in place.
   - Start fresh: Proceed with the full interview flow below.
   - Add to it: Skip to the "New Sections" part of the interview.
3. If no config or no existing document, proceed with the full interview flow.

### Scan the repository

Look for signals that inform the conversation:

- **Linter configs**: ESLint, Pylint, Rubocop, etc. -- what rules are already enforced? What complexity thresholds are configured?
- **Formatter configs**: Prettier, Black, gofmt -- what formatting decisions are already automated?
- **Existing code style**: Are functions generally short or long? Imperative or functional? Heavy on comments or sparse?
- **Test patterns**: What testing framework? Co-located or separate? Mocking patterns?
- **Language**: TypeScript, Python, Go, Java, etc. -- language idioms affect naming conventions and error handling patterns.

Share relevant findings with the user at the start: "I noticed your project has ESLint configured with max-complexity: 15 and uses Prettier for formatting. I'll use that as context."

If the project is new with no code, proceed with pure defaults as the starting point.

## Choosing the Mode

The first decision in the conversation. Present the three options:

"How would you like to define your clean code principles?

1. **Customize specific sections** (overlay) -- Keep the defaults and change only what differs for your project. This produces a slim document. Most teams choose this.
2. **Define everything from scratch** (override) -- Walk through all sections and produce a comprehensive standalone document.
3. **Add project-specific sections only** (overlay with additions) -- Keep all defaults as-is and add new sections for your team's specific rules.

The defaults cover standard clean code practices well. Option 1 is recommended unless your coding standards are fundamentally different."

Map the choice:
- Options 1 and 3 -> `mode: overlay`
- Option 2 -> `mode: override`

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
3. If the user says it matches -> skip it (section will NOT appear in the output).
4. If the user wants changes -> dive into that section, discuss the specifics, record the changes.
5. At the end, ask: "Any sections you'd like to add that aren't in the defaults?" (e.g., language-specific idioms, framework patterns).
6. Only sections the user changed or added appear in the output document.

### For override mode

This is thorough. Every section gets attention and appears in the output.

1. Walk through every section in full detail.
2. User confirms, modifies, or replaces each section.
3. All sections appear in the output -- defaults for unchanged ones, user's version for changed ones.

### Common scenarios

- **"I agree with everything"** -> No custom document needed. Tell the user: "The embedded defaults are already active and match your preferences. No custom document is needed -- the clean-code atom will use the defaults automatically."
- **"I agree except one section"** -> Overlay mode, interview that one section only.
- **"We use shorter functions"** -> Overlay §2 (thresholds change from ~20 to whatever the team prefers).
- **"We use Result types instead of exceptions"** -> Overlay §8 (error handling patterns change fundamentally).
- **"We're a functional team -- no classes"** -> Overlay §1 (remove class cohesion guidance), §5 (parameter patterns for functional style), §9 (functional patterns emphasis).
- **"We want stricter complexity limits"** -> Overlay §3 (adjust thresholds, e.g., max complexity 5 instead of 10).
- **"We have language-specific idioms"** -> Overlay with additions, e.g., §11 Go-specific patterns, §12 Python-specific patterns.

## Section-by-Section Interview Guide

Read `./assets/template.md` and follow the `<!-- INTERVIEW GUIDANCE: -->` comments for each section. Those comments contain the specific questions to ask, probing questions, and what is customizable vs fixed.

### Cross-section dependency table

Decisions in early sections affect later sections. When a user changes an early section, flag the dependent sections:

| Decision in | Affects | How |
|-------------|---------|-----|
| §1 -- SRP scope (classes vs functions-only) | §2 (extraction targets), §10 (checklist) | Functional codebases extract to functions only; class-based codebases also extract to classes |
| §2 -- Function size thresholds | §3 (complexity thresholds), §10 (checklist) | Shorter functions imply lower complexity budgets |
| §3 -- Complexity thresholds | §2 (function size) | Lower complexity limits may require stricter function size |
| §4 -- Naming conventions | §7 (comment necessity) | Better naming reduces the need for "what" comments |
| §5 -- Parameter design | §1 (SRP signals) | Long parameter lists often signal SRP violations |
| §8 -- Error handling strategy | §9 (testability patterns) | Result types vs exceptions change how error paths are tested |

When a dependency is triggered, inform the user: "Since you changed [X], we should also review [Y] -- it's affected by that decision."

### Overlay-specific section flow

For each of the 10 default sections:

1. Summarize the section's key points in 2-3 sentences.
2. Ask: "Does this match your project?"
3. **Yes** -> Move to the next section. This section will not appear in the output.
4. **No** -> Dive into the section details using the template guidance. Produce the user's version.
5. After all 10 sections, ask about new sections.

### Override-specific section flow

For each of the 10 default sections:

1. Present the section's full content.
2. Ask: "Does this work as-is, or would you like to modify it?"
3. **As-is** -> Include the default content in the output unchanged.
4. **Modify** -> Discuss changes, produce the modified version.
5. After all 10 sections, ask about new sections.
6. All sections go in the output.

## Output Assembly

### For overlay mode

1. YAML frontmatter: `mode: overlay`
2. Overlay preamble text (from template)
3. Table of contents listing only the included sections
4. Only the sections the user changed or added
5. Each section must be self-contained -- it is a complete replacement of that section in defaults. Do not write diffs or partial sections.
6. Section headings must match `defaults.md` exactly (the atom matches sections by heading)
7. New sections (§11+) are included after the default sections
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
1. If `.lattice/config.yaml` exists and has `paths.clean_code`, use that path.
2. Otherwise, default to `.lattice/standards/clean-code.md`.

**Write the document:**
1. Create `.lattice/standards/` directory (and `.lattice/` parent) if it does not exist.
2. Write the document to the determined path.

**Update config:**
1. If `.lattice/config.yaml` does not exist, create it with:
   ```yaml
   paths:
     clean_code: .lattice/standards/clean-code.md
   ```
2. If `.lattice/config.yaml` exists but has no `paths.clean_code`, add the key. Preserve all existing content.
3. If `.lattice/config.yaml` exists and already has the key, no config change needed.

**Confirm to user:**
"Your clean code document has been written to `[PATH]` in **[overlay|override]** mode. The clean-code atom will now use it [on top of the defaults | instead of the defaults]."

## Document Quality Checks

Before writing the final document, verify:

### Overlay mode checks

- [ ] Each included section is self-contained and complete (not a diff or partial section)
- [ ] Section headings match `defaults.md` exactly (for section matching by the atom)
- [ ] No `<!-- INTERVIEW GUIDANCE: -->` comments remain
- [ ] Frontmatter has `mode: overlay`
- [ ] Only changed/added sections are included -- unchanged sections are omitted

### Override mode checks

- [ ] Every section from the template is present (§1 through §10, plus any new sections)
- [ ] Thresholds are consistent across sections (function size aligns with complexity limits)
- [ ] Code examples use pseudocode (language-agnostic, same style as defaults.md)
- [ ] Validation checklist (§10) is consistent with the principles defined in §1 through §9
- [ ] No `<!-- INTERVIEW GUIDANCE: -->` comments remain
- [ ] Frontmatter has `mode: override`
- [ ] Document is readable as a standalone specification

### Both modes

- [ ] Frontmatter is valid YAML with correct mode value
- [ ] Document is well-formatted markdown
- [ ] Config file (`.lattice/config.yaml`) is correctly updated
- [ ] Output path exists and is writable
