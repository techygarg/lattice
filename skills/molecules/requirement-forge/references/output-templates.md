# Requirement Forge — Output Templates

Read this file when writing `.lattice/requirements/` documents. Use these templates exactly.

---

## Apex File: `.lattice/requirements/index.md`

Thin and rarely hand-touched. Everything below the boundary comment is generated at Step 6 by scanning `epics/*.md` headers — never hand-append a row here.

```markdown
---
project: [Project Name]
last_updated: [Date]
---

# Requirements Index — [Project Name]

## Definitions

**Epic:** [from loaded standards or built-in default]
**Feature:** [from loaded standards or built-in default]

<!-- If loaded standards include §10 Domain Terminology, add: -->
## Glossary

| Term | Definition |
|---|---|
| [Term] | [Project-specific definition from standards §10] |

---

## Epics

<!-- GENERATED — regenerated from epics/*.md headers, do not hand-edit below -->

| Epic | Summary |
|---|---|
| [Epic Name](epics/epic-slug.md) | one-paragraph description, condensed to one line |

<!-- END GENERATED -->
```

---

## Epic File: `.lattice/requirements/epics/{epic-slug}.md`

Header is hand-authored (written once at Step 3, rarely revisited). Feature table is generated at Step 6 — never hand-append a row.

```markdown
---
epic: [Epic Name]
---

# [Epic Name]

[One-paragraph description.]

<!-- If source documents were provided during intake, add/update at Step 6: -->
## Source Materials

| Document | Type | Features Derived |
|---|---|---|
| [document name or path] | [PRD / stakeholder notes / Jira export / etc.] | [Feature A, Feature B] |

<!-- Add/update at Step 6 when applicable: -->
## Deferred Items
Content from source materials intentionally not mapped to any feature in this cycle.

- [Item] — reason for deferral

## Features

<!-- GENERATED — regenerated from features/*.md filenames/titles where epic matches, do not hand-edit below. Status, priority, and dependencies live only in each feature file — never mirrored here. -->

| Feature | Summary |
|---|---|
| [Feature A](../features/feature-a.md) | one-line summary |
| [Feature B](../features/feature-b.md) | one-line summary |

<!-- END GENERATED -->
```

---

## Feature File: `.lattice/requirements/features/{feature-name}.md`

```markdown
---
feature: [Feature Name]
epic: [Epic Name]
status: draft
priority: [from loaded standards]
depends_on: []
personas: []
source_docs: []
---

# [Feature Name]

## Problem Statement

## User / Personas
Who experiences this problem? Name specific user types or roles — not "users."

## Scope
**In scope:**
**Out of scope:**

## Boundary Conditions

## Assumptions
Statements the team proceeds with as true. If any assumption proves wrong, revisit the affected scenarios.

## Scenarios

### Scenario 1: [Verb phrase]
[One sentence describing the situation.]

**Acceptance Criteria:**
- Given [context], when [action], then [outcome]

### Scenario 2: [Verb phrase]
...

*(Scenarios ordered chronologically — natural implementation sequence.)*

## Technical Constraints
Non-negotiable inputs for design. Populate with:
- Fixed external interfaces (SDKs, platform APIs, existing contracts that cannot change)
- Pre-existing internal interfaces that cannot be modified
- Hard platform/runtime limits (e.g., "must run on .NET 6", "no new NuGet deps")

**STOP: No implementation decisions here — no class names, method shapes, DTO designs.** Those belong in the design context doc. Constraint = what design cannot change, not how design should work.

## Open Questions
- [ ] ...

## Links
- Design: *(link added by design-blueprint when context doc is created)*
- Design override: *(added by design-blueprint — one bullet per field, type, or behavior changed from this spec during design, with the reason; none means L4 contracts are fully consistent with this spec)*
- Design alignment: *(added by design-blueprint when L4 contracts confirmed consistent with this spec and no overrides exist)*
- Epic index: [epic-slug.md](../epics/epic-slug.md)
```
