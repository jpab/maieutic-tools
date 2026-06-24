---
name: dialectic-synthesis
description: Compares exactly two artifacts against explicitly stated goals and produces a reasoned synthesis plan — what to take from each, what to discard, how to resolve genuine conflicts. A decision document, not a diff.
version: 0.1.0
author: jpab
---

# dialectic-synthesis

A thinking tool, not an execution tool. You take two artifacts — code, skill definitions, design documents, specs, prototypes, or ideas held in prose — and produce a structured synthesis plan: what to take from each, what to discard, where they genuinely conflict and how to resolve it, and a concrete path forward. You never merge anything. The output is a decision document the developer acts on.

The analysis is always relative to goals the developer states first. Without that anchor, any comparison is just opinion.

## Invocation

```
/dialectic-synthesis                          — start a session, capture everything conversationally
/dialectic-synthesis "<hint>"                 — optional: a name, or "compare X against Y" as a starting hint
```

Arguments are hints only. The authoritative capture of the two artifacts and the goals happens in Phase 0. Do not treat an invocation string as a complete specification — confirm it.

## Hard rules (apply throughout)

- **Exactly two artifacts.** If the developer presents three or more, stop and say: "dialectic-synthesis compares exactly two artifacts. Pick the two strongest, or run it pairwise." Do not proceed with more than two.
- **Goals before analysis.** Do not read either artifact until Phase 0 goals are established (or each goal dimension is consciously waved off by the developer).
- **The reading is blind.** When reading an artifact in Phase 1, do not let the goals color the reading. Understand each artifact on its own terms first. Goals re-enter only at Phase 2.
- **Never merge.** You produce a plan for a synthesis. You never edit, combine, or write the artifacts themselves.
- **Honesty over balance.** Do not manufacture tension that isn't there, and do not fake a hybrid when one artifact genuinely dominates. The truth against the goals is the only deliverable that matters.

## Execution mode

Check whether `.claude/agents/goal-elicitation.md` exists.

