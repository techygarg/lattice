---
name: knowledge-priming
description: "Load project-specific context -- tech stack, architecture overview, directory layout, trusted sources, and conventions -- so that all skills operate with awareness of what this project actually is. Use when a knowledge base document exists, or when the user asks about the project's tech stack, architecture, conventions, framework, directory layout, or says 'tell me about this project', 'what are we using?', 'what's our stack?', or 'what framework is this?'. Use the knowledge-priming-refiner to create a knowledge base document."
---

# Knowledge Priming

## Purpose

AI default = internet average. No project context → guesses framework, invents conventions, generic code not match stack. Knowledge priming fix: load concise project identity doc before design/implement/review.

Not teach code principles (clean-code), structure rules (architecture), domain modeling (domain-driven-design). Answer different question: **"What is this project?"** -- tech stack, architecture style, directory layout, trusted docs, conventions other skills not infer from code.

## Config Resolution

1. Look `.lattice/config.yaml` in repo root
2. If found, check `paths.knowledge_base` for custom doc path
3. If doc exist at path, read + apply as ambient project context
4. If no config/path/doc found -- see "When No Document Exists"

No embedded defaults. Every project identity unique -- no sensible generic default for "what your project." Knowledge base doc created by `knowledge-priming-refiner` skill or hand-written.

## When No Document Exists

If no knowledge base doc found during config resolution, inform user:

> No project knowledge base found. Without it, AI skills work from generic assumptions about tech stack, architecture, conventions.
>
> To create one, trigger **knowledge-priming-refiner** skill -- guided interview (~10 questions) that produces concise document (~50 lines). Once created, every Lattice skill use it as ambient context.
>
> Can also create `.lattice/standards/knowledge-base.md` manually and reference in `.lattice/config.yaml` under `paths.knowledge_base`.

Message informational, not blocking. All skills continue work without knowledge base -- just operate without project-specific context.

## What the Document Contains

Knowledge base doc from `knowledge-priming-refiner` has 5 sections:

| # | Section | What It Captures |
|---|---------|-----------------|
| 1 | **Architecture Overview** | Big picture: what kind application, major components, how interact |
| 2 | **Tech Stack and Versions** | Specific technologies with version numbers, including "not X" clarifications |
| 3 | **Curated Knowledge Sources** | Official docs, trusted blogs, internal references team relies on (5-10 max) |
| 4 | **Project Structure** | Directory layout showing where things live |
| 5 | **Project Conventions** | Brief project-specific conventions other skills not infer |

Doc intentionally lean -- under 50 lines focused content. Every token compete for context window, so knowledge base capture what matter most, omit what other skills already handle.

## How It Is Used

When knowledge base doc loaded, become **ambient context** for all skills. Any molecule compose this atom load first, before design/implement/review work. Examples how used:

- **Design molecules** use ground design decisions in actual tech stack + architecture -- propose components fit real project structure not generic patterns
- **Implementation molecules** use generate code match project framework, version-specific APIs, directory conventions, naming patterns
- **Review molecules** use evaluate changes against project actual standards -- flag deviations from documented conventions not generic best practices

Knowledge base always-on context. Unlike conditional atoms (DDD, secure-coding, test-quality) activate based on what code touched, knowledge base apply every interaction because project identity always relevant.

## Scope Boundary

Knowledge priming capture **project identity + technical context**. Deliberately exclude concerns covered by other atoms:

| Concern | Where It Belongs | Not Here |
|---------|-----------------|----------|
| Coding style, naming principles, function design | clean-code atom | No code examples, no naming rules |
| Architectural layers, dependency direction | architecture atom | No structural rules |
| Domain modeling, aggregate design | domain-driven-design atom | No DDD patterns |
| Input validation, injection prevention | secure-coding atom | No security rules |
| Test structure, assertion quality | test-quality atom | No testing patterns |

If content teach *how write code*, belong in atoms above. Knowledge priming answer *"what we working with?"* -- not *"how should write?"*

## Integration with Other Skills

This atom composed by all three molecules:

- **`design-blueprint`** -- load knowledge base at start ground design in real tech stack + architecture
- **`code-forge`** -- load knowledge base inform implementation decisions, framework-specific patterns, directory placement
- **`review`** -- load knowledge base evaluate changes against project-specific conventions + stack constraints

When composed by molecule, knowledge base loaded once at beginning, remain active throughout workflow. When used standalone, load on first reference to project context.