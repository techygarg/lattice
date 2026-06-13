---
mode: overlay
project: "[Project Name]"
date: "[Date]"
---

<!-- INTERVIEW GUIDANCE:
OVERLAY PREAMBLE — include this text verbatim in overlay-mode output, substituting project name and date.
OVERRIDE PREAMBLE — replace with the override preamble below.
-->

This document customises the built-in requirement standards for **[Project Name]**. Sections present here override the corresponding defaults in the `requirement-quality` atom. Sections not present here use the atom's embedded defaults unchanged.

<!-- OVERRIDE PREAMBLE (use this instead of overlay preamble for mode: override):
This document defines the requirement standards for **[Project Name]**. The `requirement-quality` atom uses this document as its sole source of structural decisions — no built-in defaults apply.
-->

---

## §1 Epic Definition

<!-- INTERVIEW GUIDANCE:
Default: An epic is a named group of related features forming a coherent product area or capability. One epic represents a meaningful shippable increment of product value — not an individual feature, not the entire product. Naming: Title Case noun phrase (e.g., "User Authentication", "Payment Processing").

Ask: "Does this definition of an epic match how your team thinks about epics? Is there a size or scope constraint you'd like to set?"

Probing questions:
- "How many features would you expect a typical epic to contain — 3–5? 10+?"
- "Is 'epic' a term your team already uses, or do you use a different term?"
- "Should epics map to team ownership, product areas, or delivery milestones?"

What is customisable: naming convention, scope description, size expectation.
What is fixed: epics are navigational — they group features, they are not implemented directly.
-->

An epic is a named group of related features forming a coherent product area or capability. One epic represents a meaningful increment of product value — not an individual feature, not the entire product.

**Naming:** Title Case noun phrase (e.g., "User Authentication", "Payment Processing").

---

## §2 Feature Definition

<!-- INTERVIEW GUIDANCE:
Default: A feature is a complete, self-contained unit of product behavior. It is independently designable and implementable — it can be handed to design-blueprint without resolving unknowns external to its scope. A feature that cannot be fully specced without knowing the answer to something outside its boundary is not yet independent enough.

Size signal: more than 5 scenarios suggests the feature should be split. A feature with 1 scenario may be too small and should be merged with a related feature.

Ask: "Does this definition of a feature match what you mean by 'feature'? Is the size signal right for your context?"

Probing questions:
- "How large do your features typically get before they feel too big?"
- "Should features map to individual design-blueprint sessions, or is a larger scope OK?"
- "Are there cases in your domain where a feature legitimately has many scenarios?"

What is customisable: size signal (max scenarios), description of independence.
What is fixed: features must be independently designable and implementable.
-->

A feature is a complete, self-contained unit of product behavior. It is independently designable and implementable — it can be handed to design-blueprint and then code-forge without resolving unknowns that sit outside its scope.

**Size signal:** more than 5 scenarios suggests the feature should be split. Fewer than 2 scenarios suggests it should be merged with a related feature.

---

## §3 Feature Independence Rule

<!-- INTERVIEW GUIDANCE:
Default: A feature is considered independent if: (a) all requirements and acceptance criteria are fully specified within the feature file, (b) no external decisions or designs are required before design-blueprint can begin, (c) it delivers coherent user value on its own — a user can complete a meaningful action using this feature alone.

Ask: "Does this independence rule match what you'd expect? Are there exceptions in your domain — features that deliberately depend on another in progress?"

Probing questions:
- "Are there cases where two features must be designed together?"
- "Is 'coherent user value on its own' the right test, or is partial value acceptable?"

What is customisable: the specific criteria (a, b, c) can be adjusted.
What is fixed: independence is required for the pipeline (forge → design → code) to work without constant re-briefing.
-->

A feature is considered independently specced when:
- All requirements and acceptance criteria are fully stated within the feature file.
- No external decisions are needed before design-blueprint can begin.
- It delivers coherent user value on its own — a user can complete a meaningful action using this feature alone.

