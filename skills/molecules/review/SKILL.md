---
name: review
description: "Perform a structured code review by composing validation checklists from relevant atoms based on what code changed. Loads atoms conditionally -- clean-code always, architecture/DDD/security/tests only when the delta touches their domain. Produces a severity-ordered report with specific locations and fixes. Use when the user asks to 'review this', 'code review', 'quality check', 'validate the code', 'check my code', 'review the delta', or 'review this PR'."
---

# Review

## Required Skills

Load and apply these skills based on the scope of the review (see Step 2 for conditional loading):

1. `framework:knowledge-priming` -- Load project context (tech stack, architecture, conventions) to evaluate changes against real project standards (always loaded)
2. `framework:collaborative-judgment` -- Surface borderline findings with both interpretations instead of silently classifying (always loaded)
3. `framework:clean-code` -- Code craft validation: SRP, naming, complexity, error handling (always loaded)
4. `framework:architecture` -- Structural validation: layer rules, dependency direction, architectural flows (conditional)
5. `framework:domain-driven-design` -- Domain modeling validation: aggregates, entities, value objects (conditional)
   → Skip if `disable.domain_driven_design: true` in `.ai/config.yaml`
6. `framework:secure-coding` -- Security validation: trust boundaries, injection, secrets, input handling (conditional)
7. `framework:test-quality` -- Test validation: AAA structure, isolation, assertions, naming (conditional)

## Config Resolution

The review molecule supports optional process configuration through a review-standards document produced by the review-refiner (or written by hand). This configures how the review *process* works — not what atoms check for (that's atom-level config via atom refiners).

**Resolution steps:**

1. Look for `.ai/config.yaml` in the repository root.
2. Check for the config key `paths.review_standards`.
3. If a document exists at that path, read it and check its YAML frontmatter for `mode`:
   - **`mode: overlay`**: Read the embedded defaults in this workflow first, then apply the document's sections on top. Sections are matched by heading — custom sections replace matching defaults, new sections are appended.
   - **`mode: override`** (or no mode specified): The custom document takes full precedence. It must be comprehensive.
4. If no config exists or no review-standards document is found, use the embedded defaults throughout this workflow (full backward compatibility — identical behavior to a review with no config).

The review-standards document has 7 sections that map to workflow steps:

| Section | Affects step |
|---------|-------------|
| §1 Atom Loading Policy | Step 2 (Load Relevant Atoms) |
| §2 Severity Classification | Step 4 (Produce Report) |
| §3 Report Preferences | Step 4 (Produce Report) |
| §4 Scope Rules | Step 1 (Identify the Delta) |
| §5 Insight Capture Preferences | Step 5 (Capture Insights and Log Review) |
| §6 Health Log Preferences | Step 5 (Capture Insights and Log Review) |
| §7 Custom Review Dimensions | Step 3 (Run Targeted Validation) |

Each step below notes where config applies with "**Config override**" callouts. When no review-standards document exists, these callouts are ignored and defaults apply.

## Workflow

### Disable Check

Read `.ai/config.yaml`. If `disable.domain_driven_design: true` → skip `framework:domain-driven-design` for the entire workflow. No replacement atom. Do not load it in Step 2, do not run its checks in Step 3, and do not include it in the report in Step 4.

### Step 1: Identify the Delta

Determine what code is being reviewed and establish the scope.

- **PR or commit**: Use `git diff` to identify changed files and lines. The delta is the set of changes, not the entire codebase.
- **Set of files**: The user specifies which files to review. The delta is those files.
- **Feature or module**: The user points to a feature. Identify the relevant files from the codebase.

Classify the delta by answering these questions:

1. **Which architectural layers are touched?** (per the loaded architecture rules) -- determines if `architecture` loads.
2. **Is domain code included?** (files in the configured `domain_folder` or containing aggregates, entities, value objects) -- determines if `domain-driven-design` loads.
3. **Are security-sensitive areas touched?** (authentication, authorization, input handling, database queries, external API calls, file I/O, configuration, secrets) -- determines if `secure-coding` loads.
4. **Are test files included?** -- determines if `test-quality` loads.

**Config override (§4 Scope Rules):** If the review-standards document defines scope rules, apply them after identifying the delta:
- **Directory exclusions**: Remove files matching exclusion patterns from the delta before classification.
- **Directory inclusions (always-full-scan)**: When the delta touches a file in an always-full-scan directory, expand the delta to include all files in that directory.
- **Surrounding-code policy**: Use the configured policy (strict/default/expansive) instead of the default.
- **Dependency expansion**: If enabled, also include files that directly import from changed files.

### Step 2: Load Relevant Atoms

**Always load**: `framework:clean-code` -- applies to all code regardless of layer or purpose.

**Conditionally load** based on the delta classification:

| Condition | Load | Why |
|-----------|------|-----|
| Delta touches multiple layers, adds new files, or changes file locations | `framework:architecture` | Structural changes can break dependency direction or layer responsibilities |
| Delta includes files in the domain folder or modifies domain objects | `framework:domain-driven-design` | Domain changes can break aggregate boundaries, anemic models, or invariant enforcement |
| Delta touches trust boundaries (HTTP handlers, auth, DB queries, external APIs, secrets, config) | `framework:secure-coding` | Security-sensitive code needs injection, validation, and secrets checks |
| Delta includes test files | `framework:test-quality` | Test code has its own quality standards (AAA, isolation, naming) |

When multiple atoms load, they run independently -- each atom's checklist is applied to the parts of the delta relevant to it. Findings from different atoms are merged in Step 4.

**Config override (§1 Atom Loading Policy):** If the review-standards document defines atom loading rules, apply them instead of (override) or on top of (overlay) the table above:
- **Always-load overrides**: Additional atoms moved to always-load (e.g., `secure-coding` on every review). `clean-code` and `knowledge-priming` must remain always-loaded regardless of config.
- **Suppressed atoms**: Atoms listed as suppressed are never loaded, even if the delta matches their trigger condition.
- **Custom path-based triggers**: If the delta includes files matching a custom path pattern, load the associated atom regardless of the standard conditions.
- **Modified conditions**: Replacement trigger conditions for conditional atoms.

### Step 3: Run Targeted Validation

For each loaded atom, apply two passes against the delta:

**Pass 1 -- Self-Validation Checklist**: Walk through the atom's Self-Validation Checklist (the numbered items in each atom's SKILL.md). For each check, examine whether any code in the delta violates it. Record violations with:
- The specific check that failed
- The exact file and line(s)
- A concrete suggested fix

