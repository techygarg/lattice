# Skills Tuning Findings — ConfIT Session Analysis

Source: Observed from `/Users/grahul/Documents/Personal/Code/ConfIT/.lattice` — real production usage of the Lattice pipeline across 9 implemented features (FLOW-001/002, ASSERT-001/002, DSL-002, ENV-001/003/004/005).

---

## Issue Summary Table

| Priority | Type | Name | Issues Found | Proposed Fix |
|---|---|---|---|---|
| **P1** | Molecule | `design-blueprint` | (1) No step to detect when a design decision overrides a contract from the linked requirement spec — drift is silent (proven: `header:` → `headerKey:` in ENV-001 was never backpropagated). (2) "Design status: Approved" written as prose in doc body — code-forge must parse free text to know if design is complete; no machine-readable signal. (3) No dedup guard on Key Files table — ENV-004 context doc has 6 files listed twice. | (1) Add a step in Step 3 (Finalize): "Compare final contracts against the linked requirement spec. For any field/type/behavior that changed, add a `Design override:` line to the requirement spec's Links section." (2) Add `status: blueprint` to context doc frontmatter at creation; update to `complete` at end of Step 3. (3) Before writing Key Files, dedup by path. |
| **P1** | Atom | `context-anchoring` | (1) Template (`feature-doc-template.md`) shows a 4-section skeleton — but design-blueprint writes 8+ sections (L1–L4, Design Summary, etc.) into it. Users loading context docs are surprised; the template misrepresents what the doc actually becomes. (2) No `status` field in frontmatter — docs are frozen at "Approved — ready for implementation" permanently after implementation, with no completion signal. (3) Empty section placeholders (`<!-- When resolved... -->`) remain as comment noise in all completed feature docs. | (1) Add an extended template variant (`feature-doc-extended-template.md`) showing the full post-design-blueprint structure; or add a note to the base template: "design-blueprint extends this with Level 1–4 sections." (2) Add `status: blueprint | implementing | complete | diverged` to frontmatter spec. (3) Default placeholder text to `None.` — comments are invisible to readers and add no value once a section is empty at design-close. |
| **P1** | Atom | `learning-harvest` | (1) Default path in skill is `.lattice/learnings/operational-learnings.md` — actual ConfIT file is `.lattice/learnings.md` (different path, different format). Backward compat only covers `review-insights.md`. Net result: skill reports "No operational learnings yet" and the existing 3 entries are invisible to it. (2) Existing learnings file is narrative paragraphs — skill expects `- YYYY-MM-DD [context] Pattern` bullet format. File appears hand-written, not harvested by the skill. (3) "Design Patterns" section perpetually empty — harvest at session-end biases toward implementation observations; design-level learnings aren't actively prompted. | (1) Add `.lattice/learnings.md` to backward compat detection alongside `review-insights.md`. Offer migration. (2) When a non-conforming file is detected, offer to reformat existing entries into the canonical structure (with user confirmation). (3) In the harvest step for design-blueprint sessions, explicitly prompt: "Were there any design decomposition or scope decisions that didn't go the way you expected?" to surface Design Patterns entries. |
| **P2** | Molecule | `requirement-forge` | (1) `## Implementation Notes` section in the output template writes early implementation thinking (types, class names, method shapes) into the requirement spec — proven stale after design-blueprint runs (ENV-001 mentions `AuthType` enum, separate config classes, `header:` field — none survived design). (2) Links section is passive: `Design: *(updated when design-blueprint creates a context anchor doc)*` — no mechanism to populate it or flag drift. (3) No frontmatter field to track `status: approved → implementing → complete` in feature specs — index.md is updated manually but spec files never change status. | (1) Rename to `## Technical Constraints` and restrict to: known dependencies, non-negotiable platform facts, pre-existing interfaces that must be respected. Remove free-form implementation ideas — that's design-blueprint's job. (2) Add explicit instruction: "After design-blueprint runs, it updates this Links section — but if a design decision changes a contract from this spec, also note it here as `Design override: [field] changed from X to Y — see [context doc link]`." (3) Add `status` to frontmatter; have design-blueprint update it to `designing`, code-forge update it to `implementing`, and a close step update it to `complete`. |
| **P3** | Refiner | `knowledge-priming-refiner` | Produced a redirect stub: "context is in CLAUDE.md" with no actual project knowledge. `knowledge-priming` atom loads this file and gets nothing. The refiner has no detection for "I just wrote a hollow output" — the skill considers itself done when a file exists, not when it contains actionable content. | Add a self-validation step after writing: count substantive sections. If the output file has fewer than 3 populated sections OR is primarily a redirect to another file, flag: "The knowledge base I created is mostly a pointer — it won't prime future sessions effectively. Should we inline the key content from [referenced file]?" |

---

## Structural Issues — Pipeline Boundary Analysis

Three boundary problems that cut across the table above.

### A. requirement-forge → design-blueprint: boundary bleed

The `Implementation Notes` section turns requirement-forge into a light design tool. The intended boundary is: requirement spec = WHAT/WHY/WHO only. But "Implementation Notes" writes HOW — class names, method shapes, DTO hierarchies. When design-blueprint then runs and produces different contracts, neither skill reconciles them. The section isn't just noisy — it actively misleads.

**Clean boundary**: requirement spec ends at Scenarios + ACs. All implementation thinking starts in design-blueprint Step 1. Removing (or renaming + restricting) `## Implementation Notes` to `## Technical Constraints` enforces this hard.

### B. design-blueprint → code-forge: no formal handoff signal

design-blueprint ends with prose: `"Design status: Approved — ready for implementation"`. code-forge loads the context doc and presumably reads this. But there's no machine-readable gate. If design-blueprint was interrupted mid-session, the doc might look complete but be missing Level 3 or 4. code-forge has no way to verify.

**Fix**: A `status: blueprint` frontmatter field that design-blueprint sets on creation and updates to `complete` at Step 3 close. code-forge checks this field before proceeding.

### C. Post-implementation: the pipeline has no closing step

The full pipeline is: `requirement-forge` → `design-blueprint` → `code-forge`. But there's no completion step. After code-forge finishes, context docs stay frozen at "Approved — ready for implementation," requirement specs stay at `status: approved`, and the `.lattice` folder drifts from reality.

ConfIT has 9 implemented features. Zero have a completion marker anywhere in `.lattice`.

**Fix**: Not a new skill — lifecycle transitions. code-forge already ends by suggesting learning-harvest; extend that close step to also write `status: complete` in both the context doc frontmatter and the requirement spec frontmatter. One-line writes, high signal value across the whole folder.

---

## Evidence File References

| Issue | File in ConfIT .lattice |
|---|---|
| contract drift (header → headerKey) | `requirements/features/env-001-declarative-auth-profiles.md` vs `context/env-001-declarative-auth-profiles.md` |
| Implementation Notes stale after design | `requirements/features/env-001-declarative-auth-profiles.md` §Implementation Notes |
| Key Files duplicates | `context/env-004-declarative-suite-configuration.md` §Key Files |
| All docs frozen at "Approved" | `context/env-001`, `env-003`, `env-004`, `env-005`, `flow-001`, `flow-002`, `assert-001`, `assert-002`, `dsl-002` |
| Learning path mismatch | `.lattice/learnings.md` (actual) vs skill default `.lattice/learnings/operational-learnings.md` |
| Knowledge base redirect stub | `.lattice/standards/knowledge-base.md` |
