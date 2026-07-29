# maieutic-tools — Agent Context

This is the maieutic-tools monorepo. It contains agentic developer tools distributed as Agent Skills (SKILL.md) and Claude Code subagents (.claude/agents/).

## What this repo is

A collection of tools for developers who want to stay in control of every significant decision while using AI agents to handle execution. The tools are named using Greek/philosophical concepts that reflect their methodology.

## Repo structure

```
maieutic-tools/
├── README.md                        # manifesto, tool catalogue, install instructions
├── AGENTS.md                        # this file — cross-tool project context
│
├── tools/
│   ├── socratic-dev/
│   │   ├── README.md
│   │   ├── skills/
│   │   │   └── socratic-dev/
│   │   │       └── SKILL.md         # universal skill, works on 30+ agent tools
│   │   └── agents/                  # Claude Code native subagents
│   │       ├── task-context.md      # questions, session state
│   │       ├── task-evaluator.md    # sufficiency gate before planning
│   │       ├── codebase-context.md  # reads repo and wiki
│   │       ├── grill.md             # designs the next grilling question
│   │       ├── ideation.md          # proposes plans
│   │       ├── implementation.md    # executes approved plan
│   │       └── critic.md            # adversarial reviewer at decision gates
│   │
│   ├── anamnesis-wiki/
│   │   ├── README.md
│   │   ├── skills/
│   │   │   ├── wiki-bootstrap/
│   │   │   │   └── SKILL.md         # full Socratic wiki build from scratch
│   │   │   ├── wiki-scaffold/
│   │   │   │   └── SKILL.md         # fast baseline wiki, no Socratic session
│   │   │   └── wiki-maintain/
│   │   │       └── SKILL.md         # surgical updates after implementation loops
│   │   └── agents/
│   │       └── wiki-writer.md       # handles all three modes on Claude Code
│   │
│   ├── dialectic-synthesis/
│   │   ├── README.md
│   │   ├── skills/
│   │   │   └── dialectic-synthesis/
│   │   │       └── SKILL.md         # four-phase two-artifact synthesis methodology
│   │   └── agents/                  # Claude Code native subagents
│   │       ├── goal-elicitation.md  # asks questions, no file access
│   │       ├── artifact-reader.md   # reads one artifact, blind to goals (runs 2×, parallel)
│   │       ├── tension-mapper.md    # maps conflicts/complements against goals
│   │       ├── synthesis-planner.md # writes the decision document
│   │       └── synthesis-critic.md  # adversarial reviewer at analysis gates
│   │
│   └── antilogy-verdict/
│       ├── README.md
│       ├── skills/
│       │   └── antilogy-verdict/
│       │       └── SKILL.md         # two opposed cases on one target, then a verdict
│       └── agents/                  # Claude Code native subagents
│           ├── antilogy-advocate.md # strongest honest case FOR (runs in parallel)
│           └── antilogy-adversary.md # strongest honest case AGAINST (runs in parallel)
│
└── docs/
    ├── philosophy.md
    ├── pairing.md
    └── cross-platform.md
```

## Tools

### socratic-dev

A guided development loop. Input is a ticket description. Output is an implemented change, preceded by: a questions phase, parallel context gathering (business + codebase), 2–3 proposed plans written to `.socratic/<name>-plan.md`, developer approval, and implementation.

Key behaviours:
- Asks questions before acting, never assumes
- Saves state to `.socratic/<session-name>.md` (gitignored)
- Saves plans to `.socratic/<session-name>-plan.md` (committable)
- `--resume` continues a paused session (after questions or after plans)
- `--close` triggers the wiki handoff — never automatic

### anamnesis-wiki

A living codebase wiki maintained by an agent. Inspired by Andrej Karpathy's LLM Wiki pattern. The wiki lives at `wiki/` in the user's project root (not in this repo).

Three modes:
- `wiki-bootstrap` — full build, read-first, phased Socratic (preferred)
- `wiki-scaffold` — fast baseline, no Socratic session, recommends bootstrap
- `wiki-maintain` — surgical updates based on socratic-dev handoff

Wiki structure (in the user's project):
```
wiki/
├── README.md
├── architecture.md
├── decisions/         ← ADRs, one file per decision
├── debt.md
├── runbooks/
└── glossary.md
```

### dialectic-synthesis

A thinking tool, not an execution tool. Takes exactly two artifacts (code, designs, specs, prototypes, or prose ideas) and produces a synthesis plan — what to take from each, what to discard, how to resolve genuine conflicts. A decision document, never a diff. It never merges anything.

Four phases (0–3), one subagent each:
- `goal-elicitation` — establishes the goal anchor; questions only, no file access
- `artifact-reader` — reads one artifact blind to the goals (runs twice, in parallel)
- `tension-mapper` — maps conflicts/complements against the goals; goals enter here
- `synthesis-planner` — writes the decision document

Key behaviours:
- Exactly two artifacts — rejects more
- Blind reading firewall: artifacts are understood before goals enter, so analysis can't bend to a foregone conclusion
- No state machine — one-shot thinking pass, no `--resume`/`--close` (unlike socratic-dev)
- Output: `.dialectic/<name>-synthesis.md` (committable, not gitignored — it's the deliverable)
- Not a lazy winner: verdict is a spectrum from pure-winner to balanced hybrid; usually "base + grafts"

### antilogy-verdict

A stress-test for one proposal. Takes a single target (plan, decision, claim, design, or diff) plus the goal it serves and the constraints it respects, generates two opposed cases about it in isolation, adjudicates the clash privately, and emits only the verdict.

Two subagents, spawned in parallel from one message:
- `antilogy-advocate` — the strongest honest case FOR; no generic benefits, every point quoted
- `antilogy-adversary` — the strongest honest case AGAINST; no strengths section, no severity ratings

Key behaviours:
- The two cases are built independently — neither agent sees the other's output, so neither anchors on it
- The raw reports are never relayed to the user; only the adjudicated verdict is
- **Writes no file** — no session state, no decision document. The only tool in the collection with no artifact
- No state machine, no `--resume`/`--close`; goal and constraints are required, not optional
- Distinct from dialectic-synthesis by input: that tool compares two artifacts that already exist, this one generates two cases about one proposal

## Distribution

Tools are distributed via [agentskills.io](https://agentskills.io):

```bash
npx skills add jpab/maieutic-tools
npx skills add jpab/maieutic-tools/tools/socratic-dev
npx skills add jpab/maieutic-tools/tools/anamnesis-wiki
npx skills add jpab/maieutic-tools/tools/dialectic-synthesis
npx skills add jpab/maieutic-tools/tools/antilogy-verdict
```

SKILL.md files work on 30+ agent tools. `.claude/agents/` definitions activate a multi-agent layer on Claude Code — same methodology, parallel specialist execution.

## Architecture principle

Progressive enhancement. The SKILL.md gives the methodology everywhere. Claude Code adds multi-agent orchestration with scoped specialist subagents. Same tool, richer execution where the platform supports it.

## Conventions

- Tool names: `<philosophical-concept>-<functional-suffix>`
- Skill invocations: `/<tool-name>`, `/<tool-name> --resume <session>`, `/<tool-name> --close <session>`
- Session files: `.socratic/<name>.md` and `.socratic/<name>-plan.md` (gitignored in user's project)
- Wiki files: `wiki/` in user's project root, plain markdown, `[[wiki-links]]` for interlinking
