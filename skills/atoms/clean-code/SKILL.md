---
name: clean-code
description: "Apply clean code principles when generating or modifying implementation code. Enforces function focus, naming clarity, complexity management, error handling, and self-documenting style. Use when the user mentions 'clean code', 'code quality', 'coding guidelines', or 'implementation quality'. Loaded automatically by the code-generating molecules (code-forge, refactor-safely, bug-fix). This skill governs the craft of writing individual code units -- not architecture (see architecture), not security posture (see secure-coding), not test structure (see test-quality), and not refactoring workflows (see refactor-safely)."
---
# Clean Code

## Config Resolution

Projects can customize this skill's standards. Resolution order:

1. Read `.lattice/config.yaml` in the repo root.
2. If found, check `paths.clean_code` for a custom document path.
3. If a custom document exists at that path, read it and check its YAML frontmatter for `mode`:
   - **`mode: override`**: the custom document has full precedence. Use it instead of the embedded defaults. It must be comprehensive -- treat it as the sole reference.
   - **`mode: overlay`** (or no mode field): read the embedded `./references/defaults.md` first, then apply the custom document's sections on top. A custom section replaces the matching default section (matched by exact heading); new sections append after the defaults.
4. If a custom path is configured but no document exists at it → tell the user which configured path is missing, then fall back to `./references/defaults.md`.
5. If there is no config file or no `paths.clean_code` key, read `./references/defaults.md`.
6. **Language adaptation**: if `paths.language_idioms` is set in the config and the document exists, read it and adapt the defaults using these sections:
   - **"Error Handling"** → adapt §8 (Error Handling) patterns to the language's idioms. Language idioms take precedence over the pseudocode defaults.
   - **"Type System & Object Model"** → adapt §1 (Single Responsibility) cohesion guidance to the language's constructs (e.g., struct vs class).
   - **"Naming Conventions"** → adapt §4 (Meaningful Naming) patterns to the language's conventions.
   - **"Parameter & Function Design"** → adapt §2 (Small, Focused Functions) and §5 (Parameter Design) to the language's capabilities.
   - **"Dependency Management"** → adapt §9 (Test-Friendly Code) dependency-injection patterns to the language's idioms.

## Self-Validation Checklist

**STOP after generating each component. Verify ALL checks. Fix every failed check before presenting. Judgment calls → present options (see Ambiguity Signals).**

1. **SINGLE RESPONSIBILITY**: Can you describe each function without "and"? If not → extract a separate function.
2. **SIZE**: Is each function under the size threshold from the loaded doc (~20 lines default)? If not → extract a sub-operation into its own named function.
3. **COMPLEXITY**: Is cyclomatic complexity under the threshold from the loaded doc (~10 default)? If not → flatten with a guard clause or extract a branch.
4. **ABSTRACTION LEVEL**: Does each function operate at one level of abstraction? If high-level logic mixes with low-level detail → extract the detail.
5. **NAMING**: Does each function/variable name reveal intent without needing surrounding context? If not → rename to be self-documenting.
6. **PARAMETERS**: Is the parameter count under the threshold from the loaded doc (4 default)? If not → group parameters into an object.
7. **PRIMITIVE OBSESSION**: Would a string/number/boolean be clearer as a named type? If so → introduce a parameter object or typed wrapper.
8. **ERROR HANDLING**: Does every fail-able operation have explicit handling with an actionable message? Is it handled at the right level?

**Project-specific checks**: if the loaded doc (from Config Resolution) contains a Validation Checklist section (§10 from the clean-code-refiner template), apply those checks as additional project-specific validation after the checklist above.

All checks pass → state "Passes clean-code. [next step]."

## Active Anti-Pattern Scan

After the checklist, scan for each of these. Any box you can check → fix before presenting.

- [ ] **God Function**: a function exceeds ~30 lines doing multiple things; describing it requires "and" → extract focused functions.
- [ ] **Deep Nesting**: three or more levels of indentation → flatten with early returns / guard clauses.
- [ ] **Cryptic Naming**: variables like `d`, `tmp2`, `processData` → rename to reveal intent.
- [ ] **Long Parameter Lists**: five or more parameters → group into an object or split the function.
- [ ] **Premature Abstraction**: a utility extracted from only two similar blocks → inline it until the Rule of Three (third instance with the same reason to change).
- [ ] **Swallowed Errors**: empty catch blocks, generic "something went wrong" messages, silent null returns → handle explicitly.
- [ ] **Comments as Deodorant**: a comment explains convoluted code instead of the code being fixed → rename to self-document; keep only "why" comments, remove "what" comments.
- [ ] **Hidden Side Effects**: a function named `getX` also writes a cache or sends notifications → rename or separate the concern.
- [ ] **Dead Code**: commented-out blocks, unused imports, unreachable branches → delete them (version control preserves history).
- [ ] **Untestable Logic**: side effects tangled with business logic; unit testing requires mocking I/O → push side effects to the boundary, extract pure functions, inject dependencies.

## Ambiguity Signals

Multiple valid outcomes exist. Present the options rather than silently choosing. If `framework:collaborative-judgment` is loaded, use its presentation format. See `./references/defaults.md` for resolution guidance on each signal below.

- **Single Responsibility**: two tightly-coupled sequential operations may be one responsibility (a pipeline), not two. The "and" test catches true violations AND false positives.
- **Function Size**: near-threshold size (20–30 lines) with one clear purpose -- extraction may create five unclear smaller functions. Present the tradeoff.
- **DRY vs Premature Abstraction**: two identical blocks may serve different purposes and diverge independently. Until a third instance with the same reason to change appears, this is genuinely ambiguous.
- **Error Handling Strategy**: exception vs Result type vs error codes depends on language idiom and team convention, not on universal rules.
