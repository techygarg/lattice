# Domain-Driven Design: Default Principles

Embedded defaults DDD tactical patterns. Synthesize Evans Domain-Driven Design, Vernon Implementing Domain-Driven Design, practical aggregate heuristics → actionable rules.

Embedded defaults. See SKILL.md Config Resolution project overrides.

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

---

## 1. Aggregate Design Rules

Aggregate boundaries hardest design decision DDD. Everything follows getting right.

### Consistency Boundary Principle

Aggregate = objects **must** immediately consistent after every transaction. Not "related things." Not "share db table." Specifically: objects whose combined state must satisfy invariant checked atomically.

Ask: *"If entity changes, what else MUST valid same instant?"* Only those belong same aggregate.

### Sizing Heuristic

Start **smallest possible aggregate**: root entity + value objects. Add internal entities only when transactional invariant forces inside. Debating whether belongs? Almost certainly not.

Small aggregates load fast, conflict rarely, scale well. Large aggregates slow, contended, fragile.

### Reference by Identity

Aggregates reference other aggregates ID only — never direct object reference. Object references create hidden coupling, expand transaction scope, make impossible distribute independently.

```
// WRONG: Order holds a direct reference to Customer
class Order
  customer: Customer          // pulls Customer into Order's transaction scope

// RIGHT: Order holds Customer's identity
class Order
  customerId: CustomerId      // loose coupling, separate transaction scopes
```

### One Transaction Rule

Each aggregate defines one transaction boundary. Single business operation modify at most one aggregate per transaction. Need two aggregates updated atomically? Either boundary wrong (merge) or accept eventual consistency via domain events.

### Invariant Ownership

Every business rule belongs exactly one aggregate — one whose root enforces. Rule spans two aggregates? One of three true:
1. Boundary wrong — should be one aggregate.
2. One aggregate can own rule by receiving other's state as value (not reference).
3. Rule eventual consistency concern — enforce via domain events + compensating actions.

### Code Example: Order Aggregate with LineItems

LineItems inside Order aggregate because invariant "order total must equal sum line item subtotals" requires atomic consistency.

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

Customer separate aggregate referenced by `CustomerId`. Own lifecycle, invariants, transaction boundary. Loading Order never require loading Customer.

### Code Example: Decomposing a God Aggregate

Before — Shipment incorrectly inside Order:

```
class Order
  lineItems: List<LineItem>
  shipment: Shipment          // no shared invariant with lineItems
  trackingHistory: List<TrackingEvent>  // grows independently of Order
```

After — Shipment extracted own aggregate:

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

Order + Shipment evolve independently. Shipment delivered? Domain event notify Order context if needed.

---

## 2. Entity Patterns

### Identity

Entity has persistent identity survives state changes. Order remains same Order whether status DRAFT or CONFIRMED. Identity typically typed identifier (value object wrapping raw ID).

### Equality

Two entities equal iff same identity — regardless attribute values. Order id=123 same entity whether total $50 or $500.

```
class Entity
  equals(other):
    return this.id == other.id

  hashCode():
    return hash(this.id)
```

### Behavior-Rich Entities

Entities encapsulate business rules as methods. Entity has only getters/setters? Logic leaked elsewhere (typically application services).

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

Entities have lifecycle: creation → state transitions → possible deactivation/completion. Each transition enforce preconditions.

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

Value object no identity. Defined entirely by attributes. Two Money objects amount=10 currency=USD same Money — no "which one."

### Immutability

Value objects never change after creation. Operations "modify" return new instance. Eliminates aliasing bugs, safe share.

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

Value object validates self at construction. Constructor succeeds? Value valid. Invalid states unrepresentable.

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

Two value objects equal when all attributes equal. No identity comparison.

```
class Money
  equals(other):
    return this.amount == other.amount
       and this.currency == other.currency
```

### Common Value Object Catalog

Domain concepts should almost always be value objects, not raw primitives:

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

**Guardrail**: Wrap primitives carrying domain meaning, requiring validation, or preventing type-confusion bugs (Money, Email, typed IDs). Don't wrap low-significance values like pagination sizes, retry counts, version numbers -- overhead outweighs benefit.

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

Typed identifiers prevent bugs where CustomerId accidentally passed where OrderId expected. Type system catches compile time.

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

Domain service encapsulates business logic **spans multiple entities/value objects** and no natural home any single one. Key test: logic operates on data from multiple aggregates/entities and no single entity "owns" computation? Belongs domain service.

### When NOT to Use

- **Single-entity logic** → belongs in entity
- **Orchestration/workflow coordination** → belongs application service
- **I/O operations** (db, HTTP, messaging) → belongs infrastructure
- **Data transformation external consumers** → belongs application service/mapper