---

## §4 Scenario Definition

<!-- INTERVIEW GUIDANCE:
Default: A scenario is a bounded situation the feature must handle. Scenarios have names, are ordered chronologically (natural implementation sequence), and contain 3–6 acceptance criteria. The default nomenclature is "scenario".

Max per feature: ~5. If a feature accumulates more, challenge whether it should be split.
Min per feature: 2 — at least one happy path and one failure or edge case. A single-scenario feature may be too small to stand alone.
Max AC per scenario: ~6. If a scenario accumulates more, challenge whether the scenario is too broad.

Ask: "Does 'scenario' feel like the right word for your team? Some teams use 'use case', 'story', 'case', or 'flow'. And is the 3–6 AC range per scenario right for your context?"

Probing questions:
- "Does your team have an existing name for this concept?"
- "Is 6 ACs per scenario too tight or about right for your typical feature complexity?"

What is customisable: nomenclature, max scenario count, max AC count.
What is fixed: scenarios are ordered chronologically (natural implementation sequence) — this is non-negotiable because it makes feature files directly usable as input to design-blueprint and code-forge. Do not offer alternative orderings.
-->

A scenario is a bounded situation the feature must handle. Scenarios are:
- Named with a verb phrase describing the situation (e.g., "User submits valid form").
- Ordered chronologically — the natural implementation sequence.
- Bounded: 3–6 acceptance criteria per scenario. If more are needed, the scenario is too broad.

**Nomenclature:** scenario
**Ordering:** chronological — the natural implementation sequence. Not negotiable.
**Max per feature:** 5. More than 5 signals the feature should be split.
**Min per feature:** 2. At least one happy path and one failure or edge case.
**Max ACs per scenario:** 6. More than 6 signals the scenario is too broad.

---

## §5 Acceptance Criteria Format

<!-- INTERVIEW GUIDANCE:
Default: Given/When/Then. Each criterion: "Given [context], when [action], then [outcome]."

Ask: "Does your team write ACs in Given/When/Then format, or do you prefer a different style?"

Options to present if the user is unsure:
1. Given/When/Then — structured, maps to test cases, most common for feature specs
2. Bullet statements — "The system must [do X] when [condition Y]." Faster to write, less structured.
3. Numbered — same as bullets but numbered for traceability.
4. Hybrid — Given/When/Then for behaviour ACs, bullets for non-functional or constraint ACs.

Probing questions:
- "Do your ACs need to map directly to test cases?"
- "Do you need traceability IDs on ACs for compliance?"

What is customisable: the entire format.
What is fixed: ACs must be verifiable — each one has a clear pass/fail condition.
-->

**Format:** Given/When/Then

Each acceptance criterion:
```
Given [context or precondition],
when [action or event],
then [expected outcome].
```

ACs must be verifiable — each one has a clear pass/fail condition. Vague ACs ("the system should handle errors gracefully") are not acceptable.

---

## §6 Priority Notation

<!-- INTERVIEW GUIDANCE:
Default: P0 / P1 / P2. P0 = critical / must-have. P1 = important / should-have. P2 = nice-to-have.

Ask: "How does your team express feature priority? P0/P1/P2, MoSCoW, High/Medium/Low, or something else?"

Options to present:
1. P0/P1/P2 — compact, engineering-friendly
2. MoSCoW — Must/Should/Could/Won't — product-friendly, common in BA practice
3. High/Medium/Low — simple, widely understood
4. Numbered (1, 2, 3) — simple ordinal
5. Custom — team defines their own values

Probing questions:
- "Should priority live at the feature level only, or also at the scenario level within a feature?"
- "Who sets priority — product, engineering, or jointly?"

What is customisable: the notation and the labels.
What is fixed: priority must appear in the feature file's frontmatter so the molecule can use it.
-->

**Notation:** P0 / P1 / P2

