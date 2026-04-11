# Clean Architecture: Default Principles

## 1. Layer Responsibilities

| Layer | Responsibility | Depends On | Depended On By |
|-------|---------------|------------|----------------|
| **Controllers / Handlers** | Translate external input (HTTP, gRPC, CLI, events) into app calls, format responses | Application Services | Nothing (entry point) |
| **Application Services** | Orchestrate use cases: validate, call domain, coordinate infrastructure via interfaces | Domain, Infrastructure interfaces | Controllers |
| **Domain** | Business rules, entities, value objects, domain services, domain events | Nothing (innermost) | Application Services, Infrastructure (via interfaces) |
| **Infrastructure: Repositories** | Persist/retrieve domain objects for state-changing ops. Implements domain-defined interfaces | Domain (for interfaces) | Application Services (injected) |
| **Infrastructure: Providers** | Fetch data for read-only ops. Return DAOs directly. No domain interface | Nothing (concrete class or app-layer interface) | Application Services (injected) |
| **Infrastructure: Other** | External APIs, file I/O, messaging, caching, notifications | Domain (for interfaces, when applicable) | Application Services (injected) |

### Typical Directory Mapping

```
src/
├── controllers/        # or handlers/, routes/, api/
│   ├── UserController
│   └── OrderController
├── services/           # or usecases/, application/
│   ├── OrderService                # handles both command and query flows
│   └── UserService                 # one service per domain concept
├── domain/             # or core/, model/
│   ├── entities/
│   │   ├── Order
│   │   └── User
│   ├── value-objects/
│   │   ├── Money
│   │   └── Email
│   ├── services/
│   │   └── PricingService
│   ├── events/
│   │   └── OrderPlaced
│   └── repositories/   # interfaces only -- for state-changing operations
│       ├── OrderRepository
│       └── UserRepository
└── infrastructure/     # or adapters/, persistence/
    ├── repositories/   # state-changing: implements domain-defined interfaces
    │   ├── PostgresOrderRepository  (implements OrderRepository)
    │   └── PostgresUserRepository   (implements UserRepository)
    ├── providers/      # read-only: no domain interface, returns DAOs
    │   ├── UserProvider
    │   └── OrderProvider
    ├── external/
    │   └── StripePaymentGateway
    └── messaging/
        └── KafkaEventPublisher
```

Note two sibling folders under `infrastructure/`: `repositories/` (command flows, implementing domain interfaces) and `providers/` (query flows, no domain interface).

---

## 2. Dependency Direction

```
┌──────────────────────────────────────────────────┐
│  Controllers / Handlers         (outermost)      │
│    │                                             │
│    ▼                                             │
│  Application Services                            │
│    │                                             │
│    ▼                                             │
│  Domain                          (innermost)     │
│    ▲                                             │
│    │ implements interfaces                       │
│  Infrastructure                  (outer)         │
└──────────────────────────────────────────────────┘

Dependencies flow INWARD only.
Infrastructure depends on Domain (it implements domain interfaces).
Domain depends on NOTHING outside itself.
```

Infrastructure sits outer ring though implements interfaces defined inner ring. Source code dependency points inward (infrastructure imports domain interface), runtime call goes outward. Dependency Inversion -- mechanism used when inner layer needs trigger outer layer.

**Data crossing boundaries** simple structures -- DTOs, plain objects, primitives. Map external formats to app-layer types inward, domain objects to response DTOs outward. Isolation means API contract and DB schema evolve independently.

---

## 3. Per-Layer Rules

### 3.1 Controllers / Handlers

**What belongs here:**
- HTTP route definitions, request parsing
- Input validation (format, presence -- not business rules)
- Response formatting, status code mapping
- Auth middleware integration
- Request/response DTOs

**What does not belong here:**
- Business rule evaluation ("if order total > 100, apply discount")
- Direct DB calls
- Domain object construction from raw input (use mapper/factory)

**Common violations:**
- Controller reads DB, applies logic, writes back -- all one method
- Business rule conditionals in controller actions
- Returning domain entities directly as JSON

### 3.2 Application Services

One service per domain concept (e.g., `OrderService`, `UserService`). Each service both command methods and query methods, using different infrastructure paths.

**Command methods (state-changing -- create, update, delete):**
- Orchestration: validate → create/hydrate domain → persist via Repository → publish event
- Transaction boundary management
- Authorization checks
- Calling infrastructure through repository interfaces defined domain

**Query methods (reads -- get, list, search):**
- Call Provider fetch data as DAOs
- Map DAOs to response DTOs
- No domain object construction

