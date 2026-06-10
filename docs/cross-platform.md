# Cross-platform support

## What works where

maieutic-tools ships two layers: SKILL.md files that work on any agentskills.io-compatible tool, and `.claude/agents/` definitions that activate a multi-agent layer on Claude Code specifically.

| Layer | Format | Works on |
|---|---|---|
| Core skills | SKILL.md | 30+ agent tools via agentskills.io |
| Multi-agent layer | `.claude/agents/` | Claude Code only |

## The two tiers

### Tier 1 — SKILL.md (everywhere)

The SKILL.md loads into whatever agent the developer is running. That agent — whether it's Codex, Gemini CLI, Cursor, VS Code Copilot, or any other skills-compatible tool — follows the methodology defined in the skill: asking questions before acting, proposing plans, waiting for approval, managing session state.

One agent, doing everything, following instructions. The full socratic-dev methodology. The full anamnesis-wiki methodology. Works on every tool that supports the agentskills.io standard.

### Tier 2 — `.claude/agents/` (Claude Code)

The same SKILL.md loads, but Claude Code also picks up the agent definitions in `.claude/agents/`. Now instead of one agent doing everything sequentially, the orchestrator spawns specialists that run in parallel:

**socratic-dev on Claude Code:**
- `task-context` and `codebase-context` run in parallel after questions are answered
- `ideation` runs after both complete, with full context from both
- `implementation` runs after plan approval, with everything it needs

**anamnesis-wiki on Claude Code:**
- `wiki-writer` handles all three modes (bootstrap, scaffold, maintain) as a specialist with scoped permissions — deep read access, focused write access to `wiki/` only

**dialectic-synthesis on Claude Code:**
- `goal-elicitation` establishes the goal anchor — no file access, questions only
- `artifact-reader` runs twice in parallel, once per artifact — read-only, and crucially never receives the goals
- `tension-mapper` maps both readings against the goals — goals enter context here for the first time
- `synthesis-planner` produces the decision document

The blind-reading firewall that dialectic-synthesis depends on is enforced structurally on Claude Code: `artifact-reader` literally cannot see the goals because they were never passed to it. On Tier 1, a single agent preserves the same firewall by discipline — writing out each artifact reading in full before re-reading the goals. The methodology is identical; the enforcement mechanism differs.

Each subagent is scoped to its role. Permissions are constrained to what that agent actually needs. The orchestrator coordinates; the specialists execute.

## What this means in practice

Tier 2 produces genuinely better results. The reason subagents exist is that separated contexts reason more cleanly: `codebase-context` reads the repo without the ticket framing in its window; `ideation` synthesises both contexts without having watched them being gathered; `implementation` executes the plan without carrying the full history of the planning session. Each agent sees only what it needs, and nothing else.

On Tier 1, a single agent holds everything — the ticket, the questions, the codebase reading, the plan proposals — in one growing context. The methodology is the same, but the reasoning is noisier. It works. It is not equivalent.

If you use Claude Code, use it with the subagents. If you use another tool, Tier 1 gives you the methodology — and the methodology alone is most of the value.

## Skill locations by platform

**Claude Code:**
```
~/.claude/skills/<skill-name>/SKILL.md    ← personal (all projects)
.claude/skills/<skill-name>/SKILL.md      ← project-level (this project only)
```

**VS Code / GitHub Copilot:**
```
.agents/skills/<skill-name>/SKILL.md
```

**Other tools:** refer to each tool's documentation for their skills directory.

The `npx skills add` command from agentskills.io handles installation automatically.

## What `npx skills add` installs

`npx skills add jpab/maieutic-tools` copies the SKILL.md files to the appropriate location for your tool. The `.claude/agents/` definitions are also copied for Claude Code. You do not need to manage the files manually.

## Checking compatibility

The `compatibility` frontmatter field in each SKILL.md describes any environment requirements. Skills that use the `.claude/agents/` layer note that Claude Code is required for the full multi-agent experience. On other platforms, the SKILL.md itself carries the complete methodology.
