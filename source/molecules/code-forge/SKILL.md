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

**Where this workflow overrides its atoms** — on these points the text here wins over the atom's own wording:

- **Confirmations** (context-anchoring): Load an exact match for the feature the user named without asking. Write Enrich entries — key files, implementation decisions, resolved questions — without a separate confirmation, and say what was recorded when presenting the work.
- **Requirement doc** (context-anchoring Load): an external requirement doc that no connector can reach → use the constraints recorded in the context doc's `## Constraints`; ask for a paste only when none are recorded.
- **Learnings queue** (learning-harvest): after the last layer, do not surface the queue — the Step 5 Harvest follows immediately.
- **Re-approval** (context-anchoring's "update the doc and re-approve"): for a small design change (Step 3), the user's agreement in this session is the re-approval — `status` stays `approved`. A bigger change goes to design-blueprint.

<!-- include: additional-instructions -->

## Workflow

### Step 1: Establish Implementation Context

1. Run `framework:learning-harvest` Load behavior. Focus hint: "implementation session — focus: implementation craft, quality signals, reliability".
2. Run `framework:context-anchoring` Document Discovery: scan the context base directory (per the atom's Config Resolution) for an existing anchor doc covering this feature's implementation.
   - **Found** → Load behavior. Present the structured acknowledgment: feature name, **status**, decision count, open questions, constraints. **STOP:** Honor every logged decision and constraint as an active commitment.
   - **Not found** → do not stop to ask. Say: "No context doc found — working from what we've discussed. Point me to a design doc or blueprint if one exists." Continue as **"Without approved design"**: all atom rails still apply; there is simply no approved design doc to reference. The user points to a doc → load it and follow it.

**Design completeness check** — run both checks before Step 2 and ask at most once (no context doc exists → skip both, proceed as **"Without approved design"**):

**Check 1 — status:** Read the context doc frontmatter `status`.
- `approved` → pass.
- `complete` → this feature was already implemented and its doc is closed. New scope → recommend `/design-blueprint`, which designs it in a new context doc. A follow-up on the existing design that the user confirms → continue as **"With approved design"** (Check 2 still applies).
- Anything else (including `draft` or a missing field) → fail.

**Check 2 — levels present:** Scan the body for `## Design: Level 3` and `## Design: Level 4`. A one-line placeholder section (`Not walked — …` or `Taken from …`) counts as present; a section marked stale counts as missing.
- Both present → pass.
- Either missing → fail.

Either check failed → **STOP**, one question naming everything that failed: "Context doc not approved (`status: [value]`) / missing [Level 3 / Level 4 / both]. Run `/design-blueprint` first, or proceed anyway?" On confirmation → log the status and the absent levels in the Decisions Log. Check 1 failed → continue as **"Without approved design"**. Only Check 2 failed → continue as **"With approved design"** and treat the absent levels as gaps to fill during implementation.

Both pass → proceed as **"With approved design"**.

### Step 2: Plan Implementation Order

**Resume first**: the context doc's Key Files table already lists components of this design → an earlier session built them. Confirm the files exist, mark those components built in the plan, and start at the first unbuilt one. A `[Reopen]` row in the Decisions Log → the design changed after some components were built; check each built component against the reopened level and add the needed changes to the plan. **STOP:** Never regenerate a built component unless the user asks.

**With approved design**: extract the component list and layer assignments from the context anchor doc. Use the Level 2 (Components) decisions for layer placement and Level 3 (Interactions) for dependency flow. A level that is a one-line placeholder carries no design — derive that part as under "Without approved design".

**Without approved design**: explore the codebase first and map each required component to the existing module it extends or modifies, or mark it `new`. Start from any level sections the context doc does have. Then classify the components into architecture layers using the layer definitions from `framework:architecture`. For each component determine:

- What is its primary responsibility? (business rules, data access, coordination, external I/O)
- Which layer in the loaded architecture doc matches that responsibility?
- What dependency constraints apply to that layer?

If `framework:architecture` resolved no layer definitions (neither defaults nor a custom doc), surface it: "No architecture rules available. Run `/architecture-refiner` to define your architecture standards. Proceeding without architecture guidance." Continue with the remaining atom rails.

**Architecture fit**: no `paths.architecture` document is configured and the existing code is not organized in the default layers → follow the code. Place components in the existing structure, say so in the plan ("No architecture document configured — following the existing structure, not the clean-architecture defaults. Run `/architecture-refiner` to record it."), and apply the architecture checks in Steps 3–4 only where they do not contradict that structure. A `[Level 2]` decision in the context doc already settled this → follow it. An empty repository has nothing to follow — the defaults apply.

In both cases, plan an **inside-out implementation order** following the dependency direction from the loaded architecture doc (or of the existing structure, when the plan follows the code) — start at the innermost layer (no outward dependencies) and work outward, so each layer's dependencies already exist when it is built.

Classify each operation per the flow patterns in the loaded architecture doc (e.g., command vs query flows, or the equivalent distinction in your architecture style).

Present the implementation plan — ordered component list, layer assignments, flow classifications, and any components already built — and confirm with the user before writing code. If the user rejects or corrects the plan, revise and re-present it. **STOP:** Never start coding on an unagreed plan.

In the same message as the plan, ask the user to choose a **review mode**:

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
- **Write tests** using `framework:test-quality` self-validation. When a requirement doc is readable, each acceptance criterion this component fulfils gets a test named for it.
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
  - **Small design change** — it stays inside Level 4 (a signature, type, field, or error case of an existing interface) and Levels 2–3 still hold → once the user agrees, update the affected `## Design: Level 4` text in place (and the Design Summary where it repeats that contract) so the doc matches the code, log it as a `[Level 4]` decision with the reason, leave `status` as `approved`, and continue.
  - **Bigger design change** — it adds, removes, or re-scopes a component or interaction (Levels 2–3), or replaces an interface → do not edit the design here; design-blueprint owns that change. Record the finding under the context doc's `## Open Questions` as `[for design] …` and tell the user: "This changes the approved design. Run `/design-blueprint` to reopen Level [N], then `/code-forge` to continue." Stop work on the affected components; components the change does not touch may continue.
  - Any other deviation (new dependency, unexpected complexity) → agree it with the user, log it as a decision, and continue.

**Record as you go** (all review modes): after each layer — each component in component-by-component mode — use `framework:context-anchoring` Enrich before starting the next, so an interrupted session leaves the doc current:

- **Add key files** as created — path + role in the doc's Key Files table (skip a path already listed).
- **Capture implementation decisions** — library choices, pattern selections, agreed deviations from the plan, tradeoffs made, as Decisions Log entries (decision, reasoning, alternatives considered).
- **Resolve open questions** — when a design-phase question gets answered during implementation, log the answer as a decision entry AND remove the question from the Open Questions list.

### Step 4: Cross-Component Verification

These checks verify **architecture coherence**, not code quality (already verified per-component in Step 3). After all components are implemented:

- **With blueprint**: verify interaction flows match the L3 (Interactions) design — every designed interaction is traceable in the code. Skip when Level 3 is a placeholder.
- **Acceptance criteria** (a requirement doc is linked, or the user pointed to one, and it is readable): map every acceptance criterion to a test that exercises it — or, where it cannot be tested automatically, to the code that fulfils it. Check a criterion the design overrode (a `Design override` line in the requirement doc's `## Links` that names this context doc, or names none) against the override. A criterion with neither → add the missing test or code, or tell the user it is uncovered. Requirement doc unreadable or unreachable → say the check was skipped. **STOP:** Never report the feature done with an uncovered criterion the user has not accepted.
- **Dependency direction**: apply `framework:architecture` verification across all components — inter-component dependency direction follows the loaded architecture rules; no layer imports from a layer it is not permitted to depend on.
- **Zero Implementation Rule**: check that no new components, interactions, or contracts were introduced beyond the Step 2 plan. Something added → flag it — it may be necessary, but it must be a conscious decision, not scope creep.
- **Final security scan**: apply `framework:secure-coding` across component boundaries — data flowing between components crosses trust bounds safely.
- **Learnings check**: if operational learnings were loaded in Step 1, verify that previously-flagged patterns did not recur in this implementation.

### Step 5: Enrich Context

Use `framework:context-anchoring` Enrich to write anything from Step 3's "Record as you go" that is still missing — key files, implementation decisions, resolved open questions. No context doc exists and significant implementation decisions were made → suggest creating one.

**Harvest learnings**: run `framework:learning-harvest` Harvest behavior. Session context: "implementation session — code generation from design contracts". Synthesize and propose cross-cutting patterns from this session — implementation gotchas, design-to-reality gaps, library/framework lessons. The user confirms what enters the document. **STOP: run this before closing the feature lifecycle below.**

**Close the feature lifecycle** (when a context doc exists): write `status: complete` into the context doc frontmatter once every planned component is implemented and Step 4 left nothing unresolved. **STOP: required discrete file edit.** Work remains — unbuilt components, failing tests, a change the user asked for → leave `status` unchanged and list what remains.

**STOP: do not write status to `requirement_doc`.** The requirement's status belongs to whoever manages it — a human, or an external system it may live in. This molecule manages only its own context doc.

After enriching the context doc, recommend review:

> "Implementation complete. Recommend running `/review` on the generated code before considering the feature done — it provides an independent quality assessment against the same atom standards, catches issues the generator may be blind to, and captures learnings for future sessions."
