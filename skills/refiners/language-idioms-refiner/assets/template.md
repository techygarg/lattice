---
language: {language}
version: "{version}"
---

<!-- This is the template for the language-idioms-refiner output.
     Sections marked with <!-- INTERVIEW GUIDANCE: --> contain instructions
     for the refiner interview. Strip ALL guidance comments from the final output.

     IMPORTANT: The 6 core section headings below are a STABLE CONTRACT.
     Multiple atoms reference these headings by exact name. Do not rename them.
     Additional sections may be added after the core 6. -->

# Language Idioms: {Language}

<!-- INTERVIEW GUIDANCE:
Replace {Language} with the detected or confirmed language name (e.g., "Go", "Rust", "Python").
Replace {language} and {version} in frontmatter with lowercase identifier and version string. -->

## Error Handling

<!-- INTERVIEW GUIDANCE:
This section is consumed by:
- clean-code atom §8 (Error Handling) — adapts throw/catch pseudocode to language idioms
- secure-coding atom §1 (Trust Boundary Identification) — adapts error message patterns at boundaries

PROPOSE based on detected language (see SKILL.md Language-Specific Proposals).
Present: "For [Language], the idiomatic error handling approach is [proposal]. Does this match your team?"

Probing questions if user wants to adjust:
- "Does your team use a specific error library? (e.g., Go: pkg/errors vs fmt.Errorf, Rust: thiserror vs anyhow)"
- "How do you distinguish recoverable from unrecoverable errors?"
- "Any project-specific error types or error wrapping conventions?"

Record:
- Error philosophy (one sentence: exceptions, error returns, Result types, etc.)
- Error creation pattern (how errors are constructed)
- Error propagation pattern (how errors flow up the call stack)
- Any notable idioms or libraries

Target: 4-8 lines. No code examples — atoms adapt their own pseudocode using these descriptions.
-->

{Language} uses {error_philosophy}. {Error_creation_pattern}. {Error_propagation_pattern}.

{Additional error idioms or library choices if any.}

## Type System & Object Model

<!-- INTERVIEW GUIDANCE:
This section is consumed by:
- clean-code atom §1 (Single Responsibility) — adapts class/struct cohesion guidance
- domain-driven-design atom — adapts entity, value object, and aggregate implementation patterns

PROPOSE based on detected language.
Present: "For [Language], the type system uses [proposal]. Does this match?"

Probing questions if user wants to adjust:
- "Do you use the language's full type system? (e.g., Go: do you use generics? TypeScript: strict mode?)"
- "Classes, structs, both? How do you model domain objects?"
- "Inheritance or composition? How does your team achieve polymorphism?"
- "How does your language handle null/absence? (null, Option, Maybe, nil)"

Record:
- Primary type constructs (classes, structs, data classes, records, etc.)
- Interface mechanism (nominal, structural, implicit, traits, protocols)
- Composition model (inheritance, embedding, mixins, traits)
- Null handling idiom

Target: 4-8 lines.
-->

{Primary_type_constructs}. {Interface_mechanism}. {Composition_model}. {Null_handling}.

## Naming Conventions

<!-- INTERVIEW GUIDANCE:
This section is consumed by:
- clean-code atom §4 (Meaningful Naming) — adapts naming pattern table to language conventions

PROPOSE based on detected language.
Present: "For [Language], the standard naming conventions are [proposal]. Any team-specific deviations?"

Probing questions if user wants to adjust:
- "Any abbreviations your team considers acceptable beyond language standard? (e.g., ctx, req, resp)"
- "Package/module naming conventions?"
- "Do you follow the language community standard strictly or have team variations?"

Record:
- Case conventions (snake_case, camelCase, PascalCase — for what)
- Visibility markers (capitalization, underscores, keywords)
- Acronym style
- Package/module naming

Target: 4-6 lines. Brief — naming conventions are well-documented per language; capture only what the atom needs.
-->

