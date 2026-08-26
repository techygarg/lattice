---
name: context-anchoring
description: "Manage per-feature living documents that capture decisions, constraints, and reasoning across AI sessions during active development. Scoped to feature-level work — design, implementation, bugfix, refactor — not for codebase-wide assessments or product-wide specifications (those define their own document lifecycles). Handles creating new context documents, loading existing ones, and enriching them with new decisions. Use when starting a new feature, resuming work, making technical decisions, resolving questions, or when context needs to persist across sessions. Use this skill whenever the user mentions 'load context', 'update context', 'context doc', 'decisions', 'continue where we left off', 'what did we decide', or 'capture this decision'."
---
# Context Anchoring

## Scope

> Feature-level only — anchors decisions as a feature flows from design → implementation → bugfix → refactor.

## Config Resolution

This skill manages a directory of per-feature context docs. Resolution order:

1. Read `.lattice/config.yaml` in the repo root.
2. If found and `paths.context_base` is set → use that directory as the context base (the Create behavior creates it on demand).
3. If there is no config file or no `paths.context_base` key → use the default `.lattice/context/`.

Each feature gets one doc at `<context_base>/<feature-name>.md`. No default principles, no overlay modes, no override files -- just a thin template and per-feature docs that grow through enrichment.

## Why Context Anchors Exist

AI has no persistent memory across sessions. Early decisions get contradicted, naming drifts, and the "why" evaporates -- a forgotten decision becomes a potential contradiction, a lost constraint becomes a violation, an unresolved question becomes a silent assumption.

Context anchor docs prevent this by being:

- **Feature-bound** -- one doc per feature, scoped decisions only
- **Decision-focused** -- capture what, why, and what-else-was-considered for every choice
- **Append-only** -- decisions are never removed or rewritten, only added chronologically
- **Session-spanning** -- the doc outlives the conversation and carries context forward
- **Git-native** -- lives in the repo, versioned alongside code

Two documents per feature: the **requirement doc** (static, written upfront, not managed by this skill) defines *what* to build; the **context anchor doc** (living, evolving, managed by this skill) captures *how* and *why* -- decisions, constraints, reasoning that emerge during development.

The requirement doc may live in this repo or in whatever system the team already tracks requirements in (Jira, Linear, a wiki) -- this atom never writes to it regardless of where it lives.

## Document Lifecycle

Three behaviors govern the context anchor doc's lifecycle. Each is triggered reactively (user asks) or proactively (AI suggests). In both cases, the AI **always confirms before acting** -- propose, user disposes.

| Behavior | Purpose | Reactive Trigger | Proactive Trigger |
|----------|---------|-----------------|-------------------|
| **Create** | Start a new context doc | User asks to create one | AI detects feature work beginning without a doc |
| **Load** | Restore context from an existing doc | User asks to load/resume | AI detects existing docs and suggests loading |
| **Enrich** | Add a new decision, constraint, or resolution | User asks to capture something | AI detects a decision made in conversation |

## Status Lifecycle

Every context doc carries a `status` frontmatter field. Never infer status from body prose.

| Value | Set by |
|---|---|
| `draft` | `context-anchoring` Create — design not yet complete |
| `approved` | `design-blueprint` Step 3 — L1–L4 complete, design reviewed |
| `complete` | `code-forge` Step 5 — implementation done |

**STOP: Check this field before acting on a context doc.** `draft` ≠ approved. `approved` ≠ complete. Deviation from an approved design → update the doc and re-approve — no new status values exist.

## Create Behavior

Always confirm before creating.

**Steps**:

1. **Identify the feature name.** Derive the kebab-case filename from it (e.g., "User Authentication" → `user-authentication.md`). Confirm the name with the user.
2. **Ask about the requirement doc.** If the user has one, capture it for the `requirement_doc` frontmatter field -- a local file path, or an external reference (URL, ticket ID, or other identifier resolvable via a connected MCP tool). If neither, leave `null`.
3. **Create `<context_base>/`** if it does not already exist.
4. **Generate from template.** Read `./assets/feature-doc-template.md` and fill in:
   - Frontmatter: `feature`, `requirement_doc`, `created` (today's date), `status: draft`
   - H1 heading: feature name
   - Summary: one-line description (ask the user or derive from context)
   - If the template file is not found, generate the doc using this minimal structure:
     ```
     ---
     feature: <feature-name>
     requirement_doc: <local path, external reference, or null>
     created: <today's date>
     status: draft
     ---
     # <Feature Name>
     <one-line summary>
     ## Decisions Log
     | Date | Decision | Reasoning | Alternatives Considered |
     |------|----------|-----------|------------------------|
     ## Open Questions
     None.
     ## Constraints
     None.
     ## Key Files
     ```
5. **Confirm creation.** Show the user the proposed path and a content summary.

## Load Behavior

Always confirm before loading.

**Steps**:

1. **Read the context doc.** Parse the frontmatter and all sections.
2. **Resolve the linked requirement doc** if `requirement_doc` is not null. Local path → read directly. External reference (URL, ticket ID, or other identifier) and a connected MCP tool can resolve it → attempt the fetch. Neither applies → ask the user to paste the current requirement constraints directly -- expected, not an error. Use whatever is resolved to understand feature goals and scope, but do not modify it.
3. **Present the structured acknowledgment** (see Output Formats below):
   - Feature name and summary
   - **Status** (from the frontmatter `status` field — surface explicitly)
   - Requirement doc status (linked or not linked)
   - Decision count and latest decision
   - Open questions (if any)
   - Constraints (if any)
4. **Honor all logged decisions.** Every decision in the log is an active commitment. Never contradict a logged decision without explicit discussion and a new decision entry explaining the change.
5. **Respect constraints as non-negotiable.** Constraints are harder than decisions -- they represent boundaries that cannot be crossed without a deliberate, documented override.
6. **Flag open questions when work touches them.** If the current task involves an area with an unresolved question, surface it immediately. Never silently assume an answer.

## Enrich Behavior

Always confirm before writing.

**What to capture in the Decisions Log**:

- **Date** -- when the decision was made
- **Decision** -- what was decided, stated clearly and concisely
- **Reasoning** -- why this choice was made, key factors
- **Alternatives Considered** -- what else was evaluated and why it was rejected

**Rules**:

1. **Append-only.** New entries go at the bottom of the Decisions Log table. Never modify or remove existing entries.
2. **Chronological order.** Entries reflect the order decisions were made, not grouped by topic.
3. **Concise but complete.** Each entry must be understandable on its own without re-reading the full conversation.
4. **Feature-bound only.** Capture only decisions relevant to this specific feature. Cross-cutting concerns, project-wide conventions, and general preferences belong elsewhere.
5. **Resolve open questions explicitly.** When an open question gets answered, add the answer as a decision in the log *and* remove the question from the Open Questions list.
6. **Constraints are non-negotiable.** Once recorded, a constraint binds. Changing a constraint requires a new decision entry explaining why it is being revised.
7. **Constraint Override Protocol.** If the user explicitly says to override a constraint (e.g., "forget that constraint, we've changed direction"), never silently delete it. Instead: (a) ask the user to confirm the override explicitly, (b) strike through the constraint in the Constraints section (prefix with `~~`), and (c) add a decision entry in the Decisions Log recording the override and reasoning. Constraint history preserved; binding status revoked.
8. **Key Files dedup.** When adding to the Key Files table, check whether the path already exists in the table. If it does — skip.
9. **Cross-cutting check.** After enriching, apply the learning-harvest cross-cutting test: (1) does it name a pattern or approach, not a feature-specific fact? (2) could a developer on a different feature apply it without knowing this feature's context? If both pass — silently add it to the learning-harvest queue. Do not prompt the user here.

## Document Discovery

When the user asks to load or resume but does not specify which feature:

1. **Scan the context base directory** for `.md` files.
2. **Match by frontmatter** `feature` field or by filename.
3. **Multiple docs exist** → present a numbered list with feature name, creation date, and decision count. Let the user choose.
4. **Only one doc exists** → suggest loading it. Confirm before proceeding.
5. **No docs exist** → inform the user and suggest creating one.
6. **Fuzzy match**: the user's term partially matches multiple docs (e.g., "auth" matching `user-authentication.md` and `oauth-authentication.md`) → show all partial matches with full filenames and let the user choose. Never guess.

When the user mentions a feature name in conversation, check whether a matching context doc exists. If it does and has not been loaded this session, suggest loading it.

## Output Formats

**Load**: show feature name, **status** (from frontmatter), requirement doc status, decision count, open questions, constraints, latest decision. Close with: "All logged decisions are active. Constraints are non-negotiable. I will flag open questions when work touches them."

**Enrich**: show exactly what will be added (decision, reasoning, alternatives considered). Wait for confirmation before writing.

**Create**: show proposed path, feature name, requirement doc link. Wait for confirmation before creating.

## Integration with Other Skills

This atom is composed by the molecules that orchestrate feature workflows:

- **`design-blueprint`** — invokes **Create** or **Load** in Step 1 (Establish Context), then invokes **Enrich** at each design-level checkpoint to capture decisions as they emerge
- **`code-forge`** — invokes **Load** in Step 1 (Establish Implementation Context), then invokes **Enrich** throughout Steps 3–5 to capture implementation decisions, key files, and resolved questions
- **`refactor-safely`** — invokes **Document Discovery** and **Load** in Step 1, persists the approved refactor plan via **Enrich** in Step 3, and captures final decisions in Step 8
- **`bug-fix`** — invokes **Document Discovery** and **Load** in Step 1, captures diagnosis and repair decisions via **Enrich** in Step 7

When a context doc is active (loaded in the current session), **Enrich** runs continuously -- the AI monitors the conversation for decisions worth capturing and suggests enrichment as they arise. This is not limited to the molecule that loaded the doc; any skill producing decisions can trigger an enrichment suggestion.
