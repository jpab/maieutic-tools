# anamnesis-wiki

A living codebase knowledge base that sits between you and the raw code.

Not RAG. Not a search index. A structured, interlinked markdown wiki built from genuine understanding of your codebase — and kept current automatically as it evolves.

The name comes from the Platonic concept of anamnesis: the idea that knowledge is not acquired from the outside but recollected from within. The wiki doesn't summarise your code; it recovers what the code already knows about itself.

---

## What it builds

The wiki lives at `wiki/` in your project root. It's plain markdown — readable by you, navigable by any agent, diffable in git.

```
wiki/
├── README.md          ← index, explains the structure, links everything
├── architecture.md    ← system overview and component map
├── decisions/         ← one file per architectural decision (ADR format)
├── debt.md            ← known technical debt, tagged by severity
├── runbooks/          ← operational procedures
└── glossary.md        ← domain terms and their meaning in the codebase
```

Pages interlink with `[[wiki-links]]`. The wiki grows with your codebase — new decisions get their own file in `decisions/`, new debt gets an entry in `debt.md`, new runbooks appear in `runbooks/`.

---

## Modes

### bootstrap

The full treatment. Run this once on an existing codebase to build the wiki from scratch.

```bash
/wiki-bootstrap
```

bootstrap reads the entire codebase first — source files, existing markdown, docs, configuration — before asking a single question. Then it runs a phased Socratic session:

1. **Understanding** — the agent tells you what it understood about the project. You confirm, correct, and fill gaps.
2. **Decisions** — the agent asks why certain decisions were made. Not "what does this do" but "why this, not that." This is where the ADRs come from.
3. **Contradictions** — the agent surfaces ambiguities and inconsistencies it found. You resolve them.

The result is a wiki that reflects genuine understanding, not a mechanical extraction. Bootstrap is time-consuming by design. It's worth it.

### scaffold

A faster alternative when bootstrap hasn't been run and you need something in place now.

```bash
/wiki-scaffold
```

scaffold reads the codebase, generates a first-pass wiki without a deep Socratic session, and gets the structure in place quickly. The wiki it produces is shallower than bootstrap — architecture and glossary will be thinner, decisions may be incomplete. It adds a notice to `wiki/README.md` recommending a full bootstrap when you have time.

Use scaffold to get started. Use bootstrap to get it right.

### maintain

Updates the wiki after an implementation loop. Called automatically by socratic-dev — you don't invoke this directly in normal use.

```bash
/wiki-maintain
```

maintain receives a structured handoff from socratic-dev: what was built, what decisions were locked in during implementation, any technical debt introduced. It updates the specific pages that changed — a new file in `decisions/`, an entry appended to `debt.md`, an updated section in `architecture.md` — without re-reading the whole codebase.

If you want to update the wiki after a change made outside a socratic-dev session, you can invoke maintain manually and describe what changed.

---

## Install

```bash
npx skills add jpab/maieutic-tools/tools/anamnesis-wiki
```

Or as part of the full collection:

```bash
npx skills add jpab/maieutic-tools
```

---

## Claude Code: multi-agent mode

On Claude Code, the `.claude/agents/wiki-writer.md` definition handles all three modes. The wiki-writer agent is a specialist with deep reading permissions and focused write access to the `wiki/` directory.

On other platforms, the host agent follows the same methodology directly from the SKILL.md files.

---

## Pairing with socratic-dev

anamnesis-wiki works standalone, but it reaches its full value paired with [socratic-dev](../socratic-dev/).

When socratic-dev is running, it reads the wiki at the start of every loop and writes to it at the end. The wiki compounds — each ticket closed adds structured knowledge that makes the next ticket faster to plan and safer to implement.

If you install both, run `wiki-bootstrap` before your first socratic-dev session.

---

## A note on ownership

The wiki is yours. It lives in your repo, in plain markdown, with no lock-in. Read it, edit it, commit it. The agent updates it; you own it.
