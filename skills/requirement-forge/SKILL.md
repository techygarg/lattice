---
name: requirement-forge
description: "Generate structured feature specifications through a collaborative product interview. Acts as a senior PM and business analyst pair — arrives with a point of view, challenges scope, proposes options at every decision. Composes the requirement-quality atom for spec quality enforcement and collaborative-judgment for surfacing genuine decisions. Produces an epic/feature hierarchy in .lattice/requirements/ that serves as direct input to design-blueprint. Use when the user says 'forge requirements', 'write requirements', 'spec this feature', 'create a feature spec', 'define this epic', 'write a PRD', 'spec out what we are building', or 'requirement forge'."
---

# Requirement Forge

## Required Skills

Read and apply in order:

1. `framework:requirement-quality` — load requirement standards and enforce spec quality throughout (always)
2. `framework:collaborative-judgment` — surface genuine judgment calls instead of silent assumptions (always)
3. `framework:knowledge-priming` — ground feature language in actual project domain (conditional: skip if no codebase exists yet)

## Mode Detection

**Collaborative (default)** — confirmation gate at each phase. Proposes at every decision, challenges scope, treats the user as a partner.

**Autonomous** — invoked when the user says "forge autonomously", "draft everything", or "autonomous mode". Steps 2–5 run without gates. After drafting, present complete output for review. `framework:requirement-quality` checks still run silently before each file write.

## PM/BA Persona

Behave as an experienced senior PM and business analyst.

- **Ask WHY before accepting WHAT.** If the user states a solution without a problem, ask what user pain it solves.
- **Challenge scope actively.** Name the concern specifically: "This sounds like two features" or "A user can't complete [task] without [missing piece]."
- **Propose at every decision.** Never ask an open question without a view. State your preference and let the user confirm or override.
- **Do not just listen and agree.** When the user's framing is incomplete or inconsistent, say so and offer a better framing.

## Additional Instructions

**STOP: Before Step 1, read `additional_instructions.requirement_forge` (one line or a list) from `.lattice/config.yaml`.** No file or no key → skip silently.

When lines are found:

1. Show them verbatim under "Additional instructions (from config):".
2. **Highest priority — apply them for the whole session, including on resume.** On any conflict with anything else in this skill — steps, gates, STOP rules — or with its Required Skills, standards documents, or operational learnings, the config line wins.

## Workflow

### Step 1: Standards and Session Check

**1a — Load standards**

Trigger `framework:requirement-quality` — it handles config resolution and loads the active standards. Do not re-implement or recite its logic here.

If no standards document is found at `paths.requirement_standards`: do not stop. Say in one line which built-in defaults govern the session and that `/requirement-forge-refiner` tailors them, then continue.

**1b — Session resume**

Scan `.lattice/requirements/` for existing documents.

- **Legacy format check** — if `index.md` exists with epic sections and feature tables written directly inside it (no `epics/` directory alongside), and `requirements_layout` is absent from `.lattice/config.yaml` or set to `flat`: tell the user "This project's requirements index uses an older Lattice layout. Run `/lattice-init` to check for and apply available upgrades." **STOP:** do not attempt migration in this molecule.
- **If `index.md` exists** (sharded layout) → read it plus `epics/*.md`, inventory all feature files under `features/`. Classify each as: unfinished (its `## Scenarios` still carries the in-progress line), structurally incomplete (missing sections), quality-suspect (run `framework:requirement-quality` Anti-Pattern Scan silently — flag anything that fires), or complete. Collect each epic's `## Planned Features` — features agreed earlier but not yet specced; delete a planned line whose feature file already exists. A feature file its epic's generated table does not list → regenerate that table now, per Step 6.
- **If anything is unfinished, planned, or has issues** → list it once (feature — state or issue) and ask which to work on now. Each pick → Step 5 for it: an unfinished file resumes at its next scenario, a planned feature starts at its frame, a file with issues is fixed in place. The rest wait for a later session.
- **Everything complete, or nothing picked** → ask what to do next, then re-enter at the right step:
  - Add features to existing epic → **Step 4**
  - Create new epic → **Step 3**
  - Update a spec → **Step 5**
- **If nothing exists** → proceed to Step 2.

**STOP:** Do not advance to Step 2 until all resume decisions are recorded.

---

### Step 2: Intake

Open with: *"Do you have existing material I should read — PRDs, feature lists, Confluence pages, Jira exports, files in this repo? If yes, point me to them. If no, describe what you're building."*

**If material is provided** — read silently. Before forming the hypothesis, triage the source material:

1. **Classify each document**: product requirements, technical design, stakeholder wishlist, marketing/positioning, competitive analysis, or mixed. Only product requirements and stakeholder wishlists feed the feature pipeline — flag the rest as reference-only.
2. **Identify overlaps**: two documents describing the same capability in different words → merge into one feature, note both sources.
3. **Identify contradictions**: two documents disagreeing on scope, behavior, or priority → log each conflict explicitly and resolve before including in the hypothesis.
4. **Check granularity**: does the material look like ACs / tasks (too granular) or whole product areas (too coarse)? Name it before presenting the hypothesis.
5. **Identify gaps**: what user-facing behaviors are implied but never stated? What failure paths are missing?
6. **Flag orphaned content**: material that doesn't map to any feature (deferred ideas, out-of-scope suggestions, marketing copy) → collect for the relevant epic's Deferred Items section in Step 6.

Present synthesis: *"Here's what I understand from [N] documents: [epic list with one-liners]. Sources classified as [types]. [Any contradictions or gaps.] [Orphaned content flagged for deferral.] Does this map reflect your vision? What's wrong or missing?"*

**If no material** — *"Tell me what you're building — the problem, who has that problem, any constraints. Don't worry about structure yet."* Listen, synthesize, present the same hypothesis format.

**Single-feature fast path**: if synthesis reveals only 1–3 features, don't force the full epic pipeline. Offer to spec those features directly — skip Step 3 (Epic Definition) and Step 4 (Feature Discovery), proceed directly to Step 5 with the confirmed features. Before starting Step 5, create a placeholder epic: one `.lattice/requirements/epics/{epic-slug}.md` named for the feature area (confirm the name with the user), and the thin `index.md` pointing to it, same as Step 3's write sequence. List the confirmed features under the epic's `## Planned Features`, as Step 4 does.

**STOP:** Do not advance to Step 3 (or Step 5 if fast path) until the synthesis is confirmed.

---

### Step 3: Epic Definition

Propose the full epic list. For each epic: name, one-paragraph description, rough scope boundary.

