---
name: clean-code
description: "Apply clean code principles when generating or modifying implementation code. Enforces function focus, naming clarity, complexity management, error handling, and self-documenting style. Use during code generation, refactoring, or when the user mentions 'clean code', 'code quality', 'refactor this', 'simplify this', 'coding guidelines', or 'implementation quality'. This skill governs the craft of writing individual code units -- not architecture (see clean-architecture), not security posture (see secure-coding), and not test structure (see test-quality)."
---

# Clean Code

## Config Resolution

This skill supports project-specific customizations. Resolution order:

1. Look for `.ai/config.yaml` in the repository root
2. If found, check `paths.clean_code` for a custom document path
3. If the custom path exists, read that document and check its YAML frontmatter for `mode`:
   - **`mode: override`** (or no mode specified): The custom document takes full precedence.
     Use it instead of the embedded defaults. It must be comprehensive -- it is the sole reference.
   - **`mode: overlay`**: Read the embedded `./references/defaults.md` first, then apply the
     custom document's sections on top. Sections in the custom document replace matching
     sections in defaults (matched by heading). New sections are appended after defaults.
4. If no config, no path, or path not found, read `./references/defaults.md`

The defaults ship with this skill and represent opinionated best practices.
They work out of the box for any project. Override only when your team has
specific standards that differ from the defaults.

## Core Principle

Clean code is about the **craft of writing individual units of code** -- functions, classes, modules. It operates at a different level than architecture (which governs where code lives and how layers interact) and domain modeling (which governs how business rules are expressed). The goal: code that is readable, maintainable, and communicates its intent without requiring the reader to hold unrelated context in their head.

The principles here apply during code generation, not as a post-generation review pass. When writing code, apply these principles as you go -- the same way a skilled developer does. The cost of writing clean code during generation is near zero; the cost of cleaning up later is always higher.

## Single Responsibility

A function should have one reason to change. A class should have one axis of cohesion. This is not the architectural layer version (that belongs to clean-architecture) -- this is the code-unit version. When a function validates input, transforms data, and writes to a log, it has three reasons to change. Extract until each unit does one thing.

The test: describe what a function does without using "and." If you cannot, it does more than one thing.

**Guardrail**: The "and" test catches functions with *independent* responsibilities, not tightly coupled steps of one responsibility. `validateAndNormalizeEmail` does two things that must always happen together in sequence — separating them creates an invalid-state window. When the steps have no valid independent use, they are one responsibility expressed as a pipeline, not two responsibilities to separate.

For classes, the signal is **cohesion**: when most methods use most instance variables, the class is cohesive. When a subset of methods only touches a subset of fields, that subset likely belongs in its own class. See `./references/defaults.md` for extraction patterns and before/after examples.

## Small, Focused Functions

Functions should be short, do one thing, and do it well. A long function is not inherently bad -- but a long function that does multiple things always is. When you extract, name the extracted function to document the intent of the block you pulled out. The function name replaces the comment you would have written.

A function should operate at **one level of abstraction**. When high-level orchestration (`createOrder`, `sendNotification`) is mixed with low-level detail (`string.split(',')[2].trim()`), the reader must constantly shift mental gears. Extract the low-level detail into a named function and let each function tell its story at a consistent altitude.

Guideline: aim for functions under ~20 lines. This is a signal, not a hard rule -- a 25-line function with a single clear purpose is better than five 5-line functions with unclear relationships. See `./references/defaults.md` for concrete thresholds and examples.

## Cyclomatic Complexity

Deep nesting erodes readability. Every nested `if` inside a loop inside a conditional requires the reader to maintain a mental stack. Prefer early returns and guard clauses to flatten control flow. When a function accumulates branches, it is usually doing more than one thing -- extract the branches into named functions.

Three techniques for reducing complexity:

1. **Guard clauses**: replace nested conditions with early exits. Each guard removes one level of indentation.
2. **Extract conditional branches**: when a condition is complex, extract it into a named boolean or function. The name documents the intent.
3. **Pipeline operations**: replace loops with filter/map/reduce chains when the language supports it. Each step in the pipeline does one thing.

Guideline: keep cyclomatic complexity under ~10 per function. Functions above this threshold benefit from decomposition. See `./references/defaults.md` for detailed examples of each technique.

## Meaningful Naming

Names are the primary documentation of code. A well-named function, variable, or class eliminates the need for a comment explaining what it does. The rules: names reveal intent, not implementation. No abbreviations that require project-specific context to decode. Boolean names start with `is`, `has`, `can`, or `should`. Function names are verb-first (`calculateTotal`, not `totalCalculation`). Class names are noun-based (`OrderValidator`, not `ValidateOrder`).

