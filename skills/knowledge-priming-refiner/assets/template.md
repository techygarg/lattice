# Knowledge Priming Refiner Template

This template defines the structure of the `.lattice/standards/knowledge-base.md` output document. It contains the 5-section anatomy with interview guidance comments for each section.

When producing the output, strip all `<!-- INTERVIEW GUIDANCE: -->` comments. The final document is a reference, not a conversation log.

---

## Frontmatter

<!-- INTERVIEW GUIDANCE:
Default to override since every project's knowledge base is unique.
-->

```yaml
---
feature: "<Project Name> Knowledge Base"
mode: override
created: "<date>"
---
```

---

## Preamble

<!-- INTERVIEW GUIDANCE:
Include the preamble matching the chosen mode. Only one preamble appears in the output.
-->

**Override preamble:**

> This is the knowledge base for [PROJECT NAME]. It primes AI with project-specific context -- tech stack, architecture, trusted sources, and project structure -- so generated code fits this codebase rather than defaulting to generic patterns.

**Overlay preamble:**

> This document contains selected knowledge base sections for [PROJECT NAME]. Sections included here were explicitly defined; other sections can be added in future revisions.

---

## 1. Architecture Overview

<!-- INTERVIEW GUIDANCE:
Purpose: Give AI the big picture -- what kind of application this is, what the major components are, and how they interact. Without this, AI has to guess the architecture from file names alone.

Ask: "What kind of application is this? What are the major components and how do they interact?"

Probing questions:
- Is this a monolith, microservices, serverless, or something else?
- What are the main modules or services?
- How do components communicate (HTTP, message queues, events, direct calls)?
- Is there a database-per-service or shared database?
- Are there any external integrations that shape the architecture?

Example of good content:

  This is a microservices-based e-commerce platform.
  - **API Gateway**: Handles routing, auth, rate limiting
  - **User Service**: Authentication, profiles, preferences
  - **Order Service**: Cart, checkout, order history
  - **Notification Service**: Email, SMS, push notifications

  Services communicate via async message queues (RabbitMQ).
  Each service owns its database (PostgreSQL).

Keep it to 5-10 lines. This is the elevator pitch, not the architecture doc.
-->

[Architecture overview content goes here]

---

## 2. Tech Stack and Versions

<!-- INTERVIEW GUIDANCE:
Purpose: Tell AI exactly which technologies and versions are in use. Version numbers matter because APIs change between versions -- "Prisma 5.x" tells AI which query API to use, while "Prisma" alone might produce code for any version.

Include "not X" clarifications -- these steer AI away from common defaults that do not apply. For example, "Fastify 4.x (not Express)" prevents AI from defaulting to Express patterns.

This section captures tool IDENTITY (which framework, which version). Language-level IDIOMS (how to write error handling, how to structure tests, how DI works) belong in the language-idioms document produced by the `language-idioms-refiner`.

Ask: "What technologies does your project use? Include version numbers where possible. Are there common alternatives that you explicitly do NOT use?"

Probing questions:
- Runtime and language version? (Node.js 20.x, Python 3.12, Go 1.22)
- Framework and version? (Fastify 4.x, Django 5.x, Spring Boot 3.x)
- Database and ORM? (PostgreSQL 15 with Prisma 5.x)
- Auth approach? (JWT with httpOnly cookies, OAuth2 with Clerk)
- Testing framework and runner? (Vitest, pytest, Go testing) -- just the tool name and "not X" if applicable; testing idioms and patterns are covered by the language-idioms document
- Validation library? (Zod, Pydantic, Joi)
- Any "not X" clarifications? (Fastify not Express, Vitest not Jest)

Example of good content:

  - **Runtime**: Node.js 20.x (LTS)
  - **Framework**: Fastify 4.x (not Express)
  - **Database**: PostgreSQL 15 with Prisma ORM 5.x
  - **Auth**: JWT with httpOnly cookies (not localStorage)
  - **Testing**: Vitest + Testing Library (not Jest)
  - **Validation**: Zod schemas (not Joi)

