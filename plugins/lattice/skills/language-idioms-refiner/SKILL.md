---
name: language-idioms-refiner
description: "Facilitate a structured conversation to define language-specific idioms and patterns for a repository. Produces a language-idioms.md document consumed by multiple atoms to adapt pseudocode defaults to the project's language. Use when setting up a new project, switching languages, or when the user says 'setup language', 'define language idioms', 'configure language', 'language patterns', or 'adapt for Go/Rust/Python'."
---

# Language Idioms Refiner

## What This Produces

- **Output**: `.lattice/standards/language-idioms.md` (or custom path from `.lattice/config.yaml` -> `paths.language_idioms`)
- **Mode**: Always standalone -- no embedded language defaults exist in atoms to overlay on. For revisions, load existing document and update sections in place.
- **Config keys**:
  - `language` (top-level) -- language identifier (e.g., `go`, `rust`, `python`, `java`, `typescript`)
  - `paths.language_idioms` -- path to the produced document
- **Template**: Read `./assets/template.md` for the full document structure, pre-populated examples, and interview guidance comments
- **Consumed by**: Multiple atoms reference specific sections by heading name:

| Section | Consumed by |
|---------|------------|
| **Error Handling** | `clean-code` atom (§8), `secure-coding` atom (§1 trust boundary messages) |
| **Type System & Object Model** | `clean-code` atom (§1 SRP/cohesion), `domain-driven-design` atom (entities, VOs, aggregates) |
| **Naming Conventions** | `clean-code` atom (§4) |
| **Testing Patterns** | `test-quality` atom (§5 naming, §4 isolation, §6 builders) |
| **Parameter & Function Design** | `clean-code` atom (§2 function size, §5 parameters) |
| **Dependency Management** | `clean-code` atom (§9 testability/DI), `architecture` atom (dependency direction) |

These six section headings are the **stable contract**. Atoms reference them by name. Additional sections can be added by consumers but these six must be present.

## Scope Clarification

This document captures **how the project's language expresses engineering patterns** -- the language-level idioms that atoms need to adapt their pseudocode defaults. Clear boundaries:

| Concern | Where It Belongs | Not Here |
|---------|-----------------|----------|
| Project identity, tech stack, directory layout | `knowledge-priming` atom | No project structure or framework docs |
| Code craftsmanship rules (thresholds, heuristics) | `clean-code` atom / overlay | No function size limits or DRY rules |
| Architecture layers, dependency direction | `architecture` atom / overlay | No layer definitions |
| Domain modeling guardrails | `domain-driven-design` atom / overlay | No aggregate rules |
| Team-specific preferences within language | Atom-specific overlays | No team decisions (see below) |

**Key distinction from atom overlays**: This document describes *how the language works*. Atom overlays describe *how the team works within the language*.

- **Language idioms doc**: "Go uses explicit error returns (`if err != nil`), not exceptions"
- **Clean-code overlay**: "We use `fmt.Errorf('context: %w', err)` for wrapping, custom error types for domain errors"

Language idioms are facts about the language. Atom overlays are team choices.

## Before You Begin

### Check for existing documents

1. Read `.lattice/config.yaml` -- does `paths.language_idioms` point to a file?
2. If yes, read that file. Ask the user:
   - "You already have a language idioms document for **[language]**. Would you like to **revise** it (update specific sections), **start fresh** (new interview), or **switch language**?"
   - Revise: Load the existing document, walk through only the sections the user wants to change.
   - Start fresh: Proceed with the full interview flow below.
   - Switch language: Proceed with full interview for the new language; existing document will be replaced.
3. If no config or no existing document, proceed with the full interview flow.

### Detect the language

Determine the project language before starting the interview:

1. **From config**: Check `.lattice/config.yaml` for `language` key.
2. **From project files** (if no config key):
   - `package.json` → TypeScript / JavaScript
   - `tsconfig.json` → TypeScript (confirm over JavaScript)
   - `go.mod` → Go
   - `pom.xml` or `build.gradle` or `build.gradle.kts` → Java or Kotlin
   - `Cargo.toml` → Rust
   - `requirements.txt` or `pyproject.toml` or `setup.py` → Python
   - `Gemfile` → Ruby
   - `*.csproj` or `*.sln` → C# / .NET
   - `Package.swift` → Swift
3. **Multiple languages detected**: Ask the user which is the primary language. One language-idioms document per project (covers the primary language).
4. **No detection**: Ask the user directly.

Present the detected language: "I detected this is a **Go** project (found `go.mod`). I'll propose Go-idiomatic patterns for each section. You can confirm or adjust."

## Interview Flow

This refiner works differently from other refiners. Instead of showing defaults and asking "change or keep?", it **proposes language-specific content** and asks "does this match your team's usage?"

### Step 1: Confirm language and version

"I detected **[Language] [version]**. Is this correct?"

Record language and version. These go in the document frontmatter.

### Step 2: Walk through sections with proposals

For each of the 6 sections:

1. **Propose** pre-populated content based on the detected language (see Language-Specific Proposals below).
2. **Present** the proposal: "Here's what I'd recommend for [Language]. Does this match how your team uses [Language]?"
3. **User confirms** → record as-is.
4. **User adjusts** → discuss specifics, record their version.

