# Contributing to Lattice

Thank you for your interest in contributing. Lattice is a framework of composable AI skills — markdown files that teach AI assistants structured engineering thinking. There is no runtime, no build step, no compiled code. Contributions are skill files, documentation, and the ideas behind them.

This guide explains how to contribute effectively. Read it before opening a PR — conventions matter here because skill files are read by AI assistants, and small structural choices affect how reliably they are followed.

---

## Ways to Contribute

- **New skills** — new atoms, molecules, or refiners
- **Improve existing skills** — sharper rules, better anti-pattern scans, clearer checklists
- **Fix documentation** — gaps, inaccuracies, outdated content
- **Report issues** — broken skill behavior, documentation bugs, missing use cases
- **Suggest ideas** — open a discussion before investing time in a large new skill

---

## Before You Start

If you're new to Lattice, spend 5 minutes with the [README](../README.md) — it gives you the mental model of atoms, molecules, refiners, and the pipeline. This guide is self-contained from there.

### Check existing issues and discussions

Search open issues before starting. If you're planning a new skill, open a discussion first — especially for molecules and refiners, which have broader scope and are worth aligning on before writing.

### Understand the three tiers

Every contribution fits into one of three tiers. Getting the tier right matters — a checklist-style guardrail is an atom; an orchestrated workflow is a molecule; a guided interview that produces config is a refiner.

| Tier | What it is | When to add one |
|------|-----------|-----------------|
| **Atom** | Single-principle guardrail | You have a specific engineering principle that should be enforced consistently during code generation or review |
| **Molecule** | Multi-step workflow composing atoms | You have a workflow that coordinates several atoms in a defined sequence |
| **Refiner** | Guided interview producing `.lattice/standards/*.md` | Teams need to customize how an atom or molecule behaves for their project |

If you're unsure which tier fits, open a discussion.

---

## Local Setup

Clone and start editing — there is no build step, no dependencies, no install:

```bash
git clone https://github.com/techygarg/lattice.git
cd lattice
```

Skills are plain markdown files. Open any `SKILL.md` in an editor and you're working.

## Repository Structure

```
skills/
├── atoms/{skill-name}/
│   ├── SKILL.md              # The skill itself
│   └── references/
│       └── defaults.md       # Embedded defaults (code-quality atoms only)
├── molecules/{skill-name}/
│   └── SKILL.md
└── refiners/{skill-name}/
    ├── SKILL.md
    └── assets/
        └── template.md       # Interview output template
docs/                         # Framework documentation
tools/
└── install.sh                # Copies skills into an AI tool's skills directory
sample/                       # .NET 8 User Service spec — use this to test your skill
```

---

## Skill Conventions

### All skills — required frontmatter

Every `SKILL.md` must open with YAML frontmatter:

```yaml
---
name: skill-name
description: "Trigger-phrase-rich description of when and why to invoke this skill."
---
```

**Rules:**
- `name` — lowercase kebab-case. Must exactly match the skill's folder name.
- `description` — include specific trigger phrases users or the AI would say. Pull from the actual phrasing people use. Example from `clean-code`: `"when the user mentions 'clean code', 'code quality', 'refactor this', 'simplify this', 'make this cleaner'"`. Vague descriptions like `"applies best practices"` are rejected.
- Folder name must match `name` exactly: skill named `test-quality` lives in `skills/atoms/test-quality/`.
- Config keys in `.lattice/config.yaml` use snake_case of the skill name: `test-quality` → `paths.test_quality`.

---

### Adding an Atom

Atoms teach one engineering principle. The canonical example is `skills/atoms/clean-code/SKILL.md`.

**Section order — mandatory:**

```
## Config Resolution
## Self-Validation Checklist
## Active Anti-Pattern Scan
[principle content sections]
## Ambiguity Signals    ← code-quality atoms only
```

**Config Resolution** — all code-quality atoms support project customization. Copy this pattern:

```markdown
## Config Resolution

1. Look `.lattice/config.yaml` in repo root
2. If found, check `paths.your_skill_key` for custom doc path
3. If custom path exists, read doc and check YAML frontmatter for `mode`:
   - **`mode: override`**: Custom doc full precedence. Must be comprehensive.
   - **`mode: overlay`**: Read embedded `./references/defaults.md` first, then apply custom sections on top.
4. If no config/path/file, read `./references/defaults.md`
```

**Self-Validation Checklist** — numbered, labeled, imperative STOP language:

```markdown
## Self-Validation Checklist

STOP after generating each component. Verify ALL before proceeding.

1. **PRINCIPLE NAME**: Specific check question? If not → specific corrective action.
2. **ANOTHER PRINCIPLE**: ...
```

Key requirements:
- Use `STOP` language — creates a cognitive boundary for the AI
- Each item: label in **BOLD CAPS**, check question, consequence ("If not → fix")
- Numbered, not bulleted

**Active Anti-Pattern Scan** — checkbox format:

```markdown
## Active Anti-Pattern Scan

- [ ] Pattern Name: Description — corrective action
- [ ] Another Pattern: ...
```

The checkbox format triggers completion behavior in AI assistants — more reliable than prose lists.

**`references/defaults.md`** — required for code-quality atoms. Contains the atom's opinionated default rules. Teams can overlay or override this via config. Special atoms (`knowledge-priming`, `design-first`, `context-anchoring`, `collaborative-judgment`) do not have defaults.md — do not add one to these.

**Ambiguity Signals** — required for code-quality atoms. Documents the genuine gray areas where the AI should surface a decision to the user rather than silently choosing:

