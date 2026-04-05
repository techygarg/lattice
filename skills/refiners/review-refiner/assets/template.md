# Review Refiner Template

This template defines the structure of the `.ai/standards/review-standards.md` output document. It contains all default values from the review molecule's hardcoded behavior, interleaved with interview guidance comments.

When producing the output, strip all `<!-- INTERVIEW GUIDANCE: -->` comments. The final document is a specification, not a conversation log.

**Scope boundary**: This template configures *how the review process works* -- atom loading, severity levels, report format, scope rules, insight capture, health logging. It does NOT configure *what atoms check for* -- those quality standards belong in atom-specific refiners (architecture-refiner, clean-code-refiner, ddd-refiner).

| Belongs here (process orchestration) | Belongs in atom refiners (quality standards) |
|---------------------------------------|----------------------------------------------|
| Which atoms load and when | What checks an atom runs |
| Severity level definitions | What constitutes a violation |
| Report format and grouping | Checklist items and anti-patterns |
| Delta scope rules | Layer definitions, naming rules |
| Insight capture preferences | Domain modeling rules |
| Health log format | Security check thresholds |
| Custom review dimensions | Atom-specific validation logic |

---

## Frontmatter

<!-- INTERVIEW GUIDANCE:
Choose one of the two frontmatter options based on the user's chosen mode.
Default to overlay unless the user explicitly wants to redefine everything.
-->

Option A — Overlay mode (most common):

```yaml
---
mode: overlay
---
```

Option B — Override mode (complete replacement):

```yaml
---
mode: override
---
```

---

## Preamble

<!-- INTERVIEW GUIDANCE:
Include the preamble matching the chosen mode. Only one preamble appears in the output.
-->

**Overlay preamble:**

> This document overlays project-specific customizations on top of the review molecule's embedded defaults. Only sections included here differ from the defaults — all other sections remain as-is.
>
> Sections below replace matching sections in the defaults (matched by heading). New sections are appended after defaults.

**Override preamble:**

> These are the review process standards for [PROJECT NAME]. They fully replace the embedded defaults in the review molecule.

**Table of contents** (for override mode; overlay mode only lists included sections):