### Statelessness

Domain services stateless. Receive everything as parameters, return results. No internal state, no retained entity references.

### Pure Domain — No I/O

Domain service performs pure business computation. Not call databases, APIs, file systems. Logic requires external data? Application service fetches, passes to domain service.

### The Distinction: Domain Service vs Application Service

| Aspect | Domain Service | Application Service |
|--------|---------------|-------------------|
| **Contains** | Business rules + computations | Workflow orchestration |
| **State** | Stateless | Stateless |
| **I/O** | None — pure computation | Coordinates I/O via infrastructure |
| **Dependencies** | Other domain objects only | Domain + infrastructure interfaces |
| **Example** | Calculate price given product, customer tier, discount rules | Fetch product from repo, fetch customer, call pricing service, save order |

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

Domain events named **past tense** — describe what already happened domain. Facts, not commands.

| Good | Bad |
|------|-----|
| OrderPlaced | PlaceOrder (command, not event) |
| PaymentReceived | ProcessPayment (command) |
| InventoryReserved | ReserveInventory (command) |
| CustomerDeactivated | DeactivateCustomer (command) |
| ShipmentDelivered | DeliverShipment (command) |

### Payload

Event carries enough data describe what happened without requiring consumer query back details:

- **Aggregate ID**: Which aggregate changed
- **Relevant values**: Data describing change
- **Timestamp**: When happened
- **Optional**: Correlation ID tracing, actor/user ID

Don't put entire aggregate state in event. Include only what consumers need.

### When to Raise Events

- **Cross-aggregate coordination**: OrderConfirmed → InventoryService reserves stock
- **Notification concerns**: PaymentReceived → send confirmation email
- **Audit trail**: Significant state changes stakeholders want track
- **Eventual consistency**: Two aggregates must eventually reflect same business fact

Don't raise events trivial internal state changes nothing reacts to.

### Where Events Live

Domain events **defined domain layer** — part ubiquitous language. Published by aggregate (collected during operation) or by application service after persisting.

### Not Event Sourcing

Default approach: domain events for **communication + coordination**, not persistence mechanism. Aggregates persisted through repositories to database. Events side channel notifying other parts system.

Event sourcing (persisting events as source truth, rebuilding state from them) separate architectural choice, own trade-offs. Don't conflate two.

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

Application service persists aggregate, then publishes collected events:

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

Repositories exist aggregate roots only — not internal entities/value objects. `LineItem` inside `Order` aggregate? No `LineItemRepository`. Save/load entire Order aggregate through `OrderRepository`.

### Collection Semantics

Think repository as in-memory collection aggregates. Interface feel like adding to, finding in, removing from collection — not issuing SQL queries.

```
interface OrderRepository
  save(order: Order): void
  findById(id: OrderId): Order or null
  findByCustomerId(customerId: CustomerId): List<Order>
  remove(order: Order): void
```

### Interface in Domain, Implementation in Infrastructure

Repository interface defined domain layer — port. Implementation lives infrastructure, handles actual persistence mechanics (SQL, ORM, document store). Already enforced Clean Architecture; DDD defines semantic contract.

### Returns Fully-Constituted Aggregates

Repository returns complete aggregates all internal entities/value objects properly assembled. Never partial objects, DTOs, raw db rows. Consumer receives ready-to-use domain object, all invariants satisfied.

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

- **Complex reporting queries**: Multi-table joins, aggregations, analytics → use Provider (Clean Architecture query flow)
- **Bulk operations**: Mass updates, batch deletes → use infrastructure-level operations
- **Search with complex filters**: Full-text search, faceted queries → use Provider/dedicated search infrastructure

Repository job: persist + reconstitute aggregates command operations. Read-optimized queries belong Providers.

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

Use factory when aggregate creation involves validation, multiple steps, complex assembly beyond simple constructor. Creation straightforward? Factory method on aggregate root sufficient.

### Two Purposes

1. **Initial creation**: Building new aggregate first time, enforcing creation-time invariants
2. **Reconstitution**: Rebuilding aggregate from persisted data (used by repository implementations)

### Factory Method on Aggregate Root

Most cases: static factory method on root simplest/best approach. Enforces creation invariants, returns fully valid aggregate.

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

Use standalone factory when creation requires data from multiple sources or assembly logic complex enough warrant own class.

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

Note: `creditScoreService` here domain service (pure computation from applicant data), not infrastructure call. External I/O needed get credit score? Application service fetch first, pass in.

### Reconstitution Factory