### Step 3: Additional sections

After the 6 core sections, ask: "Any language-specific patterns I should add? For example: concurrency patterns, memory management, async/await idioms, or framework-specific conventions."

Record any additional sections the user wants.

### Step 4: Produce document

Assemble and write the document.

## Section-by-Section Interview Guide

Read `./assets/template.md` and follow the `<!-- INTERVIEW GUIDANCE: -->` comments for each section.

### The 6 core sections

| # | Section | What It Captures |
|---|---------|-----------------|
| 1 | **Error Handling** | Language error philosophy (exceptions, error returns, Result types), error propagation patterns, error creation idioms |
| 2 | **Type System & Object Model** | Classes vs structs, interfaces (nominal vs structural), inheritance vs composition, generics, type safety idioms |
| 3 | **Naming Conventions** | Case conventions, visibility modifiers, acronym style, package/module naming, idiomatic patterns |
| 4 | **Testing Patterns** | Test framework idioms, test organization, assertion patterns, mocking approach, test naming style |
| 5 | **Parameter & Function Design** | Argument passing idioms, options/config patterns, multiple returns, named parameters, function signatures |
| 6 | **Dependency Management** | DI approach (container vs manual), interface placement, wiring patterns, import/module conventions |

### Cross-section awareness

| Decision in | Affects | How |
|-------------|---------|-----|
| §1 Error Handling | §4 Testing | Error patterns determine how error paths are tested |
| §2 Type System | §5 Parameters, §6 Dependencies | Object model shapes function signatures and DI approach |
| §3 Naming | §4 Testing | Naming conventions apply to test names too |

## Language-Specific Proposals

For well-known languages, pre-populate each section with idiomatic defaults. The interview confirms or adjusts these. For unrecognized languages, ask open-ended questions.

### Go

| Section | Proposal summary |
|---------|-----------------|
| Error Handling | Explicit error returns (`value, err := ...`), `if err != nil`, error wrapping with `fmt.Errorf("context: %w", err)`, sentinel errors for expected cases, no exceptions |
| Type System | Structs with methods (receiver functions), implicit interfaces (structural typing), composition via embedding, no inheritance, no classes |
| Naming | Exported = capitalized, unexported = lowercase, short names in small scopes, acronyms fully uppercase (`HTTP`, `ID`), package name is part of identifier (`http.Client` not `http.HTTPClient`) |
| Testing | Table-driven tests, `t.Run` for subtests, `testing.T` parameter, test files `_test.go` co-located, no assertion library required (stdlib comparisons) |
| Parameters | Accept interfaces return structs, functional options pattern for config (`WithTimeout(5*time.Second)`), multiple return values, no method overloading |
| Dependencies | Pass interface parameters (not constructor DI), define interfaces at consumer not provider, no DI container, explicit wiring in `main()` or `cmd/` |

### Rust

| Section | Proposal summary |
|---------|-----------------|
| Error Handling | `Result<T, E>` for recoverable, `panic!` for unrecoverable, `?` operator for propagation, `thiserror` for library errors, `anyhow` for application errors |
| Type System | Structs + impl blocks, traits (explicit implementation), enums with data (algebraic types), ownership/borrowing, no inheritance, no null (`Option<T>` instead) |
| Naming | `snake_case` functions/variables, `PascalCase` types/traits, `SCREAMING_SNAKE` constants, lifetime names short (`'a`, `'b`) |
| Testing | `#[test]` attribute, `#[cfg(test)] mod tests` in same file, integration tests in `tests/` directory, `assert_eq!`/`assert!` macros |
| Parameters | Ownership: borrow (`&T`) vs move, generic bounds (`impl Trait`), builder pattern for complex config, no default parameters |
| Dependencies | Trait objects (`dyn Trait`) or generics (`impl Trait`) for abstraction, no DI container, explicit construction |

### Python

| Section | Proposal summary |
|---------|-----------------|
| Error Handling | EAFP over LBYL (try/except, not if-checks), context managers (`with`) for cleanup, custom exceptions inheriting from base classes, raise/except |
| Type System | Classes, dataclasses (`@dataclass`), protocols for structural typing (PEP 544), duck typing, type hints encouraged but optional at runtime |
| Naming | `snake_case` functions/variables, `PascalCase` classes, `SCREAMING_SNAKE` constants, `_private` convention (single underscore), `__dunder__` for magic methods |
| Testing | pytest preferred, fixtures for setup/teardown, `@pytest.mark.parametrize` for data-driven tests, plain `assert` (pytest rewrites), test files `test_*.py` |
| Parameters | `**kwargs` for options, named/keyword arguments, default values, dataclass or TypedDict for config objects |
| Dependencies | Constructor injection with protocols/ABCs, or function parameters, no heavyweight DI container (or `dependency-injector` if needed) |

### Java / Kotlin

