# Test Quality: Default Principles

These defaults synthesize Gerard Meszaros's xUnit Test Patterns, Kent Beck's TDD, Martin Fowler's testing guidance into one actionable set.

If project has custom `.lattice/test-quality.md` (referenced through `.lattice/config.yaml`), that doc wins.

## Table of Contents

1. [AAA Structure](#1-aaa-structure)
2. [One Behavior Per Test](#2-one-behavior-per-test)
3. [Assertion Patterns](#3-assertion-patterns)
4. [Test Isolation Techniques](#4-test-isolation-techniques)
5. [Test Naming Conventions](#5-test-naming-conventions)
6. [Test Data Builders and Factories](#6-test-data-builders-and-factories)
7. [Test Pyramid Distribution](#7-test-pyramid-distribution)
8. [Anti-Pattern Catalog](#8-anti-pattern-catalog)

---

## 1. AAA Structure

Every test: three clear phases. Reader spots each phase at glance.

### Good Separation

```
function should_apply_discount_when_order_exceeds_threshold():
  // Arrange
  order = anOrder()
    .withItem("Widget", price: 500)
    .withItem("Gadget", price: 600)
    .build()
  discountPolicy = PercentageDiscount(threshold: 1000, rate: 0.10)

  // Act
  result = discountPolicy.apply(order)

  // Assert
  assertEqual(result.discount, 110.00)
  assertEqual(result.total, 990.00)
```

### Poor Separation

```
// POOR: Phases are interleaved; logic in arrange and assert
function test_discount():
  items = []
  for i in range(5):
    items.append(Item("item" + str(i), price: random(100, 500)))  // logic in arrange
  order = Order(items)
  total = 0
  for item in items:
    total += item.price  // computing expected value manually
  if total > 1000:
    result = PercentageDiscount(0.10).apply(order)
    assertTrue(result.discount > 0)  // vague assertion
  else:
    result = PercentageDiscount(0.10).apply(order)
    assertEqual(result.discount, 0)
```

### When Arrange Is Long

Extract complex setup into builder/factory -- no 20-line arrange phase.

```
// POOR: Long arrange phase obscures the test's intent
function should_send_welcome_email_when_user_registers():
  emailService = MockEmailService()
  userRepo = InMemoryUserRepository()
  hashService = BcryptHashService()
  validationService = UserValidationService(userRepo)
  registrationService = RegistrationService(userRepo, emailService, hashService, validationService)
  request = RegistrationRequest(
    name: "Jane Doe",
    email: "jane@example.com",
    password: "SecurePass123!",
    confirmPassword: "SecurePass123!",
    acceptedTerms: true
  )

  registrationService.register(request)

  assertTrue(emailService.wasSentTo("jane@example.com"))

// GOOD: Builder and fixture simplify arrange
function should_send_welcome_email_when_user_registers():
  { registrationService, emailService } = aRegistrationContext().build()
  request = aRegistrationRequest().withEmail("jane@example.com").build()

  registrationService.register(request)

  assertTrue(emailService.wasSentTo("jane@example.com"))
```

---

## 2. One Behavior Per Test

### Splitting a Multi-Behavior Test

```
// POOR: Tests two behaviors -- creation and duplicate rejection
function test_user_registration():
  service = UserRegistrationService(InMemoryUserRepo())

  // Behavior 1: successful registration
  result = service.register("jane@example.com", "password123")
  assertTrue(result.success)
  assertEqual(result.user.email, "jane@example.com")

  // Behavior 2: duplicate rejection
  result2 = service.register("jane@example.com", "password456")
  assertFalse(result2.success)
  assertEqual(result2.error, "Email already registered")

// GOOD: Each behavior gets its own test
function should_register_user_with_valid_email():
  service = UserRegistrationService(InMemoryUserRepo())

  result = service.register("jane@example.com", "password123")

  assertTrue(result.success)
  assertEqual(result.user.email, "jane@example.com")

function should_reject_registration_when_email_already_exists():
  service = UserRegistrationService(InMemoryUserRepo())
  service.register("jane@example.com", "password123")  // setup: existing user

  result = service.register("jane@example.com", "password456")

  assertFalse(result.success)
  assertEqual(result.error, "Email already registered")
```

### Multiple Assertions Are Fine for One Behavior

```
// This is fine -- all assertions verify facets of one behavior (user creation)
function should_create_user_with_all_fields_populated():
  result = userService.createUser(aCreateUserRequest().build())

  assertEqual(result.name, "Jane Doe")
  assertEqual(result.email, "jane@example.com")
  assertEqual(result.role, "member")
  assertNotNull(result.id)
  assertNotNull(result.createdAt)
```

---

## 3. Assertion Patterns

### Specific vs Generic

```
// POOR: Generic assertion -- passes even when behavior is wrong
function should_calculate_order_total():
  order = anOrder().withItem("Widget", price: 25.00, quantity: 3).build()

  result = order.calculateTotal()

  assertNotNull(result)        // passes if result is 0, -1, or any non-null value
  assertTrue(result > 0)       // passes if result is 1 or 1000000

// GOOD: Specific assertion -- fails precisely when behavior is wrong
function should_calculate_order_total():
  order = anOrder().withItem("Widget", price: 25.00, quantity: 3).build()

  result = order.calculateTotal()

  assertEqual(result, 75.00)   // fails if the calculation is wrong by any amount
```

### Custom Assertion Helpers

```
// When the same assertion pattern recurs across many tests, extract a helper

// WITHOUT helper: assertion intent is buried in mechanics
function should_place_order_successfully():
  result = orderService.place(anOrder().build())

  assertEqual(result.status, "placed")
  assertNotNull(result.orderId)
  assertNotNull(result.placedAt)
  assertTrue(result.placedAt <= now())

// WITH helper: assertion intent is clear
function should_place_order_successfully():
  result = orderService.place(anOrder().build())

  assertOrderWasPlaced(result)  // encapsulates the four checks above

// The helper (defined once, used in many tests)
function assertOrderWasPlaced(result):
  assertEqual(result.status, "placed", "Order should have status 'placed'")
  assertNotNull(result.orderId, "Placed order should have an ID")
  assertNotNull(result.placedAt, "Placed order should have a timestamp")
  assertTrue(result.placedAt <= now(), "Placed timestamp should not be in the future")
```

### Asserting on the Negative Space

```
// Sometimes the most important assertion is that something did NOT happen
function should_not_send_email_when_order_fails_validation():
  emailService = MockEmailService()
  orderService = OrderService(emailService: emailService)
  invalidOrder = anOrder().withQuantity(-1).build()

  orderService.place(invalidOrder)

  assertEqual(emailService.sentEmails.count, 0)  // assert nothing was sent
```

---

## 4. Test Isolation Techniques

### Database Isolation

```
// POOR: Tests share database state -- order-dependent
function test_create_user():
  db.insert("users", { id: 1, name: "Jane" })
  user = userRepo.findById(1)
  assertEqual(user.name, "Jane")
  // does not clean up -- next test might find this row

// GOOD: Transaction rollback -- each test starts clean
function should_persist_user():
  transaction = db.beginTransaction()
  try:
    userRepo = UserRepository(transaction)
    userRepo.save(User(name: "Jane"))

    found = userRepo.findByName("Jane")

    assertEqual(found.name, "Jane")
  finally:
    transaction.rollback()  // always rolls back -- no state leaks
```

### File System Isolation

```
// POOR: Tests use a shared directory
function test_write_report():
  writeReport("/tmp/reports/test-report.csv")
  assertTrue(fileExists("/tmp/reports/test-report.csv"))
  // other tests might read or overwrite this file

// GOOD: Each test gets its own temp directory
function should_write_report_to_file():
  tempDir = createTempDirectory()
  reportPath = tempDir + "/report.csv"

  writeReport(reportPath)

  assertTrue(fileExists(reportPath))
  content = readFile(reportPath)
  assertContains(content, "Total,42.50")
  // tempDir cleaned up in teardown
```

### Time Isolation

```
// POOR: Test depends on real clock
function should_expire_session_after_30_minutes():
  session = Session.create()
  sleep(1800)  // wait 30 minutes -- terrible!
  assertTrue(session.isExpired())

// GOOD: Inject a clock
function should_expire_session_after_30_minutes():
  clock = FakeClock(now: "2024-01-15T10:00:00Z")
  session = Session.create(clock: clock)

  clock.advance(minutes: 30)

  assertTrue(session.isExpired(clock))
```

### Network Isolation

```
// POOR: Test hits a real external API
function should_fetch_exchange_rate():
  rate = exchangeService.getRate("USD", "EUR")
  assertNotNull(rate)  // flaky -- depends on network and external service

// GOOD: Use a fake or stub
function should_fetch_exchange_rate():
  fakeApi = FakeExchangeApi()
  fakeApi.setRate("USD", "EUR", 0.85)
  exchangeService = ExchangeService(api: fakeApi)

  rate = exchangeService.getRate("USD", "EUR")

  assertEqual(rate, 0.85)
```

---

## 5. Test Naming Conventions

### Pattern: should_[behavior]_when_[condition]

```
should_apply_discount_when_order_exceeds_threshold
should_reject_order_when_inventory_insufficient
should_send_notification_when_payment_succeeds
should_return_empty_list_when_no_results_match
should_throw_validation_error_when_email_is_malformed
```

### Pattern: [method]_[scenario]_[expected]

```
calculateTotal_withDiscountApplied_returnsReducedAmount
register_withDuplicateEmail_throwsConflictError
findByStatus_withNoMatches_returnsEmptyList
cancel_whenAlreadyCancelled_throwsIllegalStateError
```

### Anti-Pattern Names (Avoid)

```
// BAD: These names provide no diagnostic value when they fail
test1
testHappyPath
testEdgeCase
testCalculateTotal           // mirrors method name, adds no context
testOrderValidation          // too vague -- which validation? which outcome?
test_it_works                // what works? under what conditions?
```

### Language-Specific Conventions

```
// JavaScript/TypeScript (describe/it blocks)
describe("OrderService.place"):
  it("should apply discount when order exceeds threshold")
  it("should reject order when inventory is insufficient")

// Python (unittest)
def test_should_apply_discount_when_order_exceeds_threshold(self):
def test_should_reject_order_when_inventory_insufficient(self):

// Java (JUnit)
@Test void shouldApplyDiscountWhenOrderExceedsThreshold()
@Test void shouldRejectOrderWhenInventoryInsufficient()

// Go
func TestCalculateTotal_WithDiscount_ReturnsReducedAmount(t *testing.T)
func TestCalculateTotal_WithEmptyCart_ReturnsZero(t *testing.T)
```

---

## 6. Test Data Builders and Factories

### Builder Pattern

```
// The builder provides sensible defaults -- tests only override what matters

class OrderBuilder:
  id = "order-123"
  customerId = "customer-456"
  items = [Item("Default Widget", price: 10.00, quantity: 1)]
  status = "pending"
  createdAt = "2024-01-15T10:00:00Z"

  function withId(id): this.id = id; return this
  function withCustomerId(id): this.customerId = id; return this
  function withItem(name, price, quantity):
    this.items.append(Item(name, price, quantity)); return this
  function withNoItems(): this.items = []; return this
  function withStatus(status): this.status = status; return this
  function build(): return Order(this.id, this.customerId, this.items, this.status, this.createdAt)

function anOrder(): return OrderBuilder()

// Usage in tests -- only specify what matters for THIS test
function should_reject_order_with_no_items():
  order = anOrder().withNoItems().build()  // other fields use defaults

  result = orderService.validate(order)

  assertFalse(result.isValid)

function should_calculate_total_for_multiple_items():
  order = anOrder()
    .withItem("Widget", price: 25.00, quantity: 2)
    .withItem("Gadget", price: 15.00, quantity: 1)
    .build()

  total = order.calculateTotal()

  assertEqual(total, 65.00)
```

### Factory Functions (Simpler Alternative)

```
// When a full builder is overkill, a factory function with defaults works
function aUser(overrides = {}):
  defaults = {
    id: "user-123",
    name: "Jane Doe",
    email: "jane@example.com",
    role: "member",
    createdAt: "2024-01-15T10:00:00Z"
  }
  return User({ ...defaults, ...overrides })

// Usage
function should_promote_user_to_admin():
  user = aUser({ role: "member" })

  user.promote("admin")

  assertEqual(user.role, "admin")
```

### Named Constants for Boundary Values

```
// POOR: Magic numbers
function should_apply_discount():
  order = anOrder().withTotal(1500).build()  // why 1500?

// GOOD: Named constants communicate intent
ABOVE_DISCOUNT_THRESHOLD = 1500
BELOW_DISCOUNT_THRESHOLD = 500
AT_DISCOUNT_THRESHOLD = 1000

function should_apply_discount_when_above_threshold():
  order = anOrder().withTotal(ABOVE_DISCOUNT_THRESHOLD).build()

  result = discountPolicy.apply(order)

  assertTrue(result.discountApplied)

function should_not_apply_discount_when_below_threshold():
  order = anOrder().withTotal(BELOW_DISCOUNT_THRESHOLD).build()

  result = discountPolicy.apply(order)

  assertFalse(result.discountApplied)
```

---

## 7. Test Pyramid Distribution

### Guideline Ratios

```
                  /  E2E  \          ~5-10% of tests
                 /  Tests   \        Slow, expensive, cover critical paths only
                /____________\
               /  Integration  \     ~15-25% of tests
              /    Tests        \    Verify boundaries (DB, APIs, messages)
             /___________________\
            /     Unit Tests      \  ~70-80% of tests
           /  Fast, isolated,      \ Test individual functions and classes
          /   one behavior each     \
         /___________________________\
```

### When to Write Each Type

**Unit test** when:
- Testing pure function/method with clear inputs/outputs
- Testing business logic without I/O
- Testing edge cases/boundaries
- Testing error paths

**Integration test** when:
- Verifying DB queries return correct results
- Verifying API client parses external responses correctly
- Verifying message handler processes events correctly
- Verifying file I/O works with real filesystem

**E2E test** when:
- Verifying critical user journey (login, checkout, registration)
- Verifying independently deployed services work together
- Smoke testing deployment

### Push Coverage Downward

When integration/E2E test catches bug:

1. **Write unit test** reproducing specific failure
2. **Fix bug** -- unit test goes green
3. **Keep higher-level test** for regression, but unit test is primary guard now

Bug caught at fastest, cheapest level going forward.

---

## 8. Anti-Pattern Catalog

### Test-per-Method

```
// POOR: One test per production method, regardless of behaviors
function test_calculateTotal():       // what scenario? what expected outcome?
function test_applyDiscount():        // happy path only? edge cases?
function test_validateOrder():        // which validation rule?

// GOOD: One test per behavior
function should_calculate_total_for_single_item()
function should_calculate_total_for_multiple_items()
function should_return_zero_for_empty_order()
function should_apply_percentage_discount_when_above_threshold()
function should_not_apply_discount_when_below_threshold()
function should_reject_order_when_no_items()
function should_reject_order_when_quantity_is_negative()
```

### Shared Mutable State

```
// POOR: Class-level mutable state shared across tests
class OrderTests:
  orderService = OrderService()        // shared -- state accumulates
  testOrder = Order(items: [])         // mutated by multiple tests

  function test_add_item():
    testOrder.addItem(Item("Widget"))
    assertEqual(testOrder.items.count, 1)

  function test_remove_item():
    testOrder.removeItem("Widget")     // depends on test_add_item running first!
    assertEqual(testOrder.items.count, 0)

// GOOD: Each test creates its own state
class OrderTests:
  function should_add_item_to_order():
    order = anOrder().withNoItems().build()

    order.addItem(Item("Widget"))

    assertEqual(order.items.count, 1)

  function should_remove_item_from_order():
    order = anOrder().withItem("Widget").build()

    order.removeItem("Widget")

    assertEqual(order.items.count, 0)
```

### Conditional Test Logic

```
// POOR: Test contains control flow
function test_process_orders():
  orders = getTestOrders()
  for order in orders:
    result = orderService.process(order)
    if order.total > 1000:
      assertTrue(result.hasDiscount)
    else:
      assertFalse(result.hasDiscount)

// GOOD: Separate tests with explicit inputs
function should_apply_discount_for_high_value_order():
  order = anOrder().withTotal(1500).build()

  result = orderService.process(order)

  assertTrue(result.hasDiscount)

function should_not_apply_discount_for_low_value_order():
  order = anOrder().withTotal(500).build()

  result = orderService.process(order)

  assertFalse(result.hasDiscount)
```