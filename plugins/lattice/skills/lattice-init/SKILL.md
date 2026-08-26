---
name: lattice-init
description: "Guided setup and upgrade-check experience for Lattice projects -- scans the repository, detects existing configuration and outdated conventions, suggests refiners and available upgrades in priority order, and creates or reconciles the .lattice/ config. Bridges the gap between installing skills and getting first value, and between upgrading Lattice and adopting its newest conventions. Use when the user says 'lattice init', 'set up lattice', 'initialize lattice', 'get started with lattice', 'configure lattice for this project', 'check for lattice upgrades', or 'upgrade lattice conventions'."
---

# Lattice Init

## Required Skills

Read apply skills order:

1. `framework:knowledge-priming` -- Load project context understand what project is what already exists

## Workflow

### Step 1: Scan the Project

Detect signals about project understand shape existing Lattice state.

**Language/framework detection** -- check files in repo root:
- `package.json` → Node.js / TypeScript
- `tsconfig.json` → TypeScript (confirm over JavaScript)
- `go.mod` → Go
- `pom.xml` or `build.gradle` or `build.gradle.kts` → Java or Kotlin
- `Cargo.toml` → Rust
- `requirements.txt` or `pyproject.toml` or `setup.py` → Python
- `Gemfile` → Ruby
- `*.csproj` or `*.sln` → C# / .NET
- `Package.swift` → Swift

<!-- synced with language-idioms-refiner "Detect the language" -- edit both -->

If multiple language markers are found in the repo root, note all of them and ask the user which is the primary stack before continuing.

**Directory structure** -- list top-level dirs. Identify common patterns:
- `src/`, `lib/`, `app/` → source code
- `test/`, `tests/`, `spec/` → test suites
- `docs/` → documentation
- `cmd/`, `internal/`, `pkg/` → Go project structure
- `domain/`, `infrastructure/`, `application/` → layered architecture

**Existing `.lattice/` state** -- check what Lattice artifacts already exist:
- `.lattice/config.yaml` → central config (check for `language` key)
- `.lattice/standards/language-idioms.md` → language idioms refiner output
- `.lattice/standards/knowledge-base.md` → knowledge priming output
- `.lattice/standards/architecture.md` → architecture refiner output (clean architecture, hexagonal, modular monolith, or custom style)
- `.lattice/standards/clean-code.md` → clean code refiner output
- `.lattice/standards/ddd-principles.md` → DDD refiner output
- `.lattice/standards/review-standards.md` → review refiner output
- `.lattice/context/` → feature context documents (count them)
- `.lattice/learnings/operational-learnings.md` → accumulated operational learnings (managed by learning-harvest atom)
- `.lattice/reviews/review-log.md` → review log
- `.lattice/requirements/index.md` → check shape: if epic sections and feature tables are written directly inside it (no `epics/` directory alongside) and `requirements_layout` is absent from config, flag as **legacy layout — upgrade available**

### Step 2: Present Findings

Present:

```
## Project Scan Results

**Project**: [detected language/framework] at [repo root]
**Structure**: [key directories found]

### Lattice Setup Status

Running mode: **[customized -- standards docs active below / built-in defaults -- full functionality]**

- `.lattice/config.yaml`: [exists / not created yet]
- Language: [detected language / language key from config / not detected]
- Language idioms: [.lattice/standards/language-idioms.md / built-in default]
- Knowledge base: [.lattice/standards/knowledge-base.md / built-in default]
- Architecture standards: [.lattice/standards/architecture.md / built-in default]
- Clean code standards: [.lattice/standards/clean-code.md / built-in default]
- DDD standards: [.lattice/standards/ddd-principles.md / built-in default]
- Review standards: [.lattice/standards/review-standards.md / built-in default]
- Context documents: [N found / none]
- Review learnings: [found at .lattice/learnings/operational-learnings.md / none]
- Review log: [found at .lattice/reviews/review-log.md / none]
- Requirements layout: [sharded / legacy — upgrade available / not found]
```

**STOP (fresh install): if no `.lattice/` state exists at all AND no legacy requirements layout was detected** — create the minimal `.lattice/config.yaml` shown in Step 3, tell the user: "Lattice is ready. It runs on built-in defaults with full functionality. Refiner interviews that pin your team's conventions are optional — ask for them anytime." Skip to Step 4. Do not present the customization menu unprompted.

