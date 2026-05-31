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
│   │       ├── codebase-context.md  # reads repo and wiki
│   │       ├── ideation.md          # proposes plans
│   │       └── implementation.md    # executes approved plan
│   │
│   └── anamnesis-wiki/
│       ├── README.md
│       ├── skills/
│       │   ├── wiki-bootstrap/
│       │   │   └── SKILL.md         # full Socratic wiki build from scratch
│       │   ├── wiki-scaffold/
│       │   │   └── SKILL.md         # fast baseline wiki, no Socratic session
│       │   └── wiki-maintain/
│       │       └── SKILL.md         # surgical updates after implementation loops
│       └── agents/
│           └── wiki-writer.md       # handles all three modes on Claude Code
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

## Distribution

Tools are distributed via [agentskills.io](https://agentskills.io):

```bash
npx skills add jpab/maieutic-tools
npx skills add jpab/maieutic-tools/tools/socratic-dev
npx skills add jpab/maieutic-tools/tools/anamnesis-wiki
```

SKILL.md files work on 30+ agent tools. `.claude/agents/` definitions activate a multi-agent layer on Claude Code — same methodology, parallel specialist execution.

## Architecture principle

Progressive enhancement. The SKILL.md gives the methodology everywhere. Claude Code adds multi-agent orchestration with scoped specialist subagents. Same tool, richer execution where the platform supports it.

## Conventions

- Tool names: `<philosophical-concept>-<functional-suffix>`
- Skill invocations: `/<tool-name>`, `/<tool-name> --resume <session>`, `/<tool-name> --close <session>`
- Session files: `.socratic/<name>.md` and `.socratic/<name>-plan.md` (gitignored in user's project)
- Wiki files: `wiki/` in user's project root, plain markdown, `[[wiki-links]]` for interlinking
