---
name: domain-driven-design
description: "Apply DDD tactical patterns when working with domain code. Enforces aggregate design, value objects over primitives, entity identity rules, and bounded context boundaries. Use when creating or modifying domain models, designing aggregates, working in the domain folder, or when the user mentions 'domain', 'aggregate', 'value object', 'entity', 'bounded context', or 'DDD'. This skill auto-activates when code changes touch the configured domain folder."
---

# Domain-Driven Design

## Config Resolution

This skill supports project-specific customizations. Resolution order:

1. Look for `.ai/config.yaml` in the repository root
2. If found, check `paths.ddd_principles` for a custom document path
3. If the custom path exists, read that document and check its YAML frontmatter for `mode`:
   - **`mode: override`** (or no mode specified): The custom document takes full precedence.
     Use it instead of the embedded defaults. It must be comprehensive -- it is the sole reference.
   - **`mode: overlay`**: Read the embedded `./references/defaults.md` first, then apply the
     custom document's sections on top. Sections in the custom document replace matching
     sections in defaults (matched by heading). New sections are appended after defaults.
4. If no config, no path, or path not found, read `./references/defaults.md`

The defaults ship with this skill and represent opinionated best practices.
They work out of the box for any project. Override only when your team has
specific standards that differ from the defaults.

## Self-Validation Checklist

STOP after generating each component. Verify ALL of the following before proceeding. If any check clearly fails, fix the code before presenting it. If a check is a judgment call with multiple valid approaches (see Ambiguity Signals), flag it — present your options and reasoning rather than silently choosing.

1. **ENTITY VS VALUE OBJECT**: For each domain object — does the business track individual instances over time? Yes → entity with identity. No → value object with immutability and self-validation.
2. **AGGREGATE BOUNDARY**: Does a transactional invariant require this object inside the aggregate? If not → separate aggregate referenced by ID.
3. **RICH BEHAVIOR**: Do entities have methods that enforce business rules, guard state transitions, and raise events? If entities are just data holders → move logic from services into entities.
4. **VALUE OBJECT COVERAGE**: Scan for primitive types that should be value objects — string emails, number amounts, raw UUIDs as identifiers → wrap in value objects with validation.
5. **AGGREGATE COHESION**: List the business rules the root enforces. Does each internal entity participate in at least one invariant? If not → it belongs in its own aggregate.
6. **DOMAIN EVENTS**: Are domain events raised for state transitions other aggregates react to, changes that trigger notifications, and audit/compliance requirements? Don't raise events for internal changes nothing reacts to.

## Active Anti-Pattern Scan

After verifying the checklist above, scan your output for these specific anti-patterns. If you find any, fix them before presenting the code.

- [ ] **Anemic Domain Model**: Entities are data holders with only getters/setters; all logic lives in services → move business rules into entities and value objects
- [ ] **Primitive Obsession**: Raw strings for email, numbers for money, UUIDs for IDs → wrap in value objects with validation and behavior
- [ ] **God Aggregate**: Aggregate with many entities, slow to load, high contention → decompose to keep only what shares a transactional invariant
- [ ] **Cross-Aggregate Transaction**: Service updates two aggregates in one transaction → use domain events for eventual consistency
- [ ] **Leaking Domain Logic**: Business rules in controllers, application services, or infrastructure → extract to domain objects or domain services
- [ ] **Misidentified Entity/Value Object**: Entity without lifecycle, or value object with identity tracking → apply the identity test

## Ambiguity Signals

These checks often have multiple valid outcomes. When you encounter one, present options rather than silently choosing.

- **Aggregate Boundary Size**: Smaller aggregates (more events, eventual consistency) vs larger aggregates (simpler transactions, immediate consistency). Neither is inherently correct — it depends on contention patterns and invariant scope.
- **Entity vs Value Object**: Some concepts (like `Address` or `Money`) may or may not need identity depending on the domain's complexity. Apply the identity test, but acknowledge when it's borderline.
- **Domain Service vs Entity Method**: Logic that spans multiple entities could live in a domain service or be a method on the primary entity. The choice depends on which entity "owns" the invariant.

## Scope Statement

This skill operates within a single repository, for a single bounded context (e.g., one API -- Order, User, Pricing). It covers tactical DDD patterns only -- not strategic DDD (no context mapping, no microservice topology, no bounded context integration).

`framework:clean-architecture` provides the structural envelope -- where code lives, which layers exist, which direction dependencies flow. This skill defines how to craft the domain *within* that envelope: rich models, invariants, aggregate boundaries, and ubiquitous language.

