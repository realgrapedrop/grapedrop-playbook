# Agents

## What this folder is

17 native Claude Code agent definitions, one per persona in `../personas/`. Each agent is a YAML-frontmatter file that wraps its persona and turns it into an invocable Claude Code subagent with cross-session memory enabled.

These files are the **source** for the project's team. They get installed into `.claude/agents/` (the location Claude Code reads) by running `bash .project/playbook/scripts/install-agents.sh` from the project root. Once installed, `ls .claude/agents/` lists them and you invoke them by name.

The source of truth split:

- **`.project/<ROLE>-PERSONA.md`** is the canonical voice and responsibility of a teammate. Edit here to change voice.
- **`.project/playbook/reference/agents/<name>.md`** (this folder) is the Claude Code activation shim. Edit here to change frontmatter (tools, model, preloaded skills, memory scope).
- **`.claude/agents/<name>.md`** is the installed copy in this project. Re-run `install-agents.sh` to refresh from the playbook source.

## The team at a glance

| Agent | Owns | Model | Memory | Preloaded skills |
|---|---|---|---|---|
| `architect` | Design, architecture, ADRs, requirements derivation | opus | project | brainstorming, writing-plans |
| `enduser` | Use cases, user journeys, user-facing copy | sonnet | project | brainstorming |
| `developer` | Implementation, tests, code review, build and ship work | sonnet | project | writing-plans, executing-plans, subagent-driven-development, test-driven-development, systematic-debugging |
| `designer` | Design system, components, accessibility, UI patterns | sonnet | project | none |
| `brand` | Positioning, voice and tone, brand strategy | sonnet | project | none |
| `legal` | Entity, IP, contracts, ToS, Privacy, regulated surfaces | opus | project | none |
| `sales` | ICP, demo script, qualification, pricing posture | sonnet | project | none |
| `customer-success` | Onboarding, health metrics, QBR, renewal motion | sonnet | project | none |
| `marketing` | Marketing ops, CRM, content program, demand gen | sonnet | project | none |
| `people` | Hiring, scorecards, comp bands, performance process | sonnet | project | none |
| `community` | Community charter, channel policy, contributor programs | sonnet | project | none |
| `support` | KB articles, ticketing, escalation paths | sonnet | project | none |
| `compliance` | SOC 2, GDPR, audit-ready controls, breach runbook | opus | project | none |
| `finance` | Billing, revenue recognition, fundraise prep | sonnet | project | none |
| `bizdev` | Partner tiering, joint GTM, partner enablement | sonnet | project | none |
| `security-auditor` | Audits across UI, security, and functional bugs; finds, files, verifies | opus | project | systematic-debugging |
| `qa-engineer` | Whole-platform functional/E2E test suite; runs it, gates bug-fix closure | sonnet | project | test-driven-development, systematic-debugging, verification-before-completion |

`opus` is reserved for roles that do heavy structural reasoning (architecture, legal, compliance) and for the security auditor. Every other role defaults to `sonnet`. Customize per project in the agent file's frontmatter.

The `model` line is also a cost control, so do not delete it. An agent without one inherits the main session's model, which is usually the most expensive one you have. Claude Code resolves an agent's model in this order: a model named for that one invocation, then this frontmatter line, then the `CLAUDE_CODE_SUBAGENT_MODEL` environment variable, then the main session's model. `verify-install.sh` Check 7 warns when an installed agent has lost its `model` line. An optional `effort` line (`low`, `medium`, `high`, `xhigh`, `max`) overrides the session's effort level for that agent; the shipped agents leave it unset and inherit. The reasoning is in `../rules/CONTEXT-ECONOMY.md` Rule 1.

`memory: project` means Claude Code automatically creates and maintains `.claude/agent-memory/<agent>/MEMORY.md` for each agent. The first 200 lines of MEMORY.md are auto-injected at session start. The agent reads and updates it without any manual prompt from you. That is the cross-session recall mechanism.

## Agent definition file shape

Every agent in this folder follows the same shape. Read any existing file (`architect.md` is a good starting point) for a complete example. The structure:

```yaml
---
name: <kebab-case-name>
description: <one-paragraph trigger statement - when to invoke this agent>
tools: <comma-separated Claude tools the agent is allowed to use>
model: <opus | sonnet | haiku | fable | a full model ID | inherit>
memory: <project | user | local>
skills:
  - <plugin:skill-name>      # optional preloaded skills
  - <plugin:skill-name>
---

You are the <Role> on this project.

**Your persona** lives at `.project/<ROLE>-PERSONA.md`. Read it at session start for your full voice (a one-line voice summary).

**Your relevant rule docs.**
- `.project/playbook/reference/rules/<DOC>.md` (why this doc matters to this agent)
- `.project/playbook/reference/rules/SECURITY-POSTURE.md` (inherited by every agent)

**Cross-session memory.** Read your `.claude/agent-memory/<name>/MEMORY.md` ... (standard memory instruction)

**Project-wide knowledge.** Read `.project/playbook/knowledge/` ... (standard knowledge instruction)

**Your first action in any session is** to consult MEMORY.md and the knowledge folder, then report what you remember and confirm the current task before proposing actions.
```

The persona file is the source of voice; the agent file is a thin Claude Code activation shim that points at it. Keep the agent file small. When voice or responsibility changes, edit the persona, not the agent.

## How to install

Installs all 17 native Claude Code agent definitions from this folder into `.claude/agents/` at your project root. Pass agent names to install a subset (e.g. `bash install-agents.sh architect developer`). Idempotent. Nothing needs reloading afterward: Claude Code watches `.claude/agents/` and picks up the new definitions within seconds. To verify all 17 landed, run `bash .project/playbook/scripts/verify-install.sh` (Check 3) or `ls .claude/agents/`. The full bootstrap walk-through (including post-install verification) lives in `../../START-PLAYBOOK.md` Phase 3.

```bash
bash .project/playbook/scripts/install-agents.sh
```

## How to invoke

At the Claude Code prompt, two patterns work.

**Explicit.**
```
Using the architect agent, draft the principles section of docs/DESIGN.md
based on the spec at docs/specs/YYYY-MM-DD-<topic>-design.md.
```

**Implicit** when `.claude/CLAUDE.md` says "the architect agent owns docs/DESIGN.md". Claude defaults to the architect voice when working on that doc without being told.

## Adding a new agent to the team

1. Add the persona template at `../personas/<ROLE>-PERSONA.md` if it does not exist (follow the six-section structure documented in `../rules/TEAM-PERSONAS.md`).
2. Add the agent file at this folder (`<name>.md`) following the shape above.
3. Re-run `bash .project/playbook/scripts/install-agents.sh <name>` to install the new agent into `.claude/agents/`.
4. Update the team-at-a-glance table above so this README stays in sync.
5. Update `../../AGENTS.md` (the multi-tool entry point at the repo root) so non-Claude-Code agents also see the new team member.

## Removing an agent

1. Delete the agent file from this folder.
2. Delete the copy from `.claude/agents/<name>.md`.
3. Optionally delete the persona file at `../personas/<ROLE>-PERSONA.md` if no other agent in the team uses it.
4. Update the team-at-a-glance table above.
5. The agent's prior `.claude/agent-memory/<name>/MEMORY.md` is preserved by default. Delete it manually if you want a clean slate.
