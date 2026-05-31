---
name: wiki-maintain
description: Updates the codebase wiki after an implementation loop. Called automatically by socratic-dev --close, or manually after changes made outside a socratic-dev session.
version: 0.1.0
author: jpab
---

# wiki-maintain

Update the codebase wiki to reflect what just changed. Surgical — touch only the pages that need updating, based on a structured handoff from socratic-dev or a developer-provided description.

---

## Invocation

Called automatically by socratic-dev:
```
/wiki-maintain  (invoked by socratic-dev --close with handoff context)
```

Called manually after changes made outside socratic-dev:
```
/wiki-maintain "<description of what changed>"
```

---

## Precondition

If `wiki/` does not exist in the project root, stop. Tell the developer to run `wiki-bootstrap` or `wiki-scaffold` to create the wiki first.

---

## When called by socratic-dev

socratic-dev passes a structured handoff:

```markdown
## What was built
<summary>

## Decisions made
<list>

## Technical debt introduced
<list or "none">

## Runbook changes needed
<list or "none">
```

It also passes the path to the session file (`.socratic/<session-name>.md`), which contains the full context of the implementation loop.

Use both. The handoff tells you what changed; the session file tells you why.

---

## When called manually

The developer provides a plain-language description of what changed. Read the relevant source files to confirm the changes before updating the wiki. Do not update wiki pages based solely on what the developer says — verify against the code.

---

## What to update

### `wiki/decisions/`

For each decision in the handoff (or identified during your review):
- If it is a new decision, create a new ADR file using the format established in bootstrap.
- If it modifies an existing decision, update the existing file. Add a `## Amendment` section at the bottom rather than rewriting the original — preserve the history.

File naming: `<YYYY-MM-DD>-<short-slug>.md`

### `wiki/debt.md`

- Add new debt entries from the handoff.
- Mark resolved debt as `Resolved` with the date, rather than deleting it — the history is useful.
- If the implementation paid down existing debt, update those entries.

### `wiki/architecture.md`

Update only if the implementation changed the system's structure — new components, removed components, changed interactions, new technology introduced. If the change was internal to an existing component without structural effect, do not update `architecture.md`.

### `wiki/runbooks/`

If the handoff lists runbook changes, update the relevant files. If a new operational procedure was introduced (new deployment step, new migration procedure, new rollback path), create a new file.

### `wiki/glossary.md`

If the implementation introduced new domain terms — new entity names, new abstractions, new API concepts — add them. Keep definitions specific to this codebase, not general.

### `wiki/README.md`

Update the index only if new files were created. Do not update it for edits to existing files.

---

## Rules

- Do not rewrite pages that do not need updating. Surgical edits only.
- Do not delete history — mark decisions as amended, debt as resolved, runbooks as superseded.
- If you are uncertain whether something warrants an update, err on the side of updating. A slightly over-maintained wiki is better than a stale one.
- After all updates, output a brief summary: which files were changed and why.
