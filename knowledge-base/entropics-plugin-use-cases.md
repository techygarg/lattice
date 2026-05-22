# Lattice Plugin — Top 6 Use Cases (Entropics Submission)

**Plugin:** lattice v1.4.0

**Install:**

```
/plugins marketplace add techygarg/lattice
/plugins install lattice
/reload-plugins
```

All workflows run as chat commands (e.g. `/lattice-init`), not terminal scripts.

---

## Use Case 1 — Onboard a project in one session

| | |
|---|---|
| **For** | Any engineer joining an existing repo |
| **Command** | `/lattice-init` → then suggested refiners (typically `/knowledge-priming-refiner`, `/language-idioms-refiner`, `/architecture-refiner`) |
| **You provide** | Access to the codebase; answers in short guided interviews |
| **Lattice does** | Scans the repo, creates `.lattice/config.yaml`, and writes team-specific standards under `.lattice/standards/` |
| **Value** | Every later skill uses *your* stack, layout, architecture, and language idioms — not generic AI defaults |
| **Output** | Committable `.lattice/` folder as the team's shared AI context layer |

---

## Use Case 2 — Deliver a feature end-to-end with persisted decisions

| | |
|---|---|
| **For** | Product + engineering building a new capability |
| **Commands** | `/requirement-forge` → `/design-blueprint` → `/code-forge` → `/review` |
| **You provide** | Feature idea, PRD, or verbal scope; confirmations at design gates |
| **Lattice does** | Specs WHAT/WHY (requirements), agrees HOW (blueprint with confirmation gates), implements inside-out with quality atoms, then delta-reviews the change |
| **Value** | No silent design choices, no lost context mid-session; each stage feeds the next from `.lattice/` artifacts |
| **Output** | `.lattice/requirements/` → `.lattice/context/` → code → review findings and learnings for the next cycle |

**Example prompt chain:** *"Spec password reset with email link and rate limiting"* → *"Design from `features/password-reset.md`"* → *"Implement the approved blueprint"* → *"Review this branch vs main"*

---

## Use Case 3 — Orient a legacy codebase before changing anything

| | |
|---|---|
| **For** | Tech leads on brownfield systems with architectural drift |
| **Command** | `/architecture-compass` |
| **You provide** | Repo access; interview answers on pain, past failures, and success criteria |
| **Lattice does** | Strategic scan, targeted interview, collaborative agreement on current architecture vs minimum viable direction |
| **Value** | Prevents months of uncoordinated refactors; team gets one agreed map before execution |
| **Output** | `.lattice/insights/architecture.md` — current state, recommended direction, gap assessment, and 2–3 concrete first moves (which molecule to use next) |

**Does not:** move code, plan sprints, or audit naming/style — orientation only.

---

## Use Case 4 — Refactor structure without changing behavior

| | |
|---|---|
| **For** | Engineers fixing layer violations, god modules, or misplaced domain logic |
| **Command** | `/refactor-safely` |
| **You provide** | Scope (e.g. module or class) and target structure |
| **Lattice does** | Agrees target architecture first, adds characterization tests, refactors in small steps, verifies with architecture and clean-code atoms |
| **Value** | Refactor with a safety net when coverage is weak; behavior stays observable-identical |
| **Output** | Restructured code + tests; decisions can be recorded in `.lattice/context/` |

---

## Use Case 5 — Fix a bug with evidence, not guesses

| | |
|---|---|
| **For** | Developers and QA on regressions or unclear production failures |
| **Command** | `/bug-fix` |
| **You provide** | Symptoms, repro steps, logs, or error messages |
| **Lattice does** | Root-cause analysis → failing test that reproduces → minimal fix → regression protection |
| **Value** | Stops patch-first fixes on critical paths; fix is justified and guarded by a test |
| **Output** | RCA summary, failing test, fix, and optional learnings for future sessions |

---

## Use Case 6 — Review a change against enforced team standards

| | |
|---|---|
| **For** | Authors and reviewers before merge |
| **Command** | `/review` |
| **You provide** | Branch, PR, or file delta to review |
| **Lattice does** | Delta-scoped review; applies atoms conditionally (clean-code always; architecture, DDD, security, tests when relevant) |
| **Value** | Same enforcement lenses every time — not dependent on reviewer memory; findings are severity-ordered with locations and fixes |
| **Output** | Structured review report; recurring patterns can feed `.lattice/` for improved future generation |

**Optional setup:** `/review-refiner` once to tailor severity rules and report format.

---

## Quick reference

| # | Command(s) | Primary artifact |
|---|------------|------------------|
| 1 | `/lattice-init` + refiners | `.lattice/config.yaml`, `.lattice/standards/` |
| 2 | `/requirement-forge` → `/design-blueprint` → `/code-forge` → `/review` | requirements → context → code → review log |
| 3 | `/architecture-compass` | `.lattice/insights/architecture.md` |
| 4 | `/refactor-safely` | Restructured code + characterization tests |
| 5 | `/bug-fix` | Failing test + minimal fix |
| 6 | `/review` | Severity-ordered delta review |

---

## What makes Lattice different (one paragraph for Entropics)

Lattice is not a single mega-prompt. It is **26 composable skills** (atoms, molecules, refiners) plus a **living `.lattice/` folder** that stores your team's standards, specs, designs, and review learnings. Skills compose into SDLC workflows; refiners customize behavior without forking skill source. The same plugin serves greenfield features, brownfield orientation, safe refactors, disciplined bug fixes, and standards-backed reviews.
