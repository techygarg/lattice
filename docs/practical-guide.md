# Practical Guide

Scenario-driven answers to common questions practitioners have when adopting and using Lattice. Each answer is self-contained and brief.

---

## Contents

- [Getting Started](#getting-started)
- [Architecture](#architecture)
- [Customization](#customization)
- [Workflow](#workflow)
- [Domain-Driven Design](#domain-driven-design)
- [Team Usage](#team-usage)
- [The Learning Flywheel](#the-learning-flywheel)
- [Troubleshooting](#troubleshooting)

---

## Getting Started

### I just installed Lattice. What do I do first?

Run `/lattice-init`. It scans your project, creates `.lattice/config.yaml`, and tells you which refiners to run based on what it finds. After that, run the suggested refiners (starting with `/knowledge-priming-refiner`) to give Lattice context about your project. Once done, you're ready to use any molecule.

### My project already has 50k+ lines of code. Is Lattice only for new projects?

No. Lattice works for brownfield codebases too. Run `/lattice-init` to scan the repo and set up `.lattice/` around what you already have. Use `/refactor-safely`, `/bug-fix`, and `/review` for incremental improvement without rewriting everything. Run `/architecture-refiner` to give Lattice explicit ground rules for whatever architecture you actually follow — it writes `.lattice/standards/architecture.md` so the architecture atom enforces your structure, not a generic default.

### What happens if I skip all refiners and just start using molecules?

Molecules work, but results will be generic. Without `/knowledge-priming-refiner`, Lattice has no awareness of your project — it can't tailor generated code to your stack or conventions. The embedded defaults for architecture, clean code, DDD, and review are solid, so skipping the other refiners is fine. But `/knowledge-priming-refiner` is a must.

### What is the `.lattice/` folder and should I commit it to version control?

The `.lattice/` folder is Lattice's living context layer. It holds `config.yaml` (your settings), `standards/` (refiner outputs like architecture and coding rules), `blueprints/` (design decisions), `reviews/` (review log), and `learnings/` (review insights). Commit it — it's the shared source of truth for your team's standards and accumulates value over time.

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

Use `/design-blueprint` when the feature involves real design decisions — new components, cross-layer interactions, API contracts, or anything where getting the structure wrong is costly to fix. Go straight to `/code-forge` for small, well-understood changes where the design is already clear. When in doubt, blueprint first — it takes minutes and prevents larger refactors later.

### What is the difference between `/refactor-safely` and just refactoring directly?

`/refactor-safely` requires agreement on the target structure before touching code, then uses characterization tests as a safety net to ensure externally observable behavior doesn't change. Refactoring directly skips both — no upfront structural agreement and no enforced regression protection. Use `/refactor-safely` when the change is non-trivial or the code lacks test coverage.

### When should I use `/bug-fix` vs. just fixing the bug myself?

`/bug-fix` enforces the right thought process: RCA first, reproduce with a failing test, then fix. It prevents jumping straight to a patch without understanding the cause. That said, it's a judgment call — for obvious, contained bugs you're confident about, fixing directly is fine. `/bug-fix` adds the most value when the root cause is unclear or the fix touches critical paths.

### How does `/review` differ from a normal code review?

`/review` is delta-scoped and structured — it only reviews what changed, applies all relevant atoms (architecture, clean code, security, test quality) as enforcement lenses, and produces severity-ordered findings. A normal code review depends on the reviewer's knowledge and attention. `/review` ensures no atom's rules are silently skipped and captures recurring patterns as learnings to improve future code generation.

### What is the "inside-out implementation order" in code-forge?

Inside-out means code-forge implements from the innermost layer outward: domain/core entities first, then use cases, then adapters/infrastructure, then the entry points (controllers, handlers). This order ensures outer layers always depend on already-implemented inner layers — matching the dependency direction defined in your architecture rules and preventing placeholder stubs from leaking into the final code.

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

Check two things: first, that `.lattice/standards/knowledge-base.md` exists and describes your project's tech stack, conventions, and coding style — run `/knowledge-priming-refiner` if it doesn't. Second, check `.lattice/standards/clean-code.md` — if it's missing or generic, run `/clean-code-refiner` to capture your project-specific style. Code-forge generates to the standards it loads; if those are missing, it falls back to generic defaults.

### The architecture atom isn't loading my custom document. What could be wrong?

Check three things: (1) `.lattice/config.yaml` has `paths.architecture` pointing to the correct file path; (2) the file actually exists at that path; (3) `architecture_mode: custom` is set — without it, the atom uses clean architecture defaults and ignores the custom document. If all three are correct, check that the document has a valid markdown structure with headings the atom can parse.
