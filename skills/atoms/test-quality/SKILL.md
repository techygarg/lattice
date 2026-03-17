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

## Core Principle

A test's purpose is to **describe a behavior and fail when that behavior breaks**. Every design choice in a test should serve this purpose. Tests that are hard to read, brittle to refactor, or slow to run are not fulfilling this contract.

The cost of a bad test is not zero -- it is negative. A flaky test trains the team to ignore failures. A brittle test that breaks on every refactor slows development. A test that passes when the behavior is broken provides false confidence. The principles here ensure tests are assets, not liabilities.

This skill governs how to write tests -- structure, isolation, assertions, naming. What to test is driven by the code being implemented and the domain rules it enforces.

## Test Structure (Arrange-Act-Assert)

Every test has three phases, clearly separated. This structure makes the test readable at a glance -- the reader can immediately see the setup, the action, and the expected outcome.

- **Arrange**: Set up the preconditions and inputs. Create the objects, configure the dependencies, prepare the test data.
- **Act**: Perform the single action under test. One function call, one method invocation, one operation.
- **Assert**: Verify the expected outcome. Check return values, state changes, or side effects.

One blank line between each phase. No logic in the arrange or assert phases -- no conditionals, no loops, no try/catch. If the arrange is complex, extract a factory or builder. If the assert is complex, extract a custom assertion helper.

The test body should read like a specification: "Given this setup, when this happens, then this should be true." See `./references/defaults.md` for AAA structure examples with good vs poor separation.

## One Behavior Per Test

A test should verify one specific behavior, not exercise multiple scenarios. The test name should describe the behavior: `should_reject_order_when_inventory_insufficient`, not `test_order_validation`.

Multiple assertions are fine when they verify different facets of **the same behavior**. Verifying that a created user has the correct name, email, and role is one behavior (user creation). Verifying that user creation works AND that duplicate emails are rejected is two behaviors -- two tests.

The reason: when a multi-behavior test fails, the failure message is ambiguous. You cannot tell which behavior broke without reading the test body and tracing the failure. Single-behavior tests turn failures into diagnostics -- the test name tells you what broke.

See `./references/defaults.md` for examples of splitting multi-behavior tests.

## Assertion Quality

Assert on the specific thing that matters. The assertion is the most important line in the test -- it defines what "correct" means.

- **Assert on observable behavior**, not implementation details. Prefer `assertEqual(result.total, 42.50)` over `verify(calculator.multiply was called)`. When you assert on method calls, the test breaks on any refactor even if the behavior is preserved.
- **Prefer specific assertions over generic.** `assertEqual(result.total, 42.50)` over `assertNotNull(result)`. Generic assertions pass when the behavior is broken -- they test existence, not correctness.
- **Custom assertion helpers** improve readability when the same assertion pattern recurs. `assertOrderIsValid(order)` is clearer than five raw assertions repeated across twenty tests.
- **Assert on the negative space** when it matters. Sometimes the most important assertion is that something did NOT happen -- no email was sent, no record was created, no exception was thrown.

See `./references/defaults.md` for assertion pattern examples (specific vs generic, custom assertions).

## Test Isolation

Tests must not depend on each other. No shared mutable state. No execution order dependencies. Each test sets up its own world and tears it down. The principle: **any test should pass when run alone and when run in any order within the suite.**

Isolation techniques by context:

- **Database tests** -- Use transactions that roll back after each test, or use a fresh database per test. Never rely on seed data from a previous test.
- **File system tests** -- Use temporary directories created per test and cleaned up after.
- **Network tests** -- Use stubs, fakes, or recorded responses. Never hit real external services in unit tests.
- **Time-dependent tests** -- Inject a clock abstraction. Never call `Date.now()` or equivalent directly in code under test.
- **Shared fixtures** -- Acceptable for immutable reference data (country codes, currency formats). Mutable state must be per-test.

See `./references/defaults.md` for test isolation techniques with before/after examples.

## Test Naming

Test names are the first thing a developer reads when a test fails. A good test name makes the failure meaningful without reading the test body.

- **Pattern**: `should_[expected behavior]_when_[condition]` or `[method]_[scenario]_[expected result]`.
- **Describe behavior, not implementation.** `should_apply_discount_when_order_exceeds_threshold` -- not `test_calculateTotal_method`.
- **Make failure messages meaningful.** When `should_reject_order_when_inventory_insufficient` fails, you know the system accepted an order it should have rejected. When `testOrder3` fails, you know nothing.
- **Avoid** `test1`, `testHappyPath`, or names that mirror method names without adding context.

See `./references/defaults.md` for test naming convention examples across languages.

## Test Data Management

Test data should be explicit, minimal, and intentional. The reader should understand why each value was chosen.

- **Use builders or factories** for test data, not raw constructors with many parameters. Only specify values relevant to the test -- use sensible defaults for everything else.
- **Avoid magic numbers and strings.** Use named constants or builder methods that communicate intent: `anOrder().withTotal(ABOVE_DISCOUNT_THRESHOLD)` is clearer than `new Order(null, null, 1500, null)`.
- **Shared fixtures** are acceptable for immutable reference data. Mutable state must be per-test.
- **Inline the important data.** If the test is about a specific edge case (empty string, zero quantity, boundary value), make that value visible in the test body, not hidden in a fixture file.

