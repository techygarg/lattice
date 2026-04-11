---
name: lattice-init
description: "Guided setup experience for new Lattice projects -- scans the repository, detects existing configuration, suggests refiners in priority order, and creates the .lattice/ config. Bridges the gap between installing skills and getting first value. Use when the user says 'lattice init', 'set up lattice', 'initialize lattice', 'get started with lattice', or 'configure lattice for this project'."
---

# Lattice Init

## Required Skills

Read apply skills order:

1. `framework:knowledge-priming` -- Load project context understand what project is what already exists

## Workflow

### Step 1: Scan the Project

Detect signals about project understand shape existing Lattice state.

**Language/framework detection** -- check files repo root:
- `package.json` → Node.js / TypeScript
- `go.mod` → Go
- `pom.xml` or `build.gradle` → Java
- `Cargo.toml` → Rust
- `requirements.txt` or `pyproject.toml` → Python
- `Gemfile` → Ruby
- `*.csproj` or `*.sln` → C# / .NET

If multiple language markers found repo root, note all ask user which primary stack use refiner suggestions before continuing.

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
- `.lattice/learnings/review-insights.md` → accumulated review insights
- `.lattice/reviews/review-log.md` → review log

### Step 2: Present Findings

Report what found -- concise, structured. Present user:

```
## Project Scan Results

**Project**: [detected language/framework] at [repo root]
**Structure**: [key directories found]

### Lattice Setup Status
- `.lattice/config.yaml`: [exists / not found]
- Language: [detected language / language key from config / not detected]
- Language idioms: [found at .lattice/standards/language-idioms.md / not found]
- Knowledge base: [found at .lattice/standards/knowledge-base.md / not found]
- Architecture standards: [found at .lattice/standards/architecture.md / not found]
- Clean code standards: [found / not found]
- DDD standards: [found / not found]
- Review standards: [found / not found]
- Context documents: [N found / none]
- Review learnings: [found / none]
- Review log: [found / none]
```

**If everything already set up** (config exists all core standards docs exist): acknowledge "Lattice fully configured for this project" skip directly Step 4.

### Step 3: Guided Setup

Based gaps found Step 2, suggest refiners priority order. Walk user through each missing piece one time.

**Priority order**:

1. **Knowledge-priming-refiner** (if `.lattice/standards/knowledge-base.md` missing) -- "Captures project identity -- tech stack, architecture, directory layout, conventions. Every other skill uses this context make better decisions."
2. **Language-idioms-refiner** (if `.lattice/standards/language-idioms.md` missing) -- "Defines how your language expresses engineering patterns -- error handling, type system, naming, testing, DI. Multiple atoms use this to adapt pseudocode defaults to your language. Fast interview: proposes language-idiomatic defaults, you confirm or adjust."
3. **Architecture-refiner** (if `.lattice/standards/architecture.md` missing AND project has source code dir) -- "Defines project architecture standards — layer structure, dependency rules, validation checklist. Supports multiple styles: clean architecture (default), hexagonal / ports & adapters, modular monolith, or custom."
4. **DDD-refiner** (if `.lattice/standards/ddd-principles.md` missing AND project has domain folder or domain-like structure) -- "Captures aggregate design rules, entity patterns, domain event conventions so DDD atom enforces domain modeling style."
5. **Clean-code-refiner** (if `.lattice/standards/clean-code.md` missing) -- "Tailors coding standards -- function size limits, complexity thresholds, naming conventions. Defaults work well most projects, so optional."
6. **Review-refiner** (if `.lattice/standards/review-standards.md` missing) -- "Customizes how review molecule works -- atom loading rules, severity levels, report format, scope rules. Defaults work well most projects, so optional."

**For each gap**, present user:
- What refiner does (one sentence, from descriptions above)
- Three choices: **Run now**, **Skip for later**, or **Skip all remaining**

**If user says "run"** → Tell user invoke refiner: "Run `/[refiner-name]` now start guided interview." If refiner exits before completing, user can re-run -- existing partial output `.lattice/standards/` will not block interview from restarting.

**If user says "skip"** → Move next refiner priority order.

**If user says "skip all"** → Jump Step 4.

**Config creation**: If `.lattice/config.yaml` not exist and user not run any refiners (skipped all), create minimal config file:

```yaml
# .lattice/config.yaml -- Lattice Framework Configuration
# All paths are relative to the repository root.
# Run refiners to populate: /knowledge-priming-refiner, /language-idioms-refiner, /architecture-refiner, /ddd-refiner, /clean-code-refiner, /review-refiner

version: 1
language: {detected-language}
paths: {}
```

If user runs at least one refiner, refiner itself create or update config file -- no need create here. Set `language` key from detected language even if no refiners run -- atoms use it as fallback when language-idioms document not present.

### Step 4: Next Steps

Present workflow so user knows what do next.

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