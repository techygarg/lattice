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

Multiple valid outcome. Present option rather than silently choose. Guardrails section provide resolution rule; flag tension, apply rule.

- **Single Responsibility**: Two tightly-coupled sequential operation may be one responsibility (pipeline), not two. "And" test catch true violation AND false positive.
- **Function Size**: Near-threshold (20-30 lines) with one clear purpose -- extract may create five unclear smaller function. Present tradeoff.
- **DRY vs Premature Abstraction**: Two identical block may serve different purpose and diverge. Until third instance with same reason to change, genuinely ambiguous.
- **Error Handling Strategy**: Exception vs Result type vs error code depend on language idiom and team convention, not universal.

## Core Principle

Clean code about **craft writing individual unit** -- function, class, module. Distinct from architecture (govern where code live) and domain modeling (govern business rule). Apply during code generation, not post-generation review.

## Guardrails and Nuances

Checklist and anti-pattern above are primary enforcement. These nuance resolve Ambiguity Signals. See `./references/defaults.md` for full explanation, threshold, code example.

- **SRP pipeline guardrail**: "And" test catch function with *independent* responsibility, not tightly coupled step of one responsibility. `validateAndNormalizeEmail` do two thing always together in sequence — separate create invalid-state window. When step have no valid independent use, one responsibility expressed as pipeline.

- **Size vs clarity**: 25-line function with one clear purpose better than five 5-line function with unclear relationship. Near-threshold case signal, not hard rule.

- **Magic number extraction**: Extract literal to named constant when meaning not self-evident or appear multiple place. Do NOT extract self-documenting: `return []`, `startIndex = 0`, `percentage / 100`, HTTP status code in framework response.

- **Boolean parameter opacity**: `createUser(data, true)` opaque at call site. Prefer named option (`{ sendWelcomeEmail: true }`) or split into descriptively named function.

- **DRY vs wrong abstraction**: Wrong abstraction more costly than no abstraction -- fight every future change not fit mold. Extract when see pattern **three times** with **same reason to change**. Until then, tolerate duplication.

- **Actionable vs safe error messages**: Error at trust boundary must not reveal internal (see `framework:secure-coding`) but still actionable. "Invalid email format" safe and actionable; "Something went wrong" safe but useless; "SQL syntax error at line 42" leak internal. Pattern: log full detail server-side with correlation ID, return generic but actionable message with same ID.