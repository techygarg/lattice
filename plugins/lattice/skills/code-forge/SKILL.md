---
name: code-forge
description: "Generate implementation code from an approved design blueprint or verbal requirements. Composes context anchoring, architecture, clean code, DDD, security, and test quality into an inside-out implementation workflow. Use when moving from design to code, implementing approved contracts, or when the user says 'implement', 'code this', 'build it', 'forge the code', or 'generate the code'."
---

# Code Forge

## Required Skills

Read and apply:

1. `framework:knowledge-priming` -- Load project context (stack, architecture, conventions) so implementation matches the real project. (always)
2. `framework:context-anchoring` -- Find and load the feature's context anchor doc; enrich it as implementation decisions are made (Create / Load / Enrich behaviors). (always)
3. `framework:learning-harvest` -- Load prior operational learnings to inform implementation at session start; harvest new ones at session end. (always)
4. `framework:collaborative-judgment` -- Surface genuine judgment calls as structured options instead of silently assuming. (always)
5. `framework:architecture` -- Layer placement, dependency direction, structural validation. (always)
6. `framework:clean-code` -- Craft guardrails: SRP, naming, complexity, error handling. (always)
7. `framework:domain-driven-design` -- Aggregates, entities, value objects, domain services. (conditional: domain-layer components only)
8. `framework:secure-coding` -- Trust bounds, injection prevention, secrets handling. (conditional: trust-boundary code only)
9. `framework:test-quality` -- AAA structure, isolation, assertion quality, naming. (always when writing tests)

## Workflow

### Step 1: Establish Implementation Context

