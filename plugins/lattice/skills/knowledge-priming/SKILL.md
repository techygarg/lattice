---
name: knowledge-priming
description: "Load project-specific context -- tech stack, architecture overview, directory layout, trusted sources, and conventions -- so that all skills operate with awareness of what this project actually is. Use when a knowledge base document exists, or when the user asks about the project's tech stack, architecture, conventions, framework, directory layout, or says 'tell me about this project', 'what are we using?', 'what's our stack?', or 'what framework is this?'. Use the knowledge-priming-refiner to create a knowledge base document."
---

# Knowledge Priming

## Config Resolution

1. Look for `.lattice/config.yaml` in repo root.
2. If found, check `paths.knowledge_base` for custom doc path.
3. If doc exists at that path, read the full document.
4. **STOP: Apply the loaded document as ambient context before any design, implement, or review work begins.**
5. If no config, path, or doc found → see "When No Document Exists".

## When No Document Exists

Inform the user:

> No project knowledge base found. AI skills will operate from generic assumptions about tech stack, architecture, and conventions.
>
> To create one, trigger **knowledge-priming-refiner** — guided interview (~10 questions) producing a concise document (~50 lines).
>
> Can also create `.lattice/standards/knowledge-base.md` manually and reference in `.lattice/config.yaml` under `paths.knowledge_base`.

Do not block. Continue without knowledge base.

## What the Document Contains

| # | Section | What It Captures |
|---|---------|-----------------|
| 1 | **Architecture Overview** | App type, major components, how they interact |
| 2 | **Tech Stack and Versions** | Specific technologies with version numbers, including "not X" clarifications |
| 3 | **Curated Knowledge Sources** | Official docs, trusted blogs, internal references (5–10 max) |
| 4 | **Project Structure** | Directory layout showing where things live |
| 5 | **Project Conventions** | Project-specific conventions other skills cannot infer from code |

## Scope Boundary

| Concern | Owned By |
|---------|----------|
| Coding style, naming principles, function design | clean-code atom |
| Architectural layers, dependency direction | architecture atom |
| Domain modeling, aggregate design | domain-driven-design atom |
| Input validation, injection prevention | secure-coding atom |
| Test structure, assertion quality | test-quality atom |

Knowledge priming answers *"what are we working with?"* — not *"how should we write?"*