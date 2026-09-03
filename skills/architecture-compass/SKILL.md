---
name: architecture-compass
description: "Architectural thinking partner for an existing repository — scans the codebase, conducts a structured interview, agrees on current architectural state and recommended direction, and produces a shareable insights document. Scoped to one repository, module, or folder. Does not execute transformation — it orients. Use when the user says 'assess my codebase architecture', 'what direction should my codebase go', 'architecture compass', 'understand my architecture', 'audit architecture drift', 'architectural assessment', or 'help me understand what is wrong with my codebase'."
---

# Architecture Compass

## Required Skills

Read, apply:

1. `framework:knowledge-priming` -- Load codebase context: language, framework, structure, conventions (always)
2. `framework:architecture` -- Architectural audit lens and recommended direction guardrails (always)
3. `framework:domain-driven-design` -- Strategic DDD only: bounded contexts, domain seams (conditional: only when domain complexity warrants it)
4. `framework:collaborative-judgment` -- Surface judgment calls during co-design rounds (always)

## Workflow

### Step 1: Load Existing Context

**Check for an existing insights document first.** If `.lattice/insights/architecture.md` already exists:
- Read it. Check the Session Status table using these three states:
  - `pending` — row exists, no content written yet
  - `in-progress` — content exists in the section but no agreed date recorded
  - `✅ agreed` — content exists and date is recorded