Short-lived loop variables can be terse (`i`, `x`). Everything else should be descriptive enough to read in isolation. The general rule: **name length should be proportional to scope**. A two-line loop body tolerates `i`; a module-level constant used across the codebase should be `MAX_LOGIN_ATTEMPTS_BEFORE_LOCKOUT`. See `./references/defaults.md` for naming pattern tables.

**Magic numbers and strings**: Extract a literal to a named constant when its meaning is not self-evident from context or when it appears in multiple places. Do NOT extract self-documenting values: `return []` (empty collection), `startIndex = 0` (universal convention), `percentage / 100` (mathematical identity), or HTTP status codes in framework response calls. The test: would a reader pause and wonder "why this specific value?" If yes, extract and name it. If the value is obvious from context, inlining is cleaner than a constant. See `./references/defaults.md` for extraction decision examples.

## No Primitive Obsession at the Function Level

When a function takes more than three or four parameters, the parameter list becomes a cognitive burden and an invitation for call-site errors. Group related parameters into an object. This is not the same as DDD's value objects (which model domain concepts) -- this operates at the function signature level. A `SearchFilters` parameter object is cleaner than `(query, page, size, sortBy, sortDirection, includeArchived)`.

Watch for boolean parameters especially -- a boolean argument at a call site (`createUser(data, true)`) is opaque. The reader cannot tell what `true` means without checking the signature. Prefer named options (`createUser(data, { sendWelcomeEmail: true })`) or split into two functions with descriptive names.

See `./references/defaults.md` for parameter grouping patterns and thresholds.

## DRY Without Premature Abstraction

Duplication is not always the enemy. Two blocks of code that look identical but serve different business purposes should remain separate -- they will diverge as requirements change. Premature abstraction creates coupling between unrelated concerns, and undoing that coupling is harder than dealing with duplication. The wrong abstraction is more costly than no abstraction -- it fights every future change that does not fit its mold.

The heuristic: extract when you see the same pattern **three times** with the **same reason to change**. Until then, tolerate the duplication. When you do extract, name the abstraction for what it does, not for the fact that it removes duplication.

A good test for whether two blocks of code are "true" duplicates: if a requirement change in one context would require the same change in the other, they share a reason to change and are candidates for extraction. If the requirement change would only affect one, they are independent and should remain separate. See `./references/defaults.md` for the Rule of Three with examples.

## Comments and Self-Documentation

Code should be self-documenting through naming and structure. When you feel the urge to write a comment explaining *what* the code does, rename the function or variable instead. Comments that restate the code are noise -- they rot as the code changes and actively mislead.

Comments are valuable when they explain **why** -- non-obvious business rules, workarounds for known issues, constraints imposed by external systems, or performance trade-offs. A good comment answers a question the reader would have that the code cannot answer on its own.

One exception: regex patterns and complex algorithms benefit from a plain-English description comment, even though it explains "what." The cognitive cost of parsing a regex inline is high enough that the comment earns its place. See `./references/defaults.md` for comment guidelines with good and bad examples.

## Error Handling as a First-Class Concern

Error handling is not an afterthought bolted on after the happy path works. Fail fast -- validate inputs at the boundary and reject bad data before it propagates. Error messages should be actionable -- tell the caller what went wrong and what they can do about it.

Handle errors at the right level. Too early and you lose the context needed to make a good decision. Too late and you lose the ability to recover. Do not use exceptions for control flow -- they obscure the normal execution path and make reasoning about the code harder.

The key distinction: a caught error with an empty body is not handling -- it is hiding. Every catch block should either recover meaningfully, translate the error to the appropriate abstraction level, or propagate it with added context.

**Reconciling "actionable" with "safe"**: Error messages at trust boundaries (HTTP responses, user-facing UI) must not reveal internal details (stack traces, SQL errors, file paths) -- see `framework:secure-coding`. But they should still be actionable for the caller: "Invalid email format" is safe and actionable; "Something went wrong" is safe but useless; "SQL syntax error at line 42" is actionable but leaks internals. The pattern: log full details server-side with a correlation ID, return a generic but actionable message to the caller with the same correlation ID for support tracing.

See `./references/defaults.md` for error handling patterns by language paradigm.

## Test-Friendly Code

