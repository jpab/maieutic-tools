---
name: wiki-bootstrap
description: Builds a codebase wiki from scratch through deep reading and phased Socratic questioning. Thorough — run once on a new project.
version: 0.1.0
author: jpab
---

# wiki-bootstrap

Build a codebase wiki from genuine understanding. Read first, ask second. The wiki you produce must reflect what the codebase actually is — not a mechanical extraction, and not a summary of what the developer tells you without looking at the code.

Inspired by Andrej Karpathy's LLM Wiki pattern.

---

## Invocation

```
/wiki-bootstrap
```

Run once on a project that has no `wiki/` directory. If `wiki/` already exists, tell the developer to use `wiki-scaffold` for incremental additions or `wiki-maintain` for post-implementation updates.

---

## Phase 0 — Read everything

Before asking a single question, read the codebase. Do not skip this phase. Do not ask the developer anything yet.

Read in this order:
1. Any existing markdown files in the root (`README.md`, `CONTRIBUTING.md`, `ARCHITECTURE.md`, etc.)
2. Any `docs/` directory
3. Configuration files that reveal structure (`package.json`, `pyproject.toml`, `Makefile`, `docker-compose.yml`, `*.config.*`, etc.)
4. Directory structure — understand the layout before reading files
5. Source files — prioritise entry points, interfaces, and the files touched most in recent commits if git history is available
6. Any existing ADRs, decision logs, or design documents

Your goal: form a clear model of what this system does, how it is structured, what its major components are, what technologies it uses, and what decisions are visible in the code.

---

## Phase 1 — Demonstrate understanding

Do not ask the developer what their system does. Tell them what you understood.

Present a structured summary:

**System:** What does this project do, in one or two sentences?

**Components:** What are the main parts? Name them using the language the codebase already uses.

**Key technologies and patterns:** What is the stack? What architectural patterns are in play (e.g. event-driven, layered, CQRS, monolith)?

**What you are less certain about:** Where did the code leave you with open questions? Name them specifically — "I see two different auth patterns in use and I'm not sure which is canonical" is useful. "I'm not sure about some things" is not.

Ask the developer to confirm, correct, and fill any gaps. Record their corrections. Do not move to Phase 2 until the system summary is confirmed.

---

## Phase 2 — Probe decisions

You now understand the what. Phase 2 surfaces the why.

For each significant decision visible in the codebase — architectural choices, library selections, data model design, API shape, deployment approach — ask the developer why that decision was made, if the answer is not evident in the code or documentation.

Frame questions as alternatives: "You're using X — was Y considered and ruled out, or was X the obvious choice?" This is more precise than "why did you choose X?" and easier to answer.

Examples:
- "You have a monorepo with shared packages — was a multi-repo approach considered, or did this start as a single service?"
- "The API is REST with no GraphQL layer — was GraphQL evaluated for the client-facing endpoints?"
- "You're using Postgres for both relational data and job queues — was a dedicated queue (Redis, SQS) considered?"

Rules:
- Only ask about decisions that are significant enough to warrant an ADR. Don't ask about incidental choices.
- Maximum 5–7 questions in this phase. Batch them — don't ask one at a time.
- Record every answer. These become the `decisions/` entries in the wiki.
- If the `architecture-decision-records` skill is available, it will be used when writing the ADR files — no need to format during this phase, just capture the substance.

---

## Phase 3 — Clarify contradictions and ambiguities

Name anything you found in the code that appears inconsistent, undocumented, or in tension with itself. Ask the developer to explain or resolve each one.

Examples:
- "There are two error handling patterns — X in the API layer and Y in the service layer. Is one canonical?"
- "The README says the system is stateless, but there's a Redis session store. Is the README outdated?"
- "Module A imports from Module C, and Module C imports from Module A. Is this intentional?"

Record resolutions. These inform `debt.md` and `architecture.md`.

---

## Build the wiki

