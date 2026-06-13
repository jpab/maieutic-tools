# socratic-dev

A guided agentic development loop that keeps you in control of every significant decision.

You bring a ticket. socratic-dev brings questions, a sufficiency check, context, and options — in that order. Nothing gets implemented until you've chosen an option and confirmed the full plan. The plan is a file you can commit, share with your team, and discuss before a line of code is written. When you're ready, you resume. When implementation is done, you close — optionally with an adversarial critic that checks what was built against what was approved.

The loop's central guarantee: **no write-capable agent runs before you've approved the plan.** This isn't a promise the implementation agent makes to itself — every agent except the implementer is read-only *by tool grant*. The gate is structural.

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

### Sufficiency check

Before any code is read, a lightweight `task-evaluator` asserts that the ticket plus your answers are specific enough to plan against. If the task is too thin — a direction with no definition of done, an undrawn scope boundary — it surfaces a short list of targeted clarifying questions and halts rather than planning against guesswork. If the task is plannable, it gets out of the way. A false halt costs one round-trip; a missed gap costs a wrong plan.

### Context gathering

Once the task is sufficient, `codebase-context` reads the repo — the wiki first (if present), then the relevant code paths — and reports the technical landscape: what exists, what patterns are established, what constraints are real versus assumed. It's read-only.

### Options and the two gates

`ideation` produces a named options-comparison: 2–3 meaningfully different approaches, each a paragraph (tradeoffs and assumptions explicit), plus a recommendation that names what would flip the choice. This is written to `.socratic/<session-name>-plan.md` — yours to commit, open in a PR, or paste into a Slack thread.

**Gate 1 — pick an option.** Resume and choose one by number, or push back: "I like option 2 but avoid touching the auth middleware." Once you've chosen, socratic-dev expands that option into a full implementation plan and appends it to the same file under `## Selected plan`.

**Gate 2 — confirm the full plan.** Resume again to confirm the expanded plan, or modify it. Nothing write-capable runs until you confirm here.

```
.socratic/
├── add-rate-limiting.md        ← session state
└── add-rate-limiting-plan.md   ← options, then the full plan, committable
```

Take the time you need between gates:

```bash
/socratic-dev --resume add-rate-limiting
```

### Implementation

Only after Gate 2 does the `implementation` agent run — the **only** agent in the loop that holds write tools. It has the ticket context, the codebase context, the confirmed plan, and your annotations. It does not improvise.

### Closing the loop

When implementation is complete, call `--close`:

```bash
/socratic-dev --close add-rate-limiting
```

You're first offered an **optional critic** — a read-only adversarial reviewer that diffs what was built against the approved plan and flags divergences and unresolved questions, appending a session-close note to the plan file. It does not block; it produces a record. Then `--close` generates a structured handoff — what was built, what decisions were locked in, any technical debt introduced — and calls `wiki-maintain` to update the codebase wiki. If anamnesis-wiki is not installed, it logs a recommendation and exits cleanly.

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

On Claude Code, the `agents/` definitions in this directory activate a multi-agent layer. The orchestrator (your main session) owns every write to `.socratic/` and delegates the heavy phases to specialist subagents:

| Agent | Tools | Role |
|---|---|---|
| `task-context` | read-only | Reads the ticket, surfaces product and engineering questions |
| `task-evaluator` | read-only | Asserts the task is specific enough to plan against; halts on thin input |
| `codebase-context` | read-only | Reads the repo, the wiki, and the relevant code paths |
| `ideation` | read-only | Produces the named options-comparison and a recommendation |
| `implementation` | **write** | Executes the confirmed plan, produces the handoff summary |
| `critic` | read-only | Opt-in at `--close`: diffs the implementation against the approved plan |

The boundary is the point: every agent except `implementation` is **read-only by grant**, so no agent can touch code before you've confirmed the plan at Gate 2. The orchestrator runs them in sequence — `task-context` → `task-evaluator` → `codebase-context` → `ideation` → [Gate 1] → [Gate 2] → `implementation` → [optional `critic`].

On platforms without subagents, a single agent follows the same methodology in sequence — but there the read-only/write separation is behavioural rather than enforced by grant. The Claude Code version makes the gate structural.

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
