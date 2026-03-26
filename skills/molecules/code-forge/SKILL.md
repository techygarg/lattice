---
name: code-forge
description: "Generate implementation code from an approved design blueprint or verbal requirements. Composes context anchoring, clean architecture, clean code, DDD, security, and test quality into an inside-out implementation workflow. Use when moving from design to code, implementing approved contracts, or when the user says 'implement', 'code this', 'build it', 'forge the code', or 'generate the code'."
---

# Code Forge

## Required Skills

Read and apply these skills:

1. `framework:knowledge-priming` -- Load project context (tech stack, architecture, conventions) so implementation matches the real project (always)
2. `framework:context-anchoring` -- Load or discover an existing context anchor document; enrich it as implementation decisions are made (always)
3. `framework:collaborative-judgment` -- Surface genuine judgment calls with structured options instead of silently assuming (always)
4. `framework:clean-architecture` -- Layer placement, dependency direction, command/query flow classification (always)
5. `framework:clean-code` -- Code craft guardrails: SRP, naming, complexity, error handling (always)
6. `framework:domain-driven-design` -- Aggregates, entities, value objects, domain services (conditional: only when touching domain folder)
7. `framework:secure-coding` -- Trust boundaries, injection prevention, secrets management (conditional: only for boundary-crossing code)
8. `framework:test-quality` -- AAA structure, isolation, assertion quality, naming (always when writing tests)

## Workflow

### Step 1: Establish Implementation Context

**Load learnings**: If `.ai/learnings/review-insights.md` exists, read it. Use recent insights to inform generation — e.g., if learnings say "anemic domain models keep appearing," actively push behavior into entities. If learnings flag "missing input validation on value objects," validate in constructors from the start. These are patterns from past reviews — use them to avoid repeating the same mistakes.

Use `framework:context-anchoring` Document Discovery to check for an existing context anchor document for the feature being implemented.

- **If found** → Load it (context-anchoring Load behavior). Present the structured acknowledgment -- feature name, decision count, open questions, constraints. Honor all logged decisions and constraints as active commitments.
- **If not found** → Nudge the user: "Do you have a design document or blueprint for this feature? Or should I work from what we've discussed?" Accept either answer gracefully.
  - If the user provides a document → load and follow it.
  - If proceeding without → all atom guardrails still apply; there is simply no structured blueprint to reference. Work from the verbal requirements in the conversation.

### Step 2: Plan Implementation Order

**With blueprint**: Extract the component list and layer assignments from the context anchor document. Use Level 2 (Components) decisions for layer placement and Level 3 (Interactions) for dependency flow.

**Without blueprint**: Classify the required components into architectural layers using `framework:clean-architecture` and these heuristics:

- **Does it enforce business rules or hold domain state?** → Domain layer (entity, value object, domain service)
- **Does it persist or retrieve data?** → Infrastructure layer. State-changing persistence → Repository (with domain interface). Read-only retrieval → Provider (concrete, no domain interface).
- **Does it orchestrate a use case by coordinating domain + infrastructure?** → Application layer (service)
- **Does it translate external input/output (HTTP, CLI, messages)?** → Interface layer (controller/handler)

Present the proposed layer assignments to the user for approval before proceeding.

In both cases, plan an **inside-out implementation order** that follows the dependency rule:

1. **Domain** -- entities, value objects, domain services, domain events
2. **Infrastructure** -- repositories, external providers, adapters
3. **Application** -- use cases, application services, orchestrators
4. **Interface** -- HTTP controllers, CLI handlers, message consumers

Classify each operation as a **command flow** (state-changing, flows through domain before reaching repositories) or a **query flow** (read-only, may use providers directly), per `framework:clean-architecture` Two Flows.

Present the implementation plan -- ordered component list, layer assignments, flow classifications -- and confirm with the user before writing any code.

After the plan is approved, ask the user to choose a **review mode**:

> "How would you like to review the implementation?"
> 1. **Layer-by-layer** (recommended) -- I'll implement each layer fully, then pause for your review before starting the next. Four review points.
> 2. **Full autonomy** -- I'll implement everything end-to-end and present the complete result. One review point at the end. (If a blueprint exists, still pause on any deviation from the approved design.)
> 3. **Component-by-component** -- I'll pause after each individual component for your feedback. Maximum review points.

