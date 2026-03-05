---
name: lattice-init
description: "Guided setup experience for new Lattice projects -- scans the repository, detects existing configuration, suggests refiners in priority order, and creates the .ai/ config. Bridges the gap between installing skills and getting first value. Use when the user says 'lattice init', 'set up lattice', 'initialize lattice', 'get started with lattice', or 'configure lattice for this project'."
---

# Lattice Init

## Required Skills

Read and apply these skills in order:

1. `framework:knowledge-priming` -- Load project context to understand what the project is and what already exists

## Workflow

### Step 1: Scan the Project

Detect signals about the project to understand its shape and existing Lattice state.

<!-- AI reasoning: The scan must be fast and non-invasive -- read-only filesystem checks. The goal is to gather enough signal to make intelligent refiner suggestions without overwhelming the user with raw data. -->

**Language/framework detection** -- check for these files at the repository root:
- `package.json` → Node.js / TypeScript
- `go.mod` → Go
- `pom.xml` or `build.gradle` → Java
- `Cargo.toml` → Rust
- `requirements.txt` or `pyproject.toml` → Python
- `Gemfile` → Ruby
- `*.csproj` or `*.sln` → C# / .NET

**Directory structure** -- list top-level directories. Identify common patterns:
- `src/`, `lib/`, `app/` → source code
- `test/`, `tests/`, `spec/` → test suites
- `docs/` → documentation
- `cmd/`, `internal/`, `pkg/` → Go project structure
- `domain/`, `infrastructure/`, `application/` → layered architecture

**Existing `.ai/` state** -- check what Lattice artifacts already exist:
- `.ai/config.yaml` → central config
- `.ai/standards/knowledge-base.md` → knowledge priming output
- `.ai/standards/clean-architecture.md` → architecture refiner output
- `.ai/standards/clean-code.md` → clean code refiner output
- `.ai/standards/ddd-principles.md` → DDD refiner output
- `.ai/context/` → feature context documents (count them)
- `.ai/learnings/review-insights.md` → accumulated review insights
- `.ai/reviews/review-log.md` → review log

### Step 2: Present Findings

Report what was found -- concise, structured. Present to the user:

<!-- AI reasoning: The scan results must give the user a clear picture in under 10 seconds. If everything is already configured, acknowledge it and skip to Step 4 -- do not waste the user's time re-running setup. -->

```
## Project Scan Results

**Project**: [detected language/framework] at [repo root]
**Structure**: [key directories found]

### Lattice Setup Status
- `.ai/config.yaml`: [exists / not found]
- Knowledge base: [found at .ai/standards/knowledge-base.md / not found]
- Clean architecture standards: [found / not found]
- Clean code standards: [found / not found]
- DDD standards: [found / not found]
- Context documents: [N found / none]
- Review learnings: [found / none]
- Review log: [found / none]
```

**If everything is already set up** (config exists and all four standards documents exist): acknowledge "Lattice is fully configured for this project" and skip directly to Step 4.

### Step 3: Guided Setup

Based on gaps found in Step 2, suggest refiners in priority order. Walk the user through each missing piece one at a time.

<!-- AI reasoning: The priority order matters. Knowledge-priming is always first because project identity is foundational -- every other atom and molecule benefits from knowing the tech stack, architecture, and conventions. Architecture and DDD come next because they establish structural rules. Clean-code is last because its defaults are usually fine without customization. Asking one at a time prevents decision fatigue. -->

**Priority order**:

1. **Knowledge-priming-refiner** (if `.ai/standards/knowledge-base.md` is missing) -- "Captures your project's identity -- tech stack, architecture, directory layout, and conventions. Every other skill uses this context to make better decisions."
2. **Architecture-refiner** (if `.ai/standards/clean-architecture.md` is missing AND the project has multi-layer structure like `src/`, `domain/`, `infrastructure/`, `application/`) -- "Defines your project's layer structure, dependency rules, and service patterns so the clean-architecture atom validates against your actual architecture."
3. **DDD-refiner** (if `.ai/standards/ddd-principles.md` is missing AND the project has a domain folder or domain-like structure) -- "Captures your aggregate design rules, entity patterns, and domain event conventions so the DDD atom enforces your domain modeling style."
4. **Clean-code-refiner** (if `.ai/standards/clean-code.md` is missing) -- "Tailors coding standards -- function size limits, complexity thresholds, naming conventions. The defaults work well for most projects, so this is optional."

**For each gap**, present to the user:
- What the refiner does (one sentence, from the descriptions above)
- Three choices: **Run it now**, **Skip for later**, or **Skip all remaining**

**If user says "run it"** → Tell the user to invoke the refiner: "Run `/[refiner-name]` now to start the guided interview."

**If user says "skip"** → Move to the next refiner in priority order.

**If user says "skip all"** → Jump to Step 4.

**Config creation**: If `.ai/config.yaml` does not exist and the user did not run any refiners (skipped all), create a minimal config file:

```yaml
# .ai/config.yaml -- Lattice Framework Configuration
# All paths are relative to the repository root.
# Run refiners to populate: /knowledge-priming-refiner, /architecture-refiner, /ddd-refiner, /clean-code-refiner

version: 1
paths: {}
```

If the user runs at least one refiner, the refiner itself will create or update the config file -- no need to create it here.

### Step 4: Next Steps

Present the workflow so the user knows what to do next.

<!-- AI reasoning: This is the payoff moment -- the user now has a configured project and a clear path forward. Keep it actionable and concise. The three molecules are the core workflow; atoms activate automatically and don't need separate instructions. -->

```
## You're Ready

Lattice is set up. Here's the workflow:

1. **Design a feature**: `/design-blueprint` -- walks through 5 progressive design levels
2. **Implement**: `/code-forge` -- generates code from the blueprint with built-in quality checks
3. **Review**: `/review` -- audits generated code against atom standards

Atoms (clean-code, DDD, secure-coding, etc.) activate automatically during these workflows.
You can also use atoms standalone -- they apply checks based on what you're working on.
```

If any refiners were skipped in Step 3, add a reminder:

```
### Skipped refiners
You can run these anytime to further customize Lattice for your project:
- [list skipped refiners with their slash commands]
```
