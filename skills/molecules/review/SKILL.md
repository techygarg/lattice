---
name: review
description: "Perform a structured code review by composing validation checklists from relevant atoms based on what code changed. Loads atoms conditionally -- clean-code always, architecture/DDD/security/tests only when the delta touches their domain. Produces a severity-ordered report with specific locations and fixes. Use when the user asks to 'review this', 'code review', 'quality check', 'validate the code', 'check my code', 'review the delta', or 'review this PR'."
---

# Review

## Required Skills

Load and apply these skills based on the scope of the review (see Step 2 for conditional loading):

1. `framework:knowledge-priming` -- Load project context (tech stack, architecture, conventions) to evaluate changes against real project standards (always loaded)
2. `framework:clean-code` -- Code craft validation: SRP, naming, complexity, error handling (always loaded)
3. `framework:clean-architecture` -- Structural validation: layer rules, dependency direction, command/query flows (conditional)
4. `framework:domain-driven-design` -- Domain modeling validation: aggregates, entities, value objects (conditional)
5. `framework:secure-coding` -- Security validation: trust boundaries, injection, secrets, input handling (conditional)
6. `framework:test-quality` -- Test validation: AAA structure, isolation, assertions, naming (conditional)

## Workflow

### Step 1: Identify the Delta

Determine what code is being reviewed and establish the scope.

- **PR or commit**: Use `git diff` to identify changed files and lines. The delta is the set of changes, not the entire codebase.
- **Set of files**: The user specifies which files to review. The delta is those files.
- **Feature or module**: The user points to a feature. Identify the relevant files from the codebase.

Classify the delta by answering these questions:

1. **Which architectural layers are touched?** (controllers, services, domain, infrastructure) -- determines if `clean-architecture` loads.
2. **Is domain code included?** (files in the configured `domain_folder` or containing aggregates, entities, value objects) -- determines if `domain-driven-design` loads.
3. **Are security-sensitive areas touched?** (authentication, authorization, input handling, database queries, external API calls, file I/O, configuration, secrets) -- determines if `secure-coding` loads.
4. **Are test files included?** -- determines if `test-quality` loads.

<!-- AI reasoning: Classification happens before loading atoms to avoid wasting context on irrelevant checklists. A change to a single value object does not need the full security checklist. A CSS-only change does not need architecture validation. Targeted loading keeps the review focused. -->

### Step 2: Load Relevant Atoms

**Always load**: `framework:clean-code` -- applies to all code regardless of layer or purpose.

**Conditionally load** based on the delta classification:

| Condition | Load | Why |
|-----------|------|-----|
| Delta touches multiple layers, adds new files, or changes file locations | `framework:clean-architecture` | Structural changes can break dependency direction or layer responsibilities |
| Delta includes files in the domain folder or modifies domain objects | `framework:domain-driven-design` | Domain changes can break aggregate boundaries, anemic models, or invariant enforcement |
| Delta touches trust boundaries (HTTP handlers, auth, DB queries, external APIs, secrets, config) | `framework:secure-coding` | Security-sensitive code needs injection, validation, and secrets checks |
| Delta includes test files | `framework:test-quality` | Test code has its own quality standards (AAA, isolation, naming) |

When multiple atoms load, they run independently -- each atom's checklist is applied to the parts of the delta relevant to it. Findings from different atoms are merged in Step 4.

### Step 3: Run Targeted Validation

For each loaded atom, apply two passes against the delta:

**Pass 1 -- Validation Checklist**: Walk through the atom's Validation Checklist (the table in each atom's SKILL.md). For each check, examine whether any code in the delta violates it. Record violations with:
- The specific check that failed
- The exact file and line(s)
- Why it matters (from the checklist's "Why It Matters" column)
- A concrete suggested fix

**Pass 2 -- Anti-Pattern Scan**: Walk through the atom's Active Anti-Pattern Scan checklist. For each anti-pattern, check if the delta exhibits the symptom. Record matches with:
- The anti-pattern name
- The symptom observed in the delta
- The fix from the anti-pattern table, adapted to the specific code

**Scope rule**: Focus on the delta. Do not review unchanged code unless a change in the delta creates a new violation in surrounding code (e.g., a new dependency that breaks the dependency rule for an existing file). When reviewing surrounding code, note that the finding originates from the delta's impact, not from pre-existing issues.

<!-- AI reasoning: Two passes ensure nothing is missed. The checklist catches structural violations (hard rules). The anti-pattern scan catches smell-level issues (patterns that indicate deeper problems). Running both produces a thorough review without requiring the AI to invent checks from scratch. -->

### Step 4: Produce Report

Ask the user which mode they prefer, or default to **summary mode** if not specified.

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

## Clean Architecture
- [critical] src/domain/Order.ts:12 -- Domain entity imports from infrastructure
  (`import { DatabaseClient }`). Domain must have zero outward dependencies.
  Define a repository interface in domain, implement in infrastructure.
```

After all atom sections, add:

- **What's done well**: List 2-3 positive observations.
- **Improvement suggestions** (optional): If there are broader patterns beyond individual findings -- e.g., "consider extracting a shared validation layer" -- note them here. Keep to 1-2 suggestions maximum.

<!-- AI reasoning: Summary mode respects the user's time -- most reviews need a quick hit list, not an essay. Full mode is for thorough reviews before merging or when the user wants to learn from the findings. The severity classification prevents "wall of warnings" fatigue by surfacing what actually matters first. -->

### Step 5: Capture Insights and Log Review

After presenting the report to the user, capture learnings and log the review for project health visibility.

**Capture Insights** — append to `.ai/learnings/review-insights.md`:

If recurring patterns or notable findings emerged from this review:

1. Create `.ai/learnings/` directory if it doesn't exist.
2. Append concise bullet points to `.ai/learnings/review-insights.md`. Create the file with a `# Review Insights` heading if it doesn't exist.
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

<!-- AI reasoning: Insights feed the learning flywheel -- code-forge loads them at session start and uses them to avoid repeating mistakes. The review log provides project health visibility -- trends in finding counts, recurring atoms, and quality direction over time. Both use rolling limits to prevent unbounded growth. The separation (insights for AI consumption, log for human consumption) keeps each artifact focused. -->
