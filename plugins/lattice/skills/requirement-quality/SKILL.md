---
name: requirement-quality
description: "Apply requirement quality principles when generating or validating feature specifications. Enforces feature completeness, scenario structure, AC verifiability, feature independence, and implementation slice quality. Use when writing feature specs, validating existing requirements, or when the user mentions 'validate this spec', 'check this feature', 'requirement quality', 'is this spec complete', or 'requirement-quality'. This skill governs the craft of writing individual feature specifications — not technical design (see design-blueprint), not implementation (see code-forge)."
---

# Requirement Quality

## Config Resolution

Skill supports project-specific standards. Order:

1. Look for `.lattice/config.yaml` in repo root
2. If found, check `paths.requirement_standards` for custom doc path
3. If custom path exists, read doc and check YAML frontmatter for `mode`:
   - **`mode: override`** (or no mode): Custom doc full precedence. Use instead of embedded defaults. Must be comprehensive — sole reference.
   - **`mode: overlay`**: Read embedded `./references/defaults.md` first, then apply custom doc sections on top. Custom sections replace matching sections in defaults (matched by heading). New sections appended after.
4. If no config/path/file, read `./references/defaults.md`

Custom standards produced by `requirement-forge-refiner` → consumed by this atom → composed by `requirement-forge` molecule.

## Self-Validation Checklist

**STOP:** Before writing any feature file, verify ALL checks. If a check clearly fails → fix before writing. If judgment call (see Ambiguity Signals) → flag and surface options.

**If validating an existing spec** (not generating), same checks apply — "fix before writing" means "fix before marking approved." Present findings as a quality report with severity.

**Draft vs approved enforcement**: For `status: draft` — items 1, 2, 10 are required. Items 3–9, 11, 12 are advisories: flag findings but do not block write. For `status: approved` — all items required, no exceptions.

1. **PROBLEM STATEMENT**: Names a specific user need or pain — not a solution in disguise, not a vague improvement? Identifies WHO has the problem (specific user type or role, not "users")?
2. **SCOPE**: Has explicit out-of-scope items — not just in-scope?
3. **BOUNDARY CONDITIONS**: Feature-wide edge cases, system limits, and constraints documented?
4. **ASSUMPTIONS**: Statements the team proceeds with as true are explicit — not buried in ACs or unstated? If an assumption proves wrong, affected scenarios are identifiable?
5. **SCENARIO NAMES**: Each scenario has a verb-phrase name (sentence case) that describes the situation — not a feature name, not an AC?
6. **AC FORMAT**: Each AC follows the agreed format (default: Given/When/Then)? Each has a clear pass/fail condition — a tester can write an automated check without asking a clarifying question?
7. **FAILURE COVERAGE**: At least one scenario covers a failure, error, or edge case?
8. **SCENARIO COUNT**: Feature has no more than the agreed max (default: 5) scenarios? If at or over → challenge whether this is one feature or two.
9. **AC COUNT**: Each scenario has no more than the agreed max (default: 6) ACs? If at or over → challenge whether this scenario is too broad.
10. **INDEPENDENCE**: Feature is self-contained — no unresolved external unknowns required before design-blueprint can begin? Any unresolved Open Questions affecting scope, behavior, or ACs are blockers unless each is marked non-blocking with a stated reason.
11. **IMPLEMENTATION NOTES**: Slices ordered chronologically, at the "what" level — no technical implementation specifics?
12. **COHERENCE**: All scenarios address the same user need in the Problem Statement? If a scenario serves a different need, it belongs in a separate feature.

Project-specific checks: if loaded doc contains a validation checklist section, apply those after base checklist.

When all checks pass: output "Spec passes requirement-quality — ready for write." (pre-write mode) or "Spec passes requirement-quality — status: approved." (validation mode).

## Active Anti-Pattern Scan

**STOP:** After checklist, scan for these. If found → fix or challenge before writing.

- [ ] **Solution as problem**: Problem statement says "we need X" instead of "users cannot do Y" → ask what user need X addresses; rewrite around the need
- [ ] **Vague problem**: "improve the experience", "make it faster", "better UX" → no verifiable outcome; push for specific, observable user impact
- [ ] **Persona-less problem**: Problem statement says "users" without identifying which user type or role → push for specificity; different personas produce different ACs
- [ ] **Hidden assumption**: AC or scenario relies on an unstated assumption ("assumes user is logged in" but no Assumptions section records this) → make the assumption explicit or add a scenario covering the case where it doesn't hold
- [ ] **Boundaryless scope**: scope section lists only what is in scope, nothing explicitly out → force at least 3 explicit exclusions; undefined scope = infinite scope
- [ ] **Happy-path-only spec**: every scenario is a success path, no failure or error scenario → add at least one failure scenario before feature is complete
- [ ] **AC sprawl**: single scenario accumulates 7+ ACs → scenario too broad; propose split into two named scenarios
- [ ] **Scenario sprawl**: feature has 6+ scenarios → feature may be two; pause and challenge scope before adding more
- [ ] **Vague AC**: "the system should handle errors gracefully", "response should be fast", "it should work correctly" → no pass/fail condition; rewrite as concrete Given/When/Then
- [ ] **Implementation AC**: AC specifies a technical approach ("system shall use Redis", "shall call the /api/v2 endpoint") → rewrite as observable outcome
- [ ] **Orphaned feature**: `depends_on` is empty but feature references another feature's data or behavior in its scenarios → flag missing dependency
- [ ] **Cross-epic feature undocumented**: feature scenarios reference behaviors from a different epic but no cross-epic dependency is recorded → place feature in its primary epic, add the other epic as a cross-reference, record the dependency in `depends_on` frontmatter
- [ ] **Technical task as feature**: feature name or problem statement describes infrastructure, tooling, or engineering work ("Set up database schema", "Configure CI/CD", "Write unit tests") → redirect to implementation layer, challenge what user need it serves
- [ ] **Wrong granularity — too fine**: feature is actually a single acceptance criterion or a micro-behavior ("Show error on wrong password") → merge into a larger feature representing the complete user-facing behavior
- [ ] **Wrong granularity — too coarse**: feature encompasses an entire product area with 10+ implicit behaviors ("User management") → decompose into discrete independently-implementable features
- [ ] **Generic slices**: Implementation notes use placeholder labels that apply to any feature ("Core functionality", "Error handling", "Edge cases") → each slice must name the specific behavior being built for THIS feature
- [ ] **Undefined domain terms**: Scenarios use specialized/domain terms not defined anywhere in the spec → add inline definitions or a Glossary section

## Ambiguity Signals

Flag these — present options and reasoning. If `framework:collaborative-judgment` is loaded, use it to structure the presentation.

- **Feature boundary**: two related behaviors — one feature or two? If Behavior A requires knowing Behavior B's design to spec its own ACs, they are one feature.
- **Scenario granularity**: one scenario with more ACs, or two separate scenarios? If both situations share the same precondition and trigger, group. If they differ in either → separate scenarios.
- **Priority**: feature serves multiple user types or epics with different urgency → surface for product decision; do not silently assign.
- **Independence borderline**: feature depends on another feature but the dependency is well-understood and stable → judgment call whether to mark dependent or proceed as independent.
- **Assumption vs. requirement**: a statement reads as both an assumption and a requirement → surface for product decision.

See `./references/defaults.md` for epic/feature/scenario definitions, AC format examples, priority notation, status workflow, naming conventions, and implementation slice guidance.
