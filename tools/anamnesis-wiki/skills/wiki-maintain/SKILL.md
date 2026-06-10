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

### `wiki/architecture.md`

Update **only** if the implementation:
- Added or removed a component, service, or top-level module
- Changed how components interact (new data flow, removed integration point)
- Introduced a new technology into the stack

Do **not** update for:
- Internal refactors that don't change the architecture's nodes or edges
- Renames of internal identifiers
- Test-only changes

### `wiki/decisions/`

For each decision in the handoff (or identified during your review):
- If it is a new decision, create a new ADR file using the format established in bootstrap.
- If it modifies an existing decision, update the existing file. Add a `## Amendment` section at the bottom rather than rewriting the original — preserve the history.

File naming: `<YYYY-MM-DD>-<short-slug>.md`

Do **not** create an ADR for:
- Implementation details with no real alternative considered
- Bug fixes or debt paydown (those go in `wiki/debt.md`)

### `wiki/debt.md`

Update when:
- The handoff lists new debt introduced during implementation
- The implementation paid down or resolved existing debt (mark as `Resolved` with date — do not delete)

Do **not** update for:
- Changes that are fully clean with no debt introduced or resolved

### `wiki/runbooks/`

Update only if the implementation changed an operational procedure — new deployment step, new migration procedure, new rollback path, new recovery step. If a new procedure was introduced, create a new file.

Do **not** update for:
- Code changes with no operational impact

### `wiki/glossary.md`

Update only if the implementation introduced new domain terms — new entity names, new abstractions, new API concepts that appear in the codebase language. Keep definitions specific to this codebase, not general programming terms.

Do **not** update for:
- Renamed internals that don't surface in public APIs or domain language
- Technical implementation details that aren't domain terms

### `wiki/patterns/`

Create a new pattern file only when:
- The handoff or a decision note explicitly says "this is the Nth time we've done X" or similar
- The implementation applies a solution that matches an existing ADR but hasn't been generalised yet
- Two existing ADRs in `wiki/decisions/` solve the same shape of problem and are worth lifting into a single pattern

Most maintain runs will **not** produce a pattern. The filing threshold is high by design.

If a pattern is created, also update `wiki/patterns/README.md` (the index) and `wiki/README.md` (link to the new pattern).

Pattern file format:
```markdown
# Pattern: <name>

## When you see
<concrete situation that prompts this pattern — specific, not generic>

## Use
<the solution, in 2–4 sentences>

## Examples in this codebase
- <decision or session that established it>
- <other sessions that used it>

## Related
- <cross-link to decisions/>
- <cross-link to other patterns>
```

### `wiki/README.md`

Update the index only if new files were created. Do not update it for edits to existing files.

---

## Rules

- Do not rewrite pages that do not need updating. Surgical edits only.
- Do not delete history — mark decisions as amended, debt as resolved, runbooks as superseded.
- If you are uncertain whether something warrants an update, err on the side of updating. A slightly over-maintained wiki is better than a stale one.
- After all updates, output a summary using this structure:

```
## Wiki update summary

### Updated
- wiki/decisions/YYYY-MM-DD-<slug>.md — <one line: why>
- wiki/debt.md — <one line: why>

### No updates for
- wiki/architecture.md — <one line: why not>
- wiki/runbooks/ — <one line: why not>
- wiki/glossary.md — <one line: why not>
- wiki/patterns/ — <one line: why not>
```

The "No updates for" list is required. It shows which pages were considered and consciously skipped — the audit trail that makes maintain trustworthy.
