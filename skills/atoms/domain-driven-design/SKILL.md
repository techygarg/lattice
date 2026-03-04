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

1. **Aggregate boundary**: "What must be consistent within a single transaction?" -- not "what is related to what." If two entities share a transactional invariant → same aggregate. If not → separate aggregates, reference by ID. If unsure → start separate, merge only if an invariant forces it.
2. **Entity vs Value Object**: Does the business track individual instances over time? Yes → entity. No → value object. Two identical Addresses are the same address (value object). Two Orders with identical items are still different orders (entity).
3. **When to use Domain Service**: Logic belongs to one entity? → put it there. Spans multiple entities or value objects? → domain service. Involves I/O? → application service.
4. **When to raise Domain Events**: Would other aggregates, external systems, or audit trails react? Yes → raise event. No → skip.

## Decomposition Signals

Recognize when an aggregate has grown too large:

- **More than ~3-5 internal entities** → question the boundary; not all of them share an invariant with the root
- **Multiple unrelated invariants** in one aggregate → likely two aggregates merged
- **Methods on the root that only touch a subset** of internals → that subset may be its own aggregate
- **"I need to load everything to validate one thing"** → boundary is too coarse
- **High contention** — multiple users frequently conflict on the same aggregate → unrelated concerns are lumped together

**Sizing heuristic**: Start with the smallest possible aggregate (root + value objects). Add internal entities only when an invariant forces them inside. If you are debating whether something belongs, it probably does not. See `./references/defaults.md` for the full decomposition guide with step-by-step approach and before/after examples.

## Self-Validation During Code Generation

When generating domain code, apply these checks:

1. **Before creating a domain object**: Is this an entity or value object? Apply the identity test -- does the business track individual instances over time?
2. **Before adding something to an aggregate**: Does a transactional invariant require this? If not, it is a separate aggregate referenced by ID.
3. **After generating**: Scan for primitive types that should be value objects -- string emails, number amounts, raw UUIDs as identifiers.
4. **After generating**: List the business rules the root enforces. Each internal entity should appear in at least one. If an entity does not participate in any invariant enforced by the root, it belongs in its own aggregate.
5. **After generating**: Raise domain events for: state transitions other aggregates react to, changes that trigger notifications or side effects, audit/compliance requirements. Do not raise events for internal state changes nothing else reacts to.
6. **After generating**: Do entities have behavior (methods with guard clauses), or are they just data holders?

## Validation Checklist

When generating or reviewing domain code, verify these constraints.

| Check | Why It Matters |
|-------|---------------|
| Aggregates enforce invariants through the root | Bypassing the root means invariants can be violated silently |
| Entities have behavior, not just data | Data-only entities push logic to services -- anemic domain model |
| Value objects replace primitives for domain concepts | Primitives carry no validation, no domain meaning, and invite duplication |
| Domain services are stateless and pure | Stateful domain services blur the line with entities; I/O blurs with application services |
| Domain events are raised for cross-aggregate concerns | Silent state changes force direct coupling between aggregates |
| Aggregates reference each other by ID | Object references create implicit coupling and expand transaction scope |
| Each aggregate fits within a single transaction | Multi-aggregate transactions indicate wrong boundaries |
| Domain layer has zero infrastructure dependencies | Already enforced by Clean Architecture; DDD reinforces the reason -- domain purity |

## Anti-Patterns

Common DDD violations. See `./references/defaults.md` for full code examples showing each violation and its fix.

| Anti-Pattern | Symptom | Fix |
|-------------|---------|-----|
| **Anemic Domain Model** | Entities are data holders; all logic in services | Move business rules into entities and value objects |
| **Primitive Obsession** | string for email, number for money, raw IDs everywhere | Wrap in value objects with validation and behavior |
| **God Aggregate** | One aggregate with many entities, slow to load, high contention | Decompose: keep only what shares a transactional invariant |
| **Cross-Aggregate Transaction** | Service updates two aggregates in one transaction | Use domain events for eventual consistency |
| **Leaking Domain Logic** | Business rules in controllers, services, or infrastructure | Extract to domain objects; if multi-entity, use domain service |
| **Misidentified Entity/Value Object** | Entity without lifecycle, or value object with identity tracking | Apply the identity test: does the business track individual instances? |
