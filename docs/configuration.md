# Configuration Reference

`.ai/config.yaml` is the central config file for a Lattice-enabled project. It maps logical keys to project-specific documents that atoms and molecules load at runtime. The file is optional — all skills work out of the box with embedded defaults. Add keys only when you want to customize a skill's behavior. See [how-it-works.md](how-it-works.md#config-resolution) for how the resolution algorithm works.

## File Structure

```yaml
version: 1
paths:
  knowledge_base: .ai/standards/knowledge-base.md
  clean_code: .ai/standards/clean-code.md
  clean_architecture: .ai/standards/clean-architecture.md
  ddd_principles: .ai/standards/ddd-principles.md
  test_quality: .ai/standards/test-quality.md
  secure_coding: .ai/standards/secure-coding.md
  review_standards: .ai/standards/review-standards.md
  context_base: .ai/context/
```

## Top-level Fields

| Field | Type | Description |
|-------|------|-------------|
| `version` | integer | Schema version. Currently `1`. |
| `paths` | map | Logical key → file path mappings. All keys are optional. |

## `paths` Keys

| Key | Purpose | Produced by | Default path | Consumed by | Mode |
|-----|---------|-------------|--------------|-------------|------|
| `knowledge_base` | Project identity — tech stack, architecture, conventions, trusted sources. No embedded default; every project is unique. | `knowledge-priming-refiner` | `.ai/standards/knowledge-base.md` | `knowledge-priming` atom | `override` (standard) |
| `clean_code` | Code craftsmanship rules — function size, naming, complexity, error handling. | `clean-code-refiner` | `.ai/standards/clean-code.md` | `clean-code` atom | `overlay` (recommended) |
| `clean_architecture` | Layer structure and dependency rules — layer assignments, command/query flows, provider and repository patterns. | `architecture-refiner` | `.ai/standards/clean-architecture.md` | `clean-architecture` atom | `overlay` (recommended) |
| `ddd_principles` | Tactical DDD patterns — aggregate design, entity/value object rules, domain services, domain events. | `ddd-refiner` | `.ai/standards/ddd-principles.md` | `domain-driven-design` atom | `overlay` (recommended) |
| `test_quality` | Test structure and quality rules — AAA structure, isolation, assertion patterns, naming conventions. | `test-quality-refiner` | `.ai/standards/test-quality.md` | `test-quality` atom | `overlay` (recommended) |
| `secure_coding` | Trust boundaries and injection prevention — input validation, secrets management, authorization, error message policies. | `secure-coding-refiner` | `.ai/standards/secure-coding.md` | `secure-coding` atom | `overlay` (recommended) |
| `review_standards` | Review process configuration — atom loading policy, severity classification, report format, insight capture. Molecule-level config, not atom-level. | `review-refiner` | `.ai/standards/review-standards.md` | `review` molecule | `overlay` (recommended) |
| `context_base` | **Directory** path for per-feature living documents. Unlike all other keys, this is a directory, not a file. | (none — managed by `context-anchoring` atom) | `.ai/context/` | `context-anchoring` atom | N/A |

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

`knowledge_base` is always `override` — project identity is unique and replaces generic defaults entirely.

## Creating and Updating Config

**Via a refiner** (recommended): Run the corresponding refiner skill (e.g., `/architecture-refiner`). The guided interview produces the standards document and writes the config key automatically.

**By hand**: Create `.ai/config.yaml` at the repo root and add keys pointing to documents you have written or will write. Re-run a refiner or edit the standards document directly whenever your standards evolve.
