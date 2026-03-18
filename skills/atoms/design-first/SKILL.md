---
name: design-first
description: "Guide structured design thinking through 5 progressive levels before any code is written. Levels: Capabilities, Components, Interactions, Contracts, Implementation. Use when building new features, refactoring significant code, designing modules, or when the user says 'design this', 'architect this', 'let's think before coding', 'walk me through the design', or 'whiteboard this'. Do not use for quick fixes, bug patches, or simple CRUD operations."
---

# Design-First (Progressive Design Facilitation)

## The Problem

AI coding assistants jump from requirement to implementation, making every design decision silently. The result: you review code while simultaneously evaluating scope, architecture, integration, contracts, and quality -- all entangled. Catching a scope mismatch in a two-minute design conversation is fundamentally cheaper than discovering it woven through 400 lines of generated code.

The solution: reconstruct the whiteboarding conversation that human pairs do naturally -- progressive levels of design alignment before any code.

## The 5 Levels

Five levels, ordered from abstract to concrete. Each level surfaces a category of decisions that would otherwise be buried in generated code.

### Level 1: Capabilities (The "What")

**Purpose**: Confirm scope. Surface the user-facing outcomes the system needs to deliver. This is the shared vocabulary check -- ensuring both human and AI are talking about the same feature, with the same boundaries.

**Output format**: A numbered list of user-facing capabilities, max 5. Each capability is a plain-language outcome, not an implementation detail.

**Boundary**: No components, no architecture, no technical detail. If a capability mentions a specific technology, class, or data structure -- it belongs at a later level. This level answers only "what does the user get?"

**Checkpoint**: "Does this Level 1 (Capabilities) look correct? Should I proceed to Level 2 (Components)?"

### Level 2: Components (The "Who")

**Purpose**: Identify the building blocks. What are the major pieces of the system, and what is each one responsible for?

**Output format**: 3-5 components, each with a single responsibility and a one-line description. Include an ASCII or Mermaid diagram showing how they relate. Note integration points with existing infrastructure.

**Boundary**: No data flow, no sequence of operations, no interaction detail. Each component is described by what it *is* and what it *owns* -- not how it communicates with others. If you find yourself writing "A sends X to B" -- that belongs at Level 3.

**Checkpoint**: "Does this Level 2 (Components) look correct? Should I proceed to Level 3 (Interactions)?"

### Level 3: Interactions (The "How They Talk")

**Purpose**: Define the data flow between components. How do the building blocks communicate to deliver the capabilities?

**Output format**: A sequence diagram (ASCII or Mermaid) or a numbered flow showing the order of operations. For each interaction, describe WHAT data passes between components. See `./references/methodology-detail.md` for notation guidance.

**Boundary**: No function signatures, no type definitions, no implementation detail. Focus on what passes between components, not how each component processes it internally. If you find yourself defining method parameters or return types -- that belongs at Level 4.

**Checkpoint**: "Does this Level 3 (Interactions) look correct? Should I proceed to Level 4 (Contracts)?"

### Level 4: Contracts (The "Interface Definitions")

**Purpose**: Define the interfaces, method signatures, and type definitions that formalize the interactions. This is the handoff artifact -- the specification that implementation will be built against.

**Output format**: Typed interfaces, method signatures, and type definitions. Language-appropriate format (TypeScript interfaces, Java interfaces, Python protocols, etc.). No function bodies -- signatures and types only. See `./references/methodology-detail.md` for interface definition patterns.

**Boundary**: No implementation logic. If a function body appears -- it belongs at Level 5. Contracts reflect the design agreed upon in Levels 1-3, nothing more. Utility functions, helper methods, or convenience wrappers that were not in the design do not belong here.

**Checkpoint**: "Does this Level 4 (Contracts) look correct? Should I proceed to Level 5 (Implementation)?"

### Level 5: Implementation (The "Code")

**Purpose**: Write the code. Implement against the agreed contracts, within the agreed component boundaries, following the agreed interaction patterns.

**Output format**: Working code that fulfills the contracts defined in Level 4. Each component is implemented within its agreed boundary. The implementation should be reviewable against the design -- a reviewer can check each component against its Level 2 description, each interaction against its Level 3 flow, each interface against its Level 4 contract.

