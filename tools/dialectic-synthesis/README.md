# dialectic-synthesis

A thinking tool for choosing between two things — without pretending the choice is easy.

You bring two artifacts: two implementations, two designs, two specs, a prototype and its rewrite, or an idea in your head and the thing you've already built. dialectic-synthesis reads each on its own terms, maps where they genuinely conflict, and produces a synthesis plan — what to take from each, what to discard, how to resolve the real conflicts, and a concrete path forward. The output is a decision document, not a diff. It never merges anything itself.

The name is the method. *Dialectic* — thesis and antithesis producing a synthesis better than either. *Synthesis* — the conceived outcome, the plan for the merged thing, not the execution.

---

## How it works

### Input

Invoke it, optionally with a hint. Everything is confirmed in conversation — there is no rigid argument contract, because one of your two artifacts might be a prose idea rather than a file.

```bash
/dialectic-synthesis
/dialectic-synthesis "compare the prototype against the new structure"
```

You name the session; that slug names the output file.

### Phase 0 — Goal elicitation

Before reading anything, dialectic-synthesis establishes the anchor: what outcome defines success, what's fixed versus flexible, whether there's a tension you already feel, and what the two artifacts actually are. Any dimension that doesn't apply, you wave off explicitly. Without stated goals, a comparison is just opinion — so this phase gates the rest.

### Phase 1 — Independent reading (blind)

Each artifact is read on its own terms, **without knowledge of the goals** — so the reading can't be bent toward a foregone conclusion. For each: its core bet, its single strongest idea, its key assumptions. The two readings are independent and, on Claude Code, run in parallel.

### Phase 2 — Tension mapping

Now the goals come back in. Where do the two genuinely conflict and force a real choice? Where do they complement freely? What does each know that the other doesn't? If there's no real tension — one is a superset of the other, or they solve different problems — the tool says so plainly instead of inventing drama.

### Phase 3 — Synthesis plan

Not a lazy winner. "Winner" and "hybrid" aren't opposites — the honest answer is usually "this one is the base, and here are the specific ideas worth grafting from the other." The plan names what it takes, what it discards, and why, resolves each conflict explicitly, and ends with a mandatory check against the goals from Phase 0.

The document is written to `.dialectic/<name>-synthesis.md` — committable, shareable, yours to act on.

```
.dialectic/
└── prototype-vs-structure-synthesis.md   ← the decision document
```

---

## Install

```bash
npx skills add jpab/maieutic-tools/tools/dialectic-synthesis
```

Or as part of the full collection:

```bash
npx skills add jpab/maieutic-tools
```

---

## Claude Code: multi-agent mode

On Claude Code, the `.claude/agents/` definitions in this directory activate a multi-agent layer. The orchestrator delegates each phase to a scoped specialist:

| Agent | Role |
|---|---|
| `goal-elicitation` | Asks the questions, establishes the goal anchor. No file access. |
| `artifact-reader` | Reads one artifact on its own terms. Read-only. Runs twice, in parallel — blind to the goals. |
| `tension-mapper` | Maps both readings against each other and the goals. Surfaces or short-circuits tension. |
| `synthesis-planner` | Chooses the verdict and writes the decision document. |

The blind-reading firewall is structural here: `artifact-reader` is never handed the goals, so it can't read toward a conclusion. On other platforms, a single agent runs the same four phases in sequence, preserving the firewall by writing each reading out in full before the goals re-enter. The methodology is identical; Claude Code enforces the firewall by isolation rather than discipline.

---

## Pairing with socratic-dev

dialectic-synthesis works standalone — it compares any two artifacts, not just code.

If you have only *one* thing and want it stress-tested rather than compared, that is [antilogy-verdict](../antilogy-verdict/)'s job: it generates the two opposed cases about a single proposal instead of reading two that already exist, and returns a verdict rather than a synthesis plan.

It also pairs, manually, with [socratic-dev](../socratic-dev/). When socratic-dev proposes two plans and you can't choose between them, feed both to dialectic-synthesis: instead of forcing a winner, it finds the hybrid — which plan is the base, and what's worth carrying from the other. Nothing auto-invokes; you drive the pairing, because the developer makes the call.

---

## What it will not do

- It will not compare more than two artifacts. Pick the two strongest, or run it pairwise.
- It will not merge, edit, or write your artifacts. It writes a plan; you execute.
- It will not manufacture tension that isn't there, or fake a balanced hybrid when one side genuinely wins.