Repository implementations use reconstitution rebuild aggregates from stored data. Bypasses creation-time validation (data already valid when first persisted) but reconstructs all internal structure.

```
class Order
  // Used by repository to rebuild from persistence — skips creation invariants
  static reconstitute(id, customerId, status, lineItems, createdAt): Order
    return new Order(id, customerId, status, lineItems, createdAt)
```

---

## 8. Anti-Pattern Catalog

Each anti-pattern with "wrong" + "right" example pseudocode.

### 8.1 Anemic Domain Model

**Symptom**: Entities data holders getters/setters. All business logic lives services.

```
// WRONG: Entity just data
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

// RIGHT: Entity owns rules
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

**Symptom**: Domain concepts as raw strings, numbers, UUIDs. Validation scattered everywhere.

```
// WRONG: Primitives everywhere
class Customer
  id: String
  email: String
  phone: String

  // Validation duplicated every service touches email
  // Nothing prevents passing phone where email expected

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

**Symptom**: One aggregate many internal entities, slow load, high contention, frequently modified unrelated reasons.

```
// WRONG: Everything crammed into Order
class Order
  lineItems: List<LineItem>
  payments: List<Payment>
  shipment: Shipment
  invoice: Invoice
  reviews: List<Review>
  returnRequests: List<ReturnRequest>

  // Methods for 6 different concerns, invariants tangled

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

**Symptom**: Single operation updates multiple aggregates one db transaction.

```
// WRONG: Two aggregates one transaction
class OrderService
  placeOrder(command):
    order = Order.create(command)
    inventory.reserve(order.lineItems)   // modifies Inventory aggregate
    orderRepo.save(order)
    inventoryRepo.save(inventory)        // two aggregates, one transaction
    // Either save fails? Both roll back — tight coupling

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
    // Reservation fails? Raise ReservationFailed for compensation
```

### 8.5 Leaking Domain Logic

**Symptom**: Business rules live controllers, application services, infrastructure instead domain objects.

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

// RIGHT: Business rule in domain, time injected testability
class Order
  cancel(currentTime):
    guard status is not SHIPPED else throw CannotCancelShippedOrderError
    guard withinCancellationWindow(currentTime) else throw CancellationWindowExpiredError
    status = OrderStatus.CANCELLED
    raise OrderCancelled(id, currentTime)

  withinCancellationWindow(currentTime): Boolean
    return daysBetween(createdAt, currentTime) <= 30
```

### 8.6 Misidentified Entity vs Value Object

**Symptom**: Something treated as entity (with repository, identity tracking) when no lifecycle, or value object treated as entity when should be immutable/defined by attributes.

```
// WRONG: Address treated as entity with own repository
class Address
  id: AddressId               // unnecessary identity
  street: String
  city: String
  zip: String

class AddressRepository       // unnecessary repository
  save(address)
  findById(id)

// RIGHT: Address value object — defined by attributes, no identity
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

Identity test: *Business track individual instances this concept over time?* Two addresses identical street/city/zip — "same address" or "two different addresses"? Same? Value object.

---

## 9. Decomposition Guide

### Warning Signals

Aggregate needs decomposition when:

1. **Too many internal entities** (>3-5): Question whether all share transactional invariant with root.
2. **Multiple unrelated invariants**: Rules never reference each other's entities probably belong separate aggregates.
3. **Methods touch only subset**: Root methods only operate some internal entities? Subset may be own aggregate.
4. **Slow loading**: "Load everything validate one thing" — boundary too coarse.
5. **High contention**: Multiple users frequently conflict same aggregate modifying unrelated parts.
6. **Growing entity count**: New features keep adding entities to aggregate rather creating new aggregates.

### Step-by-Step Decomposition

1. **List all invariants** aggregate root currently enforces.
2. **Group entities by invariant participation**: Which entities involved which invariants?
3. **Identify independent groups**: Entities participating separate non-overlapping invariants = extraction candidates.
4. **Extract to new aggregate**: Create new aggregate root extracted group. Replace direct reference with ID reference.
5. **Add domain events**: Original aggregate needs react changes in extracted aggregate (or vice versa)? Use domain events.
6. **Verify**: Each resulting aggregate loadable/savable independently. No cross-aggregate invariant require shared transaction.

### Before/After Example

Before — `Course` aggregate manages both enrollment + grading:

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

After — enrollment + grading separate aggregates:

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

Each aggregate loads independently. Enrollment contention not block grading. New grading features not risk breaking enrollment invariants.

---

*Defaults synthesize principles Evans Domain-Driven Design (2003), Vernon Implementing Domain-Driven Design (2013) + Domain-Driven Design Distilled (2016), practical aggregate design heuristics DDD community.*