# Clean Code: Default Principles

Embedded defaults for clean code. Merge Robert Martin Clean Code, Martin Fowler Refactoring, Kent Beck Smalltalk Best Practice Patterns into actionable guidelines.

Embedded defaults. See SKILL.md Config Resolution section for project-specific overrides.

## Table of Contents

1. [Single Responsibility](#1-single-responsibility)
2. [Small Focused Functions](#2-small-focused-functions)
3. [Cyclomatic Complexity](#3-cyclomatic-complexity)
4. [Meaningful Naming](#4-meaningful-naming)
5. [Parameter Design](#5-parameter-design)
6. [DRY Without Premature Abstraction](#6-dry-without-premature-abstraction)
7. [Comments and Self-Documentation](#7-comments-and-self-documentation)
8. [Error Handling](#8-error-handling)
9. [Test-Friendly Code](#9-test-friendly-code)

---

## 1. Single Responsibility

Function do one thing. Class have one axis cohesion -- one reason change.

**"and" test**: describe function purpose one sentence. Need word "and"? Function do more than one thing.

```
// POOR: This function validates, transforms, AND persists
function processOrder(rawInput):
  if rawInput.items is empty: throw Error("No items")
  if rawInput.total < 0: throw Error("Invalid total")
  items = rawInput.items.map(item => normalizeItem(item))
  total = items.reduce((sum, item) => sum + item.price * item.quantity, 0)
  discount = total > 1000 ? total * 0.1 : 0
  finalTotal = total - discount
  db.insert("orders", { items, total: finalTotal })
  emailService.send(rawInput.email, "Order confirmed")

// GOOD: Each function does one thing
function validateOrderInput(input):
  if input.items is empty: throw Error("No items")
  if input.total < 0: throw Error("Invalid total")

function calculateOrderTotal(items):
  subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0)
  discount = subtotal > 1000 ? subtotal * 0.1 : 0
  return subtotal - discount

function createOrder(input):
  validateOrderInput(input)
  items = input.items.map(normalizeItem)
  total = calculateOrderTotal(items)
  return { items, total }
```

**Class cohesion**: class cohesive when most methods use most instance variables. Subset methods only touch subset fields? That subset likely belong own class.

---

## 2. Small, Focused Functions

### Thresholds

| Metric | Guideline | Rationale |
|--------|-----------|-----------|
| **Lines per function** | Under ~20 | Function visible one screen no scroll easier reason about |
| **Levels of abstraction** | One per function | Mix high-level orchestration with low-level detail force reader context-switch |
| **Indentation depth** | Max 2 levels | Each nest level add condition reader must mental track |

Signals, not hard rules. 25-line function one clear purpose better than five 5-line functions obscure flow. Goal: readability, not line counting.

### Extraction Pattern

Function do multiple things? Extract by naming intent:

```
// BEFORE: One function mixing levels of abstraction
function renderUserProfile(userId):
  user = db.query("SELECT * FROM users WHERE id = ?", [userId])
  if user is null: return notFound()
  posts = db.query("SELECT * FROM posts WHERE author_id = ? ORDER BY date DESC LIMIT 5", [userId])
  avatar = user.avatarUrl ?? defaultAvatarUrl
  displayName = user.nickname ?? user.firstName + " " + user.lastName
  return template.render("profile", { user, posts, avatar, displayName })

// AFTER: Each extracted function documents intent through its name
function renderUserProfile(userId):
  user = findUserOrFail(userId)
  posts = getRecentPosts(userId)
  profile = buildProfileViewModel(user, posts)
  return template.render("profile", profile)
```

Extracted function names replace comments you would write. `buildProfileViewModel` document we construct view model -- function name IS comment.

---

## 3. Cyclomatic Complexity

### Thresholds

| Complexity | Assessment | Action |
|-----------|------------|--------|
| **1-5** | Simple, easy test | No action |
| **6-10** | Moderate, manageable | Consider extract if readability suffer |
| **11-20** | High, difficult test thoroughly | Extract sub-decisions into named functions |
| **21+** | Very high, likely do multiple things | Decompose aggressive; function have multiple responsibilities |

### Flattening Techniques

**Guard clauses** replace nested conditions with early exits:

```
// POOR: Deep nesting
function getDiscount(customer, order):
  if customer is not null:
    if customer.isActive:
      if order.total > 100:
        if customer.loyaltyYears > 2:
          return 0.15
        else:
          return 0.10
      else:
        return 0.05
    else:
      return 0
  else:
    return 0

// GOOD: Guard clauses flatten the logic
function getDiscount(customer, order):
  if customer is null: return 0
  if not customer.isActive: return 0
  if order.total <= 100: return 0.05
  if customer.loyaltyYears > 2: return 0.15
  return 0.10
```

**Extract conditional branches** when condition complex:

```
// POOR: Complex inline condition
if user.role == "admin" or (user.role == "manager" and user.department == order.department):
  // ... allow

// GOOD: Named condition
canApproveOrder = isAdmin(user) or isManagerOfDepartment(user, order.department)
if canApproveOrder:
  // ... allow
```

**Replace loops with pipeline** when language support:

```
// POOR: Loop with accumulation and filtering interleaved
result = []
for item in items:
  if item.isActive:
    if item.price > threshold:
      result.push({ name: item.name, discountedPrice: item.price * 0.9 })

// GOOD: Pipeline makes each step explicit
result = items
  .filter(item => item.isActive)
  .filter(item => item.price > threshold)
  .map(item => ({ name: item.name, discountedPrice: item.price * 0.9 }))
```

---

## 4. Meaningful Naming

### Naming Patterns

| Category | Convention | Good Examples | Poor Examples |
|----------|-----------|---------------|---------------|
| **Boolean variables** | `is`, `has`, `can`, `should` prefix | `isActive`, `hasPermission`, `canRetry` | `active`, `permission`, `retry` |
| **Boolean functions** | Same prefixes as boolean variables | `isExpired(token)`, `hasAccess(user, resource)` | `checkExpiry(token)`, `access(user, resource)` |
| **Functions (actions)** | Verb-first | `calculateTotal`, `sendNotification`, `validateInput` | `totalCalculation`, `notification`, `inputCheck` |
| **Functions (accessors)** | `get`, `find`, `fetch` prefix | `getUser`, `findByEmail`, `fetchLatestOrders` | `user()`, `email()`, `orders()` |
| **Classes** | Noun or noun phrase | `OrderValidator`, `PaymentProcessor`, `UserRepository` | `ValidateOrder`, `ProcessPayment`, `HandleUser` |
| **Constants** | UPPER_SNAKE_CASE or descriptive name | `MAX_RETRY_COUNT`, `DEFAULT_PAGE_SIZE` | `MRC`, `n`, `val` |
| **Collections** | Plural noun | `activeUsers`, `pendingOrders`, `validTokens` | `list`, `data`, `items` (when domain context exists) |
| **Maps/dictionaries** | `xByY` pattern | `userById`, `priceByProductId` | `map`, `lookup`, `dict` |

### Names to Avoid

- **Single letters** beyond loop counters (`i`, `j`, `k` in loops fine; `d`, `x`, `t` in business logic NOT)
- **Abbreviations** need project knowledge (`usr`, `txn`, `mgr`, `ctx` -- unless industry-standard like `HTTP`, `URL`, `ID`)
- **Generic names** carry no info (`data`, `info`, `temp`, `result`, `value`, `item` -- unless scope 2-3 lines)
- **Type-encoded names** (`strName`, `intCount`, `arrItems` -- type system handle this)
- **Negated booleans** (`isNotActive`, `hasNoPermission` -- use positive form, negate at call site)

### Scope-Length Rule

Name length proportional to scope. Loop variable 2-line body can be `i`. Module-level constant used across functions should be `MAX_LOGIN_ATTEMPTS_BEFORE_LOCKOUT`. Wider scope, more context name must carry alone.

### Magic Numbers and Strings

Extraction test: **reader pause ask "why this specific value?"** If yes, extract named constant. Value self-evident from context? Leave inline — constant add indirection without clarity.

| Scenario | Action | Example |
|----------|--------|---------|
| Meaning not self-evident | Extract named constant | `MAX_RETRIES = 3`, `SESSION_TIMEOUT_MS = 30_000`, `DEFAULT_PAGE_SIZE = 25` |
| Appears multiple places | Extract named constant | Threshold used three different validation functions |
| Empty collection literal | Leave inline | `return []`, `users = []`, `new Map()` |
| Zero as start index | Leave inline | `startIndex = 0`, `offset = 0` |
| Mathematical identity | Leave inline | `percentage / 100`, `radians * (180 / Math.PI)` |
| HTTP status in framework call | Leave inline | `res.status(404).json(...)`, `Response(data, status=200)` |
| Boolean default | Leave inline | `enabled = false`, `verbose = true` as initial values |

---

## 5. Parameter Design

### Thresholds

| Parameter Count | Assessment | Action |
|----------------|------------|--------|
| **0-2** | Ideal | No grouping need |
| **3** | Acceptable | Consider group if parameters related |
| **4** | Boundary | Group related parameters into object |
| **5+** | Excessive | Always group; function may also do too much |

### Grouping Patterns

```
// POOR: Six parameters -- hard to read, easy to misorder at call sites
function searchProducts(query, page, pageSize, sortBy, sortDirection, includeArchived):
  // ...

// GOOD: Related parameters grouped into an object
function searchProducts(query, options: SearchOptions):
  // ...

class SearchOptions:
  page: number = 1
  pageSize: number = 20
  sortBy: string = "relevance"
  sortDirection: "asc" | "desc" = "desc"
  includeArchived: boolean = false
```

### Boolean Parameter Smell

Boolean parameter often mean function do two things -- one when true, one when false. Consider split into two functions with descriptive names:

```
// POOR: What does `true` mean at the call site?
renderUser(user, true)

// GOOD: Intent is clear
renderUserCompact(user)
renderUserDetailed(user)
```

Boolean genuinely represent option (not behavioral fork)? Options object make call site self-documenting:

```
// Acceptable: boolean as a named option
renderUser(user, { compact: true })
```

---

## 6. DRY Without Premature Abstraction

### The Rule of Three

1. **First occurrence**: Write code inline. No abstraction.
2. **Second occurrence**: Note duplication. Tolerate. Two instances may serve different purposes, diverge later.
3. **Third occurrence with same reason change**: Now extract. Have enough evidence this genuine pattern, not coincidence.

### Same Reason to Change

Two blocks code look identical but serve different business purposes NOT true duplication. Will diverge when respective requirements change.

```
// These look identical but should NOT be unified:

// In OrderService -- calculates order discount
discount = subtotal > 1000 ? subtotal * 0.1 : 0

// In InvoiceService -- calculates invoice adjustment
adjustment = lineTotal > 1000 ? lineTotal * 0.1 : 0

// Why: Order discounts and invoice adjustments are governed by different business
// rules. When the discount policy changes, you don't want the invoice logic
// to change with it. Sharing an abstraction would couple unrelated concerns.
```

### Naming the Abstraction

When extract, name abstraction for **what it does**, not for fact it remove duplication:

```
// POOR: Named for the extraction motivation
function commonCalculation(amount, threshold, rate): ...

// GOOD: Named for the business intent
function applyVolumeDiscount(amount, threshold, rate): ...
```

---

## 7. Comments and Self-Documentation

### Comment Decision Framework

| Situation | Action |
|-----------|--------|
| Code unclear, comment help explain **what** it does | Refactor code be self-documenting (rename, extract, simplify) |
| Non-obvious **why** -- business rule, legal requirement, workaround | Write comment explain why |
| Performance optimization make code less readable | Comment explain trade-off, what "obvious" approach would be |
| TODO or known limitation | Comment with `TODO:` prefix, brief context |
| API documentation for public interfaces | Use doc comments / docstrings with parameter descriptions |
| Regex or complex algorithm | Comment explain intent; regex especially benefit plain-English description |

### Examples

```
// POOR: Comment restates the code
// Increment the counter by one
counter = counter + 1

// POOR: Comment explains what, not why
// Check if user is active
if user.isActive:

// GOOD: Comment explains a non-obvious business rule
// FTC regulations require cooling-off period for purchases over $25.
// During this window, the order can be cancelled without penalty.
if order.isWithinCoolingOffPeriod():

// GOOD: Comment explains a workaround
// PostgreSQL 14 has a query planner regression with CTEs on partitioned tables.
// Using a subquery instead of a CTE until we upgrade to 15+.
// See: https://postgresql.org/bugs/12345
result = db.query("SELECT * FROM (SELECT ...)")

// GOOD: Comment explains regex intent
// Matches ISO 8601 dates with optional timezone: 2024-01-15T10:30:00Z
datePattern = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(Z|[+-]\d{2}:\d{2})?$/
```

---

## 8. Error Handling

### Core Principles

| Principle | Rationale |
|-----------|-----------|
| **Fail fast** | Validate at boundary; reject bad data before propagate through layers |
| **Be explicit** | Every operation can fail should have visible error handling |
| **Be actionable** | Error messages tell caller what went wrong, what do about it |
| **Handle at right level** | Not too early (lose context), not too late (lose ability recover) |
| **No exceptions for control flow** | Exceptions obscure normal execution path; use for truly exceptional situations |

### Patterns

**Guard clauses at boundaries:**

```
function createUser(input):
  if not input.email: throw ValidationError("Email is required")
  if not isValidEmail(input.email): throw ValidationError("Email format is invalid: expected user@domain.tld")
  if not input.name: throw ValidationError("Name is required")
  if input.name.length > 200: throw ValidationError("Name exceeds 200-character limit")
  // happy path follows -- all guards passed
```

**Actionable error messages:**

```
// POOR: Caller doesn't know what to do
throw Error("Invalid input")
throw Error("Something went wrong")
throw Error("Database error")

// GOOD: Caller knows what happened and what to do
throw Error("Order total must be positive, got: -42.50")
throw Error("User with email 'a@b.com' already exists. Use updateUser() to modify existing users.")
throw Error("Connection to payments API timed out after 5s. Retry or check service status at status.payments.io")
```

> **Trust boundary note**: These actionable messages appropriate for application-level errors (service-to-service, logged server-side). At trust boundaries (HTTP responses, user-facing UI), strip internal details (emails, method names), return generic but actionable message with correlation ID. See `framework:secure-coding`.

**Handle at right level:**

```
// POOR: Error caught too early -- context lost
function getUser(id):
  try:
    return db.findById("users", id)
  catch error:
    return null   // caller doesn't know WHY it failed -- was it not found? connection error? permission denied?

// GOOD: Let it propagate to a level that can make a decision
function getUser(id):
  return db.findById("users", id)   // throws if connection fails
  // caller or middleware decides: retry? return 500? log and alert?

// GOOD: Catch when you have context to handle meaningfully
function getUserProfile(id):
  user = userProvider.findById(id)
  if user is null: throw NotFoundError("No user with ID: " + id)
  return buildProfile(user)
```

**No swallowed errors:**

```
// POOR: Silent failure -- bugs become invisible
try:
  sendNotification(user)
catch error:
  // silently ignored

// GOOD: Explicit decision about the error
try:
  sendNotification(user)
catch error:
  logger.warn("Notification failed for user " + user.id + ": " + error.message)
  // Notification is non-critical; continue without failing the operation
```

---

## 9. Test-Friendly Code

### Principles

Code hard test usually hard maintain. Same properties enable testing -- explicit dependencies, no hidden state, pure functions at core -- make code easier understand, modify.

### Patterns

**Prefer pure functions:**

```
// POOR: Depends on global state -- test must manipulate Date.now()
function isExpired(token):
  return Date.now() > token.expiresAt

// GOOD: Pure -- all inputs explicit, deterministic output
function isExpired(token, currentTime):
  return currentTime > token.expiresAt
```

**Inject dependencies:**

```
// POOR: Hardcoded dependency -- cannot test without a real email service
class OrderService:
  emailClient = new SmtpEmailClient()

  confirmOrder(order):
    emailClient.send(order.customerEmail, "Order confirmed")

// GOOD: Injected -- test with a mock, swap implementations freely
class OrderService:
  constructor(emailClient: EmailClient):
    this.emailClient = emailClient

  confirmOrder(order):
    this.emailClient.send(order.customerEmail, "Order confirmed")
```

**Avoid hidden state:**

```
// POOR: Global mutable state -- tests are order-dependent
requestCount = 0

function handleRequest(req):
  requestCount = requestCount + 1
  if requestCount > RATE_LIMIT: throw Error("Rate limited")

// GOOD: State is explicit and injectable
class RateLimiter:
  constructor(limit):
    this.limit = limit
    this.count = 0

  check():
    this.count = this.count + 1
    if this.count > this.limit: throw Error("Rate limited")

  reset():
    this.count = 0
```

**Push side effects to boundaries:**

```
// POOR: Business logic mixed with I/O
function applyDiscount(orderId, discountCode):
  order = db.findById("orders", orderId)
  discount = db.findOne("discounts", { code: discountCode })
  if discount.isExpired(): throw Error("Expired")
  newTotal = order.total * (1 - discount.rate)
  db.update("orders", orderId, { total: newTotal })
  emailService.send(order.email, "Discount applied")
  return newTotal

// GOOD: Pure calculation separated from I/O
function calculateDiscountedTotal(orderTotal, discountRate):
  return orderTotal * (1 - discountRate)

// Orchestration layer handles I/O
function applyDiscount(orderId, discountCode):
  order = orderProvider.findById(orderId)
  discount = discountProvider.findByCode(discountCode)
  if discount.isExpired(): throw Error("Expired")
  newTotal = calculateDiscountedTotal(order.total, discount.rate)
  orderRepo.updateTotal(orderId, newTotal)
  notificationService.discountApplied(order.email)
  return newTotal
```

---

*Defaults synthesize principles from Robert Martin Clean Code (2008), Martin Fowler Refactoring (1999, 2018), Kent Beck Smalltalk Best Practice Patterns (1996), collective wisdom software craftsmanship practice.*