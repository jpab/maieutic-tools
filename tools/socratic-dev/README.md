# socratic-dev

A guided agentic development loop that keeps you in control of every significant decision.

You bring a ticket. socratic-dev brings product questions, a sufficiency check, codebase context, a grilling on what the code can't answer, and options — in that order. Nothing gets implemented until you've chosen an option and confirmed the full plan. The plan is a file you can commit, share with your team, and discuss before a line of code is written. When you're ready, you resume. When implementation is done, you close — optionally with an adversarial critic that checks what was built against what was approved.

The loop's central guarantee: **no write-capable agent runs before you've approved the plan.** This isn't a promise the implementation agent makes to itself — every agent except the implementer is read-only *by tool grant*. The gate is structural.

---

## How it works

### Input

Invoke with a ticket description — a product-level summary of what needs to be built. Not a technical spec; that's what the loop surfaces.

```bash
/socratic-dev "Add rate limiting to the public API endpoints"
```

Before questions start, socratic-dev runs a quick environment check: current branch, uncommitted changes, and whether your branch is behind the remote. If anything looks wrong it warns you before any analysis begins — starting a session on the wrong branch or with stale code would make the codebase picture unreliable.

You'll then be asked to give the session a name. This becomes the slug for all session files.

### Questions phase

Before any context gathering begins, socratic-dev surfaces the **product questions** — for the Product or Business owner. These are about customer/user impact, business goals, and strategic scope: the "what" and "why" of the feature, not the "how". A product question can be answered by a product manager with no technical knowledge. Examples: "What should happen to a user who hits the limit — blocked, degraded, or notified?" / "What business goal does this serve — cost control, abuse prevention, fair use?"

Engineering unknowns are deliberately *not* asked here. They become **investigation targets** handed to `codebase-context`, which resolves most of them by reading the code. Only what the code can't answer comes back to you — later, in the grilling phase. That ordering is the point: you never get asked an engineering question the codebase would have answered for free.

If a product question needs input from someone else, use `--resume` to come back once you have the answer.

```bash
/socratic-dev --resume add-rate-limiting
```

### Sufficiency check

Before any code is read, a lightweight `task-evaluator` asserts that the ticket plus your product answers are specific enough to plan against. If the task is too thin — a direction with no definition of done, an undrawn scope boundary — it surfaces a short list of targeted clarifying questions and halts rather than planning against guesswork. If the task is plannable, it gets out of the way. A false halt costs one round-trip; a missed gap costs a wrong plan.

### Context gathering

Once the task is sufficient, `codebase-context` reads the repo — the wiki first (if present), then the relevant code paths — and reports the technical landscape: what exists, what patterns are established, what constraints are real versus assumed, and the **test seams** the area already has. It resolves the engineering investigation targets where the code answers them, and returns the residue it can't — the genuinely open questions — for the grilling phase. It's read-only.

### Grilling

Now — and only now, after the code has been read — socratic-dev grills you on what the code couldn't answer, **one question at a time**, each with a **recommended answer** so you can confirm cheaply or correct deliberately. It's adaptive: the `grill` agent picks each question in light of every answer you've already given, so a later question can build on — or be dropped because of — an earlier one. That's the point of one-at-a-time; a flat list written up front can't do it. grill anchors to the bounded residue and stops the moment nothing left would change the plan, so it won't manufacture filler questions. If `codebase-context` resolved everything, this phase is skipped. Can't answer one yet? `--resume` later — nothing guesses past a question that shapes the plan.

### Options and the two gates

`ideation` produces a named options-comparison: 2–3 meaningfully different approaches, each a paragraph (tradeoffs and assumptions explicit), plus a recommendation that names what would flip the choice. This is written to `.socratic/<session-name>-plan.md` — yours to commit, open in a PR, or paste into a Slack thread.

**Gate 1 — pick an option.** Resume and choose one by number, or push back: "I like option 2 but avoid touching the auth middleware." Once you've chosen, socratic-dev expands that option into a full implementation plan and appends it to the same file under `## Selected plan` — including the **testable behaviors** the implementer will drive out test-first and the **test seams** they'll use.

**Gate 2 — confirm the full plan.** Resume again to confirm the expanded plan, or modify it. Nothing write-capable runs until you confirm here.

At either gate you can type `critic` for an adversarial second opinion before you commit — see [the critic](#the-critic) below.

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

Only after Gate 2 does the `implementation` agent run — the **only** agent in the loop that holds write tools. It has the ticket context, the codebase context, the confirmed plan, and your annotations. It implements **test-first**: each testable behavior is driven out red → green → refactor, with tests bound to the public interface so they survive an internal refactor. It does not improvise.

### Closing the loop

When implementation is complete, call `--close`:

```bash
/socratic-dev --close add-rate-limiting
```

You're first offered the **critic** on the diff — it compares what was built against the approved plan (see below). Then `--close` generates a structured handoff — what was built, what decisions were locked in, any technical debt introduced — and calls `wiki-maintain` to update the codebase wiki. If anamnesis-wiki is not installed, it logs a recommendation and exits cleanly.

### The critic

`critic` is a read-only, on-demand adversarial reviewer available at **all three gates**, not just the end. It doesn't validate or summarise — it produces a structured falsification attempt grounded in verbatim quotes, then gets out of the way. It never blocks and never makes the decision for you; each invocation appends a `## CRITIC_REVIEW` block to the plan file, and they stack.

| Gate | What the critic reviews |
|---|---|
| Option choice | the options-comparison — false trichotomy, shared blind spots, missed options |
| Plan | the full plan — untraceable scope, missing changes, silent assumptions |
| Diff (`--close`) | the implementation vs the plan — omissions, unplanned material, tests that verify the wrong thing |

Type `critic` at Gate 1 or Gate 2 before deciding; at `--close` you're asked directly.

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
| `task-context` | read-only | Reads the ticket; surfaces product questions and engineering investigation targets |
| `task-evaluator` | read-only | Asserts the task is specific enough to plan against; halts on thin input |
| `codebase-context` | read-only | Reads the repo, the wiki, and the relevant code paths; resolves the investigation targets and returns the open residue |
| `grill` | read-only | Picks the next grilling question — given the residue and every answer so far, returns the single next question (with a recommended answer) or a stop signal |
| `ideation` | read-only | Produces the named options-comparison and a recommendation |
| `implementation` | **write** | Executes the confirmed plan test-first; produces the handoff summary |
| `critic` | read-only | On-demand at any gate: reviews the options, the plan, or the diff against the plan |

Grilling splits in two: the `grill` agent decides *what to ask next*, and the orchestrator does the asking — an adaptive loop where grill is re-invoked after each answer, so every question is chosen in light of the ones already answered. The split is forced — a single-shot subagent can't hold an interactive dialogue (it returns once and can't wait for your answer), so the asking stays with the orchestrator; but the question-choosing is offloaded to a focused agent, so the orchestrator stays a thin relay rather than designing questions live.

The boundary is the point: every agent except `implementation` is **read-only by grant**, so no agent can touch code before you've confirmed the plan at Gate 2. The orchestrator runs them in sequence — `task-context` → `task-evaluator` → `codebase-context` → `grill` loop (ask → re-invoke until it stops) → `ideation` → [Gate 1] → [Gate 2] → `implementation` → [optional `critic`].

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
