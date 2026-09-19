# Skills Inventory

## About this file

The tools inventory for the playbook. Lives in `.project/playbook/reference/tools/` (separate from `rules/` because tooling and playbook are distinct concerns; rules are what the agent reads, tools are what is installed on the machine).

This file catalogs the AI coding agent plugin skills currently installed on the developer machine plus any companion CLI binaries those skills require, so a teammate or future read can see at a glance what tooling is available without crawling the plugin cache.

Entry point lives at `../README.md`. Getting started and install live at `../docs/USER-GUIDE.md`. The bootstrap wizard engine lives at `../START-PLAYBOOK.md`. The playbook rule docs live in `../rules/`. Persona templates live in `../personas/`.

Captured 2026-05-30 for Claude Code; Codex coverage added 2026-06-01. Re-check via `ls ~/.claude/plugins/cache/` (Claude Code) or `ls ~/.codex/plugins/` (Codex) if a plugin update is suspected.

## Tool support

The playbook is positioned for either of the two leading terminal AI coding agents in 2026.

| Agent | Status | Project-instructions file | Skills install location |
|---|---|---|---|
| **Claude Code** (Anthropic) | Primary; the wizard and install scripts are written for Claude Code | `.claude/CLAUDE.md` plus `.claude/SECURITY-POSTURE.md` | `~/.claude/plugins/cache/<plugin>/` plus `~/.agents/skills/` |
| **Codex** (OpenAI) | Supported; install path is partially manual until v1.7.0 ships a `--codex` flag on the install scripts | `AGENTS.md` at repo root (Codex walks from git root to cwd; closer-to-cwd files win) | `~/.codex/plugins/` plus `~/.agents/skills/` (shared with Claude Code) |

What is shared between the two tools.

- **Domain skills under `~/.agents/skills/`** are tool-agnostic and work in both Claude Code and Codex. The `install-skills.sh` script installs to this path via the underlying `npx skills add` commands. Codex's skill lookup order includes `$HOME/.agents/skills`, so anything `install-skills.sh` installs is automatically visible to Codex.
- **The `superpowers` plugin** ships for both Claude Code (`obra/superpowers` in the Claude Code marketplace) and Codex (`/plugins` marketplace). Same 14 skills, same workflows. Invocation syntax differs (see cheat sheet below).
- **The `parallel-cli` binary** is a regular CLI binary and works in either tool. The skill wrappers in `parallel-agent-skills` are Claude Code only; Codex users invoke `parallel-cli` directly.
- **The `AGENTS.md` file at the repo root** is the open-standard entry point Codex (and Cursor, Gemini CLI, Windsurf) reads. Claude Code reads `.claude/CLAUDE.md` instead but the `AGENTS.md` file is also useful as a non-tool-specific orientation doc.

What is not shared.

- **Subagent file format.** Claude Code subagents are Markdown with YAML frontmatter at `.claude/agents/<name>.md`. Codex subagents are TOML at `~/.codex/agents/<name>.toml` (personal) or `.codex/agents/<name>.toml` (project). The playbook ships only the Markdown form. Codex users get the persona-backed experience by reading `.project/<ROLE>-PERSONA.md` and asking Codex to adopt the voice, until parallel TOML subagent definitions ship in a future playbook release.
- **Memory.** Claude Code has hand-edited `MEMORY.md` files at `.claude/agent-memory/<agent>/MEMORY.md`. Codex has model-summarized "Memories" generated from idle sessions, stored at `~/.codex/memories/`. Codex Memories are unavailable in EEA/UK/CH at launch. Treat Codex Memories as generated state, not source-of-truth.

## Invocation syntax cheat sheet

For skills, agents, and common operations the prompts in this playbook reference. If a prompt uses Claude Code syntax (the default in this playbook), the Codex equivalent is in the right column.

