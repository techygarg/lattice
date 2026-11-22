# Clean Code Refiner Template

This template defines the structure of the `.lattice/standards/clean-code.md` output document. It contains all default content from the clean-code atom's `defaults.md`, interleaved with interview guidance comments.

When producing the output, strip all `<!-- INTERVIEW GUIDANCE: -->` comments. The final document is a specification, not a conversation log.

---

## Frontmatter

<!-- INTERVIEW GUIDANCE:
Choose one of the two frontmatter options based on the user's chosen mode.
Default to overlay unless the user explicitly wants to redefine everything.
-->

Option A -- Overlay mode (most common):

```yaml
---
mode: overlay
---
```

Option B -- Override mode (complete replacement):

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

> This document overlays project-specific customizations on top of the clean-code atom's embedded defaults. Only sections included here differ from the defaults -- all other sections remain as-is.
>
> Sections below replace matching sections in the defaults (matched by heading). New sections are appended after defaults.

**Override preamble:**

> These are the clean code principles for [PROJECT NAME]. They fully replace the embedded defaults in the clean-code atom.

**Table of contents** (for override mode; overlay mode only lists included sections):

1. [Single Responsibility](#1-single-responsibility)
2. [Small, Focused Functions](#2-small-focused-functions)
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

<!-- INTERVIEW GUIDANCE:
Summary for overlay mode: "The default says: a function should do one thing (the 'and' test -- if you need 'and' to describe it, extract). For classes, cohesion means most methods use most fields. Does this match your project?"

Probing questions:
- Does your team use classes or is the codebase purely functional? (If functional, class cohesion guidance can be removed)
- How strictly do you interpret SRP? Some teams tolerate orchestration functions that do multiple things in sequence.
- Are there patterns in your codebase where SRP is intentionally relaxed (e.g., middleware chains, pipeline stages)?

Customizable: Thresholds for what counts as "one thing," class vs function focus, extraction targets.
Fixed: The core principle that units of code should have one reason to change.

Cross-section impact: If the team is purely functional (no classes), this affects §2 (extraction targets are always functions), §5 (parameter design shifts), and §10 (class-related checklist items can be removed).
-->

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

<!-- INTERVIEW GUIDANCE:
Summary for overlay mode: "The default says: aim for functions under ~20 lines, one level of abstraction per function, max 2 levels of indentation. These are signals, not hard rules. Does this match your project?"

Probing questions:
- Does your team have a different line limit? (Some teams prefer 10-15, others tolerate 30)
- Does your linter enforce a max function length or max nesting?
- Are there patterns where longer functions are acceptable (e.g., state machine handlers, configuration builders)?

Customizable: Line thresholds, indentation depth, exceptions to the rule.
Fixed: The principle that functions should do one thing at one level of abstraction.

Cross-section impact: Shorter function limits imply lower complexity budgets (§3).
-->

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

The extracted function names replace the comments you would have written.

---

## 3. Cyclomatic Complexity

<!-- INTERVIEW GUIDANCE:
Summary for overlay mode: "The default says: keep cyclomatic complexity under ~10 per function. Three flattening techniques: guard clauses, extract conditionals, pipeline operations. Does this match your project?"

Probing questions:
- Does your linter already enforce a complexity threshold? What is it?
- Does your team prefer guard clauses or do you use other patterns (e.g., pattern matching in functional languages)?
- Are there areas where higher complexity is tolerated (e.g., parsers, state machines)?

Customizable: Complexity thresholds, preferred flattening techniques, exceptions.
Fixed: The principle that deep nesting and high branch counts erode readability.

Cross-section impact: Lower complexity limits may require stricter function size (§2).
-->

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

<!-- INTERVIEW GUIDANCE:
Summary for overlay mode: "The default says: names reveal intent, not implementation. Boolean names use is/has/can, functions are verb-first, classes are noun-based. Name length proportional to scope. Does this match your project?"

Probing questions:
- Does your team have naming conventions that differ from these? (e.g., some Go teams use shorter names)
- Are there domain-specific abbreviations that ARE acceptable? (e.g., `tx` for transaction in financial code)
- Does your team use specific suffixes for types? (e.g., `Input`, `Output`, `DTO`, `Response`)
- Does your language have idioms that override general naming rules? (e.g., Go prefers short names in small scopes)

Customizable: Naming patterns, acceptable abbreviations, language-specific conventions.
Fixed: The principle that names should reveal intent.
-->

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

---

## 5. Parameter Design

<!-- INTERVIEW GUIDANCE:
Summary for overlay mode: "The default says: 0-2 parameters ideal, 4 is the boundary, 5+ always group. Boolean parameters are a smell -- prefer named options or split functions. Does this match your project?"

Probing questions:
- Does your team tolerate more parameters? (Some functional codebases accept higher counts with good naming)
- Do you use a builder pattern or options pattern for complex construction?
- How does your team handle configuration objects -- do you prefer explicit parameters or config objects?
- Does your language have named parameters (Python, Kotlin)? This changes whether parameter objects are needed.

Customizable: Parameter count thresholds, grouping strategies, language-specific patterns.
Fixed: The principle that long parameter lists create cognitive burden and call-site errors.

Cross-section impact: If the team is purely functional (from §1), parameter design patterns shift -- more parameters may be acceptable if the language supports named parameters.
-->

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

<!-- INTERVIEW GUIDANCE:
Summary for overlay mode: "The default says: tolerate duplication until the Rule of Three -- three instances with the same reason to change. The wrong abstraction is more costly than no abstraction. Does this match your project?"

Probing questions:
- How aggressively does your team extract shared code? (Some teams extract earlier, some later)
- Are there areas where duplication is explicitly acceptable? (e.g., test setup code, configuration)
- Does your team use code generation that makes some duplication acceptable?
- How do you name extracted abstractions -- any conventions?

Customizable: Extraction threshold (Rule of Two vs Rule of Three), naming conventions for abstractions.
Fixed: The principle that premature abstraction couples unrelated concerns.
-->

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

<!-- INTERVIEW GUIDANCE:
Summary for overlay mode: "The default says: code should be self-documenting through naming. Comments explain WHY, not WHAT. Exceptions: regex patterns and complex algorithms deserve 'what' comments. Does this match your project?"

Probing questions:
- Does your team use doc comments / docstrings? For all public APIs or selectively?
- Are there areas where "what" comments are acceptable in your codebase? (e.g., complex SQL, business rules encoded in conditions)
- Do you use TODO/FIXME conventions? Any format requirements?
- Does your team use JSDoc/TSDoc/Javadoc for generated documentation?

Customizable: Doc comment policy, TODO format, additional exceptions to the "no what comments" rule.
Fixed: The principle that comments explaining "what" are a code smell indicating the code should be refactored.
-->

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

<!-- INTERVIEW GUIDANCE:
Summary for overlay mode: "The default says: fail fast at boundaries, error messages should be actionable, handle at the right level (not too early, not too late), never swallow errors. Uses exceptions for truly exceptional situations. Does this match your project?"

Probing questions:
- Does your team use exceptions or Result/Either types for error handling?
- Do you have a custom error class hierarchy? (e.g., AppError, ValidationError, NotFoundError)
- How does your team handle errors across boundaries? (e.g., domain errors translated to HTTP status codes)
- Are there patterns for logging vs returning vs rethrowing errors?
- Does your team use error codes or just messages?

Customizable: Error handling strategy (exceptions vs Result types), custom error patterns, error message format.
Fixed: The principle that errors must be handled explicitly and never silently swallowed.

Cross-section impact: If the team uses Result types instead of exceptions (§8), testing patterns change (§9) -- error paths are tested through return values, not catch blocks.
-->

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

**Handle at the right level:**

```
// POOR: Error caught too early -- context lost
function getUser(id):
  try:
    return db.findById("users", id)
  catch error:
    return null   // caller doesn't know WHY it failed

// GOOD: Let it propagate to a level that can make a decision
function getUser(id):
  return db.findById("users", id)   // throws if connection fails
  // caller or middleware decides: retry? return 500? log and alert?
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

<!-- INTERVIEW GUIDANCE:
Summary for overlay mode: "The default says: prefer pure functions, inject dependencies, avoid hidden state, push side effects to boundaries (Functional Core / Imperative Shell). Does this match your project?"

Probing questions:
- What testing framework does your team use?
- Does your team practice TDD or write tests after implementation?
- How does your team handle mocking -- do you prefer fakes, stubs, or mocks? Minimal mocking?
- Are there patterns for test data setup? (Builders, factories, fixtures)
- How strict is your team about test isolation? (Some teams accept shared state in integration tests)

Customizable: Testing framework specifics, mocking preferences, test data patterns.
Fixed: The principle that testable code is well-structured code.

Cross-section impact: If §8 uses Result types instead of exceptions, error path testing changes -- test assertions check return values, not catch blocks.
-->

Code that is hard to test is usually hard to maintain. The same properties that enable testing -- explicit dependencies, no hidden state, pure functions at the core -- make code easier to understand and modify.

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

<!-- INTERVIEW GUIDANCE:
This section should be consistent with all previous sections. If any thresholds, patterns, or strategies were changed earlier, update the corresponding checklist items here.

Ask: "This checklist summarizes everything above. Should the AI check all of these when generating or reviewing code? Any to add or remove?"

If §1 removed class guidance (functional codebase), remove class-related items.
If §3 changed complexity thresholds, update the complexity item.
If §8 changed error handling to Result types, update the error handling items.

Customizable: Individual checklist items, thresholds, additional groups.
Fixed: Must have at least function design and error handling groups.
-->

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

## New Sections

<!-- INTERVIEW GUIDANCE:
At the end of the interview, ask:
"Are there any project-specific sections you'd like to add that aren't covered by the defaults?
Common additions:
- Language-specific idioms (e.g., Go error handling with if err != nil, Python context managers)
- Framework-specific patterns (e.g., React hook rules, Express middleware patterns)
- Team agreements (e.g., logging standards, feature flag conventions)
- Performance patterns (e.g., caching strategies, lazy loading rules)
- Concurrency patterns (e.g., async/await conventions, goroutine lifecycle rules)"

If the user wants to add sections, number them starting from 11.
New sections work in both overlay and override mode.
-->

---

## Footer

<!-- INTERVIEW GUIDANCE:
Include project name, generation date, and mode indicator in the output.
Example:

---
*Generated for [PROJECT NAME] on [DATE]. Mode: [overlay|override].*
*Produced by the clean-code-refiner skill.*
-->
