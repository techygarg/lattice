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

## Scope Statement

Skill operate within single repo, single bounded context (e.g., one API -- Order, User, Pricing). Cover tactical DDD pattern only -- not strategic DDD (no context map, no microservice topology, no bounded context integration).

If task appear span multiple bounded context (e.g., Order feature call Shipping logic), flag before proceed: "This touch [Context A] and [Context B]. Cross-context integration strategic DDD — outside skill scope. Want scope one context, or proceed knowing cross-context coordination your responsibility?"

`framework:architecture` provide structural envelope -- where code live, which layer exist, which direction dependency flow. This skill define how craft domain *within* envelope: rich model, invariant, aggregate boundary, ubiquitous language.

## Core Principle

Domain model authoritative expression business rule. Rich domain object encapsulate behavior and enforce invariant. Code speak ubiquitous language business.

If business rule exist, should expressible through domain model -- not scatter across controller, application service, or infrastructure. Entity only data holder with external service do all work is anemic model, primary anti-pattern this skill prevent.

## The Aggregate Rule

Single governing principle make DDD work -- equivalent Dependency Rule Clean Architecture:

**"Design around invariant, not relationship."**

Aggregate **consistency boundary** -- set object MUST immediately consistent within single transaction. Not convenience grouping related thing. Rules:

1. **Only aggregate root accessible from outside.** External code never reach past root manipulate internal entity.
2. **Reference other aggregate by identity (ID), never by object reference.** Object reference create hidden coupling and expand transaction scope.
3. **One transaction per aggregate.** If business operation need two aggregate update atomic, either boundary wrong or need domain event eventual consistency.
4. **Start small.** Begin root + value object. Add internal entity only when transactional invariant force inside. If debate whether something belong, it not.

See `./references/defaults.md` full aggregate design framework with code example, decomposition heuristic, before/after pseudocode.

## Tactical Patterns

Each pattern: what, why, key rule. See `./references/defaults.md` deep guidance and code example.

### Aggregate

Consistency boundary. Root access only. Reference by ID. One transaction. Every internal entity must participate least one invariant enforce by root -- if not, belong own aggregate.

### Entity

Have identity persist through state change. Equality by identity, not attribute. Must have behavior -- method enforce business rule, guard state transition, raise event. Entity only getter/setter is anemic model.

### Value Object

Define by attribute, not identity. Immutable. Self-validate -- invalid state unrepresentable. Use instead primitive: Money not number, Email not string, OrderId not UUID. See `./references/defaults.md` common value object catalog.

### Domain Service

Stateless business logic span multiple entity or value object with no natural home any single one. Pure domain computation -- no I/O, no infrastructure call. Not confuse application service, which orchestrate use case and coordinate infrastructure.

### Domain Event

Something happen domain that domain expert care. Name past tense (OrderPlaced, PaymentReceived). Carry data needed describe what happen (aggregate ID, relevant value, timestamp). Use cross-aggregate coordination and eventual consistency. Not event sourcing -- aggregate persist through repository.

### Repository

One per aggregate root, not per entity. Interface define domain layer, implementation infrastructure. Collection-like semantic (save, findById, remove). Return fully-constitute aggregate, not partial object or DTO.

**Repository for command (state-change) operation only.** Read-only query belong Provider (see `framework:architecture` query flow pattern). Provider concrete infrastructure class no domain-layer interface -- return DAO, not domain object. Not conflate Repository and Provider: Repository protect invariant through domain object; Provider serve read efficient bypass domain construction.

### Factory

Encapsulate complex aggregate creation. Two purpose: initial creation (enforce creation invariant) and reconstitution from persistence. Simple case use factory method aggregate root (`Order.create(...)`). Complex case involve multiple source use standalone factory class.

## Design Decision Framework

When make domain modeling decision, ask:

1. **Aggregate boundary**: "What must consistent within single transaction?" -- not "what related what." If unsure → start separate, merge only if invariant force.
2. **Entity vs Value Object**: Business track individual instance over time? Yes → entity. No → value object.
3. **Domain Service vs Entity Method**: Logic belong one entity? → put there. Span multiple entity? → domain service. Involve I/O? → application service.
4. **Domain Events**: Other aggregate, external system, or audit trail react? Yes → raise event. No → skip.

## Decomposition Signals

Recognize when aggregate grow too large:

- **More than ~3-5 internal entity** → not all share invariant with root
- **Multiple unrelated invariant** → likely two aggregate merge
- **Root method only touch subset** internal → subset may own aggregate
- **"Need load everything validate one thing"** → boundary too coarse
- **High contention** → unrelated concern lump together

See `./references/defaults.md` full decomposition guide before/after example.