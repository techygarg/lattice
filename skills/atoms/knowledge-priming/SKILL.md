---
name: knowledge-priming
description: "Load project-specific context -- tech stack, architecture overview, directory layout, trusted sources, and conventions -- so that all skills operate with awareness of what this project actually is. Use when a knowledge base document exists, or when the user asks about the project's tech stack, architecture, conventions, framework, directory layout, or says 'tell me about this project', 'what are we using?', 'what's our stack?', or 'what framework is this?'. Use the knowledge-priming-refiner to create a knowledge base document."
---

# Knowledge Priming

## Purpose

AI defaults to the average of the internet. Without project-specific context, it guesses your framework, invents conventions, and produces generic code that does not match your stack. Knowledge priming solves this by loading a concise project identity document that tells the AI what it is working with -- before any design, implementation, or review begins.

This atom does not teach coding principles (that is clean-code), structural rules (that is architecture), or domain modeling (that is domain-driven-design). It answers a different question: **"What is this project?"** -- the tech stack, the architecture style, the directory layout, the trusted documentation sources, and the conventions that other skills cannot infer from code alone.

## Config Resolution

1. Look for `.ai/config.yaml` in the repository root
2. If found, check `paths.knowledge_base` for a custom document path
3. If a document exists at that path, read it and apply it as ambient project context
4. If no config, no path, or no document found -- see "When No Document Exists" below

There are no embedded defaults. Every project's identity is unique -- there is no sensible generic default for "what is your project." The knowledge base document is created by the `knowledge-priming-refiner` skill or written by hand.

## When No Document Exists

If no knowledge base document is found during config resolution, inform the user:

> No project knowledge base found. Without it, AI skills will work from generic assumptions about your tech stack, architecture, and conventions.
>
> To create one, trigger the **knowledge-priming-refiner** skill -- a guided interview (~10 questions) that produces a concise document (~50 lines). Once created, every Lattice skill will use it as ambient context.
>
> You can also create `.ai/standards/knowledge-base.md` manually and reference it in `.ai/config.yaml` under `paths.knowledge_base`.

This message is informational, not blocking. All skills continue to function without a knowledge base -- they just operate without project-specific context.

## What the Document Contains

The knowledge base document produced by the `knowledge-priming-refiner` has 5 sections:

| # | Section | What It Captures |
|---|---------|-----------------|
| 1 | **Architecture Overview** | Big picture: what kind of application, major components, how they interact |
| 2 | **Tech Stack and Versions** | Specific technologies with version numbers, including "not X" clarifications |
| 3 | **Curated Knowledge Sources** | Official docs, trusted blogs, internal references the team relies on (5-10 max) |
| 4 | **Project Structure** | Directory layout showing where things live |
| 5 | **Project Conventions** | Brief project-specific conventions that other skills cannot infer |

The document is intentionally lean -- under 50 lines of focused content. Every token competes for context window space, so the knowledge base captures what matters most and omits what other skills already handle.

## How It Is Used

When a knowledge base document is loaded, it becomes **ambient context** for all skills. Any molecule that composes this atom loads it first, before any design, implementation, or review work begins. Examples of how it is used:

- **Design molecules** use it to ground design decisions in the actual tech stack and architecture -- proposing components that fit the real project structure rather than generic patterns
- **Implementation molecules** use it to generate code that matches the project's framework, version-specific APIs, directory conventions, and naming patterns
- **Review molecules** use it to evaluate changes against the project's actual standards -- flagging deviations from documented conventions rather than generic best practices

The knowledge base is always-on context. Unlike conditional atoms (DDD, secure-coding, test-quality) that activate based on what code is being touched, the knowledge base applies to every interaction because project identity is always relevant.

## Scope Boundary

Knowledge priming captures **project identity and technical context**. It deliberately excludes concerns covered by other atoms:

| Concern | Where It Belongs | Not Here |
|---------|-----------------|----------|
| Coding style, naming principles, function design | clean-code atom | No code examples, no naming rules |
| Architectural layers, dependency direction | architecture atom | No structural rules |
| Domain modeling, aggregate design | domain-driven-design atom | No DDD patterns |
| Input validation, injection prevention | secure-coding atom | No security rules |
| Test structure, assertion quality | test-quality atom | No testing patterns |

If the content teaches *how to write code*, it belongs in one of the atoms above. Knowledge priming answers *"what are we working with?"* -- not *"how should we write?"*

## Integration with Other Skills

This atom is composed by all three molecules:

- **`design-blueprint`** -- loads knowledge base at the start to ground design in the real tech stack and architecture
- **`code-forge`** -- loads knowledge base to inform implementation decisions, framework-specific patterns, and directory placement
- **`review`** -- loads knowledge base to evaluate changes against project-specific conventions and stack constraints

When composed by a molecule, the knowledge base is loaded once at the beginning and remains active throughout the workflow. When used standalone, it loads on first reference to project context.
