# socratic-dev

A guided agentic development loop that keeps you in control of every significant decision.

You bring a ticket. socratic-dev brings questions, context, and options — in that order. Nothing gets implemented until you've seen the plans and chosen one. The plan is a file you can commit, share with your team, and discuss before a line of code is written. When you're ready, you resume. When implementation is done, you close.

---

## How it works

### Input

Invoke with a ticket description — a product-level summary of what needs to be built. Not a technical spec; that's what the loop surfaces.

```bash
/socratic-dev "Add rate limiting to the public API endpoints"
```

You'll be asked to give the session a name. This becomes the slug for all session files.

### Questions phase

Before any context gathering begins, socratic-dev surfaces two sets of questions in a single prompt:

**Product questions** — gaps in the ticket that would block planning. What counts as the limit? Per user, per IP, per API key? What's the expected behaviour when the limit is hit?

**Engineering questions** — technical constraints and tradeoffs the plans need to account for. Is there an existing middleware layer? Are there services that should be exempt?

Most of the time you already know the answers — you started the ticket, after all. Answer them in the session and the loop continues. If a product question needs input from someone else, use `--resume` to come back once you have the answer.

```bash
/socratic-dev --resume add-rate-limiting
```

### Context gathering

Once questions are answered, two specialist agents run in parallel:

- **business-context** — understands the ticket, the product goals, and what done looks like
- **codebase-context** — reads the repo, the wiki (if present), and the relevant code paths

Both agents are given everything they need to reason clearly. Neither proceeds if it has open questions — the questions phase ensures they don't.

### Planning

socratic-dev proposes 2–3 concrete plans. Each plan is a paragraph: what the approach is, what it trades away, and what it assumes. Not a bullet list of steps — a reasoned option.

The plans are written to `.socratic/<session-name>-plan.md`. This file is yours to commit, open in a PR, share with your team, or paste into a Slack thread. The plan exists as an artifact before implementation begins — that's intentional.

```
.socratic/
├── add-rate-limiting.md        ← session state
└── add-rate-limiting-plan.md   ← the plans, committable
```

Take the time you need. When you're ready to move forward:

```bash
/socratic-dev --resume add-rate-limiting
```

### Approval

Pick a plan by number. Or push back: "I like option 2 but I want to avoid touching the auth middleware." The loop holds until you've committed to a direction. You can negotiate a modified plan or a new one entirely.

### Implementation

The implementation agent executes the approved plan. It has the ticket context, the codebase context, the plan, and your annotations. It does not improvise.

### Closing the loop

When implementation is complete, call `--close`:

```bash
/socratic-dev --close add-rate-limiting
```

This generates a structured handoff — what was built, what decisions were locked in, any technical debt introduced — and calls `wiki-maintain` to update the codebase wiki. If anamnesis-wiki is not installed, it logs a recommendation and exits cleanly.

---

## Install

```bash
npx skills add jpab/maieutic-tools/tools/socratic-dev
```

Or as part of the full collection:

```bash
npx skills add jpab/maieutic-tools
```

---

## Claude Code: multi-agent mode

On Claude Code, the `.claude/agents/` definitions in this directory activate a multi-agent layer. The orchestrator delegates to four specialist subagents:

| Agent | Role |
|---|---|
| `task-context` | Reads the ticket, asks the questions, owns the session state |
| `codebase-context` | Reads the repo, the wiki, and the relevant code paths |
| `ideation` | Proposes plans based on both context agents' output |
| `implementation` | Executes the approved plan, produces the handoff summary |

Each subagent runs with scoped permissions. `codebase-context` and `task-context` run in parallel after the questions phase. `ideation` runs after both complete. `implementation` runs after you approve a plan.

On other platforms, a single agent follows the same methodology in sequence. The experience is capable; the Claude Code version is faster and more precise.

---

## Pairing with anamnesis-wiki

socratic-dev works standalone, but it's designed to pair with [anamnesis-wiki](../anamnesis-wiki/).

When the wiki exists, `codebase-context` reads it first — `wiki/architecture.md`, `wiki/decisions/`, and `wiki/glossary.md` give it structured understanding of the codebase before it reads a line of code. Planning gets faster and more accurate as the wiki grows.

When you call `--close`, `wiki-maintain` updates the wiki with what changed — new ADRs, debt entries, runbook additions. The wiki gets smarter with every loop.

If you have both installed, run `wiki-bootstrap` on your codebase before your first socratic-dev session.

---

## Session files

socratic-dev saves session state to `.socratic/` in your project root. You name the session when you start.

```
.socratic/
├── add-rate-limiting.md        ← session state (questions, answers, context, decisions)
└── add-rate-limiting-plan.md   ← proposed plans — commit this, share it, discuss it
```

Add `.socratic/` to your `.gitignore` — or selectively commit the plan files. That's up to you.
