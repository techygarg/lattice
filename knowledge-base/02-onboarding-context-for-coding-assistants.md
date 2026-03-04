# Onboarding Context for Coding Assistants

*AI coding assistants default to generic patterns from their training data. I propose treating project context as infrastructure—versioned files that prime the model before each session—rather than relying on ad-hoc copy-pasting. This is essentially manual RAG (Retrieval-Augmented Generation), and I believe it fundamentally changes the quality of AI-generated code.*

---

When I onboard a new developer, I don't just point them at the codebase and say "go." I walk them through our conventions. I show them examples of code we consider good. I explain why we made certain architectural choices—why we use Fastify instead of Express, why services are functional instead of class-based, why validation happens at the route level. Only after this context-setting do I expect them to contribute code that fits.

AI coding assistants need the same onboarding.

Many developers experience what might be called a "Frustration Loop" with AI assistants: generate code, find it doesn't fit the codebase, regenerate with corrections, repeat until giving up or accepting heavily-modified output. I have come to believe this friction stems not from AI capability, but from a missing step—we ask AI to contribute without first sharing the context it needs.

This article explores what I call **Knowledge Priming**—the practice of sharing curated project context with AI before asking it to generate code.

The core insight is simple: AI assistants are like highly capable but entirely contextless collaborators. They can work faster than any human, but they know nothing about a specific project's conventions, constraints, or history. Without context, they default to generic patterns that may or may not fit.

---

## The Default Behavior Problem

Here is what typically happens when asking AI to generate code without priming:

**Request:** "Create a UserService that handles authentication"

**AI generates 200 lines of code using:**
- Express.js (the project uses Fastify)
- JWT stored in localStorage (the project uses httpOnly cookies)
- A `utils/auth.js` helper (the convention is `lib/services/`)
- Class-based syntax (the codebase is functional)
- An outdated bcrypt API (the project uses the latest version)

The code *works*. It is syntactically correct. It might even pass basic tests. But it is completely wrong for the codebase.

Why? Because AI defaults to its training data—a blend of millions of repositories, tutorials, and Stack Overflow answers. It generates the "average" solution from the internet, not the right solution for a specific team.

This is exactly what would happen if I asked a new hire to write code on Day 1 without any onboarding. They would draw on their prior experience—which may or may not match our conventions.

### The Knowledge Hierarchy

I find it helpful to think of AI knowledge in three layers, ordered by priority:

1. **Training Data** (lowest priority): Millions of repositories, tutorials, generic patterns—often outdated. This is "the average of the internet."

2. **Conversation Context** (medium priority): What has been discussed in the current session, recent files the AI has seen. This fades over long conversations.

3. **Priming Documents** (highest priority): Explicit project context—architecture decisions, naming conventions, specific versions and patterns. When provided, these override the generic defaults.

The hierarchy matters. When priming documents are provided, the instruction is essentially: "Ignore the generic internet patterns. Here is how this project works." And in my experience, AI does listen.

Technically, this is manual RAG (Retrieval-Augmented Generation)—filling the context window with high-value project-specific tokens that override lower-priority training data. Just as a new hire's prior habits are overridden by explicit team conventions once explained, AI's training-data defaults yield to explicit priming.

There is a mechanistic reason this works. Transformer models process context through attention mechanisms that operate, in effect, as a finite budget—every token in the context window competes for influence over the model's output. When the window is filled with generic training-data patterns, the model draws on the average of everything it has seen. When it is filled with specific, high-signal project context, those tokens attract more attention weight and steer generation toward the patterns that matter. This is why curation matters more than volume: a focused priming document does not just *add* context, it shifts the balance of what the model pays attention to.

---

## What Knowledge Priming Looks Like

Knowledge Priming is the practice of sharing curated documentation, architectural patterns, and version information with AI *before* asking it to generate code.

Think of it as the onboarding packet for a new hire:
- "Here is the tech stack and versions"
- "Here is how code is structured"
- "Here are the naming conventions"
- "Here are examples of good code in this codebase"

