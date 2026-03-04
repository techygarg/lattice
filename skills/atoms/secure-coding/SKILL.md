---
name: secure-coding
description: "Apply security-conscious thinking when generating or modifying code. Enforces trust boundary awareness, input validation, injection prevention, secrets management, and defense-in-depth authorization. Use when generating code that handles user input, authentication, authorization, database queries, external APIs, file operations, or when the user mentions 'security review', 'secure this', 'check for vulnerabilities', 'trust boundary', 'input validation', or 'OWASP'. This skill governs the security posture of generated code -- not architecture (see clean-architecture) and not code craft (see clean-code)."
---

# Secure Coding

## Config Resolution

This skill supports project-specific customizations. Resolution order:

1. Look for `.ai/config.yaml` in the repository root
2. If found, check `paths.secure_coding` for a custom document path
3. If the custom path exists, read that document and check its YAML frontmatter for `mode`:
   - **`mode: override`** (or no mode specified): The custom document takes full precedence.
     Use it instead of the embedded defaults. It must be comprehensive -- it is the sole reference.
   - **`mode: overlay`**: Read the embedded `./references/defaults.md` first, then apply the
     custom document's sections on top. Sections in the custom document replace matching
     sections in defaults (matched by heading). New sections are appended after defaults.
4. If no config, no path, or path not found, read `./references/defaults.md`

The defaults ship with this skill and represent opinionated best practices.
They work out of the box for any project. Override only when your team has
specific standards that differ from the defaults.

## Core Principle

Security is about **thinking in trust boundaries**. Every data flow crosses a boundary somewhere -- between the user and the server, between the application and the database, between your code and a third-party API. The question is not "could this be exploited?" but "where does trusted meet untrusted, and what happens at that boundary?"

This atom teaches adversarial thinking during code generation, not as an afterthought. When writing code, identify trust boundaries as you go -- the same way a skilled developer considers edge cases. The cost of building security in during generation is near zero; the cost of retrofitting it after a breach is catastrophic.

The boundary with clean-code: clean-code says "handle errors explicitly with actionable messages." Secure-coding says "error messages shown to users must not reveal internal details." Both apply; this skill governs the security dimension.

## Trust Boundaries

A trust boundary exists wherever trusted code meets untrusted data. The default stance: **all external data is hostile until proven otherwise.** Common boundaries:

- **HTTP requests** -- query parameters, headers, body, cookies. All user-controlled.
- **File uploads** -- filenames, content types, and file contents. All user-controlled.
- **Database reads** -- data may have been poisoned by a prior injection or compromised process.
- **Third-party API responses** -- external services can return unexpected or malicious data.
- **User-controlled configuration** -- environment variables set by deployers, feature flags, URL parameters.
- **Deserialization** -- JSON, XML, YAML, or binary formats from external sources can trigger unexpected behavior.

Every boundary needs validation. When generating code that crosses a boundary, explicitly identify which side is trusted and which is not. If you cannot determine the trust level, treat it as untrusted. See `./references/defaults.md` for trust boundary identification patterns and diagrams.

## Input Validation and Sanitization

Validate at the boundary, not deep in business logic. By the time data reaches the domain layer, it should already be validated and safe. The rules:

- **Allowlist over denylist.** Define what is acceptable, not what is forbidden. Denylist approaches miss novel attack vectors.
- **Type-check, range-check, format-check.** A "quantity" should be a positive integer within a reasonable range, not an arbitrary string.
- **Sanitize for the output context.** HTML encoding for HTML output, parameterization for SQL, shell escaping for commands. The same input may need different sanitization depending on where it is used.
- **Never trust client-side validation alone.** Client-side validation is a UX convenience, not a security control. All validation must be enforced server-side.

See `./references/defaults.md` for input validation patterns by type (string, number, email, URL, file path) with before/after examples.

## Authentication vs Authorization

Authentication answers "who are you?" Authorization answers "are you allowed to do this?" They are separate concerns and must be implemented separately.

- **Check authorization at every layer.** A common mistake is checking auth at the controller but not re-verifying at the service layer. Defense in depth means verifying at multiple layers.
- **Never rely on UI-level restrictions** to prevent unauthorized access. Hiding a button does not prevent a direct API call.
- **Use principle of least privilege.** Grant the minimum permissions needed for each operation. Overly broad permissions are a latent vulnerability.
- **Separate authentication failures from authorization failures.** "Invalid credentials" vs "you do not have permission" -- conflating them leaks information.

See `./references/defaults.md` for authorization check patterns (middleware, decorator, inline).

## Secrets Management

Secrets in source code are the most common and most preventable security failure. The rules are absolute:

- **No secrets in code** -- not in source files, not in config files committed to version control, not in comments, not in log output.
- **Use environment variables or secret managers.** Twelve-factor app principles apply: configuration that varies between environments belongs in the environment.
- **Rotate credentials.** Assume every secret has a shelf life. Design systems to support rotation without downtime.
- **Minimize secret lifetime in memory.** If a secret must exist in memory, scope it tightly and clear it when done.
- **Log the fact, not the value.** Log that authentication occurred, not the credentials used. Log that a secret was accessed, not the secret itself.