Default to **layer-by-layer** if the user does not express a preference.

### Step 3: Implement Per Component

For each component in the planned order, generate **code and tests together** -- tests are not an afterthought.

For every component:

- **Place in the correct architectural layer** per `framework:clean-architecture`. Validate dependency direction -- dependencies point inward, never outward.
- **Apply `framework:clean-code` self-validation** during generation. Run the inline checks: SRP compliance, meaningful naming, low cyclomatic complexity, proper error handling, no magic values, clean function signatures, no dead code, appropriate abstraction level, clear control flow, minimal comments (code should be self-documenting).
- **Write tests** using `framework:test-quality` self-validation.

Conditional checks applied per component:

- **If domain layer** → Apply `framework:domain-driven-design` self-validation.
- **If trust boundary** (HTTP handler, external API call, user input processing, file I/O) → Apply `framework:secure-coding` self-validation.
- **If blueprint exists** → Verify the component fulfills its Level 4 (Contracts) specification. Flag any deviation from the agreed contract.

**Post-Generation Verification** (applies to every component, in all review modes):

After generating each component and before presenting it to the user:

1. Run the **Self-Validation Checklist** from each applicable atom against every function/class in this component. The atoms use imperative STOP-and-verify language -- follow it literally.
2. Run the **Active Anti-Pattern Scan** from each applicable atom. Check every box in the scan list.
3. If violations are found → fix them before presenting. Do not present code you know violates an atom checklist.
4. If judgment calls are flagged (see each atom's Ambiguity Signals) → collect them. Present using `framework:collaborative-judgment` protocol before showing the code. Do not silently resolve.
5. If all checks pass with no flagged judgment calls → present with a brief compliance note (e.g., "All clean-code and DDD checks pass"). Keep it to one line when clean -- only be verbose when reporting violations and fixes.

**Pacing -- follow the user's chosen review mode**:

- **Layer-by-layer**: Implement all components within a layer, then present the full layer (code + tests) for review before moving to the next layer.
- **Full autonomy**: Implement all layers continuously. Present the complete implementation (all code + all tests) at the end. Skip to Step 4 (Cross-Component Verification) after all components are done.
- **Component-by-component**: Present each component with its tests individually. Wait for approval before moving to the next.
- **Exception (all modes)**: If a component requires a significant deviation from the plan (new dependency, changed contract, unexpected complexity), pause immediately and discuss before continuing -- regardless of the chosen review mode.

### Step 4: Cross-Component Verification

This step checks **architectural coherence** -- not code quality (that was verified per-component in Step 3). After all components are implemented:

- **With blueprint**: Verify that interaction flows match the Level 3 (Interactions) design. Every designed interaction should be traceable in the code.
- **Dependency direction**: Verify that all dependencies point inward. No domain imports from infrastructure. No application layer bypassed by controllers calling infrastructure directly.
- **Zero Implementation Rule**: Check that no new components, interactions, or contracts were introduced beyond what was planned in Step 2. If something was added, flag it -- it may be necessary, but it should be a conscious decision, not scope creep.
- **Final security scan**: Apply `framework:secure-coding` across component boundaries. Check that data flowing between components crosses trust boundaries safely.
- **Learnings check**: If `.ai/learnings/review-insights.md` was loaded in Step 1, verify that previously-flagged patterns do not recur in this implementation. If a past insight said "anemic domain models keep appearing" -- check that entities in this implementation have behavior.

### Step 5: Enrich Context

Throughout Steps 3 and 4, use `framework:context-anchoring` Enrich behavior to keep the living document current:

- **Add key files** as they are created -- path, purpose, layer assignment.
- **Capture implementation decisions** -- library choices, pattern selections, deviations from blueprint, trade-offs made.
- **Resolve open questions** -- if questions from the design phase are answered during implementation, log the resolution.
- **If no context document exists** and significant implementation decisions were made → suggest creating one. The decisions are worth preserving for future sessions.

After enriching the context document, recommend a review:

> "The implementation is complete. I recommend running `/review` on the generated code before considering this feature done -- it provides an independent quality assessment against the same atom standards, catches issues the generator may be blind to, and captures learnings for future sessions."
