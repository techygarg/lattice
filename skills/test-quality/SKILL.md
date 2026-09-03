---
name: test-quality
description: "Apply test quality principles when generating or reviewing test code. Enforces Arrange-Act-Assert structure, one behavior per test, assertion quality, test isolation, meaningful naming, and test data management. Use when writing tests, reviewing test code, or when the user mentions 'write tests', 'test this', 'test quality', 'test review', 'improve tests', or 'test structure'. Loaded automatically by the code-generating molecules (code-forge, refactor-safely, bug-fix). This skill governs the craft of writing individual test cases -- not what to test (that is driven by the code being implemented) but how to write tests that are reliable, readable, and maintainable."
---
# Test Quality

## Config Resolution

Projects can customize this skill's standards. Resolution order:

1. Read `.lattice/config.yaml` in the repo root.
2. If found, check `paths.test_quality` for a custom document path.
3. If a custom document exists at that path, read it and check its YAML frontmatter for `mode`:
   - **`mode: override`**: the custom document has full control. Use it instead of the embedded defaults. It must be complete -- treat it as the sole reference.
   - **`mode: overlay`** (or no mode field): read the embedded `./references/defaults.md` first, then apply the custom document on top. A custom section replaces the matching default section (matched by exact heading); new sections append after the defaults.
4. If a custom path is configured but no document exists at it → tell the user which configured path is missing, then fall back to `./references/defaults.md`.
5. If there is no config file or no `paths.test_quality` key, read `./references/defaults.md`.
6. **Language adaptation**: if `paths.language_idioms` is set in the config and the document exists, read its **"Testing Patterns"** section and adapt §5 (Test Naming Conventions), §4 (Test Isolation Techniques), and §6 (Test Data Builders and Factories) to the language's test-framework idioms. Language idioms take precedence over the pseudocode defaults.

## Self-Validation Checklist

**STOP after generating each test. Verify ALL checks before continuing. Fix every failed check. If a check is ambiguous (see Ambiguity Signals), flag it -- present options and reasoning.**

1. **AAA STRUCTURE**: Are arrange, act, and assert visually separate (blank lines)? Is there any logic (if/loop/try) inside arrange or assert?
2. **SINGLE BEHAVIOR**: Does the test verify one behavior per the loaded doc (default: one behavior per test; a name that needs "and" → split it)?
3. **ASSERTION QUALITY**: Does it assert observable behavior rather than implementation? Is it specific enough to catch a regression?
4. **ISOLATION**: Does the test depend on another test's output or effects? Is all mutable state created per-test?
5. **TEST NAME**: Does the name follow the team convention per the loaded doc (default: describe the behavior, not the method)? Is the failure message clear?
6. **TEST DATA**: Does complex arrange use builders/factories? Are magic values promoted to named constants? (Inline literals are fine for trivial tests.)
7. **MOCK BOUNDARIES**: Are mocks placed per the loaded doc (default: only at architectural boundaries -- I/O, external services -- not between internal collaborators)?
8. **TEST CODE AS FIRST-CLASS**: Is the test structured like production code? Shared constants at top, helpers extracted, no dead code, clear file organization?

**Project-specific checks**: if the loaded doc (from Config Resolution) contains a validation checklist section, apply those checks after the base checklist.

All checks pass → state "Passes test-quality. [next step]."

## Active Anti-Pattern Scan

After the checklist, scan for each of these. Any box you can check → fix before presenting.

- [ ] **Test-per-Method**: one test per method regardless of behaviors → one test per scenario, named for the behavior.
- [ ] **Assertion Roulette**: multiple unrelated assertions; unclear which one broke → split to one behavior per test.
- [ ] **Shared Mutable State**: tests pass alone but fail together → isolate state; per-test setup; no static mutable data.
- [ ] **Testing Implementation Details**: test breaks on a refactor that preserves behavior; mocks assert call counts → assert observable behavior, not method calls.
- [ ] **Mystery Guest**: test depends on an external file/db/env var not visible in the test → inline the data or use builders; make all preconditions visible.
- [ ] **Slow Tests by Default**: the unit suite takes minutes; tests hit db/network/filesystem → mock or fake I/O; use in-memory implementations.
- [ ] **Conditional Test Logic**: a test contains if/loop/try -- a test that needs its own tests → remove the logic; use parameterized tests; let assertions fail naturally.
- [ ] **Copy-Paste Tests**: near-identical tests with small changes → extract shared setup into builders; parameterize.

## Class-Level Review

**Fires when**: (1) all tests for a class are complete -- new or existing; (2) any test in an existing class is added or edited.

**STOP before presenting.** The per-test checks verify individual quality; this review verifies that the test suite covers the class's contract.

### Full review (new class or significant additions)

1. **Behavior inventory** — list every public method/behavior of the class under test. If the class is not available, ask the user to enumerate them.
2. **Coverage matrix** — map each test to the behavior it covers. Any behavior with zero tests → **blocking**. Do not present until the user closes the gap or explicitly accepts it.
3. **Error path check** — scan the class under test for explicit throws, conditional error branches, and edge guards. For each one found: does a test exercise this path? If not → flag it by name. Zero-coverage error paths are blocking unless the user explicitly accepts them.
4. **Behavioral duplication** — compare the "then" clauses across all tests. The same observable outcome regardless of structural differences → flag as likely duplication; name both tests.
5. **Balance signal** — any behavior that has tests but none covering a failure or edge case → surface as a question, not a hard failure: "`deleteUser` has 1 test (happy path only) -- does it have error cases?"

### Edit-scoped review (adding or changing one test in an existing class)

Run steps 3–5 only, scoped to the changed test:

- Does this test duplicate the observable outcome of any existing test?
- Does it cover a behavior or error path not previously covered?

## Ambiguity Signals

Multiple valid outcomes exist. Present the options rather than silently choosing. If `framework:collaborative-judgment` is loaded, use its presentation format. See `./references/defaults.md` for resolution guidance.

- **Unit vs Integration**: a service coordinates several components -- test it in isolation (mocked) or with real collaborators? Depends on the coupling and what the test must verify.
- **Mock Depth**: mock direct dependencies or let calls pass through? Over-mocking tests the implementation; under-mocking creates slow, flaky tests.
- **Test Granularity**: one test with multiple assertions vs multiple tests with one assertion each? When the assertions verify facets of the same behavior, grouping is fine.

## Test Code as First-Class Code

**Treat test files like production classes:**

- Shared constants and boundary values at the top of the file (named, not magic)
- Shared builders/factories extracted to helpers -- not copy-pasted per test
- Setup methods or fixtures for repeated arrange patterns
- Logical grouping: related behaviors together (by feature, by scenario type)
- Dead tests removed, not commented out
- Refactoring applies: extract a method when arrange is long, rename when intent is unclear, move shared setup when duplicated

**Refactoring opportunities to surface proactively:**

- Multiple tests repeat the same arrange → extract a builder or shared fixture
- The same assertion pattern across tests → extract a custom assertion helper
- A test file grows beyond ~300 lines → split by behavior group
- Constants scattered inline → collect at the top with descriptive names
- Deeply nested test structures → flatten with clear naming

See `./references/defaults.md` for AAA structure examples, assertion patterns, isolation techniques, naming conventions, test data builder patterns, and pyramid distribution guidance.
