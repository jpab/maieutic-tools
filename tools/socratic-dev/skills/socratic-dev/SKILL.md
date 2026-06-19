---
name: socratic-dev
description: Guided agentic development loop. Surfaces ambiguities, checks the task is plannable, forces an option choice, and waits for explicit plan approval before any write-capable agent runs.
version: 0.2.0
author: jpab
---

# socratic-dev

A guided development loop. You ask before you act. You propose before you build. You wait for approval before you implement. The developer is the architect; you are the executor.

## Invocation

Three ways to call this skill:

```
/socratic-dev "<ticket description>"         — start a new session
/socratic-dev --resume <session-name>        — continue a paused session
/socratic-dev --close <session-name>         — close a completed session (optional critic)
```

---

## Agent topology and the boundary that makes the loop safe

This skill is orchestrated by you, the main session. You delegate the heavy phases to subagents and you own every write to `.socratic/`.

The loop has one structural guarantee: **no write-capable agent runs before the developer has approved the full plan.** This is not a prose promise the implementation agent makes to itself — it is enforced by tool grants.

- `task-context`, `task-evaluator`, `codebase-context`, and `ideation` are **read-only by grant** (`tools: [Read, Grep, Glob]`). They cannot edit code. They return structured markdown; **you** persist it to the session and plan files.
- `implementation` is the **only** write-capable agent. You do not invoke it until both approval gates below have passed.
- `critic` is **read-only** and **on-demand**. At any of the three gates the developer may ask for it before deciding — see "Invoking the critic" below.

The flow, with both gates explicit:

```
task-context (questions)
  → [developer answers]
  → task-evaluator (sufficiency gate — halts on thin input)
  → codebase-context
  → ideation (named options-comparison + recommendation)
  → [GATE 1: developer approves an option]        ← critic available (option-choice)
  → orchestrator writes the full plan
  → [GATE 2: developer confirms the full plan]     ← critic available (plan)
  → implementation (the only write-capable agent)
  → [--close: optional critic on the diff]         ← critic available (diff)
```

These gates and the read-only/write boundary are unconditional. Do not collapse them, and do not invoke `implementation` early because the task looks small. The critic never blocks — it produces a record the developer reads and decides on.

---

## Starting a new session

### Step 0 — Environment pre-flight

Before anything else, run:

```bash
git status -sb
```

Check for three conditions and report findings to the developer:

1. **Branch** — if on `main` or `master`, warn explicitly: "You are on the main branch. Starting a session here will implement directly on main. Confirm, or switch to a feature branch first."
2. **Uncommitted changes** — if the working tree has modifications or staged changes, warn: "There are uncommitted local changes. These will be visible to codebase-context and may skew the analysis. Stash, commit, or confirm you want to proceed."
3. **Behind remote** — if git reports the branch is behind its upstream (e.g. `## main...origin/main [behind 3]`), warn: "Your branch is behind the remote. codebase-context will read stale code. Pull first, or confirm you want to proceed."

If all three are clean, say so in one line and continue. If any condition is present, stop and wait for the developer to confirm or resolve before proceeding. Do not proceed on an unacknowledged warning.

---

### Step 1 — Name the session

Ask the developer for a short slug name for this session (e.g. `add-rate-limiting`). All session files will use this name. Do not proceed until you have it.

Create `.socratic/` in the project root if it does not exist. Add `.socratic/` to `.gitignore` if not already present.

Create `.socratic/<session-name>.md` with this structure:

```markdown
# Session: <session-name>

## Ticket
<ticket description>

## Status
questions-pending

## Product questions
<!-- to be filled -->

## Engineering questions
<!-- to be filled -->

## Answers
<!-- to be filled -->

## Task evaluation
<!-- to be filled -->

## Codebase context
<!-- to be filled -->

## Selected option
<!-- to be filled -->

## Plan confirmed
<!-- to be filled -->

## Implementation notes
<!-- to be filled -->
```

**Status values** the session moves through:
`questions-pending` → `clarification-pending` (only if the evaluator halts) → `option-pending` → `plan-pending` → `implementation-pending` → `done-pending-close` → `closed`.

### Step 2 — Questions phase (`task-context`)

Invoke the `task-context` subagent with the ticket description. It is read-only and returns two labelled sets of questions:

**Product questions** — for the Product or Business owner, not the developer. They are about customer/user impact, business goals, and strategic scope — the "what" and "why", not the "how". A product question can be answered by a product manager with no technical knowledge. Examples: "What should happen to a user who hits the limit — are they blocked, degraded, or notified?" / "Is self-service limit increase in scope, or is that a future request?" / "What business goal does the rate limit serve — cost control, abuse prevention, fair use?"

**Engineering questions** — for the developer. Technical unknowns that codebase-context cannot answer by reading the code alone. Examples: "Is there an existing middleware chain the limit should slot into?" / "Are there internal services that should be exempt from the limit?"

Present both sets to the developer in a single response. Record them in the session file under `## Product questions` and `## Engineering questions` — **you** write the file; the subagent does not.

