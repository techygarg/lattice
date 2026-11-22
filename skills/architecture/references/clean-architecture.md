# Clean Architecture Enforcement Rules

These are the enforcement instructions for clean architecture mode. They define the Self-Validation Checklist, Anti-Pattern Scan, Ambiguity Signals, and structural principles that the architecture atom applies when `architecture_mode` is `clean` (the default).

Detailed content (layer responsibility tables, per-layer rules, command/query flow examples, violation/fix pairs) lives in `./clean-architecture-defaults.md` or in the team's overlay/override document.

## Self-Validation Checklist

**STOP after generating each component. Verify ALL checks before proceeding. A check fails → fix the code before presenting. A check is a judgment call with multiple valid approaches (see Ambiguity Signals below) → flag it -- present options and reasoning rather than silently choosing.**

1. **OPERATION TYPE**: Is this a state-change (command) or a read (query)? Determine FIRST -- it dictates the entire flow.
2. **COMMAND FLOW**: For state-change operations, does data flow through the domain before the Repository? Are domain invariants enforced before persisting?
3. **QUERY FLOW**: For read operations, is a Provider used (not a Repository)? Are domain objects avoided where no invariant needs enforcing?
4. **DEPENDENCY DIRECTION**: Do all source-code dependencies point inward? Does the domain layer have zero imports from outer layers?
5. **LAYER PLACEMENT**: Is each class in the correct layer? Controllers translate only, application services orchestrate, domain enforces rules, infrastructure implements interfaces.
6. **BOUNDARY DATA**: Does data crossing layer boundaries use simple structures (DTOs, plain objects)? No framework-specific types or entities leak outward.
7. **INTERFACE OWNERSHIP**: Are Repository interfaces defined in the domain layer? Are Provider contracts absent from the domain layer?
8. **SINGLE LAYER**: Does each class belong to exactly one architectural layer? No class spans HTTP parsing, business logic, AND database access.

All checks pass → state "Passes architecture. [next step]."

## Active Anti-Pattern Scan

After verifying the checklist above, scan the output for these anti-patterns. Any box you can check → fix before presenting the code.

- [ ] **Business Logic in Controllers**: a controller makes business decisions beyond translation → extract to the domain or a use case.
- [ ] **Domain Depending on Infrastructure**: the domain imports a database client, HTTP library, or external service → define an interface in the domain, implement it in infrastructure.
- [ ] **God Classes**: a single class changes for every kind of requirement → decompose into focused classes per layer.
- [ ] **Anemic Architecture**: layers exist as folders but the dependency rule is not enforced → verify imports, add interfaces.
- [ ] **Leaking Data Formats**: a database schema change breaks an API contract → map between DAO, domain object, and response DTO at each boundary.
- [ ] **Circular Dependency**: two layers import each other (e.g., application imports an infrastructure type and vice versa) → introduce an interface in the inner layer.
- [ ] **Fat Application Service**: business rules accumulate in the orchestration layer → move decisions into domain entities or domain services.
- [ ] **Leaking Entity**: a domain object returned directly from a controller instead of mapped to a response DTO → add a boundary mapping step.

## Ambiguity Signals

These checks often have multiple valid outcomes. When you encounter one, present the options rather than silently choosing. If `framework:collaborative-judgment` is loaded, use its presentation format.

- **Layer Placement**: logic that coordinates domain objects but also contains business rules could be a domain service or an application service. The distinction: is the logic itself a business rule, or does it orchestrate business rules?
- **Query Complexity**: a read operation that must enforce business rules before returning data blurs the Provider vs Repository boundary.
- **DTO Granularity**: one DTO per endpoint vs shared DTOs across related endpoints -- a tradeoff between type safety and duplication.

## Core Principle

Clean Architecture is about **structure** -- where code lives, which layers exist, which direction dependencies flow. Distinct from DDD, which is about crafting domain logic *within* the domain layer. This skill handles the structural envelope; DDD handles the domain craft inside it.

Structural constraints: business rules independently testable, not coupled to frameworks, UI, database, or external agencies. Any outer-layer component swappable without touching domain logic.

## The Dependency Rule

A single rule makes the architecture work: **source code dependencies only point inward.**

Nothing in an inner layer knows anything about an outer layer. No name declared in an outer layer -- function, class, variable, data format -- is mentioned by code in an inner layer.

The reason is isolation. When inner layers are ignorant of outer layers, you can swap, rewrite, or remove any outer layer without cascading changes inward.

When control flow must go outward (e.g., a use case needs to call a repository), use **Dependency Inversion**: the inner layer defines an interface, the outer layer implements it. The source-code dependency points inward even though the runtime call goes outward. Data crossing boundaries should be simple structures -- DTOs, plain objects, primitives -- never framework-specific types.

See `./clean-architecture-defaults.md` for layer responsibility tables, per-layer rules, command/query flow examples, and violation/fix pairs.