### Before and After

Without priming, a request for a UserService might yield Express.js, class-based code, wrong file paths, and outdated APIs—requiring 45 minutes of fixing or a complete rewrite.

With priming, the same request might yield Fastify, functional patterns, correct file paths, and current APIs—requiring only 5 minutes of review and minor tweaks.

I cannot claim this is a validated finding, but the reasoning seems sound: explicit context should override generic defaults. My own experiments have been encouraging.

---

## Anatomy of a Priming Document

A good priming document is not a brain dump. It is a curated, structured guide that gives AI exactly what it needs—no more, no less.

I propose seven sections. Each mirrors what I would walk through when onboarding a human colleague:

### 1. Architecture Overview

*What I tell a new hire: "Let me explain the big picture first."*

The big picture. What kind of application is this? What are the major components? How do they interact?

```markdown
## Architecture Overview
This is a microservices-based e-commerce platform.
- **API Gateway**: Handles routing, auth, rate limiting
- **User Service**: Authentication, profiles, preferences
- **Order Service**: Cart, checkout, order history
- **Notification Service**: Email, SMS, push notifications

Services communicate via async message queues (RabbitMQ).
Each service owns its database (PostgreSQL).
```

### 2. Tech Stack and Versions

*What I tell a new hire: "Here's our stack—and watch out for version-specific APIs."*

Specificity matters. Version numbers matter—APIs change between versions.

```markdown
## Tech Stack
- **Runtime**: Node.js 20.x (LTS)
- **Framework**: Fastify 4.x (not Express)
- **Database**: PostgreSQL 15 with Prisma ORM 5.x
- **Auth**: JWT with httpOnly cookies (not localStorage)
- **Testing**: Vitest + Testing Library (not Jest)
- **Validation**: Zod schemas (not Joi)
```

### 3. Curated Knowledge Sources

*What I tell a new hire: "Before you search the internet, here are the docs and blogs that shaped how we think. Start here."*

Every team has trusted sources: the official documentation they actually read, but also the blog posts that influenced their architecture, the tutorials that explained things clearly, the articles that captured lessons the docs never will. Together, these form the team's shared mental model.

When AI consults curated sources first—rather than its vast, generic training data—the output aligns faster. The team's thinking is already baked in.

```markdown
## Curated Knowledge

### Official Documentation
| Topic | Source | Why We Trust It |
|-------|--------|-----------------|
| Fastify routing | https://fastify.dev/docs/latest/Guides/Getting-Started | Official, matches our v4.x |
| Prisma relations | https://www.prisma.io/docs/orm/prisma-schema/data-model/relations | Authoritative for schema patterns |

### Blogs & Articles We Follow
| Concept | Source | Why It Shaped Our Thinking |
|---------|--------|---------------------------|
| Error handling patterns | [team-vetted blog URL] | Clearer than official docs, practical examples |
| Testing strategies | [team-vetted blog URL] | Influenced our test architecture |

### Internal References
| Topic | Path | What It Captures |
|-------|------|------------------|
| Error conventions | docs/error-handling.md | Our specific patterns |
| API design decisions | docs/adr/003-api-versioning.md | Decision rationale |
```

Keep this curated—not comprehensive. Five to ten sources that genuinely shaped how the team works.

### 4. Project Structure

*What I tell a new hire: "Here's where things live. File placement matters."*

Where things live. File placement matters.

```
src/
├── lib/
│   ├── services/      # Business logic (UserService, OrderService)
│   ├── repositories/  # Database access layer
│   ├── schemas/       # Zod validation schemas
│   └── utils/         # Pure utility functions
├── routes/            # Fastify route handlers
├── middleware/        # Auth, logging, error handling
├── types/             # TypeScript type definitions
└── config/            # Environment-specific config
```

### 5. Naming Conventions

