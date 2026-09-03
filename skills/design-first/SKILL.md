---
name: design-first
description: "Guide structured design thinking through 5 progressive levels before any code is written. Levels: Capabilities, Components, Interactions, Contracts, Implementation. Use when building new features, refactoring significant code, designing modules, or when the user says 'design this', 'architect this', 'let's think before coding', 'walk me through the design', or 'whiteboard this'. For simple utilities enter at Level 4 (Contracts), for single-component tasks at Level 2 — see Complexity Calibration. Do not use for quick bug patches."
---

# Design-First (Progressive Design Facilitation)

## The 5 Levels

### Level 1: Capabilities (The "What")

**Purpose**: Confirm scope. Surface the user-facing outcomes the system must deliver. Shared vocabulary check — ensure the human and the AI are talking about the same feature with the same boundaries.

**Output format**: Numbered list of user-facing capabilities, max 5. Each capability is a plain-language outcome, not an implementation detail.

**Boundary**: No components, no architecture, no technical detail. If a capability mentions a specific technology, class, or data structure, it belongs at a later level. This level answers only "what does the user get?"

**Checkpoint**: "Does this Level 1 (Capabilities) look correct? Should I proceed to Level 2 (Components)?"

### Level 2: Components (The "Who")

**Purpose**: Identify the building blocks. What major pieces does the system have, and what is each one responsible for?

**Output format**: 3-5 components, each with a single responsibility and a one-line description. Include an ASCII or Mermaid diagram showing how they relate. Note integration points with existing infrastructure.

**Boundary**: No data flow, no sequence of operations, no interaction detail. Describe each component by what it *is* and what it *owns* — not how it communicates with others. If you find yourself writing "A sends X to B", that belongs at Level 3.

**Checkpoint**: "Does this Level 2 (Components) look correct? Should I proceed to Level 3 (Interactions)?"

### Level 3: Interactions (The "How They Talk")

**Purpose**: Define the data flow between components. How do the building blocks communicate to deliver the capabilities?

**Output format**: A sequence diagram (ASCII or Mermaid) or a numbered flow showing the order of operations. For each interaction, describe WHAT data passes between components. See `./references/methodology-detail.md` for notation guidance.

**Boundary**: No function signatures, no type definitions, no implementation detail. Focus on what passes between components, not how each component processes internally. If you are defining method parameters or return types, that belongs at Level 4.

**Checkpoint**: "Does this Level 3 (Interactions) look correct? Should I proceed to Level 4 (Contracts)?"

### Level 4: Contracts (The "Interface Definitions")

**Purpose**: Define the interfaces, method signatures, and type definitions that formalize the interactions. This is the handoff artifact — the specification that implementation is built against.

**Output format**: Typed interfaces, method signatures, type definitions in a language-appropriate format (TypeScript interfaces, Java interfaces, Python protocols, etc.). Use the project's primary language; if ambiguous, ask before writing contracts. No function bodies — signatures and types only. Include error/failure types where interactions can fail. See `./references/methodology-detail.md` for interface definition patterns.

**Boundary**: No implementation logic. If a function body appears, it belongs at Level 5. Contracts reflect the design agreed at Levels 1-3, nothing more — no utility functions, helper methods, or convenience wrappers that are not part of the design. Every Level 3 interaction must map to at least one interface or type; no new interactions may appear here that were not agreed at Level 3.

**Checkpoint**: "Does this Level 4 (Contracts) look correct? Should I proceed to Level 5 (Implementation)?"

### Level 5: Implementation (The "Code")

**Purpose**: Write code. Implement against the agreed contracts, within the agreed component boundaries, following the agreed interaction patterns.

**Output format**: Working code that fulfills the contracts defined at Level 4, each component implemented within its agreed boundary. The implementation is reviewable against the design: each component checked against its Level 2 description, each interaction against its Level 3 flow, each interface against its Level 4 contract.