Challenge any epic that is too narrow (one feature doesn't warrant an epic) or too broad (encompasses the entire product). Offer alternatives for contestable boundaries.

**Large product**: if the list has 4+ epics or 15+ estimated features, propose a session focus — complete one epic fully before moving to others.

Ask: *"Does this epic structure reflect how you think about the product?"*

**STOP:** Do not advance to Step 4 until the epic list is confirmed.

**Immediately after confirmation:**
1. Create `.lattice/requirements/`, `.lattice/requirements/epics/`, and `.lattice/requirements/features/` if they do not exist.
2. Write one `.lattice/requirements/epics/{epic-slug}.md` per confirmed epic — name, description, and an empty generated feature-table section. Read `references/output-templates.md` for the exact structure. Epics not selected for this session's focus are still created, just with no features yet.
3. Write `.lattice/requirements/index.md` as the thin apex — Definitions plus the generated epic-list table (one row per epic file just created). Read `references/output-templates.md` for the exact structure.
4. Ensure `.lattice/config.yaml` has `requirements_layout: sharded`. Create the config file if it does not exist; add the key if the file exists without it. Never overwrite an existing `sharded` value.

**STOP: do not write feature tables into `index.md` or hand-append rows to an epic file's generated `## Features` table at any point** — see Step 6.

---

### Step 4: Feature Discovery (per epic)

For each confirmed epic, propose the feature breakdown: name, one-line description, epic assignment, dependencies.

Apply `framework:requirement-quality` anti-pattern scan proactively here — surface misclassified items as PM/BA challenges before the user commits to a feature list.

Ask: *"Does this feature breakdown feel right for [Epic Name]?"*

**Record the plan**: once an epic's feature list is confirmed, write it into that epic file's `## Planned Features` — one line per feature with its description and dependencies (see `references/output-templates.md`). Step 5 deletes each line as it writes that feature's file, so a session that stops early leaves the rest on disk.

**STOP:** Do not advance to Step 5 until the feature list for every in-scope epic is confirmed.

---

### Step 5: Feature Spec (per feature)

Work through confirmed features one at a time.

**Level 1 — Feature Frame**: Collect dependencies, problem statement, user personas (who has this problem — specific roles, not "users"), scope (with explicit out-of-scope items), boundary conditions, assumptions (what the team proceeds with as true without full validation), technical constraints (fixed external interfaces, existing contracts that cannot change, hard platform limits — or none), and a proposed priority in the loaded standards' notation. Challenge each field: wrong problem, wrong user, inflated scope. After presenting: *"Does this frame capture the right problem, the right users, and the right scope? Let's lock this before scenarios."*

**STOP:** Do not begin scenarios until the frame is confirmed.

**Write the draft** once the frame is confirmed (an existing file → see *Updating an existing file* below): write `.lattice/requirements/features/{feature-name}.md` with `status: draft`. Read `references/output-templates.md` for the exact file structure; create the `features/` directory if it does not exist. Populate the frontmatter: `depends_on` from the dependencies confirmed in Step 4 (Feature Discovery) or the frame; `personas` from the frame; `source_docs` from intake documents; `priority` as confirmed with the frame — never assign it silently. Under `## Scenarios` put the in-progress line `*(In progress — scenarios not yet confirmed.)*`. A section with nothing to record gets `None.` — never leave the template's guidance text in the file. Delete this feature's line from its epic's `## Planned Features`, and the section once it is empty.

**Level 2 — Scenarios**: Spec scenarios one at a time in implementation order. For each: propose name (verb phrase), one-sentence description, and ACs in the format `framework:requirement-quality` loaded. Add each scenario to the file once the user confirms it. After the first success-path scenario, probe: *"Where's the failure path? What happens when [validation fails / session expires / permission denied]?"*

After all scenarios: *"Does this fully cover [Feature Name]? Anything missed?"* Confirmed → delete the in-progress line.

**Check the finished spec**: apply the `framework:requirement-quality` Self-Validation Checklist and Anti-Pattern Scan. Failures → fix with the user; a failure the user leaves open keeps the spec `draft`, and Step 6 will not offer it for approval. Ambiguity signals → surface via `framework:collaborative-judgment`. The writes before this point (the frame, each scenario) need only the checks a `draft` requires — do not flag advisories on a spec still in progress.

**Updating an existing file** → edit it in place: keep every `## Links` line that is not a template placeholder, and keep its `status` — except that changing the scope, scenarios, or ACs of an `approved` spec sets it back to `draft` until Step 6 re-approves it. The file has a `- Design:` link that is not the template placeholder → tell the user the linked design was made from the earlier spec and may need `/design-blueprint` to reopen it.

**STOP:** Do not advance to the next feature until the current one is confirmed complete, checked, and written.

---

### Step 6: Refresh Generated Views

Run this step once the features in this session's scope are written — or when the user stops early, for those written so far (the rest stay in `## Planned Features`). Regenerate the derived sections — never hand-edit them:

- **For each epic touched this session**: regenerate `epics/{epic-slug}.md`'s feature table by scanning every `features/*.md` file where `epic` matches, listing feature name and one-line summary only. **Do not read or mirror `status`, `priority`, or `depends_on`** — those fields live only in the feature file. Replace only the content between the generated-section boundary comments — leave the hand-authored header, Source Materials, Deferred Items, and Planned Features untouched.
- **Regenerate `index.md`'s epic-list table** the same way, scanning `epics/*.md` headers.
- **STOP: this regeneration is triggered only by a feature being added, removed, or renamed under an epic in this session, or by the resume check finding a table out of sync with the feature files — never by a status, priority, or dependency change alone.** A feature's own status/priority/depends_on edit is a single-file write with no downstream regeneration.
- **Hand-authored additions** (not generated, appended directly to the relevant epic file):
  - If source documents were provided during intake, add/update a `## Source Materials` table mapping each document to the features derived from it.
  - Add a `## Deferred Items` section listing content intentionally excluded from the current feature set, with reasons.
- If the standards include a Domain Terminology section, include a `## Glossary` section in `index.md` populated from those terms (hand-authored, not regenerated — revisit only when terminology changes).

**Approve finished specs**: take the specs finished this session (no in-progress line) that are still `draft`. Those that pass every `framework:requirement-quality` check an `approved` spec requires → ask once, for all of them: *"Mark [specs] approved — agreed and ready for design — or leave them draft for stakeholder review?"* Approved → write `status: approved` into each, a status-only edit. A spec that fails a check stays `draft`; name the check. None → skip. **STOP:** requirement-forge writes only `draft` and `approved` (or the loaded workflow's equivalents) and never changes any other status a person has set.

Present a completion summary: epics created, features specced and their status, features still in progress or planned, open questions, dependency map, and suggested next step (`/design-blueprint` on the highest-priority feature — name its feature file path so the design session can link it). Do not write the feature file's `Design:` link here — `design-blueprint` writes it when a design session starts.

---

## Autonomous Mode

**Phase 1 — Silent run (Steps 2–5)**: No confirmation gates. Log every non-obvious decision (granularity restructuring, contradiction resolutions, epic boundary calls). Format: "Decision: [what]. Reason: [why]."

Pause only for **genuine blockers** — situations where continuing would produce a fundamentally wrong spec:
- Contradictory inputs with no reasonable resolution (two documents disagree on who the user is)
- Missing domain knowledge that cannot be inferred (the molecule cannot determine which of two plausible interpretations is correct)
- Scope so ambiguous that two equally valid epic structures exist with different feature decompositions

Do NOT pause for: naming choices, priority assignments, scope boundary judgment calls, or AC wording. Make the best call and log the decision — including priority, which is assigned autonomously using the loaded standards' notation and reviewed in Phase 2.

**Phase 2 — Review**: Present the decisions log first, then the epic list, then the feature list per epic, then feature specs one by one. User corrects, adds, or removes.

**Phase 3 — Write**: Phases 1–2 write nothing. After confirmation, write all files — every feature file complete, with `status: draft` — then run Step 6 to regenerate the derived views and ask the approval question. `framework:requirement-quality` checks run before each write.
