# DDD Refiner Template

This template defines the structure of the `.lattice/standards/ddd-principles.md` output document. It contains all default content from the domain-driven-design atom's `defaults.md`, interleaved with interview guidance comments.

When producing the output, strip all `<!-- INTERVIEW GUIDANCE: -->` comments. The final document is a specification, not a conversation log.

---

## Frontmatter

<!-- INTERVIEW GUIDANCE:
Choose one of the two frontmatter options based on the user's chosen mode.
Default to overlay unless the user explicitly wants to redefine everything.
-->

Option A — Overlay mode (most common):

```yaml
---
mode: overlay
---
```

Option B — Override mode (complete replacement):

```yaml
---
mode: override
---
```

---

## Preamble

<!-- INTERVIEW GUIDANCE:
Include the preamble matching the chosen mode. Only one preamble appears in the output.
-->

**Overlay preamble:**

> This document overlays project-specific customizations on top of the domain-driven-design atom's embedded defaults. Only sections included here differ from the defaults — all other sections remain as-is.
>
> Sections below replace matching sections in the defaults (matched by heading). New sections are appended after defaults.

**Override preamble:**

> These are the domain-driven design principles for [PROJECT NAME]. They fully replace the embedded defaults in the domain-driven-design atom.

**Table of contents** (for override mode; overlay mode only lists included sections):