- **If it exists** (Claude Code with this tool's agents installed): run in **orchestrated mode** — delegate each phase to its specialist subagent as described below. This is the preferred path; the blind reading firewall is enforced structurally because the artifact-reader never receives the goals.
- **If it does not exist** (any other platform): run in **solo mode** — you perform all four phases yourself, in sequence, following the exact same methodology. This file is the single source of truth; the subagents are scoped extracts of it.

The methodology below is identical in both modes. Only the delegation differs.

---

## Phase 0 — Goal elicitation (the maieutic phase)

**Orchestrated:** delegate to `goal-elicitation`.
**Solo:** do this yourself, asking the developer directly. You have no file access in spirit here — ask, do not read the artifacts yet.

Establish four dimensions. Treat them as a checklist of coverage, not a fixed script — phrase each per the situation, and skip any the developer has already answered in their invocation or earlier messages.

1. **Success** — what outcome defines a good synthesis here?
2. **Constraints** — what is fixed versus flexible?
3. **Known tension** — is there a conflict between the two already felt? (A valid answer is "none yet.")
4. **Context & the two artifacts** — what kind of thing is this (code, design, spec, idea)? What are the two artifacts, concretely? Capture each referent — a path, a glob, or a prose description of an idea the developer holds.

Rules:
- Ask only what genuinely affects the analysis. One sentence per question. Do not pad.
- The gate is satisfied when each dimension is **answered or consciously waved off** by the developer — never assumed by you.
- Do not proceed to Phase 1 until the gate is satisfied and both artifacts are identified.

Hold the goal anchor (the answers to all four dimensions) in working context. It will be embedded verbatim into the final document and is the standard every later phase is judged against.

## Phase 1 — Independent reading (blind)

**Orchestrated:** spawn `artifact-reader` **twice, in parallel** — once per artifact. Each run receives one artifact referent and the context type. **Neither receives the goals.**
**Solo:** read each artifact yourself, one at a time. **Write out the full reading of each artifact (below) before you re-read the goals.** This write-ordering is what preserves the blind firewall when one agent does everything.

For each artifact, produce an independent reading:
- **What it is** — one or two lines.
- **Core bet** — the central thing this artifact is wagering on being right.
- **Strongest idea** — the single best thing in it.
- **Key assumptions** — what it takes for granted that the other might not.

If a referent cannot be resolved (path doesn't exist, glob matches nothing, glob matches many files ambiguously, prose too vague to analyze), do not guess. Return to the developer, report exactly what's unresolvable, and get clarification before continuing. For a prose/idea artifact, read it from what the developer stated in Phase 0 — there is no file.

## Phase 2 — Tension mapping

**Orchestrated:** delegate to `tension-mapper`, passing both artifact readings **and** the goal anchor (goals enter here for the first time).
**Solo:** now bring the goals back in and map the two readings against each other and against the goals.

Produce:
- **Genuine conflicts** — where the two force a real choice. For each, name what's actually at stake.
- **Complementary** — where they combine freely, no conflict.
- **What each knows the other doesn't** — the asymmetric knowledge in each.

Optional structured output: include a **scoring matrix** against the goals only if the goals define more than three weighted criteria. Otherwise a matrix is theater — omit it. A SWOT per artifact is similarly optional, used only when an artifact is complex enough to warrant it.

**Honest short-circuit.** If, under goal-anchored scrutiny, no genuine tension survives, say so plainly rather than inventing some:
- One artifact is a superset of the other → state it; the synthesis will be trivially short.
- The two solve different problems and aren't comparable against the goals → state it and recommend re-scoping the comparison. Do not force a synthesis.

Before moving to the verdict, offer the developer an adversarial review of the tension map (`review_target: tension-map`) — see [Invoking the critic](#invoking-the-critic). It is optional and never blocks.

## Phase 3 — Synthesis plan

**Orchestrated:** delegate to `synthesis-planner`, passing the goal anchor and the tension map.
**Solo:** produce the plan yourself.

This is not a lazy winner. By now both artifacts have been mined for what the other lacks, so you have earned the right to a verdict — but it must be the honest one against the goals. "Winner" and "hybrid" are not opposites. Choose your point on this spectrum and justify it:

- **Pure A** (or pure B) — the other contributes nothing worth carrying. The rare endpoint; only when genuinely true.
- **A as base + grafts from B** (or the mirror) — the most common honest result. One artifact is the foundation; the other donates one or two specific ideas worth grafting. A clear winner usually still produces this asymmetric hybrid.
- **Balanced hybrid** — each contributes major pieces.

Show your work: when you favor one artifact, name what you specifically considered and rejected from the other, and why.

### Write the deliverable

Create `.dialectic/` in the project root if it does not exist. Write the document to `.dialectic/<name>-synthesis.md`, where `<name>` is the slug captured in Phase 0. This file is committable — it is the deliverable, not transient state. Do not gitignore it.

Use this exact skeleton:

```markdown
# Synthesis: <name>

## Goals
<The four dimensions from Phase 0, verbatim — success, constraints, known tension, context.>

## The two artifacts
- A: <referent — what it is, one line>
- B: <referent — what it is, one line>

## Independent readings
### Artifact A
- Core bet:
- Strongest idea:
- Key assumptions:

### Artifact B
- Core bet:
- Strongest idea:
- Key assumptions:

## Tension map
- Genuine conflicts (force a choice):
- Complementary (combine freely):
- What each knows the other doesn't:
<Optional: scoring matrix, only if goals define >3 weighted criteria.>

## Synthesis plan
- Base: <A, B, or balanced — and why>
- Take from A: <what, and why>
- Take from B: <what, and why>
- Discard from A: <what, and why>
- Discard from B: <what, and why>
- Conflict resolutions: <each genuine conflict → the call made + rationale>
- Recommended path forward: <concrete, sequenced steps the developer can act on>

## Goal check
<Test the synthesis plan against each goal from Phase 0. State plainly whether the plan satisfies it. This section is mandatory.>
```

Tell the developer the document has been written and where. Offer an adversarial review of the synthesis plan (`review_target: synthesis-plan`) — see [Invoking the critic](#invoking-the-critic). Do not act on it — the developer decides what to do next.

---

## Invoking the critic

dialectic-synthesis has its own adversarial critic, `synthesis-critic` — an on-demand, read-only reviewer that falsifies the analysis against the goals it claims to serve. It is offered at two gates: the tension map (end of Phase 2, `review_target: tension-map`) and the synthesis plan (after Phase 3, `review_target: synthesis-plan`). The developer triggers it; you never run it unprompted, and it never blocks.

**Orchestrated mode** (the agent is installed — check `.claude/agents/synthesis-critic.md`): spawn the `synthesis-critic` subagent with the `review_target` and the path to the synthesis document. If the developer already ran it at this same gate, also pass the **headlines** of the prior `## CRITIC_REVIEW` blocks (headlines only, so it does not anchor). Append the returned block to the synthesis document — never overwrite; invocations stack. Then let the developer decide.

**Solo mode** (no agent): you perform the adversarial pass yourself, in a deliberately skeptical voice. This is a falsification attempt, not a review — the default "this looks sound, two small notes" *is* the failure mode. Hold these hard rules:

- Every concern grounded in a **verbatim quote** from the synthesis document. If you cannot quote it, the concern does not exist.
- **No** "strengths", "overall", "summary", or "recommendation" sections — falsification only.
- **No severity ratings** — severity invites averaging; present every concern at equal weight.
- Hunt the gate's failure modes: at the tension map — manufactured tension, missed conflict, false short-circuit; at the synthesis plan — lazy winner, forced hybrid, goal-check theater, untraceable recommendation.
- Name the **strongest alternative** and what the analysis would have to be wrong about for it to win; omit if you cannot name it.
- No nitpicks — strategic only.
- If you find no falsification, say so plainly. Do not invent weak concerns.

Append your findings under a `## CRITIC_REVIEW` heading in the synthesis document, then let the developer decide.

---

## Pairing

dialectic-synthesis is standalone. It also pairs, manually, with [socratic-dev](../../../socratic-dev/): when socratic-dev proposes two plans you cannot choose between, feed them to dialectic-synthesis to find the hybrid instead of forcing a winner. Nothing auto-invokes — the developer drives the pairing.
