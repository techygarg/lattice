# Architecture Compass — Interview Guide

This guide governs Step 3 of the architecture-compass molecule. It contains the four-act question framework, how to select and adapt questions from the scan findings, how to interpret answers as architectural inputs, conversation principles, and red flags to watch for.

---

## The Four-Act Arc

The interview is not a questionnaire. It is a conversation with a narrative arc. Each act has a distinct purpose. The order matters — do not reorder.

```
Act 1 — Burning Platform   Why now? What is the immediate pain?
Act 2 — History            How did you get here? What was tried?
Act 3 — Vision             What do you want to be able to do?
Act 4 — Guardrails         What cannot change? What must be protected?
```

**Acts 1 and 2 are always asked.** They establish why this session exists and what has already failed.  
**Act 3 is always asked.** It is the most important act — answers are architectural inputs, not soft context.  
**Act 4 is selective** — ask only what the scan did not already reveal.

**Total questions in practice: 5–7.** Skip any question the scan already answered. A sharp 5-question interview outperforms a thorough 10-question form.

---

## Act 1 — Burning Platform

**Purpose:** Understand why the team is acting now. What changed or what finally broke?

**Question bank (choose 1–2 based on scan findings):**

- "What finally made you decide to act on this? What changed or what broke?"
- "What is the single biggest pain the current architecture causes your team every week?"
- "If you could fix one structural thing about this codebase tomorrow, what would it be?"

**When to skip:** If the team already described the pain when invoking the molecule (e.g., "our services layer is a mess and we can't ship without breaking things"), you already have Act 1. Acknowledge it rather than re-asking.

**What to listen for:**
- Delivery pain ("we can't ship without breaking things") → dependency isolation is the priority
- Onboarding pain ("new devs take 6 weeks to be productive") → clear layers and module ownership matter most
- Maintenance pain ("every change touches 8 files") → high coupling, needs seam identification
- Team coordination pain ("we step on each other") → bounded contexts, ownership boundaries

---

## Act 2 — History

**Purpose:** Understand how the codebase got here, and what has already been tried. Previous attempts are the most important risk signal.

**Question bank (choose 1–2 based on scan findings):**

- "Has the team tried to improve this architecture before? What happened?"
- "Which parts of the codebase does the team understand well — and which are treated as a black box?"
- "Are there areas nobody wants to touch, and do you know why?"

**When to skip:** If the codebase is relatively new (scan showed consistent structure and naming), history is less relevant. Focus on the other acts.

**What to listen for:**
- "We tried this 18 months ago and stopped" → there is a specific blocker. Ask what stopped it. That blocker will stop this attempt too unless the recommended direction addresses it explicitly.
- "Nobody touches the payments module" → either high risk or poor understanding. Flag as a high-risk zone in the insights document.
- "We have a lot of legacy code from a previous team" → temporal seam likely exists. The scan should have found it.

**Red flag:** If the team mentions a previous failed attempt but cannot say what stopped it, that is a signal the same thing will happen again. Probe gently: "Was it technical complexity, time constraints, team changes, or something else?"

---

## Act 3 — Vision

**Purpose:** Understand what success looks like. This is the most important act. Answers here are architectural inputs — they directly shape the recommended direction.

**Question bank (choose 1–2):**

- "What would you be able to do after this work that you cannot do today?"
- "What does success look like six months from now? What would the team celebrate?"
- "Is there a specific architecture style you have in mind, or should I recommend based on the codebase and your goals?"

**Never skip Act 3.** A recommended direction proposed without understanding the team's vision will be technically sound and practically wrong.

**Answer interpretation table — the most critical part of this guide:**

| What the team says | What it means architecturally |
|---|---|
| "We want to onboard new devs in 2 weeks, not 6" | Explicit, named layers. Clear module ownership. Consistent naming that reveals intent. No implicit knowledge required to navigate the codebase. |
| "We want teams to work independently without stepping on each other" | Bounded contexts with clear ownership seams. Separate deployability per context if possible. Explicit contracts at context boundaries. |
| "We want to stop shipping bugs when we touch unrelated code" | Strict dependency inversion. Infrastructure depends on domain, never the reverse. Isolated modules with narrow interfaces. |
| "We want to add new features without full regression testing" | Testable boundaries. Ports and adapters pattern. Side-effect-free domain logic. |
| "We want the codebase to be easier to reason about" | Reduce coupling. One responsibility per module. Dependency direction that matches mental model (top-down, not tangled). |
| "We want to move faster" | Reduce coupling first — high coupling is the primary velocity killer. Then clear layer boundaries so work can proceed in parallel. |
| "We want to be able to delete old code safely" | Explicit module interfaces. Nothing depending on internals. Clear ownership so blast radius is known before deletion. |
| "We want a clean foundation before the next big initiative" | Minimum viable architecture improvement — enough structure to build confidently, not a complete rewrite. |