1. Run `framework:learning-harvest` Load behavior. Focus hint: "implementation session — focus: implementation craft, quality signals, reliability".
2. Run `framework:context-anchoring` Document Discovery: scan the context base directory (per the atom's Config Resolution) for an existing anchor doc covering this feature's implementation.
   - **Found** → Load behavior. Present the structured acknowledgment: feature name, **status**, decision count, open questions, constraints. **STOP:** Honor every logged decision and constraint as an active commitment.
   - **Not found** → ask the user: "Is there a design doc or blueprint for this feature, or do we work from what we've discussed?" Accept either answer gracefully:
     - Doc provided → load it and follow it.
     - Proceed without → all atom rails still apply; there is simply no approved design doc to reference. Work from the verbal requirements in conversation.

**Design completeness check** — run both gates before Step 2 (no context doc exists → skip both, proceed as **"Without approved design"**):

**Check 1 — status:** Read the context doc frontmatter `status`.
- `approved` → pass.
- `complete` → this feature was already implemented. If the current request is new scope, recommend `/design-blueprint` for a fresh design pass; if the user confirms proceeding on the existing design, continue as **"With approved design"** (Check 2 still applies).
- Anything else (including `draft` or a missing field) → **STOP:** "Context doc not approved (`status: [value]`). Run `/design-blueprint` first. Proceed anyway?" On confirmation → log it in the Decisions Log and continue as **"Without approved design"**.

**Check 2 — levels present:** Scan the body for `## Design: Level 3` and `## Design: Level 4`.
- Both present → pass.
- Either missing → **STOP:** "Missing [Level 3 / Level 4 / both]. Proceed anyway?" On confirmation → log the absent levels in the Decisions Log and treat them as gaps to fill during implementation.

Both pass → proceed as **"With approved design"**.

### Step 2: Plan Implementation Order

**With approved design**: extract the component list and layer assignments from the context anchor doc. Use the Level 2 (Components) decisions for layer placement and Level 3 (Interactions) for dependency flow.

**Without approved design**: classify the required components into architecture layers using the layer definitions from `framework:architecture`. For each component determine:

- What is its primary responsibility? (business rules, data access, coordination, external I/O)
- Which layer in the loaded architecture doc matches that responsibility?
- What dependency constraints apply to that layer?

If `framework:architecture` resolved no layer definitions (neither defaults nor a custom doc), surface it: "No architecture rules available. Run `/architecture-refiner` to define your architecture standards. Proceeding without architecture guidance." Continue with the remaining atom rails.

Present the proposed layer assignments to the user for approval before proceeding.

In both cases, plan an **inside-out implementation order** following the dependency direction from the loaded architecture doc — start at the innermost layer (no outward dependencies) and work outward, so each layer's dependencies already exist when it is built.

Classify each operation per the flow patterns in the loaded architecture doc (e.g., command vs query flows, or the equivalent distinction in your architecture style).

Present the implementation plan — ordered component list, layer assignments, flow classifications — and confirm with the user before writing code. If the user rejects or corrects the plan, revise and re-present it. **STOP:** Never start coding on an unagreed plan.

After the plan is approved, ask the user to choose a **review mode**:

> "How should we review the implementation?"
> 1. **Layer-by-layer** (recommended) — implement each layer fully, pause for review before the next. One review point per layer.
> 2. **Full autonomy** — implement everything end-to-end, present the complete result. One review point at the end. (If a blueprint exists, still pause on any deviation from the approved design.)
> 3. **Component-by-component** — pause after each individual component for feedback. Maximum review points.

Default to **layer-by-layer** if the user expresses no preference.

### Step 3: Implement Per Component

For each component in planned order, generate **code and tests together** — tests are not an afterthought.

Every component:

- **Prefer the simpler path first.** Before writing custom code: does a stdlib function, platform built-in, or existing dependency already cover this? If yes, use it. Can it be expressed in shorter code? Use that. Write custom code only when the simpler options genuinely fall short.
- **Place in the correct architecture layer** per `framework:architecture`; dependency direction follows the loaded architecture rules.
- **Apply `framework:clean-code` self-validation** during generation. Inline checks: SRP compliance, meaningful naming, low cyclomatic complexity, proper error handling, no magic values, clean function signatures, no dead code, appropriate abstraction level, clear control flow, minimal comments (the code documents itself).
- **Write tests** using `framework:test-quality` self-validation.
- **Run what you wrote**, where the environment allows: execute the component's tests before presenting and include the result in the compliance note. If execution is not available, say so — never imply tests passed when they were only written.

Conditional checks per component:

- **Domain layer** → apply `framework:domain-driven-design` self-validation.
- **Trust boundary** (HTTP handler, external API call, user-input processing, file I/O) → apply `framework:secure-coding` self-validation.
- **Blueprint exists AND Level 4 was confirmed present in Step 1** → verify the component fulfills its L4 (Contracts) specification; flag any deviation from the agreed contract. If the user proceeded without L4 (Check 2 failed), skip this check — there are no contracts to verify against.

**Post-generation verification** (every component, all review modes):

After generating each component, before presenting it to the user:

1. Run the **Self-Validation Checklist** from each applicable atom against every function/class in the component. Atoms use imperative STOP-verify language — follow it literally.
2. Run the **Active Anti-Pattern Scan** from each applicable atom; check every box on the scan list.
3. Violations found → fix before presenting.
4. Judgment calls flagged (see each atom's Ambiguity Signals) → collect them and present via the `framework:collaborative-judgment` protocol before showing code. Never silently resolve.
5. All checks pass with no flagged judgment calls → present with a brief compliance note ("All clean-code, DDD checks pass") — one line when clean; verbose only when reporting violations and fixes.

**Pacing — follow the user's chosen review mode:**

- **Layer-by-layer**: implement all components within a layer, present the full layer (code + tests) for review before starting the next layer.
- **Full autonomy**: implement all layers continuously; present the complete implementation (all code + tests) at the end, then skip to Step 4.
- **Component-by-component**: present each component with its tests individually; wait for approval before the next.
- **Exception (all modes)**: a component needs a significant deviation from the plan (new dependency, changed contract, unexpected complexity) → **STOP:** pause immediately and discuss before continuing, regardless of the chosen review mode.

### Step 4: Cross-Component Verification

These checks verify **architecture coherence**, not code quality (already verified per-component in Step 3). After all components are implemented:

- **With blueprint**: verify interaction flows match the L3 (Interactions) design — every designed interaction is traceable in the code.
- **Dependency direction**: apply `framework:architecture` verification across all components — inter-component dependency direction follows the loaded architecture rules; no layer imports from a layer it is not permitted to depend on.
- **Zero Implementation Rule**: check that no new components, interactions, or contracts were introduced beyond the Step 2 plan. Something added → flag it — it may be necessary, but it must be a conscious decision, not scope creep.
- **Final security scan**: apply `framework:secure-coding` across component boundaries — data flowing between components crosses trust bounds safely.
- **Learnings check**: if operational learnings were loaded in Step 1, verify that previously-flagged patterns did not recur in this implementation.

### Step 5: Enrich Context

Throughout Steps 3-4, use `framework:context-anchoring` Enrich behavior to keep the living doc current:

- **Add key files** as created — path + role in the doc's Key Files table (skip a path already listed).
- **Capture implementation decisions** — library choices, pattern selections, deviations from the blueprint, tradeoffs made, as Decisions Log entries (decision, reasoning, alternatives considered).
- **Resolve open questions** — when a design-phase question gets answered during implementation, log the answer as a decision entry AND remove the question from the Open Questions list.
- **No context doc exists and significant implementation decisions were made** → suggest creating one.

**Harvest learnings**: run `framework:learning-harvest` Harvest behavior. Session context: "implementation session — code generation from design contracts". Synthesize and propose cross-cutting patterns from this session — implementation gotchas, design-to-reality gaps, library/framework lessons. The user confirms what enters the document. **STOP: run this before closing the feature lifecycle below.**

**Close the feature lifecycle**: write `status: complete` into the context doc frontmatter. **STOP: required discrete file edit.**

**STOP: do not write status to `requirement_doc`.** The requirement's status belongs to whoever manages it — a human, or an external system it may live in. This molecule manages only its own context doc.

After enriching the context doc, recommend review:

> "Implementation complete. Recommend running `/review` on the generated code before considering the feature done — it provides an independent quality assessment against the same atom standards, catches issues the generator may be blind to, and captures learnings for future sessions."