**Service constructor pattern:**
- Inject both Repository (commands) and Provider (queries) into same service
- Service decides which infrastructure path based on operation

**App services vs domain services:** App services orchestrate workflows, coordinate infrastructure boundaries. Domain services execute pure business logic spanning entities/value objects, no I/O.

**Common violations:**
- Service contains all business logic while entities data holders (anemic domain model)
- Importing concrete repository classes instead interfaces
- Constructing domain objects for read ops when Provider sufficient

### 3.3 Domain

**What belongs here:**
- Entities with behavior (not just data)
- Value objects (Money, Email, OrderId -- immutable, equality by attributes)
- Domain services (business logic not naturally fit single entity)
- Domain events (OrderPlaced, PaymentReceived)
- Repository interfaces (contracts infrastructure implements)
- Factory methods for complex object creation

**What does not belong here:**
- Imports from outer layer
- Framework annotations (@Entity, @Column, @RestController)
- DB-specific types (ResultSet, Document, Row)
- HTTP-specific types (Request, Response, Headers)

**Common violations:**
- Entities annotated with ORM decorators
- Domain services calling repositories directly instead receiving data through app services

### 3.4 Infrastructure

Two distinct data access patterns, plus other technical mechanisms:

**Repositories (`infrastructure/repositories/`):**
- Implement interfaces defined `domain/repositories/`
- Accept/return **domain objects**
- Internally map between domain objects and DAOs
- Used exclusively state-changing ops

**Providers (`infrastructure/providers/`):**
- No interface in domain -- contract lives app layer or concrete class
- Return **DAOs** directly
- Used exclusively read ops
- Optimized query performance without domain construction overhead

**Other infrastructure:** External API clients, file I/O, message queues, caches, notifications.

**Common violations:**
- Repository methods containing business logic
- Concrete infrastructure types exposed to app services
- Using Repository for read-only queries (unnecessary mapping overhead)
- Provider returning domain entities instead DAOs

---

## 4. Command and Query Flows

Every endpoint falls one these flows. Choosing right flow first structural decision when generating code.

Single service handles both flows. `OrderService` has command methods (`createOrder`, `updateOrder`) use Repository through domain, query methods (`getOrder`, `listOrders`) use Provider directly. Command/query separation *flow* distinction within service, not class-level split.

### 4.1 Command Flow (Create, Update, Delete)

State-changing ops engage full stack. Domain layer enforces invariants, business rules before state change persisted.

```
Controller (Request DTO)
  → Application Service
    → Domain (created/hydrated, business rules enforced)
      → Repository (accepts Domain, converts to DAO, persists)
```

Example demonstrates Dependency Inversion at domain/infrastructure boundary -- interface defined domain, implemented infrastructure:

```
// domain/repositories/ -- interface in domain
interface OrderRepository
  save(order: Order): void
  findById(id: OrderId): Order or null

// infrastructure/repositories/ -- implementation
class PostgresOrderRepository implements OrderRepository
  save(order: Order):
    dao = OrderDAO.fromDomain(order)
    db.insert("orders", dao)

  findById(id: OrderId): Order or null
    dao = db.findOne("orders", { id: id.value })
    return dao ? OrderDAO.toDomain(dao) : null

// services/ -- orchestration
class OrderService
  constructor(orderRepo: OrderRepository, eventPublisher: EventPublisher)

  createOrder(command: CreateOrderCommand): OrderId
    order = Order.create(command.items, command.customerId)
    orderRepo.save(order)
    eventPublisher.publishAll(order.pullDomainEvents())
    return order.id
```

### 4.2 Query Flow (Get, List, Search)

Read ops bypass domain entirely. No invariants protect, so domain construction unnecessary overhead.

**DAO (Data Access Object)**: Simple record mirrors DB query result. Not domain entity. Service maps DAOs to response DTOs, selecting only fields API consumer needs.

```
Controller (Request params)
  → Application Service
    → Provider (returns DAO directly to service)
  ← Service maps DAO to Response DTO
← Controller returns Response DTO
```

Example shows both flows single service with explicit DTO mapping:

```
// Application Service -- both Repository (commands) and Provider (queries)
class UserService
  constructor(userRepo: UserRepository, userProvider: UserProvider)
    // userRepo for state-changing operations
    // userProvider for read operations

  // Command flow: goes through domain, uses Repository
  registerUser(command: RegisterUserCommand): String
    user = User.create(command.email, command.name)
    userRepo.save(user)
    return user.id.value

  // Query flow: bypasses domain, uses Provider, maps DAO to response DTO
  getUser(userId: String): UserResponse
    dao = userProvider.findById(userId)
    if dao is null: throw NotFoundError("User not found")
    return UserResponse.fromDAO(dao)

  listActiveUsers(page: Integer, size: Integer): List<UserResponse>
    daos = userProvider.listActive(page, size)
    return daos.map(UserResponse.fromDAO)

// Infrastructure -- Provider (in infrastructure/providers/)
// No domain interface. Concrete class or application-layer interface.
class UserProvider
  findById(id: String): UserDAO or null
    return db.findOne("users", { id })

  listActive(page: Integer, size: Integer): List<UserDAO>
    return db.query(
      "SELECT * FROM users WHERE active = true LIMIT ? OFFSET ?",
      [size, page * size]
    )

// Response DTO -- explicit field selection, not a passthrough of the DAO.
// DB-internal fields are stripped; names are shaped for the API contract.
class UserResponse
  id: String
  name: String
  email: String
  active: Boolean

  static fromDAO(dao: UserDAO): UserResponse
    return new UserResponse(dao.id, dao.name, dao.email, dao.active)
    // dao.passwordHash, dao.internalFlags, dao.createdAt are intentionally excluded
```

### 4.3 Provider vs Repository: Structural Comparison

| Aspect | Repository | Provider |
|--------|-----------|----------|
| **Purpose** | Persist/retrieve domain objects for state-changing ops | Fetch data for read-only ops |
| **Interface defined in** | `domain/repositories/` | App layer or concrete class in infrastructure |
| **Accepts** | Domain objects (entities, aggregates) | Primitive query parameters |
| **Returns** | Domain objects | DAOs (data access objects) |
| **Called by** | Command methods (create, update, delete) | Query methods (get, list, search) |
| **Domain involvement** | Full -- invariants enforced | None -- data flows DB → response DTO |
| **Mapping** | Domain ↔ DAO (bidirectional) | DAO → Response DTO (one-directional, done in service) |

### 4.4 When Read Needs Domain

Rarely, read requires domain logic -- e.g., access control depending domain state. These cases use command flow structure even though no state changes. Domain involvement justified by business rule.

---

## 5. Example Violations and Fixes

### Business Logic in Controller

```
// BAD: Controller makes business decisions
class OrderController
  createOrder(request):
    items = request.body.items
    total = 0
    for each item in items:
      total = total + item.price * item.quantity
      if item.quantity > 100: total = total * 0.9   // business rule in controller
    if total > 10000: throw Error("Order limit exceeded")  // business rule
    db.query("INSERT INTO orders...", [total])       // direct DB access

// GOOD: Controller delegates to service
class OrderController
  constructor(orderService: OrderService)

  handle(request):
    command = CreateOrderCommand.fromRequest(request)
    result = orderService.createOrder(command)
    return OrderResponse.from(result)
```

### Domain Depending on Infrastructure

```
// BAD: Domain entity depends on infrastructure
class Order
  dbClient = new DatabaseClient()

  calculateTotal(): Money
    taxRate = dbClient.findConfig("tax_rate")   // I/O inside domain — violation
    // ...

// GOOD: Domain defines interface, receives data
interface TaxRateProvider
  getCurrentRate(region: Region): TaxRate

class Order
  calculateTotal(taxRate: TaxRate): Money
    // pure business logic, no I/O

class OrderService
  constructor(taxRates: TaxRateProvider, orders: OrderRepository)

  createOrder(command: CreateOrderCommand):
    rate = taxRates.getCurrentRate(command.region)
    order = Order.create(command.items)
    total = order.calculateTotal(rate)
    // ...
```

### Leaking Data Formats

```
// BAD: Database model returned directly from API
class UserController
  getUser(request):
    user = db.findOne("users", { id: request.params.id })
    return user                 // exposes passwordHash, internal IDs, DB column names

// GOOD: Map at the boundary
class UserController
  constructor(userService: UserService)

  handle(request):
    return userService.getUser(request.params.id)   // returns Response DTO
```

### God Class

```
// BAD: One class does everything -- validation, HTTP, business rules, persistence, email, messaging
class OrderService
  createOrder(data):
    // 130+ lines covering 7 responsibilities

// GOOD: Decomposed by responsibility and layer
// domain/entities/Order              -- business rules
// domain/repositories/OrderRepository -- persistence interface
// infrastructure/repositories/PostgresOrderRepository -- persistence impl
// infrastructure/external/InventoryClient -- external API
// infrastructure/messaging/OrderEventPublisher -- messaging
// services/OrderService              -- orchestration only
```

