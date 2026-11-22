# Architecture Refiner Template (Generic)

This template defines the structure of the `.lattice/standards/architecture.md` output document for non-clean-architecture styles (hexagonal, modular monolith, custom, etc.). Used when `architecture_mode: custom` is set. It contains interview guidance comments that are stripped from the final output.

When producing the output, strip all `<!-- INTERVIEW GUIDANCE: -->` comments. The final document is a specification, not a conversation log.

---

## Frontmatter

<!-- INTERVIEW GUIDANCE:
The generic architecture document always uses override mode — there are no embedded defaults
to overlay onto. The architecture atom reads this document as the sole reference.
-->

```yaml
---
mode: override
---
```

---

## Preamble

<!-- INTERVIEW GUIDANCE:
Include the preamble with the selected architecture style name.
-->

> These are the architecture principles for [PROJECT NAME], following a [STYLE NAME] architecture. This document is the sole reference for the `architecture` atom — there are no embedded defaults.

**Table of contents:**

1. [Layer Definitions](#1-layer-definitions)
2. [Dependency Rules](#2-dependency-rules)
3. [Boundary Rules](#3-boundary-rules)
4. [Per-Layer Rules](#4-per-layer-rules)
5. [Key Flows](#5-key-flows)
6. [Validation Checklist](#6-validation-checklist)
7. [Anti-Patterns](#7-anti-patterns)
8. [Ambiguity Signals](#8-ambiguity-signals)

---

## 1. Layer Definitions

<!-- INTERVIEW GUIDANCE:
Ask: "What layers does your architecture use? Please describe each layer and its responsibility."

For Hexagonal / Ports & Adapters, seed the conversation:
"Hexagonal architecture typically has:
- Core Domain — business rules and domain logic
- Ports — interfaces that define how the core communicates with the outside
- Adapters — implementations that connect ports to real infrastructure (DB, HTTP, messaging)
Does this match your project, or do you use different terminology?"

For Modular Monolith, seed:
"Modular monolith typically has vertical slices — each module owns its own layers internally.
What are your modules? And within each module, what layers do you use?"

For Custom, ask:
"Please describe each layer in your architecture — its name, what belongs in it, and what it is responsible for."

Probing questions:
- How many layers do you have?
- Do you have a shared/common layer for cross-cutting concerns?
- What directories map to each layer?
- Is there a clear innermost layer that has no outward dependencies?

Record: a table with Layer Name, Responsibility, and typical directory mapping.
-->

| Layer | Responsibility | Typical Directory |
|-------|---------------|-------------------|
| (fill per interview) | | |

### Directory Mapping

```
src/
├── (fill per interview)
```

---

## 2. Dependency Rules

<!-- INTERVIEW GUIDANCE:
Ask: "Which layers can depend on which? What is the dependency direction?"

Show an ASCII diagram as a starting point based on the style:

For Hexagonal:
"In hexagonal architecture, the typical rule is:
- Adapters depend on Ports
- Ports depend on Core Domain
- Core Domain depends on nothing
Does this match your project?"

For Modular Monolith:
"In modular monolith, the typical rules are:
- Modules should not depend on each other's internals
- Modules communicate through public contracts (APIs, events)
- Within a module, inner layers have no outward dependencies
Does this match your project?"

For Custom:
"Please describe your dependency rules — which layers can import from which?"

Probing questions:
- Is there a strict inward-only rule, or are there exceptions?
- How do you handle dependency inversion when an inner layer needs to trigger something in an outer layer?
- What format do you use for data crossing boundaries? (DTOs, events, plain objects)

Record: an ASCII diagram showing dependency direction + prose rules.
-->

```
(fill ASCII dependency diagram per interview)
```

**Data crossing boundaries**: (fill per interview — DTOs, events, plain objects, etc.)

---

## 3. Boundary Rules

<!-- INTERVIEW GUIDANCE:
Ask: "How do your layers communicate with each other?"

Probing questions:
- Do layers communicate through interfaces, events, direct method calls, or a mix?
- Do you use dependency injection? What mechanism? (DI container, manual, framework-provided)
- Are there specific patterns for crossing boundaries? (ports, mediators, event buses)
- Is cross-module communication different from cross-layer communication?

Record: the communication patterns, DI approach, and any boundary-crossing conventions.
-->

(fill per interview)

---

## 4. Per-Layer Rules

<!-- INTERVIEW GUIDANCE:
Walk through each layer from §1 one at a time. For each layer, ask:
"What is allowed in this layer? What is forbidden?"

For each layer, capture:
- What belongs here (bullet list)
- What does not belong here (bullet list)
- Common violations to watch for (bullet list)

This section is critical — it provides the enforcement detail the atom needs.
-->

### (Layer 1 Name)

**What belongs here:**
- (fill per interview)

**What does not belong here:**
- (fill per interview)

**Common violations:**
- (fill per interview)

### (Layer 2 Name)

**What belongs here:**
- (fill per interview)

**What does not belong here:**
- (fill per interview)

**Common violations:**
- (fill per interview)

<!-- INTERVIEW GUIDANCE:
Repeat the sub-section pattern for each layer identified in §1.
-->

---

## 5. Key Flows

<!-- INTERVIEW GUIDANCE:
Ask: "Can you walk me through 1-2 representative flows in your architecture?"

Suggested prompts:
- "How does a write operation (e.g., creating a resource) flow through your layers?"
- "How does a read operation flow through your layers?"
- "How does a cross-module or cross-boundary operation work?"

For each flow, capture:
- Flow name (e.g., "Write Operation", "Read Operation")
- Step-by-step path through the layers
- Which layer is responsible for what at each step

Record: named flows with step-by-step layer traversal, using pseudocode or flow diagrams.
-->

### Flow 1: (Name)

```
(fill step-by-step flow per interview)
```

### Flow 2: (Name)

```
(fill step-by-step flow per interview)
```

---

## 6. Validation Checklist

<!-- INTERVIEW GUIDANCE:
This section is REQUIRED — the architecture atom reads it to run post-generation verification.
The atom uses imperative STOP-and-verify language with this list. It must contain at least 3 concrete checks.

Ask: "What should the AI check after generating code to ensure it follows your architecture?"

Seed with universal structural checks adapted to the user's layers:
- Is each class/module in the correct layer?
- Does the dependency direction follow the rules in §2?
- Does data crossing boundaries use the patterns from §3?

Then ask for style-specific checks:
"Are there any additional checks specific to your architecture style?"

Format: NUMBERED list with labeled items (e.g., "1. LAYER PLACEMENT: ..."). NOT checkboxes.
The atom will STOP after generating each component and walk through this list sequentially.
Minimum: 3 items. Aim for 5-8 for comprehensive coverage.
-->

STOP after generating each component. Verify ALL of the following before proceeding:

1. (fill per interview — e.g., **LAYER PLACEMENT**: Is each class in the correct layer?)
2. (fill per interview — e.g., **DEPENDENCY DIRECTION**: Do all dependencies follow the rules above?)
3. (fill per interview — e.g., **BOUNDARY DATA**: Does data crossing layers use the correct format?)

---

## 7. Anti-Patterns

<!-- INTERVIEW GUIDANCE:
This section is REQUIRED — the architecture atom reads it to run active anti-pattern scanning.
The atom scans generated code for each pattern listed here. It must contain at least 3 anti-patterns.

Ask: "What are the most common architectural mistakes in your style that the AI should watch for?"

Seed with universal anti-patterns adapted to the user's style:
- Logic in the wrong layer
- Dependencies flowing in the wrong direction
- Boundary violations (leaking types across layers)
- God classes spanning multiple layers

Then ask for style-specific anti-patterns:
"Are there patterns specific to [hexagonal / modular monolith / your style] that should be flagged?"

For EACH anti-pattern, ask: "When the AI finds this pattern, what should it do to fix it?"
This is critical — the atom needs both the symptom (what to detect) and the fix (what to do about it).

Format: checkbox list with pattern name, symptom, and fix action.
Minimum: 3 anti-patterns. Aim for 5-8 for comprehensive coverage.
-->

After verifying the checklist above, scan output for these anti-patterns. If found, fix before presenting.

- [ ] **(Pattern Name)**: (symptom) → (fix action)
- [ ] **(Pattern Name)**: (symptom) → (fix action)
- [ ] **(Pattern Name)**: (symptom) → (fix action)

---

## 8. Ambiguity Signals

<!-- INTERVIEW GUIDANCE:
This section is optional but recommended. It helps the AI know when to ask instead of silently choosing.

Ask: "Are there architectural decisions in your style where multiple valid approaches exist?
For example, a component that could reasonably live in two different layers, or a flow
that could be implemented with either direct calls or events?"

Seed with universal architectural ambiguities:
- A component could belong in layer A or layer B — what determines the answer?
- A cross-boundary operation could use synchronous calls or events — when to use which?
- Data structures could be shared between layers or duplicated — what's the team's preference?

Then ask for style-specific ambiguities:
"In [hexagonal / modular monolith / your style], what are the gray areas where engineers disagree?"

Format: bullet list describing the ambiguous scenario and what makes it a judgment call.
When the AI encounters one of these during generation, it should present options rather than silently choosing.
-->

These checks often have multiple valid outcomes. When you encounter one, present options rather than silently choosing.

- (fill per interview — e.g., a component that could live in either of two layers)

---

## New Sections

<!-- INTERVIEW GUIDANCE:
At the end of the interview, ask:
"Are there any project-specific sections you'd like to add? Common additions:
- Naming conventions (file naming, class naming patterns)
- Framework-specific rules (e.g., NestJS module structure, Spring conventions)
- Testing patterns (how tests align with architectural layers)
- Error handling patterns (how errors propagate across layers)
- Event patterns (event naming, payload structure, when to use events)"

If the user wants to add sections, number them starting from 9.
-->

---

## Footer

<!-- INTERVIEW GUIDANCE:
Include project name, generation date, and style name in the output.
Example:

---
*Generated for [PROJECT NAME] on [DATE]. Style: [STYLE NAME].*
*Produced by the architecture-refiner skill.*
-->
