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

## Self-Validation Checklist

STOP after generating each component. Verify ALL of the following before proceeding. If any check clearly fails, fix the code before presenting it. If a check is a judgment call with multiple valid approaches (see Ambiguity Signals), flag it — present your options and reasoning rather than silently choosing.

1. **TRUST BOUNDARIES**: Where does trusted code meet untrusted data? Are all boundaries explicitly identified?
2. **INPUT VALIDATION**: Is every external input validated at the boundary with allowlists before reaching business logic?
3. **QUERY SAFETY**: Are all database queries parameterized? Is there any string concatenation in query building?
4. **COMMAND SAFETY**: Is there any shell/command execution? If so, is input strictly allowlisted?
5. **SECRETS**: Are there any API keys, passwords, tokens, or connection strings in the code? If so → move to environment variables or secret manager.
6. **OUTPUT ENCODING**: Is output encoded appropriately for its rendering context (HTML, JSON, URL)?
7. **AUTHORIZATION**: Is authorization verified at the service layer, not just at the controller? Does each endpoint enforce least privilege?
8. **ERROR MESSAGES**: Do error messages exposed to users avoid revealing internal details (stack traces, SQL queries, file paths)?
9. **DEPENDENCIES**: Are newly introduced third-party packages necessary? Are versions pinned or constrained? Are any known-vulnerable packages being added?

## Active Anti-Pattern Scan

After verifying the checklist above, scan your output for these specific anti-patterns. If you find any, fix them before presenting the code.

- [ ] **Trust All Input**: No validation on request parameters; data flows directly to business logic → validate at boundary with allowlists
- [ ] **SQL String Concatenation**: User input interpolated into SQL queries → use parameterized queries or ORM query builders
- [ ] **Hardcoded Secrets**: API keys, passwords, or tokens in source code → use environment variables or secret managers
- [ ] **Missing Authorization**: Auth checked at login but not re-verified at service or resource level → check at every layer
- [ ] **Overly Broad Permissions**: Admin access granted where read-only would suffice → apply least privilege
- [ ] **Unvalidated Redirects**: User-controlled URLs used in redirects → allowlist permitted destinations
- [ ] **Verbose Error Messages**: Stack traces or SQL in API responses → return generic messages, log details server-side
- [ ] **Logging Sensitive Data**: Passwords, tokens, or PII in log files → log events, not values; mask sensitive fields

## Ambiguity Signals

These checks often have multiple valid outcomes. When you encounter one, present options rather than silently choosing.

- **Trust Boundary Scope**: An internal API behind a trusted gateway may or may not need full boundary validation. The answer depends on the deployment topology and threat model.
- **Error Message Detail**: How much information is "actionable but safe" depends on whether the consumer is a human user, a frontend client, or an internal service.
- **Validation Depth**: Whether to re-validate data at inner layers (defense-in-depth) or trust the boundary validation depends on the risk profile and performance requirements.
- **Auth vs Authz Failure Response**: Whether to return 401 (not authenticated) or 403 (not authorized) depends on whether the identity is known. Conflating them leaks information (a 403 confirms the resource exists). When the consumer is a human user, distinguish clearly; when the consumer is an internal service, the separation may differ.

## Core Principle

Security is about **thinking in trust boundaries**. Every data flow crosses a boundary somewhere -- between the user and the server, between the application and the database, between your code and a third-party API. The question is not "could this be exploited?" but "where does trusted meet untrusted, and what happens at that boundary?"

This atom teaches adversarial thinking during code generation, not as an afterthought. When writing code, identify trust boundaries as you go -- the same way a skilled developer considers edge cases. The cost of building security in during generation is near zero; the cost of retrofitting it after a breach is catastrophic.

The boundary with clean-code: clean-code says "handle errors explicitly with actionable messages." Secure-coding says "error messages shown to users must not reveal internal details." Both apply; this skill governs the security dimension.

The boundary with clean-architecture: "check authorization at every layer" (this skill) maps directly to clean-architecture's layer structure. Clean-architecture defines *where* each check lives (service layer, not controller); secure-coding defines *what* to check (identity confirmed, permission granted, resource owned).

## Trust Boundaries

**All external data is hostile until proven otherwise.** Common boundaries: HTTP requests (query params, headers, body, cookies), file uploads (names, types, contents), database reads (may be poisoned), third-party API responses, user-controlled configuration, and deserialization from external sources.

When generating code that crosses a boundary, explicitly identify which side is trusted and which is not. If you cannot determine the trust level, treat it as untrusted. See `./references/defaults.md` for trust boundary identification patterns.

## Input Validation and Sanitization

Validate at the boundary, not deep in business logic. The rules:

- **Allowlist over denylist.** Denylist approaches miss novel attack vectors.
- **Type-check, range-check, format-check.** A "quantity" should be a positive integer within a reasonable range, not an arbitrary string.
- **Sanitize for the output context.** HTML encoding for HTML, parameterization for SQL, shell escaping for commands.
- **Never trust client-side validation alone.** All validation must be enforced server-side.

See `./references/defaults.md` for input validation patterns by type.

## Authentication vs Authorization

Separate concerns, implemented separately. The rules:

- **Check authorization at every layer** -- not just at the controller. Hiding a button does not prevent a direct API call.
- **Least privilege.** Grant the minimum permissions needed for each operation.
- **Separate auth failures from authz failures.** "Invalid credentials" vs "you do not have permission" -- conflating them leaks information.

See `./references/defaults.md` for authorization check patterns.

## Secrets Management

- **No secrets in code** -- not in source files, not in committed config, not in comments, not in log output.
- **Use environment variables or secret managers.**
- **Rotate credentials.** Design systems to support rotation without downtime.
- **Log the fact, not the value.** Log that authentication occurred, not the credentials used.

See `./references/defaults.md` for secrets management patterns.

## Injection Prevention

Root cause: treating user input as trusted structure. Separate data from instructions.

- **SQL injection** -- Parameterized queries only. Never concatenate user input into SQL strings.
- **Command injection** -- Avoid shell execution. If unavoidable, allowlist commands and arguments.
- **XSS** -- Context-aware output encoding (HTML, JavaScript, URL contexts).
- **Path traversal** -- Canonicalize and validate against an allowlist. Reject `..` and unexpected absolute paths.
- **SSRF** -- Allowlist permitted domains and schemes. Block internal/private IP ranges.

See `./references/defaults.md` for injection prevention patterns.
