# antilogy-verdict

A stress-test for one proposal — argued from both sides at once, then adjudicated.

You bring one thing you are about to commit to: a plan, a decision, a claim, a design, or a diff. antilogy-verdict builds two opposed cases about it — the strongest honest case FOR and the strongest honest case AGAINST — in isolation from each other, then decides where they genuinely conflict and returns a single verdict. Not both reports. Not a summary of the argument. The outcome.

The two cases are built *independently*. Neither arguer sees the other's work, so neither anchors on it, pre-concedes to it, or splits the difference with it. What you get back is what survived the collision.

The name is the method. *Antilogy* — the Protagorean practice of constructing two opposed arguments on the same matter, on the premise that a position you have not argued against you do not yet understand. *Verdict* — what it returns. Not a document, not a merge, not a plan: a decision, delivered into the conversation, with the losing arguments already discarded.

---

## How it works

### Input

Invoke it against whatever is on the table. The target, the goal it serves, and the constraints it must respect are confirmed in conversation — a critique or an advocacy against an assumed goal is worthless, so the goal is not optional.

```bash
/antilogy-verdict
/antilogy-verdict "the caching layer we sketched yesterday"
```

### Step 1 — Assemble the target briefing

The two arguers share none of your conversation. Whatever is not in their briefing, they cannot use. So the first step is packing one self-contained block: the target itself inline (or the exact paths and base ref where it lives), what it is *for*, and what it must respect. If the goal and constraints cannot be established from the conversation, you are asked before anything spawns.

### Step 2 — Both cases, in parallel

Both arguers receive the same briefing in the same moment, and run concurrently. One builds the case FOR at full strength; the other builds the case AGAINST at full strength. Neither is told what the other will say, and neither sees the result.

### Step 3 — Adjudicate privately, emit only the verdict

The two raw cases come back to the orchestrator as tool results and stay there. You never see them unless you ask. What you see is the adjudication: each point where the two genuinely engage the same issue, decided on the merits — and "neither, both miss X" is a permitted answer. A concern the advocate neutralises is resolved. A strength the adversary falsifies is dead. Only what survives reaches you.

```markdown
## ANTILOGY VERDICT: <target, one line>

**Bottom line:** <does it hold, and the single biggest reason>

### What won
### What lost
### Your call
```

**It writes no file.** Alone among the tools in this collection, antilogy-verdict persists nothing — no session directory, no decision document, no state. The verdict is conversational output you read in thirty seconds and act on. That is deliberate: a document you have to open is a document you have to maintain, and this output has a shelf life of one decision.

---

## Install

```bash
npx skills add jpab/maieutic-tools/tools/antilogy-verdict
```

Or as part of the full collection:

```bash
npx skills add jpab/maieutic-tools
```

---

## Claude Code: multi-agent mode

On Claude Code, the `agents/` definitions in this directory activate a two-agent layer. The main session stays the parent and adjudicator; the two cases are built by scoped specialists:

| Agent | Role |
|---|---|
| `antilogy-advocate` | Builds the strongest honest case FOR. Not a cheerleader — no generic benefits, every point grounded in a verbatim quote, honest about the conditions under which it wins. |
| `antilogy-adversary` | Builds the strongest honest case AGAINST. Not a reviewer — no strengths section, no severity ratings, every concern grounded in a verbatim quote. |

Both are read-only. Their shared grant is `Read`, `Grep`, `Glob`, and `Bash` for read-only inspection only — `git diff`, `git status`, reading files. Nothing in this tool writes to your repo.

The firewall is structural here: the two agents are separate contexts spawned in one message, so neither *can* see the other's output. On other platforms a single agent runs the same three steps, writing the full case FOR before the case AGAINST. The methodology survives; the guarantee does not — one agent cannot be blind to its own first case. Solo mode is a weaker instrument, not merely a slower one. See [docs/cross-platform.md](../../docs/cross-platform.md).

Install the agents with:

```bash
curl -fsSL https://raw.githubusercontent.com/jpab/maieutic-tools/main/install-agents.sh | sh -s -- antilogy-verdict
```

---

## Not to be confused with dialectic-synthesis

Both tools adjudicate competing positions. They differ by what you bring.

[dialectic-synthesis](../dialectic-synthesis/) takes **two artifacts that already exist** — two implementations, two designs, a prototype and its rewrite — and produces a plan for combining them. antilogy-verdict takes **one proposal** and *generates* the two opposed cases about it, then tells you whether it holds.

Two things in hand and a merge to plan: dialectic-synthesis. One thing in hand and a decision to make: antilogy-verdict.

---

## What it will not do

- It will not show you both cases by default. The raw reports stay with the orchestrator; you get the verdict. Ask for them explicitly if you want them.
- It will not write a file. No session state, no decision document, nothing to commit or clean up.
- It will not implement anything off the back of its own verdict. The verdict is a decision input, not an action — you decide what happens next.
- It will not run against an unstated goal. If it cannot establish what the target is *for*, it asks rather than guessing.
- It will not manufacture a balanced result. If one side is simply right, that is the verdict.