1. [Atom Loading Policy](#1-atom-loading-policy)
2. [Severity Classification](#2-severity-classification)
3. [Report Preferences](#3-report-preferences)
4. [Scope Rules](#4-scope-rules)
5. [Insight Capture Preferences](#5-insight-capture-preferences)
6. [Health Log Preferences](#6-health-log-preferences)
7. [Custom Review Dimensions](#7-custom-review-dimensions)

### Cross-Section Dependencies

Decisions in one section affect others. When a user changes a section, flag the dependent sections:

| Decision in | Affects | How |
|-------------|---------|-----|
| §1 Atom Loading | §2, §3, §5, §6 | Per-atom severity overrides reference atom names; report sections map to loaded atoms; insight categories follow atoms; log atom names must match |
| §2 Severity | §3, §5, §6, §7 | Report ordering follows severity levels; capture criteria reference severity; log counts use severity names; custom dimensions need severity assignment |
| §4 Scope Rules | §1, §7 | Expanded scope may trigger more conditional atoms; custom dimensions follow scope rules |
| §7 Custom Dimensions | §2, §3 | Custom dimensions contribute findings needing severity classification and report placement |

When a dependency is triggered, inform the user: "Since you changed [X], we should also review [Y] — it's affected by that decision."

---

## 1. Atom Loading Policy

<!-- INTERVIEW GUIDANCE:
Ask: "The review molecule loads certain atoms always and others conditionally based on the delta. Here's the current behavior. Would you like to change which atoms are always loaded, change the conditions for conditional atoms, suppress any atoms, or add custom trigger conditions?"

Show the tables below.

Probing questions:
- Are there atoms you always want loaded regardless of the delta? (e.g., "always run secure-coding on every review")
- Are there atoms you want to suppress entirely? (e.g., "we're not doing DDD, skip that atom")
- Do you have path-based rules? (e.g., "any file in src/api/ should trigger secure-coding")
- Should any currently-conditional atom become always-loaded?

Customizable:
- Move atoms between always/conditional/suppressed categories
- Add path-based trigger rules for conditional atoms
- Change the conditions that trigger conditional atoms

Fixed:
- clean-code must remain in the "always" category (fundamental code quality applies universally)
- knowledge-priming must remain in the "always" category (project context is always needed)
- Cannot add atoms that don't exist in the framework

Cross-section impact:
- Per-atom severity overrides in §2 must reference atoms that are actually loadable
- Report sections in §3 correspond to loaded atoms
- Insight categories in §5 may reference atom names
- Log entries in §6 list which atoms were loaded
-->

### Always Load

These atoms are loaded for every review regardless of what changed:

| Atom | Why always |
|------|-----------|
| `clean-code` | Code craft standards (SRP, naming, complexity, error handling) apply to all code |
| `knowledge-priming` | Project context (tech stack, architecture, conventions) informs all validation |

### Conditionally Load

These atoms load when the delta matches specific criteria:

| Atom | Trigger condition | Why conditional |
|------|-------------------|-----------------|
| `architecture` | Delta touches multiple layers, adds new files, or changes file locations | Structural checks are only relevant when structure changes |
| `domain-driven-design` | Delta includes files in the configured domain folder or modifies domain objects | Domain modeling rules only apply to domain code |
| `secure-coding` | Delta touches trust boundaries (HTTP handlers, auth, DB queries, external APIs, secrets, config) | Security checks target code that handles untrusted input or sensitive operations |
| `test-quality` | Delta includes test files | Test standards (AAA, isolation, naming) only apply to test code |

### Suppressed

No atoms are suppressed by default. Suppressed atoms are never loaded regardless of the delta.

### Custom Path-Based Triggers

No custom path triggers by default. Path triggers override the standard conditions above.

**Example customizations** (not active by default):

```yaml
# Example: Always trigger secure-coding for API files
- path: "src/api/**"
  loads: secure-coding

# Example: Always trigger DDD for any file under domain/
- path: "src/domain/**"
  loads: domain-driven-design

# Example: Trigger architecture for config and module files
- path: "src/modules/*/module.ts"
  loads: architecture
```

---

## 2. Severity Classification

<!-- INTERVIEW GUIDANCE:
Ask: "The review uses three severity levels for findings. Here are the current definitions. Would you like to change these levels, add new levels, or set per-atom severity overrides?"

Show the severity table and per-atom overrides section below.

Probing questions:
- Do you need a level above critical? (e.g., "blocker" for CI-gating or merge-blocking issues)
- Should any atom's findings start at a minimum severity? (e.g., "security findings are never below warning")
- Should any atom's findings be capped? (e.g., "DDD findings capped at warning while the team adopts the pattern")
- Do you want to redefine what each level means?

Customizable:
- Add new severity levels (e.g., "blocker", "nitpick")
- Redefine level descriptions and guidance
- Set per-atom minimum severity (floor)
- Set per-atom maximum severity (ceiling)

Fixed:
- Must have at least two severity levels (a "must fix" and an "optional" level)
- Levels must be orderable from most to least severe

Cross-section impact:
- Report ordering in §3 follows severity order
- Insight capture criteria in §5 may reference severity levels
- Health log counts in §6 group by severity
- Custom dimensions in §7 need a default severity from this list
-->

### Severity Levels

Findings are classified into these levels, ordered from most to least severe:

| Level | Meaning | Guidance |
|-------|---------|----------|
| **critical** | Will cause bugs, security vulnerabilities, or data loss | Must fix before merging |
| **warning** | Violates a principle and will cause maintenance pain | Should fix — technical debt if left |
| **suggestion** | Could be improved but works correctly as-is | Consider fixing — not blocking |

### Per-Atom Severity Overrides

No per-atom overrides by default. All atoms use the standard severity classification.

**Example customizations** (not active by default):

```yaml
# Example: Security findings are never below warning
- atom: secure-coding
  minimum_severity: warning

# Example: DDD findings capped at warning during adoption
- atom: domain-driven-design
  maximum_severity: warning

# Example: Architecture violations are always at least warning
- atom: architecture
  minimum_severity: warning
```

When a per-atom override is active, findings from that atom are clamped to the specified range. A security finding that would normally be a "suggestion" gets promoted to "warning" with a minimum override. A DDD finding that would normally be "critical" gets capped to "warning" with a maximum override.

---

## 3. Report Preferences

<!-- INTERVIEW GUIDANCE:
Ask: "The review report uses summary mode by default, with severity-ordered findings. Would you like to change the default mode, adjust the finding format, or customize what appears in the report?"

Show the defaults below.

Probing questions:
- Should the default mode be full instead of summary?
- Do you want a cap on findings in summary mode? (e.g., "show top 10 only")
- Do you want to keep or remove the "What's done well" section?
- Should findings be grouped differently? (by atom, by file, by severity)
- Are there custom sections you want in every report? (e.g., "Performance Notes", "Migration Safety")

Customizable:
- Default report mode (summary or full)
- Finding cap for summary mode
- "What's done well" toggle (on/off)
- Grouping strategy (by-severity, by-atom, by-file)
- Finding format template
- Custom report sections

Fixed:
- Both summary and full modes must remain available (user can always request either)
- Findings must include file location and description at minimum
-->

### Default Mode

**Summary mode** is the default. User can always request full mode explicitly.

### Finding Format

Each finding follows this format:

```
[SEVERITY] file:line -- description (atom-name: check-name)
```

### Summary Mode Behavior

- Findings ordered by severity (critical → warning → suggestion)
- Show the most important findings — do not enumerate every minor issue
- No hard cap on findings (include all that matter)
- End with a **"What's done well"** sentence highlighting something positive about the delta

### Full Mode Behavior

- Findings organized by atom (one section per loaded atom)
- All findings included, severity-ordered within each atom section
- End with **"What's done well"** (2-3 positive observations) and optional **"Improvement suggestions"** (1-2 broader patterns)

### Grouping Strategy

Default grouping: **by-severity** in summary mode, **by-atom** in full mode.

**Alternative grouping options** (not active by default):

- **by-file**: Group findings by file path, severity-ordered within each file. Useful for large deltas touching many files.
- **by-severity**: Group findings by severity level, all atoms mixed. Default for summary mode.
- **by-atom**: Group findings by atom, severity-ordered within each atom. Default for full mode.

### "What's Done Well"

Enabled by default. Every review includes at least one positive observation about the delta — good naming, proper error handling, clean test structure, correct layer placement.

### Custom Report Sections

No custom sections by default.

**Example customizations** (not active by default):

```yaml
# Example: Add a "Performance Notes" section at the end of every report
- name: "Performance Notes"
  description: "Observations about performance patterns in the delta"
  position: after-findings

# Example: Add a "Migration Safety" section for database changes
- name: "Migration Safety"
  trigger: "delta includes migration files"
  position: after-findings
```

---

## 4. Scope Rules

<!-- INTERVIEW GUIDANCE:
Ask: "The review focuses on the delta — only changed files and lines. It can look at surrounding code when a change creates new violations. Would you like to change how scope works?"

Show the defaults below.

Probing questions:
- Should the review expand to "immediate dependencies" — files that import from changed files?
- Are there directories to always exclude? (generated code, vendored dependencies, migrations)
- Are there directories to always include fully when any file in them changes? (e.g., "always review the full domain/ folder when any domain file changes")
- How should surrounding code be handled? (strict: delta only, default: delta + new violations in surrounding code, expansive: delta + all surrounding context)

Customizable:
- Expand scope to immediate dependencies
- Directory exclusions (glob patterns)
- Directory inclusions (always-full-scan directories)
- Surrounding-code policy (strict / default / expansive)

Fixed:
- The review must always include the delta itself (cannot exclude changed files)
- Scope expansion must be bounded — no unbounded graph traversal

Cross-section impact:
- Expanded scope may trigger more conditional atoms in §1
- Custom dimensions in §7 follow the same scope rules
-->

### Delta Focus

The review focuses on the delta — changed files and lines. This is the set of changes, not the entire codebase.

### Surrounding Code Policy

**Default**: Focus on the delta. Exception: review surrounding code when a change in the delta creates a new violation in existing code (e.g., a new dependency that breaks the dependency rule for an existing file). When reviewing surrounding code, note that the finding originates from the delta's impact, not from pre-existing issues.

**Available policies:**

| Policy | Behavior |
|--------|----------|
| **strict** | Delta only. Never look at surrounding code. |
| **default** | Delta + surrounding code only when the delta creates new violations in it. |
| **expansive** | Delta + broader context around changed code for holistic review. |

### Dependency Expansion

Disabled by default. When enabled, the review also examines files that directly import from changed files ("immediate dependencies"). This catches cases where a change breaks a consumer.

### Directory Exclusions

No exclusions by default. All files in the delta are reviewed.

**Example customizations** (not active by default):

```yaml
# Example: Exclude generated code
- pattern: "src/generated/**"
  reason: "Auto-generated, not human-authored"

# Example: Exclude vendored dependencies
- pattern: "vendor/**"
  reason: "Third-party code, not project-owned"

# Example: Exclude database migrations
- pattern: "migrations/**"
  reason: "Schema migrations reviewed separately"
```

### Directory Inclusions (Always-Full-Scan)

No always-full-scan directories by default.

**Example customizations** (not active by default):

```yaml
# Example: Always scan full domain/ when any domain file changes
- pattern: "src/domain/**"
  reason: "Domain integrity requires full-context review"

# Example: Always scan full auth module when any auth file changes
- pattern: "src/auth/**"
  reason: "Security-sensitive module needs holistic review"
```

---

## 5. Insight Capture Preferences

<!-- INTERVIEW GUIDANCE:
Ask: "After each review, the molecule captures recurring patterns to a learnings file that code-forge uses to avoid repeating mistakes. Here are the current defaults. Would you like to change how insights are captured?"

Show the defaults below.

Probing questions:
- Should the pruning threshold be higher? (e.g., 100 entries for larger teams with more review history)
- Do you want categorization tags? (e.g., [security], [domain], [performance])
- Should certain findings always be captured? (e.g., "always capture security findings regardless of recurrence")
- Do you prefer grouped format (by category) or flat format (chronological)?

Customizable:
- Pruning threshold (number of entries before suggesting cleanup)
- Categorization tags
- Capture criteria (what triggers an insight being saved)
- Format (grouped by category or flat chronological)
- Entry length limit

Fixed:
- Insights must be append-only (no overwriting existing entries)
- Insights must include a date for recency tracking
- File path is .ai/learnings/review-insights.md (configurable via config.yaml)

Cross-section impact:
- Capture criteria may reference severity levels from §2
- Categories may align with loaded atoms from §1
-->

### File Location

Append to `.ai/learnings/review-insights.md`. Create the file with a `# Review Insights` heading if it doesn't exist.

### Entry Format

```
- YYYY-MM-DD [Feature]: Pattern observed — actionable takeaway
```

Each insight is ONE bullet point, max 2 lines.

### Capture Criteria

Only capture patterns that would help future code generation — not every finding. A one-off typo is not an insight; "domain services keep doing repository work" is. Look for:

- Recurring patterns across reviews
- Systematic violations (not one-off mistakes)
- Patterns that code-forge can act on in future sessions

### Pruning Threshold

If the file exceeds **~50 entries**, suggest pruning oldest entries that haven't recurred in recent reviews.

### Categorization

No categorization tags by default. Entries are flat and chronological.

**Example customizations** (not active by default):

```yaml
# Example: Add category tags to each insight
categories:
  - "[security]"
  - "[domain]"
  - "[architecture]"
  - "[performance]"
  - "[testing]"

# Format with categories:
# - YYYY-MM-DD [security] [Feature]: Pattern — takeaway
```

### Grouped vs Flat Format

**Flat** (default): All insights in chronological order, newest at the bottom.

**Grouped** (alternative): Insights organized under category headings. Requires categorization to be enabled.

---

## 6. Health Log Preferences

<!-- INTERVIEW GUIDANCE:
Ask: "Each review appends a structured summary to the review log for project health tracking. Here are the current defaults. Would you like to change the log format?"

Show the defaults below.

Probing questions:
- Do you want custom fields in each log entry? (e.g., "reviewer confidence", "estimated fix time")
- Should the entry cap be different? (e.g., more history for larger projects)
- Do you want additional metrics? (findings-per-file ratio, most-firing atoms, severity distribution)
- How should old entries be compressed? (one-line summary, statistics only, removed entirely)

Customizable:
- Entry format and fields
- Entry length cap (lines per entry)
- History cap (entries before rolloff)
- Additional metrics
- History compression format

Fixed:
- Log must include date, scope, and result counts at minimum
- File path is .ai/reviews/review-log.md (configurable via config.yaml)
- Log is append-only (no overwriting)

Cross-section impact:
- Result counts use severity level names from §2
- Atom names in log entries correspond to loaded atoms from §1
-->

### File Location

Append to `.ai/reviews/review-log.md`. Create the file with a `# Review Log` heading if it doesn't exist.

### Entry Format

Each entry is a structured summary, max **8 lines**:

```
## YYYY-MM-DD — [feature/scope name]
- **Scope**: [file count], [layers touched]
- **Atoms**: [atoms loaded for this review]
- **Result**: [critical count] critical, [warning count] warning, [suggestion count] suggestion
- **Key findings**: [top 2-3 specific findings, one line each]
- **Strengths**: [one positive highlight]
```

### History Cap

If the log exceeds **~20 entries**, move the oldest entries to a one-line `## History` summary section at the top of the file.

### Custom Fields

No custom fields by default.

**Example customizations** (not active by default):

```yaml
# Example: Add reviewer confidence field
custom_fields:
  - name: "Confidence"
    description: "Reviewer's confidence in the thoroughness of the review (high/medium/low)"

# Example: Add fix time estimate
custom_fields:
  - name: "Estimated fix time"
    description: "Rough estimate to address all findings"
```

### Additional Metrics

No additional metrics by default.

**Example customizations** (not active by default):

```yaml
# Example: Track findings-per-file ratio
additional_metrics:
  - name: "findings_per_file"
    description: "Number of findings divided by number of files reviewed"

# Example: Track most-firing atoms
additional_metrics:
  - name: "top_atoms"
    description: "Which atoms produced the most findings"
```

### History Compression

When old entries roll off, they are compressed to a one-line summary:

```
- YYYY-MM-DD — [scope]: [total findings] findings ([critical] critical)
```

---

## 7. Custom Review Dimensions

<!-- INTERVIEW GUIDANCE:
Ask: "Beyond the standard atom checks, are there review concerns specific to your project that you'd like every review to check? These are checks that don't fit into existing atoms."

This section has NO defaults — it is entirely additive. Only include it in the output if the user defines at least one dimension.

Show the examples below to spark ideas.

Probing questions:
- Are there performance patterns to watch for? (N+1 queries, DB calls in loops, unbounded result sets)
- Are there API consistency rules? (naming conventions, response envelope format, versioning)
- Should public APIs without doc comments be flagged?
- Are there migration safety concerns? (schema changes without rollback, data migrations without validation)
- Are there backward compatibility rules? (breaking changes to public APIs, removed fields)

Customizable: Everything — this is a blank canvas.

Fixed:
- Each dimension must have a name, what to check, trigger condition, and default severity
- Dimensions follow the same two-pass review pattern as atoms (check criteria → record findings)
- Dimensions use severity levels from §2

Cross-section impact:
- Dimensions contribute findings that need severity classification from §2
- Dimension findings appear in the report following §3 preferences
- Dimensions follow scope rules from §4
-->

No custom dimensions by default. This section is entirely additive — define dimensions for review concerns specific to your project that existing atoms don't cover.

### Example Dimensions

These are examples to illustrate the format. None are active by default.

#### Performance Patterns

```yaml
name: "Performance Patterns"
check: |
  - N+1 queries: DB call inside a loop or repeated fetches for related data
  - Unbounded result sets: queries without LIMIT or pagination
  - DB calls in hot paths: database access in frequently-called utility functions
  - Missing indexes: queries filtering on non-indexed columns (when schema is available)
trigger: "Delta includes database queries, repository calls, or data access code"
default_severity: warning
```

#### API Consistency

```yaml
name: "API Consistency"
check: |
  - Endpoint naming follows convention (e.g., plural nouns, kebab-case)
  - Response envelope format is consistent (e.g., { data, error, meta })
  - Error responses include error codes
  - Pagination follows the project's standard pattern
trigger: "Delta includes controller/handler or API route definitions"
default_severity: suggestion
```

#### Documentation Coverage

```yaml
name: "Documentation Coverage"
check: |
  - Public API functions/methods have doc comments
  - Exported types/interfaces have descriptions
  - Complex business logic has inline explanation
trigger: "Delta includes public API definitions or exported interfaces"
default_severity: suggestion
```

#### Migration Safety

```yaml
name: "Migration Safety"
check: |
  - Schema changes have a rollback migration
  - Data migrations validate before transforming
  - Column drops are preceded by a deprecation period
  - New NOT NULL columns have a default value
trigger: "Delta includes migration files or schema changes"
default_severity: critical
```

#### Backward Compatibility

```yaml
name: "Backward Compatibility"
check: |
  - Removed or renamed public API endpoints are versioned
  - Changed response shapes have deprecation notices
  - Removed fields use soft deprecation before hard removal
  - Breaking changes are documented in changelog
trigger: "Delta modifies public API endpoints or response types"
default_severity: warning
```

### Dimension Format

Each custom dimension must include:

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Human-readable name for the dimension |
| `check` | Yes | What to look for — a checklist of patterns or rules |
| `trigger` | Yes | When this dimension applies — based on delta classification |
| `default_severity` | Yes | Default severity for findings from this dimension (must be a level from §2) |

Dimensions follow the same two-pass pattern as atoms: check criteria against the delta, then record findings with severity, file location, and suggested fix. Dimension findings merge into the report alongside atom findings.

---

## New Sections

<!-- INTERVIEW GUIDANCE:
At the end of the interview, ask:
"Are there any additional review process preferences you'd like to add that aren't covered by the seven sections above?"

If the user wants to add sections, number them starting from 8.
New sections work in both overlay and override mode.
-->

---

## Footer

<!-- INTERVIEW GUIDANCE:
Include project name, generation date, and mode indicator in the output.
Example:

---
*Generated for [PROJECT NAME] on [DATE]. Mode: [overlay|override].*
*Produced by the review-refiner skill.*
-->
