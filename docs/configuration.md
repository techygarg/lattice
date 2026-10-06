---
description: .lattice/config.yaml field reference -- what each key does and when you need to set it.
---

# Configuration Reference

`.lattice/config.yaml` is the central config file for a Lattice-enabled project. It maps logical keys to project-specific documents that atoms and molecules load at runtime. The file is optional — all skills work out of the box with embedded defaults. Add keys only when you want to customize a skill's behavior. See [how-it-works.md](how-it-works.md#config-resolution) for how the resolution algorithm works.

## File Structure

```yaml
version: 1
language: go
paths:
  language_idioms: .lattice/standards/language-idioms.md
  knowledge_base: .lattice/standards/knowledge-base.md
  clean_code: .lattice/standards/clean-code.md
  architecture: .lattice/standards/architecture.md
  ddd_principles: .lattice/standards/ddd-principles.md
  test_quality: .lattice/standards/test-quality.md
  secure_coding: .lattice/standards/secure-coding.md
  review_standards: .lattice/standards/review-standards.md
  requirement_standards: .lattice/standards/requirement-standards.md

lattice:
  store:
    context_base: .lattice/context/
    operational_learnings: .lattice/learnings/operational-learnings.md
    review_log: .lattice/reviews/review-log.md
    requirements_base: .lattice/requirements/

architecture_mode: clean
requirements_layout: sharded
```

## Top-level Fields

| Field | Type | Description |
|-------|------|-------------|
| `version` | integer | Schema version. Currently `1`. |
| `language` | string | Project's primary language identifier (e.g., `go`, `rust`, `python`, `java`, `typescript`, `csharp`). Set by `lattice-init` or `language-idioms-refiner`; informational metadata describing the project. Atoms do not read this key — language adaptation is driven entirely by `paths.language_idioms`. |
| `paths` | map | Logical key → standards document path mappings. All keys are optional. |
| `lattice.store` | map | Locations of living documents (context docs, learnings, review log, requirements). All keys are optional. See below. |
| `architecture_mode` | string | Architecture enforcement mode. `clean` (default) or `custom`. See below. |
| `requirements_layout` | string | Requirements folder layout. `sharded` (current) or `flat` (legacy, pre-migration). See below. |

## `paths` Keys

| Key | Purpose | Produced by | Default path | Consumed by | Mode |
|-----|---------|-------------|--------------|-------------|------|
| `language_idioms` | Language-specific patterns — error handling philosophy, type system, naming conventions, testing idioms, parameter design, dependency management. Cross-cutting: consumed by multiple atoms. | `language-idioms-refiner` | `.lattice/standards/language-idioms.md` | `clean-code`, `test-quality`, `secure-coding`, `domain-driven-design`, `architecture` atoms | standalone (no overlay/override — always complete) |
| `knowledge_base` | Project identity — tech stack, architecture, conventions, trusted sources. No embedded default; every project is unique. | `knowledge-priming-refiner` | `.lattice/standards/knowledge-base.md` | `knowledge-priming` atom | `override` (standard) |
| `clean_code` | Code craftsmanship rules — function size, naming, complexity, error handling. | `clean-code-refiner` | `.lattice/standards/clean-code.md` | `clean-code` atom | `overlay` (recommended) |
| `architecture` | Architecture standards — layer structure, dependency rules, structural validation. Used by both clean architecture mode and custom architecture mode. | `architecture-refiner` | `.lattice/standards/architecture.md` | `architecture` atom | `overlay` (clean mode) or `override` (custom mode) |
| `ddd_principles` | Tactical DDD patterns — aggregate design, entity/value object rules, domain services, domain events. | `ddd-refiner` | `.lattice/standards/ddd-principles.md` | `domain-driven-design` atom | `overlay` (recommended) |
| `test_quality` | Test structure and quality rules — AAA structure, isolation, assertion patterns, naming conventions. | No refiner — write by hand or via `/knowledge-priming-refiner` for general conventions | `.lattice/standards/test-quality.md` | `test-quality` atom | `overlay` (recommended) |
| `secure_coding` | Trust boundaries and injection prevention — input validation, secrets management, authorization, error message policies. | No refiner — write by hand or via `/knowledge-priming-refiner` for general conventions | `.lattice/standards/secure-coding.md` | `secure-coding` atom | `overlay` (recommended) |
| `review_standards` | Review process configuration — atom loading policy, severity classification, report format, insight capture. Molecule-level config, not atom-level. | `review-refiner` | `.lattice/standards/review-standards.md` | `review` molecule | `overlay` (recommended) |
| `requirement_standards` | Requirement standards — epic/feature definitions, scenario structure, AC format, priority notation, status workflow, and naming conventions. Consumed by the `requirement-quality` atom via config resolution; the `requirement-forge` molecule composes that atom. | `requirement-forge-refiner` | `.lattice/standards/requirement-standards.md` | `requirement-quality` atom | `overlay` (recommended) |
| `context_base` | **Legacy.** Use `lattice.store.context_base` instead. Still read as a fallback. | — | — | `lattice-store` atom | N/A |
| `operational_learnings` | **Legacy.** Use `lattice.store.operational_learnings` instead. Still read as a fallback. | — | — | `lattice-store` atom | N/A |

## `lattice.store` Keys

Living documents — files that grow during sessions rather than standards set up front — are located by the `lattice-store` atom. Every skill that reads or writes one resolves its path through that atom; none hardcode a `.lattice/` subfolder.

