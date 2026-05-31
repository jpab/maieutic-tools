---
name: socratic-dev
description: Guided agentic development loop. Surfaces ambiguities, proposes plans, waits for developer approval before implementing anything.
version: 0.1.0
author: jpab
---

# socratic-dev

A guided development loop. You ask before you act. You propose before you build. You wait for approval before you implement. The developer is the architect; you are the executor.

## Invocation

Three ways to call this skill:

```
/socratic-dev "<ticket description>"         — start a new session
/socratic-dev --resume <session-name>        — continue a paused session
/socratic-dev --close <session-name>         — close a completed session
```

---

## Starting a new session

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

## Plan selected
<!-- to be filled -->

## Implementation notes
<!-- to be filled -->
```

### Step 2 — Questions phase

Before reading any code, identify what you do not know. Produce two clearly labelled sets of questions in a single response to the developer:

**Product questions** — gaps in the ticket that would prevent good planning. These are about goals, acceptance criteria, user-facing behaviour, constraints from the business side. Examples: "What is the rate limit — requests per minute, per hour?" / "What should happen when a user hits the limit — 429 with retry-after, or silent queue?"

**Engineering questions** — technical unknowns that would force an assumption during planning. These are about the codebase, existing patterns, constraints from the technical side. Examples: "Is there an existing middleware chain the limit should slot into?" / "Are there internal services that should be exempt?"

Rules:
- Ask only questions that genuinely affect which plan is best. Do not pad.
- Keep each question to one sentence.
- Do not ask questions whose answers are clearly in the ticket.

After the developer answers, record the answers in `.socratic/<session-name>.md` under `## Answers`. Update `## Status` to `context-pending`.

If the developer cannot answer a product question yet, stop here. Tell them to call `--resume <session-name>` when ready. Do not proceed to context gathering on incomplete information.

### Step 3 — Context gathering

Read the codebase. Focus on what is relevant to the ticket and the questions answered. If `wiki/` exists in the project root, read `wiki/README.md`, `wiki/architecture.md`, `wiki/glossary.md`, and any relevant files in `wiki/decisions/` first — this is your map before you read the territory.

Then read the relevant source files, configuration, and any existing documentation.

Your goal is to understand: what already exists that this ticket touches, what patterns are established, and what constraints are real versus assumed.

### Step 4 — Planning

Propose 2–3 plans. Each plan must be a short paragraph — not a bullet list. Cover: what the approach is, what it trades away, and what it assumes. Make the tradeoffs explicit. Do not recommend a plan; present the options and let the developer choose.

Write the plans to `.socratic/<session-name>-plan.md`:

```markdown
# Plan: <session-name>

## Option 1 — <short title>
<paragraph>

## Option 2 — <short title>
<paragraph>

## Option 3 — <short title> (if applicable)
<paragraph>
```

Tell the developer this file has been written and can be committed or shared. Update `## Status` to `plan-pending` in the session file.

Stop here. Wait for `--resume`.

---

## Resuming a session (`--resume`)

Read `.socratic/<session-name>.md` to determine the current status.

- `questions-pending` — the developer has answers to provide. Re-display the unanswered questions and collect the answers. Then proceed to Step 3.
- `plan-pending` — the developer is ready to approve a plan. Re-display the plans from `.socratic/<session-name>-plan.md` and ask which they choose.

### Plan approval

The developer picks an option by number, or pushes back with modifications. If they modify:
- Acknowledge what changed.
- Confirm the modified plan back to them in one paragraph.
- Ask for explicit confirmation before proceeding.

Once a plan is confirmed, record it in `.socratic/<session-name>.md` under `## Plan selected`. Update `## Status` to `implementation-pending`.

### Step 5 — Implementation

Execute the approved plan. You have: the ticket, the answered questions, the codebase context, and the confirmed plan. Do not deviate from the plan without surfacing the deviation and asking for guidance.

As you implement, note any decisions made that were not in the plan (unavoidable choices, discovered constraints). Record these in `## Implementation notes` in the session file.

When implementation is complete, update `## Status` to `done-pending-close`. Tell the developer to call `--close <session-name>` to complete the loop.

---

## Closing a session (`--close`)

Read `.socratic/<session-name>.md`. Confirm status is `done-pending-close`.

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

## Rules that apply throughout

- Never implement anything before a plan has been explicitly approved.
- Never assume an answer to a question — surface it.
- Never auto-close the loop — `--close` is always a deliberate developer action.
- If the wiki exists, always read it before reading source code.
- Keep all responses factual and direct. No hype, no filler, no unsolicited suggestions outside the current phase.