*What I tell a new hire: "Here are the naming conventions. Consistency matters more than personal preference."*

Explicit conventions prevent style drift.

```markdown
## Naming Conventions
- **Files**: kebab-case (`user-service.ts`, not `UserService.ts`)
- **Functions**: camelCase, verb-first (`createUser`, `validateToken`)
- **Types/Interfaces**: PascalCase with descriptive suffixes (`UserCreateInput`, `AuthResponse`)
- **Constants**: SCREAMING_SNAKE_CASE (`MAX_RETRY_COUNT`)
- **Boolean variables**: is/has/can prefix (`isActive`, `hasPermission`)
```

### 6. Code Examples

*What I tell a new hire: "Here's an example of code we consider good. Follow this pattern."*

Show, do not just tell. Include 2-3 examples of "good code" from the codebase.

```typescript
// lib/services/user-service.ts
import { prisma } from '../db/client'
import { UserCreateInput, UserResponse } from '../types/user'
import { hashPassword } from '../utils/crypto'

export async function createUser(input: UserCreateInput): Promise<UserResponse> {
  const hashedPassword = await hashPassword(input.password)
  
  const user = await prisma.user.create({
    data: {
      ...input,
      password: hashedPassword,
    },
    select: {
      id: true,
      email: true,
      createdAt: true,
      // Never return password
    },
  })
  
  return user
}
```

Note: Services are pure functions, not classes. They receive dependencies via parameters when needed.

### 7. Anti-patterns to Avoid

*What I tell a new hire: "Here's what NOT to do. We've learned these lessons the hard way."*

Tell AI what NOT to do. This prevents common mistakes.

```markdown
## Anti-patterns (Do NOT use)
- Class-based services (use functional approach)
- Express.js patterns (this project uses Fastify)
- Storing JWT in localStorage (use httpOnly cookies)
- Using `any` type (always define proper types)
- Putting business logic in route handlers (use services)
- Raw SQL queries (use Prisma ORM)
```

---

## Priming as Infrastructure, Not Habit

The most powerful approach, I believe, is treating priming as **infrastructure** rather than habit.

Instead of manually pasting context at the start of each session (a habit that fades), store the priming document in the repository where it applies automatically:

```
# Cursor
.cursor/
├── rules                    # Always-on project context (auto-loaded)
└── commands/
    └── priming.md          # Referenceable with @priming

# GitHub Copilot
.github/
└── copilot-instructions.md  # Workspace-level instructions

# Claude Projects
Upload priming doc to Project Knowledge
```

Why infrastructure beats copy-paste:
- **Version controlled**: Changes are auditable and reviewable
- **Applies automatically**: No manual copy-paste each session
- **Team-wide consistency**: Everyone gets the same context
- **PR-reviewable changes**: Governance built into existing workflows

This transforms priming from a "personal productivity hack" into "team infrastructure." The difference between a habit that fades and a practice that persists.

Just as onboarding materials for new hires are maintained as organizational assets—not improvised each time—priming documents should be treated as first-class artifacts.

---

## Common Pitfalls

In my own experimentation, I have observed several failure modes:

| Pitfall | Alternative |
|---------|-------------|
| **Too much information**: 20+ page docs overwhelm AI and dilute focus | Keep it to 1-3 pages of essential context |
| **Too vague**: "Modern best practices" tells AI nothing | Be specific: "Fastify 4.x, Prisma 5.x, functional services" |
| **No examples**: Describing patterns without showing them | Include 2-3 real code snippets from the codebase |
| **Outdated content**: Priming doc from 6 months ago | Review and update monthly, or when major changes happen |
| **Missing anti-patterns**: Telling AI what TO do but not what to AVOID | Explicitly list patterns not wanted |

### The "Too Much" Trap

One mistake is treating the priming document like comprehensive documentation. It is not. It is a *cheat sheet* for AI—the minimum context needed to generate aligned code.

