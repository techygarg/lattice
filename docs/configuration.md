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
  context_base: .lattice/context/

architecture_mode: clean
```

## Top-level Fields

| Field | Type | Description |
|-------|------|-------------|
| `version` | integer | Schema version. Currently `1`. |
| `language` | string | Project's primary language identifier (e.g., `go`, `rust`, `python`, `java`, `typescript`, `csharp`). Set by `lattice-init` or `language-idioms-refiner`. Used as fallback by atoms when `paths.language_idioms` document is not present. |
| `paths` | map | Logical key → file path mappings. All keys are optional. |
| `architecture_mode` | string | Architecture enforcement mode. `clean` (default) or `custom`. See below. |

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
| `context_base` | **Directory** path for per-feature living documents. Unlike all other keys, this is a directory, not a file. | (none — managed by `context-anchoring` atom) | `.lattice/context/` | `context-anchoring` atom | N/A |

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
