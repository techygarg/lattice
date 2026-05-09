# Requirements: Default Standards

Embedded defaults for the requirement-quality atom. Opinionated guardrails — override via refiner or write `.lattice/standards/requirement-standards.md` directly.

---

## §1 Epic Definition

Epic is named group of related features forming coherent product area or capability. One epic = meaningful increment of product value — not one feature, not entire product.

**Navigational unit**: epics group features. Not implemented directly. Cannot be handed to design-blueprint.

**Naming**: Title Case noun phrase — "User Authentication", "Payment Processing", "Order Management".

**Size signal**: typical epic contains 3–7 features. Fewer than 2 → merge with sibling epic. More than 10 → challenge whether one epic or two.

---

## §2 Feature Definition

Feature is complete, self-contained unit of product behavior. Must be independently designable and implementable — can be handed to design-blueprint without resolving unknowns external to its scope.

**Test for completeness**: can a developer open this file, read it, and begin design-blueprint without asking a single clarifying question? If no → feature is incomplete.

**Size signal**: more than 5 scenarios → challenge whether one feature or two. Fewer than 2 scenarios → consider merging with related feature.

**Not a story**: feature is the atomic unit. Story decomposition is a team execution concern, downstream of feature spec.

---

## §3 Feature Independence Rule

Feature is independently specced when ALL of the following hold:

1. **Requirements complete within file** — no "TBD", no "refer to Feature X for details", no unresolved open questions that block design.
2. **No external design dependency** — design-blueprint can begin without waiting for another feature to be designed first.
3. **Coherent user value** — delivers something a user can do on its own. Partial value is acceptable; zero value without another feature is not.

Feature that cannot meet (1) → incomplete, do not write file.
Feature that cannot meet (2) → record dependency in `depends_on` frontmatter and note the constraint.
Feature that cannot meet (3) → challenge whether it is a feature or an internal technical slice.

**Cross-epic placement**: when a feature's scenarios draw on behaviors from two different epics, it belongs in the epic where most of its behavior lives (the primary owner). Add a cross-reference note in the feature file pointing to the other epic, and record the cross-epic dependency in `depends_on`. A feature split across two epics with no documented relationship is an orphaned dependency — it will surface as a blocker during design-blueprint.

---

## §4 Scenario Definition

Scenario is bounded situation the feature must handle. Not a user story. Not an acceptance criterion. A situation — a named, scoped context with its own set of verifiable outcomes.

**Nomenclature**: scenario

**Structure**:
- Name: verb phrase in sentence case — "User submits valid form", "Session expires during checkout"
- Description: one sentence describing the situation this scenario covers
- Acceptance criteria: 3–6 items in agreed format

**Ordering**: chronological — the natural implementation sequence. First scenario is the first thing a developer would build. Last scenario is typically edge cases and error handling.

**Max per feature**: 5. Reaching 5 → pause and ask whether this is still one feature.
**Min per feature**: 2 — one happy path, one failure or edge case.

---

## §5 Acceptance Criteria Format

**Format**: Given/When/Then

```
Given [context or precondition],
when [action or event],
then [expected outcome].
```

**Verifiability rule**: every AC must have a clear pass/fail condition. Reader must be able to say "this either happened or it didn't." Vague ACs are not ACs.

| Acceptable | Not acceptable |
|---|---|
| Given a logged-in user, when they submit a valid form, then a success message appears within 2s | The system should handle the form gracefully |
| Given an expired session, when a request is made, then a 401 response with code SESSION_EXPIRED is returned | Errors should be handled properly |
| Given a file over 5MB, when the user attempts upload, then an error message states the size limit | Large files should be rejected |

**Max per scenario**: 6. Exceeding → scenario is too broad; split.

---

## §6 Priority Notation

| Value | Meaning |
|---|---|
| P0 | Critical — must be delivered for the epic to ship. No workaround. |
| P1 | Important — should be delivered this cycle; acceptable to defer only under hard constraints. |
| P2 | Nice-to-have — deliver when capacity allows; product remains viable without it. |

Priority lives at the feature level (frontmatter). Not at the scenario level.

---

## §7 Status Workflow

`draft` → `approved` → `in-design` → `implemented`

| Status | Meaning |
|---|---|
| draft | Being specced — not yet agreed by stakeholders |
| approved | Spec agreed; ready for design-blueprint |
| in-design | design-blueprint session in progress or complete |
| implemented | code-forge complete; feature shipped |

---

## §8 Naming Conventions

| Artifact | Convention | Example |
|---|---|---|
| Epic name | Title Case noun phrase | "Payment Processing" |
| Feature display name | Title Case | "User Login" |
| Feature file name | kebab-case | `user-login.md` |
| Scenario name | Verb phrase, sentence case | "User submits valid credentials" |
| Open question | Imperative sentence ending in `?` | "Should rate limiting apply per user or per IP?" |

---

## §9 Implementation Notes (Slices)

Implementation notes describe the natural build sequence for the feature — what would be built first, second, third. Ordered "what" not "how". 2–5 slices per feature.

**Level of detail**: behavioral, not technical. "Core form validation and submission" not "wire the zod schema to the POST /api/forms endpoint".

**Purpose**: sequencing hint for design-blueprint and code-forge. Not a story breakdown. Not a task list. The developer uses these as a chronological guide, not as prescribed tickets.

**Format**: numbered list, each a short phrase.

```
1. Core [behavior] — [what it enables]
2. [Next behavior] — [what it adds]
3. [Error/edge handling] — [what it protects]
```

---

*Defaults informed by BABOK (Business Analysis Body of Knowledge), BDD (Behaviour-Driven Development) practice, Gojko Adzic Specification by Example (2011), and product management craft.*
