# Personas and the .project Directory

## About this file

First of six rule docs in the playbook (`TEAM-PERSONAS.md` this file, `DESIGN-METHODOLOGY.md`, `DEVELOPMENT-BUILD.md`, `BUSINESS-OPERATIONS.md`, `BUG-TRACKING.md`, `PRE-DEVELOPMENT-BLUEPRINT.md`). Tooling inventory lives separately at `../tools/SKILLS-INVENTORY.md`. Covers two related ideas. The `.project/` directory pattern that holds operational files Claude Code can write to freely. The persona-as-team concept that lives inside that directory and shapes how Claude communicates on this project.

## About the .project directory

The `.project/` directory at the root of the repo is intended to be gitignored on purpose. It exists as a workaround for a Claude Code permission boundary. Even in `bypassPermissions` mode, Claude Code requires explicit user approval to write inside the `.claude/` directory. That makes `.claude/` awkward as a home for operational files that Claude should be able to update freely.

The workaround is `.project/`. Keep operational files there (persona files, project conventions, memory aids, infrastructure notes, process docs like this one), gitignore the directory so private content stays private, and reference those files from `.claude/CLAUDE.md` by relative path. Claude can read and update anything in `.project/` without permission prompts.

## The persona concept

The most useful pattern is persona files. Think of these as the team that works for you on the project. Each persona is a teammate with its own unique skills, voice, and area of responsibility. When you tell Claude Code which persona to put on for a given task, you are effectively pulling the right teammate into the room. The personas, together, build the project.

A block of references inside `.claude/CLAUDE.md` looks like this:

```
The architect persona rules live in .project/ARCHITECT-PERSONA.md.
The end-user persona rules live in .project/ENDUSER-PERSONA.md.
The developer persona rules live in .project/DEVELOPER-PERSONA.md.
```

Add more lines and matching files based on what your project actually needs beyond the 17 shipped persona templates. A data project might add `DATA-ANALYST-PERSONA.md` or `ML-ENGINEER-PERSONA.md`. An infrastructure project might add `SECURITY-PERSONA.md` or `SRE-PERSONA.md`. A research project might add `RESEARCHER-PERSONA.md`. Whatever role you wish you had a teammate for, write the persona file and reference it from `.claude/CLAUDE.md`.

When `.claude/CLAUDE.md` is loaded into Claude Code's project context, the references resolve and Claude reads the files from `.project/`. Updates happen freely because `.project/` sits outside the `.claude/` permission boundary.

## Security baseline lives in two places on purpose

Persona files live in `.project/` so Claude can update them freely. The security baseline behaves differently. It ships in two copies. The active production copy at `.claude/SECURITY-POSTURE.md`, which `.claude/CLAUDE.md` references and Claude reads on every session. A playbook reference copy at `SECURITY-POSTURE.md` (this folder), which travels with the playbook when shared. The dual-location pattern exists because `.claude/` requires explicit user approval to write to even in `bypassPermissions` mode; that boundary protects the production copy from silent modification. The playbook copy is freely writable and is what the bootstrap script (`../../START-PLAYBOOK.md` Phase 1) copies into `.claude/`.

Every persona inherits the rules in `SECURITY-POSTURE.md`; no persona overrides them.

## What goes in a persona file

A useful persona file has six sections. Treat the structure as a template; the content is what makes each persona distinct.

| Section | What it captures |
|---|---|
| **Who I Am** | One-paragraph identity. The teammate's role, background, and what kind of work they take. |
| **What I Optimize For** | The trade-offs this persona prefers. Speed vs correctness, simplicity vs flexibility, conservative vs experimental. |
| **Voice and Style** | Concrete writing rules. Sentence length, em-dash use, jargon level, formatting conventions. Specific enough that two outputs from the same persona read like they came from the same person. |
| **What NOT to Do** | The anti-patterns. Hype words to avoid, decisions out of scope, topics this persona refuses to weigh in on. |
| **When to Use This Persona** | The doc types or task types this persona owns. |
| **When to Switch** | Pointers to the other personas that own adjacent surfaces. Prevents the persona from drifting into someone else's lane. |

Optional sections worth adding once the project matures: **Patterns I Use Often** (recurring shapes the persona reaches for), **Citing Things** (what evidence the persona requires before a claim), and **What I Care About Beyond the Code** (the higher-order goals that explain why the persona makes the trade-offs it does).

## Persona templates

A set of 17 generic persona templates lives in `../personas/`. Copy the relevant ones into `.project/` and customize for the project. The starter set by project shape.