See `./references/defaults.md` for secrets management patterns (env vars, secret managers, rotation).

## Injection Prevention

Injection attacks share a common root cause: treating user input as trusted structure. The fix is always the same -- separate data from instructions.

- **SQL injection** -- Use parameterized queries. Never concatenate user input into SQL strings. ORMs generally parameterize by default, but raw queries require explicit parameterization.
- **Command injection** -- Avoid shell execution entirely when possible. If unavoidable, use allowlists for commands and arguments. Never pass user input directly to a shell.
- **XSS (Cross-Site Scripting)** -- Context-aware output encoding. HTML-encode for HTML context, JavaScript-encode for script context, URL-encode for URL context.
- **Path traversal** -- Canonicalize paths and validate against an allowlist of permitted directories. Reject paths containing `..` or absolute paths when relative paths are expected.
- **SSRF (Server-Side Request Forgery)** -- Validate and restrict outbound URLs. Allowlist permitted domains and schemes. Block requests to internal/private IP ranges.

The common thread: never treat user input as trusted structure. See `./references/defaults.md` for injection prevention patterns with before/after examples.

## Dependency and Supply Chain Awareness

Your code is only as secure as its weakest dependency. When adding or updating dependencies:

- **Pin dependency versions.** Avoid floating ranges that auto-upgrade to potentially compromised versions.
- **Be cautious with transitive dependencies.** A direct dependency may pull in dozens of indirect ones, each expanding the attack surface.
- **Prefer well-maintained packages** with security track records, active maintainers, and timely vulnerability patches.
- **Ask the question**: does this dependency expand the attack surface? Could a compromised version affect our system? Is there a simpler alternative?

See `./references/defaults.md` for dependency evaluation criteria and supply chain risk patterns.

## Self-Validation During Code Generation

When generating code, apply these checks as you write -- not as a post-generation review, but as an inline discipline:

1. **Identify trust boundaries**: Where does trusted code meet untrusted data in this code? Are all boundaries explicit?
2. **Validate inputs at boundaries**: Is every external input validated before it reaches business logic?
3. **Check query construction**: Are all database queries parameterized? Any string concatenation in query building?
4. **Scan for shell execution**: Is there any shell/command execution? If so, is input allowlisted?
5. **Check for hardcoded secrets**: Are there any API keys, passwords, tokens, or connection strings in the code?
6. **Verify output encoding**: Is output encoded appropriately for its context (HTML, JSON, URL)?
7. **Check authorization**: Is authorization verified at the service layer, not just at the controller?
8. **Review error messages**: Do error messages exposed to users avoid revealing internal details (stack traces, SQL queries, file paths)?

## Anti-Patterns

Common security violations and their fixes. See `./references/defaults.md` for code examples showing each violation and its correction.

| Anti-Pattern | Symptom | Fix |
|-------------|---------|-----|
| **Trust All Input** | No validation on request parameters; data flows directly to business logic | Validate at the boundary with allowlists; type-check, range-check, format-check |
| **SQL String Concatenation** | User input interpolated directly into SQL queries | Use parameterized queries or ORM query builders with bound parameters |
| **Hardcoded Secrets** | API keys, passwords, or tokens embedded in source code or config files | Use environment variables or secret managers; add secret patterns to `.gitignore` |
| **Missing Authorization** | Auth checked at login but not re-verified at service or resource level | Check authorization at every layer; enforce at the service level, not just the UI |
| **Overly Broad Permissions** | Admin-level access granted where read-only would suffice | Apply principle of least privilege; grant minimum permissions per operation |
| **Unvalidated Redirects** | User-controlled URLs used in redirects without validation | Allowlist permitted redirect destinations; reject absolute URLs or external domains |
| **Verbose Error Messages** | Stack traces, SQL queries, or file paths exposed in API error responses | Return generic messages to users; log detailed errors server-side only |
| **Logging Sensitive Data** | Passwords, tokens, or PII written to log files | Log events, not values; mask or omit sensitive fields in log output |

## Validation Checklist

When generating or reviewing code, verify these constraints.

| Check | Why It Matters |
|-------|---------------|
| Trust boundaries are explicitly identified | Unidentified boundaries are undefended boundaries -- the most common root cause of security failures |
| Inputs are validated at the boundary with allowlists | Late validation lets malicious data propagate; denylist approaches miss novel attack vectors |
| All database queries use parameterized parameters | SQL injection remains a top-10 vulnerability because string concatenation is the path of least resistance |
| No hardcoded secrets in source or committed config | Secrets in version control are exposed to every developer, CI system, and potential repository leak |
| Output is encoded for its rendering context | Context-unaware encoding (or none) enables XSS -- the most common web vulnerability |
| Authorization is checked at the service layer | UI-only auth checks are trivially bypassed by direct API calls |
| Error messages are safe for external display | Verbose errors reveal architecture, technology stack, and potential attack vectors to adversaries |
| Dependencies are pinned to specific versions | Floating versions can auto-upgrade to compromised packages without anyone noticing |
