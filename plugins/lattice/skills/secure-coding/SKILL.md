---
name: secure-coding
description: "Apply security-conscious thinking when generating or modifying code. Enforces trust boundary awareness, input validation, injection prevention, secrets management, and defense-in-depth authorization. Use when generating code that handles user input, authentication, authorization, database queries, external APIs, or file operations, or when the user mentions 'security review', 'secure this', 'check for vulnerabilities', 'trust boundary', 'input validation', or 'OWASP'. Loaded automatically by the code-generating molecules (code-forge, refactor-safely, bug-fix). This skill governs the security posture of generated code -- not architecture (see architecture) and not code craft (see clean-code)."
---

# Secure Coding

## Config Resolution

Projects can customize this skill's standards. Resolution order:

1. Read `.lattice/config.yaml` in the repo root.
2. If found, check `paths.secure_coding` for a custom document path.
3. If a custom document exists at that path, read it and check its YAML frontmatter for `mode`:
   - **`mode: override`**: the custom document has full precedence. Use it instead of the embedded defaults. It must be comprehensive -- treat it as the sole reference.
   - **`mode: overlay`** (or no mode field): read the embedded `./references/defaults.md` first, then apply the custom document's sections on top. A custom section replaces the matching default section (matched by exact heading); new sections append after the defaults.
4. If a custom path is configured but no document exists at it → tell the user which configured path is missing, then fall back to `./references/defaults.md`.
5. If there is no config file or no `paths.secure_coding` key, read `./references/defaults.md`.
6. **Language adaptation**: if `paths.language_idioms` is set in the config and the document exists, read its **"Error Handling"** section and adapt §2 (Input Validation Patterns) error-message patterns to the language's idioms. Language idioms take precedence over the pseudocode defaults.

## Self-Validation Checklist

**STOP after generating each component. Verify ALL checks before proceeding. A check clearly fails → fix the code before presenting. A check is a judgment call with multiple valid approaches (see Ambiguity Signals) → flag it -- present options and reasoning rather than silently choosing.**

1. **TRUST BOUNDARIES**: Where does trusted code meet untrusted data? Are all boundaries explicitly identified?
2. **INPUT VALIDATION**: Is every external input validated at the boundary with an allowlist before it reaches business logic?
3. **QUERY SAFETY**: Are all database queries parameterized? Is any string concatenation used in query building?
4. **COMMAND SAFETY**: Is there any shell/command execution? If so, is the input strictly allowlisted?
5. **SECRETS**: Are there API keys, passwords, tokens, or connection strings in code? If so → move them to environment variables or a secret manager.
6. **OUTPUT ENCODING**: Is output encoded appropriately for its render context (HTML, JSON, URL)?
7. **AUTHORIZATION**: Is authorization verified at the service layer, not just the controller? Does every endpoint enforce least privilege?
8. **ERROR MESSAGES**: Do error messages exposed to users avoid revealing internal detail (stack traces, SQL queries, file paths)?
9. **DEPENDENCIES**: Is each new third-party package necessary? Are versions pinned or constrained? Is any known-vulnerable package being added?

All checks pass → state "Passes secure-coding. [next step]."

## Active Anti-Pattern Scan

**STOP:** After verifying the checklist above, scan the output for each anti-pattern below. Any box you can check → fix before presenting the code.

- [ ] **Trust All Input**: no validation on request parameters; data flows straight into business logic → validate at the boundary with an allowlist.
- [ ] **SQL String Concatenation**: user input interpolated into a SQL query → use a parameterized query or ORM query builder.
- [ ] **Hardcoded Secrets**: API key, password, or token in source code → use an env var or secret manager.
- [ ] **Missing Authorization**: auth checked at login but not re-verified at the service or resource level → check at every layer.
- [ ] **Overly Broad Permissions**: admin access granted where read-only suffices → apply least privilege.
- [ ] **Unvalidated Redirects**: a user-controlled URL used in a redirect → allowlist permitted destinations.
- [ ] **Verbose Error Messages**: stack trace or SQL in an API response → return a generic message; log details server-side.
- [ ] **Logging Sensitive Data**: passwords, tokens, or PII in log files → log the event, not the value; mask sensitive fields.

## Ambiguity Signals

Checks here often have multiple valid outcomes. When you encounter one, present the options rather than silently choosing. If `framework:collaborative-judgment` is loaded, use its presentation format.

- **Trust Boundary Scope**: an internal API behind a trusted gateway may or may not need full boundary validation.
- **Error Message Detail**: how much detail is "actionable but safe" depends on whether the consumer is a human user, a frontend client, or an internal service.
- **Validation Depth**: whether to re-validate at inner layers (defense-in-depth) or trust boundary validation alone.
- **Auth vs Authz Failure Response**: whether to return 401 (not authenticated) or 403 (not authorized) depends on whether the identity is known.

## Core Principle

Govern the security posture of generated code -- trust boundaries, input validation, injection prevention, secrets, authorization.

Boundary with clean-code: clean-code governs error-message craft; this skill governs what error messages must not reveal (internal detail).

Boundary with architecture: architecture defines *where* checks live (service layer, not controller); this skill defines *what* to check (identity confirmed, permission granted, resource owned).

See `./references/defaults.md`.