**STOP: If `.lattice/config.yaml` and all core standards docs exist AND no legacy requirements layout was detected:** Tell user "Lattice fully configured." Skip to Step 4.

**STOP:** if a legacy requirements layout was detected, do not skip on that basis alone — present it as a gap in Step 3 even when everything else is fully configured.

### Step 3: Guided Setup

Reached only when something needs attention (a gap above) or the user asked to customize. Frame every item below as optional refinement -- Lattice is fully functional without any of it.

**Priority order**:

1. **Requirements layout upgrade** (if legacy layout detected in Step 1) -- "Your requirements index uses an older layout that hand-edits one shared file per feature, which causes merge conflicts when multiple developers work in parallel. The current layout shards it by epic and generates rollups from feature files instead of hand-editing them. One-time migration; does not touch any feature file's content beyond a link repointing (a rare exception is surfaced and confirmed, never silent). This upgrade only matters if your team keeps requirements in this repo -- teams tracking requirements in an external system (Jira, Linear, etc.) can skip it."
2. **Knowledge-priming-refiner** (if `.lattice/standards/knowledge-base.md` missing) -- "Captures project identity -- tech stack, architecture, directory layout, conventions. Every other skill uses this context make better decisions."
3. **Language-idioms-refiner** (if `.lattice/standards/language-idioms.md` missing) -- "Defines how your language expresses engineering patterns -- error handling, type system, naming, testing, DI. Multiple atoms use this to adapt pseudocode defaults to your language. Fast interview: proposes language-idiomatic defaults, you confirm or adjust."
4. **Architecture-refiner** (if `.lattice/standards/architecture.md` missing AND project has source code dir) -- "Defines project architecture standards — layer structure, dependency rules, validation checklist. Supports multiple styles: clean architecture (default), hexagonal / ports & adapters, modular monolith, or custom."
5. **DDD-refiner** (if `.lattice/standards/ddd-principles.md` missing AND project has domain folder or domain-like structure) -- "Captures aggregate design rules, entity patterns, domain event conventions so DDD atom enforces domain modeling style."
6. **Clean-code-refiner** (if `.lattice/standards/clean-code.md` missing) -- "Tailors coding standards -- function size limits, complexity thresholds, naming conventions. Defaults work well most projects, so optional."
7. **Review-refiner** (if `.lattice/standards/review-standards.md` missing) -- "Customizes how review molecule works -- atom loading rules, severity levels, report format, scope rules. Defaults work well most projects, so optional."

**For each gap**, present user:
- What it does (one sentence, from descriptions above)
- Three choices: **Run now**, **Skip for later**, or **Skip all remaining**

**If user says "run"**:
- For the requirements layout upgrade → read `references/requirements-migration.md` and follow those steps directly in this session. Confirm the plan (epics detected, files to be created, index.md's new contents) before writing anything.
- For any refiner → tell user to invoke it: "Run `/[refiner-name]` now start guided interview."

**If user says "skip"** → Move to next item in priority order.

**If user says "skip all"** → Jump Step 4.

**Config creation**: If `.lattice/config.yaml` not exist and user not run any refiners (skipped all), create minimal config file:

```yaml
# .lattice/config.yaml -- Lattice Framework Configuration
# All paths are relative to the repository root.
# Runs on built-in defaults until customized -- refiner interviews are optional (see docs/configuration.md).

version: 1
language: {detected-language}
paths: {}
```

If the user runs at least one refiner, the refiner itself creates or updates the config file -- no need to create it here. Either way, set the `language` key from the detected language when the file is created.

### Step 4: Next Steps

```
## You're Ready

Lattice is set up. Here's the workflow:

1. **Design a feature**: `/design-blueprint` -- walks through 5 progressive design levels
2. **Implement**: `/code-forge` -- generates code from the blueprint with built-in quality checks
3. **Refactor safely**: `/refactor-safely` -- agrees the target structure first, adds characterization protection, and improves code without changing behavior
4. **Fix a bug**: `/bug-fix` -- reproduces the failure, adds a regression test, and applies the minimal safe repair
5. **Review**: `/review` -- audits generated code against atom standards

Atoms (architecture, clean-code, DDD, secure-coding, etc.) activate automatically during these workflows.
You can also use atoms standalone -- they apply checks based on what you're working on.
```

If any refiners skipped Step 3, add reminder:

```
### Skipped refiners
You can run these anytime to further customize Lattice for your project:
- [list skipped refiners with their slash commands]
```