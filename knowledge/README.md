# Project Knowledge

## What this folder is

The project's shared knowledge base. Cross-cutting decisions, gotchas, and learnings that every agent and every future Claude Code session should see when they pick up work on this project.

Distinct from two other persistence mechanisms.

| Where | Scope | Who reads it | Lifetime |
|---|---|---|---|
| `.claude/agent-memory/<agent>/MEMORY.md` | One agent's lane | Only that agent (auto-injected) | This project, checked into git via `memory: project` |
| `~/.claude/projects/<slug>/memory/` | One user's session history | Just Claude in this user's local env | Personal, never shared |
| **`.project/playbook/knowledge/<topic>.md`** (this folder) | **Project-wide, cross-agent** | **Every agent, every human reader, every future session** | **Project-wide, checked in** |

If a fact, decision, or constraint matters to more than one agent, it belongs here. If it only matters to the agent that learned it, it belongs in that agent's `MEMORY.md`.

## When to write a knowledge file

Write to this folder whenever an agent or a human discovers any of the following.

- **A load-bearing decision** the project will now build on. Chain choice, framework choice, data-residency call, billing model, brand hook, security control commitment.
- **A non-obvious constraint** that future work must respect. Regulatory boundary, vendor limitation, customer contract clause, performance budget.
- **A gotcha** that cost time to discover and would cost time again if rediscovered. A subtle library behavior, an environment-specific bug, an API quirk.
- **A cross-agent handoff fact** that one agent learns and another needs. Customer ICP insight from Sales that Marketing must build on. Architectural constraint from Architect that Developer must respect. Compliance ruling from Compliance that affects how Sales positions the product.

If a discovery would be wasted work for the next session or the next agent to redo, write it down here.

## File naming convention

One file per topic. Kebab-case filename, no date prefix (the file accumulates over time; entries inside are dated).

```
.project/playbook/knowledge/
  positioning-and-brand-hook.md
  data-residency-and-jurisdiction.md
  payment-provider-decisions.md
  xrpl-chain-choice.md
  icp-and-anti-icp.md
  recurring-support-patterns.md
```

If a topic becomes too long, split it. If two topics keep cross-referencing each other, consider merging. The fuller hygiene discipline (the Current position summary for long files, explicit reversals, graduating stable entries to `docs/`, and the review ritual that keeps all of it honest) lives in `../reference/rules/MEMORY-HYGIENE.md`.

## File format

Each file uses a simple dated-entries format. Entries grow over time; old entries are not deleted (they are the record).

```markdown
# <Topic title>

## What this file is

One paragraph: what this topic covers and why it deserves its own file.

## Entries

### 2026-05-30 - Initial entry

What was decided / discovered / committed to. Written by: <agent or human>.

**Context.** Why this came up.
**Decision or finding.** What is now true going forward.
**Implications for other agents.** Which agents need to know and what they should do differently.
**References.** Links to ADRs, spec sections, external docs, related knowledge files.

### 2026-06-15 - Revisited under new constraint

When the topic is revisited, add a new dated entry. Do not edit prior entries in place; they are the record of what the project believed at each point in time. If a prior decision is reversed, the new entry says so explicitly and explains why.

## Cross-references

- `architect/MEMORY.md` for the architect's working state on this topic
- `docs/ARCHITECTURE.md` for the production-canonical statement (if applicable)
- `.project/playbook/knowledge/<related-topic>.md` for adjacent context
```

## How agents are instructed to use this folder

Every agent definition in `.claude/agents/` includes the same standing instruction.

> Read `.project/playbook/knowledge/` for cross-cutting decisions made by you or by other agents. When you discover a non-obvious project-level fact, decision, or constraint, write it to `.project/playbook/knowledge/<topic>.md` so every agent and every future session sees it.

Each agent also has its own `MEMORY.md` (auto-injected by Claude Code via `memory: project` in the agent frontmatter). The agent reads MEMORY.md for its own lane and the knowledge folder for cross-agent context.

## How humans should use this folder

Read first, write rarely. If you are about to make a project-level decision, scan the knowledge folder for prior entries on the topic. If you are about to ask an agent to do something, point it at the relevant knowledge file in your prompt so it does not redo discovery work.

When you write, follow the file-format convention above. Date the entry. Sign it (your name or "human"). Note which agents the entry affects.

## What goes here vs `docs/`

This folder is the **internal working knowledge** of the project. `docs/` is the **shareable artifacts** (use cases, requirements, design, architecture, brand strategy, business plan, go-to-market).

Rule of thumb: if a fact is canonical and stable enough to publish to teammates or external readers, it belongs in `docs/`. If it is a working note, a gotcha, an open trade-off, or an in-flight decision, it belongs here. Knowledge entries often graduate to docs entries when they stabilize.