| Value | Meaning |
|---|---|
| P0 | Critical — must be delivered for the epic to ship |
| P1 | Important — should be delivered; acceptable to defer only under constraints |
| P2 | Nice-to-have — deliver if capacity allows |

Priority lives at the feature level (frontmatter field).

---

## §7 Status Workflow

<!-- INTERVIEW GUIDANCE:
Default: draft → approved → in-design → implemented

Ask: "Does this status workflow match how features move through your team's process? Do you need additional statuses?"

Probing questions:
- "Is there a 'ready for design' status separate from 'approved'?"
- "Do you track when a feature is 'in development' vs 'designed'?"
- "Do you ever mark features as deprecated or cancelled?"

Common additions:
- ready-for-design (after approval, before design starts)
- in-development (after design approved, code in progress)
- deprecated / cancelled

What is customisable: the entire workflow and status labels.
What is fixed: a status field must exist in the feature file's frontmatter.
-->

Feature status progresses in this order:

`draft` → `approved` → `in-design` → `implemented`

| Status | Meaning |
|---|---|
| draft | Being specced — not yet agreed |
| approved | Spec agreed; ready for design-blueprint |
| in-design | design-blueprint session in progress or complete |
| implemented | code-forge complete; feature shipped |

---

## §8 Naming Conventions

<!-- INTERVIEW GUIDANCE:
Default:
- Epic names: Title Case noun phrase
- Feature file names: kebab-case (e.g., user-login.md)
- Feature display names: Title Case
- Scenario names: verb phrase in sentence case (e.g., "User submits valid form")

Ask: "Are there naming conventions your team already follows that should carry over here?"

Probing questions:
- "Should feature file names include the epic name as a prefix?"
- "Do you have a convention for naming things that span multiple epics?"
- "Should scenario names include an ID for traceability (e.g., SC-001)?"

What is customisable: all naming conventions.
What is fixed: file names must be filesystem-safe (no spaces, lowercase preferred).
-->

| Artifact | Convention | Example |
|---|---|---|
| Epic name | Title Case noun phrase | "Payment Processing" |
| Feature file name | kebab-case | `user-login.md` |
| Feature display name | Title Case | "User Login" |
| Scenario name | Verb phrase, sentence case | "User submits valid credentials" |

---

## §9 Implementation Slices

<!-- INTERVIEW GUIDANCE:
Default: High-level "what" only, ordered chronologically. Each slice describes what will be built in that step — not how it will be implemented. 2–5 slices per feature.

Purpose: give developers and designers a natural build order without prescribing implementation decisions. These are ordering hints, not story breakdowns.

Ask: "How much detail do you want in the implementation slices section of feature files? High-level ordering hints, or more detailed breakdown?"

Probing questions:
- "Should slices reference specific components or keep it purely behavioral?"
- "Is a 2–5 slice range appropriate, or do your features tend to need more?"

What is customisable: level of detail, count range.
What is fixed: slices are ordered chronologically and describe "what", not "how".
-->

Implementation slices are ordering hints inside a feature file — they describe the natural build sequence without prescribing technical implementation.

**Level of detail:** high-level "what" only. No implementation specifics.
**Count:** 2–5 slices per feature. More than 5 suggests the feature may be too large.
**Format:** numbered list, each a short phrase describing what is built in that step.

Example:
```
1. Core form render and validation
2. Submission and success state
3. Error states and retry logic
```

---

<!-- INTERVIEW GUIDANCE: §10+ are additions, not defaults. Only include if the user defines domain-specific terminology or other project-specific standards not covered by §1–§9.

Ask at the end: "Is there any domain-specific terminology or project-specific conventions we should record here so the molecule uses the right language?"

Common additions:
- Domain terminology (glossary of terms the molecule should use consistently)
- Custom frontmatter fields (beyond feature, epic, status, priority)
- Cross-epic dependency notation
- Stakeholder or ownership fields
-->

---

*Generated by requirement-forge-refiner | Project: [Project Name] | Date: [Date] | Mode: overlay*
