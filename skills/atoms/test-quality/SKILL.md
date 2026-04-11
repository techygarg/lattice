---
name: test-quality
description: "Apply test quality principles when generating or reviewing test code. Enforces Arrange-Act-Assert structure, one behavior per test, assertion quality, test isolation, meaningful naming, and test data management. Use when writing tests, reviewing test code, or when the user mentions 'write tests', 'test this', 'test quality', 'test review', 'improve tests', or 'test structure'. This skill governs the craft of writing individual test cases -- not what to test (that is driven by the code being implemented) but how to write tests that are reliable, readable, and maintainable."
---
# Test Quality

## Config Resolution

Skill support project custom. Order:

1. Look `.lattice/config.yaml` in repo root
2. If find, check `paths.test_quality` for custom doc path
3. If custom path exist, read doc & check YAML frontmatter for `mode`:
   - **`mode: override`** (or no mode): Custom doc take full control. Use instead default. Must be complete -- is only reference.
   - **`mode: overlay`**: Read `./references/defaults.md` first, then apply custom doc on top. Custom sections replace match sections (by heading). New sections add after.
4. If no config/path/file, read `./references/defaults.md`
5. **Language adaptation**: If `paths.language_idioms` exist in config, read **"Testing Patterns"** section and adapt §5 (Test Naming), §4 (Test Isolation), §6 (Test Data Builders) to language test framework idioms. Language idioms take precedence over pseudocode defaults.

Defaults ship w/ skill. Work out-of-box. Override only when team have different standards.

## Self-Validation Checklist

STOP after gen each test. Check ALL before continue. If fail, fix. If ambiguous (see Ambiguity Signals), flag -- show options & reasoning.

1. **AAA STRUCTURE**: arrange, act, assert separate w/ blank lines? Any logic (if/loop/try) in arrange or assert?
2. **SINGLE BEHAVIOR**: Test verify one behavior? Name need "and"?
3. **ASSERTION QUALITY**: Assert observable behavior, not implementation? Specific enough catch regression?
4. **ISOLATION**: Test depend other test output/effects? All mutable state per-test?
5. **TEST NAME**: Name describe behavior, not method? Failure message clear?
6. **TEST DATA**: Use builders/factories? Magic values → named constants?
7. **MOCK BOUNDARIES**: Mock only at arch boundaries (I/O, external), not internal collab?

## Active Anti-Pattern Scan

After checklist, scan these. If find, fix before present.

- [ ] **Test-per-Method**: One test per method regardless behaviors → One test per scenario, named for behavior
- [ ] **Assertion Roulette**: Multiple unrelated asserts; unclear which broke → Split to one behavior per test
- [ ] **Shared Mutable State**: Pass alone, fail together → Isolate state; per-test setup; no static mutable
- [ ] **Testing Implementation Details**: Break on refactor w/ same behavior; mock call counts → Assert observable behavior, not method calls
- [ ] **Mystery Guest**: Depend external file/db/env var not visible → Inline data or use builders; all preconditions visible
- [ ] **Slow Tests by Default**: Unit suite take minutes; hit db/network/fs → Mock/fake I/O; use in-memory
- [ ] **Conditional Test Logic**: Test have if/loop/try -- test need own tests → Remove logic; use parameterized; let asserts fail natural
- [ ] **Copy-Paste Tests**: Near-identical w/ small changes → Extract shared setup to builders; use parameterized

## Ambiguity Signals

Multiple valid outcomes. Present options, not choose silent.

- **Unit vs Integration**: Service coordinate components -- test isolate (mock) or real collab? Depend coupling & what verify.
- **Mock Depth**: Mock direct depend or let call through? Over-mock test implementation; under-mock create slow/flaky.
- **Test Granularity**: One test multi asserts vs multi tests one assert? When asserts verify facets same behavior, group ok.

## Core Principle

Test purpose: **describe behavior & fail when behavior break**. Every choice serve this. Hard read, brittle refactor, slow run = not fulfill contract.

Bad test cost negative. Flaky train team ignore. Brittle slow dev. Pass when behavior broke = false confidence. Principles ensure tests assets, not liabilities.

Skill govern HOW write tests -- structure, isolation, asserts, naming. WHAT test driven by code implement & domain rules.

See `./references/defaults.md` for AAA structure examples, assertion patterns, isolation techniques, naming conventions, test data builder patterns, and pyramid distribution guidance.