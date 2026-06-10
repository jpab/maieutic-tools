# Pairing socratic-dev and anamnesis-wiki

These two tools are designed independently but compound when used together. This document explains how.

## What each tool does alone

**socratic-dev alone** gives you a rigorous development loop. Every ticket goes through: questions, context gathering, plan proposals, developer approval, implementation. Nothing is assumed; nothing is built without your sign-off. But the context gathering starts from scratch every session — reading the codebase raw, without a structured map of what has been decided before.

**anamnesis-wiki alone** gives you a maintained knowledge base. Bootstrap builds it from genuine understanding. Scaffold gets a baseline in place. Maintain keeps it current. But maintain only runs when you invoke it — there is no automatic trigger from the work you are doing, so it relies on your discipline to stay current.

## What changes when you pair them

### socratic-dev reads the wiki

When `codebase-context` runs at the start of a socratic-dev loop, it reads `wiki/` first:

- `wiki/architecture.md` — the component map, so it knows what it's working inside before reading a line of code
- `wiki/decisions/` — the ADRs, so it knows why things are built the way they are
- `wiki/glossary.md` — the domain language, so the plans it proposes use the vocabulary your codebase already uses
- `wiki/debt.md` — the known constraints, so the plans it proposes don't inadvertently make things worse

The result: planning gets faster and more accurate as the wiki grows. A `codebase-context` run on a well-maintained wiki produces better plans than one reading the raw codebase, because it has the reasoning behind the code, not just the code.

### socratic-dev writes the wiki

When you call `--close` at the end of a loop, socratic-dev generates a structured handoff and passes it to `wiki-maintain`. The handoff contains: what was built, what architectural decisions were locked in during implementation (not just planning — the real decisions that happened as the code was written), and any technical debt introduced.

`wiki-maintain` updates the specific pages that changed. A new ADR file for each decision. An entry in `debt.md` for each shortcut. An update to `architecture.md` if the system structure changed. The wiki does not need to re-read the whole codebase — it receives the handoff and applies targeted updates.

### The compound effect

The wiki gets smarter with every ticket you close. The development loop gets faster as the wiki grows. After enough loops, `codebase-context` is navigating a rich, accurate map of your system instead of reading cold. The plans it proposes are grounded in real decisions and real constraints. The developer spends less time correcting wrong assumptions and more time choosing between genuinely good options.

## Getting started with both

1. Install both tools:
   ```bash
   npx skills add jpab/maieutic-tools
   ```

2. Run `wiki-bootstrap` on your codebase first:
   ```
   /wiki-bootstrap
   ```
   This is the foundational step. The bootstrap session reads your entire codebase, demonstrates its understanding to you, asks about your decisions, and builds the wiki from genuine comprehension. It is time-consuming. It is worth doing before your first socratic-dev session, because the wiki it produces is what every future `codebase-context` run will read first.

3. Start your first socratic-dev session:
   ```
   /socratic-dev "your ticket"
   ```

4. When implementation is done, close the loop:
   ```
   /socratic-dev --close <session-name>
   ```
   This triggers `wiki-maintain` automatically.

---

## Pairing socratic-dev and dialectic-synthesis

This pairing is manual and situational. socratic-dev proposes 2–3 plans; usually you pick one. Sometimes two plans are genuinely close and you can't decide which is the better base, or whether there's a hybrid worth building instead.

That's when you feed both plans to dialectic-synthesis. It reads each plan on its own terms, maps where they genuinely conflict, and produces a synthesis plan: which is the base, what's worth grafting from the other, and how to resolve the real conflicts. You get a decision document rather than a coin flip.

Nothing auto-invokes this. You drive it: copy the two plan options from `.socratic/<name>-plan.md` into dialectic-synthesis as the two artifacts, and state your goal anchor (what a good implementation actually needs to achieve). The output goes to `.dialectic/<name>-synthesis.md`, which you can commit alongside the plan file.

The pairing works in the other direction too: if you have a concept or a rough idea in your head and a half-built implementation already in the repo, dialectic-synthesis can compare them before you decide whether to keep building or change direction.

---

## If you can't bootstrap first

Run `wiki-scaffold` to get a baseline wiki in place, then start using socratic-dev. The wiki will be shallower than a bootstrapped one, but `wiki-maintain` will improve it incrementally with every loop you close. Each `--close` adds real decisions and real debt entries — things that only a bootstrapped wiki would have captured up front.

When you have time, run `wiki-bootstrap`. It will rebuild from scratch, overwriting the scaffold. Everything that `wiki-maintain` added will be recreated from the ground up with genuine Socratic comprehension.