| Section | Proposal summary |
|---------|-----------------|
| Error Handling | **Java**: unchecked exceptions preferred over checked (modern style), custom exceptions extend `RuntimeException`. **Kotlin**: sealed class Result pattern, `runCatching`, no checked exceptions |
| Type System | **Java**: classes, interfaces, records (16+), sealed classes (17+). **Kotlin**: data classes, sealed hierarchies, null safety (`?`), extension functions |
| Naming | `camelCase` variables/methods, `PascalCase` classes/interfaces, `SCREAMING_SNAKE` constants, packages `lowercase.dotted` |
| Testing | JUnit 5, `@Test`, `@ParameterizedTest`, `@Nested` for grouping, Mockito (Java) / MockK (Kotlin), AssertJ for fluent assertions |
| Parameters | **Java**: builder pattern for >3 params, method overloading. **Kotlin**: named arguments, default values, data class config |
| Dependencies | Constructor injection (Spring, Guice, or manual), DI containers are idiomatic, program to interfaces |

### TypeScript

| Section | Proposal summary |
|---------|-----------------|
| Error Handling | try/catch with custom Error subclasses, typed error handling optional (Result pattern via libraries), no checked exceptions |
| Type System | Interfaces, type aliases, union/intersection types, generics, `unknown` over `any`, discriminated unions for state |
| Naming | `camelCase` variables/functions, `PascalCase` types/classes/enums, `SCREAMING_SNAKE` constants, no `I` prefix for interfaces |
| Testing | Jest or Vitest, `describe`/`it` blocks, mock functions (`jest.fn()`), `expect().toBe()` assertions, `.test.ts` or `.spec.ts` co-located |
| Parameters | Options objects with destructuring, default values, rest parameters, overloaded signatures for type narrowing |
| Dependencies | Constructor injection, DI optional (tsyringe, inversify), or module-level factory functions |

### C# / .NET

| Section | Proposal summary |
|---------|-----------------|
| Error Handling | Exceptions for exceptional cases, custom exceptions from `Exception` base, `try/catch/finally`, no error codes for business logic, `Result` pattern growing in popularity |
| Type System | Classes, interfaces (explicit), records (C# 9+), structs (value types), nullable reference types (C# 8+), generics |
| Naming | `PascalCase` methods/properties/classes, `camelCase` local variables/parameters, `_camelCase` private fields, `I` prefix for interfaces (`IService`) |
| Testing | xUnit or NUnit, `[Fact]`/`[Theory]` (xUnit), `[Test]`/`[TestCase]` (NUnit), FluentAssertions, Moq for mocking |
| Parameters | Named parameters, optional parameters with defaults, builder pattern or options pattern (`IOptions<T>`) for config |
| Dependencies | Constructor injection via built-in DI (`IServiceCollection`), DI containers idiomatic, interface-first |

### Other Languages

For languages not listed above, use open-ended questions for each section:

1. "How does [Language] handle errors? Exceptions, error returns, algebraic types, or something else?"
2. "What's the object model? Classes, structs, traits, protocols? Inheritance or composition?"
3. "What are the naming conventions? Case style, visibility markers, module naming?"
4. "What's the testing ecosystem? Framework, organization, assertion style?"
5. "How do you pass configuration and options to functions? Named params, objects, builders?"
6. "How is dependency injection handled? Containers, manual wiring, interface parameters?"

## Output Assembly

1. YAML frontmatter: `language` and `version`
2. Title line: `# Language Idioms: {Language}`
3. All 6 core sections with confirmed/adjusted content
4. Any additional sections the user added
5. Strip all `<!-- INTERVIEW GUIDANCE: -->` comments

**Target size**: 40-60 lines of focused content. Each section should be 4-8 lines: a brief philosophy statement plus the key idiomatic patterns as a concise list. No code examples -- atoms have their own examples in pseudocode that they adapt using this document's guidance.

**Determine output path:**
1. If `.lattice/config.yaml` exists and has `paths.language_idioms`, use that path.
2. Otherwise, default to `.lattice/standards/language-idioms.md`.

**Update config:**
1. Set `language: {language}` at top level (create or update).
2. Set `paths.language_idioms` pointing to the output file.
3. If `.lattice/config.yaml` does not exist, create it. Preserve all existing content.

**Confirm to user:**
"Your language idioms document has been written to `[PATH]` for **[Language] [version]**. The following atoms will now adapt their patterns: clean-code, test-quality, secure-coding, domain-driven-design, and architecture."

## Document Quality Checks

Before writing the final document, verify:

- [ ] All 6 core section headings are present and match exactly: `Error Handling`, `Type System & Object Model`, `Naming Conventions`, `Testing Patterns`, `Parameter & Function Design`, `Dependency Management`
- [ ] Content is specific to the language, not generic advice ("use error returns" not "handle errors properly")
- [ ] No code craftsmanship rules (thresholds, complexity limits) -- those belong in atom overlays
- [ ] No project identity information (tech stack, directory layout) -- that belongs in knowledge-priming
- [ ] Content is concise -- each section 4-8 lines, total document under 60 lines
- [ ] Frontmatter has correct `language` and `version` values
- [ ] Config file is correctly updated with both `language` key and `paths.language_idioms`
- [ ] No `<!-- INTERVIEW GUIDANCE: -->` comments remain in output
