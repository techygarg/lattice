---
sidebar_label: Verification
description: Why verification runs as an isolated subagent instead of a slash command, and the cost model behind that choice.
---

# Verification: Design Rationale

Why the verifier exists, the cost model behind it, and how to wire it into your own sessions.

> **Audience**: Teams deciding whether to adopt Lattice's verification gate, and anyone wondering why it's a subagent instead of a slash command. Motivation is coming from : [The Orchestrator Tax](https://martinfowler.com/articles/orchestrator-tax.html)

---

## The Problem

Confirming a change actually works usually means running the project's build/test commands in the main session. Two failure modes follow from that:

- **On green**, the full stdout of every stage — build noise, dependency resolution, hundreds of passing test names — lands in the main session's context anyway, paid for whether or not anyone will ever look at it.
- **On red**, the session either re-reads that same noisy output to find the one line that matters, or gives up and pastes the whole thing back to itself.

Either way, the cost of "did this work?" scales with how noisy the tooling is, not with how useful the answer is.

## The Hypothesis

> **A pass/fail check should cost almost nothing when it passes, and only the price of what's actually needed when it fails.**

Verification is deterministic — it needs no judgment, no creativity, no large context window. It needs: run the configured commands, in order, report what happened. That's a job for a script, not for the reasoning session's full attention. Wrapping the script in a lightweight subagent adds a second cost win wherever the host supports one: the run happens in an isolated context, and only a small structured verdict — never the run itself — touches the main session.

## The Philosophy

1. **Deterministic execution owns the run, not the agent.** `scripts/run-verification.sh` (the portable core) owns config parsing, iteration, stop-on-first-failure, and logging. The `verifier` subagent (`agents/verifier.md`, a host adapter) never reimplements that control flow, never greps a log for a root cause, never guesses why something failed. It runs the script once and reports what's already on disk.

2. **The file is the interface, not stdout.** Every stage's full output goes to `<runsDir>/<runId>/<stage>.log`. stdout carries only marker lines and ids — never log content — so the isolation guarantee holds at the shell layer, before an agent is even involved. The mechanical facts — status, exit code, duration, log path per stage — plus the run-level verdict (`overallStatus`, `failedStages`, `headline`) all live in `summary.json`, written by the script itself.

3. **The script is the source of truth for the verdict, not the agent.** `overallStatus`, `failedStages`, and `headline` are computed once, in the script, from data the stage loop already has — never re-derived by the subagent. This is what makes the two invocation paths equivalent: a human running the script directly and a subagent running it on their behalf reach the same file with the same verdict already in it. The subagent's only job is to run the script inside an isolated context and hand the file back unchanged — it never opens a `logFile`, and it never recomputes anything the file already states. On red, the calling session gets the failing stage's name and its `logFile` path, and opens that file itself, on its own terms, only if the verdict isn't enough.

4. **Nothing is wired in automatically.** No molecule calls the verifier as part of its own workflow, and installing Lattice does not turn this on by itself. It's independent, opt-in infrastructure — see [Host Portability](https://github.com/techygarg/lattice/blob/main/PROJECT.md#host-portability) for why shared behavior stays out of host adapters. A team that doesn't want an automated gate is never forced into one.

Point 3 is also the direct answer to a natural question: why bother with a subagent at all, if you could just run the script yourself? Because both paths read the exact same file. The subagent adds isolation — the run's stdout and the file Read happen off in their own context, so only this small JSON blob crosses back into the session that asked for it — never a second, smarter opinion about what the file means.

## How It's Set Up

`/lattice-init` offers verification setup whenever `.lattice/verification.yaml` or the vendored script is missing — declining is a supported outcome; many projects won't want automated gating, and nothing else in Lattice depends on it existing. Accepting produces three things in the project, in order: a confirmed `.lattice/verification.yaml` built from detected stack commands, a vendored copy of the runner at `.lattice/scripts/run-verification.sh`, and (if agreed) the gate block below appended to the project's instruction file. Exact step-by-step behavior lives in `lattice-init`'s own SKILL.md (Step 8) — treat that as the source of truth if this summary and that file ever disagree.

Two host-specific details worth knowing going in, since they're easy to get wrong by hand:

- **Vendoring the script** copies from wherever Lattice is actually installed, never a guessed path: `$CLAUDE_PLUGIN_ROOT/scripts/run-verification.sh` on a Claude Code plugin install; on a Codex plugin install, a relative path from `lattice-init`'s own skill file, since Codex ships `scripts/` as an undeclared sibling of `skills/` with no plugin-root environment variable equivalent to `$CLAUDE_PLUGIN_ROOT`; the repo root in a Lattice dev checkout.
- **Wiring the gate** targets `CLAUDE.md` on Claude Code, `AGENTS.md` on Codex or another AGENTS.md-convention host. A project with both files already present gets the block appended to both, since either host might read that project later.

```markdown
<!-- lattice:verification -->
Before declaring any work done, run this project's verification suite (.lattice/verification.yaml): spawn the `verifier` subagent when the host supports subagents; otherwise run `.lattice/scripts/run-verification.sh .lattice/verification.yaml` and read summary.json from the printed run directory. Green → reply in one line. Red → headline, failed stage name(s), their log paths; never open or paste a log into the session. Never mark work complete while any stage fails.
<!-- /lattice:verification -->
```

Because this is plain instruction text in a file every host already reads at session start, the same block works identically across hosts — no per-tool integration code, no plugin required. Declining the gate step still prints the block so it can be pasted in by hand later.

## How It Runs, Per Host

Once the config and the vendored script exist, "run verification" always resolves to the same underlying call: `bash .lattice/scripts/run-verification.sh .lattice/verification.yaml`, then read `summary.json`. What differs by host is who makes that call, and how isolated it is:

- **Claude Code** — `agents/verifier.md` is auto-discovered from the `agents/` directory, a Claude Code plugin convention. A session can spawn it as a subagent: the Bash call and the file Read happen inside the subagent's own context, so only the small JSON verdict crosses back into the calling session.
- **Codex, or any host with no subagent primitive** — there is nothing to spawn, so the session itself runs the script and reads `summary.json` inline, in its own context. Same file, same verdict, no isolation hop — this is the "otherwise" branch in the gate block above, and for Codex it is the *only* branch, always.

This applies identically whether verification is triggered manually (you ask the session to run it) or automatically (the gate block above fires on its own before work is declared done) — the gate text is host-agnostic, so it produces the correct behavior on either host without modification.

## What Goes in `.lattice/verification.yaml`

The config lists your project's real checks, in the order they should run. Each stage is a name plus one shell command — `/lattice-init` proposes this from the detected stack, but the shape is simple enough to hand-write:

```yaml
version: 1
# runsDir is optional; defaults to tmp/verification if omitted
stages:
  - name: unit
    command: npm test
  - name: integration
    command: npm run test:integration
```

Two stages is a reasonable minimum: something fast and narrow (`unit`) that catches most regressions, and something slower and broader (`integration`) that only needs to run if the fast one already passed. Add a `build` stage before both if your project needs a compile step first — verification always stops at the first failed stage, so ordering cheapest-and-most-likely-to-fail first saves the most time. Fold anything stage-specific — a working directory, a timeout, an env var — directly into that stage's `command` string; the schema stays exactly `name` + `command`, nothing more. Full schema reference: the header comment in `scripts/run-verification.sh`.

Comments must be their own line — the parser doesn't strip a trailing `# ...` from the end of a value line, so `runsDir: tmp/verification   # default` would silently fold the comment text into the path itself.

## What It Is Not

- Not a code reviewer — see [Framework Intelligence](../framework-intelligence.md) for the atom-level quality checks that run before this.
- Not a check-chooser — stages come entirely from `.lattice/verification.yaml`, which you write.
- Not a fixer — a failed stage is reported, never patched.
- Not mandatory — many projects will decline verification setup entirely at `/lattice-init`, and that is a supported outcome.
