# Lattice Convention Rules — Validator Reference

Detailed per-tier checks for the skill-validate. Read this alongside CLAUDE.md.

---

## Atoms

### Required sections (in this order)
1. YAML frontmatter
2. `## Config Resolution`
3. `## Self-Validation Checklist`
4. `## Active Anti-Pattern Scan`
5. `## Ambiguity Signals` *(code-quality atoms only — not knowledge-priming, design-first, context-anchoring, collaborative-judgment)*
6. `## Core Principle`

### Config Resolution checks
- [ ] Reads `.lattice/config.yaml` first
- [ ] Checks `paths.{snake_case_key}` for custom doc path
- [ ] Handles both `mode: overlay` (merge with defaults) and `mode: override` (replace defaults)
- [ ] Falls back to `./references/defaults.md` when no config found
- [ ] Has a `references/defaults.md` file (code-quality atoms) — check it exists

### Self-Validation Checklist checks
- [ ] Each item is numbered
- [ ] Each item has a bold label (`**LABEL**:`)
- [ ] Uses imperative STOP language: "STOP after generating each component. Verify ALL..."
- [ ] Each item has a clear pass/fail condition — not vague guidance
- [ ] Fix instruction is present when a check fails ("If not → [action]")

### Active Anti-Pattern Scan checks
- [ ] Checkbox format: `- [ ] **Pattern Name**: description → fix`
- [ ] Each anti-pattern has: name, what it looks like, what to do
- [ ] At least 5 anti-patterns for code-quality atoms
- [ ] No overlap with the Self-Validation Checklist (scan catches smells, checklist catches hard violations)

### Ambiguity Signals checks
- [ ] Each signal describes a genuinely ambiguous situation (two valid approaches)
- [ ] Each signal has guidance for resolution — not just "it depends"
- [ ] References `framework:collaborative-judgment` or `./references/defaults.md` for resolution

### defaults.md checks
- [ ] Exists at `references/defaults.md`
- [ ] Structured with numbered sections (§1, §2, ...) matching what the refiner produces
- [ ] Contains opinionated defaults — not placeholders or vague guidance
- [ ] Ends with attribution/reference line

---

## Molecules

### Required sections
1. YAML frontmatter
2. `## Required Skills` (with `framework:{atom-name}` references and always/conditional labels)
3. `## Workflow` (numbered steps)
4. Optional: Mode Detection, Persona sections

### Required Skills checks
- [ ] Every atom reference uses `framework:{name}` format
- [ ] Each reference has an always/conditional qualifier
- [ ] Every referenced atom exists in `skills/atoms/{name}/SKILL.md`
- [ ] No atom content is inlined — only references

### Generative molecule checks (code-forge, refactor-safely, bug-fix pattern)
- [ ] No confirmation gates between steps
- [ ] Pauses only on genuine judgment calls via `framework:collaborative-judgment`
- [ ] Linear numbered steps
- [ ] No session resume check required (generative molecules don't maintain living documents across sessions)

### Planning/interactive molecule checks (design-blueprint, plan-transformation, requirement-forge pattern)
- [ ] Step 1 checks for existing output document — if found, reads it and resumes from earliest incomplete step
- [ ] Every phase has: (1) present output, (2) specific targeted question, (3) hard gate language "Do NOT advance to Step N until the user explicitly confirms"
- [ ] Can exit early with partial output as a valid outcome
- [ ] Writes to a named `.lattice/{subfolder}/` — never to `.lattice/` root
- [ ] Subfolder is in CLAUDE.md known subfolders list

### Output document template checks (planning molecules)
- [ ] A template or structure for the output document is defined in the SKILL.md
- [ ] Template includes frontmatter fields (where applicable)
- [ ] Template is complete enough that a new session could read the output and resume work

---

## Refiners

### Required sections
1. YAML frontmatter
2. `## What This Produces` (output path, two modes, config key, template reference)
3. `## Scope Clarification`
4. `## Before You Begin` (check for existing doc, scan repo for signals)
5. `## Choosing the Mode` (overlay vs override)
6. `## Facilitation Approach` (conversation style, overlay flow, override flow)
7. `## Section-by-Section Interview Guide` (reference to template)
8. `## Output Assembly`
9. `## Document Quality Checks`

### What This Produces checks
- [ ] Output path is `.lattice/standards/{name}.md`
- [ ] Both overlay and override modes are described
- [ ] Config key is documented (`paths.{snake_case_key}`)
- [ ] References `./assets/template.md`
- [ ] States which atom (or molecule) consumes the produced document

### Facilitation approach checks
- [ ] Overlay mode: present default briefly, ask if it matches, only record changes
- [ ] Override mode: walk through every section, all sections appear in output
- [ ] Common scenarios listed (e.g., "I agree with everything" → no custom doc needed)

### Template checks (assets/template.md)
- [ ] `<!-- INTERVIEW GUIDANCE: -->` comments present for each section
- [ ] Each guidance block includes: default content summary, what to ask, probing questions, what is customisable vs. fixed
- [ ] Default content is present (not just guidance comments)
- [ ] Frontmatter with `mode:` placeholder
- [ ] Footer with project/date/mode placeholders

### Output Assembly checks
- [ ] Instructions for overlay mode output (only changed sections)
- [ ] Instructions for override mode output (all sections)
- [ ] Config update instructions (how to write/update `.lattice/config.yaml`)
- [ ] Strip all `<!-- INTERVIEW GUIDANCE: -->` comments from final output

### Quality Checks section
- [ ] Overlay mode checks listed as checkboxes
- [ ] Override mode checks listed as checkboxes
- [ ] Both modes share: valid YAML frontmatter, well-formatted markdown, config updated

---

## All tiers — naming and frontmatter

- [ ] `name:` is lowercase-hyphenated (e.g., `requirement-quality`, not `RequirementQuality`)
- [ ] Folder name = `name:` field exactly
- [ ] `description:` includes what the skill does AND trigger phrases (what the user would say)
- [ ] Description is specific enough to trigger correctly — not so narrow it misses valid use cases
- [ ] No YAML syntax errors in frontmatter
