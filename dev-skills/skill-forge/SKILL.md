---
name: skill-forge
description: "Create a new Lattice skill — atom, molecule, or refiner — following all framework conventions. Writing skill files manually almost always produces convention violations: wrong section order, missing confirmation gates, defaults.md without the right structure. This skill knows all of that and guides you through it. Use whenever adding any new atom, molecule, or refiner to Lattice, or when the user says 'create a new skill', 'add an atom', 'add a molecule', 'add a refiner', 'build X for Lattice', 'new lattice skill', or 'skill forge'. Does not validate, align docs, or deploy — those are separate skills you run after."
---

# Lattice Skill Forge

**Core responsibility:** Create the right files with the right structure for a new Lattice skill.

**Input:** A description of what the skill should do and when it should trigger.

**Output:** One or more skill files written to the correct path:
- Atom → `skills/atoms/{name}/SKILL.md` + `skills/atoms/{name}/references/defaults.md`
- Molecule → `skills/molecules/{name}/SKILL.md`
- Refiner → `skills/refiners/{name}/SKILL.md` + `skills/refiners/{name}/assets/template.md`

**How to verify this skill did its job:**
- All required files exist at the correct paths
- Folder name matches `name:` frontmatter exactly
- All tier-required sections are present in correct order
- No placeholder content — all sections contain real, specific content

---

## Step 1: Understand intent and select tier

Ask the user: *"What should this skill do, and when should it trigger? Describe it briefly."*

From the description, determine the tier:

| The skill... | Tier |
|---|---|
| Enforces ONE principle with a checklist and anti-pattern scan | **Atom** |
| Orchestrates multiple atoms into a multi-step workflow | **Molecule** |
| Runs a guided interview to produce a `.lattice/standards/*.md` file | **Refiner** |

State your read and confirm with the user. Get explicit tier agreement before proceeding.

---

## Step 2: Requirements alignment (molecules and refiners only)

Before writing a single line of SKILL.md, agree on the design.

Check `knowledge-base/` for an existing requirements doc:
```bash
ls knowledge-base/ | grep -i {name}
```

**If found** → read it, summarise key design decisions, confirm they still reflect intent.

**If not found** → resolve these questions through conversation before writing:

For a **molecule:**
- Which atoms does it compose? (Read `skills/atoms/` to see what exists.)
- Is it **generative** (produces code/artifacts, linear flow) or **planning/interactive** (produces living documents, confirmation gates at each phase)?
- What does it write to `.lattice/`? Which subfolder? (Must be a named subfolder, never the root.)
- What is the session resume behavior — how does it handle an interrupted session?

For a **refiner:**
- Which atom does it configure? (A refiner must have an atom that reads its output.)
- What `paths.{snake_case_key}` config key does it add to `.lattice/config.yaml`?
- What sections does the interview template cover?
- Overlay/override — which is the default mode?

Write a one-paragraph design summary and confirm with the user.

**Do NOT write SKILL.md until design is confirmed.**

---

## Step 3: Read current conventions

Read `CLAUDE.md` — the Skill Conventions section. Always read it fresh; never rely on memory.

Note the current skill counts (atoms/molecules/refiners) — they will need updating in CLAUDE.md after creation, but that is `skill-align`'s job.

---

## Step 4: Write the skill files

### Writing an Atom

**`skills/atoms/{name}/SKILL.md`** — sections in this exact order:

1. **YAML frontmatter** — `name` (lowercase-hyphenated), `description` (include trigger phrases)
2. **Config Resolution** — always this pattern:
   - Check `.lattice/config.yaml` for `paths.{config_key}`
   - If found: read doc, check `mode: overlay` (merge with defaults) or `mode: override` (replace)
   - If not found: read `./references/defaults.md`
3. **Self-Validation Checklist** — numbered items, bold label, imperative STOP language, clear pass/fail condition and fix per item
4. **Active Anti-Pattern Scan** — checkbox format (`- [ ] **Name**: what it looks like → fix`), minimum 5 items
5. **Ambiguity Signals** — genuine gray areas where two valid approaches exist; resolution guidance for each
6. **Core Principle** — what the atom governs, what it does NOT govern (boundary with other atoms)

**`skills/atoms/{name}/references/defaults.md`** — the embedded defaults:
- Numbered sections (§1, §2...) matching what a future refiner would produce
- Opinionated, specific content — not placeholders
- End with an attribution line

### Writing a Molecule

**`skills/molecules/{name}/SKILL.md`**:

1. **YAML frontmatter** — name, description with trigger phrases
2. **Required Skills** — list every atom as `framework:{name}` with always/conditional qualifier
3. **Mode Detection** (if the molecule has modes) — how modes are invoked, what each changes
4. **Workflow** — numbered steps with clear inputs and outputs per step

**Generative molecule conventions** (`code-forge`, `bug-fix`, `refactor-safely` pattern):
- Linear numbered steps, no confirmation gates
- Pause only on genuine judgment calls via `framework:collaborative-judgment`
- No session resume check needed

**Planning/interactive molecule conventions** (`design-blueprint`, `requirement-forge` pattern):
- Step 1 MUST check for an existing output document. If found: read it, determine earliest incomplete step, resume from there
- Every phase MUST have three things: (1) present the output, (2) ask a specific targeted question, (3) hard gate: *"Do NOT advance to Step N until the user explicitly confirms."*
- Can exit early — partial output is a valid outcome
- Always writes to a named `.lattice/{subfolder}/` — never to `.lattice/` root

### Writing a Refiner

**`skills/refiners/{name}/SKILL.md`** — cover all of these:
- What it produces (output path, two modes, config key, which atom reads it)
- Scope clarification (what this refiner does NOT configure)
- Check for existing doc before starting interview
- Mode selection conversation (overlay vs override, when to use each)
- Facilitation approach (one section at a time, defaults-first, record decisions not discussion)
- Section-by-section guide (reference `./assets/template.md` and its Interview Guidance comments)
- Output assembly rules (overlay: only changed sections; override: all sections)
- Config update instructions (write `paths.{key}` to `.lattice/config.yaml`)
- Document quality checks (one checklist per mode)

**`skills/refiners/{name}/assets/template.md`**:
- Full document structure with `<!-- INTERVIEW GUIDANCE: -->` comments per section
- Each guidance block contains: default content, what to ask, probing questions, what is customisable vs. fixed
- Overlay preamble and override preamble (separate blocks, clearly labeled)
- Footer with project/date/mode placeholders
- INTERVIEW GUIDANCE comments are stripped from the final produced document

---

## Step 5: Confirm files are complete

Before finishing, verify:
- [ ] All required files exist at the correct paths
- [ ] Folder name = `name:` frontmatter field (exactly, character by character)
- [ ] `description:` contains trigger phrases — what a user would actually type to invoke this
- [ ] All tier-specific sections are present in the correct order
- [ ] For atoms: `defaults.md` exists and has §-numbered sections with real content
- [ ] For refiners: `template.md` exists with Interview Guidance comments in every section
- [ ] For planning molecules: every phase has the three-part confirmation gate pattern
- [ ] No section contains placeholder text ("TBD", "TODO", "add content here")

Report what was created and where. Do not run validation, sync, or deploy — those are separate steps.
