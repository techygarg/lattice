# Secure Coding: Default Principles

Embedded defaults for secure code. Synthesizes OWASP, SANS, defensive programming into actionable guidelines.

Custom `.lattice/secure-coding.md` (via `.lattice/config.yaml`) overrides this.

## Table of Contents

1. [Trust Boundary Identification](#1-trust-boundary-identification)
2. [Input Validation Patterns](#2-input-validation-patterns)
3. [Parameterized Query Patterns](#3-parameterized-query-patterns)
4. [Output Encoding by Context](#4-output-encoding-by-context)
5. [Authorization Check Patterns](#5-authorization-check-patterns)
6. [Secrets Management Patterns](#6-secrets-management-patterns)
7. [Injection Prevention Patterns](#7-injection-prevention-patterns)

---

## 1. Trust Boundary Identification

Trust boundary = data crosses trust levels. Find these first.

### Common Trust Boundaries

```
                    UNTRUSTED                          TRUSTED
                ┌──────────────┐                  ┌──────────────┐
                │  Browser /   │   HTTP Request   │  Controller  │
                │  Mobile App  │ ───────────────► │  (Boundary)  │
                └──────────────┘                  └──────┬───────┘
                                                         │ validated
                ┌──────────────┐                  ┌──────▼───────┐
                │  External    │   API Response   │  Application │
                │  API         │ ───────────────► │  Service     │
                └──────────────┘                  └──────┬───────┘
                                                         │ validated
                ┌──────────────┐                  ┌──────▼───────┐
                │  Database    │   Query Result   │  Repository  │
                │  (may be     │ ───────────────► │  (Boundary)  │
                │  poisoned)   │                  └──────────────┘
                └──────────────┘
```

### Boundary Identification Checklist

For every function/module ask:

1. **Where data from?** Outside app = crosses boundary.
2. **Validated before?** If no, validate here.
3. **Could be tampered?** Cookies, URL params, forms, headers = user-controlled.
4. **From another service?** Even internal services can return bad data if compromised/buggy.

### Pattern: Trust Boundary Annotation

```
// POOR: No awareness of trust boundary
function handleRequest(req):
  userId = req.params.userId
  return db.query("SELECT * FROM users WHERE id = " + userId)

// GOOD: Trust boundary explicitly identified and defended
function handleRequest(req):
  // TRUST BOUNDARY: req.params is user-controlled input
  userId = validateAndParseUserId(req.params.userId)  // validate at boundary
  return userRepository.findById(userId)               // parameterized internally
```

---

## 2. Input Validation Patterns

### By Type

**String validation:**
```
// POOR: Accept any string
function setUsername(name):
  this.username = name

// GOOD: Validate format, length, and content
function setUsername(name):
  if name is null or name.trim().length == 0:
    throw ValidationError("Username is required")
  if name.length > 50:
    throw ValidationError("Username must be 50 characters or fewer")
  if not matches(name, /^[a-zA-Z0-9_-]+$/):
    throw ValidationError("Username may only contain letters, numbers, hyphens, and underscores")
  this.username = name.trim()
```

**Number validation:**
```
// POOR: Trust the input is a valid number
function setQuantity(qty):
  this.quantity = qty

// GOOD: Type-check, range-check
function setQuantity(qty):
  if not isInteger(qty):
    throw ValidationError("Quantity must be an integer")
  if qty < 1 or qty > 10000:
    throw ValidationError("Quantity must be between 1 and 10,000")
  this.quantity = qty
```

**Email validation:**
```
// POOR: Regex-only validation (unreliable for email)
function setEmail(email):
  if not matches(email, /.*@.*/): throw Error("Invalid")
  this.email = email

// GOOD: Structural validation + length limits
function setEmail(email):
  if email is null or email.trim().length == 0:
    throw ValidationError("Email is required")
  if email.length > 254:
    throw ValidationError("Email exceeds maximum length")
  if not isValidEmailFormat(email):  // use a well-tested library
    throw ValidationError("Invalid email format")
  this.email = email.toLowerCase().trim()
```

**URL validation:**
```
// POOR: Accept any URL
function setCallbackUrl(url):
  this.callbackUrl = url

// GOOD: Validate scheme, domain, and structure
function setCallbackUrl(url):
  parsed = parseUrl(url)
  if parsed.scheme not in ["https"]:
    throw ValidationError("Only HTTPS URLs are allowed")
  if parsed.host in BLOCKED_HOSTS or isPrivateIp(parsed.host):
    throw ValidationError("URL points to a restricted destination")
  this.callbackUrl = parsed.toString()  // normalized
```

**File path validation:**
```
// POOR: Accept any path
function readFile(userPath):
  return fs.read(userPath)

// GOOD: Canonicalize and validate against allowlist
function readFile(userPath):
  canonicalPath = fs.realpath(UPLOAD_DIR + "/" + userPath)
  if not canonicalPath.startsWith(UPLOAD_DIR):
    throw SecurityError("Path traversal detected")
  return fs.read(canonicalPath)
```

---

## 3. Parameterized Query Patterns

### SQL (Direct)

```
// POOR: String concatenation -- SQL injection
function findUser(username):
  query = "SELECT * FROM users WHERE username = '" + username + "'"
  return db.execute(query)

// GOOD: Parameterized query
function findUser(username):
  query = "SELECT * FROM users WHERE username = ?"
  return db.execute(query, [username])
```

### ORM Patterns

```
// POOR: Raw query with interpolation through ORM
function searchProducts(term):
  return orm.rawQuery("SELECT * FROM products WHERE name LIKE '%" + term + "%'")

// GOOD: ORM query builder with bound parameters
function searchProducts(term):
  return orm.products
    .where("name", "LIKE", "%" + term + "%")  // ORM handles parameterization
    .findMany()
```

### NoSQL (Document Databases)

```
// POOR: User input directly in query operator
function findUser(input):
  return db.users.find({ username: input })
  // if input is { "$gt": "" }, this returns all users

// GOOD: Explicitly extract the expected scalar value
function findUser(input):
  if typeof input != "string":
    throw ValidationError("Username must be a string")
  return db.users.find({ username: input })
```

### Dynamic Query Building

```
// POOR: Dynamic column names from user input
function sortBy(column):
  return db.execute("SELECT * FROM products ORDER BY " + column)

// GOOD: Allowlist for dynamic identifiers
ALLOWED_SORT_COLUMNS = {"name", "price", "created_at"}

function sortBy(column):
  if column not in ALLOWED_SORT_COLUMNS:
    throw ValidationError("Invalid sort column")
  return db.execute("SELECT * FROM products ORDER BY " + column)
  // column is from a fixed allowlist, not user-controlled
```

---

## 4. Output Encoding by Context

Same data needs different encoding by render location. No single "sanitize" function.

### HTML Context

```
// POOR: Raw user data in HTML
function renderGreeting(username):
  return "<h1>Hello, " + username + "</h1>"
  // if username is "<script>alert('xss')</script>", this executes

// GOOD: HTML-encode user data
function renderGreeting(username):
  return "<h1>Hello, " + htmlEncode(username) + "</h1>"
  // htmlEncode converts < > & " ' to their HTML entities
```

### JSON Context

```
// POOR: String interpolation into JSON
function buildResponse(message):
  return '{"message": "' + message + '"}'
  // if message contains a quote, this breaks or injects

// GOOD: Use JSON serializer
function buildResponse(message):
  return JSON.stringify({ message: message })
```

### URL Context

```
// POOR: Raw user data in URL
function buildLink(searchTerm):
  return "/search?q=" + searchTerm

// GOOD: URL-encode user data
function buildLink(searchTerm):
  return "/search?q=" + urlEncode(searchTerm)
```

### Shell Context

```
// POOR: User data in shell command
function convertFile(filename):
  exec("convert " + filename + " output.png")

// GOOD: Avoid shell entirely; use direct process execution
function convertFile(filename):
  if not matches(filename, /^[a-zA-Z0-9._-]+$/):
    throw ValidationError("Invalid filename")
  execDirect(["convert", filename, "output.png"])  // no shell interpretation
```

---

## 5. Authorization Check Patterns

### Middleware Pattern

```
// Authorization enforced at middleware level
// Applies to all routes matching the pattern

router.use("/admin/*", requireRole("admin"))
router.use("/api/orders/:id", requireOwnership("order"))

function requireRole(role):
  return (req, res, next) =>
    if req.user.role != role:
      return res.status(403).json({ error: "Forbidden" })
    next()
```

### Service-Layer Pattern (Defense in Depth)

```
// Even with middleware, verify at the service layer
class OrderService:
  function cancelOrder(orderId, requestingUserId):
    order = this.orderRepository.findById(orderId)
    if order is null:
      throw NotFoundError("Order not found")

    // Authorization check at service layer -- defense in depth
    if order.userId != requestingUserId and not this.isAdmin(requestingUserId):
      throw ForbiddenError("Not authorized to cancel this order")

    order.cancel()
    this.orderRepository.save(order)
```

### Decorator/Attribute Pattern

```
// Language-level authorization annotation
@authorize(roles: ["admin", "manager"])
function deleteUser(userId):
  // authorization already verified by decorator
  user = userRepository.findById(userId)
  user.deactivate()
  userRepository.save(user)
```

### Resource-Level Authorization

```
// POOR: Only checks if user is authenticated
function getDocument(docId, user):
  if not user.isAuthenticated:
    throw UnauthorizedError()
  return documentRepository.findById(docId)  // any authenticated user can access any document

// GOOD: Checks if user is authorized for this specific resource
function getDocument(docId, user):
  if not user.isAuthenticated:
    throw UnauthorizedError()
  document = documentRepository.findById(docId)
  if not document.isAccessibleBy(user):
    throw ForbiddenError("Not authorized to access this document")
  return document
```

---

## 6. Secrets Management Patterns

### Environment Variables

```
// POOR: Hardcoded in source
const DB_PASSWORD = "super_secret_123"
const API_KEY = "sk-abc123def456"

// GOOD: From environment
const DB_PASSWORD = env.require("DB_PASSWORD")  // throws if not set
const API_KEY = env.require("API_KEY")
```

### Secret Manager Integration

```
// For production systems with secret rotation
class DatabaseConfig:
  function getConnectionString():
    secret = secretManager.getSecret("db/production/credentials")
    return buildConnectionString(
      host: secret.host,
      port: secret.port,
      user: secret.username,
      password: secret.password
    )
    // secret object goes out of scope and is garbage collected
```

### Logging Safely

```
// POOR: Logging credentials
log.info("Connecting to DB with user=" + dbUser + " password=" + dbPassword)
log.info("API request with key: " + apiKey)

// GOOD: Log the event, not the secret
log.info("Connecting to DB", { user: dbUser, host: dbHost })  // no password
log.info("API request initiated", { endpoint: url, hasApiKey: true })  // existence, not value
```

### Credential Rotation Pattern

```
// Design for rotation: accept multiple valid credentials during transition
class ApiAuthenticator:
  function validateKey(providedKey):
    validKeys = secretManager.getSecret("api/valid-keys")  // returns array
    return validKeys.any(key => secureCompare(key, providedKey))
    // during rotation, both old and new keys are valid
```

---

## 7. Injection Prevention Patterns

### SQL Injection

```
// VULNERABLE: String concatenation
query = "SELECT * FROM users WHERE email = '" + email + "' AND status = 'active'"
// Attack: email = "' OR '1'='1' --"

// FIXED: Parameterized
query = "SELECT * FROM users WHERE email = ? AND status = 'active'"
db.execute(query, [email])
```

### Command Injection

```
// VULNERABLE: Shell execution with user input
function compressFile(filename):
  exec("tar -czf archive.tar.gz " + filename)
  // Attack: filename = "file.txt; rm -rf /"

// FIXED: Avoid shell; use direct execution with argument array
function compressFile(filename):
  if not matches(filename, /^[a-zA-Z0-9._-]+$/):
    throw ValidationError("Invalid filename characters")
  execDirect(["tar", "-czf", "archive.tar.gz", filename])
```

### XSS Prevention

```
// VULNERABLE: Unencoded output
function renderComment(comment):
  return "<div class='comment'>" + comment.text + "</div>"

// FIXED: Context-aware encoding
function renderComment(comment):
  return "<div class='comment'>" + htmlEncode(comment.text) + "</div>"

// ALSO FIXED: Use a templating engine with auto-escaping
// Most modern frameworks (React, Angular, Jinja2, Thymeleaf) auto-escape by default
// Be cautious with "raw" or "safe" markers that disable escaping
```

### Path Traversal

```
// VULNERABLE: Direct path construction
function serveFile(filename):
  path = "/var/uploads/" + filename
  return readFile(path)
  // Attack: filename = "../../etc/passwd"

// FIXED: Canonicalize and validate
function serveFile(filename):
  basePath = "/var/uploads"
  requestedPath = realpath(basePath + "/" + filename)
  if not requestedPath.startsWith(basePath + "/"):
    throw SecurityError("Access denied: path traversal attempt")
  return readFile(requestedPath)
```

### SSRF Prevention

```
// VULNERABLE: Server fetches any URL
function fetchWebhook(url):
  return httpClient.get(url)
  // Attack: url = "http://169.254.169.254/latest/meta-data/" (AWS metadata)

// FIXED: Validate URL scheme and destination
ALLOWED_SCHEMES = {"https"}
BLOCKED_IP_RANGES = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16", "169.254.0.0/16"]

function fetchWebhook(url):
  parsed = parseUrl(url)
  if parsed.scheme not in ALLOWED_SCHEMES:
    throw SecurityError("Only HTTPS URLs are allowed")
  resolvedIp = dns.resolve(parsed.host)
  if isInRange(resolvedIp, BLOCKED_IP_RANGES):
    throw SecurityError("URL resolves to a blocked IP range")
  return httpClient.get(url)
```