If a priming doc is longer than 3 pages, consider:
- Does AI need *all* of this to generate a service?
- Can detailed docs live elsewhere and just be referenced?
- Are edge cases included that rarely come up?

AI can always ask follow-up questions. Start focused, expand only when needed.

---

## Keeping Priming Documents Current

Documentation rots. Every team has a graveyard of outdated wikis and stale READMEs. How to prevent a priming doc from joining them?

**Treat it as code, not docs:**
- Store in repo: `docs/ai-priming.md`
- Changes require PR review (like any code change)
- Tech lead owns quarterly review (aligned with dependency updates)

**Reference, do not duplicate:**
- For auth decisions: "See ADR-007"
- For API contracts: "See OpenAPI spec in `/api/schema.yaml`"
- For deployment patterns: "See ops runbook"

**Update triggers:**

| Trigger | Action |
|---------|--------|
| New framework version | Update stack section |
| New architectural pattern | Add code example |
| Repeated AI mistakes | Add anti-pattern |
| Major refactor | Review structure section |

A stale priming doc is worse than none—it teaches AI outdated patterns. But a priming doc that lives in the repo, reviewed like code, stays current by design.

---

## A Real-World Example

Here is a condensed priming document from a project I worked on:

```markdown
# Acme API - Priming Context

## Quick Overview
B2B SaaS API for inventory management. Multi-tenant, event-driven.

## Stack
- Node.js 20, Fastify 4, TypeScript 5
- PostgreSQL 15 + Prisma 5 (multi-tenant via tenantId)
- Auth: Clerk (external), JWT validation middleware
- Queue: BullMQ + Redis for async jobs
- Testing: Vitest

## Trusted Sources
### Docs
- Fastify: https://fastify.dev/docs/latest
- Prisma multi-tenancy: https://www.prisma.io/docs/orm/prisma-client/queries/multi-tenancy

### Blogs We Follow
- BullMQ patterns: [team-vetted blog on queue handling]

### Internal
- ADRs: docs/adr/ (architecture decisions)
- Error handling: docs/error-conventions.md

## Structure
src/
├── modules/           # Feature modules (users/, products/, orders/)
│   └── [module]/
│       ├── service.ts    # Business logic
│       ├── routes.ts     # HTTP handlers
│       ├── schema.ts     # Zod schemas
│       └── types.ts      # TypeScript types
├── shared/            # Cross-cutting (db, auth, queue)
└── config/            # Env config

## Patterns
- Functional services (no classes)
- All queries include `where: { tenantId }` (multi-tenant)
- Validation at route level with Zod
- Errors thrown as `AppError` with status codes

## Anti-patterns
- No classes for services
- No raw SQL (use Prisma)
- No business logic in routes
- No hardcoded tenantId

## Example Service
[Include one short example from the codebase]
```

Notice: It is under 50 lines. That is the target. Focused, specific, actionable.

---

## Trade-offs and Limitations

This approach is not without costs:

- **Upfront effort**: Creating and maintaining priming documents requires time
- **Diminishing returns**: For very simple tasks, the overhead may not be justified
- **Stale context risk**: Outdated priming docs can be worse than none
- **Not a guarantee**: Even with good priming, AI will sometimes produce wrong output

I hypothesize that the payoff is greatest for non-trivial work—especially work that spans multiple sessions or involves team coordination. For a quick utility function, manual correction may be faster than maintaining context infrastructure.

---

## Conclusion

Knowledge Priming is, in essence, manual RAG: filling the AI's context window with high-value, project-specific information before asking for code generation. The hypothesis is straightforward—explicit context should override generic defaults, resulting in output that fits the codebase rather than "the average of the internet."

My current thinking is that the key shift is treating context as infrastructure (versioned files in the repo) rather than habit (copy-pasting at session start). Infrastructure persists; habits fade.

This is the foundation for everything else. Design-first conversations are more productive when AI already understands the architecture. Custom commands work better when AI knows the conventions. The investment in priming compounds.

---