1. [Aggregate Design Rules](#1-aggregate-design-rules)
2. [Entity Patterns](#2-entity-patterns)
3. [Value Object Patterns](#3-value-object-patterns)
4. [Domain Service Rules](#4-domain-service-rules)
5. [Domain Event Patterns](#5-domain-event-patterns)
6. [Repository Patterns](#6-repository-patterns)
7. [Object Creation Patterns](#7-object-creation-patterns)
8. [Decomposition Guide](#8-decomposition-guide)
9. [Validation Checklist — Detailed](#9-validation-checklist--detailed)

---

## 1. Aggregate Design Rules

<!-- INTERVIEW GUIDANCE:
Ask: "How do you think about aggregate boundaries? Here's the default approach — aggregates are consistency boundaries, not convenience groupings. Does this match your team's thinking?"

Show the consistency boundary principle and sizing heuristic.

Probing questions:
- How large are your current aggregates? Do any feel too big or too slow to load?
- Do you have cases where a single transaction updates multiple aggregates?
- How do you handle eventual consistency between aggregates? Domain events? Sagas?
- Do you have any aggregates that are frequently contended by multiple users?

Customizable: Sizing thresholds, reference-by-ID exceptions, transaction boundary approach, code examples.
Fixed: The consistency boundary principle is non-negotiable. Aggregates must enforce invariants through the root.

Cross-section impact: Aggregate boundaries defined here affect §6 (one repository per aggregate root), §5 (cross-aggregate events), and §8 (decomposition triggers).
-->

Aggregate boundaries are the single hardest design decision in DDD. Everything else follows from getting them right.

### Consistency Boundary Principle

An aggregate is the set of objects that **must** be immediately consistent after every transaction. Not "things that are related." Not "things that share a database table." Specifically: the objects whose combined state must satisfy an invariant that is checked atomically.

Ask: *"If this entity changes, what else MUST be valid in the same instant?"* Only those objects belong in the same aggregate.

### Sizing Heuristic

Start with the **smallest possible aggregate**: a root entity plus its value objects. Add internal entities only when a transactional invariant forces them inside. If you are debating whether something belongs inside, it almost certainly does not.

Small aggregates load fast, conflict rarely, and scale well. Large aggregates are slow, contended, and fragile.

**Anti-pattern — God Aggregate**: Many internal entities, slow load, high contention → decompose. Keep only what shares transactional invariant.

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

**Anti-pattern — Cross-Aggregate Transaction**: Updating two aggregates in one transaction → use domain event + eventual consistency.

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

<!-- INTERVIEW GUIDANCE:
Ask: "How do you handle entity identity and lifecycle? The default: entities have typed identifiers, behavior-rich methods, and enforced state transitions. Does this match your project?"

Probing questions:
- Do your entities currently have behavior or are they mostly data holders (anemic)?
- How do you handle identity — typed IDs, raw UUIDs, database-generated IDs?
- Do you use state machines for entity lifecycle transitions?
- Are there domain-specific lifecycle patterns (e.g., approval workflows, multi-step processes)?

Customizable: Identity strategy, lifecycle patterns, specific guard clause conventions, code examples.
Fixed: Entities must have identity-based equality and must encapsulate behavior (not be anemic).

Cross-section impact: Entity identity patterns affect §3 (typed ID value objects), §6 (repository findById signatures).
-->

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

**Anti-pattern — Anemic Domain Model**: Entity data holder only getter/setter; all logic in services → move business rules into entity.

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

<!-- INTERVIEW GUIDANCE:
Ask: "Which domain concepts in your project should be value objects instead of primitives? Here are common ones. Which apply, and what would you add?"

Show the common value object catalog table.

Probing questions:
- Do you currently use raw strings/numbers for domain concepts like money, email, IDs?
- Are there domain-specific value objects unique to your business (e.g., PolicyNumber, ISIN, SKU)?
- How strict should validation be at construction time?
- Do you use typed IDs for aggregate roots? For all entities?

Customizable: Value object catalog (add/remove items), validation strictness, specific value object implementations.
Fixed: Value objects must be immutable and self-validating. Equality must be attribute-based.

Cross-section impact: Value objects chosen here are used throughout §1 (aggregate examples), §2 (typed IDs).
-->

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

**Anti-pattern — Primitive Obsession**: Raw string email, number money, UUID ID → wrap value object.

**Anti-pattern — Misidentified Entity/Value Object**: Apply identity test — *"Business track individual instances over time?"* Same attributes = same thing? Value object. Different lifecycle per instance? Entity.

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

<!-- INTERVIEW GUIDANCE:
Ask: "Do you use domain services for business logic that spans multiple entities? Here's the default rule: domain services are stateless, pure-computation, no I/O. Does this match?"

Show the domain service vs application service comparison table.

Probing questions:
- Do you have business logic that spans multiple entities today? Where does it live?
- Is there confusion in your team about what belongs in a domain service vs an application service?
- Do any of your current "domain services" make database or API calls? (That would make them application services.)

Customizable: Examples, naming conventions, specific domain service patterns for the project.
Fixed: Domain services must be stateless and pure (no I/O). The distinction from application services is non-negotiable.
-->

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

**Anti-pattern — Leaking Domain Logic**: Business rule in controller or application service → extract to domain object or domain service.

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

<!-- INTERVIEW GUIDANCE:
Ask: "When should domain events be raised in your project? The default: past-tense naming, carry enough data, used for cross-aggregate coordination. Does this match?"

Probing questions:
- Do you currently use domain events? If so, what naming convention?
- How do you handle cross-aggregate coordination today? Direct calls? Events? Sagas?
- Do you need event sourcing, or just domain events for communication?
- What events matter in your domain? What state changes do other parts of the system react to?

Customizable: Naming conventions, payload structure, event publishing strategy, specific domain events.
Fixed: Events must be past-tense facts (not commands). Events must be defined in the domain layer.

Cross-section impact: Domain events defined here are used in §1 (cross-aggregate coordination).
-->

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

<!-- INTERVIEW GUIDANCE:
Ask: "How do you handle persistence for your aggregates? The default: one repository per aggregate root, collection semantics, interface in domain, returns full aggregates. Does this match?"

Probing questions:
- Do you have repositories for non-root entities? (That would be a violation.)
- Do your repositories return partial objects or DTOs? (Should return full aggregates.)
- Do you use the Provider pattern (from Clean Architecture) for read-optimized queries, or do all queries go through repositories?
- How do you handle complex reporting queries?

Customizable: Repository method conventions, query patterns, specific infrastructure choices.
Fixed: One repository per aggregate root. Interface in domain layer. Returns fully-constituted aggregates.

Cross-section impact: Repository patterns here must align with §1 (one per aggregate root), and integrate with Clean Architecture's Provider pattern for read flows.
-->

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

## 7. Object Creation Patterns

<!-- INTERVIEW GUIDANCE:
Ask: "How does your team handle aggregate creation? There are several valid approaches — factory methods on the aggregate root, standalone factory classes, builder pattern, or plain constructors. Which does your team prefer, or would you like guidance?"

This is an ambiguity signal in the DDD atom — no single pattern is prescribed. The interview should surface the team's preference.

Probing questions:
- Are your aggregate creation scenarios simple (constructor/factory method) or complex (multiple data sources, multi-step assembly)?
- Does your team already use a specific creation pattern (factory, builder)?
- Do you need reconstitution for rebuilding aggregates from persistence?
- Do you have creation workflows that involve external validation or data lookup?

Customizable: Creation pattern choice (factory method, standalone factory, builder, plain constructor), creation conventions, specific implementations.
Fixed: Creation must enforce creation-time invariants. Reconstitution must be separate from initial creation.
-->

Complex aggregate creation should encapsulate validation and assembly. Multiple valid approaches exist — creation pattern choice (factory method, standalone factory, builder) depends on assembly complexity and team conventions. See SKILL.md Ambiguity Signals.

### Static Factory Method (Most Common)

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

### Reconstitution

Repository implementations use reconstitution to rebuild aggregates from stored data. This bypasses creation-time validation (the data was already valid when first persisted) but reconstructs all internal structure.

```
class Order
  // Used by repository to rebuild from persistence — skips creation invariants
  static reconstitute(id, customerId, status, lineItems, createdAt): Order
    return new Order(id, customerId, status, lineItems, createdAt)
```

---

---

## 8. Decomposition Guide

<!-- INTERVIEW GUIDANCE:
Ask: "Have you had to break apart aggregates that grew too large? The default guide provides warning signals and a step-by-step decomposition process. Does this match your experience?"

Probing questions:
- Do you have any aggregates that feel too large or slow to load?
- How do you decide when something should be extracted from an aggregate?
- Do you have team-specific thresholds for aggregate size?

Customizable: Warning signal thresholds, decomposition steps, specific examples.
Fixed: The decomposition principle (separate by invariant boundary, not by convenience) is non-negotiable.

Note: Anti-patterns related to aggregate sizing (god aggregate, cross-aggregate transaction) are now inline in §1 Aggregate Design Rules.
-->

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

## 9. Validation Checklist — Detailed

<!-- INTERVIEW GUIDANCE:
Show the six groups below. Ask:
"Should the AI check all of these when generating or reviewing domain code? Any to add or remove?"

Customizable: Can add or remove individual checks. Can add new groups.
Fixed: Must have at least aggregate checks and entity checks groups.
-->

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

## New Sections

<!-- INTERVIEW GUIDANCE:
At the end of the interview, ask:
"Are there any project-specific sections you'd like to add that aren't covered by the defaults?
Common additions:
- Ubiquitous language glossary (term definitions shared between domain experts and developers)
- Bounded context boundaries (what's in scope, what's not)
- Event storming artifacts (if the team uses event storming for discovery)
- Domain-specific invariants catalog (project-specific business rules)
- Testing patterns for domain objects (how to test aggregates, value objects)"

If the user wants to add sections, number them starting from 10.
New sections work in both overlay and override mode.
-->

---

## Footer

<!-- INTERVIEW GUIDANCE:
Include project name, generation date, and mode indicator in the output.
Example:

---
*Generated for [PROJECT NAME] on [DATE]. Mode: [overlay|override].*
*Produced by the ddd-refiner skill.*
-->
