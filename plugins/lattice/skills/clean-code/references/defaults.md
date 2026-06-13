# Clean Code: Default Principles

Embedded defaults clean code. Opinionated guardrails — override via SKILL.md Config Resolution.

## 1. Single Responsibility

Function do one thing. Class have one axis cohesion -- one reason change.

**"and" test**: describe function purpose one sentence. Need word "and"? Function do more than one thing. Extract each responsibility into named function — function name IS the documentation.

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

1. **Guard clauses**: replace nested conditions with early returns — flatten nesting, reduce indentation depth
2. **Extract named conditions**: complex boolean expressions → named variable or function (`canApproveOrder = isAdmin(user) or isManagerOfDepartment(user, order.department)`)
3. **Pipeline over loops**: when language supports, replace loop-with-accumulation with filter/map chain — each step explicit

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
// GOOD: Comment explains a non-obvious business rule
// FTC regulations require cooling-off period for purchases over $25.
// During this window, the order can be cancelled without penalty.
if order.isWithinCoolingOffPeriod():

// GOOD: Comment explains a workaround
// PostgreSQL 14 has a query planner regression with CTEs on partitioned tables.
// Using subquery instead of CTE until upgrade to 15+.  See: postgresql.org/bugs/12345
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

**Handle at right level** — not too early (lose context, caller can't decide), not too late (lose ability to recover). Let errors propagate to the layer with enough context to make a meaningful decision. Catch-and-return-null hides whether failure was "not found", "connection error", or "permission denied."

**No swallowed errors** — empty catch blocks make bugs invisible. Always log, re-throw, or explicitly document why ignoring is safe:

```
try:
  sendNotification(user)
catch error:
  logger.warn("Notification failed for user " + user.id + ": " + error.message)
  // Notification is non-critical; continue without failing the operation
```

---

## 9. Test-Friendly Code

Code hard to test is usually hard to maintain. Design for testability by default:

1. **Prefer pure functions** — all inputs explicit as parameters (no `Date.now()`, no globals). Deterministic output. Easiest to test.
2. **Inject dependencies** — constructor/parameter injection over `new` inside methods. Enables mocking, swapping implementations.
3. **Avoid hidden state** — no module-level mutable variables. Encapsulate state in explicit objects with reset capability.
4. **Push side effects to boundaries** — separate pure business logic (calculation, validation) from I/O (database, network, filesystem). Pure core + thin orchestration shell.

**Anti-pattern — God Function with embedded I/O**: function that reads from DB, applies business logic, writes to DB, and sends notifications in one body. Extract pure calculation, let orchestration layer handle I/O.

---

*Defaults synthesize principles from Robert Martin Clean Code (2008), Martin Fowler Refactoring (1999, 2018), Kent Beck Smalltalk Best Practice Patterns (1996), collective wisdom software craftsmanship practice.*