---
name: secure-coding
description: "Apply security-conscious thinking when generating or modifying code. Enforces trust boundary awareness, input validation, injection prevention, secrets management, and defense-in-depth authorization. Use when generating code that handles user input, authentication, authorization, database queries, external APIs, file operations, or when the user mentions 'security review', 'secure this', 'check for vulnerabilities', 'trust boundary', 'input validation', or 'OWASP'. This skill governs the security posture of generated code -- not architecture (see architecture) and not code craft (see clean-code)."
---

# Secure Coding

## Config Resolution

Skill support project-custom. Order:

1. Look `.lattice/config.yaml` in repo root
2. If found, check `paths.secure_coding` for custom doc path
3. If custom path exist, read doc, check YAML frontmatter for `mode`:
   - **`mode: override`** (or no mode): Custom doc take full precedence.
     Use instead embed default. Must be comprehensive -- sole reference.
   - **`mode: overlay`**: Read embed `./references/defaults.md` first, then apply
     custom doc sections on top. Custom sections replace matching
     sections in default (match by heading). New sections append after default.
4. If no config, no path, or path not found, read `./references/defaults.md`
5. **Language adaptation**: If `paths.language_idioms` exist in config, read **"Error Handling"** section and adapt §1 (Trust Boundary Identification) error message patterns to language idioms. Language idioms take precedence over pseudocode defaults.

## Self-Validation Checklist

STOP after gen each component. Verify ALL before proceed. If check clearly fail, fix code before present. If check judgment call with multiple valid approach (see Ambiguity Signals), flag — present options and reasoning rather than silent choose.

1. **TRUST BOUNDARIES**: Where trusted code meet untrusted data? All boundaries explicit identified?
2. **INPUT VALIDATION**: Every external input validated at boundary with allowlist before reach business logic?
3. **QUERY SAFETY**: All database query parameterized? Any string concat in query build?
4. **COMMAND SAFETY**: Any shell/command execution? If so, input strict allowlisted?
5. **SECRETS**: Any API key, password, token, connection string in code? If so → move to env var or secret manager.
6. **OUTPUT ENCODING**: Output encoded appropriate for render context (HTML, JSON, URL)?
7. **AUTHORIZATION**: Authorization verified at service layer, not just controller? Each endpoint enforce least privilege?
8. **ERROR MESSAGES**: Error message exposed to user avoid reveal internal detail (stack trace, SQL query, file path)?
9. **DEPENDENCIES**: New third-party package necessary? Version pinned or constrained? Any known-vulnerable package added?

## Active Anti-Pattern Scan

**STOP:** After verify checklist above, scan output for specific anti-pattern. If find any, fix before present code.

- [ ] **Trust All Input**: No validation on request param; data flow direct to business logic → validate at boundary with allowlist
- [ ] **SQL String Concatenation**: User input interpolated into SQL query → use parameterized query or ORM query builder
- [ ] **Hardcoded Secrets**: API key, password, token in source code → use env var or secret manager
- [ ] **Missing Authorization**: Auth checked at login but not re-verified at service or resource level → check at every layer
- [ ] **Overly Broad Permissions**: Admin access granted where read-only suffice → apply least privilege
- [ ] **Unvalidated Redirects**: User-controlled URL used in redirect → allowlist permitted destination
- [ ] **Verbose Error Messages**: Stack trace or SQL in API response → return generic message, log detail server-side
- [ ] **Logging Sensitive Data**: Password, token, PII in log file → log event, not value; mask sensitive field

## Ambiguity Signals

Check often have multiple valid outcome. When encounter, present option rather than silent choose.

- **Trust Boundary Scope**: Internal API behind trusted gateway may or may not need full boundary validation.
- **Error Message Detail**: How much info is "actionable but safe" depend on whether consumer is human user, frontend client, or internal service.
- **Validation Depth**: Whether to re-validate at inner layer (defense-in-depth) or trust boundary validation alone.
- **Auth vs Authz Failure Response**: Whether to return 401 (not authenticated) or 403 (not authorized) depend on whether identity is known.

## Core Principle

Govern security posture of generated code — trust boundaries, input validation, injection prevention, secrets, authorization.

Boundary with clean-code: clean-code governs error message craft; this skill governs what error messages must not reveal (internal detail).

Boundary with architecture: architecture defines *where* checks live (service layer, not controller); this skill defines *what* to check (identity confirmed, permission granted, resource owned).

See `./references/defaults.md`.