{Case_conventions}. {Visibility_markers}. {Acronym_style}. {Package_module_naming}.

## Testing Patterns

<!-- INTERVIEW GUIDANCE:
This section is consumed by:
- test-quality atom §5 (Test Naming Conventions) — adapts naming examples to language test framework
- test-quality atom §4 (Test Isolation Techniques) — adapts isolation patterns to language idioms
- test-quality atom §6 (Test Data Builders and Factories) — adapts builder patterns to language constructs

PROPOSE based on detected language.
Present: "For [Language], the testing approach is typically [proposal]. Is this what your team uses?"

Probing questions if user wants to adjust:
- "Which test framework? (e.g., Go: stdlib, Rust: built-in, Python: pytest vs unittest, Java: JUnit 5 vs TestNG)"
- "Test file organization? Co-located or separate test directory?"
- "Mocking approach? (e.g., Go: interfaces, Python: unittest.mock, Java: Mockito)"
- "Assertion library? (e.g., AssertJ, FluentAssertions, testify)"
- "Data-driven/parameterized tests? Table-driven?"

Record:
- Test framework and assertion approach
- Test file organization and naming
- Mocking/stubbing idiom
- Data-driven test pattern

Target: 4-8 lines.
-->

{Test_framework_and_assertions}. {Test_file_organization}. {Mocking_idiom}. {Data_driven_pattern}.

## Parameter & Function Design

<!-- INTERVIEW GUIDANCE:
This section is consumed by:
- clean-code atom §2 (Small, Focused Functions) — adapts function design to language capabilities
- clean-code atom §5 (Parameter Design) — adapts grouping and options patterns to language idioms

PROPOSE based on detected language.
Present: "For [Language], function and parameter design typically follows [proposal]. Does this match?"

Probing questions if user wants to adjust:
- "Does your language support named/keyword arguments? Do you use them?"
- "Multiple return values? How do you handle them?"
- "Options/config pattern? (e.g., Go: functional options, Python: **kwargs, Java: builders)"
- "Method overloading available and used?"

Record:
- Argument passing idiom (positional, named, destructured, etc.)
- Options/config pattern for complex inputs
- Multiple returns or output parameters
- Method overloading / default parameters

Target: 4-6 lines.
-->

{Argument_passing_idiom}. {Options_config_pattern}. {Multiple_returns}. {Overloading_defaults}.

## Dependency Management

<!-- INTERVIEW GUIDANCE:
This section is consumed by:
- clean-code atom §9 (Test-Friendly Code) — adapts DI and testability patterns
- architecture atom — adapts dependency direction enforcement to language idioms

PROPOSE based on detected language.
Present: "For [Language], dependency injection is typically handled via [proposal]. Does this match your team?"

Probing questions if user wants to adjust:
- "DI container or manual wiring? Which one?"
- "Where do you define interfaces — at the provider or consumer?"
- "How do you wire dependencies in the entry point? (main function, composition root, framework config)"
- "Import/module conventions that affect dependency structure?"

Record:
- DI approach (container, constructor injection, function parameters, etc.)
- Interface placement (provider-side vs consumer-side)
- Wiring location (main, composition root, framework config)
- Notable conventions

Target: 4-6 lines.
-->

{DI_approach}. {Interface_placement}. {Wiring_location}. {Notable_conventions}.

<!-- INTERVIEW GUIDANCE:
After all 6 core sections, ask:
"Any language-specific patterns I should add that aren't covered above? For example:
- Concurrency patterns (goroutines, async/await, threads)
- Memory management (ownership, GC tuning, pool patterns)
- Module/package organization
- Framework-specific idioms"

If user adds sections, use ## heading format and keep them concise (4-8 lines each).
These additional sections are not referenced by atoms by default, but provide useful
context when loaded alongside the core sections.

REMEMBER: Strip all <!-- INTERVIEW GUIDANCE: --> comments from the final output.
The produced document should be a clean, lean specification (~40-60 lines). -->
