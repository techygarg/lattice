# Domain-Driven Design: Default Principles

Embedded defaults DDD tactical patterns. Opinionated guardrails — override via SKILL.md Config Resolution.

## 1. Aggregate Design Rules

### Consistency Boundary

Aggregate = objects **must** immediately consistent after every transaction. Not "related things." Specifically: objects whose combined state must satisfy invariant checked atomically.

Ask: *"If entity changes, what else MUST valid same instant?"* Only those belong same aggregate.

### Sizing Heuristic

Start **smallest possible aggregate**: root entity + value objects. Add internal entities only when transactional invariant forces. Debating whether belongs? Almost certainly not.

**Anti-pattern — God Aggregate**: Many internal entities, slow load, high contention → decompose. Keep only what share transactional invariant.

### Reference by Identity

Aggregates reference other aggregates ID only — never direct object reference.

```
class Order
  customerId: CustomerId      // ID reference, not Customer object
```

### One Transaction Rule

Single business operation modify at most one aggregate per transaction. Need two aggregates updated atomically? Boundary wrong (merge) or accept eventual consistency via domain events.

**Anti-pattern — Cross-Aggregate Transaction**: Updating two aggregates one transaction → use domain event + eventual consistency.

### Invariant Ownership

Every business rule belongs exactly one aggregate. Rule spans two aggregates?
1. Boundary wrong — should be one aggregate.
2. One aggregate own rule by receiving other's state as value (not reference).
3. Rule eventual consistency concern — enforce via domain events + compensating actions.

### Code Example: Order Aggregate

```
class Order                                   // Aggregate Root
  id: OrderId
  customerId: CustomerId                      // reference by ID
  status: OrderStatus
  lineItems: List<LineItem>                   // internal — shares transactional invariant

  static create(customerId, items):
    guard items is not empty
    order = new Order(OrderId.generate(), customerId, DRAFT, [])
    for each item in items:
      order.addLineItem(item.productId, item.quantity, item.unitPrice)
    return order

  addLineItem(productId, quantity, unitPrice):
    guard status is DRAFT
    guard quantity > 0
    lineItems.add(new LineItem(LineItemId.generate(), productId, quantity, unitPrice))

  confirm():
    guard lineItems is not empty
    guard status is DRAFT
    status = CONFIRMED
    raise OrderConfirmed(id, customerId, total(), now())

  total(): Money
    return lineItems.sum(item => item.subtotal())
```

---

## 2. Entity Patterns

Entity has persistent identity surviving state changes. Two entities equal iff same identity — regardless attribute values.

### Behavior-Rich Entities

Entities encapsulate business rules as methods. Guard state transitions, raise events, enforce invariants.

**Anti-pattern — Anemic Domain Model**: Entity data holder only getter/setter; all logic in services → move business rules into entity.

```
class Account
  balance: Money
  status: AccountStatus

  withdraw(amount):
    guard status is ACTIVE
    guard balance >= amount
    balance = balance.subtract(amount)
    raise FundsWithdrawn(id, amount, balance)
```

---

## 3. Value Object Patterns

Value objects: no identity, defined by attributes, immutable, self-validating at construction. Operations return new instances.

### Self-Validation

Constructor succeeds? Value valid. Invalid states unrepresentable.

```
class Email
  address: String

  constructor(raw):
    guard raw matches email pattern
    address = lowercase(trim(raw))
```

### Common Value Object Catalog

Wrap primitives carrying domain meaning, requiring validation, or preventing type-confusion bugs. Don't wrap low-significance values (pagination sizes, retry counts).

| Concept | Instead of | Why |
|---------|-----------|-----|
| **Money** | number/decimal | Carries currency, prevents mixed-currency arithmetic |
| **Email** | string | Self-validates format, normalizes casing |
| **Address** | multiple strings | Groups related fields, validates completeness |
| **DateRange** | two dates | Enforces start < end, provides overlap logic |
| **Quantity** | integer | Enforces non-negative, provides arithmetic |
| **Typed ID** (OrderId, CustomerId) | string/UUID | Prevents passing wrong ID type |
| **Status** | string/enum | Encapsulates valid transitions |

**Anti-pattern — Primitive Obsession**: Raw string email, number money, UUID ID → wrap value object.

**Anti-pattern — Misidentified Entity/Value Object**: Apply identity test — *"Business track individual instances over time?"* Same attributes = same thing? Value object. Different lifecycle per instance? Entity.

---

## 4. Domain Service Rules

Domain service: stateless business logic **spanning multiple entities/value objects** with no natural home in any single one.

### When to Use vs NOT

