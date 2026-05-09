# Requirement Forge — Output Templates

Read this file when writing `.lattice/requirements/` documents. Use these templates exactly.

---

## Apex File: `.lattice/requirements/index.md`

```markdown
---
project: [Project Name]
last_updated: [Date]
---

# Requirements Index — [Project Name]

## Definitions

**Epic:** [from loaded standards or built-in default]
**Feature:** [from loaded standards or built-in default]

---

## Epics

### [Epic Name]
[One-paragraph description.]

| Feature | Summary | Status | Priority | Depends On |
|---|---|---|---|---|
| [Feature A](features/feature-a.md) | one-line summary | draft | P0 | — |
| [Feature B](features/feature-b.md) | one-line summary | draft | P1 | Feature A |

<!-- If loaded standards include §10 Domain Terminology, add: -->
## Glossary

| Term | Definition |
|---|---|
| [Term] | [Project-specific definition from standards §10] |

<!-- If source documents were provided during intake, add: -->
## Source Materials

| Document | Type | Features Derived |
|---|---|---|
| [document name or path] | [PRD / stakeholder notes / Jira export / etc.] | [Feature A, Feature B] |

## Deferred Items
Content from source materials intentionally not mapped to any feature in this cycle.

- [Item] — reason for deferral
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

## Implementation Notes
1. ...
2. ...

## Open Questions
- [ ] ...

## Links
- Design: *(updated when design-blueprint creates a context anchor doc for this feature)*
- Epic index: [index.md](../index.md)
```