**Pass 2 -- Anti-Pattern Scan**: Walk through the atom's Active Anti-Pattern Scan (the checkbox items in each atom's SKILL.md). For each anti-pattern, check if the delta exhibits the symptom. Record matches with:
- The anti-pattern name
- The symptom observed in the delta
- The fix, adapted to the specific code

**Scope rule**: Focus on the delta. Do not review unchanged code unless a change in the delta creates a new violation in surrounding code (e.g., a new dependency that breaks the dependency rule for an existing file). When reviewing surrounding code, note that the finding originates from the delta's impact, not from pre-existing issues.

**Config override (§7 Custom Review Dimensions):** If the review-standards document defines custom review dimensions, run them after the atom validation passes:
- For each custom dimension, check whether the delta matches its trigger condition.
- For matching dimensions, apply the dimension's checklist against the delta using the same two-pass approach: check each criterion, record findings with the dimension's default severity (or classified severity), file location, and suggested fix.
- Custom dimension findings are merged with atom findings in Step 4.

### Step 4: Produce Report

Default to **summary mode**. Use **full mode** if the user asked for a detailed or comprehensive review.

**Summary mode** (default):

Present the top issues ordered by severity, one line each. Cap at the most important findings -- do not enumerate every minor issue.

For each finding:
```
[SEVERITY] file:line -- description (atom-name: check-name)
```

Severity levels:
- **critical** -- Will cause bugs, security vulnerabilities, or data loss. Must fix.
- **warning** -- Violates a principle and will cause maintenance pain. Should fix.
- **suggestion** -- Could be improved but works correctly as-is. Consider fixing.

When a finding is borderline between severity levels, use `framework:collaborative-judgment` — note the uncertainty inline with both interpretations rather than silently classifying.

End with a **"What's done well"** sentence highlighting something positive about the delta -- good naming, proper error handling, clean test structure, correct layer placement. Every review should acknowledge what's working, not just what's broken.