- Resume from the earliest `pending` or `in-progress` phase. For `in-progress` phases: present the existing content for re-confirmation rather than regenerating it.
- **In-progress without content:** If Current Architecture is `in-progress` but the document has no Current Architecture content (the previous session's scan context was lost), re-run Step 2 scan before presenting.
- **Staleness check:** If the most recent `✅ agreed` date in the Session Status table is older than 30 days, run a lightweight re-scan (Steps 2.1 and 2.6 only — tree + imports). If material structural changes are detected, present them and ask whether Current Architecture needs revision before proceeding.
- Do not re-scan if Current Architecture is already `✅ agreed` and the staleness check passes.
- Tell the user what was found and which phase the session resumes from.

If no existing document: proceed from Step 2.

Check for `.lattice/config.yaml`. Load `knowledge-base.md` and `architecture.md` from `.lattice/standards/` if they exist — these shape both the audit lens and the recommended direction proposal.

If no `.lattice/` config exists, offer to run `lattice-init` first. If declined, infer defaults from the scan.

---

### Step 2: Silent Scan — Architectural Signal Extraction

Do not ask any questions yet. Scan first, form a hypothesis, then ask only what code cannot reveal.

**Confirm scope before scanning.** If the working directory is a monorepo or contains multiple independent services/modules, ask: *"Which service or module should this assessment focus on?"* Do not scan the full monorepo root — assess one bounded scope at a time. If the user requests the full monorepo: explain that a single insights document cannot meaningfully capture many independent architectures. Offer: (1) assess the shared infrastructure/platform layer as one scope, (2) produce a lightweight index of all services with one-line architecture classification, then deep-assess the 2–3 most painful ones. If the user still insists, proceed with a service-by-service scan at reduced depth (Steps 2.1 + 2.6 per service).

This is signal extraction, not a full read. **Target: 15–25 file reads** (view/open operations). Grep, glob, and directory listings do not count against this budget — they are structural reconnaissance, not deep reads. Stop reading a module once its responsibility, dependencies, and layer fit are clear.

**Scanning protocol — execute in order:**

1. **Directory tree** (3 levels deep) — intended organization, layer structure, naming conventions. Do this before opening any file.

2. **Dependency manifests** — `package.json`, `pom.xml`, `go.mod`, `requirements.txt`. Language, framework, key external dependencies.

3. **Architecture documents** — `README.md`, `ARCHITECTURE.md`, `docs/`, ADR directories. The intended architecture often lives here — the gap between intention and reality is itself a finding.

4. **Archaeology** — before analysing flows, reduce scope:
   - Dead code (no callers) — candidates for deletion, but verify no side effects first: static initializers, scheduled tasks, event listeners, and framework hooks are invisible to call-graph analysis
   - Duplicate functionality — two implementations of the same concept, must reconcile before any change
   - Implicit coupling — shared mutable state, globals, ambient context, thread-locals
   - Hidden integration points — outbound calls to external systems in unexpected places

5. **Seam identification and viability** — natural boundaries where one side can change without the other knowing:
   - Domain seams (distinct business concepts), technical seams (I/O vs. business logic), team seams, temporal seams
   - For each seam: assess viability — how many callers cross it? Cheap seams become first moves.

6. **Import and dependency patterns** — grep import statements across all source files. Do not open full bodies. Reveals dependency direction, load-bearing modules, layer violations cheaply.

7. **Entry points** — 3–5 files: routes, controllers, CLI handlers, event consumers. Reveals outermost layer.

8. **Interface and contract files** — interfaces, abstract classes, ports. Reveals intended boundaries, whether followed or not.

9. **One representative file per top-level module** — confirm responsibility, catch what import grep missed.

10. **Stop. Form the hypothesis:**
    - What the architecture actually is vs. what it was intended to be
    - **Drift or mismatch?** Drift = sound intention, gradual decay → restore. Mismatch = wrong pattern for domain → replace. This shapes the recommended direction.
    - Which seams are viable (low exploitation cost)
    - Most significant violations, with specific named evidence
    - Dead code and duplicates that can be cleaned up before any structural work

    If a module remains unclear after Step 9, read one additional file from it. This is the only scan extension permitted.

    **If the scan produces no meaningful architectural signal** — fewer than 3 distinct modules, no dependency violations, no seams, or the codebase is clearly early-stage (new repo, mostly generated code, flat structure) — surface this before the interview: *"This codebase has no architectural complexity to assess — fewer than 3 modules, no dependency violations, and no identifiable seams. This is either early-stage or intentionally simple. `/design-blueprint` may be more appropriate if you're establishing architecture from scratch. Continue the assessment anyway?"* If the user confirms, proceed. If not, end the session.

**Skip entirely:** full method implementations, test files, generated code, vendor directories, migration files, static assets.

---

### Step 3: Four-Act Interview

Read `references/interview-guide.md`. Apply the four-act arc, question bank per act, answer interpretation table, conversation principles, and red flags from that document.

**If the user explicitly declines the interview** ("just analyze the code", "don't ask me questions"): *"The recommended direction will be based solely on code signals without team context. It may miss delivery constraints, team topology, or unstated goals. Proceed?"* If confirmed, skip to Step 4. Flag the Team Vision section in the insights document as "inferred, not confirmed."

**STOP:** Act 3 answers are architectural inputs, not soft context. The recommended direction in Step 5 must visibly respond to what the team said in Act 3. Consult the answer interpretation table in `references/interview-guide.md` before forming the recommendation.

---

### Step 4: Current Architecture Agreement (Round 1)

Present the architectural snapshot from the scan. Goal: shared, accurate map — not a critique.

Present:
- Drift or mismatch determination with rationale
- Current layer structure (or absence) with specific file/directory evidence
- Module inventory: what each module actually owns and what it shouldn't
- Dependency flow — Mermaid diagram using **actual module and layer names from this codebase**. The structure below is a template only — replace every node label with real names found in the scan. Never present generic labels like "Services" or "DB" in the real output.

```mermaid
graph TD
  [ActualEntryLayer] --> [ActualServiceLayer]
  [ActualServiceLayer] --> [ActualDataLayer]
  [ActualServiceLayer] --> [ActualDomainLayer]
  [ActualDomainLayer] --> [ActualDataLayer]
  style [ActualDataLayer] fill:#f96
```

- Seams identified and their viability
- Archaeology findings — dead code, duplicates, quick wins
- Key violations — specific and named, not generic

If the scan findings and the interview answers contradict each other — e.g., scan shows no layers but team described having clean architecture — present both explicitly before asking for confirmation: *"The scan shows [X]. You described [Y]. Is there a gap between intent and current implementation, or did I misread something?"* Resolve the contradiction before advancing.

Ask specifically: *"Does this map accurately reflect how the codebase is structured today? What's missing, wrong, or intentional that I've marked as a violation?"*

If the map has not converged after 3 correction rounds, use `framework:collaborative-judgment` to surface the specific unresolved points and ask the user to make a decision rather than continuing to iterate.

**STOP:** Do not advance to Step 5 until the user explicitly confirms the current architecture map.

Use `framework:collaborative-judgment` for genuine ambiguities in the current-state read.

---

### Step 5: Recommended Direction (Round 2)

Propose a recommended architectural direction tailored to *this* codebase — not a generic template.

**Carry drift/mismatch forward:**
- **Drift** → restore original intent. The target should feel like "what this was always trying to be."
- **Mismatch** → design fresh from the domain up. Do not restore — replace.

**Minimum viable direction:** Propose the simplest structure that resolves the stated pain. Test: can the team take the first move this week? A direction that only pays off after six months of work is the wrong direction.

**Vision-guardrail tension:** If the team's vision (Act 3) is structurally incompatible with a guardrail (Act 4), surface the tension explicitly before proposing: *"Your goal of [X] requires changes to [Y], which you've marked as off-limits. The recommended direction will work around this constraint — here's how and what it costs in terms of the vision."* Do not silently compromise — name the tradeoff.

**Apply `framework:architecture` guardrails.** The non-negotiable rule: domain has zero dependency on infrastructure — infrastructure depends on domain.

**Apply `framework:domain-driven-design`** (strategic only) when: multiple distinct business capabilities exist, different parts change at different rates, or different teams own different areas. When none apply, skip DDD.

The proposal covers:
- Architecture style and rationale — specific to this codebase, not a textbook example
- Layer definitions — what each layer owns, what it must never own
- Dependency direction rules — explicit, with the domain/infrastructure inversion as a hard rule
- Module and folder structure — names that match the language and framework conventions of this codebase
- Bounded context boundaries (when DDD applies)

Present:
- Recommended direction Mermaid diagram — use **actual proposed layer names for this codebase**, not generic labels. The structure below is a template only — replace every node with names that reflect this codebase's language, framework, and domain.

```mermaid
graph TD
  [ActualAPILayer] --> [ActualApplicationLayer]
  [ActualApplicationLayer] --> [ActualDomainLayer]
  [ActualInfraLayer] --> [ActualDomainLayer]
  [ActualAPILayer] --> [ActualInfraLayer]
  style [ActualDomainLayer] fill:#6f9
```

- Annotated target folder tree — layers as directories, representative files per layer with one-line role annotations. Apply `framework:knowledge-priming` and `.lattice/standards/language-idioms.md` (if it exists) to ensure layer names and file naming conventions match this codebase's language and framework — not a generic OOP template. Not exhaustive — enough to make the structure unambiguous.
- Bounded context map (when DDD applies)

Ask: *"Does this direction address the pain you described? Are there constraints or preferences that should change this proposal?"*

**STOP:** Do not advance to Step 6 until the user explicitly confirms the recommended direction.

If the direction has not converged after 3 revision rounds, use `framework:collaborative-judgment` to surface the specific unresolved tensions (e.g., vision vs. constraints, simplicity vs. completeness) and ask the user to make a decision rather than continuing to iterate.

This step is a valid stopping point. If the team only needs current + recommended direction agreed, the session can end here. In that case, **run Step 7 immediately** to persist what was agreed. Sections not yet reached must appear in the Session Status table as `pending` — do not omit them. Gap assessment and first moves can be completed in a follow-up session.

---

### Step 6: Gap Assessment and First Moves

**Gap assessment — structural items only:**
- Must change — structural moves required to reach the recommended direction
- Should change — violations worth addressing while doing the work
- Explicitly defer — named items out of scope for now (not forgotten)
- Leave alone — modules or layers where dependency direction already matches the recommended direction and no violations were found in the scan. Name them explicitly so they are protected from unnecessary change.

Do not include tactical items (naming, test coverage, code style) — execution concerns handled by `code-forge` and `refactor-safely`.

**First moves** — not a full backlog. The 2–3 most important structural decisions to make next.

Right granularity: one layer introduced, one seam isolated, one dependency inverted. Not "improve the domain layer" (too broad). Not "rename this method" (too narrow).

For each first move:
- What structural change to make
- Why this first — what it unblocks
- Which molecule to use:
  - Structural move (existing code changes location or responsibility) → `/refactor-safely`
  - New structure (a layer, interface, or module that does not yet exist) → `/design-blueprint` → `/code-forge`
- **Affected modules:** specific files/directories from the Current Architecture scan
- **Depends on:** `[Move N]` or `none` — makes sequencing explicit
- **Done when:** structural success criterion — e.g., "domain/ has zero imports from infrastructure/", "all DB calls go through a repository interface", "routes/ contains no business logic"

Ask: *"Do these first moves match your team's capacity and what you want to tackle first?"*

**STOP:** Do not advance to Step 7 until the user confirms the gap assessment and first moves.

---

### Step 7: Write the Insights Document

Produce `.lattice/insights/architecture.md`. Create `.lattice/insights/` directory if it does not exist.

**Required structure:**

```markdown
# Architecture Compass — [Repository Name]

## Session Status
| Phase | Status | Agreed |
|---|---|---|
| Scan + Interview | complete | — |
| Current Architecture | ✅ agreed | [date] |
| Recommended Direction | ✅ agreed | [date] |
| Gap Assessment | ✅ agreed | [date] |
| First Moves | ✅ agreed | [date] |

## Repository Identity
Language, framework, size, scope boundary, delivery constraints, team context.

## Why We're Doing This
The burning platform — from the interview. What's breaking today.
Previous attempts and what stopped them.

## Team Vision & Guardrails
What the team wants to achieve (Act 3 answers — verbatim + architectural interpretation).
Constraints and off-limits areas (Act 4 answers).
These are architectural inputs that directly shape the Recommended Direction.

## Archaeology Findings
Dead code candidates. Duplicates to reconcile.
Implicit coupling. Hidden integration points. Quick wins.

## Domain Map
Core domain. Natural seams. Bounded contexts (if applicable).

## Current Architecture
Drift or mismatch — with rationale.
Layer structure. Module inventory.
[Mermaid diagram — layers and violations]
Key violations — specific and named.

## Recommended Direction
Architecture style and rationale.
Layer definitions and dependency rules.
[Mermaid diagram — clean target]
[Annotated target folder tree]
[Bounded context map — if applicable]

## Gap Assessment
Must change / Should change / Explicitly defer / Leave alone.

## First Moves
[Move 1] — what, why first, which molecule, affected modules, depends on, done when
[Move 2] — what, why first, which molecule, affected modules, depends on, done when
[Move 3] — what, why first, which molecule, affected modules, depends on, done when (if applicable)

## Progress Log
[Append on every subsequent session: YYYY-MM-DD — phase revisited, what changed, new findings]
```

Use today's date in YYYY-MM-DD format wherever `[date]` appears in the Session Status table.

On subsequent sessions that resume this document, append an entry to the Progress Log before closing: date, which phase was revisited, what changed, any new findings that emerged.
