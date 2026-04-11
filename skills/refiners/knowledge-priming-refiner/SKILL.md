---
name: knowledge-priming-refiner
description: "Facilitate a structured conversation to create a project-specific knowledge base document. Produces a knowledge-base.md that primes AI with the project's tech stack, architecture, trusted sources, and project structure. Use when the user says 'set up knowledge base', 'prime the project', 'onboard AI', 'create knowledge base', 'set up project context', or 'configure AI context'."
---

# Knowledge Priming Refiner

## Purpose

This refiner facilitates a structured conversation to create a project-specific knowledge base document. The document captures the project's identity -- its tech stack, architecture, directory layout, and the trusted sources that shaped how the team works. Think of it as answering one question: "What does AI need to know about *this project* to avoid defaulting to generic internet patterns?"

This is not about how to write good code -- that is handled by the `clean-code` atom (coding principles), `architecture` atom (structural rules), and `domain-driven-design` atom (domain modeling). Knowledge priming covers what those skills cannot know: which framework, which version, which docs to trust, and how the repo is organized.

## What This Produces

- **Output**: `.lattice/standards/knowledge-base.md` (or custom path from `.lattice/config.yaml` -> `paths.knowledge_base`)
- **Mode**: Override is the standard approach -- every project's knowledge base is unique, so there are no generic defaults to overlay on. Overlay mode is available for selective revisions of an existing document.
- **Config key**: `paths.knowledge_base` in `.lattice/config.yaml`
- **Template**: Read `./assets/template.md` for the full document structure and interview guidance comments
- **Consumed by**: The `knowledge-priming` atom loads this document via config resolution and provides it as ambient project context to all skills and molecules

## Scope Boundary

Knowledge priming captures **project identity and technical context**. It deliberately excludes concerns covered by other skills:

| Concern | Where It Belongs | Not In Knowledge Priming |
|---------|-----------------|--------------------------|
| Language idioms (error handling, type system, naming, testing patterns, DI) | `language-idioms` document | No language-level patterns or idioms |
| Coding style, naming principles, function design | `clean-code` atom | No code examples, no naming rules |
| Architectural layers, dependency direction | `architecture` atom | No structural rules |
| Domain modeling, aggregate design | `domain-driven-design` atom | No DDD patterns |
| Code-level anti-patterns (god functions, deep nesting) | `clean-code` atom | No coding anti-patterns |

If you find yourself writing content that teaches *how to write code*, it belongs in one of the atoms above, not here. Knowledge priming answers "what are we working with?" -- not "how should we write?"

## Before You Begin

### Check for existing documents

Before starting the interview:

1. Read `.lattice/config.yaml` -- does `paths.knowledge_base` point to a file?
2. If yes, read that file. Ask the user:
   - "You already have a knowledge base document. Would you like to **revise** it (update specific sections), **start fresh** (new interview), or **add to it**?"
   - Revise: Load the existing document, walk through only the sections the user wants to change.
   - Start fresh: Proceed with the full interview flow below.
3. If no config or no existing document, proceed with the full interview flow.

### Scan the repository

Look for signals that inform the conversation:

- **package.json / Cargo.toml / go.mod / pyproject.toml**: What languages, frameworks, and versions are in use?
- **Directory structure**: How is the project organized? Monorepo, single app, modules?
- **Existing docs**: README, ADRs, contributing guides, architecture docs?
- **Config files**: Linter configs, formatter configs, CI pipeline files -- these reveal conventions.

Share relevant findings with the user at the start: "I noticed your project uses [X framework] with [Y structure]. I'll use that as context for our conversation."

## Facilitation Approach

- **One section at a time.** Walk through the 5 sections sequentially.
- **Show examples first.** For each section, explain what it captures, show a concrete example, then ask the user.
- **Record the user's content, not the discussion.** The output document reads as a reference.
- **Encourage specificity.** "Fastify 4.x" is useful; "modern framework" is not. Version numbers matter because APIs change between versions.
- **Keep it lean.** Target under 3 pages / ~50 lines of focused content. Every token competes for context window space.

## Section-by-Section Interview Guide

Read `./assets/template.md` and follow the `<!-- INTERVIEW GUIDANCE: -->` comments for each section.

### The 5 sections

| # | Section | What It Captures |
|---|---------|-----------------|
| 1 | **Architecture Overview** | Big picture: what kind of application, major components, how they interact |
| 2 | **Tech Stack and Versions** | Specific technologies with version numbers, including "not X" clarifications |
| 3 | **Curated Knowledge Sources** | Official docs, trusted blogs, internal references the team relies on (5-10 max) |
| 4 | **Project Structure** | Directory layout showing where things live |
| 5 | **Project Conventions** | Brief project-specific conventions that other skills cannot infer (optional, slim) |

### Cross-section awareness

| Described in | Informs | How |
|-------------|---------|-----|
| §1 -- Architecture | §4 -- Project Structure | Architecture style shapes directory layout |
| §2 -- Tech Stack | §5 -- Project Conventions | Stack choices may imply project-specific conventions |
| §2 -- Tech Stack | §3 -- Curated Sources | Each technology has authoritative docs worth curating |

## Output Assembly

1. YAML frontmatter: `mode: override` (or `overlay` for selective)
2. Preamble text (from template)
3. All sections with the user's content
4. Sections the user skipped get a `<!-- TODO: Fill in during next revision -->` comment
5. Strip all `<!-- INTERVIEW GUIDANCE: -->` comments from the output

**Determine output path:**
1. If `.lattice/config.yaml` exists and has `paths.knowledge_base`, use that path.
2. Otherwise, default to `.lattice/standards/knowledge-base.md`.

**Update config:**
1. If `.lattice/config.yaml` does not exist, create it with `paths.knowledge_base` pointing to the output file.
2. If it exists but lacks the key, add it. Preserve existing content.

## Document Quality Checks

Before writing the final document, verify:

- [ ] Content is specific, not generic ("Fastify 4.x" not "modern framework")
- [ ] Tech stack entries include version numbers where applicable
- [ ] "Not X" clarifications steer AI away from common defaults that do not apply
- [ ] Curated sources are limited to 5-10 high-value entries
- [ ] No coding guidelines (naming rules, code examples, anti-patterns) -- those belong in other skills
- [ ] Document stays under ~50 lines of focused content (excluding headings and formatting)
- [ ] Would a new developer find this useful for understanding *what this project is*?
