---
name: design-first
description: "Guide structured design thinking through 5 progressive levels before any code is written. Levels: Capabilities, Components, Interactions, Contracts, Implementation. Use when building new features, refactoring significant code, designing modules, or when the user says 'design this', 'architect this', 'let's think before coding', 'walk me through the design', or 'whiteboard this'. For simple utilities or single-component tasks, enter at Level 4 (Contracts). Do not use for quick bug patches."
---

# Design-First (Progressive Design Facilitation)

## The Problem

AI jump requirement→implementation, make all design decision silent. Result: you review code while evaluate scope, architecture, integration, contracts, quality -- all tangled. Catch scope mismatch in 2-min design talk way cheaper than find buried in 400 lines generated code.

Solution: rebuild whiteboard talk human pairs do natural -- progressive design levels before code.

## The 5 Levels

Five levels, abstract→concrete. Each level surface decision category that otherwise buried in generated code.

### Level 1: Capabilities (The "What")

**Purpose**: Confirm scope. Surface user-facing outcomes system need deliver. Shared vocabulary check -- ensure human and AI talk same feature, same boundaries.

**Output format**: Numbered list user-facing capabilities, max 5. Each capability plain-language outcome, not implementation detail.

**Boundary**: No components, no architecture, no technical detail. If capability mention specific technology, class, or data structure -- belong later level. This level answer only "what user get?"

**Checkpoint**: "Does this Level 1 (Capabilities) look correct? Should I proceed to Level 2 (Components)?"

### Level 2: Components (The "Who")

**Purpose**: Identify building blocks. What major pieces system, what each one responsible for?

**Output format**: 3-5 components, each with single responsibility and one-line description. Include ASCII or Mermaid diagram showing how relate. Note integration points with existing infrastructure.

**Boundary**: No data flow, no sequence operations, no interaction detail. Each component described by what it *is* and what it *owns* -- not how communicate with others. If write "A sends X to B" -- belong Level 3.

**Checkpoint**: "Does this Level 2 (Components) look correct? Should I proceed to Level 3 (Interactions)?"

### Level 3: Interactions (The "How They Talk")

**Purpose**: Define data flow between components. How building blocks communicate deliver capabilities?

**Output format**: Sequence diagram (ASCII or Mermaid) or numbered flow showing order operations. For each interaction, describe WHAT data passes between components. See `./references/methodology-detail.md` for notation guidance.

**Boundary**: No function signatures, no type definitions, no implementation detail. Focus what passes between components, not how each component process internally. If define method parameters or return types -- belong Level 4.

**Checkpoint**: "Does this Level 3 (Interactions) look correct? Should I proceed to Level 4 (Contracts)?"

### Level 4: Contracts (The "Interface Definitions")

**Purpose**: Define interfaces, method signatures, type definitions that formalize interactions. Handoff artifact -- spec that implementation built against.

**Output format**: Typed interfaces, method signatures, type definitions. Language-appropriate format (TypeScript interfaces, Java interfaces, Python protocols, etc.). No function bodies -- signatures and types only. See `./references/methodology-detail.md` for interface definition patterns.

**Boundary**: No implementation logic. If function body appear -- belong Level 5. Contracts reflect design agreed Levels 1-3, nothing more. Utility functions, helper methods, convenience wrappers not in design not belong here.

**Checkpoint**: "Does this Level 4 (Contracts) look correct? Should I proceed to Level 5 (Implementation)?"

### Level 5: Implementation (The "Code")

**Purpose**: Write code. Implement against agreed contracts, within agreed component boundaries, following agreed interaction patterns.

**Output format**: Working code fulfill contracts defined Level 4. Each component implemented within agreed boundary. Implementation reviewable against design -- reviewer check each component against Level 2 description, each interaction against Level 3 flow, each interface against Level 4 contract.

**Boundary**: Only after Level 4 explicitly approved. Implementation follow design; not introduce new components, new interactions, new contracts not agreed upon.

## The Zero Implementation Rule

Most critical discipline: **no code until design agreed.**

If catch self writing function bodies before Level 5 approved -- STOP. Return current design level, present only output appropriate that level.

Rule exist because AI training optimize for produce tangible output quick, means AI constantly try collapse levels -- offer component diagrams with code already written, or propose contracts with implementations attached. Discipline staying current abstraction level protect working memory from premature detail, keep conversation focused on decision category being made.

Simplest version entire methodology: no code until design agreed. Everything else follow from there.

## Complexity Calibration

Not every task need all five levels. Framework scale to complexity work -- tool for manage complexity, not ritual apply uniform.

| Task Complexity | Start At | Example |
|---|---|---|
| Simple utility | Level 4 (Contracts) | Date formatter, string helper |
| Single component | Level 2 (Components) | Validation service, API endpoint |
| Multi-component feature | Level 1 (Capabilities) | Notification system, payment flow |
| New system integration | Level 1 + deep Level 3 | Third-party API, event pipeline |

When start later level, earlier levels implicitly agreed -- scope and components obvious enough not need explicit alignment.

## Level Completion Protocol

At end each level:

1. Present level output in format specified that level (numbered list, diagram, sequence flow, or interfaces).
2. Ask gating question: "Does this Level [N] look correct? Should I proceed to Level [N+1]?"
3. Wait explicit approval before advance. Not proceed on silence or ambiguity.
4. If user redirect, correct, or raise concerns -- revise current level. Not advance until revision approved.

Each level constrain decision space for next. Skip level or advance without approval mean constraints not established, later levels drift.

**Mid-level exit**: If user say "skip to code" or "just implement it" before design complete, acknowledge tradeoff before proceed: "Skipping Level [N] means [what hasn't been aligned] -- I'll flag any design gaps I notice as I implement. Proceeding now." Then implement. Not refuse or block; note risk and move forward.

## Simplicity Check (Every Level)

At end each level output, before ask gating question, ask: **"Is this simpler than it could be?"**

Active push back on unnecessary complexity: capabilities beyond scope, components that could merge, interaction steps add no value, contracts with utility functions nobody requested. Present simpler alternative first. Let user choose add complexity rather than have remove it.

Not post-design concern -- active discipline every checkpoint. Every addition surface area must review, test, maintain. Simpler better.

## Anti-Patterns

Common violations collapse progressive structure:

| Anti-Pattern | Symptom | Fix |
|---|---|---|
| **Level Collapse** | Components described with implementation code | Strip code, return to component boundaries only |
| **Scope Creep** | Level 1 lists capabilities not in requirements | Remove unrequested items, confirm scope |
| **Premature Detail** | Level 2 includes sequence diagrams or data flow | Move interaction detail to Level 3 |
| **Gold Plating** | Contracts include utility functions not in the design | Remove; contracts reflect the design, not extras |
| **Skipping Levels** | Jump from Level 1 to Level 4 | Back up; each level constrains the next |
| **Silent Advancement** | Moving to the next level without explicit approval | Always ask the gating question and wait |
| **Feature Injection** | Adding rate limiting, analytics, or hooks nobody asked for | Remove unrequested features; design what was requested |