| Persona | Tier | Owns |
|---|---|---|
| `ARCHITECT-PERSONA.md` | Any project | System design, ADRs, the design and architecture docs |
| `ENDUSER-PERSONA.md` | Any project | Use cases, user-facing copy, the consumer surface |
| `DEVELOPER-PERSONA.md` | Any project | Implementation, tests, code review |
| `SECURITY-AUDITOR-PERSONA.md` | Any project | Audits across UI, security, and functional bugs; issue discovery and remediation tracking |
| `QA-ENGINEER-PERSONA.md` | Any project | Whole-platform functional and E2E test automation; runs the suite and verifies bug fixes before close |
| `BRAND-PERSONA.md` | Tier 1 | Positioning, brand identity, voice and tone |
| `LEGAL-PERSONA.md` | Tier 1 | Entity, IP, contracts, ToS, Privacy |
| `DESIGNER-PERSONA.md` | Tier 1 | Design system, component library, accessibility |
| `SALES-PERSONA.md` | Tier 2 | Sales playbook, ICP, demo script, qualification |
| `CUSTOMER-SUCCESS-PERSONA.md` | Tier 2 | Onboarding, health metrics, QBR, renewals |
| `MARKETING-PERSONA.md` | Tier 2 | Marketing ops, CRM, content program |
| `PEOPLE-PERSONA.md` | Tier 2 | Hiring, interview scorecards, compensation |
| `COMMUNITY-PERSONA.md` | Tier 2 | Community charter, engagement, contributor programs |
| `SUPPORT-PERSONA.md` | Tier 3 | Knowledge base, ticketing, tier 1 vs tier 2 |
| `COMPLIANCE-PERSONA.md` | Tier 3 | SOC 2, GDPR, audit-ready controls |
| `FINANCE-PERSONA.md` | Tier 3 | Billing, ASC 606, fundraising operations |
| `BIZDEV-PERSONA.md` | Tier 3 | Partner tiering, joint GTM, partner enablement |

See `BUSINESS-OPERATIONS.md` for the tier framework. Add more personas as the project shape demands; the templates in `../personas/` follow the same six-section structure and can be cloned as starting points.

## How to invoke a persona

Two patterns work well. Either is fine; pick whichever fits the conversation.

**Explicit at the start of a request.**

```
Using the ARCHITECT persona, draft the principles section of
docs/DESIGN.md based on the spec at
docs/specs/YYYY-MM-DD-<topic>-design.md.
```

**Implicit by referencing the artifact type.** When `.claude/CLAUDE.md` says "the architect persona owns docs/DESIGN.md", Claude defaults to the architect voice when working on that doc without needing to be told.

## Personas as native Claude Code agents

Each persona has a matching **native Claude Code subagent** definition in `../agents/<name>.md`. After running `bash .project/playbook/scripts/install-agents.sh`, these are copied into `.claude/agents/`, where Claude Code discovers them automatically. Invoking an agent (via the Agent tool or by name in a prompt) spawns a fresh session that loads that agent's instructions directly, with the persona file as the canonical voice reference.

The agent definitions are thin wrappers. Each agent's body instructs it to:

1. Read its persona file at `.project/<ROLE>-PERSONA.md` for voice and responsibility.
2. Read its phase-relevant rule docs from this folder.
3. Inherit `SECURITY-POSTURE.md` (every agent does).
4. Consult its own `MEMORY.md` (auto-injected by Claude Code via `memory: project` frontmatter) before starting any task.
5. Read `.project/playbook/knowledge/` for cross-cutting decisions from other agents.
6. Write any non-obvious project-level discovery to `.project/playbook/knowledge/<topic>.md` so every other agent sees it.

**Source of truth.** The persona file (`.project/<ROLE>-PERSONA.md`) remains the canonical voice. The agent file (`.claude/agents/<name>.md`) is the Claude Code activation shim that points at it. Edit the persona file when you want to change voice or responsibility; edit the agent file when you want to change the agent's frontmatter (tools, model, preloaded skills, memory scope).

## Cross-session memory and shared knowledge

Two persistence mechanisms work together.

| Where | Scope | Auto-managed? | Read by | Best for |
|---|---|---|---|---|
| `.claude/agent-memory/<agent>/MEMORY.md` | One agent's lane | Yes, by Claude Code (via `memory: project` frontmatter) | Only that agent (auto-injected at session start) | In-flight work, recent decisions in this agent's domain, items the agent intends to come back to |
| `.project/playbook/knowledge/<topic>.md` | Project-wide | No, agents and humans write deliberately | Every agent, every human reader, every future session | Load-bearing decisions, gotchas, cross-agent handoff facts |

If a fact matters to only the agent that learned it, it goes in that agent's MEMORY.md. If it matters to multiple agents (or to humans reading the project), it goes in the knowledge folder. See `../knowledge/README.md` for the convention.

The combination is what lets the team "come to life" across sessions: each agent recalls its own working state automatically (MEMORY.md), and shared decisions stay visible to everyone (knowledge folder).

Both layers decay without maintenance: a MEMORY.md past the auto-inject budget silently stops reaching its agent, and a stale knowledge entry steers agents wrong. The pruning rules and the review ritual live in `MEMORY-HYGIENE.md`.

Memory is one of several things that load into a session before any work starts, alongside `CLAUDE.md`, skill descriptions, and tool listings. How the team keeps that baseline small, which model does which work, and when to end a session and hand off through these two memory layers is covered in `CONTEXT-ECONOMY.md`.

## Next

Read `DESIGN-METHODOLOGY.md` for the flow that uses these personas and the skills from `../tools/SKILLS-INVENTORY.md` to turn an idea into a positioned product.

Read `BUSINESS-OPERATIONS.md` for the functional areas beyond product and engineering that each persona supports.

Read `../personas/<ROLE>-PERSONA.md` for the full template of any specific persona.
