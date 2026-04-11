---
name: clean-code
description: "Apply clean code principles when generating or modifying implementation code. Enforces function focus, naming clarity, complexity management, error handling, and self-documenting style. Use during code generation, refactoring, or when the user mentions 'clean code', 'code quality', 'refactor this', 'simplify this', 'improve this', 'make this cleaner', 'clean this up', 'tidy this', 'coding guidelines', or 'implementation quality'. This skill governs the craft of writing individual code units -- not architecture (see architecture), not security posture (see secure-coding), and not test structure (see test-quality)."
---
# Clean Code

## Config Resolution

Skill support project custom. Order:

1. Look `.lattice/config.yaml` in repo root
2. If found, check `paths.clean_code` for custom doc path
3. If custom path exist, read doc and check YAML frontmatter for `mode`:
   - **`mode: override`** (or no mode): Custom doc full precedence. Use instead embedded default. Must be comprehensive -- sole reference.
   - **`mode: overlay`**: Read embedded `./references/defaults.md` first, then apply custom doc sections on top. Custom sections replace matching sections in default (matched by heading). New sections appended after default.
4. If no config/path/file, read `./references/defaults.md`
5. **Language adaptation**: If `paths.language_idioms` exist in config, read that document and adapt defaults using these sections:
   - **"Error Handling"** → adapt §8 (Error Handling) patterns to language idioms. Language idioms take precedence over pseudocode defaults.
   - **"Type System & Object Model"** → adapt §1 (Single Responsibility) cohesion guidance to language constructs (e.g., struct vs class).
   - **"Naming Conventions"** → adapt §4 (Meaningful Naming) patterns to language conventions.
   - **"Parameter & Function Design"** → adapt §2 (Small, Focused Functions) and §5 (Parameter Design) to language capabilities.
   - **"Dependency Management"** → adapt §9 (Test-Friendly Code) DI patterns to language idioms.

Default ship with skill. Opinionated best practice. Work out of box. Override only when team have different standard.

## Self-Validation Checklist

STOP after generate each component. Verify ALL before proceed. If check clearly fail, fix before present. If judgment call with multiple valid approach (see Ambiguity Signals), flag it — present options and reasoning.

1. **SINGLE RESPONSIBILITY**: Describe each function without "and"? If not → extract separate function.
2. **SIZE**: Each function under ~20 lines? If not → extract sub-operation into named function.
3. **COMPLEXITY**: Cyclomatic complexity under ~10 per function? If not → flatten with guard clause, extract branch.
4. **ABSTRACTION LEVEL**: Each function operate at one level? If high-level mixed with low-level → extract detail.
5. **NAMING**: Function/variable name reveal intent without context? If not → rename self-documenting.
6. **PARAMETERS**: Four or fewer parameter? If not → group into object.
7. **PRIMITIVE OBSESSION**: String/number/boolean clearer as named type? If so → introduce parameter object or typed wrapper.
8. **ERROR HANDLING**: Every fail-able operation have explicit handling with actionable message? Handled at right level?

## Active Anti-Pattern Scan

After checklist, scan for these. If find, fix before present.

- [ ] **God Function**: Function exceed ~30 lines doing multiple thing; description need "and" → extract focused function
- [ ] **Deep Nesting**: Three+ level indentation → flatten with early return/guard clause
- [ ] **Cryptic Naming**: Variable like `d`, `tmp2`, `processData` → rename reveal intent
- [ ] **Long Parameter Lists**: Five+ parameter → group into object or split function
- [ ] **Premature Abstraction**: Utility extracted from only two similar block → inline until Rule of Three with same reason to change
- [ ] **Swallowed Errors**: Empty catch, generic "something went wrong," silently return null → handle explicitly
- [ ] **Comments as Deodorant**: Comment explain convoluted code instead refactor → rename self-documenting; keep only "why" comment, remove "what"
- [ ] **Hidden Side Effects**: Function named `getX` also write cache/send notification → rename or separate
- [ ] **Dead Code**: Commented-out block, unused import, unreachable branch → delete (version control preserve)
- [ ] **Untestable Logic**: Side effect tangled with business logic; unit test need mock I/O → push side effect to boundary, extract pure function, inject dependency

## Ambiguity Signals

Multiple valid outcome. Present option rather than silently choose. See `./references/defaults.md` for resolution guidance on each signal below.

- **Single Responsibility**: Two tightly-coupled sequential operation may be one responsibility (pipeline), not two. "And" test catch true violation AND false positive.
- **Function Size**: Near-threshold (20-30 lines) with one clear purpose -- extract may create five unclear smaller function. Present tradeoff.
- **DRY vs Premature Abstraction**: Two identical block may serve different purpose and diverge. Until third instance with same reason to change, genuinely ambiguous.
- **Error Handling Strategy**: Exception vs Result type vs error code depend on language idiom and team convention, not universal.

## Core Principle

Clean code about **craft writing individual unit** -- function, class, module. Distinct from architecture (govern where code live) and domain modeling (govern business rule). Apply during code generation, not post-generation review.

See `./references/defaults.md` for SRP pipeline nuance, size vs clarity thresholds, magic number extraction rules, boolean parameter patterns, DRY vs wrong abstraction heuristics, and error message guidelines.