See `./references/defaults.md` for builder/factory patterns for test data.

## Test Pyramid Thinking

Most tests should be unit tests -- fast, isolated, focused on one behavior. The pyramid is a distribution guide, not a rigid rule.

- **Unit tests** (base): Test individual functions, methods, or classes in isolation. Fast, deterministic, focused. These form the majority of the suite.
- **Integration tests** (middle): Verify that boundaries work together -- database queries return expected results, API clients parse responses correctly, message handlers process events.
- **End-to-end tests** (top): Verify critical user journeys through the full stack. Expensive to write and maintain, slow to run. Reserve for high-value paths.

When a test at a higher level fails, **write a unit test that reproduces the failure** before fixing it. Push coverage downward. Avoid the ice cream cone anti-pattern -- many E2E tests and few unit tests -- which leads to slow, flaky, expensive test suites.

See `./references/defaults.md` for test pyramid distribution guidance.

## Self-Validation During Code Generation

When generating test code, apply these checks as you write -- not as a post-generation review, but as an inline discipline. If any check clearly fails, fix it. If a check is a judgment call with multiple valid approaches (see Ambiguity Signals), flag it — present your options and reasoning rather than silently choosing.

1. **Check AAA structure**: Are arrange, act, and assert phases clearly separated with blank lines? Is there logic in arrange or assert?
2. **Verify one behavior per test**: Does this test verify a single behavior? Could the test name describe it without "and"?
3. **Assess assertion quality**: Are assertions on observable behavior, not implementation details? Are they specific enough to catch real regressions?
4. **Confirm isolation**: Does this test depend on any other test's output or side effects? Is mutable state per-test?
5. **Review the test name**: Does the name describe the behavior being tested? Would the failure message be meaningful?
6. **Check test data**: Are builders or factories used? Are magic values replaced with named constants?
7. **Verify mock boundaries**: Are mocks used only at architectural boundaries (I/O, external services), not for internal collaborators?

## Anti-Patterns

Common test quality violations and their fixes. See `./references/defaults.md` for code examples showing each violation and its correction.

| Anti-Pattern | Symptom | Fix |
|-------------|---------|-----|
| **Test-per-Method** | One test per production method regardless of behaviors; tests mirror implementation structure | Organize tests by behavior: one test per scenario, named for the behavior it verifies |
| **Assertion Roulette** | Multiple unrelated assertions in one test; failure does not indicate which behavior broke | Split into one behavior per test; each test has a focused assertion set |
| **Shared Mutable State** | Tests pass individually but fail when run together or in different order | Isolate test state; use per-test setup/teardown; no static mutable fields |
| **Testing Implementation Details** | Tests break on refactor even though behavior is unchanged; mock counts verified | Assert on observable behavior (return values, state changes, side effects), not method calls |
| **Mystery Guest** | Test depends on external file, database seed, or environment variable not visible in the test body | Inline test data or use builders; make all preconditions visible in the test |
| **Slow Tests by Default** | Unit test suite takes minutes because tests hit the database, network, or filesystem | Mock or fake I/O at boundaries; push tests down the pyramid; use in-memory alternatives |
| **Conditional Test Logic** | Tests contain if/else, loops, or try/catch -- tests are programs that need their own tests | Remove logic from tests; use parameterized tests for multiple inputs; let assertions fail naturally |
| **Copy-Paste Tests** | Near-identical tests with minor variations; changing one pattern requires changing twenty tests | Extract shared setup into builders/factories; use parameterized tests for input variations |

## Ambiguity Signals

These checks often have multiple valid outcomes. When you encounter one, present options rather than silently choosing.

- **Unit vs Integration**: A service that coordinates two components could be tested in isolation (mocking dependencies) or with real collaborators. The choice depends on how tightly coupled the components are and what the test is verifying.
- **Mock Depth**: Whether to mock the direct dependency or let it call through to its own dependencies. Over-mocking tests implementation; under-mocking creates slow, flaky tests.
- **Test Granularity**: One test with multiple related assertions vs multiple tests with one assertion each. When assertions verify facets of the same behavior, grouping is reasonable.

## Validation Checklist

When generating or reviewing test code, verify these constraints.

| Check | Why It Matters |
|-------|---------------|
| AAA structure is visible with clear phase separation | Tests without clear structure require reading the entire body to understand setup, action, and expectation |
| Each test verifies one behavior | Multi-behavior tests produce ambiguous failures that require debugging to diagnose |
| Assertions target observable behavior, not implementation | Implementation-coupled tests break on every refactor, eroding trust and slowing development |
| No shared mutable state between tests | Shared state creates order-dependent tests -- the most insidious form of flakiness |
| Test names describe the behavior being verified | Poor names turn failures into mysteries; good names turn failures into diagnostics |
| Test data uses builders or factories with sensible defaults | Raw constructors with many parameters obscure which values matter and invite copy-paste errors |
| Mocks are used only at architectural boundaries | Over-mocking tests implementation, not behavior; changes to internal structure break the tests |
| Test pyramid balance is maintained | Top-heavy suites (many E2E, few unit) are slow, flaky, and expensive to maintain |