| Operation | Claude Code | Codex |
|---|---|---|
| Invoke a `superpowers` skill | `/superpowers:<skill>` (e.g. `/superpowers:writing-plans`) | `$<skill>` in prose (e.g. `$writing-plans`) or `/skills` menu |
| Invoke a domain skill installed via `npx skills add` | Mention by name or via the Skill tool | Mention by name or via `/skills` menu (same lookup path) |
| List installed agents/subagents | `ls .claude/agents/`, or ask Claude (no slash command; the `/agents` wizard was removed in v2.1.198) | `/agent` (no `s`) |
| See agents currently running | `/tasks` (press `x` to stop one) | `/agent` to switch threads |
| List installed skills | (Not a slash command; surfaces in Skill tool) | `/skills` |
| Install a plugin | `/plugin marketplace add <url>` | `/plugins` marketplace browser |
| Reload after installing skills or plugins | `/reload-plugins` | Restart Codex (no equivalent reload command in current CLI) |
| Reload after installing agents | Nothing to run; Claude Code watches `.claude/agents/` and picks up changes within seconds | Restart Codex |
| Add an MCP server | `claude mcp add ...` | `codex mcp add <name> --env VAR=val -- <command>` |
| List MCP servers | `claude mcp list` | `/mcp` slash command or `codex mcp` subcommands |
| Reference a file in chat | `@path/to/file` | `/mention` then path |
| Invoke a persona-backed agent | `@agent-<name>` or natural language | Name the agent in prose, or `/agent` to switch threads (no `@-mention` for agents in Codex) |
| Pick a model | `/model`. Do it at the start of a session; a mid-session switch rereads the whole conversation uncached | `/model` |
| Set reasoning effort | `/effort`, or the slider in `/model` (`low` to `max`) | Not verified here |
| See what fills the context window | `/context` (`/context all` for the full breakdown) | Not verified here |
| See session cost and cache hit rate | `/usage` | Not verified here |
| Start clean between unrelated tasks | `/clear` (free; `/rename` first to find the session again) | Not verified here |
| Summarize a long session in place | `/compact <what to keep>` | Not verified here |
| Disable an MCP server without removing it | `/mcp`, then toggle the server | Not verified here |
| Draft a design on an editable canvas | `/design <brief>` (bundled skill, v2.1.234+; needs a claude.ai sign in on a paid plan; not on API key, Bedrock, Google Cloud, or Foundry). Process: `../rules/DESIGN-PRODUCTION.md` | Not verified here |
| Upload a React design system to Claude Design | `/design-sync [name]` (bundled skill; first sync can take hours on a large repo) | Not verified here |
| Chart and dashboard design guidance | `/dataviz <request>` (bundled skill, v2.1.198+) | Not verified here |
| Turn off a skill without deleting it | `skillOverrides` in `.claude/settings.json` (`"off"` or `"name-only"`) | Not verified here |
| Memory inspection | Read `.claude/agent-memory/<agent>/MEMORY.md` directly | `/memories` (per-thread; off by default; phased GA) |

## superpowers (v5.1.0)

14 skills for engineering workflow. Ships for both Claude Code and Codex.

- **Claude Code install:** done by the wizard in `START-PLAYBOOK.md` Phase 1 via the `install-core.sh` script. Invoked as `/superpowers:<skill>` (e.g. `/superpowers:writing-plans`).
- **Codex install:** open Codex, type `/plugins`, search "Superpowers" in the marketplace, install. Invoked as `$<skill>` in prose (e.g. `$writing-plans`) or via the `/skills` menu.

| Skill | What it does |
|---|---|
| **brainstorming** | Turns ideas into design specs via collaborative dialogue |
| **writing-plans** | Turns specs into bite-sized implementation plans |
| **executing-plans** | Executes an implementation plan inline, batch with checkpoints |
| **subagent-driven-development** | Executes a plan with fresh subagents per task and two-stage review |
| **dispatching-parallel-agents** | Dispatches parallel subagents for independent work |
| **finishing-a-development-branch** | Closes out work cleanly (tests, PR, branch state) |
| **requesting-code-review** | Template for asking a subagent to review code |
| **receiving-code-review** | Template for responding to review feedback |
| **systematic-debugging** | Disciplined debugging workflow |
| **test-driven-development** | TDD discipline (red, green, refactor) |
| **using-git-worktrees** | Creates and manages isolated git worktrees |
| **verification-before-completion** | Verifies work before marking it done |
| **writing-skills** | Authoring new skills |
| **using-superpowers** | Bootstrap skill that loads at session start |