The "not X" clarifications are especially valuable -- they are project-specific anti-patterns that no other skill can know about.
-->

[Tech stack content goes here]

---

## 3. Curated Knowledge Sources

<!-- INTERVIEW GUIDANCE:
Purpose: Point AI to the sources the team actually trusts, rather than letting it draw from the generic internet. Every team has official docs they read, blog posts that influenced their architecture, and internal references that capture hard-won lessons.

Ask: "What are the 5-10 sources your team trusts most? Official docs, blog posts, internal references?"

Probing questions:
- Which official documentation do you actually reference? (Not all docs -- the ones you use)
- Are there blog posts or articles that shaped your architecture or patterns?
- Do you have internal docs (ADRs, error conventions, API design guides)?
- Are there any sources that are specifically NOT trusted or outdated?

Example of good content:

  ### Official Documentation
  | Topic | Source | Why We Trust It |
  |-------|--------|-----------------|
  | Fastify routing | https://fastify.dev/docs/latest/Guides/Getting-Started | Official, matches our v4.x |
  | Prisma relations | https://www.prisma.io/docs/orm/prisma-schema/data-model/relations | Authoritative for schema patterns |

  ### Internal References
  | Topic | Path | What It Captures |
  |-------|------|------------------|
  | Error conventions | docs/error-handling.md | Our specific patterns |
  | API design decisions | docs/adr/003-api-versioning.md | Decision rationale |

Keep it curated -- 5-10 high-value sources, not a comprehensive bibliography.
-->

[Curated knowledge sources content goes here]

---

## 4. Project Structure

<!-- INTERVIEW GUIDANCE:
Purpose: Show AI where things live. When AI knows the directory layout, it places new files correctly and uses the right import paths. Without this, AI guesses -- and often guesses wrong.

Ask: "What does your directory structure look like? Show the top 2-3 levels."

Probing questions:
- Where does business logic live?
- Where do route handlers / controllers go?
- Where are types or schemas defined?
- Is there a shared/common directory for cross-cutting concerns?
- How are tests organized (co-located, separate test/ directory)?
- Monorepo? If so, what is the package/workspace structure?

Example of good content:

  src/
  +-- modules/           # Feature modules (users/, products/, orders/)
  |   +-- [module]/
  |       +-- service.ts    # Business logic
  |       +-- routes.ts     # HTTP handlers
  |       +-- schema.ts     # Zod schemas
  |       +-- types.ts      # TypeScript types
  +-- shared/            # Cross-cutting (db, auth, queue)
  +-- config/            # Env config

Use ASCII tree format. Include brief annotations explaining what each directory contains.
-->

[Project structure content goes here]

---

## 5. Project Conventions

<!-- INTERVIEW GUIDANCE:
Purpose: Capture project-specific conventions that other skills cannot infer. This section is intentionally slim -- coding principles (naming, function design, anti-patterns) are handled by the clean-code atom. Only include conventions unique to THIS project.

Ask: "Are there any project-specific conventions that would not be obvious from the tech stack and structure? For example, file naming patterns, module organization rules, or team-specific practices?"

Examples of what belongs here:
- "Files use kebab-case (user-service.ts, not UserService.ts)"
- "Each module exports through an index.ts barrel file"
- "Feature flags are managed via LaunchDarkly; never hardcode toggles"
- "All API responses follow the { data, error, meta } envelope"

Examples of what does NOT belong here (covered by other skills):
- Function naming principles (clean-code)
- SRP, complexity, error handling patterns (clean-code)
- Layer responsibilities, dependency direction (architecture)
- Aggregate design, value objects (domain-driven-design)
- Language-level idioms: naming case conventions, error handling philosophy, testing patterns, DI approach (language-idioms document)

This section is optional. If the project has no conventions beyond what the tech stack implies, skip it.
-->

[Project conventions content goes here -- or omit if none]

---

## Footer

<!-- INTERVIEW GUIDANCE:
Include project name, generation date, and mode indicator in the output.
-->

---
*Generated for [PROJECT NAME] on [DATE]. Mode: [override|overlay].*
*Produced by the knowledge-priming-refiner skill.*