Once all three phases are complete, create the `wiki/` directory and write the following files:

### `wiki/README.md`

An index and orientation document. Explain the wiki's structure, what each file contains, and how to navigate it. Include a brief description of the system at the top. Link every file in the wiki.

### `wiki/architecture.md`

System overview and component map. Cover: what the system does, its major components (named as the codebase names them), how they interact, the technology stack, and the key patterns in use. Use the confirmed summary from Phase 1 and the answers from Phase 2. Use `[[wiki-links]]` to reference decisions and glossary terms.

Include a diagram showing the main components and their interactions. If the `mermaid` skill is available, invoke it to generate the diagram — it reads actual Mermaid syntax reference docs and produces reliably correct output. Otherwise generate Mermaid syntax directly, using a flowchart for pipeline/batch systems or a sequence diagram for interaction-heavy systems.

### `wiki/decisions/`

One file per architectural decision surfaced in Phase 2.

If the `architecture-decision-records` skill is available, invoke it for ADR formatting — it provides richer templates and review guidance. Otherwise use this format:

```markdown
# <Decision title>

## Status
Accepted

## Context
<Why this decision needed to be made — the problem, the constraints, what made this non-obvious>

## Decision Drivers
- <key factor that shaped the decision>
- <key factor>

## Considered Options
- <Option A> — <one-line summary of why considered or rejected>
- <Option B>

## Decision
<What was decided and why it won>

## Consequences

### Positive
- <what this enables>

### Negative
- <what this constrains or costs>

### Risks
- <what could go wrong, and the mitigation>

## Related decisions
- <link to other wiki/decisions/ entries if any>
```

File naming: `<YYYY-MM-DD>-<short-slug>.md`

### `wiki/debt.md`

Known technical debt. One entry per item surfaced in Phase 3 or visible in the code. Tag each with severity: `low`, `medium`, or `high`.

```markdown
## <Debt item title> [high]

<What it is, where it lives, why it's debt>
```

If no debt is identified, write: "No known technical debt identified at time of bootstrap."

### `wiki/runbooks/`

Create this directory. If any operational procedures are documented anywhere in the repo (deployment steps, rollback procedures, database migrations, on-call playbooks), extract them into individual files here. If none exist, create `wiki/runbooks/README.md` with a single line: "No runbooks defined yet."

### `wiki/glossary.md`

Domain terms and their meaning in this codebase specifically. Not general programming terms — terms that have a specific meaning here. One entry per term, ordered alphabetically.

```markdown
## <Term>

<What it means in this codebase, not in general>
```

### `wiki/patterns/` (optional)

Create this directory only if recurring solutions are already visible — two or more decisions that solve the same shape of problem, or patterns explicitly noted in code comments or docs. If none are visible, skip it. wiki-maintain will create it when the first pattern earns filing.

If created, add `wiki/patterns/README.md`:

```markdown
# Patterns

Recurring solutions that have appeared across multiple decisions or sessions.

| Pattern | When to use |
|---------|-------------|
```

---

## Final step — agent entry point

After writing the wiki, create or update the agent entry point at the project root:

1. Check if `CLAUDE.md` exists at the project root.
   - If yes: add a line under the first heading (or at the top if unstructured): `See [wiki/README.md](wiki/README.md) for the full codebase wiki.` Do not overwrite any existing content.
   - If no: create `AGENTS.md` with:

```markdown
# AGENTS.md

See [wiki/README.md](wiki/README.md) for the full codebase wiki.
```

This ensures any agent that reads `CLAUDE.md` or `AGENTS.md` on startup will find the wiki without needing to know its location.

---

## Final output

Tell the developer:
- Where the wiki was written
- How many decisions, debt entries, and glossary terms were captured
- Whether `AGENTS.md` was created or `CLAUDE.md` was updated
- That they should review `wiki/decisions/` and correct anything that does not match their intent
- That if socratic-dev is installed, it will read and maintain this wiki automatically from now on