**STOP:** Only after Level 4 is explicitly approved. Implementation follows the design; it must not introduce new components, new interactions, or new contracts that were not agreed upon.

## The Zero Implementation Rule

**No code until the design is agreed.**

**STOP:** If you catch yourself writing function bodies before Level 5 is approved, return to the current design level and present only the output appropriate to that level.

## Complexity Calibration

| Task Complexity | Start At | Example |
|---|---|---|
| Simple utility | Level 4 (Contracts) | Date formatter, string helper |
| Single component | Level 2 (Components) | Validation service, API endpoint |
| Multi-component feature | Level 1 (Capabilities) | Notification system, payment flow |
| New system integration | Level 1 + deep Level 3 | Third-party API, event pipeline |

## Entry Assessment

Before producing the first level output, state the entry level and rationale:

"Based on [complexity signal], I'll start at Level [N] ([name]). Earlier levels are implicitly agreed — [brief statement of what's assumed]. Want to start here or go broader?"

Wait for confirmation before producing the first level output. If the user disagrees, adjust the entry point.

## Level Completion Protocol

At the end of each level:

1. Present the level output in the format specified for that level (numbered list, diagram, sequence flow, or interfaces).
2. Self-check: is this simpler than it could be? If a simpler alternative exists, present it alongside: "I have a simpler option — [alternative]. Which do you prefer?"
3. Ask the gating question: "Does this Level [N] look correct? Should I proceed to Level [N+1]?"
4. **STOP:** Wait for explicit approval. Do not advance on silence or ambiguity.
5. If the user redirects, corrects, or raises concerns, revise the current level. Do not advance until the revision is approved.

**Level 5 exit**: there is no Level 6 — at Level 5 the protocol ends after step 2. Present the implementation for review instead of asking a gating question; the skill is complete once the user accepts the implementation or requests revisions to it.

**Out-of-level input**: If the user provides detail belonging to a later level (e.g., interaction detail during Level 2), acknowledge it — "Good thinking, I'll capture that at Level [N] ([name])" — and continue the current level. Do not ignore or reject it.

**Backtracking**: If a later level reveals a gap in an earlier level (e.g., a missing component discovered during Level 3), name the gap, propose a revision to the earlier level, get approval for the revision, then resume the current level.

**Scope expansion at Level 5**: If the user requests new scope during implementation, assess the impact. If it affects components or interactions, propose a mini-loop back to the affected level for agreement. If it is purely implementation detail (logging, config), incorporate it directly.

**Mid-level exit**: If the user says "skip to code" or "just implement it" before the design is complete, acknowledge the tradeoff before proceeding: "Skipping Level [N] means [what hasn't been aligned] — I'll flag any design gaps I notice as I implement. Proceeding now." Then implement. Do not refuse or block; note the risk and move forward.

## Simplicity Check (Every Level)

Actively push back on unnecessary complexity: capabilities beyond scope, components that could merge, interaction steps that add no value, contracts carrying utility functions nobody requested. Present the simpler alternative first. Let the user choose to add complexity rather than have to remove it later.

## Anti-Patterns

| Anti-Pattern | Symptom | Fix |
|---|---|---|
| **Level Collapse** | Components described with implementation code | Strip the code; return to component boundaries only |
| **Scope Creep** | Level 1 lists capabilities not in the requirements | Remove unrequested items; confirm scope |
| **Premature Detail** | Level 2 includes sequence diagrams or data flow | Move interaction detail to Level 3 |
| **Gold Plating** | Contracts include utility functions not in the design | Remove them; contracts reflect the design, not extras |
| **Skipping Levels** | Jump from Level 1 to Level 4 | Back up; each level constrains the next |
| **Silent Advancement** | Moving to the next level without explicit approval | Always ask the gating question and wait |
| **Feature Injection** | Adding rate limiting, analytics, or hooks nobody asked for | Remove unrequested features; design only what was requested |