**Boundary**: Only after Level 4 is explicitly approved. The implementation follows the design; it does not introduce new components, new interactions, or new contracts that were not agreed upon.

## The Zero Implementation Rule

The most critical discipline in this methodology: **no code until the design is agreed.**

If you catch yourself writing function bodies before Level 5 is approved -- STOP. Return to the current design level and present only the output appropriate for that level.

This rule exists because AI training optimizes for producing tangible output quickly, which means the AI will constantly try to collapse levels -- offering component diagrams with code already written, or proposing contracts with implementations attached. The discipline of staying at the current level of abstraction protects working memory from premature detail and keeps the conversation focused on the category of decision being made.

The simplest version of this entire methodology is this single constraint: no code until the design is agreed. Everything else follows from there.

## Complexity Calibration

Not every task needs all five levels. The framework scales to the complexity of the work -- it is a tool for managing complexity, not a ritual to be applied uniformly.

| Task Complexity | Start At | Example |
|---|---|---|
| Simple utility | Level 4 (Contracts) | Date formatter, string helper |
| Single component | Level 2 (Components) | Validation service, API endpoint |
| Multi-component feature | Level 1 (Capabilities) | Notification system, payment flow |
| New system integration | Level 1 + deep Level 3 | Third-party API, event pipeline |

When starting at a later level, the earlier levels are implicitly agreed upon -- the scope and components are obvious enough that they do not need explicit alignment.

## Level Completion Protocol

At the end of each level:

1. Present the level output in the format specified for that level (numbered list, diagram, sequence flow, or interfaces).
2. Ask the gating question: "Does this Level [N] look correct? Should I proceed to Level [N+1]?"
3. Wait for explicit approval before advancing. Do not proceed on silence or ambiguity.
4. If the user redirects, corrects, or raises concerns -- revise the current level. Do not advance until the revision is approved.

Each level constrains the decision space for the next. Skipping a level or advancing without approval means the constraints are not established, and later levels will drift.

## Challenge Requirements

If something seems over-engineered at any level, propose a simpler alternative. The AI should actively push back on unnecessary complexity -- extra components that could be merged, abstractions that add indirection without value, capabilities that were not requested.

This applies at every level: a capability list that exceeds the stated requirements, a component structure with unnecessary wrappers, an interaction flow with redundant steps, contracts with utility functions not in the design. Simpler is better. Every addition is surface area that must be reviewed, tested, and maintained.

When the user's requirements could be served by a simpler design, present the simpler alternative first and explain why. Let the user choose to add complexity rather than having to remove it.

## Anti-Patterns

Common violations that collapse the progressive structure:

| Anti-Pattern | Symptom | Fix |
|---|---|---|
| **Level Collapse** | Components described with implementation code | Strip code, return to component boundaries only |
| **Scope Creep** | Level 1 lists capabilities not in requirements | Remove unrequested items, confirm scope |
| **Premature Detail** | Level 2 includes sequence diagrams or data flow | Move interaction detail to Level 3 |
| **Gold Plating** | Contracts include utility functions not in the design | Remove; contracts reflect the design, not extras |
| **Skipping Levels** | Jump from Level 1 to Level 4 | Back up; each level constrains the next |
| **Silent Advancement** | Moving to the next level without explicit approval | Always ask the gating question and wait |
| **Feature Injection** | Adding rate limiting, analytics, or hooks nobody asked for | Remove unrequested features; design what was requested |

## Output Formats

Each level has a distinct format that reinforces its focus:

- **Level 1 (Capabilities)**: Numbered list. Each item is a user-facing outcome in plain language. No technical terms.
- **Level 2 (Components)**: ASCII or Mermaid diagram + component descriptions. Each component has a name, a single responsibility, and a note on how it integrates with existing infrastructure.
- **Level 3 (Interactions)**: Sequence diagram (ASCII or Mermaid) or numbered flow. Each step names the source, the target, and what data passes. See `./references/methodology-detail.md` for notation guidance.
- **Level 4 (Contracts)**: Typed interfaces and signatures in the project's language. Clean, minimal, no function bodies. See `./references/methodology-detail.md` for interface definition patterns.
- **Level 5 (Implementation)**: Working code organized by component, implementing the agreed contracts.
