# AGENTS.md

This file points any AI coding agent (Claude Code, Cursor, Cline, Codex, others) at the conventions, personas, and operating rules for this repository. Keep this file short. The real content lives in the docs this file references.

The playbook this file ships with is a generic, project-agnostic SaaS lifecycle playbook. After a project bootstraps from it, this file should be moved (or copied) to the project repo root so AI tools find it without entering the `.project/` directory.

## Read these first, in order

1. **`.claude/CLAUDE.md`** holds the canonical project instructions. Voice, commit identity, conventions, anything specific to this project. Read top-to-bottom before doing any work. (Created by the bootstrap script in `.project/playbook/START-PLAYBOOK.md`.)
2. **`.claude/SECURITY-POSTURE.md`** holds the six security rules every change must obey. Inherited by every persona and every agent. No exceptions.
3. **`.project/playbook/README.md`** is the Project Lifecycle playbook front door: what it is, the team, and a map to the rest of the docs. From there: `docs/USER-GUIDE.md` (install, bootstrap, day-to-day agent work, and updating), `docs/LIFECYCLE.md` (the eight stages), and `docs/ARCHITECTURE.md` (folder layout).

## When you need a specialist

The playbook ships 17 persona-backed Claude Code agents at `.claude/agents/` (sourced from `.project/playbook/reference/agents/`). Invoke by name. Each agent has `memory: project` enabled so it recalls its prior state across sessions via `.claude/agent-memory/<agent>/MEMORY.md`.

| Agent | When to invoke |
|---|---|
| `architect` | Load-bearing design or architecture decisions, ADRs, requirements work |
| `enduser` | Use cases, user journeys, user-facing copy |
| `developer` | Code, tests, code review, build and ship work |
| `designer` | Design system, components, accessibility, UI patterns |
| `brand` | Positioning, voice and tone, brand strategy |
| `legal` | ToS, Privacy, contracts, IP, regulated-surface flagging |
| `sales` | ICP, demo script, qualification, sales playbook |
| `customer-success` | Onboarding, health metrics, QBR, renewal motion |
| `marketing` | Content program, CRM, campaign planning |
| `people` | Hiring, scorecards, comp bands, performance process |
| `community` | Community charter, channel policy, advocacy |
| `support` | KB articles, ticketing, escalation paths |
| `compliance` | SOC 2, GDPR, audit-ready controls, breach runbook |
| `finance` | Billing, revenue recognition, fundraise prep |
| `bizdev` | Partner tiering, joint GTM, partner enablement |
| `security-auditor` | Security audits, UI/accessibility sweeps, pre-release bug hunts, remediation tracking |
| `qa-engineer` | Functional/E2E test automation, CI test wiring, suite triage, verifying bug fixes before close |

Each agent's persona file lives at `.project/<ROLE>-PERSONA.md` (the canonical voice) and its rule docs live at `.project/playbook/reference/rules/`.

Each agent pins its own model in its definition file. Ad hoc subagents do not, so they inherit the main session's model; when you dispatch one for reading or research, name a cheaper model for it. When you are the agent being dispatched, return conclusions and file paths, not the raw material you read, because your final message lands in the caller's context. The full discipline is in `.project/playbook/reference/rules/CONTEXT-ECONOMY.md`.

The lifecycle is in `.project/playbook/docs/LIFECYCLE.md`: eight stages, a lead for each, and the points where the end user persona comes back to check the work against `docs/USE_CASES.md` (design, build, ship, iterate). Lead means accountable, not alone. Agents cannot dispatch each other, so whoever runs the main session triggers those checks.

## When you discover something worth sharing

Project-level decisions, gotchas, and cross-agent handoff facts go in `.project/playbook/knowledge/<topic>.md` using the dated-entries convention in `.project/playbook/knowledge/README.md`. This is distinct from per-agent memory (one lane) and from personal session memory (one user, one machine).

If a fact matters to more than one agent or human reader, write it to the knowledge folder. If it only matters to the agent that learned it, it stays in that agent's MEMORY.md.

## Tool-specific entry points

### Claude Code (Anthropic)

Read `.claude/CLAUDE.md` (project conventions) and `.claude/SECURITY-POSTURE.md` (security rules). The agents in `.claude/agents/` are loaded automatically, and Claude Code watches that directory, so an added or edited definition is picked up within seconds with no reload. To see the team, run `ls .claude/agents/` or ask Claude; the `/agents` wizard was removed in Claude Code v2.1.198. Agents currently running are in `/tasks`. Skill invocation uses the `/<plugin>:<skill>` form (e.g. `/superpowers:writing-plans`). File mention uses `@path/to/file`. Persona invocation uses `@agent-<name>` or natural language.

### Codex (OpenAI)

Read this `AGENTS.md` file (Codex reads it natively at session start as the open-standard entry point used by Codex, Cursor, Gemini CLI, and Windsurf) plus `.project/playbook/README.md`. Read `.claude/SECURITY-POSTURE.md` if it exists (same six rules apply regardless of host tool); Codex does not auto-load it, so cite it explicitly.

**Subagents in Codex.** Native subagents in Codex use TOML files at `~/.codex/agents/<name>.toml` (personal) or `.codex/agents/<name>.toml` (project). The playbook ships only the Markdown + YAML form for Claude Code at `.claude/agents/`. Codex users get the persona-backed experience by reading the persona file at `.project/<ROLE>-PERSONA.md` and adopting the voice for the task; this is the manual fallback until parallel TOML subagent definitions ship in a future playbook release. List installed Codex subagents with `/agent` (no `s`); switch threads with `/agent`.

**Skill invocation in Codex.** Skills are invoked as `$<skillname>` in prose (e.g. `$writing-plans`) or via the `/skills` menu. The `obra/superpowers` plugin ships for Codex via the `/plugins` marketplace; install once per machine. Domain skills installed by the playbook's `install-skills.sh` (which writes to `~/.agents/skills/`) are picked up by Codex automatically since `$HOME/.agents/skills` is in Codex's skill lookup order.

**File mention in Codex.** Use `/mention` then path. There is no `@path/to/file` shorthand in Codex.

**MCP servers in Codex.** Add via `codex mcp add <server-name> --env VAR=val -- <command>` or list via `/mcp` slash command. STDIO and Streamable HTTP transports both supported (bearer or OAuth).

**Memory in Codex.** Codex has model-summarized "Memories" generated from idle sessions, stored at `~/.codex/memories/`. Off by default; enable with `memories.generate_memories` and `memories.use_memories` in `~/.codex/config.toml`. Unavailable in EEA, UK, Switzerland at launch. Treat Codex Memories as generated state, not source-of-truth; the hand-maintained source-of-truth for project decisions remains the knowledge folder at `.project/playbook/knowledge/`.

### Other AI coding agents

Read this file and `.project/playbook/README.md`. The persona files at `.project/<ROLE>-PERSONA.md` define the voice for each functional area. There is no automatic agent-loading equivalent in tools other than Claude Code (subagents) and Codex (`/agent`), so invoke a persona by reading its file and adopting its voice for the task.

For prompt-syntax mapping across the most common operations, see `reference/tools/SKILLS-INVENTORY.md` "Invocation syntax cheat sheet" section.

## Style and voice

The playbook does not impose a global style. Project-specific voice rules (commit identity, persona rules, style preferences) live in `.claude/CLAUDE.md` after the bootstrap script writes it for your project.