Code that is easy to test is usually well-structured code -- the two properties are deeply correlated. Prefer pure functions (same input, same output, no side effects) where possible. Inject dependencies rather than hardcoding them. Avoid hidden state -- global variables, singletons mutated at runtime, and static mutable fields make tests order-dependent and flaky.

Push side effects to the boundaries. Business logic in the center should be pure computation; I/O and state changes happen at the edges. This structure -- sometimes called the Functional Core, Imperative Shell pattern -- is not just about testability. It makes the code easier to reason about in every context because the reader can understand the logic without knowing what external systems are involved. See `./references/defaults.md` for patterns that improve testability.

## Self-Validation During Code Generation

When generating code, apply these checks as you write each function -- not as a post-generation review, but as an inline discipline:

1. **Read each function**: Can you describe its purpose without "and"? If not, extract.
2. **Check abstraction level**: Does the function mix high-level orchestration with low-level detail? Extract the detail.
3. **Scan for nesting**: More than two levels of indentation? Flatten with guard clauses or extract.
4. **Check parameter lists**: More than three or four parameters? Group into a parameter object.
5. **Review names**: Do function and variable names reveal intent without requiring context from surrounding code?
6. **Look for primitive obsession**: Are there string, number, or boolean parameters that would be clearer as named types or objects?
7. **Verify error paths**: Does every operation that can fail have explicit handling? Are error messages actionable?
8. **Check for comments explaining "what"**: Can any comment be eliminated by renaming the code it describes?
9. **Assess duplication**: Is any duplicated code justified by serving different reasons to change?
10. **Confirm testability**: Are side effects at the boundaries? Could a unit test exercise this logic without mocking I/O?

## Anti-Patterns

Common clean code violations and their fixes. See `./references/defaults.md` for code examples showing each violation and its correction.

| Anti-Pattern | Symptom | Fix |
|-------------|---------|-----|
| **God Function** | Function exceeds ~30 lines and does multiple things; description requires "and" | Extract into focused functions named for their intent |
| **Deep Nesting** | Three or more levels of indentation; reader loses track of conditions | Flatten with early returns and guard clauses; extract nested blocks |
| **Cryptic Naming** | Variables like `d`, `tmp2`, `processData`; readers need surrounding context to understand | Rename to reveal intent: `daysSinceLastLogin`, `pendingOrderCount` |
| **Long Parameter Lists** | Functions with five or more parameters; call sites are error-prone | Group related parameters into objects; use builder pattern for complex construction |
| **Premature Abstraction** | Shared utility extracted from two similar but unrelated blocks; diverges under maintenance | Inline until Rule of Three is met with same reason to change |
| **Swallowed Errors** | Empty catch blocks, generic "something went wrong" messages, silently returning null | Handle explicitly with actionable messages; fail fast at boundaries |
| **Comments as Deodorant** | Comments explaining convoluted code instead of simplifying the code itself | Refactor the code to be self-documenting; keep only "why" comments |
| **Hidden Side Effects** | Function named `getUser` that also writes to a cache or sends a notification | Caller-visible side effects (sends email, modifies shared state) → rename to reflect full behavior or separate into explicit call. Transparent implementation concerns (caching, metrics, logging) → acceptable in-place; document if non-obvious |
| **Dead Code** | Commented-out blocks, unused imports, unreachable branches, "just in case" functions that nothing calls | Delete. Version control preserves history. If code is not executed, it is noise that misleads readers and rots as the codebase evolves |

## Validation Checklist

When generating or reviewing code, verify these constraints.

| Check | Why It Matters |
|-------|---------------|
| Each function does one thing and can be described without "and" | Multi-purpose functions are harder to name, test, reuse, and modify safely |
| Functions are under ~20 lines with cyclomatic complexity under ~10 | Long, branchy functions require excessive mental context to understand |
| Names reveal intent without requiring surrounding context | Poor names force readers to trace code to understand purpose, slowing every future change |
| Parameter lists have four or fewer parameters | Long parameter lists invite call-site errors and indicate the function is doing too much |
| Error handling is explicit with actionable messages | Swallowed errors hide bugs; vague messages waste debugging time |
| Comments explain "why," not "what" | "What" comments rot and mislead; self-documenting code is the "what" |
| Duplication is only extracted when three instances share a reason to change | Premature extraction couples unrelated concerns and resists future divergence |
| Side effects are explicit and pushed to boundaries | Hidden side effects make functions unpredictable and tests unreliable |
| Dependencies are injected, not hardcoded | Hardcoded dependencies prevent testing and lock in implementation choices |
