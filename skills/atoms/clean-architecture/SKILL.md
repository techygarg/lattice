---
name: clean-architecture
description: "Enforce clean architecture structural rules when generating or modifying code. Validates layer responsibilities, dependency direction, and structural constraints. Use when generating code, reviewing architecture, creating new files, or when the user mentions 'architecture', 'layers', 'structure', 'controllers', 'services', 'repositories', 'dependency rules', 'providers', 'provider vs repository', or 'CQRS'. Also use when reviewing generated code for structural compliance."
---

# Clean Architecture

## Config Resolution

This skill supports project-specific customizations. Resolution order:

1. Look for `.ai/config.yaml` in the repository root
2. If found, check `paths.clean_architecture` for a custom document path
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

1. **OPERATION TYPE**: Is this a state-changing operation (command) or read operation (query)? Determine FIRST — it dictates the entire flow.
2. **COMMAND FLOW**: For state-changing operations — does data flow through domain before reaching Repository? Are domain invariants enforced before persistence?
3. **QUERY FLOW**: For read operations — does it use Provider (not Repository)? Are domain objects avoided where no invariant needs enforcement?
4. **DEPENDENCY DIRECTION**: Do all source code dependencies point inward? Does the domain layer have zero imports from outer layers?
5. **LAYER PLACEMENT**: Is each class in the correct layer? Controllers do translation only, application services orchestrate, domain enforces rules, infrastructure implements interfaces.
6. **BOUNDARY DATA**: Does data crossing layer boundaries use simple structures (DTOs, plain objects)? No framework-specific types or entities leaking outward.
7. **INTERFACE OWNERSHIP**: Are Repository interfaces defined in the domain layer? Are Provider contracts absent from the domain layer?
8. **SINGLE LAYER**: Does each class belong to exactly one architectural layer? No class should span HTTP parsing, business logic, and database access.

## Active Anti-Pattern Scan

After verifying the checklist above, scan your output for these specific anti-patterns. If you find any, fix them before presenting the code.

- [ ] **Business Logic in Controllers**: Controller makes business decisions beyond translation → extract to domain or use case
- [ ] **Domain Depending on Infrastructure**: Domain imports database client, HTTP library, or external service → define interface in domain, implement in infrastructure
- [ ] **God Classes**: Single class changes for every kind of requirement → decompose into focused classes per layer
- [ ] **Anemic Architecture**: Layers exist in folders but dependency rule is not enforced → verify imports, add interfaces
- [ ] **Leaking Data Formats**: Database schema change breaks API contract → map between DAO, domain object, and response DTO at each boundary

## Ambiguity Signals

These checks often have multiple valid outcomes. When you encounter one, present options rather than silently choosing.

- **Layer Placement**: Logic that coordinates domain objects but also contains business rules could be a domain service or an application service. The distinction is whether the logic IS a business rule or ORCHESTRATES business rules.
- **Query Complexity**: A read operation that needs to enforce business rules before returning data blurs the Provider vs Repository boundary.
- **DTO Granularity**: One DTO per endpoint vs shared DTOs across related endpoints — tradeoff between type safety and duplication.

## Core Principle

Clean Architecture is about **structure** -- where code lives, which layers exist, and which direction dependencies flow. It is distinct from DDD, which is about crafting domain logic *within* the domain layer. This skill handles the structural envelope; DDD handles the domain crafting inside it.

The structural constraints: business rules are independently testable, not coupled to frameworks, UI, database, or external agencies. Any outer-layer component can be swapped without touching domain logic.

## The Dependency Rule

The single rule that makes the architecture work: **source code dependencies can only point inward.**

Nothing in an inner layer can know anything about an outer layer. No name declared in an outer layer -- function, class, variable, data format -- may be mentioned by code in an inner layer.

The reason is isolation. When inner layers are ignorant of outer layers, you can swap, rewrite, or remove any outer layer without cascading changes inward.

When the flow of control must go outward (e.g., a use case needs to call a repository), use **Dependency Inversion**: the inner layer defines an interface, the outer layer implements it. The source code dependency points inward even though the runtime call goes outward. Data crossing boundaries should be simple structures -- DTOs, plain objects, primitives -- never framework-specific types.

See `./references/defaults.md` for code examples of boundary crossing with Dependency Inversion.

## Layer Definitions

Four layers, from outermost to innermost. Read `./references/defaults.md` for the complete responsibilities table with per-layer rules and common violations.

### Controllers / Handlers (Outermost)

Entry points: HTTP controllers, gRPC handlers, CLI commands, message consumers. Their job is translation -- convert external input into a form the application layer understands, invoke the appropriate use case, and convert the result back. No business logic belongs here.

### Application Services (Use Cases)

One service per domain concept (e.g., `OrderService`, `UserService`). Each service contains both command methods (state-changing, routed through domain and Repository) and query methods (read-only, routed through Provider).

### Domain (Innermost)

Enterprise-wide business rules. Entities, value objects, domain services, domain events. The domain layer has **zero outward dependencies** -- it defines interfaces (ports) that outer layers implement.

### Infrastructure (Outer)

- **Repositories** (`infrastructure/repositories/`): Implement interfaces defined in `domain/repositories/`. Accept and return domain objects. Used for **state-changing (command) operations only**. The domain defines the interface; infrastructure implements it. This is Dependency Inversion in action.
- **Providers** (`infrastructure/providers/`): Concrete classes -- **no interface in the domain layer**. Return DAOs directly to application services. Used for **read-only (query) operations only**. Providers exist entirely in infrastructure; the domain layer does not know they exist. If multiple Provider implementations exist, the interface lives in the application layer -- never in domain. Domain only defines contracts for state-changing infrastructure (Repositories).
- **Other**: External API clients, file system operations, email services, message queues, caches.

## Two Flows: Commands and Queries

Not all operations need the same architectural weight. State-changing operations and read operations follow fundamentally different flows.

### Command Flow (State-Changing Operations)

Commands need the full stack because the domain must enforce invariants and business rules *before* anything is persisted.

```
Controller (Request DTO)
  → Application Service
    → Domain (created/hydrated from DTO, business rules enforced)
      → Repository (accepts Domain, converts to DAO, persists)
```

Key rules: Repository implements a domain-defined interface, accepts and returns domain objects, and maps to DAOs internally. The domain layer is the gatekeeper -- no state change bypasses it.

### Query Flow (Read Operations)

Reads don't change state -- no invariants to protect, no business rules to enforce. The query flow is intentionally lightweight, bypassing domain construction.

```
Controller (Request params)
  → Application Service
    → Provider (returns DAO directly to service)
  ← Service maps DAO to Response DTO
← Controller returns Response DTO
```

Key rules: Provider lives in `infrastructure/providers/` with **no interface in the domain layer**. It returns DAOs, not domain entities. The service maps DAOs to response DTOs. Domain objects are not constructed during reads.

### Single Service, Two Paths

A single service per domain concept injects both Repository and Provider. Command methods route through domain and Repository; query methods route through Provider directly. This is a *flow* distinction within the service, not a class-level split. Full CQRS with separate command/query handlers is a different architectural choice -- do not conflate the two.