```markdown
## Ambiguity Signals

Surface these as judgment calls rather than deciding silently:
- Situation where multiple valid approaches exist and the choice matters
- Another genuine gray area
```

**What makes a good atom:**
- Enforces exactly one principle — not two related ones bundled together
- Rules are specific and verifiable, not generic ("avoid large functions" → "functions over 20 lines doing more than one thing violate SRP — extract")
- Anti-patterns are concrete and recognizable, not abstract

---

### Adding a Molecule

Molecules orchestrate atoms into multi-step workflows. The canonical example is `skills/molecules/code-forge/SKILL.md`.

**Required section:**

```markdown
## Required Skills

Read, apply:

1. `framework:knowledge-priming` -- reason this atom is needed (always)
2. `framework:clean-code` -- reason (always)
3. `framework:domain-driven-design` -- reason (conditional: domain layer only)
```

The prefix is `framework:` — not `lattice:`. List every atom the molecule composes, with a brief note on when it applies (always vs conditional). The molecule references and applies atoms — it never copies or duplicates atom content.

**Workflow steps** — numbered, clear, reference atoms by name:

```markdown
## Workflow

### Step 1 — Load Context
Apply `framework:knowledge-priming`. Load the project's identity...

### Step 2 — [Action]
...

### Step N — Verify
Apply atom checklists: run `framework:clean-code` self-validation, `framework:architecture` anti-pattern scan...
```

**What makes a good molecule:**
- Each step has a clear input and output
- Atoms are applied at the right stage, not all at once
- The molecule adds workflow value — if it's just "apply atom A then atom B," that's not a molecule worth adding
- Never inline an atom's rules — reference the atom and tell the AI to apply it

---

### Adding a Refiner

Refiners run a guided interview and write a standards document to `.lattice/standards/`. The canonical example is `skills/refiners/architecture-refiner/SKILL.md`.

**Structure:**

```markdown
## Purpose
One sentence: what this refiner produces and why.

## Interview
Questions organized in logical groups. Ask one group at a time.

### Group 1 — [Topic]
1. Question one
2. Question two

## Output
Writes `.lattice/standards/{filename}.md`.
Instructions for what the output document should contain.
Strip all `<!-- INTERVIEW GUIDANCE -->` comments from output.
```

**`assets/template.md`** — required. The output template with embedded guidance:

```markdown
---
mode: overlay
---

# [Standard Name]

## Section One
<!-- INTERVIEW GUIDANCE: Ask the user about X. If they say Y, write Z. -->

[placeholder content]
```

The `<!-- INTERVIEW GUIDANCE: -->` comments guide the AI during the interview and are stripped from the final output written to `.lattice/standards/`.

**Output modes** — refiners must support both:
- `mode: overlay` (default) — customizations on top of atom defaults. Document only what differs.
- `mode: override` — full replacement of atom defaults. Document must be comprehensive.

---

## Testing Your Skill

There is no automated test suite. Testing is manual — run the skill against a real project using your AI tool.

**Step 1 — Install into your AI tool:**

```bash
./tools/install.sh /path/to/your-ai-tool/skills/
# Claude Code: ~/.claude/skills/
# Cursor:      /path/to/project/.cursor/skills/
```

**Step 2 — Try it against the sample project.** The `sample/` folder contains a realistic .NET 8 User Service spec. Copy it into an empty directory and use it as a test target — it has domain concepts, constraints, and requirements that stress-test atoms well.

**Step 3 — Invoke your skill** in the AI tool's chat and verify:
- For atoms: does it enforce the principle correctly? Does it catch violations? Does it flag the right ambiguities?
- For molecules: does each step execute in order? Are atom checks applied at the right stage?
- For refiners: does the interview flow naturally? Does the output template produce a usable standards document?

**Step 3 — Test edge cases:**
- What happens when the AI encounters a clear violation? Does it fix it?
- What happens with a judgment call? Does it surface it or silently choose?
- Does the skill work without any `.lattice/config.yaml` present (defaults path)?

---

## Pull Request Guidelines

### What to include

- **The skill file(s)** — `SKILL.md` and any supporting files (`defaults.md`, `template.md`)
- **A brief test note** — what you tested it against, what you observed
- **Documentation updates** — if you added a skill, update `docs/how-it-works.md`'s skill inventory table

### What reviewers check

- Frontmatter: `name` matches folder, description has trigger phrases
- Atom structure: correct section order, STOP language, checkbox anti-patterns
- Molecule structure: Required Skills section present, no inlined atom content
- Refiner structure: assets/template.md present, both overlay and override modes addressed
- Principle focus: atoms enforce exactly one thing
- No generic language: every rule is specific and actionable

### PR title format

```
feat(atoms): add accessibility atom
fix(molecules): correct code-forge step ordering
docs: update skill inventory in how-it-works.md
refactor(refiners): clarify ddd-refiner interview flow
```

### One skill per PR

Keep PRs focused. One new atom, or one fixed molecule, or one documentation update. Bundling unrelated changes makes review harder and slows merging.

---

## What We Won't Merge

- Skills that duplicate an existing skill's principle — improve the existing one instead
- Generic instructions ("apply best practices", "write clean code") without specific, verifiable rules
- Atoms that try to cover multiple principles — split them
- Molecules that inline atom content rather than referencing atoms
- Skills without trigger phrases in the description
- Code or runtime dependencies — Lattice is markdown only

---

## Questions

Open a [GitHub Discussion](https://github.com/techygarg/lattice/discussions) for anything not covered here.
