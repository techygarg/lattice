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

## Self-Validation Checklist

STOP after generating each component. Verify ALL of the following before proceeding. If any check clearly fails, fix the code before presenting it. If a check is a judgment call with multiple valid approaches (see Ambiguity Signals), flag it — present your options and reasoning rather than silently choosing.

1. **SINGLE RESPONSIBILITY**: Can you describe each function's purpose without the word "and"? If not → extract into separate functions.
2. **SIZE**: Is each function under ~20 lines? If not → extract sub-operations into named functions.
3. **COMPLEXITY**: Is cyclomatic complexity under ~10 per function? If not → flatten with guard clauses, extract branches.
4. **ABSTRACTION LEVEL**: Does each function operate at one level of abstraction? If high-level orchestration is mixed with low-level detail → extract the detail.
5. **NAMING**: Do function and variable names reveal intent without requiring surrounding context? If not → rename to be self-documenting.
6. **PARAMETERS**: Does each function have four or fewer parameters? If not → group related parameters into an object.
7. **PRIMITIVE OBSESSION**: Are there string, number, or boolean parameters that would be clearer as named types or objects? If so → introduce parameter objects or typed wrappers.
8. **ERROR HANDLING**: Does every operation that can fail have explicit handling with actionable messages? Are errors handled at the right level?
9. **COMMENTS**: Can any comment be eliminated by renaming the code it describes? Remove "what" comments, keep only "why" comments.
10. **TESTABILITY**: Are side effects pushed to boundaries? Could a unit test exercise this logic without mocking I/O? If not → inject dependencies, extract pure logic.

## Active Anti-Pattern Scan

After verifying the checklist above, scan your output for these specific anti-patterns. If you find any, fix them before presenting the code.

- [ ] **God Function**: Any function exceeding ~30 lines that does multiple things; description requires "and" → extract into focused functions
- [ ] **Deep Nesting**: Three or more levels of indentation → flatten with early returns and guard clauses
- [ ] **Cryptic Naming**: Variables like `d`, `tmp2`, `processData` → rename to reveal intent
- [ ] **Long Parameter Lists**: Functions with five or more parameters → group into objects or split functions
- [ ] **Premature Abstraction**: Utility extracted from only two similar blocks → inline until Rule of Three with same reason to change
- [ ] **Swallowed Errors**: Empty catch blocks, generic "something went wrong," silently returning null → handle explicitly
- [ ] **Comments as Deodorant**: Comments explaining convoluted code → refactor the code to be self-documenting
- [ ] **Hidden Side Effects**: Function named `getX` that also writes to cache or sends notification → rename or separate
- [ ] **Dead Code**: Commented-out blocks, unused imports, unreachable branches → delete (version control preserves history)

## Ambiguity Signals

These checks often have multiple valid outcomes. When you encounter one, present options rather than silently choosing.

- **Single Responsibility**: Two tightly-coupled sequential operations may be one responsibility (a pipeline), not two. The "and" test catches both true violations and false positives.
- **Function Size**: A 25-line function with one clear purpose may be better than five unclear 5-line functions. Near-threshold cases are judgment calls.
- **DRY vs Premature Abstraction**: Two identical blocks may serve different business purposes and diverge later. Until the third instance with the same reason to change, this is genuinely ambiguous.
- **Error Handling Strategy**: Exceptions vs Result types vs error codes depends on language idioms and team convention, not a universal rule.

## Core Principle

Clean code is about the **craft of writing individual units of code** -- functions, classes, modules. It is distinct from architecture (which governs where code lives) and domain modeling (which governs business rules). Apply these principles during code generation, not as a post-generation review pass.

## Guardrails and Nuances

The checklist and anti-patterns above are the primary enforcement mechanism. These nuances prevent over-application of those rules. See `./references/defaults.md` for full explanations, thresholds, and code examples.

- **SRP pipeline guardrail**: The "and" test catches functions with *independent* responsibilities, not tightly coupled steps of one responsibility. `validateAndNormalizeEmail` does two things that must always happen together in sequence — separating them creates an invalid-state window. When steps have no valid independent use, they are one responsibility expressed as a pipeline.

- **Size vs clarity**: A 25-line function with one clear purpose is better than five 5-line functions with unclear relationships. Near-threshold cases are signals, not hard rules.

- **Magic number extraction**: Extract a literal to a named constant when its meaning is not self-evident or appears in multiple places. Do NOT extract self-documenting values: `return []`, `startIndex = 0`, `percentage / 100`, or HTTP status codes in framework response calls.

- **Boolean parameter opacity**: `createUser(data, true)` is opaque at the call site. Prefer named options (`{ sendWelcomeEmail: true }`) or split into descriptively named functions.

- **DRY vs wrong abstraction**: The wrong abstraction is more costly than no abstraction -- it fights every future change that doesn't fit its mold. Extract when you see the same pattern **three times** with the **same reason to change**. Until then, tolerate duplication.

- **Actionable vs safe error messages**: Error messages at trust boundaries must not reveal internal details (see `framework:secure-coding`) but should still be actionable. "Invalid email format" is safe and actionable; "Something went wrong" is safe but useless; "SQL syntax error at line 42" leaks internals. Pattern: log full details server-side with a correlation ID, return a generic but actionable message with the same ID.
