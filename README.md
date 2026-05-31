# maieutic-tools

> Agentic tools for developers who lead their AI, not follow it.

Most AI coding tools assume the right question is "how do I write this code faster?" This collection starts from a different place: the developer's job is no longer to write code — it's to make decisions. The code is the easy part. The hard part is knowing *what* to build, *why* to build it this way, and *what* the codebase now knows that it didn't before.

Maieutic refers to the Socratic method of eliciting knowledge through questioning — the idea that the right questions surface understanding that was already there but unformed. Every tool in this collection embodies that practice. They don't generate code on your behalf and hand you the result. They ask the questions that make you a more deliberate architect, then execute with precision once you've decided.

The tagline is not ironic. These tools are built for developers who find it uncomfortable to be a passive observer in their own codebase.

---

## Tools

### [socratic-dev](tools/socratic-dev/)

A guided development loop. You bring a ticket; socratic-dev brings questions, context, and options. Before anything is implemented, specialist agents read the codebase and the task, surface ambiguities, and propose 2–3 concrete plans with their tradeoffs. You pick a plan — or negotiate a different one. Then it executes. When implementation is done, it closes the loop by handing off to anamnesis-wiki to keep the knowledge base current.

Ambiguity triggers questions, never assumptions. The developer selects the plan; the agent executes.

Works standalone. Pairs naturally with anamnesis-wiki.

### [anamnesis-wiki](tools/anamnesis-wiki/)

A living codebase knowledge base, inspired by [Andrej Karpathy's LLM Wiki pattern](https://karpathy.ai/zero-to-hero.html). Not RAG — an agent incrementally builds and maintains a structured, interlinked markdown wiki that sits between you and the raw codebase. Architecture decisions, technical debt, runbooks, domain glossary — all maintained automatically as your codebase evolves.

Three modes: **bootstrap** reads your entire codebase first, then runs a phased Socratic session to build the wiki from genuine understanding. **scaffold** gets a baseline wiki in place quickly when bootstrap hasn't been run. **maintain** is called by socratic-dev at the end of each loop, updating only what changed.

The wiki lives at `wiki/` in your project root. It's yours — plain markdown, readable by you, navigable by any agent.

Works standalone. Called automatically by socratic-dev.

---

## Install

```bash
# full collection
npx skills add jpab/maieutic-tools

# individual tools
npx skills add jpab/maieutic-tools/tools/socratic-dev
npx skills add jpab/maieutic-tools/tools/anamnesis-wiki
```

---

## Pairing socratic-dev and anamnesis-wiki

socratic-dev and anamnesis-wiki are designed to work together, but neither requires the other.

socratic-dev without anamnesis-wiki gives you a rigorous development loop with no persistent knowledge base — every session starts from scratch on codebase context. It works, but you lose the compounding benefit.

anamnesis-wiki without socratic-dev gives you a maintained wiki with no structured development loop — the wiki grows only when you invoke maintain manually. It works, but you lose the automatic update at the end of every implementation.

Together: socratic-dev uses the wiki as context at the start of every loop (the codebase-context agent reads it), and updates it at the end. The wiki gets smarter with every ticket you close. The development loop gets faster as the wiki grows.

If you install both, start with `wiki-bootstrap` on your codebase before running your first socratic-dev session.

---

## Architecture

Each tool ships as a SKILL.md — the [agentskills.io](https://agentskills.io) open standard, supported across Claude Code, Codex CLI, Gemini CLI, VS Code Copilot, Cursor, GitHub Copilot, JetBrains Junie, AWS Kiro, Goose, Roo Code, Sourcegraph Amp, and others.

On Claude Code, additional `.claude/agents/` definitions activate a multi-agent layer: instead of one agent doing everything, specialist subagents run in parallel — codebase context, business context, ideation, and implementation each scoped and focused. Same methodology, richer execution.

This is progressive enhancement. The SKILL.md gives you the methodology everywhere. Claude Code gives you the full orchestra.

---

## Philosophy

The tools are named following a pattern: a Greek or philosophical concept that reflects the methodology, paired with a functional suffix that signals what it does. Socratic — how it thinks. Dev — what it does. Anamnesis (the Platonic concept of recollection, of knowledge already present waiting to be recovered) — how the wiki is built. Wiki — what it does.

The full philosophy is in [docs/philosophy.md](docs/philosophy.md).
