---
name: wiki-scaffold
description: Creates a baseline wiki for codebases that have not run wiki-bootstrap. Faster and shallower — gets the structure in place without a full Socratic session.
version: 0.1.0
author: jpab
---

# wiki-scaffold

Build a baseline codebase wiki without a full bootstrap session. Use this when the project has no `wiki/` and you need something in place now. The result is shallower than `wiki-bootstrap` — useful as a starting point, not a complete picture.

---

## Invocation

```
/wiki-scaffold
```

If `wiki/` already exists, stop. Tell the developer to use `wiki-maintain` to update an existing wiki, or `wiki-bootstrap` to rebuild from scratch.

---

## What scaffold does differently from bootstrap

Bootstrap runs a phased Socratic session — it demonstrates understanding, probes decisions, and clarifies contradictions before writing a word. That process takes time and requires the developer's active participation.

Scaffold skips the Socratic session. It reads the codebase and writes the wiki in one pass, from what it can observe without asking questions. The wiki will be less accurate on decisions (it can see the what, rarely the why), may miss domain glossary terms, and will leave some sections sparse or placeholder.

This is a deliberate tradeoff. A shallow wiki is better than no wiki.

---

## Step 1 — Read the codebase

Read in this order:
1. Root markdown files (`README.md`, `CONTRIBUTING.md`, etc.)
2. `docs/` directory if present
3. Configuration files that reveal structure
4. Directory layout
5. Source files — entry points and main interfaces

Do not ask any questions during this step.

---

## Step 2 — Build the wiki

Create `wiki/` and write the following files. Where you lack confidence, write what you can and mark it explicitly with `<!-- TODO: verify -->`.

### `wiki/README.md`

Index of the wiki. Brief system description at the top. Links to all files. Include this notice at the top:

```
> This wiki was created with wiki-scaffold (fast mode). It is a starting point, not a complete picture.
> Run wiki-bootstrap for a full Socratic build when you have time.
```

### `wiki/architecture.md`

System overview based on what the code shows. Name components using the codebase's own language. Mark anything uncertain with `<!-- TODO: verify -->`.

### `wiki/decisions/`

Create the directory. If any decisions are clearly documented (in READMEs, commit messages, or code comments), create ADR files for them. Otherwise create `wiki/decisions/README.md`:

```markdown
# Decisions

No decisions have been documented yet. Run wiki-bootstrap or add entries here manually.
```

### `wiki/debt.md`

Note any obvious technical debt visible in the code (TODOs, FIXMEs, deprecated patterns, duplicate logic). If none is obvious: "No technical debt identified by scaffold. Review manually."

### `wiki/runbooks/`

Create the directory. If operational procedures exist anywhere in the repo, extract them. Otherwise create `wiki/runbooks/README.md`: "No runbooks defined yet."

### `wiki/glossary.md`

List domain-specific terms visible in the code (entity names, key abstractions, domain nouns used in variable names, API paths, or documentation). Mark uncertain definitions with `<!-- TODO: verify -->`.

### `wiki/patterns/` (skip for scaffold)

Do not create this directory during scaffold. It is populated by wiki-maintain when patterns emerge from repeated decisions. Leave it absent — wiki-maintain will create it when the first pattern earns filing.

---

## Final output

Tell the developer:
- The wiki has been created at `wiki/`
- It is a scaffold — a starting point, not a complete picture
- They should run `wiki-bootstrap` when they have time for a full build
- If socratic-dev is installed, it will maintain this wiki automatically going forward — but bootstrap will make it significantly more useful
