# Lattice

Composable AI skills that teach assistants structured thinking — design-first, context-aware, and architecture-guided — across the full software delivery lifecycle: requirements, design, architecture, implementation, testing, and review.

AI coding assistants jump straight to code, silently make design decisions, forget constraints mid-conversation, and produce output nobody reviewed against real standards. Lattice addresses this with 27 composable skills in three tiers, plus a living context layer (the `.lattice/` folder in your project) that grows with every feature cycle.

## Install

```
/plugin install lattice --marketplace techygarg/lattice
```

## Get started

Skill commands are typed in the chat, not the terminal.

1. `/lattice-init` scans your project, suggests refiners in priority order, and creates `.lattice/config.yaml`. Everything also works on built-in defaults, so setup is optional.
2. `/requirement-forge` acts as a senior PM and business analyst pair and writes epics and feature specs into `.lattice/requirements/`.
3. `/design-blueprint` walks through four design levels (Capabilities, Components, Interactions, Contracts) and ends in an approved blueprint before any code is written.
4. `/code-forge` implements from the approved blueprint, applying the quality skills as it goes.
5. `/review` audits the change and records what was learned for the next cycle.

Alongside the pipeline: `/bug-fix` investigates and fixes a defect with regression protection, `/refactor-safely` restructures code without changing behaviour, and `/architecture-compass` assesses an existing codebase's architecture.

## The three tiers

| Tier | What it does | Skills |
|---|---|---|
| **Atoms** (11) | Single-principle guardrails | `architecture`, `clean-code`, `collaborative-judgment`, `context-anchoring`, `design-first`, `domain-driven-design`, `knowledge-priming`, `learning-harvest`, `requirement-quality`, `secure-coding`, `test-quality` |
| **Molecules** (9) | Multi-step workflows that compose atoms | `architecture-compass`, `bug-fix`, `code-forge`, `design-blueprint`, `lattice-init`, `refactor-safely`, `refiners-update`, `requirement-forge`, `review` |
| **Refiners** (7) | Guided interviews that produce your team's standards | `architecture-refiner`, `clean-code-refiner`, `ddd-refiner`, `knowledge-priming-refiner`, `language-idioms-refiner`, `requirement-forge-refiner`, `review-refiner` |

## Learn more

The full README, documentation, and source live on GitHub:

- [Lattice on GitHub — the main README](https://github.com/techygarg/lattice/blob/main/README.md)
- [How it works — full skill inventory and mechanics](https://github.com/techygarg/lattice/blob/main/docs/how-it-works.md)
- [Practical guide — scenario-driven Q&A](https://github.com/techygarg/lattice/blob/main/docs/practical-guide.md)
- [Configuration reference — every `.lattice/config.yaml` key](https://github.com/techygarg/lattice/blob/main/docs/configuration.md)
- [Report an issue](https://github.com/techygarg/lattice/issues)

## About this listing

This listing is a build of the GitHub repository's `skills/` folder, published automatically from the `claude-ai-directory` branch on every release. It leaves out the optional verification runner, which depends on a shell script. The [verification guide](https://github.com/techygarg/lattice/blob/main/docs/agents/verification.md) explains what it does and how to use it from the GitHub version.

Released under the [MIT License](https://github.com/techygarg/lattice/blob/main/LICENSE).
