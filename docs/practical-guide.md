# Practical Guide

Scenario-driven answers to common questions practitioners have when adopting and using Lattice. Each answer is self-contained and brief.

---

## Contents

- [Getting Started](#getting-started)
- [Requirements](#requirements)
- [Architecture](#architecture)
- [Language](#language)
- [Customization](#customization)
- [Workflow](#workflow)
- [Codebase Transformation](#codebase-transformation)
- [Domain-Driven Design](#domain-driven-design)
- [Team Usage](#team-usage)
- [The Learning Flywheel](#the-learning-flywheel)
- [Troubleshooting](#troubleshooting)

---

## Getting Started

### I just installed Lattice. What do I do first?

Run `/lattice-init`. It scans your project, creates `.lattice/config.yaml`, and tells you which refiners to run based on what it finds. After that, run the suggested refiners (starting with `/knowledge-priming-refiner`, then `/language-idioms-refiner`) to give Lattice context about your project and language. Once done, you're ready to use any molecule.

### My project already has 50k+ lines of code. Is Lattice only for new projects?

No. Lattice works for brownfield codebases too. Run `/lattice-init` to scan the repo and set up `.lattice/` around what you already have. Use `/refactor-safely`, `/bug-fix`, and `/review` for incremental improvement without rewriting everything. Run `/architecture-refiner` to give Lattice explicit ground rules for whatever architecture you actually follow — it writes `.lattice/standards/architecture.md` so the architecture atom enforces your structure, not a generic default.

### What happens if I skip all refiners and just start using molecules?

Molecules work, but results will be generic. Without `/knowledge-priming-refiner`, Lattice has no awareness of your project — it can't tailor generated code to your stack or conventions. Without `/language-idioms-refiner`, atoms use pseudocode defaults which assume OOP + exceptions — problematic for Go, Rust, or functional languages. The other refiners (architecture, clean code, DDD, review) have solid embedded defaults, so skipping those is fine initially. But `/knowledge-priming-refiner` and `/language-idioms-refiner` are strongly recommended.

### What is the `.lattice/` folder and should I commit it to version control?

The `.lattice/` folder is Lattice's living context layer. It holds `config.yaml` (your settings), `standards/` (refiner outputs like architecture and coding rules), `requirements/` (epic and feature specs produced by requirement-forge), `context/` (per-feature living documents capturing decisions and blueprints), `reviews/` (review log), and `learnings/` (review insights). Commit it — it's the shared source of truth for your team's standards and accumulates value over time.

---

## Requirements

### When should I use `/requirement-forge` vs. jumping straight to `/design-blueprint`?

Use `/requirement-forge` when the feature scope, problem statement, or acceptance criteria are not yet clearly defined — it acts as a senior PM + BA pair that challenges assumptions, structures epics and features, and produces specs complete enough for `design-blueprint` to consume without further interviews. Go straight to `/design-blueprint` when the feature is already well-understood and you only need to make technical design decisions. When in doubt, run requirement-forge first — a well-specced feature produces a sharper blueprint.

### What is the structure requirement-forge produces?

Two artifacts in `.lattice/requirements/`: an `index.md` apex file (epic glossary with links to all features, their status, priority, and dependencies) and per-feature files in `features/`. Each feature file contains a problem statement, user/personas, scope (in-scope and out-of-scope), boundary conditions, assumptions, ordered scenarios (each with acceptance criteria), implementation notes, and open questions. If source documents were provided during intake, `index.md` also includes a Source Materials table (tracing which documents produced which features) and a Deferred Items section (content intentionally excluded from the current feature set). The feature file is the direct input to `design-blueprint`.

### What is a scenario in requirement-forge?

A scenario is a bounded situation the feature must handle — not a user story, not an acceptance criterion. A feature is broken into 2–5 scenarios; each scenario has 3–6 Given/When/Then acceptance criteria. Scenarios are ordered chronologically — the natural implementation sequence. This two-level structure prevents both scenario sprawl (too many ACs on a flat feature) and story fragmentation (too many fine-grained stories disconnected from the feature).

### Do I need to run `/requirement-forge-refiner` before using requirement-forge?

No — requirement-forge works with built-in defaults out of the box. When no standards document is found, the molecule tells you the active defaults (Given/When/Then ACs, P0/P1/P2 priority, max 5 scenarios per feature, max 6 ACs per scenario, standard status workflow) so you know what will govern the session. Run `/requirement-forge-refiner` when you want to tailor these to your team — custom AC format, alternative nomenclature (e.g., "use case" instead of "scenario"), different priority notation, or an extended status workflow. It is a one-time setup.

### I have existing PRDs, feature lists, or Confluence pages. How does requirement-forge handle them?

The molecule opens by asking whether you have existing material before assuming a blank slate. Provide file paths, paste text, or describe where documents live. It reads everything silently and runs a structured triage: classifies each document by type (product requirements, technical design, stakeholder wishlist, marketing — only product requirements and wishlists feed the pipeline), identifies overlaps between documents (same capability described differently), surfaces contradictions for your resolution, checks granularity (ACs mistaken for features, or broad epics mistaken for features), identifies gaps (implied behaviors never explicitly stated), and flags orphaned content (material that doesn't map to any feature — collected for the Deferred Items section of `index.md`). It then presents a structured hypothesis with proposed epics and features. You confirm or correct before anything is written.

### My requirement-forge session ended before all features were specced. What happens next time?

The molecule's first action is always to scan `.lattice/requirements/` for existing work. It classifies each feature file as complete, structurally incomplete (missing sections), or quality-suspect (present but with a spec quality issue flagged by the `requirement-quality` atom). It surfaces each issue one by one and asks whether to finish it, move on, or skip — no blanket restart. When you're done resolving incomplete features, it offers explicit re-entry points: add features to an existing epic, create a new epic, or update a specific spec.

### I only want to spec one feature, not design a whole product. Does requirement-forge force me through a full epic structure?

No. If your description or documents reveal only 1–3 features, the molecule offers a single-feature fast path: spec the feature directly, then write a minimal placeholder epic to `index.md` so the structure is in place for later expansion. You are not forced to define a complete epic before speccing a single feature.

### How does requirement-forge connect to design-blueprint?

Each feature file has a `Links: Design` field that gets updated when `design-blueprint` creates a context anchor doc for that feature. The `design-blueprint` molecule's context-anchoring step accepts a "requirement doc link" pointing to the feature file — it loads the problem statement and scope as starting context for the design session. The two molecules complement each other: requirement-forge defines WHAT and WHY; design-blueprint defines HOW.

### What is the difference between collaborative and autonomous mode in requirement-forge?

Collaborative mode (default) pauses for confirmation at every phase — epic list, feature list per epic, feature frame, and each scenario. The molecule proposes and you approve or correct before advancing. Autonomous mode runs all phases silently, drafts everything, then presents the complete output for review. Use collaborative when you want to shape the spec interactively; use autonomous when you want a draft quickly and prefer to review and edit in one pass. Autonomous mode pauses only for genuine blockers — contradictions with no reasonable resolution, missing domain knowledge, or scope so ambiguous that two valid structures exist.

### Why does the feature file ask for personas? My PRD already says "for users."

"Users" is too vague for good specs. Different user types produce different acceptance criteria — what an admin sees on login is not what a buyer sees. The molecule pushes for specific roles (buyer, seller, admin, guest) so each scenario's ACs are verifiable for a concrete user type. If a feature genuinely serves all user types identically, state that explicitly — the persona section still forces you to confirm it rather than silently assume.

### My feature has assumptions that might be wrong. How does requirement-forge handle them?

Feature files include an explicit Assumptions section — statements the team proceeds with as true without full validation. The `requirement-quality` atom checks for hidden assumptions (preconditions buried in ACs without being documented) and treats them as an anti-pattern. When an assumption reads like it could be a requirement ("users will have verified emails" — is that an assumption or a feature to build?), the atom flags it as an ambiguity signal for you to decide.

### What happens to content from my source documents that doesn't map to any feature?

It goes into the Deferred Items section of `index.md` — intentionally excluded content with reasons for deferral. Nothing disappears silently. Marketing copy, competitive positioning, out-of-scope ideas, and deferred feature suggestions are all tracked so stakeholders can verify that everything from the source material was either mapped to a feature or consciously set aside.

### Can I use the `requirement-quality` atom on its own to validate specs I already wrote?

Yes. The atom works standalone — it does not require the molecule. Point it at any feature spec file and it runs the 11-item self-validation checklist (problem statement, scope, personas, assumptions, scenarios, ACs, independence, etc.) and the 15-item anti-pattern scan. It will flag issues like vague problem statements, missing failure scenarios, persona-less specs, hidden assumptions, and wrong granularity. Use it as a quality gate before handing any spec to `design-blueprint`.

---

## Architecture

### My team uses clean architecture. Do I need to configure anything?

No. Clean architecture is the default — atoms enforce it out of the box with no config needed. Optionally run `/architecture-refiner` to customize specific rules (e.g., disable the Provider pattern, adjust layer naming) and write them to `.lattice/standards/architecture.md`.

### I use clean architecture but want to customize a few rules (e.g., we don't use the Provider pattern).

Run `/architecture-refiner`. It interviews you about your specific rules and writes `.lattice/standards/architecture.md` in overlay mode by default — your customizations apply on top of clean architecture defaults, so you only need to document what differs.

### My team uses hexagonal / ports & adapters architecture. How do I set that up?

Run `/architecture-refiner` and select hexagonal / ports & adapters when prompted. It sets `architecture_mode: custom` in `.lattice/config.yaml` and writes `.lattice/standards/architecture.md` — an enriched document where you capture port/adapter boundaries, inbound/outbound rules, allowed dependency directions, anti-patterns, naming conventions, and any other constraints your team follows. The richer the document, the more precisely the architecture atom enforces your structure.

### We use a modular monolith with vertical slices. Can Lattice work with that?

Yes. Run `/architecture-refiner` and describe your modular monolith structure. It sets `architecture_mode: custom` and produces `.lattice/standards/architecture.md` where you document your slice boundaries, module contracts, shared kernel rules, and any cross-slice constraints. The architecture atom enforces exactly what you define.

### We don't follow any named architecture pattern — we have our own layer structure. Can Lattice enforce it?

Yes. Run `/architecture-refiner` and describe your layers, their responsibilities, and the rules between them. It sets `architecture_mode: custom` and writes `.lattice/standards/architecture.md` — Lattice has no requirement for a named pattern. The more precisely you describe your rules, the more precisely the atom enforces them.

### What is `architecture_mode` and when do I need to set it?

`architecture_mode` tells the architecture atom which rulebook to use: `clean` (default) uses embedded clean architecture enforcement; `custom` uses only your `.lattice/standards/architecture.md`. You only need to set it when you're not using clean architecture — `/architecture-refiner` sets it automatically when you select a non-clean style.

### I switched from clean architecture to hexagonal. How do I update my Lattice config?

Re-run `/architecture-refiner` and select hexagonal when prompted. It updates `architecture_mode: custom` in `.lattice/config.yaml` and rewrites `.lattice/standards/architecture.md` with your new structure. Your old clean architecture document is replaced.

---

## Language

### My team uses Go (or Rust, or Python). Do I need to do anything special?

Run `/language-idioms-refiner`. It detects your language, proposes idiomatic patterns (error handling, type system, naming, testing, DI), and asks you to confirm or adjust. The output goes to `.lattice/standards/language-idioms.md` and is consumed by multiple atoms — clean-code, test-quality, secure-coding, DDD, and architecture all reference specific sections to adapt their pseudocode defaults to your language. `/lattice-init` auto-suggests this as priority #2 after knowledge-priming.

### We use Java/TypeScript. The defaults already seem fine. Do we still need the language-idioms document?

Recommended but not critical. The embedded defaults have an OOP + exception-based style that aligns well with Java, Kotlin, TypeScript, and C#. The language-idioms document still adds value — it captures your specific conventions (test framework, DI approach, naming patterns) — but the gap is smaller than for Go or Rust where the defaults actively conflict.

### What's the difference between the language-idioms document and knowledge-priming?

Knowledge-priming answers "what is this project?" — tech stack, directory layout, trusted docs, conventions. Language idioms answers "how does this language express patterns?" — error handling philosophy, type system, naming rules, testing idioms, DI approach. Knowledge-priming says "we use Go 1.22 with Chi router." Language idioms says "Go uses error returns not exceptions, interfaces at consumer not provider, table-driven tests."

### What's the difference between the language-idioms document and a clean-code overlay?

Language idioms describes *how the language works* — language-level facts. A clean-code overlay describes *how your team works within the language* — team-level preferences. Language idioms: "Go uses error returns." Clean-code overlay: "We use `fmt.Errorf('context: %w', err)` for wrapping and custom error types for domain errors." They're complementary, not overlapping.

### My project uses multiple languages (e.g., Go backend + TypeScript frontend). What do I do?

One language-idioms document per project, covering the primary language. `/lattice-init` detects multiple languages and asks which is primary. If both languages are equally important, create the document for whichever language you use Lattice with most (typically the backend). The other language still gets reasonable behavior from the pseudocode defaults.

### The atoms are generating exception-based error handling, but we use Go.

You're missing the language-idioms document. Run `/language-idioms-refiner` — it proposes Go-idiomatic patterns including error returns, `if err != nil`, and error wrapping. The clean-code atom reads the "Error Handling" section and adapts §8 accordingly. Without it, atoms fall back to pseudocode defaults which assume exceptions.

---

## Customization

### How do I change what an atom checks for?

Run the corresponding refiner (e.g., `/clean-code-refiner`, `/architecture-refiner`) — it interviews you and writes a standards document to `.lattice/standards/` that the atom picks up. If no refiner exists for what you need, add your rules directly to `.lattice/standards/knowledge-base.md`; the knowledge-priming atom loads it into every workflow.

### What is the difference between overlay and override mode?

Overlay (default) applies your standards document on top of embedded defaults — only sections you define replace the corresponding defaults; everything else stays. Override fully replaces the defaults with your document — atoms enforce only what you wrote. Use overlay when you want to tweak a few rules; use override when you manage the full standard yourself.

### I ran the architecture-refiner but want to change one section. Do I re-run the whole interview?

No. Edit `.lattice/standards/architecture.md` directly — it's a plain markdown file. Update the section you want to change and save. The atom picks it up on the next invocation. Re-run `/architecture-refiner` only if you want a guided interview to rebuild the document from scratch.

### Can I write the standards document by hand instead of using a refiner?

Yes. Create the file directly under `.lattice/standards/` (e.g., `architecture.md`) and point to it in `.lattice/config.yaml` via the relevant `paths` key. The refiner is just a guided way to produce the same file — the atom only cares about the document, not how it was created.

### How do I add project-specific rules that don't exist in any atom's defaults?

Add them to `.lattice/standards/knowledge-base.md`. The knowledge-priming atom loads this document into every workflow, so any rule, convention, or constraint you put there is available to all atoms and molecules. You can edit it directly or use `/knowledge-priming-refiner` to build it via a guided interview.

---

## Workflow

### When should I use `/design-blueprint` vs. just starting with `/code-forge`?

Use `/design-blueprint` when the feature involves real design decisions — new components, cross-layer interactions, API contracts, or anything where getting the structure wrong is costly to fix. Go straight to `/code-forge` for small, well-understood changes where the design is already clear. When in doubt, blueprint first — it takes minutes and prevents larger refactors later. If the feature itself is not yet well-defined, start with `/requirement-forge` before `/design-blueprint`.

### What is the difference between `/refactor-safely` and just refactoring directly?

`/refactor-safely` requires agreement on the target structure before touching code, then uses characterization tests as a safety net to ensure externally observable behavior doesn't change. Refactoring directly skips both — no upfront structural agreement and no enforced regression protection. Use `/refactor-safely` when the change is non-trivial or the code lacks test coverage.

### When should I use `/bug-fix` vs. just fixing the bug myself?

`/bug-fix` enforces the right thought process: RCA first, reproduce with a failing test, then fix. It prevents jumping straight to a patch without understanding the cause. That said, it's a judgment call — for obvious, contained bugs you're confident about, fixing directly is fine. `/bug-fix` adds the most value when the root cause is unclear or the fix touches critical paths.

### How does `/review` differ from a normal code review?

`/review` is delta-scoped and structured — it only reviews what changed, applies all relevant atoms (architecture, clean code, security, test quality) as enforcement lenses, and produces severity-ordered findings. A normal code review depends on the reviewer's knowledge and attention. `/review` ensures no atom's rules are silently skipped and captures recurring patterns as learnings to improve future code generation.

### What is the "inside-out implementation order" in code-forge?

Inside-out means code-forge implements from the innermost layer outward: domain/core entities first, then use cases, then adapters/infrastructure, then the entry points (controllers, handlers). This order ensures outer layers always depend on already-implemented inner layers — matching the dependency direction defined in your architecture rules and preventing placeholder stubs from leaking into the final code.

---

## Codebase Transformation

### My codebase has significant architectural debt. Where do I start?

Run `/plan-transformation`. It scans the codebase, conducts a short targeted interview, then leads a collaborative session to agree on the current architecture and a target architecture. The output is `.lattice/transform/plan.md` — a living document with an agreed current state, agreed target state, and an ordered slice backlog. Once the plan exists, each slice is executed using `/refactor-safely` (for moving existing code) and `/code-forge` (for writing new code in the new structure).

### What does `/plan-transformation` actually produce?

A single document at `.lattice/transform/plan.md` with eight sections: codebase identity, archaeology findings (dead code, duplicates, hidden coupling), domain map, current architecture with dependency diagram, target architecture with diagram and annotated folder tree, gap analysis, transformation strategy, and an ordered slice backlog. Each slice specifies scope, structural change, pre-conditions, what the system can still do after the slice, risk level, and success criteria.

### How long does a planning session take?

Plan for at least one focused session. The scan and interview are fast. The two agreement rounds — current state and target architecture — take longer than most teams expect. The current state agreement in particular surfaces things the team assumed were intentional but are actually drift, and vice versa. That reconciliation is the real work of the session. The slice backlog can be built in a follow-up session if needed — reaching current + target architecture agreement is itself a complete and valuable output.

### The AI proposed a target architecture that feels too simple. Should I push for more?

Only if you have a specific reason. The molecule is designed to propose the minimum viable target — the simplest structure that resolves the stated pain. Teams consistently over-correct when looking at messy code, designing a target that looks impressive but requires six months before anything improves. The test: does each transformation slice leave the system measurably better than before? If a more ambitious target only pays off at the very end, it is the wrong target. Push for more complexity only when you have a concrete reason, not because simplicity feels unsatisfying.

### I tried transforming this codebase before and it stalled. Will this be different?

The planning interview explicitly asks about previous failed attempts. That question is the most important one in the session — previous failures reveal specific blockers (technical, organisational, or political) that will stop this attempt too unless the plan accounts for them. Whatever stopped the last attempt needs to be named in the plan document and addressed in the transformation strategy before the first slice runs.

### What is the difference between `/plan-transformation` and `/refactor-safely`?

`/refactor-safely` operates at a bounded, specific scope — one module, one component, one known structural problem. It assumes you already know what needs to change and why. `/plan-transformation` operates at the whole-codebase level — it discovers what needs to change, agrees on a target state, and produces a prioritised execution plan. Use `/plan-transformation` when you need a shared direction across the codebase. Use `/refactor-safely` when you have a specific, bounded improvement to make — including executing individual slices from a transformation plan.

### Can I run `/plan-transformation` on a codebase that already has `.lattice/` config?

Yes — and it will be better for it. If `.lattice/standards/architecture.md` exists (from running `/architecture-refiner`), the molecule uses it as the lens for the architectural audit and as input to the target architecture proposal. If `.lattice/standards/knowledge-base.md` exists, the molecule loads it to ground the codebase identity. If neither exists, the molecule infers defaults from the scan and offers to run `/lattice-init` first.

### The plan document says the target architecture is a hypothesis. Does that mean it will change?

Yes, and that is expected. No transformation plan survives contact with the codebase fully intact. Early slices surface hidden coupling, contested domain assumptions, and structural surprises that change the understanding of later ones. A plan that presents itself as authoritative gets abandoned the first time reality diverges. A plan framed as a hypothesis gets updated. Update the plan document when execution reveals new information — that is what the Progress Log section is for.

### We have a large codebase. Will `/plan-transformation` try to read everything?

No. The molecule uses a strategic scanning protocol: directory tree, dependency manifests, architecture documents, import patterns via grep, entry points, interface files, and one representative file per top-level module — roughly 15–25 targeted reads total. It reads for architectural signal, not for completeness. Full method implementations, test files, generated code, and vendor directories are skipped entirely. The scan is enough to form a reliable architectural hypothesis on any codebase size.

---

## Domain-Driven Design

### Can I customize what DDD patterns Lattice enforces?

Yes. Run `/ddd-refiner` — it interviews you about your DDD usage and writes `.lattice/standards/ddd-principles.md`. You can limit enforcement to only the patterns your team uses (e.g., aggregates and value objects but not bounded contexts) and add project-specific rules on top of the defaults. For example: "all domain objects must be constructed via the builder pattern", "aggregates must never expose mutable collections", "value objects must be immutable and self-validating". The DDD atom enforces whatever you define alongside the embedded defaults.

---

## Team Usage

### Multiple developers on my team use Lattice. How do we coordinate?

Commit `.lattice/` to version control. All standards documents, config, blueprints, and review insights live there — everyone on the team shares the same rules automatically. Refiners are run once (or as a team decision) and the outputs become the shared source of truth. Individual developers pull the latest `.lattice/` and Lattice enforces the team's agreed standards, not personal defaults.

### Should we run refiners individually or as a team?

As a team, at least for the first time. Refiner outputs define what Lattice enforces for everyone — architecture rules, coding standards, DDD patterns. These are team decisions, not individual preferences. One person running a refiner and committing the output is fine mechanically, but the decisions inside should reflect team consensus. Re-runs to tweak rules follow the same principle.

### Two developers customized the architecture differently. How do we resolve that?

Treat `.lattice/standards/architecture.md` like any other source file — resolve the conflict in version control. Review both versions as a team, agree on the rules, and merge into one canonical document. Going forward, architecture changes should go through the same review process as code changes to prevent divergence.

### A new developer joined. How do they onboard to our Lattice setup?

They pull the repo — `.lattice/` is already there with all the team's standards, config, and review history. No refiner runs needed. They install Lattice into their AI tool, and it immediately enforces the team's agreed rules. The `.lattice/` folder is the onboarding artifact.

---

## The Learning Flywheel

### What are review insights and how do they feed back into code generation?

`/review` captures two things: a **review log** (`.lattice/reviews/review-log.md`) for health tracking and trends, and **review insights** (`.lattice/learnings/review-insights.md`) for recurring patterns worth remembering. Only insights feed back into code generation — when `/code-forge` runs next, it loads `.lattice/learnings/review-insights.md` and uses those patterns to avoid repeating past mistakes (e.g., if insights flag "anemic domain models keep appearing," it actively pushes behavior into entities from the start).

### How do I know if Lattice is actually improving my code quality over time?

Check `.lattice/reviews/review-log.md` — it tracks findings per review (critical, warning, suggestion counts) and key patterns over time. If the same issues keep appearing, they'll surface in `.lattice/learnings/review-insights.md` as recurring patterns. Improvement shows up as fewer critical and warning findings per review cycle and fewer recurring entries in learnings.

### The review log is getting long. How do I manage it?

`/review` handles this automatically — once the log exceeds ~20 entries, it moves the oldest entries into a one-line `## History` summary section at the top of `.lattice/reviews/review-log.md`. For `.lattice/learnings/review-insights.md`, once it exceeds ~50 entries, `/review` will suggest pruning oldest entries that haven't recurred in recent reviews. You can also prune either file manually.

### Can I manually add insights from production incidents?

Yes. Edit `.lattice/learnings/review-insights.md` directly and add a bullet in the same format: `- YYYY-MM-DD [Feature]: Pattern observed — actionable takeaway`. Keep it concise and actionable — the goal is a signal that helps future code generation avoid the same mistake, not a detailed incident report.

---

## Troubleshooting

### An atom seems to be checking rules I don't agree with. How do I change them?

Run the corresponding refiner to produce a standards document for that atom — it replaces or overlays the embedded defaults. If no refiner exists for the atom, add your rules to `.lattice/standards/knowledge-base.md`. If you disagree with a specific check entirely, use override mode to take full control of what the atom enforces.

### Code-forge is generating code in a style that doesn't match my project. What should I check?

Check three things: first, that `.lattice/standards/knowledge-base.md` exists and describes your project's tech stack, conventions, and coding style — run `/knowledge-priming-refiner` if it doesn't. Second, check `.lattice/standards/language-idioms.md` — if it's missing and you use Go, Rust, Python, or another non-OOP language, atoms will use pseudocode defaults that assume exceptions and classes. Run `/language-idioms-refiner` to fix this. Third, check `.lattice/standards/clean-code.md` — if it's missing or generic, run `/clean-code-refiner` to capture your project-specific style.

### The architecture atom isn't loading my custom document. What could be wrong?

Check three things: (1) `.lattice/config.yaml` has `paths.architecture` pointing to the correct file path; (2) the file actually exists at that path; (3) `architecture_mode: custom` is set — without it, the atom uses clean architecture defaults and ignores the custom document. If all three are correct, check that the document has a valid markdown structure with headings the atom can parse.
