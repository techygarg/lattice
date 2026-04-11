---
name: code-forge
description: "Generate implementation code from an approved design blueprint or verbal requirements. Composes context anchoring, architecture, clean code, DDD, security, and test quality into an inside-out implementation workflow. Use when moving from design to code, implementing approved contracts, or when the user says 'implement', 'code this', 'build it', 'forge the code', or 'generate the code'."
---

# Code Forge

## Required Skills

Read, apply:

1. `framework:knowledge-priming` -- Load proj context (stack, arch, conventions) so impl matches real proj (always)
2. `framework:context-anchoring` -- Load/find context anchor doc; enrich as impl decisions made (always)
3. `framework:collaborative-judgment` -- Surface real judgment calls w/ structured opts vs silent assume (always)
4. `framework:architecture` -- Layer place, dep direction, struct valid (always)
5. `framework:clean-code` -- Craft rails: SRP, naming, complexity, err handle (always)
6. `framework:domain-driven-design` -- Aggregates, entities, VOs, domain svcs (conditional: only when touch domain folder)
7. `framework:secure-coding` -- Trust bounds, injection prevent, secrets mgmt (conditional: only boundary-cross code)
8. `framework:test-quality` -- AAA struct, isolation, assert quality, naming (always when write tests)

## Workflow

### Step 1: Establish Implementation Context

**Load learnings**: If `.lattice/learnings/review-insights.md` exists, read. Use recent insights inform gen — e.g., learnings say "anemic domain models keep appear," push behavior→entities. Learnings flag "missing input valid on VOs," valid in constructors from start. Patterns from past reviews — use avoid repeat mistakes.

Use `framework:context-anchoring` Doc Discovery check existing context anchor doc for feature impl.

- **If found** → Load (context-anchor Load behavior). Present struct ack -- feature name, decision count, open Qs, constraints. Honor all logged decisions/constraints as active commits.
- **If not found** → Nudge user: "Have design doc/blueprint for feature? Or work from discussed?" Accept either graceful.
  - User provides doc → load, follow.
  - Proceed without → all atom rails still apply; just no struct blueprint ref. Work from verbal reqs in convo.

### Step 2: Plan Implementation Order

**With blueprint**: Extract component list, layer assigns from context anchor doc. Use L2 (Components) decisions for layer place, L3 (Interactions) for dep flow.

**Without blueprint**: Classify req components→arch layers using layer defs from `framework:architecture`. Each component, determine:

- Primary responsibility? (biz rules, data access, coord, external I/O)
- Which layer in loaded arch doc matches responsibility?
- Dep constraints for that layer?

If `framework:architecture` no loaded layer defs (neither defaults nor custom doc resolved), warn: "No arch rules avail. Run `/architecture-refiner` define arch standards. Proceed w/o arch guidance." Continue w/ only remaining atom rails.

Present proposed layer assigns→user for approval before proceed.

Both cases, plan **inside-out impl order** following dep direction from loaded arch doc — start innermost layer (no outward deps), work outward. Each layer's deps should exist when built.

Classify each op per flow patterns in loaded arch doc (e.g., cmd vs query flows, or equiv distinction your arch style).

Present impl plan -- ordered component list, layer assigns, flow classifs -- confirm w/ user before write code.

After plan approved, ask user choose **review mode**:

> "How review impl?"
> 1. **Layer-by-layer** (rec) -- Impl each layer fully, pause for review before next. One review pt/layer.
> 2. **Full autonomy** -- Impl everything end-to-end, present complete result. One review pt at end. (If blueprint exists, still pause any deviation from approved design.)
> 3. **Component-by-component** -- Pause after each individual component for feedback. Max review pts.

Default **layer-by-layer** if user no preference.

### Step 3: Implement Per Component

Each component in planned order, gen **code+tests together** -- tests not afterthought.

Every component:

- **Place correct arch layer** per `framework:architecture`. Valid dep direction follows loaded arch rules.
- **Apply `framework:clean-code` self-valid** during gen. Run inline checks: SRP comply, meaningful naming, low cyclomatic complexity, proper err handle, no magic vals, clean func sigs, no dead code, appropriate abstract level, clear control flow, minimal comments (code self-doc).
- **Write tests** using `framework:test-quality` self-valid.

Conditional checks per component:

- **If domain layer** → Apply `framework:domain-driven-design` self-valid.
- **If trust boundary** (HTTP handler, external API call, user input process, file I/O) → Apply `framework:secure-coding` self-valid.
- **If blueprint exists** → Verify component fulfills L4 (Contracts) spec. Flag any deviation from agreed contract.

**Post-Gen Verification** (applies every component, all review modes):

After gen each component, before present→user:

1. Run **Self-Valid Checklist** from each applicable atom against every func/class this component. Atoms use imperative STOP-verify lang -- follow literally.
2. Run **Active Anti-Pattern Scan** from each applicable atom. Check every box scan list.
3. Violations found → fix before present. Don't present code you know violates atom checklist.
4. Judgment calls flagged (see each atom's Ambiguity Signals) → collect. Present using `framework:collaborative-judgment` protocol before show code. Don't silent resolve.
5. All checks pass, no flagged judgment calls → present w/ brief comply note (e.g., "All clean-code, DDD checks pass"). Keep one line when clean -- only verbose when report violations, fixes.

**Pacing -- follow user's chosen review mode**:

- **Layer-by-layer**: Impl all components within layer, present full layer (code+tests) for review before next layer.
- **Full autonomy**: Impl all layers continuous. Present complete impl (all code+tests) at end. Skip→Step 4 (Cross-Component Verif) after all components done.
- **Component-by-component**: Present each component w/ tests individually. Wait approval before next.
- **Exception (all modes)**: Component needs significant deviation from plan (new dep, changed contract, unexpected complexity), pause immediately, discuss before continue -- regardless chosen review mode.

### Step 4: Cross-Component Verification

Step checks **arch coherence** -- not code quality (verified per-component Step 3). After all components impl:

- **With blueprint**: Verify interaction flows match L3 (Interactions) design. Every designed interaction traceable in code.
- **Dep direction**: Apply `framework:architecture` verif across all components — verify inter-component dep direction follows loaded arch rules. No layer import from layer not permitted depend.
- **Zero Impl Rule**: Check no new components, interactions, contracts intro beyond planned Step 2. Something added, flag -- may be necessary, but should be conscious decision, not scope creep.
- **Final security scan**: Apply `framework:secure-coding` across component boundaries. Check data flowing between components crosses trust bounds safely.
- **Learnings check**: If `.lattice/learnings/review-insights.md` loaded Step 1, verify previously-flagged patterns not recur this impl. Past insight said "anemic domain models keep appear" -- check entities this impl have behavior.

### Step 5: Enrich Context

Throughout Steps 3-4, use `framework:context-anchoring` Enrich behavior keep living doc current:

- **Add key files** as created -- path, purpose, layer assign.
- **Capture impl decisions** -- lib choices, pattern selects, deviations from blueprint, tradeoffs made.
- **Resolve open Qs** -- Qs from design phase answered during impl, log resolution.
- **If no context doc exists**, significant impl decisions made → suggest create. Decisions worth preserve future sessions.

After enrich context doc, recommend review:

> "Impl complete. Recommend run `/review` on gen code before consider feature done -- provides independent quality assess against same atom standards, catches issues generator may blind to, captures learnings future sessions."