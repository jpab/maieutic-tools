---
name: antilogy-verdict
description: >
  Run an antilogy on a plan, decision, claim, design, or code change: spawn a
  rigorous advocate and an adversarial critic IN PARALLEL against the same
  target, then adjudicate where they conflict and return a synthesis to the
  conversation. Use when the user wants to stress-test something from both
  sides before committing — "run an antilogy", "advocate vs critic",
  "steelman and attack this", or invokes /antilogy-verdict.
version: 0.1.0
author: jpab
---

# antilogy-verdict

Two opposed cases about one proposal, built independently so neither anchors on the other, adjudicated into a single verdict you can read in thirty seconds. It writes no file — the verdict lands in the conversation.

## Invocation

```
/antilogy-verdict                     — run against whatever is on the table
/antilogy-verdict "<target>"          — optional: name the plan, decision, claim, design, or diff
```

Arguments are hints only. The authoritative capture of the target, the goal, and the constraints happens in Step 1 — confirm it, do not treat an invocation string as a complete briefing.

## Execution mode

Check whether the `antilogy-advocate` and `antilogy-adversary` subagents are available. They are installed either to `~/.claude/agents/` (where the repo's `install-agents.sh` puts them) or to `.claude/agents/` in the project — either location counts.

- **If both are available** (Claude Code with this tool's agents installed): run in **orchestrated mode** — the three steps below, spawning both subagents in parallel at Step 2. This is the preferred path; the firewall is enforced structurally, because neither subagent is ever handed the other's output.
- **If they are not** (any other platform, or Claude Code without the agents installed): run in **solo mode** — you perform all three steps yourself. Assemble the same briefing, write the full case FOR at its full strength, then write the full case AGAINST without softening it in light of what you just wrote, then adjudicate.

Solo mode preserves the methodology but not the guarantee: one agent writing both cases in one context cannot be blind to its own first case the way two isolated subagents are. The verdict is still useful; it is a weaker instrument, not merely a slower one.

---

You are the **parent** in an antilogy. Two isolated subagents argue opposite sides of the same target; you adjudicate and synthesize. The value is in (a) the two cases being made *independently* so neither anchors on the other, and (b) your adjudication of where they genuinely conflict — not in pasting both reports.

## Step 1 — Assemble the target briefing

The subagents share NONE of this conversation's context. Whatever you do not put in their prompt, they cannot use. Before spawning, assemble a single self-contained briefing block containing:

- **The target** — the actual plan / decision / claim / design / diff text, inline. If it lives in files or a branch, name the exact paths / base ref so they can read it themselves.
- **The goal** — what the target is *for*. A critique or advocacy against an assumed goal is worthless.
- **The constraints** — what it must respect (tech, time, scope, prior decisions).

If you cannot establish the goal and constraints from the conversation, ask the user for them before spawning — do not let the subagents guess.

## Step 2 — Spawn both in parallel

Spawn BOTH agents in a **single message with two Agent tool calls** so they run concurrently and independently. Pass each the *same* briefing block.

- `antilogy-advocate` — builds the strongest honest case FOR.
- `antilogy-adversary` — builds the strongest honest case AGAINST.

Neither sees the other's output. Do not tell either what the other will say.

## Step 3 — Adjudicate privately, then emit ONLY the verdict

The two raw reports are tool results returned to you — they are **not** shown to the user, and you must **not** relay them. The user sees only your verdict. Do the full adjudication in your head; publish just the outcome.

Adjudicate (privately):
1. **Map the clash.** For each point where the two genuinely engage the same issue, put them head to head.
2. **Decide each contested point** — who is right *on that point* and why, grounded in the target itself, not in which agent argued more fluently. "Neither — both miss X" is a valid verdict.
3. **Drop what cancels out.** A concern the advocate already neutralizes is resolved; a strength the critic falsifies is dead. Only what survives the collision reaches the verdict.

Then emit ONLY this — tight, no re-litigation of both sides, no quoting the agents at length:

```markdown
## ANTILOGY VERDICT: <target, one line>

**Bottom line:** <one or two sentences — does it hold, and the single biggest reason.>

### What won
- <surviving point> — <one line why it held>

### What lost
- <defeated point> — <one line why it fell>

### Your call
<Only items genuinely unresolved that need the user's judgment. Omit this section entirely if nothing is left open.>
```

Keep it short. Each bullet is one line. The goal is a decision input the user can read in thirty seconds — not a transcript of the two cases. If the user explicitly asks to see the full cases afterward, you may then surface the raw reports; otherwise they stay with you.

## Notes

- If one subagent returns its "nothing found" / "case is thin" block, that is signal, not failure — report it and let it shift the synthesis.
- You are read-only orchestration: do not implement anything off the back of the verdict unless the user asks. The verdict is a decision input, not an action.
- Both subagents are read-only (Read, Grep, Glob, read-only Bash). Nothing here writes to the repo.
