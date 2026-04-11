---
name: context-anchoring
description: "Manage per-feature living documents that capture decisions, constraints, and reasoning across AI sessions. Handles creating new context documents, loading existing ones, and enriching them with new decisions. Use when starting a new feature, resuming work, making technical decisions, resolving questions, or when context needs to persist across sessions. Use this skill whenever the user mentions 'load context', 'update context', 'context doc', 'decisions', 'continue where we left off', 'what did we decide', or 'capture this decision'."
---
# Context Anchoring

## Config Resolution

Skill manage dir of per-feature context docs. Resolution order:

1. Look `.lattice/config.yaml` in repo root
2. If found, check `paths.context_base` for custom dir path
3. If custom path exist, use that dir for context docs
4. If no config/path/path not found, use default `.lattice/context/`

Each feature get one doc at `<context_base>/<feature-name>.md`. No default principles, no overlay modes, no override files -- just thin template and per-feature docs that grow through enrichment.

## Problem

AI no persistent memory. Context decay real: by message 30+, early decisions contradicted, naming inconsistent, "why" evaporate. Damage compound -- forgotten decision become potential contradiction, lost constraint become violation, unresolved question become silent assumption.

Context anchor docs solve:

- **Feature-bound** -- one doc per feature, scoped decisions only
- **Decision-focused** -- capture what, why, what-else-considered for every choice
- **Append-only** -- decisions never removed/rewritten, only added chronologically
- **Session-spanning** -- doc outlive conversation, carry context forward
- **Git-native** -- live in repo, versioned alongside code

Two docs per feature: **requirement doc** (static, written upfront, not managed by this skill) and **context anchor doc** (living, evolving, managed by this skill). Requirement doc define *what* build. Context anchor doc capture *how* and *why* -- decisions, constraints, reasoning that emerge during development.

## Document Lifecycle

Three behaviors govern context anchor doc lifecycle. Each triggered reactively (user ask) or proactively (AI suggest). Both cases, AI **always confirm before acting** -- propose, user dispose.

| Behavior | Purpose | Reactive Trigger | Proactive Trigger |
|----------|---------|-----------------|-------------------|
| **Create** | Start new context doc | User ask create one | AI detect feature work beginning without doc |
| **Load** | Restore context from existing doc | User ask load/resume | AI detect existing docs and suggest loading |
| **Enrich** | Add new decision, constraint, resolution | User ask capture something | AI detect decision made in conversation |

## Create Behavior

Always confirm before creating.

**Steps**:

1. **Identify feature name.** Derive kebab-case filename from feature name (e.g., "User Authentication" → `user-authentication.md`). Confirm name with user.
2. **Ask about requirement doc.** If user have requirement document, capture path for `requirement_doc` frontmatter field. If not, leave `null`.
3. **Create dir** if `<context_base>/` not already exist.
4. **Generate from template.** Read `./assets/feature-doc-template.md` and fill in:
   - Frontmatter: `feature`, `requirement_doc`, `created` (today date)
   - H1 heading: feature name
   - Summary: one-line description (ask user or derive from context)
   - If template file not found, generate doc using this minimal structure:
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
5. **Confirm creation.** Show user proposed path and content summary. Create only after confirmation.

## Load Behavior

Always confirm before loading.

**Steps**:

1. **Read context doc.** Parse frontmatter and all sections.
2. **Read linked requirement doc** if `requirement_doc` not null. Use to understand feature goals and scope, but not modify.
3. **Present structured acknowledgment** (see Output Formats below):
   - Feature name and summary
   - Requirement doc status (linked or not linked)
   - Decision count and latest decision
   - Open questions (if any)
   - Constraints (if any)
4. **Honor all logged decisions.** Every decision in log treated as active commitment. Never contradict logged decision without explicit discussion and new decision entry explaining change.
5. **Respect constraints as non-negotiable.** Constraints harder than decisions -- represent boundaries that cannot be crossed without deliberate, documented override.
6. **Flag open questions when work touch them.** If current task involve area with unresolved question, surface immediately. Not silently assume answer.

## Enrich Behavior

Always confirm before writing.

**What capture in Decisions Log**:

- **Date** -- when decision made
- **Decision** -- what decided, stated clearly and concisely
- **Reasoning** -- why this choice made, key factors
- **Alternatives Considered** -- what else evaluated and why rejected

**Rules**:

1. **Append-only.** New entries go bottom of Decisions Log table. Never modify or remove existing entries.
2. **Chronological order.** Entries reflect order decisions made, not grouped by topic.
3. **Concise but complete.** Each entry understandable on own without re-reading full conversation.
4. **Feature-bound only.** Only capture decisions relevant to this specific feature. Cross-cutting concerns, project-wide conventions, general preferences belong elsewhere.
5. **Resolve open questions explicitly.** When open question answered, add answer as decision in log *and* remove question from Open Questions list.
6. **Constraints non-negotiable.** Once constraint recorded, it binding. Changing constraint require new decision entry explaining why constraint being revised.
7. **Constraint Override Protocol.** If user explicitly say override constraint (e.g., "forget that constraint, we've changed direction"), not silently delete. Instead: (a) ask user confirm override explicitly, (b) strike through constraint in Constraints section (prefix with `~~`), and (c) add decision entry in Decisions Log recording override and reasoning. Constraint history preserved; binding status revoked.

## Document Discovery

When user ask load or resume but not specify which feature:

1. **Scan context base dir** for `.md` files.
2. **Match by frontmatter** `feature` field or by filename.
3. **If multiple docs exist**, present numbered list with feature name, creation date, decision count. Let user choose.
4. **If only one doc exist**, suggest loading it. Confirm before proceeding.
5. **If no docs exist**, inform user and suggest creating one.
6. **Fuzzy match**: If user term partially match multiple docs (e.g., "auth" matching `user-authentication.md` and `oauth-authentication.md`), show all partial matches with full filenames and let user choose. Never guess.

When user mention feature name in conversation, check if matching context doc exist. If it do and not been loaded in this session, suggest loading it.

## Output Formats

**Load**: Show feature name, requirement doc status, decision count, open questions, constraints, latest decision. Close with: "All logged decisions are active. Constraints are non-negotiable. I will flag open questions when work touches them."

**Enrich**: Show exactly what will be added (decision, reasoning, alternatives considered). Wait confirmation before writing.

**Create**: Show proposed path, feature name, requirement doc link. Wait confirmation before creating.

## Integration with Other Skills

This atom composed by molecules that orchestrate feature workflows:

- **`design-blueprint`** -- invoke **Create** or **Load** in Step 1 (Establish Context), then invoke **Enrich** at each design level checkpoint to capture decisions as they emerge
- **`code-forge`** -- invoke **Load** in Step 1 (Establish Implementation Context) to load blueprint, then invoke **Enrich** throughout Steps 3-5 to capture implementation decisions, key files, resolved questions

When context doc active (loaded in current session), **Enrich** run continuously -- AI monitor conversation for decisions worth capturing and suggest enrichment as they arise. Not limited to molecule that loaded doc; any skill producing decisions can trigger enrichment suggestion.