After the developer answers, record the answers under `## Answers`. Proceed to Step 3.

If the developer cannot answer a product question yet, stop here. Leave `## Status` at `questions-pending` and tell them to call `--resume <session-name>` when ready. Do not proceed on incomplete information.

### Step 3 — Sufficiency gate (`task-evaluator`)

Before reading any code, invoke the `task-evaluator` subagent with the ticket description and the answered questions. It is read-only and does not analyse the codebase — it only judges whether the inputs are specific enough to plan against.

- If it returns `verdict: sufficient` — record a one-line note under `## Task evaluation` and proceed to Step 4.
- If it returns `verdict: insufficient` — record the gaps and clarifying questions under `## Task evaluation`, set `## Status` to `clarification-pending`, and present the clarifying questions to the developer. Collect their answers, append them under `## Answers`, then re-run the evaluator. If the developer cannot answer yet, stop and tell them to `--resume` when ready.

This gate prevents the loop from silently planning against thin input. It is lightweight — a false halt costs one round-trip, a missed gap costs a wrong plan.

### Step 4 — Context gathering (`codebase-context`)

Once the task is sufficient, invoke the `codebase-context` subagent with the ticket, the answered questions, and the session file path. It is read-only. It reads the wiki (if `wiki/` exists, starting with `wiki/README.md`, `wiki/architecture.md`, `wiki/glossary.md`, and relevant `wiki/decisions/`) before the source, then the relevant source files, configuration, and documentation.

It returns a structured technical summary: relevant existing code, established patterns, real constraints, answers to the engineering questions, and any short list of genuinely open technical questions. **Persist this summary to the session file under `## Codebase context`** — ideation needs it now, and the orchestrator needs it again at Gate 1 (to expand the plan) and to supply the critic at Gates 1 and 2, which may happen in a later session via `--resume`. Set `## Status` to `option-pending` once context gathering is done.

### Step 5 — Options-comparison (`ideation`)

Invoke the `ideation` subagent with the ticket, the answered questions, the `task-context` output, and the `codebase-context` output. It is read-only and returns a named options-comparison — 2-3 meaningfully different approaches, each a paragraph (tradeoffs and assumptions explicit), plus a recommendation that names what would flip the choice.

**You** write the returned output to `.socratic/<session-name>-plan.md`:

```markdown
# Plan: <session-name>

## Options

### Option 1 — <short title>
<paragraph>

### Option 2 — <short title>
<paragraph>

### Option 3 — <short title> (if applicable)
<paragraph>

## Recommendation
Option <N> — <why, and what would flip it>
```

Tell the developer this file has been written and can be committed or shared. Leave `## Status` at `option-pending`.

Stop here. Wait for `--resume`. **GATE 1 is the developer choosing an option** — do not write the full plan or invoke any write-capable agent yet.

---

## Resuming a session (`--resume`)

Read `.socratic/<session-name>.md` to determine the current status and act on it:

- `questions-pending` — re-display the unanswered questions (re-invoke `task-context` if needed). Collect answers, record them, then proceed to Step 3 (sufficiency gate).
- `clarification-pending` — re-display the evaluator's clarifying questions. Collect answers, append under `## Answers`, then re-run `task-evaluator` from Step 3.
- `option-pending` — **GATE 1.** Re-display the options-comparison from the plan file and ask which option the developer chooses. See "Option approval" below.
- `plan-pending` — **GATE 2.** Re-display the full plan from the plan file and ask for final confirmation to implement. See "Plan confirmation" below.

### Option approval (GATE 1)

When you present the options-comparison, tell the developer they can type `critic` to get an adversarial review of the options before choosing (see "Invoking the critic" — use `review_target: option-choice`).

The developer picks an option by number, types `critic`, or pushes back with modifications.

- If they type `critic`, run it, append its block to the plan file, and re-present this gate. Do not choose for them.
- If they modify an option, acknowledge what changed and confirm the modified option back to them in one sentence.
- Record the chosen option (and any modification) in the session file under `## Selected option`.

Then **write the full plan**. Read `## Codebase context` from the session file to ground it (re-run `codebase-context` and persist it only if that section is empty). Expand the chosen option into a concrete implementation plan — still prose, not a checklist — covering the approach, the files and patterns it will touch, what it deliberately leaves out, and any decision the developer should know is being made. Append it to the plan file:

```markdown
## Selected plan
<full plan prose for the chosen option>
```

You are the orchestrator writing a planning file — this is not a code write and does not breach the write-capable-agent boundary. Do not invoke the `implementation` agent here.

Set `## Status` to `plan-pending`. Present the full plan to the developer and stop. **GATE 2 is the developer confirming this full plan.**

### Plan confirmation (GATE 2)

When you present the full plan, tell the developer they can type `critic` to get an adversarial review of the plan before confirming (see "Invoking the critic" — use `review_target: plan`).

The developer confirms the full plan, types `critic`, or pushes back with modifications.

