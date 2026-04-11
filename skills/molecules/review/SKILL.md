---
name: review
description: "Perform a structured code review by composing validation checklists from relevant atoms based on what code changed. Loads atoms conditionally -- clean-code always, architecture/DDD/security/tests only when the delta touches their domain. Produces a severity-ordered report with specific locations and fixes. Use when the user asks to 'review this', 'code review', 'quality check', 'validate the code', 'check my code', 'review the delta', or 'review this PR'."
---
# Review

## Required Skills

Load/apply skills based on scope (see Step 2 for conditional loading):

1. `framework:knowledge-priming` -- Load project context (tech stack, architecture, conventions) to evaluate against real standards (always loaded)
2. `framework:collaborative-judgment` -- Surface borderline findings with both interpretations instead of silently classifying (always loaded)
3. `framework:clean-code` -- Code craft: SRP, naming, complexity, error handling (always loaded)
4. `framework:architecture` -- Structural: layer rules, dependency direction, architectural flows (conditional)
5. `framework:domain-driven-design` -- Domain modeling: aggregates, entities, value objects (conditional)
6. `framework:secure-coding` -- Security: trust boundaries, injection, secrets, input handling (conditional)
7. `framework:test-quality` -- Test: AAA structure, isolation, assertions, naming (conditional)

## Config Resolution

Review molecule supports optional config thru review-standards doc from review-refiner (or hand-written). Configures review *process* — not what atoms check (that's atom-level config via atom refiners).

**Resolution steps:**

1. Look for `.lattice/config.yaml` in repo root.
2. Check for config key `paths.review_standards`.
3. If doc exists at path, read & check YAML frontmatter for `mode`:
   - **`mode: overlay`**: Read embedded defaults first, then apply doc's sections on top. Sections matched by heading — custom replaces matching defaults, new appended.
   - **`mode: override`** (or no mode): Custom doc full precedence. Must be comprehensive.
4. If no config or no review-standards doc found, use embedded defaults thruout workflow (full backward compat — identical to review with no config).

Review-standards doc has 7 sections map to workflow steps:

| Section | Affects step |
|---------|-------------|
| §1 Atom Loading Policy | Step 2 (Load Relevant Atoms) |
| §2 Severity Classification | Step 4 (Produce Report) |
| §3 Report Preferences | Step 4 (Produce Report) |
| §4 Scope Rules | Step 1 (Identify the Delta) |
| §5 Insight Capture Preferences | Step 5 (Capture Insights and Log Review) |
| §6 Health Log Preferences | Step 5 (Capture Insights and Log Review) |
| §7 Custom Review Dimensions | Step 3 (Run Targeted Validation) |

Each step notes where config applies with "**Config override**" callouts. When no review-standards doc exists, ignore callouts & use defaults.

## Workflow

### Step 1: Identify the Delta

Determine what code reviewing & establish scope.

- **PR or commit**: Use `git diff` for changed files/lines. Delta is changes, not entire codebase.
- **Set of files**: User specifies files. Delta is those files.
- **Feature or module**: User points to feature. Identify relevant files from codebase.

Classify delta:

1. **Which architectural layers touched?** (per loaded architecture rules) -- determines if `architecture` loads.
2. **Is domain code included?** (files in configured `domain_folder` or containing aggregates, entities, value objects) -- determines if `domain-driven-design` loads.
3. **Security-sensitive areas touched?** (auth, authz, input handling, DB queries, external API calls, file I/O, config, secrets) -- determines if `secure-coding` loads.
4. **Test files included?** -- determines if `test-quality` loads.

**Config override (§4 Scope Rules):** If review-standards doc defines scope rules, apply after identifying delta:
- **Directory exclusions**: Remove files matching exclusion patterns from delta before classification.
- **Directory inclusions (always-full-scan)**: When delta touches file in always-full-scan dir, expand delta to include all files in that dir.
- **Surrounding-code policy**: Use configured policy (strict/default/expansive) instead of default.
- **Dependency expansion**: If enabled, also include files that directly import from changed files.

### Step 2: Load Relevant Atoms

**Always load**: `framework:clean-code` -- applies to all code regardless of layer/purpose.

**Conditionally load** based on delta classification:

| Condition | Load | Why |
|-----------|------|-----|
| Delta touches multiple layers, adds new files, or changes file locations | `framework:architecture` | Structural changes can break dependency direction or layer responsibilities |
| Delta includes files in domain folder or modifies domain objects | `framework:domain-driven-design` | Domain changes can break aggregate boundaries, anemic models, or invariant enforcement |
| Delta touches trust boundaries (HTTP handlers, auth, DB queries, external APIs, secrets, config) | `framework:secure-coding` | Security-sensitive code needs injection, validation, and secrets checks |
| Delta includes test files | `framework:test-quality` | Test code has own quality standards (AAA, isolation, naming) |

When multiple atoms load, run independently -- each atom's checklist applied to parts of delta relevant to it. Findings from different atoms merged Step 4.

**Config override (§1 Atom Loading Policy):** If review-standards doc defines atom loading rules, apply instead of (override) or on top of (overlay) table above:
- **Always-load overrides**: Additional atoms moved to always-load (e.g., `secure-coding` every review). `clean-code` and `knowledge-priming` must remain always-loaded regardless of config.
- **Suppressed atoms**: Atoms listed as suppressed never loaded, even if delta matches trigger condition.
- **Custom path-based triggers**: If delta includes files matching custom path pattern, load associated atom regardless of standard conditions.
- **Modified conditions**: Replacement trigger conditions for conditional atoms.

### Step 3: Run Targeted Validation

For each loaded atom, apply two passes against delta:

**Pass 1 -- Self-Validation Checklist**: Walk thru atom's Self-Validation Checklist (numbered items in atom's SKILL.md). For each check, examine if any code in delta violates. Record violations with:
- Specific check that failed
- Exact file & line(s)
- Concrete suggested fix

