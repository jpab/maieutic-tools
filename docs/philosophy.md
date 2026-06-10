# Philosophy

## The problem with "AI-assisted development"

Most AI coding tools are built around a straightforward premise: write code faster. The agent takes your prompt, produces code, and you review it. The developer is a reviewer, not an author. The agent is the driver.

This is a reasonable starting point. It's also, over time, a trap.

The more you defer to the agent, the less you understand what you're building. The codebase accumulates decisions you didn't make and don't fully understand. You can ship faster, but your mental model degrades. When something breaks in a way the agent didn't anticipate, you're less equipped to fix it than you would have been if you'd built it yourself.

The problem isn't the agent. It's the relationship.

## A different premise

The developer's job is not to write code. It is to make decisions — about what to build, why to build it this way, what the tradeoffs are, and what the codebase now knows about itself. Code is the artifact of those decisions, not the decision itself.

If that's true, the right use of an agent is to handle the artifact while the developer handles the decisions. The agent executes with precision. The developer architects with clarity. Each does what it does better.

This is not a productivity argument. It's a competence argument. A developer who stays in the decision seat remains the author of their codebase. A developer who drifts into the review seat eventually works in a codebase they don't fully own.

## What maieutic means

Maieutic comes from the Greek *maieutikos* — the art of midwifery, applied to ideas. Socrates used it to describe his method: not teaching what he knew, but asking questions that drew out what the other person already understood but had not yet articulated. The knowledge was already there. The questions made it explicit.

Every tool in this collection is built on that practice. The agent reads the codebase before asking questions, because genuine questions come from genuine understanding. It surfaces ambiguities rather than assuming answers, because an assumption that gets built on is a hidden decision. It proposes plans rather than taking action, because the developer needs to see the options to choose well.

The tools are not deferential. They are honest. They tell you what they understood, ask what they don't know, and wait for your decision before acting. They don't flatter you with confidence they don't have.

## Naming

Each tool in this collection carries two names fused together: a Greek or philosophical concept that describes its method, and a functional word that describes its domain.

**Socratic-dev.** Socratic — a method of questioning that makes implicit knowledge explicit, that treats ambiguity as something to surface rather than paper over. Dev — the development loop it guides.

**Anamnesis-wiki.** Anamnesis — the Platonic concept that knowledge is not acquired from the outside but recollected from within, that understanding is recovered rather than injected. The wiki it builds is not a summary of what you tell it. It is a recovery of what the codebase already knows about itself.

**Dialectic-synthesis.** Dialectic — the Hegelian method of holding two positions in tension and finding what survives the friction. When you have two artifacts that both have merit, the question is not which one wins but what each one knows that the other doesn't.

The philosophical name is not decoration. It describes how the tool thinks. The functional suffix describes what it does. Together they are a complete description.

## The tagline

*Agentic tools for developers who lead their AI, not follow it.*

This is not a warning against AI. It is a description of a posture. Leading your AI means: you hold the decisions, the agent holds the execution. You understand what is being built and why. You are the author, not the reviewer.

Following your AI means the opposite — you review what it produces, you accept its assumptions, you let it drive. This can feel efficient. Over time it is expensive: in comprehension, in ownership, in the ability to course-correct when the codebase grows beyond what the agent anticipated.

These tools are built for developers who find that trade uncomfortable.