## Core Principle

The domain model is the authoritative expression of business rules. Rich domain objects encapsulate behavior and enforce invariants. Code should speak the ubiquitous language of the business.

If a business rule exists, it should be expressible through the domain model -- not scattered across controllers, application services, or infrastructure. An entity that is only a data holder with external services doing all the work is an anemic model, and it is the primary anti-pattern this skill prevents.

## The Aggregate Rule

The single governing principle that makes DDD work -- equivalent to the Dependency Rule in Clean Architecture:

**"Design around invariants, not relationships."**

An aggregate is a **consistency boundary** -- the set of objects that MUST be immediately consistent within a single transaction. It is not a convenience grouping of related things. The rules:

1. **Only the aggregate root is accessible from outside.** External code never reaches past the root to manipulate internal entities.
2. **Reference other aggregates by identity (ID), never by object reference.** Object references create hidden coupling and expand transaction scope.
3. **One transaction per aggregate.** If a business operation needs two aggregates updated atomically, either the boundary is wrong or you need domain events for eventual consistency.
4. **Start small.** Begin with root + value objects. Add internal entities only when a transactional invariant forces them inside. If you are debating whether something belongs, it does not.

See `./references/defaults.md` for the full aggregate design framework with code examples, decomposition heuristics, and before/after pseudocode.

## Tactical Patterns

Each pattern: what it is, why it matters, the key rule. See `./references/defaults.md` for deep guidance and code examples.

### Aggregate

Consistency boundary. Root access only. Reference by ID. One transaction. Every internal entity must participate in at least one invariant enforced by the root -- if it does not, it belongs in its own aggregate.

### Entity

Has identity persisting through state changes. Equality by identity, not attributes. Must have behavior -- methods that enforce business rules, guard state transitions, and raise events. An entity with only getters and setters is an anemic model.

### Value Object

Defined by attributes, not identity. Immutable. Self-validating -- invalid states are unrepresentable. Use instead of primitives: Money not number, Email not string, OrderId not UUID. See `./references/defaults.md` for the common value object catalog.

### Domain Service

Stateless business logic that spans multiple entities or value objects with no natural home in any single one. Pure domain computation -- no I/O, no infrastructure calls. Not to be confused with application services, which orchestrate use cases and coordinate infrastructure.

### Domain Event

Something that happened in the domain that domain experts care about. Named in past tense (OrderPlaced, PaymentReceived). Carries the data needed to describe what happened (aggregate ID, relevant values, timestamp). Used for cross-aggregate coordination and eventual consistency. Not event sourcing -- aggregates are persisted through repositories.

### Repository

One per aggregate root, not per entity. Interface defined in domain layer, implementation in infrastructure. Collection-like semantics (save, findById, remove). Returns fully-constituted aggregates, not partial objects or DTOs.

**Repositories are for command (state-changing) operations only.** Read-only queries belong in Providers (see `framework:clean-architecture` Query Flow). Providers are concrete infrastructure classes with no domain-layer interface -- they return DAOs, not domain objects. Do not conflate Repository and Provider: Repository protects invariants through domain objects; Provider serves reads efficiently by bypassing domain construction.

### Factory

Encapsulates complex aggregate creation. Two purposes: initial creation (enforcing creation invariants) and reconstitution from persistence. Simple cases use a factory method on the aggregate root (`Order.create(...)`). Complex cases involving multiple sources use a standalone factory class.

## Design Decision Framework

When making domain modeling decisions, ask these questions:

1. **Aggregate boundary**: "What must be consistent within a single transaction?" -- not "what is related to what." If unsure → start separate, merge only if an invariant forces it.
2. **Entity vs Value Object**: Does the business track individual instances over time? Yes → entity. No → value object.
3. **Domain Service vs Entity Method**: Logic belongs to one entity? → put it there. Spans multiple entities? → domain service. Involves I/O? → application service.
4. **Domain Events**: Would other aggregates, external systems, or audit trails react? Yes → raise event. No → skip.

## Decomposition Signals

Recognize when an aggregate has grown too large:

- **More than ~3-5 internal entities** → not all share an invariant with the root
- **Multiple unrelated invariants** → likely two aggregates merged
- **Root methods that only touch a subset** of internals → that subset may be its own aggregate
- **"I need to load everything to validate one thing"** → boundary is too coarse
- **High contention** → unrelated concerns are lumped together

See `./references/defaults.md` for the full decomposition guide with before/after examples.