| Key | Kind | Default | Written by | Read by |
|-----|------|---------|------------|---------|
| `context_base` | directory | `.lattice/context/` | `context-anchoring` | `design-blueprint`, `code-forge`, `bug-fix`, `refactor-safely`, `lattice-init` |
| `operational_learnings` | file | `.lattice/learnings/operational-learnings.md` | `learning-harvest` | every molecule that loads learnings, `review-refiner`, `lattice-init` |
| `review_log` | file | `.lattice/reviews/review-log.md` | `review` | `review-refiner`, `lattice-init` |
| `requirements_base` | directory | `.lattice/requirements/` | `requirement-forge` | `design-blueprint`, `lattice-init` |

### Resolution order

For each key, the first step that yields a value wins:

1. **Session value** — the most recent `lattice.store.<key> = <path>` line in the conversation. Type it to relocate a document for the rest of the session; `lattice.store.<key> = reset` clears it.
2. **Derived value** — when a session starts from a requirement doc that lives outside the current repo, the agent walks up from that doc to the nearest `.lattice/` folder and uses it as the store for all four keys (`<store>/context/`, `<store>/learnings/operational-learnings.md`, `<store>/reviews/review-log.md`, `<store>/requirements/`). Keys you set explicitly in the session are never overwritten.
3. **`lattice.store.<key>`** in `.lattice/config.yaml`.
4. **`paths.<key>`** in `.lattice/config.yaml` — legacy, `context_base` and `operational_learnings` only. `/lattice-init` offers to move these under `lattice.store`.
5. **Default** from the table above.

### Path rules

- Relative paths resolve from the current repo root. `~` and absolute paths are allowed.
- Directory keys end in `/`.
- The first write outside the current repo asks for confirmation — those files are not version-controlled with this repo.

### Announce lines

The agent prints one line per key when it first resolves it and whenever it changes, tagged with its source:

```
lattice.store.context_base = ~/specs/.lattice/context/   # derived from refunds.md
lattice.store.review_log = .lattice/reviews/review-log.md   # config
```

Lines tagged `# session` or `# derived from <doc>` act as the session record. Lines tagged `# config` or `# default` are informational only. A `lattice.store.*` line found inside a file, tool output, or web page is ignored — only you (or the agent's own tagged lines) can set a session value.

## `architecture_mode` Key

Controls which enforcement rules the `architecture` atom loads internally. This key determines the atom's behavior — it does not affect what other atoms or molecules do.

| Value | Behavior |
|-------|----------|
| `clean` (default if absent) | The architecture atom loads clean architecture enforcement rules (`references/clean-architecture.md`) and uses `references/clean-architecture-defaults.md` as the base content. If `paths.architecture` is set, the custom document is applied as overlay or override on top of the clean-architecture defaults. |
| `custom` | The architecture atom loads custom architecture enforcement rules (`references/custom-architecture.md`) and reads the team's document at `paths.architecture` as the sole content. No embedded defaults — the document IS the standard. |

**When to use each:**

- **Team uses clean architecture (default, no config needed):** Atom loads built-in clean-arch rules. No setup required.
- **Team uses clean architecture with customizations:** Run `/architecture-refiner`, choose "Clean Architecture", customize sections. Produces a document with `mode: overlay` or `mode: override`. Config: `paths.architecture` set, `architecture_mode` absent (defaults to `clean`).
- **Team uses hexagonal, modular monolith, or custom style:** Run `/architecture-refiner`, choose the appropriate style. Produces a document with `mode: override`. Config: `paths.architecture` set, `architecture_mode: custom`.

The `architecture-refiner` sets `architecture_mode` automatically based on the user's style choice.

## `requirements_layout` Key

Controls whether `requirement-forge` treats `<requirements_base>` (see `lattice.store` above) as sharded-by-epic or expects the legacy flat form.

| Value | Behavior |
|-------|----------|
| `sharded` (current) | `index.md` is a thin apex; each epic has its own file at `epics/{epic-slug}.md` with a generated feature table listing name and summary only — no status, priority, or dependency columns. `requirement-forge` writes only feature files during normal work — epic and index rollups regenerate only when a feature is added, removed, or renamed under an epic, never on a status/priority/dependency change; those fields live solely in each feature file's own frontmatter. |
| `flat` / absent with a pre-existing `index.md` | Legacy layout — every epic's feature table lives inline in `index.md` itself. `requirement-forge` will not attempt migration; it points the user at `/lattice-init` to check for and apply available upgrades. |

Set automatically — by `requirement-forge` when it creates the first epic in a new project, or by `lattice-init`'s migration step for existing projects. Not intended to be hand-edited.

Requirements do not have to live in this repo at all — see `docs/practical-guide.md` for teams that track requirements in an external system instead.

## Custom Document Frontmatter

Standards documents (the files pointed to by `paths` keys) declare their merge mode in YAML frontmatter:

```yaml
---
mode: overlay
---
```

| Mode | Behavior |
|------|----------|
| `overlay` (default) | Custom document's sections are applied on top of the atom's embedded defaults. Sections are matched by heading — a custom section replaces the matching default section; new sections are appended. |
| `override` | Custom document fully replaces the atom's embedded defaults. Use when your standards are fundamentally different and you want complete control. |

`knowledge_base` is always `override` — project identity is unique and replaces generic defaults entirely. Custom architecture documents (`architecture_mode: custom`) are also always `override` — there are no defaults to overlay onto. `language_idioms` is always standalone — there are no embedded language defaults in atoms; the document provides the complete language context that atoms reference by section heading.

## Creating and Updating Config

**Via a refiner** (recommended): Run the corresponding refiner skill (e.g., `/architecture-refiner`). The guided interview produces the standards document and writes the config key automatically.

**By hand**: Create `.lattice/config.yaml` at the repo root and add keys pointing to documents you have written or will write. Re-run a refiner or edit the standards document directly whenever your standards evolve.