- If they type `critic`, run it, append its block to the plan file, and re-present this gate. Do not confirm for them.
- If they modify it, acknowledge what changed, rewrite the `## Selected plan` section, confirm it back in one paragraph, and ask for explicit confirmation again. Do not proceed on an unconfirmed plan.
- Once confirmed, record the confirmation under `## Plan confirmed` in the session file and set `## Status` to `implementation-pending`.

### Step 6 — Implementation (`implementation`)

Only now invoke the `implementation` subagent — the **only** write-capable agent in the loop. Pass it the ticket, the answered questions, the confirmed `## Selected plan`, any developer annotations, and the `## Codebase context` summary from the session file (which persists across `--resume` sessions).

It executes the approved plan and does not deviate without surfacing the deviation and asking for guidance. As it implements, it records decisions made that were not in the plan (unavoidable choices, discovered constraints) under `## Implementation notes` in the session file.

When implementation is complete, set `## Status` to `done-pending-close`. Tell the developer to call `--close <session-name>` to complete the loop.

---

## Closing a session (`--close`)

Read `.socratic/<session-name>.md`. Confirm status is `done-pending-close`.

### Step 7a — Optional critic

Ask the developer whether they want an adversarial review of what was built against the approved plan:

```
Run the critic before closing? It diffs the implementation against the approved
plan and flags divergences and unresolved questions. (y / n)
```

If yes, invoke the critic with `review_target: diff` (see "Invoking the critic"). Pass the base ref/branch to diff against, or an instruction to diff the working tree. Append the returned `## CRITIC_REVIEW` block to the plan file. This close-time review is the session's record of plan-vs-implementation drift.

If no, skip to Step 7b.

### Step 7b — Handoff

Generate a structured handoff — a short markdown summary:

```markdown
## What was built
<1-2 sentences>

## Decisions made
<bullet list of decisions locked in during implementation that belong in ADRs>

## Technical debt introduced
<bullet list, or "none" if clean>

## Runbook changes needed
<bullet list, or "none">
```

If `wiki-maintain` is available (anamnesis-wiki is installed), invoke it with this handoff and the path to the session file. Tell the developer the wiki is being updated.

If `wiki-maintain` is not available, display the handoff and suggest installing anamnesis-wiki to automate this step.

Update `## Status` to `closed`. The session is complete.

---

## Invoking the critic

The `critic` is an on-demand, read-only adversarial reviewer available at all three decision gates. It does not validate or summarise — it produces a structured falsification attempt grounded in verbatim quotes. The developer triggers it; you never run it unprompted (except offering it at `--close`).

| Gate | When | `review_target` | What it reviews |
|---|---|---|---|
| Option choice | GATE 1, status `option-pending` | `option-choice` | the `## Options` + `## Recommendation` |
| Plan | GATE 2, status `plan-pending` | `plan` | the `## Selected plan` for the chosen option |
| Diff | `--close`, Step 7a | `diff` | the implementation diff vs the approved plan |

When triggered, spawn the `critic` subagent with:
- The `review_target` for that gate.
- The session file path and the plan file path.
- For `option-choice` and `plan`: the `## Codebase context` summary from the session file (read it from disk — do not rely on it still being in your context, since the gate may be reached in a later `--resume` session). If that section is empty (a session started before it was persisted), re-run `codebase-context` first and persist it. For `diff`: the base ref/branch.
- **Already-flagged concerns (headlines only)** — if the developer has already run the critic at this same gate, pass the headlines of those prior `## CRITIC_REVIEW` blocks so it does not repeat them. Pass headlines only, never the full prior critique.

When it returns:
1. **Append** its `## CRITIC_REVIEW` block to `.socratic/<session-name>-plan.md` — append, never overwrite. Multiple invocations at the same gate stack.
2. Re-present the original gate prompt. The developer decides what to do with the critique on their own.

The critic never returns a "blocked" status and never makes the choice. If the developer rebuts a concern, append their text as a `### Developer response` under the most recent `## CRITIC_REVIEW` block — that record is visible to `--close`.

---

## Rules that apply throughout

- The read-only/write boundary is structural, not advisory: never invoke `implementation` (the only write-capable agent) before GATE 2 has passed. Every other agent is read-only by grant.
- The orchestrator owns every write to `.socratic/`. Read-only subagents return markdown; you persist it.
- Never skip the sufficiency gate, the option gate, or the plan-confirmation gate because the task looks small.
- Never assume an answer to a question — surface it.
- Never auto-close the loop — `--close` is always a deliberate developer action.
- The critic is on-demand and never blocks: offer it at `--close`, honour it whenever the developer types `critic` at a gate, append its block, and re-present the gate. Never let it make the developer's decision.
- If the wiki exists, `codebase-context` always reads it before source.
- Keep all responses factual and direct. No hype, no filler, no unsolicited suggestions outside the current phase.

## On non-Claude-Code platforms

The subagents above are the Claude Code multi-agent layer. On platforms without subagents, a single agent follows the same methodology in sequence — but the tool-grant boundary becomes behavioural rather than structural. There, the agent must hold the read-only/implement separation by discipline: do not edit code until both gates have passed. The structural guarantee is only as strong as the platform; on Claude Code it is enforced by grant.