**Pass 2 -- Anti-Pattern Scan**: Walk thru atom's Active Anti-Pattern Scan (checkbox items in atom's SKILL.md). For each anti-pattern, check if delta exhibits symptom. Record matches with:
- Anti-pattern name
- Symptom observed in delta
- Fix, adapted to specific code

**Scope rule**: Focus on delta. Don't review unchanged code unless change in delta creates new violation in surrounding code (e.g., new dependency breaks dependency rule for existing file). When reviewing surrounding code, note finding originates from delta's impact, not pre-existing issues.

**Config override (§7 Custom Review Dimensions):** If review-standards doc defines custom review dimensions, run after atom validation passes:
- For each custom dimension, check if delta matches trigger condition.
- For matching dimensions, apply dimension's checklist against delta using same two-pass approach: check each criterion, record findings with dimension's default severity (or classified severity), file location, suggested fix.
- Custom dimension findings merged with atom findings Step 4.

### Step 4: Produce Report

Default to **summary mode**. Use **full mode** if user asked for detailed/comprehensive review.

**Summary mode** (default):

Present top issues ordered by severity, one line each. Cap at most important findings -- don't enumerate every minor issue.

For each finding:
```
[SEVERITY] file:line -- description (atom-name: check-name)
```

Severity levels:
- **critical** -- Will cause bugs, security vulnerabilities, or data loss. Must fix.
- **warning** -- Violates principle & will cause maintenance pain. Should fix.
- **suggestion** -- Could be improved but works correctly as-is. Consider fixing.

When finding borderline between severity levels, use `framework:collaborative-judgment` — note uncertainty inline with both interpretations rather than silently classifying.

End with **"What's done well"** sentence highlighting something positive about delta -- good naming, proper error handling, clean test structure, correct layer placement. Every review should acknowledge what's working, not just what's broken.

**Full mode** (when user asks for detailed/comprehensive review):

Organize findings by atom. For each atom loaded:

```
## Clean Code
- [warning] src/services/OrderService.ts:45 -- Function `processOrder` does validation,
  business logic, and persistence (SRP violation). Extract validation into guard clause,
  persistence into repository call.
- [suggestion] src/services/OrderService.ts:72 -- Parameter list has 5 arguments.
  Group into `ProcessOrderOptions` object.

## Architecture
- [critical] src/domain/Order.ts:12 -- Inner layer imports from outer layer
  (`import { DatabaseClient }`). Violates dependency direction rules.
  Define an interface in the inner layer, implement in the outer layer.
```

