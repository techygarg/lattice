---
name: domain-driven-design
description: "Apply DDD tactical patterns when working with domain code. Enforces aggregate design, value objects over primitives, entity identity rules, and bounded context boundaries. Use when creating or modifying domain models, designing aggregates, working in the domain layer, or when the user mentions 'domain', 'aggregate', 'value object', 'entity', 'bounded context', or 'DDD'."
---
# Domain-Driven Design

## Config Resolution

Skill support project-custom. Resolution:

1. Look `.lattice/config.yaml` repo root
2. If found, check `paths.ddd_principles` custom doc path
3. If custom path exist, read doc, check YAML frontmatter `mode`:
   - **`mode: override`** (or no mode): Custom doc full precedence.
     Use instead embed default. Must comprehensive -- sole reference.
   - **`mode: overlay`**: Read embed `./references/defaults.md` first, then apply
     custom doc section on top. Section custom replace match
     section default (match by heading). New section append after default.
4. If no config, no path, or path not found, read `./references/defaults.md`
5. **Language adaptation**: If `paths.language_idioms` exist in config, read **"Type System & Object Model"** section and adapt entity, value object, and aggregate implementation patterns to language constructs (e.g., struct vs class, trait vs interface, data class vs record). Language idioms take precedence over pseudocode defaults.

Default ship with skill, represent opinionated best practice.
Work out box any project. Override only when team have
specific standard differ from default.

## Self-Validation Checklist

STOP after generate each component. Verify ALL follow before proceed. If check clearly fail, fix code before present. If check judgment call with multiple valid approach (see Ambiguity Signal), flag — present option and reasoning rather than silent choose.

1. **ENTITY VS VALUE OBJECT**: Each domain object — business track individual instance over time? Yes → entity with identity. No → value object with immutable and self-validate.
2. **AGGREGATE BOUNDARY**: Transactional invariant require this object inside aggregate? If not → separate aggregate reference by ID.
3. **RICH BEHAVIOR**: Entity have method enforce business rule, guard state transition, raise event? If entity just data holder → move logic from service into entity.
4. **VALUE OBJECT COVERAGE**: Scan primitive type should be value object — string email, number amount, raw UUID as identifier → wrap value object with validate.
5. **AGGREGATE COHESION**: List business rule root enforce. Each internal entity participate least one invariant? If not → belong own aggregate.
6. **DOMAIN EVENTS**: Domain event raise for state transition other aggregate react, change trigger notification, audit/compliance requirement? Don't raise event internal change nothing react.
7. **DOMAIN SERVICE**: Stateless logic span multiple entity place domain service rather than application service? Avoid I/O and infrastructure call?
8. **FACTORY**: Complex aggregate creation encapsulate factory method (`Order.create(...)`) or standalone factory class? Initial creation and reconstitution from persistence handle separate?

## Active Anti-Pattern Scan

After verify checklist above, scan output these specific anti-pattern. If find any, fix before present code.

- [ ] **Anemic Domain Model**: Entity data holder only getter/setter; all logic live service → move business rule into entity and value object
- [ ] **Primitive Obsession**: Raw string for email, number for money, UUID for ID → wrap value object with validate and behavior
- [ ] **God Aggregate**: Aggregate many entity, slow load, high contention → decompose keep only what share transactional invariant
- [ ] **Cross-Aggregate Transaction**: Service update two aggregate one transaction → use domain event eventual consistency
- [ ] **Leaking Domain Logic**: Business rule in controller, application service, or infrastructure → extract domain object or domain service
- [ ] **Misidentified Entity/Value Object**: Entity without lifecycle, or value object with identity track → apply identity test

## Ambiguity Signals

These check often have multiple valid outcome. When encounter, present option rather than silent choose.

- **Aggregate Boundary Size**: Small aggregate (more event, eventual consistency) vs large aggregate (simple transaction, immediate consistency). Neither inherent correct — depend contention pattern and invariant scope.
- **Entity vs Value Object**: Some concept (like `Address` or `Money`) may or may not need identity depend domain complexity. Apply identity test, but acknowledge when borderline.
- **Domain Service vs Entity Method**: Logic span multiple entity could live domain service or be method on primary entity. Choice depend which entity "own" invariant.
- **Object Creation Pattern**: Factory method on aggregate root, standalone factory class, builder pattern, or plain constructor — depend assembly complexity and team convention. Don't prescribe pattern; ask which approach team prefer.

## Scope Statement

Skill operate within single repo, single bounded context (e.g., one API -- Order, User, Pricing). Cover tactical DDD pattern only -- not strategic DDD (no context map, no microservice topology, no bounded context integration).

If task appear span multiple bounded context (e.g., Order feature call Shipping logic), flag before proceed: "This task touches [Context A] and [Context B]. Cross-context integration is strategic DDD — outside this skill's scope. Would you like to scope to one context, or proceed knowing cross-context coordination is your responsibility?"

`framework:architecture` provide structural envelope -- where code live, which layer exist, which direction dependency flow. This skill define how craft domain *within* envelope: rich model, invariant, aggregate boundary, ubiquitous language.

## Core Principle

Domain model authoritative expression business rule. Rich domain object encapsulate behavior and enforce invariant. Code speak ubiquitous language business.

If business rule exist, should expressible through domain model -- not scatter across controller, application service, or infrastructure. Entity only data holder with external service do all work is anemic model, primary anti-pattern this skill prevent.

See `./references/defaults.md` for aggregate design rules, entity/value object/domain service/domain event/repository/creation patterns with code examples, inline anti-pattern warnings, and decomposition guide.