**Full mode** (when user asks for a detailed or comprehensive review):

Organize findings by atom. For each atom that was loaded:

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
- **Improvement suggestions** (optional): If there are broader patterns beyond individual findings -- e.g., "consider extracting a shared validation layer" -- note them here. Keep to 1-2 suggestions maximum.

**Config override (§2 Severity Classification):** If the review-standards document defines custom severity levels or per-atom overrides:
- Use the custom severity level definitions instead of (override) or merged with (overlay) the defaults above.
- Apply per-atom severity overrides: if an atom has a minimum severity floor, promote findings below that floor. If an atom has a maximum severity ceiling, cap findings above that ceiling.
- Custom dimensions from §7 use severity levels from this section.

**Config override (§3 Report Preferences):** If the review-standards document defines report preferences:
- **Default mode**: Use the configured default (summary or full) instead of summary.
- **Finding cap**: Apply the configured cap for summary mode.
- **Grouping strategy**: Use the configured grouping (by-severity, by-atom, by-file) instead of the defaults.
- **"What's done well" toggle**: If disabled, omit the positive observation section.
- **Custom report sections**: Include any configured custom sections at the specified position.
- Custom dimension findings merge into the report alongside atom findings, following the same grouping and severity ordering.

### Step 5: Capture Insights and Log Review

After presenting the report to the user, capture learnings and log the review for project health visibility.

**Capture Insights** — append to `.ai/learnings/review-insights.md`:

If recurring patterns or notable findings emerged from this review:

1. Create `.ai/learnings/` directory if it doesn't exist.
2. Before appending, check for an existing entry describing the same pattern — update it with a recurrence note rather than adding a new entry. Append new concise bullet points to `.ai/learnings/review-insights.md`. Create the file with a `# Review Insights` heading if it doesn't exist.
3. Format: `- YYYY-MM-DD [Feature]: Pattern observed — actionable takeaway`
4. Each insight is ONE bullet point, max 2 lines. Keep entries concise — bullet points that help AI remember patterns, not verbose reports. Each entry should be scannable in under 10 seconds.
5. Only capture patterns that would help future code generation — not every finding. A one-off typo is not an insight; "domain services keep doing repository work" is.
6. If the file exceeds ~50 entries, suggest pruning oldest entries that haven't recurred in recent reviews.

**Log Review** — append to `.ai/reviews/review-log.md`:

1. Create `.ai/reviews/` directory if it doesn't exist.
2. Append a structured summary to `.ai/reviews/review-log.md`. Create the file with a `# Review Log` heading if it doesn't exist.
3. Format — keep each entry under 8 lines:

```
## YYYY-MM-DD — [feature/scope name]
- **Scope**: [file count], [layers touched]
- **Atoms**: [atoms loaded for this review]
- **Result**: [critical count] critical, [warning count] warning, [suggestion count] suggestion
- **Key findings**: [top 2-3 specific findings, one line]
- **Strengths**: [one positive highlight]
```

4. This is a health signal, not a detailed report. Keep entries concise — bullet points that help track trends, not replicate the full review.
5. If the log exceeds ~20 entries, move the oldest entries to a one-line `## History` summary section at the top of the file.

**Config override (§5 Insight Capture Preferences):** If the review-standards document defines insight capture preferences:
- **Pruning threshold**: Use the configured threshold instead of ~50.
- **Categorization tags**: If enabled, prefix each insight with the configured category tag (e.g., `[security]`, `[domain]`).
- **Capture criteria**: Apply custom criteria (e.g., "always capture security findings") in addition to the default pattern-based capture.
- **Format**: Use grouped format (organized under category headings) instead of flat chronological if configured.

**Config override (§6 Health Log Preferences):** If the review-standards document defines health log preferences:
- **Custom fields**: Include additional fields in each log entry (e.g., "Confidence", "Estimated fix time").
- **Entry cap**: Use the configured line limit instead of 8 lines per entry.
- **History cap**: Use the configured entry limit instead of ~20 before rolloff.
- **Additional metrics**: Include configured metrics (e.g., findings-per-file ratio, most-firing atoms) in each entry.
- **History compression format**: Use the configured format for rolled-off entries.
