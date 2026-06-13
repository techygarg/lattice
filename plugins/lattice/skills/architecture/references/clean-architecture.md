# Clean Architecture Enforcement Rules

These enforcement instructions for clean architecture mode. Define Self-Validation Checklist, Anti-Pattern Scan, Ambiguity Signals, structural principles architecture atom applies when `architecture_mode` is `clean` (default).

Detailed content (layer responsibility tables, per-layer rules, command/query flow examples, violation/fix pairs) in `./clean-architecture-defaults.md` or team's overlay/override document.

## Self-Validation Checklist

STOP after generate each component. Verify ALL before proceed. If check fails, fix code before present. If judgment call with multiple valid approaches (see Ambiguity Signals below), flag it — present options and reasoning rather than silent choose.

1. **OPERATION TYPE**: State-change (command) or read (query)? Determine FIRST — dictates entire flow.
2. **COMMAND FLOW**: State-change ops — data flow through domain before Repository? Domain invariants enforced before persist?
3. **QUERY FLOW**: Read ops — use Provider (not Repository)? Domain objects avoided where no invariant need enforce?
4. **DEPENDENCY DIRECTION**: All source code dependencies point inward? Domain layer zero imports from outer layers?
5. **LAYER PLACEMENT**: Each class in correct layer? Controllers translate only, application services orchestrate, domain enforce rules, infrastructure implement interfaces.
6. **BOUNDARY DATA**: Data cross layer boundaries use simple structures (DTOs, plain objects)? No framework-specific types or entities leak outward.
7. **INTERFACE OWNERSHIP**: Repository interfaces defined in domain layer? Provider contracts absent from domain layer?
8. **SINGLE LAYER**: Each class belong exactly one architectural layer? No class span HTTP parsing, business logic, AND database access.

## Active Anti-Pattern Scan

After verify checklist above, scan output for these anti-patterns. If find any, fix before present code.

- [ ] **Business Logic in Controllers**: Controller make business decisions beyond translation → extract to domain or use case
- [ ] **Domain Depending on Infrastructure**: Domain imports database client, HTTP library, or external service → define interface in domain, implement in infrastructure
- [ ] **God Classes**: Single class change for every kind requirement → decompose into focused classes per layer
- [ ] **Anemic Architecture**: Layers exist in folders but dependency rule not enforced → verify imports, add interfaces
- [ ] **Leaking Data Formats**: Database schema change break API contract → map between DAO, domain object, and response DTO at each boundary
- [ ] **Circular Dependency**: Two layers import each other (e.g., application import infrastructure type, infrastructure import application type) → introduce interface in inner layer
- [ ] **Fat Application Service**: Business rules or domain logic accumulate in orchestration layer → move decisions into domain entities or domain services
- [ ] **Leaking Entity**: Domain object return directly from controller instead of map to response DTO → add boundary mapping step

## Ambiguity Signals

These checks often have multiple valid outcomes. When encounter, present options rather than silent choose.

- **Layer Placement**: Logic coordinate domain objects but also contain business rules could be domain service or application service. Distinction: logic IS business rule or ORCHESTRATE business rules?
- **Query Complexity**: Read operation need enforce business rules before return data blur Provider vs Repository boundary.
- **DTO Granularity**: One DTO per endpoint vs shared DTOs across related endpoints — tradeoff between type safety and duplication.

## Core Principle

Clean Architecture about **structure** -- where code live, which layers exist, which direction dependencies flow. Distinct from DDD, which about craft domain logic *within* domain layer. This skill handle structural envelope; DDD handle domain craft inside it.

Structural constraints: business rules independently testable, not coupled to frameworks, UI, database, or external agencies. Any outer-layer component swap without touch domain logic.

## The Dependency Rule

Single rule make architecture work: **source code dependencies only point inward.**

Nothing in inner layer know anything about outer layer. No name declared in outer layer -- function, class, variable, data format -- mentioned by code in inner layer.

Reason: isolation. When inner layers ignorant of outer layers, can swap, rewrite, or remove any outer layer without cascade changes inward.

When control flow must go outward (e.g., use case need call repository), use **Dependency Inversion**: inner layer define interface, outer layer implement it. Source code dependency point inward even though runtime call go outward. Data cross boundaries should be simple structures -- DTOs, plain objects, primitives -- never framework-specific types.

See `./clean-architecture-defaults.md` for layer responsibility tables, per-layer rules, command/query flow examples, and violation/fix pairs.