**Important:** The recommended direction in Step 5 must visibly respond to what was said in Act 3. If the team said "we want to onboard new devs faster," the recommended direction should explicitly state how the proposed structure addresses that. Generic architecture proposals that ignore the stated vision will not be adopted.

---

## Act 4 — Guardrails

**Purpose:** Understand what cannot change. Asked last — not because it matters least, but because asking about constraints too early makes teams self-limit before they have articulated their vision.

**Question bank (choose 1–2, only if not answered by the scan):**

- "Are there any modules or areas that are intentionally off-limits for this work?"
- "Are there implicit contracts with external systems that are not visible in the code — verbal agreements with other teams, shared databases, undocumented integrations?"
- "Must the system remain fully deployable throughout this work, or can it be in a transitional state?"

**When to skip:** If the scan found clear external integration points and the directory structure shows obvious ownership, Acts 4 questions may be redundant. Skip them and confirm assumptions in the current state presentation instead.

**What to listen for:**
- "The payments module is off-limits this quarter" → mark explicitly in the Gap Assessment as deferred with reason.
- "We have a verbal agreement with Team X that we won't change the user API" → hidden contract, must be captured in the insights document as a constraint.
- "We can't take the system down" → strangler fig approach is required for any structural changes. Layer-by-layer rewrite is not an option.

---

## Conversation Principles

**1. Arrive with views, not a blank form.**
The scan gives the AI a hypothesis before the interview starts. Questions should feel like "I found X in the scan and want to understand if that's accurate" — not "tell me about your codebase." This builds trust and makes the conversation efficient.

**2. Reference the scan in questions.**
"I noticed your `services/` directory contains both business logic and database calls — is that drift or intentional?" is a better question than "how is your architecture structured?" The team feels heard rather than interrogated.

**3. Listen for the real pain behind the stated pain.**
"We can't ship without breaking things" often means "we have no seams — everything depends on everything." "We move slowly" often means "we don't understand our own codebase well enough to refactor confidently." Listen for the structural root cause, not just the symptom.

**4. Do not ask what can be inferred.**
If the language and framework are obvious from the scan, do not ask. If the module structure is clear, do not ask about it. Reserve every question for signal the code cannot provide.

**5. Acknowledge what was already said.**
If the team described their pain when invoking the molecule, reference it rather than re-asking. "You mentioned you can't ship without breaking things — can you tell me more about what typically breaks?" is better than asking a fresh version of the same question.

**6. Keep Acts 1–3 before Act 4.**
Teams who are asked about constraints first will self-limit. Let them articulate the pain and vision first, then introduce the guardrails. The order produces better, less constrained thinking.

**7. Probe vague answers once.**
If an answer doesn't map to any row in the interpretation table (e.g., "it's slow", "it's messy", "yes"), reframe with a scan-informed hypothesis: *"When you say it's slow — do you mean deployment is slow (coupling), local development is slow (build complexity), or shipping features is slow (unclear ownership)?"* Accept whatever the user provides after one probe — do not interrogate. If the answer remains vague after one probe, record the literal answer and move on.

---

## Red Flags

These patterns in interview answers signal elevated risk. Record them explicitly in the insights document.

| Answer pattern | Risk | What to do |
|---|---|---|
| "We tried this X months ago and it didn't work" | The same blocker will likely recur | Ask what stopped it. Name the blocker explicitly in the recommended direction. |
| "Nobody really understands that module" | High regression risk during any structural change | Flag as a low-understanding zone. Recommend characterisation tests before any changes in that area. |
| "We'll refactor it eventually, it's fine for now" | Low motivation — the work will stall | Ensure the burning platform (Act 1) is genuinely painful enough to sustain effort. If not, the session may produce a document nobody acts on. |
| "We just need to clean it up a bit" | Scope underestimation | Be specific about what "clean it up" means structurally. Vague scope produces vague direction. |
| "The team lead is the only one who understands this area" | Bus factor and knowledge silo risk | Note in insights document. Recommend knowledge transfer as a precondition to structural changes in that area. |
| "We're planning a full rewrite anyway" | Competing initiative — this session may be redundant | Clarify the timeline and scope of the rewrite. If it is imminent and covers the same ground, this session may be better scoped to the rewrite's boundaries. |