## parallel-agent-skills (v0.4.4)

9 skills wrapping the Parallel.ai web research and data enrichment API. **Claude Code only.** Codex users invoke `parallel-cli` directly (the underlying CLI binary is tool-agnostic and works in either tool).

- **Claude Code install:** done by the wizard via `install-core.sh`. Invoked as `/parallel:<skill>` (e.g. `/parallel:parallel-deep-research`).
- **Codex install:** the skill wrappers do not ship for Codex. Codex users install `parallel-cli` directly (the wizard's `install-core.sh` does this regardless of the host tool) and call subcommands such as `parallel-cli research run "<query>" --processor pro-fast --text --no-wait --json` from a Bash tool call inside Codex. Recipes for the common operations live in `parallel-agent-skills` itself, which is readable as documentation even when not installed as a Codex plugin.

| Skill | What it does |
|---|---|
| **parallel-cli-setup** | Installs and authenticates `parallel-cli` |
| **parallel-web-search** | Fast web search via Parallel |
| **parallel-web-extract** | Extracts content from a specific URL |
| **parallel-deep-research** | Comprehensive multi-source research (slow but thorough) |
| **parallel-data-enrichment** | Enriches a list of entities with structured data |
| **parallel-findall** | Finds all instances matching a query |
| **parallel-monitor** | Monitors a research run in progress |
| **result** | Helper for fetching the result of a Parallel task |
| **status** | Helper for checking Parallel task status |

## loop-engineering (v1.1)

One skill for designing and scaffolding autonomous agent loops. Part of the **universal core** (installed on every machine regardless of project shape), because loop engineering is project-agnostic: CI repair, PR babysitting, incident response, and dependency triage apply to any SaaS.

- **What it does:** interviews the user to decide whether a recurring workflow should be a loop at all, fills an 11-part loop contract (goal, honest stop conditions, budget, maker/checker split, escalation paths), then scaffolds the runnable loop files. Triggers on "build a loop", "loop engineering", "/goal", "/loop", "Ralph loop", "maker/checker", "loop contract", "run this overnight".
- **Source:** `invincible04/awesome-loop-engineering` (MIT). Upstream also ships 13 docs chapters, a prompt library, and a runnable Python reference example worth reading: https://github.com/invincible04/awesome-loop-engineering
- **Install (both tools):** `npx skills add invincible04/awesome-loop-engineering --skill loop-engineering` — done by the wizard via `install-core.sh` Step 7. Tool-agnostic: it writes to `~/.agents/skills/loop-engineering`, which both Claude Code and Codex read. Requires Node 20+.
- **Invoke:** mention by name or via the Skill tool (Claude Code); `$loop-engineering` or the `/skills` menu (Codex).
- **Methodology:** the discipline behind the skill is documented in `../rules/LOOP-ENGINEERING.md`.

## Installed domain skills for this project

Installed via `bash .project/playbook/scripts/install-skills.sh all` on 2026-05-30. Update this section whenever a new domain skill is installed or removed.

**Tool-agnostic.** Domain skills install to `~/.agents/skills/` via the underlying `npx skills add` commands. Both Claude Code and Codex look in this path (Claude Code via its Skill tool, Codex via its `/skills` menu and `$skill` mention syntax). Anything in this table works in either tool without re-install.

| Pack | Skill | What it does |
|---|---|---|
| `xrpl` | `XRPL-Commons/xrpl-dev-skills` | End-to-end XRPL dev playbook. Covers NFTs (XLS-20), payments (XRP, cross-currency, escrows, checks, payment channels), client SDKs (xrpl.js, xrpl-py), wallet integration (Xaman, Crossmark, GemWallet), security patterns, native DEX/AMM (XLS-30), Axelar cross-chain interoperability |
| `xrpl` | `resend/resend-skills` | Five email skills: send, best-practices, React Email HTML, CLI management, inbound agent inbox |
| `xrpl` | `utkusen/sast-skills` | SAST scanning across 16 skill files covering 14 vulnerability classes (SQLi, XSS, SSRF, IDOR, RCE, JWT, hardcoded secrets, path traversal, SSTI, XXE, GraphQL injection, file upload, business logic, missing auth) plus analysis and report helpers |
| `xrpl-hooks` | (same skills as `xrpl`) | See rows above. Hooks-specific knowledge comes via WebFetch URL references rather than an installable skill (see "Domain context beyond skills" below) |
| `frontend` | `anthropics/claude-code` (frontend-design) | Modern frontend component patterns; avoids generic AI-styled UI output |
| `frontend` | `vercel-labs/agent-skills` (web-design-guidelines) | Vercel Labs general web design guidance |
| `frontend` | `vercel-labs/agent-skills` (vercel-react-best-practices) | React 19 patterns: Server Components, suspense, transitions, modern React mental model |
| `frontend` | `shadcn/ui` | Direct shadcn component generation, slot patterns, Radix primitives integration |
| `frontend` | `nextlevelbuilder/ui-ux-pro-max-skill` | Premium UX: progressive disclosure, trust signals, micro-interactions, motion design |
| `frontend` | `anthropics/skills` (web-artifacts-builder) | High-fidelity interactive UI previews shareable as artifacts |
| `baseline` | `getsentry/skills` | Production error tracking via Sentry, maps to `DEVELOPMENT-BUILD.md` Phase 8 (Monitoring) |

**Where these live on disk.** Skills installed via `npx skills add --global` typically write to `~/.agents/skills/<skill-name>/`. The `.agents/skills/` directory is a generic agent-skills convention that multiple AI tools (including Claude Code) read from. Verify with `ls ~/.agents/skills/` or `find ~ -path "*/.agents/skills/*" -name "SKILL.md" 2>/dev/null`. The two universal core plugins (`superpowers`, `parallel-agent-skills`) live separately at `~/.claude/plugins/cache/`.

**Maintenance.** When a new domain skill is installed (whether via `install-skills.sh` or `npx skills add` directly), add a row above. When a skill is removed (`npx skills remove <name>`), delete its row. The inventory is the single source of truth for what tooling this project depends on.

## Useful combinations

- **brainstorming → writing-plans → subagent-driven-development.** The canonical engineering trio. Design a spec, turn it into bite-sized tasks, execute with fresh subagents and two-stage review (spec compliance, then code quality).
- **using-git-worktrees → executing-plans → finishing-a-development-branch.** Isolated-worktree workflow. Useful when an in-flight change touches many files and you want the working tree separated from your main checkout.
- **parallel-deep-research.** Run when a research question is bigger than a quick web search. Tier `pro-fast` is a practical default. Output typically takes 10 to 30 minutes per query.

## Skill files on disk

- superpowers. `~/.claude/plugins/cache/claude-plugins-official/superpowers/<version>/skills/<skill-name>/`
- parallel-agent-skills. `~/.claude/plugins/cache/parallel-agent-skills/parallel/<version>/skills/<skill-name>/`

Each skill directory contains a `SKILL.md` with the canonical instructions Claude Code loads when the skill is invoked. Read that file directly to see exactly what a skill will do before invoking it.

## Companion CLI binaries

Some plugin skills wrap a CLI binary that must also be installed on the machine. Track these here alongside the skill inventory.

| Binary | Used by | Install |
|---|---|---|
| `parallel-cli` | `parallel:*` skills | `brew install parallel-web/tap/parallel-cli` (macOS), or `pipx install "parallel-web-tools[cli]"`, or `uv tool install "parallel-web-tools[cli]"`, or `npm install -g parallel-web-cli` |

Add a row when a new skill in the inventory depends on a CLI binary the machine needs.

## Tool search: keeping tool context lean

As a project accumulates skills, MCP servers, and tools, all those definitions compete for the context window, and tool selection gets less accurate past thirty or so options. The tool search tool is the Claude mechanism that fixes this. It loads tool definitions on demand instead of all up front. You mark the rarely used tools with `defer_loading: true`, and the model searches a catalog for what it needs when it needs it, by name or description. The canonical reference is in the table under "Domain context beyond skills" below.

This matters in three places for a playbook project, with one exception to know about.

- **Products you build.** When the product itself calls the Claude API with many tools, use tool search to control context bloat and keep tool selection accurate. The full build-time guidance, including when to reach for it and the practices that make it work, lives in `../rules/DEVELOPMENT-BUILD.md` under "When the product builds its own AI agent features".
- **The coding agent's own context.** Claude Code uses the same tool search mechanism for its own tools. As you add MCP servers to the project (`claude mcp add ...`), their tools are discovered on demand rather than loaded into every session. This is why the inventory below can grow without bloating each session. Add servers your project needs and let the search surface them.
- **Skills are the exception.** Tool search defers MCP tool definitions. It does not defer skill descriptions. Every installed skill loads its description (up to 1,536 characters) into every session, and only the skill body waits for invocation. So the inventory cannot grow for free on the skills side: install the packs a project needs, and turn off the rest with `skillOverrides`. The how is in `../rules/CONTEXT-ECONOMY.md` Rule 2.
- **This inventory is the catalog.** Treat this file as the searchable list you and the agent consult to find the right skill or MCP server when a need comes up mid-build. The "Examples by project shape" and "Domain context beyond skills" tables below are the entries to search. When you install something new, add a row so the next search finds it.

## Domain-specific skills

The playbook assumes the core skills above (`superpowers`, `parallel-agent-skills`, and `loop-engineering`, plus the `parallel-cli` binary) are installed everywhere. Domain-specific skills are different. Install them based on what your project actually does and what its dependencies look like.

### Where to find domain skills

- **Claude Marketplaces.** https://claudemarketplaces.com/
- **MCP Market.** https://mcpmarket.com/ (also indexes MCP servers, not just skills)
- **Awesome Claude Skills.** https://github.com/ComposioHQ/awesome-claude-skills
- **Anthropic's official skills repo.** https://github.com/anthropics/skills
- **Community curated list.** https://github.com/inbharatai/claude-skills

### How to install a domain skill

Most are installable via the `npx skills add` command, either by GitHub `org/repo` shorthand or full URL.

```bash
# Shorthand form
npx skills add resend/resend-skills

# Full URL form
npx skills add https://github.com/XRPL-Commons/xrpl-dev-skills
```

After install, reload plugins inside Claude Code so the new skill registers.

```
/reload-plugins
```

Then verify the skill loaded by invoking it or listing it via the relevant marketplace command (e.g. `/superpowers` for superpowers-style skills; many skills appear under their own namespace slash command).

### Examples by project shape

| Project shape | Worth installing | Install command |
|---|---|---|
| **XRPL / Ripple ecosystem** | `XRPL-Commons/xrpl-dev-skills` covering NFTs (XLS-20), payments (XRP, cross-currency, escrows, checks, payment channels), client SDKs (xrpl.js, xrpl-py), wallet integration (Xaman, Crossmark, GemWallet), security patterns, native DEX/AMM (XLS-30: AMMCreate, Deposit, Withdraw, Bid, Vote, LP tokens, auction slots), tokens, interoperability. Hooks are NOT included; see the Hooks row below | `npx skills add https://github.com/XRPL-Commons/xrpl-dev-skills` |
| **XRPL Hooks (Xahau)** | No installable Claude skill exists. Hooks knowledge (SetHook transactions, WASM and C patterns, deployment to Hooks Testnet and Xahau mainnet, common use cases like NFT royalty enforcement, payment automation, account firewalls, spend limits) is fetched on demand via WebFetch from the URLs in "Domain context beyond skills" below | None. Use WebFetch with https://xrpl-hooks.readme.io/docs/introduction and https://hooks.xrpl.org/ |
| **EVM / Ethereum** | Ethereum Development Master, Solidity Contract Patterns (with OpenZeppelin RBAC/UUPS patterns), Smart Contract Security Audit (Slither, Foundry) | See https://mcpmarket.com/ |
| **Email-heavy SaaS** | Resend Agent Skills bundle (five skills: send, best-practices, React Email HTML, CLI management, inbound agent inbox) | `npx skills add resend/resend-skills` |
| **Diagram-as-code workflows** | Mermaid (`WH-2099/mermaid-skill`, 23 diagram types) or PlantUML (`SpillwaveSolutions/plantuml`) for sequence diagrams, ER diagrams, Gantt charts. Complements (does not replace) Gemini Nano Banana for the higher-design editorial canvases | `npx skills add WH-2099/mermaid-skill` |
| **Security-focused (any SaaS)** | `utkusen/sast-skills` for SAST scanning across 14 vulnerability classes (SQLi, XSS, SSRF, IDOR, RCE, JWT, hardcoded secrets, path traversal, SSTI, XXE, GraphQL injection, file upload, business logic, missing auth) plus analysis and report helpers. Gitleaks integration for secret scanning per the `SECURITY-POSTURE.md` Rule 1 | `npx skills add utkusen/sast-skills` |
| **Error tracking and observability** | Sentry Agent Skills (`getsentry/skills`), official maintained by Sentry | `npx skills add getsentry/skills` |
| **SaaS with marketing email programs** | SendGrid Automation for list management and campaign analytics | See https://mcpmarket.com/ |
| **Frontend-heavy SaaS with strict tech-stack opinions** | Anthropic's official `frontend-design` skill (avoids generic AI-styled UI output) and Vercel Labs' `web-design-guidelines` skill (general design guidance, complements the Anthropic skill). Pair with a project-specific DESIGNER and DEVELOPER persona customization that names the exact stack | `npx skills add anthropics/claude-code --skill frontend-design`, plus `npx skills add vercel-labs/agent-skills --skill web-design-guidelines` |
| **Premium UX / UI ambitions** | `nextlevelbuilder/ui-ux-pro-max-skill` for design intelligence beyond the default component library; covers patterns like progressive disclosure, trust signals, micro-interactions, motion design | `npx skills add https://github.com/nextlevelbuilder/ui-ux-pro-max-skill` |
| **Design-system-driven UI** | `shadcn/ui` skill for direct shadcn component generation, slot patterns, and Radix primitives integration | `npx skills add shadcn/ui` (or via Claude Code marketplace: `/plugin install shadcn@claude-code-skills`) |
| **High-fidelity preview / artifact-driven design review** | Anthropic's `web-artifacts-builder` skill for shareable interactive previews of UI changes | `npx skills add anthropics/skills --skill web-artifacts-builder` |
| **React component quality** | Vercel Labs' `vercel-react-best-practices` skill enforcing modern React 19 patterns (Server Components, suspense, transitions) | `npx skills add vercel-labs/agent-skills --skill vercel-react-best-practices` |

### Domain context beyond skills

Some domain ecosystems publish curated context files that Claude can fetch on demand via `WebFetch` during a session. Capturing these in this file gives future sessions a single place to look up the canonical reference URLs.

| Domain | Reference URL | What it covers |
|---|---|---|
| **XRPL** | https://xrpl.org/llms.txt | Single-URL ingest of the full developer reference set (concepts, tutorials, client libraries, transaction types, security) |
| **XRPL MCP** | https://xrpl.org/mcp | Model Context Protocol server for live XRPL docs lookups |
| **XRPL AI tools index** | https://xrpl.org/resources/dev-tools/ai-tools | Catalog of XRPL-aware AI development tools |
| **XRPL Hooks docs** | https://xrpl-hooks.readme.io/docs/introduction | Full Hooks introduction, SetHook transactions, lifecycle, examples |
| **XRPL Hooks Builder** | https://hooks.xrpl.org/ | Interactive Hooks development environment with deployment to Xahau Hooks Testnet |
| **XRPL AMM tutorial** | https://xrpl.org/docs/tutorials/defi/dex/create-an-automated-market-maker | Step-by-step AMMCreate tutorial covering pool seeding and deposit/withdraw flows |
| **XRPL AMM code samples** | https://github.com/XRPLF/xrpl-dev-portal/tree/master/_code-samples/create-amm | Runnable JavaScript and Python samples for AMM operations |
| **shadcn/ui registry** | https://ui.shadcn.com | Component catalog, install commands, customization patterns for the shadcn/Radix design system |
| **Tailwind CSS v4 docs** | https://tailwindcss.com | Utility classes, v4 changes, configuration reference |
| **Next.js 15 docs** | https://nextjs.org/docs | App Router, Server Components, Server Actions, deployment patterns |
| **Web3 UX patterns** | https://web3ux.design | Transaction-state UX, wallet-connection flows, trust-signal patterns specific to crypto products |
| **Claude tool search** | https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool | On-demand tool loading via `defer_loading`, regex and BM25 search variants, the MCP connector setup, limits, and best practices. Read when a product wires up ten or more tools or multiple MCP servers |
| **Claude Agent SDK (agent loop)** | https://code.claude.com/docs/en/agent-sdk/agent-loop | The autonomous agent loop for products you build: message lifecycle, the built-in `ToolSearch` (on-demand tool discovery) and `Agent` (subagent spawn) tools, MCP schema deferral, permission modes, and the `maxTurns` / `maxBudgetUsd` budget controls. Read when a product needs an agent that loops rather than a single API call |

For your own project domain, document the authoritative reference URLs here once. Future sessions then have a single source of truth for where to fetch context when working in that domain.

### Advanced. Community-maintained agent and persona collections

For projects that need more pre-built personas than the 15 in `../agents/`, two large community-maintained collections are worth knowing about. These are alternatives or supplements to the playbook's curated set, not replacements.

| Collection | Scale | Install | Notes |
|---|---|---|---|
| **`wshobson/agents`** | 184 agents, 16 multi-agent workflow orchestrators, 150 skills, 78 plugins, four-tier model strategy | `git clone https://github.com/wshobson/agents.git` into `~/.claude/agents/`, or `npx skills add wshobson/agents --skill <name>` for individual skills | Plugin-marketplace structure with model assignment per agent (Opus, Sonnet, Haiku, Inherit). Heavyweight; pick individual skills rather than installing the whole tree. |
| **`msitarzewski/agency-agents`** | 147 specialized agents organized across 12 divisions (engineering, design, marketing, product management, project management, testing, technical support, spatial computing, more) | `git clone https://github.com/msitarzewski/agency-agents.git` then `scripts/convert.sh` + `scripts/install.sh` (interactive picker), or manual copy of selected agents to `~/.claude/agents/` | Multi-platform (Claude Code, GitHub Copilot, Cursor, Windsurf, Aider, etc.); pick the divisions relevant to your project. |
| **`contains-studio/agents`** | Dozens, organized by department (design, engineering, marketing, etc.) | `git clone` and copy selected agents to `~/.claude/agents/` | Smaller, focused, production-tested by the contains-studio team. |

The playbook's `../agents/` set is intentionally focused on 15 generally-useful personas mapped to specific rule docs in this playbook. The community collections above are useful when a project needs deep specialization (e.g., a "mobile app builder" or "spatial computing" agent) that the playbook does not ship.

### Tier guide for the recommendations above

The playbook classifies the Claude Code skill ecosystem into four tiers.

- **Tier A. Install now, broadly useful for any SaaS.** Resend agent skills. `utkusen/sast-skills`. Mermaid diagram expert.
- **Tier B. Install when the relevant phase kicks in.** Gitleaks secret scanning. Sentry agent skills.
- **Tier C. Evaluate based on project specifics.** Smart contract security audit. Skill evaluation framework.
- **Tier D. Avoid due to maintenance, security, or fit concerns.** Slack MCP server toolkit (0 stars, unverified maintenance as of the research).

The research file has the full citation set and reasoning for each tier assignment.

## Next

Read `../rules/TEAM-PERSONAS.md` for the team-of-personas concept that complements these skills and the `.project/` directory pattern that houses them. The persona templates themselves live in `../personas/`.