After all atom sections, add:

- **What's done well**: List 2-3 positive observations.
- **Improvement suggestions** (optional): If broader patterns beyond individual findings -- e.g., "consider extracting shared validation layer" -- note here. Keep to 1-2 suggestions max.

**Config override (§2 Severity Classification):** If review-standards doc defines custom severity levels or per-atom overrides:
- Use custom severity level definitions instead of (override) or merged with (overlay) defaults above.
- Apply per-atom severity overrides: if atom has min severity floor, promote findings below that floor. If atom has max severity ceiling, cap findings above that ceiling.
- Custom dimensions from §7 use severity levels from this section.

**Config override (§3 Report Preferences):** If review-standards doc defines report preferences:
- **Default mode**: Use configured default (summary or full) instead of summary.
- **Finding cap**: Apply configured cap for summary mode.
- **Grouping strategy**: Use configured grouping (by-severity, by-atom, by-file) instead of defaults.
- **"What's done well" toggle**: If disabled, omit positive observation section.
- **Custom report sections**: Include any configured custom sections at specified position.
- Custom dimension findings merge into report alongside atom findings, following same grouping & severity ordering.

### Step 5: Capture Insights and Log Review

After presenting report, capture learnings & log review for project health visibility.

**Capture Insights** — append to `.lattice/learnings/review-insights.md`:

If recurring patterns or notable findings emerged from review:

1. Create `.lattice/learnings/` dir if doesn't exist.
2. Before appending, check for existing entry describing same pattern — update with recurrence note rather than adding new entry. Append new concise bullets to `.lattice/learnings/review-insights.md`. Create file with `# Review Insights` heading if doesn't exist.
3. Format: `- YYYY-MM-DD [Feature]: Pattern observed — actionable takeaway`
4. Each insight ONE bullet, max 2 lines. Keep concise — bullets help AI remember patterns, not verbose reports. Each entry scannable under 10 seconds.
5. Only capture patterns that help future code gen — not every finding. One-off typo not insight; "domain services keep doing repository work" is.
6. If file exceeds ~50 entries, suggest pruning oldest entries that haven't recurred in recent reviews.

**Log Review** — append to `.lattice/reviews/review-log.md`:

1. Create `.lattice/reviews/` dir if doesn't exist.
2. Append structured summary to `.lattice/reviews/review-log.md`. Create file with `# Review Log` heading if doesn't exist.
3. Format — keep each entry under 8 lines:

```
## YYYY-MM-DD — [feature/scope name]
- **Scope**: [file count], [layers touched]
- **Atoms**: [atoms loaded for this review]
- **Result**: [critical count] critical, [warning count] warning, [suggestion count] suggestion
- **Key findings**: [top 2-3 specific findings, one line]
- **Strengths**: [one positive highlight]
```

4. Health signal, not detailed report. Keep concise — bullets help track trends, not replicate full review.
5. If log exceeds ~20 entries, move oldest entries to one-line `## History` summary section at top of file.

**Config override (§5 Insight Capture Preferences):** If review-standards doc defines insight capture preferences:
- **Pruning threshold**: Use configured threshold instead of ~50.
- **Categorization tags**: If enabled, prefix each insight with configured category tag (e.g., `[security]`, `[domain]`).
- **Capture criteria**: Apply custom criteria (e.g., "always capture security findings") in addition to default pattern-based capture.
- **Format**: Use grouped format (organized under category headings) instead of flat chronological if configured.

**Config override (§6 Health Log Preferences):** If review-standards doc defines health log preferences:
- **Custom fields**: Include additional fields in each log entry (e.g., "Confidence", "Estimated fix time").
- **Entry cap**: Use configured line limit instead of 8 lines per entry.
- **History cap**: Use configured entry limit instead of ~20 before rolloff.
- **Additional metrics**: Include configured metrics (e.g., findings-per-file ratio, most-firing atoms) in each entry.
- **History compression format**: Use configured format for rolled-off entries.