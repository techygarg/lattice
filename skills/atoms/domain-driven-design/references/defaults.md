# Domain-Driven Design: Default Principles

These are the embedded opinionated defaults for DDD tactical patterns. They synthesize Eric Evans's Domain-Driven Design, Vaughn Vernon's Implementing Domain-Driven Design, and practical aggregate design heuristics into one actionable set of rules.

If the project has a custom `.ai/standards/ddd-principles.md` (produced by a domain crafter or written manually), that document takes precedence over everything here.

## Table of Contents

1. [Aggregate Design Rules](#1-aggregate-design-rules)
2. [Entity Patterns](#2-entity-patterns)
3. [Value Object Patterns](#3-value-object-patterns)
4. [Domain Service Rules](#4-domain-service-rules)
5. [Domain Event Patterns](#5-domain-event-patterns)
6. [Repository Patterns](#6-repository-patterns)
7. [Factory Patterns](#7-factory-patterns)
8. [Anti-Pattern Catalog](#8-anti-pattern-catalog)
9. [Decomposition Guide](#9-decomposition-guide)
10. [Validation Checklist — Detailed](#10-validation-checklist--detailed)

---

## 1. Aggregate Design Rules

Aggregate boundaries are the single hardest design decision in DDD. Everything else follows from getting them right.

### Consistency Boundary Principle

An aggregate is the set of objects that **must** be immediately consistent after every transaction. Not "things that are related." Not "things that share a database table." Specifically: the objects whose combined state must satisfy an invariant that is checked atomically.

Ask: *"If this entity changes, what else MUST be valid in the same instant?"* Only those objects belong in the same aggregate.

### Sizing Heuristic

Start with the **smallest possible aggregate**: a root entity plus its value objects. Add internal entities only when a transactional invariant forces them inside. If you are debating whether something belongs inside, it almost certainly does not.

Small aggregates load fast, conflict rarely, and scale well. Large aggregates are slow, contended, and fragile.

### Reference by Identity

Aggregates reference other aggregates by ID only — never by direct object reference. Object references create hidden coupling, expand transaction scope, and make it impossible to distribute aggregates independently.

```
// WRONG: Order holds a direct reference to Customer
class Order
  customer: Customer          // pulls Customer into Order's transaction scope

// RIGHT: Order holds Customer's identity
class Order
  customerId: CustomerId      // loose coupling, separate transaction scopes
```

### One Transaction Rule

Each aggregate defines one transaction boundary. A single business operation should modify at most one aggregate per transaction. If you need two aggregates updated atomically, either the boundary is wrong (merge them) or you should accept eventual consistency via domain events.

### Invariant Ownership

Every business rule belongs to exactly one aggregate — the one whose root enforces it. If a rule genuinely spans two aggregates, one of three things is true:
1. The boundary is wrong — they should be one aggregate.
2. One aggregate can own the rule by receiving the other's state as a value (not reference).
3. The rule is an eventual consistency concern — enforce via domain events and compensating actions.

### Code Example: Order Aggregate with LineItems

LineItems are inside the Order aggregate because the invariant "order total must equal the sum of line item subtotals" requires atomic consistency.

```
class Order                                   // Aggregate Root
  id: OrderId
  customerId: CustomerId                      // reference by ID, not object
  status: OrderStatus
  lineItems: List<LineItem>                   // internal entity — inside aggregate

  static create(customerId, items):
    guard items is not empty
    order = new Order(OrderId.generate(), customerId, DRAFT, [])
    for each item in items:
      order.addLineItem(item.productId, item.quantity, item.unitPrice)
    return order

  addLineItem(productId, quantity, unitPrice):
    guard status is DRAFT
    guard quantity > 0
    lineItem = new LineItem(LineItemId.generate(), productId, quantity, unitPrice)
    lineItems.add(lineItem)

  removeLineItem(lineItemId):
    guard status is DRAFT
    guard lineItems contains lineItemId
    lineItems.remove(lineItemId)

  confirm():
    guard lineItems is not empty
    guard status is DRAFT
    status = CONFIRMED
    raise OrderConfirmed(id, customerId, total(), confirmedAt: now())

  total(): Money
    return lineItems.sum(item => item.subtotal())

class LineItem                                // Internal Entity
  id: LineItemId
  productId: ProductId
  quantity: Quantity
  unitPrice: Money

  subtotal(): Money
    return unitPrice.multiply(quantity.value)
```

Customer is a separate aggregate referenced by `CustomerId`. It has its own lifecycle, its own invariants, and its own transaction boundary. Loading an Order should never require loading a Customer.

### Code Example: Decomposing a God Aggregate

Before — Shipment is incorrectly inside Order:

```
class Order
  lineItems: List<LineItem>
  shipment: Shipment          // no shared invariant with lineItems
  trackingHistory: List<TrackingEvent>  // grows independently of Order
```

After — Shipment extracted to its own aggregate:

```
class Order
  lineItems: List<LineItem>
  // shipment removed — no shared transactional invariant

class Shipment                // separate Aggregate Root
  id: ShipmentId
  orderId: OrderId            // references Order by ID
  trackingHistory: List<TrackingEvent>

  recordTrackingEvent(event):
    trackingHistory.add(event)
    if event.type is DELIVERED:
      raise ShipmentDelivered(id, orderId)
```

Order and Shipment evolve independently. When a shipment is delivered, a domain event notifies the Order context if needed.

---

## 2. Entity Patterns

### Identity

An entity has a persistent identity that survives state changes. An Order remains the same Order whether its status is DRAFT or CONFIRMED. Identity is typically a typed identifier (value object wrapping a raw ID).

### Equality

Two entities are equal if and only if they have the same identity — regardless of their attribute values. An Order with id=123 is the same entity whether its total is $50 or $500.

```
class Entity
  equals(other):
    return this.id == other.id

  hashCode():
    return hash(this.id)
```

### Behavior-Rich Entities

Entities encapsulate business rules as methods. If an entity has only getters and setters, the logic that should live inside it has leaked elsewhere (typically into application services).

```
// WRONG: Anemic entity — data holder only
class Account
  balance: Money
  status: AccountStatus

// Service does all the work
class AccountService
  withdraw(accountId, amount):
    account = repository.findById(accountId)
    if account.status != ACTIVE: throw InactiveAccountError
    if account.balance < amount: throw InsufficientFundsError
    account.balance = account.balance - amount
    repository.save(account)

// RIGHT: Rich entity — behavior and rules inside
class Account
  balance: Money
  status: AccountStatus

  withdraw(amount):
    guard status is ACTIVE else throw InactiveAccountError
    guard balance >= amount else throw InsufficientFundsError
    balance = balance.subtract(amount)
    raise FundsWithdrawn(id, amount, balance)
```

### Lifecycle

Entities have a lifecycle: creation → state transitions → possible deactivation or completion. Each transition should enforce its preconditions.

```
class Order
  // Creation
  static create(customerId, items): Order

  // State transitions — each with preconditions
  confirm():
    guard status is DRAFT
    status = CONFIRMED

  ship(trackingNumber):
    guard status is CONFIRMED
    status = SHIPPED

  cancel():
    guard status in [DRAFT, CONFIRMED]  // cannot cancel shipped order
    status = CANCELLED
```

---

## 3. Value Object Patterns

### Attributes Define It

A value object has no identity. It is defined entirely by its attributes. Two Money objects with amount=10 and currency=USD are the same Money — there is no concept of "which one."

### Immutability

Value objects never change after creation. Operations that would "modify" a value object return a new instance instead. This eliminates aliasing bugs and makes them safe to share.

```
class Money
  amount: Decimal               // immutable after construction
  currency: Currency

  add(other: Money): Money
    guard currency == other.currency
    return new Money(amount + other.amount, currency)

  subtract(other: Money): Money
    guard currency == other.currency
    guard amount >= other.amount
    return new Money(amount - other.amount, currency)

  multiply(factor: Number): Money
    return new Money(amount * factor, currency)
```

### Self-Validation

A value object validates itself at construction. If the constructor succeeds, the value is valid. Invalid states are unrepresentable.

```
class Email
  address: String

  constructor(raw: String):
    guard raw matches email pattern else throw InvalidEmailError
    guard length(raw) <= 254 else throw InvalidEmailError
    address = lowercase(trim(raw))

  localPart(): String
    return address.split("@")[0]

  domain(): String
    return address.split("@")[1]
```

### Equality

Two value objects are equal when all their attributes are equal. No identity comparison.

```
class Money
  equals(other):
    return this.amount == other.amount
       and this.currency == other.currency
```

### Common Value Object Catalog

These domain concepts should almost always be value objects, not raw primitives:

| Concept | Instead of | Why |
|---------|-----------|-----|
| **Money** | number/decimal | Carries currency, prevents mixed-currency arithmetic |
| **Email** | string | Self-validates format, normalizes casing |
| **PhoneNumber** | string | Validates format, normalizes country code |
| **Address** | multiple strings | Groups related fields, validates completeness |
| **DateRange** | two dates | Enforces start < end, provides overlap/contains logic |
| **TimeSlot** | two times | Enforces start < end, prevents overlap |
| **Quantity** | integer | Enforces non-negative, provides arithmetic |
| **Percentage** | number | Enforces 0-100 range (or 0-1), prevents misuse |
| **Typed ID** (OrderId, CustomerId) | string/UUID | Prevents passing wrong ID type to wrong method |
| **Status** | string/enum | Encapsulates valid transitions, prevents invalid states |

### Code Example: Typed Identifier

```
class OrderId
  value: UUID

  constructor(raw: UUID):
    guard raw is not null
    value = raw

  static generate(): OrderId
    return new OrderId(UUID.random())

  static from(raw: String): OrderId
    return new OrderId(UUID.parse(raw))

  equals(other: OrderId): Boolean
    return this.value == other.value

  toString(): String
    return value.toString()
```

Typed identifiers prevent a class of bugs where a CustomerId is accidentally passed where an OrderId is expected. The type system catches this at compile time.

### Code Example: Status as Value Object with Behavior

```
class OrderStatus
  value: String                // DRAFT, CONFIRMED, SHIPPED, DELIVERED, CANCELLED

  static DRAFT = new OrderStatus("DRAFT")
  static CONFIRMED = new OrderStatus("CONFIRMED")
  static SHIPPED = new OrderStatus("SHIPPED")
  static DELIVERED = new OrderStatus("DELIVERED")
  static CANCELLED = new OrderStatus("CANCELLED")

  canTransitionTo(target: OrderStatus): Boolean
    allowed = {
      DRAFT: [CONFIRMED, CANCELLED],
      CONFIRMED: [SHIPPED, CANCELLED],
      SHIPPED: [DELIVERED],
      DELIVERED: [],
      CANCELLED: []
    }
    return target in allowed[this.value]

  transitionTo(target: OrderStatus): OrderStatus
    guard canTransitionTo(target) else throw InvalidStatusTransitionError(this, target)
    return target
```

---

## 4. Domain Service Rules

### When to Use

A domain service encapsulates business logic that **spans multiple entities or value objects** and has no natural home in any single one. The key test: if the logic operates on data from multiple aggregates or entities and no single entity "owns" the computation, it belongs in a domain service.

### When NOT to Use

- **Single-entity logic** → belongs in the entity itself
- **Orchestration and workflow coordination** → belongs in application service
- **I/O operations** (database, HTTP, messaging) → belongs in infrastructure
- **Data transformation for external consumers** → belongs in application service or mapper

### Statelessness

Domain services are stateless. They receive everything they need as parameters and return results. No internal state, no retained references to entities.

### Pure Domain — No I/O

A domain service performs pure business computation. It does not call databases, APIs, or file systems. If the logic requires external data, the application service fetches that data and passes it to the domain service.

### The Distinction: Domain Service vs Application Service

| Aspect | Domain Service | Application Service |
|--------|---------------|-------------------|
| **Contains** | Business rules and computations | Workflow orchestration |
| **State** | Stateless | Stateless |
| **I/O** | None — pure computation | Coordinates I/O via infrastructure |
| **Dependencies** | Other domain objects only | Domain + infrastructure interfaces |
| **Example** | Calculate price given product, customer tier, and discount rules | Fetch product from repo, fetch customer, call pricing service, save order |

### Code Example: PricingService

```
// Domain Service — pure business computation, no I/O
class PricingService

  calculatePrice(product: Product, customerTier: CustomerTier, discountRules: List<DiscountRule>): Money
    basePrice = product.basePrice()
    tierDiscount = customerTier.discountPercentage()
    priceAfterTier = basePrice.multiply(1 - tierDiscount.value)

    for each rule in discountRules:
      if rule.appliesTo(product):
        priceAfterTier = rule.apply(priceAfterTier)

    guard priceAfterTier.isPositive()
    return priceAfterTier
```

### Code Example: What Does NOT Belong in a Domain Service

```
// WRONG: This is orchestration — it belongs in an application service
class PricingService
  constructor(productRepo, customerRepo, discountRepo)

  calculatePrice(productId, customerId):
    product = productRepo.findById(productId)       // I/O — not domain
    customer = customerRepo.findById(customerId)     // I/O — not domain
    discounts = discountRepo.findActive()            // I/O — not domain
    return compute(product, customer.tier, discounts)

// RIGHT: Application service orchestrates, domain service computes
class OrderApplicationService
  constructor(productRepo, customerRepo, discountRepo, pricingService)

  createOrder(command):
    product = productRepo.findById(command.productId)
    customer = customerRepo.findById(command.customerId)
    discounts = discountRepo.findActive()
    price = pricingService.calculatePrice(product, customer.tier, discounts)
    order = Order.create(command.customerId, product, price)
    orderRepo.save(order)
```

---

## 5. Domain Event Patterns

### Naming Convention

Domain events are named in **past tense** — they describe something that has already happened in the domain. They are facts, not commands.

| Good | Bad |
|------|-----|
| OrderPlaced | PlaceOrder (command, not event) |
| PaymentReceived | ProcessPayment (command) |
| InventoryReserved | ReserveInventory (command) |
| CustomerDeactivated | DeactivateCustomer (command) |
| ShipmentDelivered | DeliverShipment (command) |

### Payload

An event carries enough data to describe what happened without requiring the consumer to query back for details:

- **Aggregate ID**: Which aggregate changed
- **Relevant values**: The data that describes the change
- **Timestamp**: When it happened
- **Optional**: Correlation ID for tracing, actor/user ID

Do not put the entire aggregate state in the event. Include only what consumers need.

### When to Raise Events

- **Cross-aggregate coordination**: OrderConfirmed → InventoryService reserves stock
- **Notification concerns**: PaymentReceived → send confirmation email
- **Audit trail**: Any significant state change that business stakeholders would want to track
- **Eventual consistency**: When two aggregates must eventually reflect the same business fact

Do NOT raise events for trivial internal state changes that nothing else reacts to.

### Where Events Live

Domain events are **defined in the domain layer** — they are part of the ubiquitous language. They are published by the aggregate (collected during the operation) or by the application service after persisting.

### Not Event Sourcing

The default approach is domain events for **communication and coordination**, not as the persistence mechanism. Aggregates are persisted through their repositories to a database. Events are a side channel for notifying other parts of the system.

Event sourcing (persisting events as the source of truth and rebuilding state from them) is a separate architectural choice with its own trade-offs. Do not conflate the two.

### Code Example: OrderConfirmed Event

```
class OrderConfirmed                          // Domain Event
  orderId: OrderId
  customerId: CustomerId
  totalAmount: Money
  confirmedAt: Timestamp

  constructor(orderId, customerId, totalAmount, confirmedAt):
    this.orderId = orderId
    this.customerId = customerId
    this.totalAmount = totalAmount
    this.confirmedAt = confirmedAt
```

### Code Example: Raising Events from an Aggregate

```
class Order
  id: OrderId
  status: OrderStatus
  domainEvents: List<DomainEvent>             // collected, not published yet

  confirm():
    guard status is DRAFT
    guard lineItems is not empty
    status = CONFIRMED
    domainEvents.add(new OrderConfirmed(id, customerId, total(), now()))

  pullDomainEvents(): List<DomainEvent>
    events = copy(domainEvents)
    domainEvents.clear()
    return events
```

The application service persists the aggregate, then publishes collected events:

```
class OrderApplicationService
  constructor(orderRepo, eventPublisher)

  confirmOrder(orderId):
    order = orderRepo.findById(orderId)
    order.confirm()
    orderRepo.save(order)
    eventPublisher.publishAll(order.pullDomainEvents())
```

---

## 6. Repository Patterns

### One Per Aggregate Root

Repositories exist for aggregate roots only — not for internal entities or value objects. If `LineItem` is inside the `Order` aggregate, there is no `LineItemRepository`. You save and load the entire Order aggregate through `OrderRepository`.

### Collection Semantics

Think of a repository as an in-memory collection of aggregates. The interface should feel like adding to, finding in, and removing from a collection — not like issuing SQL queries.

```
interface OrderRepository
  save(order: Order): void
  findById(id: OrderId): Order or null
  findByCustomerId(customerId: CustomerId): List<Order>
  remove(order: Order): void
```

### Interface in Domain, Implementation in Infrastructure

The repository interface is defined in the domain layer — it is a port. The implementation lives in infrastructure and handles the actual persistence mechanics (SQL, ORM, document store). This is already enforced by Clean Architecture; DDD defines the semantic contract.

### Returns Fully-Constituted Aggregates

A repository returns complete aggregates with all internal entities and value objects properly assembled. Never partial objects, never DTOs, never raw database rows. The consumer receives a ready-to-use domain object with all invariants already satisfied.

```
// WRONG: Returning partial or raw data
interface OrderRepository
  findById(id: OrderId): OrderDAO              // raw data, not domain
  findOrderWithoutItems(id: OrderId): Order    // partial aggregate

// RIGHT: Full aggregate
interface OrderRepository
  findById(id: OrderId): Order or null         // complete aggregate
```

### What Does NOT Belong in a Repository

- **Complex reporting queries**: Multi-table joins, aggregations, analytics → use a Provider (Clean Architecture query flow)
- **Bulk operations**: Mass updates, batch deletes → use infrastructure-level operations
- **Search with complex filters**: Full-text search, faceted queries → use a Provider or dedicated search infrastructure

The repository's job is to persist and reconstitute aggregates for command operations. Read-optimized queries belong in Providers.

### Code Example: Repository Interface

```
interface OrderRepository
  save(order: Order): void
  findById(id: OrderId): Order or null
  remove(order: Order): void

interface CustomerRepository
  save(customer: Customer): void
  findById(id: CustomerId): Customer or null
  findByEmail(email: Email): Customer or null
```

### Code Example: Repository vs Provider

```
// Repository — for command flow, returns domain objects
interface OrderRepository                      // interface in domain/repositories/
  save(order: Order): void
  findById(id: OrderId): Order or null

// Provider — for query flow, returns DAOs
class OrderProvider                            // concrete class in infrastructure/providers/
  findOrderSummaries(customerId, page, size): List<OrderSummaryDAO>
  findOrderDetails(orderId): OrderDetailsDAO or null
  countOrdersByStatus(status): Integer
```

---

## 7. Factory Patterns

### When to Use

Use a factory when aggregate creation involves validation, multiple steps, or complex assembly that goes beyond a simple constructor. If creation is straightforward, a factory method on the aggregate root is sufficient.

### Two Purposes

1. **Initial creation**: Building a new aggregate for the first time, enforcing creation-time invariants
2. **Reconstitution**: Rebuilding an aggregate from persisted data (used by repository implementations)

### Factory Method on Aggregate Root

For most cases, a static factory method on the root is the simplest and best approach. It enforces creation invariants and returns a fully valid aggregate.

```
class Order
  static create(customerId: CustomerId, items: List<OrderItemRequest>): Order
    guard items is not empty else throw EmptyOrderError
    guard customerId is not null

    order = new Order(
      id: OrderId.generate(),
      customerId: customerId,
      status: OrderStatus.DRAFT,
      lineItems: [],
      createdAt: now()
    )

    for each item in items:
      order.addLineItem(item.productId, item.quantity, item.unitPrice)

    return order
```

### Standalone Factory

Use a standalone factory when creation requires data from multiple sources or when the assembly logic is complex enough to warrant its own class.

```
class LoanApplicationFactory
  constructor(creditScoreService: CreditScoreService, riskPolicy: RiskPolicy)

  create(applicant: Applicant, requestedAmount: Money, term: LoanTerm): LoanApplication
    creditScore = creditScoreService.scoreFor(applicant)
    riskLevel = riskPolicy.assess(creditScore, requestedAmount, term)

    guard riskLevel is not PROHIBITED else throw LoanProhibitedError

    return new LoanApplication(
      id: LoanApplicationId.generate(),
      applicantId: applicant.id,
      requestedAmount: requestedAmount,
      term: term,
      riskLevel: riskLevel,
      status: LoanApplicationStatus.PENDING
    )
```

Note: The `creditScoreService` here is a domain service (pure computation from applicant data), not an infrastructure call. If external I/O is needed to get the credit score, the application service should fetch it first and pass it in.

### Reconstitution Factory

Repository implementations use reconstitution to rebuild aggregates from stored data. This bypasses creation-time validation (the data was already valid when first persisted) but reconstructs all internal structure.

```
class Order
  // Used by repository to rebuild from persistence — skips creation invariants
  static reconstitute(id, customerId, status, lineItems, createdAt): Order
    return new Order(id, customerId, status, lineItems, createdAt)
```

---

## 8. Anti-Pattern Catalog

Each anti-pattern with a "wrong" and "right" example in pseudocode.

### 8.1 Anemic Domain Model

**Symptom**: Entities are data holders with getters and setters. All business logic lives in services.

```
// WRONG: Entity is just data
class Order
  id: OrderId
  status: String
  total: Decimal
  // no behavior — just fields

class OrderService
  confirmOrder(orderId):
    order = repo.findById(orderId)
    if order.status != "DRAFT":
      throw InvalidStatusError
    if order.total <= 0:
      throw InvalidTotalError
    order.status = "CONFIRMED"
    repo.save(order)

// RIGHT: Entity owns its rules
class Order
  id: OrderId
  status: OrderStatus
  lineItems: List<LineItem>

  confirm():
    guard status is DRAFT else throw InvalidStatusTransitionError
    guard lineItems is not empty else throw EmptyOrderError
    status = OrderStatus.CONFIRMED
    raise OrderConfirmed(id, total(), now())

  total(): Money
    return lineItems.sum(item => item.subtotal())
```

### 8.2 Primitive Obsession

**Symptom**: Domain concepts represented as raw strings, numbers, or UUIDs. Validation scattered everywhere.

```
// WRONG: Primitives everywhere
class Customer
  id: String
  email: String
  phone: String

  // Validation duplicated in every service that touches email
  // Nothing prevents passing phone where email is expected

// RIGHT: Value objects
class Customer
  id: CustomerId
  email: Email
  phone: PhoneNumber

class Email
  address: String

  constructor(raw):
    guard raw matches email pattern
    address = lowercase(trim(raw))

class CustomerId
  value: UUID

  constructor(raw):
    guard raw is valid UUID
    value = raw
```

### 8.3 God Aggregate

**Symptom**: One aggregate with many internal entities, slow to load, high contention, frequently modified for unrelated reasons.

```
// WRONG: Everything crammed into Order
class Order
  lineItems: List<LineItem>
  payments: List<Payment>
  shipment: Shipment
  invoice: Invoice
  reviews: List<Review>
  returnRequests: List<ReturnRequest>

  // Methods for 6 different concerns, invariants are tangled

// RIGHT: Separate aggregates by invariant boundary
class Order                    // Order aggregate: lineItems + order-level invariants
  lineItems: List<LineItem>
  status: OrderStatus

class Payment                  // Payment aggregate
  id: PaymentId
  orderId: OrderId             // reference by ID
  amount: Money
  status: PaymentStatus

class Shipment                 // Shipment aggregate
  id: ShipmentId
  orderId: OrderId             // reference by ID
  trackingNumber: TrackingNumber

class Review                   // Review aggregate
  id: ReviewId
  orderId: OrderId             // reference by ID
  rating: Rating
  comment: ReviewText
```

### 8.4 Cross-Aggregate Transaction

**Symptom**: A single operation updates multiple aggregates in one database transaction.

```
// WRONG: Two aggregates in one transaction
class OrderService
  placeOrder(command):
    order = Order.create(command)
    inventory.reserve(order.lineItems)   // modifies Inventory aggregate
    orderRepo.save(order)
    inventoryRepo.save(inventory)        // two aggregates, one transaction
    // If either save fails, both roll back — tight coupling

// RIGHT: One aggregate per transaction, domain event for coordination
class OrderService
  placeOrder(command):
    order = Order.create(command)
    orderRepo.save(order)
    // Order.create raised OrderPlaced event

class InventoryEventHandler
  on(event: OrderPlaced):
    inventory = inventoryRepo.findForProducts(event.productIds)
    inventory.reserve(event.lineItems)
    inventoryRepo.save(inventory)
    // Separate transaction — eventual consistency
    // If reservation fails, raise ReservationFailed for compensation
```

### 8.5 Leaking Domain Logic

**Symptom**: Business rules live in controllers, application services, or infrastructure instead of domain objects.

```
// WRONG: Business rule in controller
class OrderController
  cancelOrder(request):
    order = orderService.findById(request.orderId)
    if order.status == "SHIPPED":
      return Error("Cannot cancel shipped order")  // business rule in controller
    if daysBetween(order.createdAt, now()) > 30:
      return Error("Cancellation window expired")  // business rule in controller
    orderService.cancel(order)

// RIGHT: Business rule in domain
class Order
  cancel():
    guard status is not SHIPPED else throw CannotCancelShippedOrderError
    guard withinCancellationWindow() else throw CancellationWindowExpiredError
    status = OrderStatus.CANCELLED
    raise OrderCancelled(id, now())

  withinCancellationWindow(): Boolean
    return daysBetween(createdAt, now()) <= 30
```

### 8.6 Misidentified Entity vs Value Object

**Symptom**: Something treated as an entity (with repository, identity tracking) when it has no lifecycle, or a value object treated as an entity when it should be immutable and defined by attributes.

```
// WRONG: Address treated as entity with its own repository
class Address
  id: AddressId               // unnecessary identity
  street: String
  city: String
  zip: String

class AddressRepository       // unnecessary repository
  save(address)
  findById(id)

// RIGHT: Address is a value object — defined by its attributes, no identity
class Address
  street: String
  city: String
  zip: String
  country: Country

  constructor(street, city, zip, country):
    guard street is not blank
    guard zip matches country.zipPattern
    // all fields set, immutable after construction

  equals(other):
    return this.street == other.street
       and this.city == other.city
       and this.zip == other.zip
       and this.country == other.country
```

The identity test: *Does the business track individual instances of this concept over time?* If you have two addresses with identical street/city/zip, are they "the same address" or "two different addresses"? If the same — it is a value object.

---

## 9. Decomposition Guide

### Warning Signals

An aggregate needs decomposition when:

1. **Too many internal entities** (more than 3-5): Question whether they all share a transactional invariant with the root.
2. **Multiple unrelated invariants**: Rules that never reference each other's entities probably belong in separate aggregates.
3. **Methods that touch only a subset**: If root methods only operate on some internal entities, that subset may be its own aggregate.
4. **Slow loading**: "I need to load everything to validate one thing" — the boundary is too coarse.
5. **High contention**: Multiple users frequently conflict on the same aggregate because they are modifying unrelated parts.
6. **Growing entity count**: New features keep adding entities to the aggregate rather than creating new aggregates.

### Step-by-Step Decomposition

1. **List all invariants** the aggregate root currently enforces.
2. **Group entities by invariant participation**: Which entities are involved in which invariants?
3. **Identify independent groups**: Entities that participate in separate, non-overlapping invariants are candidates for extraction.
4. **Extract to new aggregate**: Create a new aggregate root for the extracted group. Replace the direct reference with an ID reference.
5. **Add domain events**: If the original aggregate needs to react to changes in the extracted aggregate (or vice versa), use domain events.
6. **Verify**: Each resulting aggregate should be loadable and savable independently. No cross-aggregate invariant should require a shared transaction.

### Before/After Example

Before — `Course` aggregate manages both enrollment and grading:

```
class Course                               // God aggregate
  id: CourseId
  title: String
  maxEnrollment: Integer
  enrollments: List<Enrollment>            // invariant: count <= maxEnrollment
  gradebook: Gradebook                     // separate concern
  assignments: List<Assignment>            // separate concern

  enroll(studentId):
    guard enrollments.count < maxEnrollment
    enrollments.add(new Enrollment(studentId))

  gradeAssignment(studentId, assignmentId, score):
    // touches only gradebook/assignments — never enrollment
    gradebook.record(studentId, assignmentId, score)
```

After — enrollment and grading are separate aggregates:

```
class Course                               // Enrollment aggregate
  id: CourseId
  title: String
  maxEnrollment: Integer
  enrollments: List<Enrollment>

  enroll(studentId):
    guard enrollments.count < maxEnrollment
    enrollments.add(new Enrollment(studentId))
    raise StudentEnrolled(id, studentId)

class CourseGradebook                      // Grading aggregate
  id: GradebookId
  courseId: CourseId                        // reference by ID
  assignments: List<Assignment>
  grades: List<Grade>

  gradeAssignment(studentId, assignmentId, score):
    guard assignments contains assignmentId
    grades.add(new Grade(studentId, assignmentId, score))
```

Each aggregate loads independently. Enrollment contention does not block grading. New grading features do not risk breaking enrollment invariants.

---

## 10. Validation Checklist — Detailed

Use after generating or reviewing domain code. Grouped by pattern.

### Aggregate Checks

- [ ] Each aggregate has a clearly identified root entity
- [ ] Only the root is accessible from outside the aggregate
- [ ] Internal entities are not referenced directly by external code
- [ ] Other aggregates are referenced by ID, not by object
- [ ] Each aggregate fits within a single transaction
- [ ] No more than ~3-5 internal entities (if more, question the boundary)
- [ ] Every internal entity participates in at least one invariant enforced by the root

### Entity Checks

- [ ] Each entity has a typed identifier (value object, not raw string/UUID)
- [ ] Equality is based on identity, not attributes
- [ ] Business rules are methods on the entity, not in external services
- [ ] State transitions enforce preconditions (guard clauses)
- [ ] No public setters that bypass business rules

### Value Object Checks

- [ ] Value objects are immutable — operations return new instances
- [ ] Self-validating constructors — invalid states are unrepresentable
- [ ] Equality is based on attributes, not identity
- [ ] Primitives for domain concepts are replaced with value objects (Money, Email, OrderId)
- [ ] No identity field (id) on value objects

### Domain Service Checks

- [ ] Stateless — no internal state retained between calls
- [ ] Pure domain computation — no I/O, no infrastructure dependencies
- [ ] Logic genuinely spans multiple entities or value objects
- [ ] Not duplicating logic that belongs in a single entity

### Domain Event Checks

- [ ] Named in past tense (OrderPlaced, not PlaceOrder)
- [ ] Carries sufficient data to describe what happened (aggregate ID + relevant values)
- [ ] Does not carry entire aggregate state
- [ ] Raised for cross-aggregate coordination and significant state changes
- [ ] Defined in domain layer

### Repository Checks

- [ ] One repository per aggregate root — not per entity
- [ ] Interface defined in domain layer, implementation in infrastructure
- [ ] Collection-like semantics (save, findById, remove)
- [ ] Returns fully-constituted aggregates, not partial objects or DTOs
- [ ] No complex reporting queries — those belong in Providers

---

*These defaults synthesize principles from Eric Evans's Domain-Driven Design (2003), Vaughn Vernon's Implementing Domain-Driven Design (2013) and Domain-Driven Design Distilled (2016), and practical aggregate design heuristics from the DDD community.*
