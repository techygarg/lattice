# Clean Code: Default Principles

These are the embedded opinionated defaults for clean code. They synthesize principles from Robert Martin's Clean Code, Martin Fowler's Refactoring, and Kent Beck's Smalltalk Best Practice Patterns into one actionable set of guidelines for writing individual units of code.

These are the embedded defaults. See the SKILL.md Config Resolution section for how project-specific overrides work.

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
10. [Validation Checklist](#10-validation-checklist)

---

## 1. Single Responsibility

A function should do one thing. A class should have one axis of cohesion -- one reason to change.

**The "and" test**: describe the function's purpose in one sentence. If you need the word "and," the function does more than one thing.

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

**Cohesion in classes**: a class is cohesive when most methods use most instance variables. When a subset of methods only touches a subset of fields, that subset likely belongs in its own class.

---

## 2. Small, Focused Functions

### Thresholds

| Metric | Guideline | Rationale |
|--------|-----------|-----------|
| **Lines per function** | Under ~20 | A function visible in one screen without scrolling is easier to reason about |
| **Levels of abstraction** | One per function | Mixing high-level orchestration with low-level detail forces the reader to context-switch |
| **Indentation depth** | Max 2 levels | Each nesting level adds a condition the reader must mentally track |

These are signals, not hard rules. A 25-line function with one clear purpose is better than five 5-line functions that obscure the flow. The goal is readability, not line counting.

### Extraction Pattern

When a function does multiple things, extract by naming the intent:

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

The extracted function names replace the comments you would have written. `buildProfileViewModel` documents that we are constructing a view model -- the function name is the comment.

---

## 3. Cyclomatic Complexity

### Thresholds

| Complexity | Assessment | Action |
|-----------|------------|--------|
| **1-5** | Simple, easy to test | No action needed |
| **6-10** | Moderate, still manageable | Consider extraction if readability suffers |
| **11-20** | High, difficult to test thoroughly | Extract sub-decisions into named functions |
| **21+** | Very high, likely doing multiple things | Decompose aggressively; this function has multiple responsibilities |

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

**Extract conditional branches** when the condition itself is complex:

```
// POOR: Complex inline condition
if user.role == "admin" or (user.role == "manager" and user.department == order.department):
  // ... allow

// GOOD: Named condition
canApproveOrder = isAdmin(user) or isManagerOfDepartment(user, order.department)
if canApproveOrder:
  // ... allow
```

**Replace loops with pipeline operations** when the language supports it:

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

- **Single letters** beyond loop counters (`i`, `j`, `k` in loops are fine; `d`, `x`, `t` in business logic are not)
- **Abbreviations** that require project knowledge (`usr`, `txn`, `mgr`, `ctx` -- unless the abbreviation is industry-standard like `HTTP`, `URL`, `ID`)
- **Generic names** that carry no information (`data`, `info`, `temp`, `result`, `value`, `item` -- unless scope is two or three lines)
- **Type-encoded names** (`strName`, `intCount`, `arrItems` -- the type system handles this)
- **Negated booleans** (`isNotActive`, `hasNoPermission` -- use the positive form and negate at the call site)

### Scope-Length Rule

Name length should be proportional to scope. A loop variable with a two-line body can be `i`. A module-level constant used across functions should be `MAX_LOGIN_ATTEMPTS_BEFORE_LOCKOUT`. The wider the scope, the more context the name must carry on its own.

### Magic Numbers and Strings

The extraction test: **would a reader pause and ask "why this specific value?"** If yes, extract to a named constant. If the value is self-evident from context, leave it inline — a constant adds indirection without adding clarity.

| Scenario | Action | Example |
|----------|--------|---------|
| Meaning not self-evident | Extract to named constant | `MAX_RETRIES = 3`, `SESSION_TIMEOUT_MS = 30_000`, `DEFAULT_PAGE_SIZE = 25` |
| Appears in multiple places | Extract to named constant | A threshold used in three different validation functions |
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
| **0-2** | Ideal | No grouping needed |
| **3** | Acceptable | Consider grouping if parameters are related |
| **4** | Boundary | Group related parameters into an object |
| **5+** | Excessive | Always group; the function may also be doing too much |

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

A boolean parameter often means the function does two things -- one when true, one when false. Consider splitting into two functions with descriptive names:

```
// POOR: What does `true` mean at the call site?
renderUser(user, true)

// GOOD: Intent is clear
renderUserCompact(user)
renderUserDetailed(user)
```

When the boolean genuinely represents an option (not a behavioral fork), an options object makes the call site self-documenting:

```
// Acceptable: boolean as a named option
renderUser(user, { compact: true })
```

---

## 6. DRY Without Premature Abstraction

### The Rule of Three

1. **First occurrence**: Write the code inline. No abstraction.
2. **Second occurrence**: Note the duplication. Tolerate it. The two instances may serve different purposes and diverge later.
3. **Third occurrence with same reason to change**: Now extract. You have enough evidence that this is a genuine pattern, not coincidence.

### Same Reason to Change

Two blocks of code that look identical but serve different business purposes are **not** true duplication. They will diverge when their respective requirements change.

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

When you do extract, name the abstraction for **what it does**, not for the fact that it removes duplication:

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
| Code is unclear and a comment would help explain **what** it does | Refactor the code to be self-documenting (rename, extract, simplify) |
| Non-obvious **why** -- business rule, legal requirement, workaround | Write a comment explaining why |
| Performance optimization that makes code less readable | Comment explaining the trade-off and what the "obvious" approach would be |
| TODO or known limitation | Comment with `TODO:` prefix and brief context |
| API documentation for public interfaces | Use doc comments / docstrings with parameter descriptions |
| Regex or complex algorithm | Comment explaining intent; regex especially benefits from a plain-English description |

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
| **Fail fast** | Validate at the boundary; reject bad data before it propagates through layers |
| **Be explicit** | Every operation that can fail should have visible error handling |
| **Be actionable** | Error messages should tell the caller what went wrong and what to do about it |
| **Handle at the right level** | Not too early (losing context), not too late (losing ability to recover) |
| **No exceptions for control flow** | Exceptions obscure the normal execution path; use them for truly exceptional situations |

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

> **Trust boundary note**: These actionable messages are appropriate for application-level errors (service-to-service, logged server-side). At trust boundaries (HTTP responses, user-facing UI), strip internal details (emails, method names) and return a generic but actionable message with a correlation ID. See `framework:secure-coding`.

**Handle at the right level:**

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

Code that is hard to test is usually hard to maintain. The same properties that enable testing -- explicit dependencies, no hidden state, pure functions at the core -- make code easier to understand and modify.

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

## 10. Validation Checklist

Use this after generating or reviewing code. Each item maps to a principle above.

### Function Design

- [ ] Each function does one thing (passes the "and" test)
- [ ] Functions are under ~20 lines; exceptions have a single clear purpose
- [ ] Cyclomatic complexity is under ~10 per function
- [ ] Indentation depth does not exceed two levels
- [ ] Guard clauses are used instead of deep nesting

### Naming

- [ ] Function names are verb-first and reveal intent
- [ ] Class names are noun-based
- [ ] Boolean names use `is`/`has`/`can`/`should` prefix
- [ ] No abbreviations that require project-specific context to decode
- [ ] Name length is proportional to scope

### Parameter Design

- [ ] Functions have four or fewer parameters
- [ ] Related parameters are grouped into objects
- [ ] Boolean parameters are avoided or wrapped in named options

### Abstraction

- [ ] Duplication is only extracted after three instances with the same reason to change
- [ ] Extracted abstractions are named for what they do, not for the fact that they reduce duplication
- [ ] No premature abstractions coupling unrelated concerns

### Comments

- [ ] No comments explaining "what" the code does (refactor to be self-documenting instead)
- [ ] Comments explain "why" for non-obvious business rules, workarounds, and constraints
- [ ] Regex patterns have a plain-English description comment
- [ ] Public APIs have doc comments with parameter descriptions

### Error Handling

- [ ] Inputs are validated at boundaries with guard clauses
- [ ] Error messages are actionable (what went wrong, what to do)
- [ ] No swallowed errors (empty catch blocks)
- [ ] Exceptions are not used for control flow
- [ ] Errors are handled at the level with sufficient context to decide

### Testability

- [ ] Business logic is in pure functions where possible
- [ ] Dependencies are injected, not hardcoded
- [ ] No hidden mutable global state
- [ ] Side effects are at the boundaries, not interleaved with logic

---

*These defaults synthesize principles from Robert Martin's Clean Code (2008), Martin Fowler's Refactoring (1999, 2018), Kent Beck's Smalltalk Best Practice Patterns (1996), and the collective wisdom of software craftsmanship practice.*
