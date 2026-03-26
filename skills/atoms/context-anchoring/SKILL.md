---
name: context-anchoring
description: "Manage per-feature living documents that capture decisions, constraints, and reasoning across AI sessions. Handles creating new context documents, loading existing ones, and enriching them with new decisions. Use when starting a new feature, resuming work, making technical decisions, resolving questions, or when context needs to persist across sessions. Use this skill whenever the user mentions 'load context', 'update context', 'context doc', 'decisions', 'continue where we left off', 'what did we decide', or 'capture this decision'."
---

# Context Anchoring

## Config Resolution

This skill manages a directory of per-feature context documents. Resolution order:

1. Look for `.ai/config.yaml` in the repository root
2. If found, check `paths.context_base` for a custom directory path
3. If the custom path exists, use that directory for context documents
4. If no config, no path, or path not found, use default `.ai/context/`

Each feature gets one document at `<context_base>/<feature-name>.md`. There are no default principles, no overlay modes, no override files -- just a thin template and per-feature documents that grow through enrichment.

## The Problem

AI has no persistent memory. Context decay is real: by message 30+, early decisions get contradicted, naming becomes inconsistent, the "why" behind a choice evaporates. The damage compounds -- each forgotten decision becomes a potential contradiction, each lost constraint becomes a potential violation, each unresolved question becomes a silent assumption.

Context anchor documents solve this. They are:

- **Feature-bound** -- one document per feature, scoped to that feature's decisions only
- **Decision-focused** -- captures the what, why, and what-else-was-considered for every choice
- **Append-only** -- decisions are never removed or rewritten, only added chronologically
- **Session-spanning** -- the document outlives any single conversation, carrying context forward
- **Git-native** -- lives in the repository, versioned alongside the code it documents

Two documents serve each feature: a **requirement doc** (static, written upfront, not managed by this skill) and a **context anchor doc** (living, evolving, managed by this skill). The requirement doc defines *what* to build. The context anchor doc captures *how* and *why* -- the decisions, constraints, and reasoning that emerge during development.

## Document Lifecycle

Three behaviors govern the context anchor document lifecycle. Each can be triggered reactively (user asks) or proactively (AI suggests). In both cases, the AI **always confirms before acting** -- proposes, user disposes.

| Behavior | Purpose | Reactive Trigger | Proactive Trigger |
|----------|---------|-----------------|-------------------|
| **Create** | Start a new context document | User asks to create one | AI detects feature work beginning without a doc |
| **Load** | Restore context from an existing document | User asks to load/resume | AI detects existing docs and suggests loading |
| **Enrich** | Add a new decision, constraint, or resolution | User asks to capture something | AI detects a decision was made in conversation |

## Create Behavior

**When**: Starting new feature work and no existing context document exists for this feature.

**Reactive**: The user explicitly asks to create a context document or start a new feature.

**Proactive**: When feature work begins -- new requirement discussed, design started, implementation kicked off -- and no context document exists for this feature, suggest creating one. Always confirm before creating.

**Steps**:

1. **Identify the feature name.** Derive a kebab-case filename from the feature name (e.g., "User Authentication" → `user-authentication.md`). Confirm the name with the user.
2. **Ask about a requirement doc.** If the user has a requirement document, capture its path for the `requirement_doc` frontmatter field. If not, leave it `null`.
3. **Create the directory** if `<context_base>/` does not already exist.
4. **Generate from template.** Read `./assets/feature-doc-template.md` and fill in:
   - Frontmatter: `feature`, `requirement_doc`, `created` (today's date)
   - H1 heading: the feature name
   - Summary: a one-line description (ask the user or derive from context)
   - If the template file is not found, generate the document using this minimal structure:
     ```
     ---
     feature: <feature-name>
     requirement_doc: <path or null>
     created: <today's date>
     ---
     # <Feature Name>
     <one-line summary>
     ## Decisions Log
     | Date | Decision | Reasoning | Alternatives Considered |
     |------|----------|-----------|------------------------|
     ## Open Questions
     ## Constraints
     ## Key Files
     ```
5. **Confirm creation.** Show the user the proposed path and content summary. Create only after confirmation.

## Load Behavior

**When**: Starting a new session on an existing feature, resuming work, or continuing where a previous conversation left off.

**Reactive**: The user asks to load context, resume a feature, or continue previous work.

**Proactive**: When the conversation suggests work on a feature that has an existing context document -- e.g., the user mentions a feature name that matches a document, or references previous decisions -- suggest loading it. Always confirm before loading.

**Steps**:

1. **Read the context document.** Parse frontmatter and all sections.
2. **Read the linked requirement doc** if `requirement_doc` is not null. Use it to understand the feature's goals and scope, but do not modify it.
3. **Present a structured acknowledgment** (see Output Formats below):
   - Feature name and summary
   - Requirement doc status (linked or not linked)
   - Decision count and latest decision
   - Open questions (if any)
   - Constraints (if any)
4. **Honor all logged decisions.** Every decision in the log is treated as an active commitment. Never contradict a logged decision without explicit discussion and a new decision entry explaining the change.
5. **Respect constraints as non-negotiable.** Constraints are harder than decisions -- they represent boundaries that cannot be crossed without a deliberate, documented override.
6. **Flag open questions when work touches them.** If the current task involves an area with an unresolved question, surface it immediately. Do not silently assume an answer.

## Enrich Behavior

**When**: A decision is made during conversation, a constraint is identified, an open question is resolved, or a key file is added.

**Reactive**: The user explicitly asks to capture a decision, log a constraint, or update the context document.

**Proactive**: When a decision emerges from conversation -- an approach is chosen, an alternative is rejected, a constraint is agreed upon, a question is resolved -- suggest enriching the context document. Always confirm before writing.

**What to capture in the Decisions Log**:

- **Date** -- when the decision was made
- **Decision** -- what was decided, stated clearly and concisely
- **Reasoning** -- why this choice was made, the key factors
- **Alternatives Considered** -- what else was evaluated and why it was rejected

**Rules**:

1. **Append-only.** New entries go at the bottom of the Decisions Log table. Never modify or remove existing entries.
2. **Chronological order.** Entries reflect the order decisions were made, not grouped by topic.
3. **Concise but complete.** Each entry should be understandable on its own without re-reading the full conversation.
4. **Feature-bound only.** Only capture decisions relevant to this specific feature. Cross-cutting concerns, project-wide conventions, and general preferences belong elsewhere.
5. **Resolve open questions explicitly.** When an open question is answered, add the answer as a decision in the log *and* remove the question from the Open Questions list.
6. **Constraints are non-negotiable.** Once a constraint is recorded, it is binding. Changing a constraint requires a new decision entry explaining why the constraint is being revised.
7. **Constraint Override Protocol.** If the user explicitly says to override a constraint (e.g., "forget that constraint, we've changed direction"), do not silently delete it. Instead: (a) ask the user to confirm the override explicitly, (b) strike through the constraint in the Constraints section (prefix with `~~`), and (c) add a decision entry in the Decisions Log recording the override and its reasoning. The constraint history is preserved; its binding status is revoked.

## Document Discovery

When the user asks to load or resume but does not specify which feature:

1. **Scan the context base directory** for `.md` files.
2. **Match by frontmatter** `feature` field or by filename.
3. **If multiple documents exist**, present a numbered list with feature name, creation date, and decision count. Let the user choose.
4. **If only one document exists**, suggest loading it. Confirm before proceeding.
5. **If no documents exist**, inform the user and suggest creating one.
6. **Fuzzy match**: If the user's term partially matches multiple documents (e.g., "auth" matching `user-authentication.md` and `oauth-authentication.md`), show all partial matches with full filenames and let the user choose. Never guess.

When the user mentions a feature name in conversation, check if a matching context document exists. If it does and has not been loaded in this session, suggest loading it.

## Output Formats

**Load**: Show feature name, requirement doc status, decision count, open questions, constraints, and latest decision. Close with: "All logged decisions are active. Constraints are non-negotiable. I will flag open questions when work touches them."

**Enrich**: Show exactly what will be added (decision, reasoning, alternatives considered). Wait for confirmation before writing.

**Create**: Show proposed path, feature name, and requirement doc link. Wait for confirmation before creating.

## Integration with Other Skills

This atom is composed by molecules that orchestrate feature workflows:

- **`design-blueprint`** -- invokes **Create** or **Load** in Step 1 (Establish Context), then invokes **Enrich** at each design level checkpoint to capture decisions as they emerge
- **`code-forge`** -- invokes **Load** in Step 1 (Establish Implementation Context) to load the blueprint, then invokes **Enrich** throughout Steps 3-5 to capture implementation decisions, key files, and resolved questions

When a context document is active (loaded in the current session), **Enrich** runs continuously -- the AI monitors the conversation for decisions worth capturing and suggests enrichment as they arise. This is not limited to the molecule that loaded the document; any skill producing decisions can trigger an enrichment suggestion.
