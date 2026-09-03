---
name: domain-driven-design
description: "Apply DDD tactical patterns when working with domain code, and validate proposed domain models before approval (design mode). Enforces aggregate design, value objects over primitives, entity identity rules, and bounded context boundaries. Use when creating or modifying domain models, designing aggregates, working in the domain layer, or when the user mentions 'domain', 'aggregate', 'value object', 'entity', 'bounded context', or 'DDD'."
---
# Domain-Driven Design

## Config Resolution

The skill supports project-custom principles. Resolution:

1. Look for `.lattice/config.yaml` in the repo root.
2. If found, check `paths.ddd_principles` for a custom doc path.
3. If a custom document exists at that path, read it and check its YAML frontmatter `mode`:
   - **`mode: override`**: the custom doc has full precedence.
     Use it instead of the embedded default. It must be comprehensive -- sole reference.
   - **`mode: overlay`** (or no mode): read the embedded `./references/defaults.md` first, then apply
     the custom doc on top. A custom section replaces the matching default
     section (matched by heading); new sections append after the defaults.
4. If a custom path is configured but no document exists at it → tell the user which configured path is missing, then read `./references/defaults.md`.
5. If there is no config file or no `paths.ddd_principles` key → read `./references/defaults.md`.
6. **Language adaptation**: if `paths.language_idioms` is set in the config and the document exists, read its **"Type System & Object Model"** section and adapt entity, value object, and aggregate implementation patterns to language constructs (e.g., struct vs class, trait vs interface, data class vs record). Language idioms take precedence over pseudocode defaults.

## Self-Validation Checklist

**STOP after generating each component.** Verify ALL checks before proceeding. If any check fails, fix before presenting. If a check is a judgment call with multiple valid approaches (see Ambiguity Signals), flag it — present options and reasoning rather than silently choosing; if `framework:collaborative-judgment` is loaded, use its presentation format.

1. **ENTITY VS VALUE OBJECT**: For each domain object — does the business track individual instances over time? Yes → entity with identity. No → value object, immutable and self-validating.
2. **AGGREGATE BOUNDARY**: Does a transactional invariant require this object inside the aggregate? If not → reference it from a separate aggregate by ID.
3. **RICH BEHAVIOR**: Does the entity have methods that enforce business rules, guard state transitions, raise events? If the entity is just a data holder → move logic from services into the entity.
4. **VALUE OBJECT COVERAGE**: Scan for primitives that should be value objects — string emails, number amounts, raw UUIDs as identifiers → wrap in a validating value object.
5. **AGGREGATE COHESION**: List the business rules the root enforces. Does every internal entity participate in at least one invariant? If not → it belongs in its own aggregate.
6. **DOMAIN EVENTS**: Should a domain event be raised — a state transition another aggregate reacts to, a change triggering notification, an audit/compliance requirement? Do not raise events for internal changes nothing reacts to.
7. **DOMAIN SERVICE**: Does stateless logic spanning multiple entities belong in a domain service rather than an application service? Keep I/O and infrastructure calls out of it.
8. **FACTORY**: Is complex aggregate creation encapsulated behind a factory method (`Order.create(...)`) or a standalone factory class? Are initial creation and reconstitution from persistence handled separately?

All checks pass → state "Passes domain-driven-design. [next step]."

## Active Anti-Pattern Scan

After verifying the checklist above, scan the output for these specific anti-patterns. If you find any, fix before presenting.

- [ ] **Anemic Domain Model**: Entity is a getter/setter data holder; all logic lives in services → move business rules into entities and value objects
- [ ] **Primitive Obsession**: Raw string for email, number for money, UUID for ID → wrap in a validating value object with behavior
- [ ] **God Aggregate**: Aggregate has many entities, loads slowly, high contention → decompose; keep only what shares a transactional invariant
- [ ] **Cross-Aggregate Transaction**: Service updates two aggregates in one transaction → use domain events and eventual consistency
- [ ] **Leaking Domain Logic**: Business rule in a controller, application service, or infrastructure → extract into a domain object or domain service
- [ ] **Misidentified Entity/Value Object**: Entity without a lifecycle, or value object with tracked identity → apply the identity test

## Ambiguity Signals

These checks often have multiple valid outcomes. When you encounter one, present the options rather than silently choosing. If `framework:collaborative-judgment` is loaded, use its presentation format.

- **Aggregate Boundary Size**: Small aggregate (more events, eventual consistency) vs large aggregate (simple transaction, immediate consistency). Neither is inherently correct — it depends on contention patterns and invariant scope.
- **Entity vs Value Object**: Some concepts (like `Address` or `Money`) may or may not need identity depending on domain complexity. Apply the identity test, but acknowledge when borderline.
- **Domain Service vs Entity Method**: Logic spanning multiple entities could live in a domain service or be a method on the primary entity. The choice depends on which entity "owns" the invariant.
- **Object Creation Pattern**: Factory method on the aggregate root, standalone factory class, builder pattern, or plain constructor — depends on assembly complexity and team convention. Don't prescribe a pattern; ask which approach the team prefers.

## Scope Statement

This skill operates within a single repo, single bounded context (e.g., one API -- Order, User, Pricing). It covers tactical DDD patterns only -- not strategic DDD (no context maps, no microservice topology, no bounded-context integration).

If a task appears to span multiple bounded contexts (e.g., an Order feature calling Shipping logic), flag before proceeding: "This task touches [Context A] and [Context B]. Cross-context integration is strategic DDD — outside this skill's scope. Would you like to scope to one context, or proceed knowing cross-context coordination is your responsibility?"

## Design Mode

When invoked during design — no code is being written; a planning molecule is validating a proposed domain model — apply the same checks as a forward-looking validation:

1. Take the proposed artifact (aggregate list, entity/value object classification, event set, or contract types) as the unit of validation.
2. Run the **Self-Validation Checklist** and **Active Anti-Pattern Scan** against it — before the model is presented for user approval.
3. Report violations as concrete findings on the model ("Order aggregates both pricing and fulfillment state — split by transactional invariant"), not generic advice. Resolve them through the design.
4. **STOP:** do not skip evaluation because no code exists yet — the proposed model is what gets validated.

See `./references/defaults.md` for aggregate design rules, entity/value object/domain service/domain event/repository/creation patterns with code examples, inline anti-pattern warnings, and a decomposition guide.