| Use Domain Service | Do NOT Use — Instead |
|---|---|
| Logic operates on data from multiple aggregates | Single-entity logic → entity method |
| Pure business computation, no I/O | Orchestration/workflow → application service |
| No single entity "owns" the computation | I/O operations → infrastructure |

### Pure Domain — No I/O

Domain service performs pure computation. Application service fetches data, passes to domain service.

```
// Domain Service — pure computation
class PricingService
  calculatePrice(product, customerTier, discountRules): Money
    basePrice = product.basePrice()
    tierDiscount = customerTier.discountPercentage()
    price = basePrice.multiply(1 - tierDiscount.value)
    for each rule in discountRules:
      if rule.appliesTo(product): price = rule.apply(price)
    guard price.isPositive()
    return price
```

**Anti-pattern — Leaking Domain Logic**: Business rule in controller or application service → extract to domain object or domain service.

---

## 5. Domain Event Patterns

Domain events: past tense, describe what already happened. Facts, not commands.

### Payload

Event carries aggregate ID, relevant values describing change, timestamp. Don't put entire aggregate state — include only what consumers need.

### When to Raise

- Cross-aggregate coordination (OrderConfirmed → reserve stock)
- Notification concerns (PaymentReceived → confirmation email)
- Audit trail for significant state changes
- Eventual consistency between aggregates

Don't raise events trivial internal changes nothing reacts to.

### Not Event Sourcing

Default: domain events for communication + coordination, not persistence mechanism. Aggregates persisted through repositories. Event sourcing separate architectural choice — don't conflate.

```
class Order
  domainEvents: List<DomainEvent>

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

---

## 6. Repository Patterns

### Core Rules

- **One per aggregate root** — not internal entities/value objects
- **Collection semantics** — interface feels like in-memory collection, not SQL queries
- **Interface in domain, implementation in infrastructure**
- **Returns fully-constituted aggregates** — never partial objects, DTOs, raw db rows

### What Does NOT Belong

Complex reporting queries, bulk operations, search with complex filters → use Provider (query flow). Repository job: persist + reconstitute aggregates for command operations.

```
// Repository — command flow, domain objects
interface OrderRepository
  save(order: Order): void
  findById(id: OrderId): Order or null
  remove(order: Order): void

// Provider — query flow, DAOs
class OrderProvider
  findOrderSummaries(customerId, page, size): List<OrderSummaryDAO>
```

---

## 7. Object Creation Patterns

Complex aggregate creation should encapsulate validation and assembly. Multiple valid approaches exist — creation pattern choice (factory method, standalone factory, builder) depends on assembly complexity and team conventions. See SKILL.md Ambiguity Signals.

### Static Factory Method (Most Common)

```
class Order
  static create(customerId, items):
    guard items is not empty
    order = new Order(OrderId.generate(), customerId, DRAFT, [])
    for each item in items:
      order.addLineItem(item.productId, item.quantity, item.unitPrice)
    return order
```

### Reconstitution

Repository implementations rebuild aggregates from stored data — bypass creation-time validation (data already valid when first persisted).

```
class Order
  static reconstitute(id, customerId, status, lineItems, createdAt): Order
    return new Order(id, customerId, status, lineItems, createdAt)
```

---

## 8. Decomposition Guide

### Warning Signals

1. **Too many internal entities** (>3-5): Question whether all share transactional invariant.
2. **Multiple unrelated invariants**: Rules never reference each other's entities.
3. **Methods touch only subset**: Root methods only operate some internal entities.
4. **Slow loading / High contention**: Boundary too coarse.

### Steps

1. List all invariants root enforces.
2. Group entities by invariant participation.
3. Identify independent groups — extraction candidates.
4. Extract to new aggregate, replace reference with ID.
5. Add domain events for cross-aggregate coordination.
6. Verify each aggregate loadable/savable independently.

### Example

```
// Before — Course manages enrollment + grading
class Course
  enrollments: List<Enrollment>    // invariant: count <= maxEnrollment
  gradebook: Gradebook             // separate concern — never touches enrollment

// After — separate aggregates
class Course                        // Enrollment aggregate
  enrollments: List<Enrollment>
  enroll(studentId):
    guard enrollments.count < maxEnrollment
    raise StudentEnrolled(id, studentId)

class CourseGradebook               // Grading aggregate
  courseId: CourseId                 // reference by ID
  assignments: List<Assignment>
  grades: List<Grade>
```

---

*Defaults synthesize Evans Domain-Driven Design, Vernon Implementing Domain-Driven Design, practical aggregate design heuristics.*