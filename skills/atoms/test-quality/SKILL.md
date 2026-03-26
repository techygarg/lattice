---
name: test-quality
description: "Apply test quality principles when generating or reviewing test code. Enforces Arrange-Act-Assert structure, one behavior per test, assertion quality, test isolation, meaningful naming, and test data management. Use when writing tests, reviewing test code, or when the user mentions 'write tests', 'test this', 'test quality', 'test review', 'improve tests', or 'test structure'. This skill governs the craft of writing individual test cases -- not what to test (that is driven by the code being implemented) but how to write tests that are reliable, readable, and maintainable."
---

# Test Quality

## Config Resolution

This skill supports project-specific customizations. Resolution order:

1. Look for `.ai/config.yaml` in the repository root
2. If found, check `paths.test_quality` for a custom document path
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

STOP after generating each test. Verify ALL of the following before proceeding. If any check clearly fails, fix the code before presenting it. If a check is a judgment call with multiple valid approaches (see Ambiguity Signals), flag it — present your options and reasoning rather than silently choosing.

1. **AAA STRUCTURE**: Are arrange, act, and assert phases clearly separated with blank lines? Is there any logic (conditionals, loops, try/catch) in arrange or assert?
2. **SINGLE BEHAVIOR**: Does this test verify a single behavior? Could the test name describe it without "and"?
3. **ASSERTION QUALITY**: Are assertions on observable behavior, not implementation details? Are they specific enough to catch real regressions?
4. **ISOLATION**: Does this test depend on any other test's output or side effects? Is all mutable state created per-test?
5. **TEST NAME**: Does the name describe the behavior being tested, not the method? Would the failure message be immediately meaningful?
6. **TEST DATA**: Are builders or factories used? Are magic values replaced with named constants that reveal their purpose?
7. **MOCK BOUNDARIES**: Are mocks used only at architectural boundaries (I/O, external services), not for internal collaborators?

## Active Anti-Pattern Scan

After verifying the checklist above, scan your output for these specific anti-patterns. If you find any, fix them before presenting the code.

- [ ] **Test-per-Method**: One test per production method regardless of behaviors; tests mirror implementation structure → Organize tests by behavior: one test per scenario, named for the behavior it verifies
- [ ] **Assertion Roulette**: Multiple unrelated assertions in one test; failure does not indicate which behavior broke → Split into one behavior per test; each test has a focused assertion set
- [ ] **Shared Mutable State**: Tests pass individually but fail when run together or in different order → Isolate test state; use per-test setup/teardown; no static mutable fields
- [ ] **Testing Implementation Details**: Tests break on refactor even though behavior is unchanged; mock call counts verified → Assert on observable behavior (return values, state changes, side effects), not method calls
- [ ] **Mystery Guest**: Test depends on external file, database seed, or environment variable not visible in the test body → Inline test data or use builders; make all preconditions visible in the test
- [ ] **Slow Tests by Default**: Unit test suite takes minutes because tests hit the database, network, or filesystem → Mock or fake I/O at boundaries; push tests down the pyramid; use in-memory alternatives
- [ ] **Conditional Test Logic**: Tests contain if/else, loops, or try/catch -- tests are programs that need their own tests → Remove logic from tests; use parameterized tests for multiple inputs; let assertions fail naturally
- [ ] **Copy-Paste Tests**: Near-identical tests with minor variations; changing one pattern requires changing twenty → Extract shared setup into builders/factories; use parameterized tests for input variations

## Ambiguity Signals

These checks often have multiple valid outcomes. When you encounter one, present options rather than silently choosing.

- **Unit vs Integration**: A service that coordinates two components could be tested in isolation (mocking dependencies) or with real collaborators. The choice depends on how tightly coupled the components are and what the test is verifying.
- **Mock Depth**: Whether to mock the direct dependency or let it call through to its own dependencies. Over-mocking tests implementation; under-mocking creates slow, flaky tests.
- **Test Granularity**: One test with multiple related assertions vs multiple tests with one assertion each. When assertions verify facets of the same behavior, grouping is reasonable.

## Core Principle

A test's purpose is to **describe a behavior and fail when that behavior breaks**. Every design choice in a test should serve this purpose. Tests that are hard to read, brittle to refactor, or slow to run are not fulfilling this contract.

The cost of a bad test is not zero -- it is negative. A flaky test trains the team to ignore failures. A brittle test that breaks on every refactor slows development. A test that passes when the behavior is broken provides false confidence. The principles here ensure tests are assets, not liabilities.

This skill governs how to write tests -- structure, isolation, assertions, naming. What to test is driven by the code being implemented and the domain rules it enforces.

## Test Structure (Arrange-Act-Assert)

Three phases, clearly separated with blank lines. No logic in arrange or assert -- no conditionals, no loops, no try/catch. Complex arrange → extract a factory/builder. Complex assert → extract a custom assertion helper.

See `./references/defaults.md` for AAA structure examples.

## One Behavior Per Test

One test, one behavior. Multiple assertions are fine when they verify facets of **the same behavior** (e.g., checking name, email, and role of a created user). Verifying creation AND duplicate rejection is two behaviors -- two tests.

## Assertion Quality

- **Assert on observable behavior**, not implementation details. Prefer `assertEqual(result.total, 42.50)` over `verify(calculator.multiply was called)`.
- **Specific over generic.** `assertEqual(result.total, 42.50)` over `assertNotNull(result)`.
- **Custom assertion helpers** when the same pattern recurs across tests.
- **Assert on the negative space** when it matters -- something did NOT happen.

See `./references/defaults.md` for assertion pattern examples.

## Test Isolation

**Any test should pass when run alone and in any order.** No shared mutable state. No execution order dependencies. Isolation techniques: transaction rollback for DB tests, temp directories for filesystem tests, stubs/fakes for network tests, injected clock for time-dependent tests. Shared fixtures are acceptable only for immutable reference data.

See `./references/defaults.md` for test isolation techniques.

## Test Naming

Pattern: `should_[expected behavior]_when_[condition]` or `[method]_[scenario]_[expected result]`. Describe behavior, not implementation. Avoid `test1`, `testHappyPath`, or names that mirror method names without context.

## Test Data Management

Use builders or factories -- only specify values relevant to the test, use sensible defaults for everything else. `anOrder().withTotal(ABOVE_DISCOUNT_THRESHOLD)` over `new Order(null, null, 1500, null)`. Inline edge-case values in the test body, not in fixture files.

See `./references/defaults.md` for builder/factory patterns.

## Test Pyramid Thinking

Most tests should be unit tests. When a higher-level test fails, **write a unit test that reproduces the failure** before fixing it. Push coverage downward. Avoid the ice cream cone anti-pattern (many E2E, few unit tests).

See `./references/defaults.md` for test pyramid distribution guidance.
