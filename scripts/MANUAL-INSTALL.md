# Manual Install Guide

## About this file

The manual alternative to `../docs/USER-GUIDE.md`. Same outcome (universal core installed, optional domain skills installed, project bootstrap ready), more reading, fewer scripts.

Read this file when:

- You want to understand each install step in detail before running it.
- A script in `scripts/` fails and you want to diagnose by running the underlying commands by hand.
- Your environment differs from what the scripts assume (different package manager, no Node, restricted network, etc.).

If you just want to get going, follow `../docs/USER-GUIDE.md` instead. The scripts there cover what is documented in this file.

Two parts.

- **Part 1.** The universal core. Install Claude Code, the two core plugins (`superpowers`, `parallel-agent-skills`), the `parallel-cli` binary, and the `loop-engineering` skill. One-time per machine, roughly 15 to 25 minutes if done manually.
- **Part 2.** Domain-specific skills. Install per project based on what the project does (XRPL, Resend, frontend, security, etc.). Skip if your project does not need any.

Two of the Part 1 steps run **inside Claude Code** (look for the prompt `>`). The rest run in a **regular terminal**. Headings call out where each step happens. Every install command lives in its own code fence so you can copy-paste a single command in one click.

The full landscape of installable skills with tier classifications (A through D) lives in `../reference/tools/SKILLS-INVENTORY.md`. This doc is the install procedure; the inventory is the catalog.

---

# Part 1. Universal core install

If your machine already has Claude Code, the `superpowers` plugin, the `parallel-agent-skills` plugin, `parallel-cli`, and the `loop-engineering` skill working, skip to Part 2.

Steps 1 through 9 below install each component by hand. The same outcome is produced by running `bash .project/playbook/scripts/install-core.sh` from your project root (see `../docs/USER-GUIDE.md`).

## Step 1. Install Claude Code (regular terminal)

Claude Code is Anthropic's official command-line tool for Claude. Install it by following the official guide at https://docs.claude.com/en/docs/claude-code.

After install, confirm.

```bash
claude --version
```

You should see a version string.

## Step 2. Open Claude Code (regular terminal)

From any directory, run.

```bash
claude
```

You are now inside a Claude Code session. The next four sub-steps in Step 3 happen at the Claude Code prompt (`>`), not in a regular terminal.

## Step 3. Install the `superpowers` plugin (inside Claude Code)

The `superpowers` plugin gives Claude the engineering skills the playbook uses (brainstorming, writing-plans, subagent-driven-development, and more). Type each slash command at the Claude Code prompt.

### 3a. Register the marketplace

This points Claude Code at the marketplace where the `superpowers` plugin lives. You only do this once per machine.

```
/plugin marketplace add obra/superpowers-marketplace
```

### 3b. Install the plugin

```
/plugin install superpowers@superpowers-marketplace
```

### 3c. Reload plugins so the new install activates

```
/reload-plugins
```

### 3d. Verify the install worked

```
/superpowers
```

You should see a list of skills.

## Step 4. Exit Claude Code and return to a regular terminal

```
/exit
```

## Step 5. Install the `parallel-cli` binary (regular terminal)

The `parallel-agent-skills` plugin (installed in Step 7 below) calls a command-line tool called `parallel-cli` to talk to the Parallel API. Install `parallel-cli` first; the plugin install in Step 7 will use it.

Pick whichever package manager fits your machine. Each option is its own copy-paste-ready block.

### Option A. macOS via Homebrew (recommended on macOS)

```bash
brew install parallel-web/tap/parallel-cli
```

### Option B. Linux or cross-platform via pipx

```bash
pipx install "parallel-web-tools[cli]" && pipx ensurepath
```

### Option C. Cross-platform via uv

```bash
uv tool install "parallel-web-tools[cli]"
```

### Option D. Cross-platform via npm

```bash
npm install -g parallel-web-cli
```

After install, verify.

```bash
parallel-cli --version
```

## Step 6. Authenticate `parallel-cli` and add API credit (regular terminal)

### 6a. Open the OAuth login flow

```bash
parallel-cli login
```

A browser window opens. Sign in with your Parallel account (create one at https://platform.parallel.ai if you do not have one).

### 6b. Add credit at the dashboard

Visit https://platform.parallel.ai/settings and add credit. Even $5 covers many small projects.

### 6c. Verify auth

```bash
parallel-cli auth --json
```

You should see JSON with `"authenticated": true`.

### 6d. Verify balance

```bash
parallel-cli balance get
```

You should see a non-zero balance.

## Step 7. Install the `parallel-agent-skills` plugin via parallel-cli (regular terminal)

Unlike `superpowers`, the `parallel-agent-skills` plugin is installed by the `parallel-cli` binary itself rather than via a Claude Code marketplace command.

```bash
parallel-cli skills install
```

## Step 7b. Install the `loop-engineering` skill (regular terminal)

The `loop-engineering` skill designs and scaffolds autonomous agent loops (CI repair, PR babysitting, incident response, dependency triage). It is part of the universal core because loops apply to any SaaS. Unlike the rest of Part 1, this step uses `npx skills add`, which needs **Node 20+** (install from https://nodejs.org if you do not have it; see the Part 2 prerequisite). The skill is tool-agnostic and works in both Claude Code and Codex.

```bash
npx skills add invincible04/awesome-loop-engineering --skill loop-engineering
```

It installs to `~/.agents/skills/loop-engineering`. Verify.

```bash
ls ~/.agents/skills/loop-engineering
```

## Step 8. Re-open Claude Code and reload (regular terminal, then inside Claude Code)

### 8a. Re-open Claude Code

```bash
claude
```

### 8b. Reload plugins

```
/reload-plugins
```

### 8c. Verify the parallel skills are present

```
/parallel:parallel-deep-research
```

You should see the skill activate (it asks for a research topic). Cancel out with Ctrl+C; you do not need to actually run a research query just to verify.

## Step 9. Final core verification (regular terminal)

### 9a. Claude Code

```bash
claude --version
```

### 9b. superpowers plugin

```bash
ls ~/.claude/plugins/cache/claude-plugins-official/superpowers/
```

### 9c. parallel-agent-skills plugin

```bash
ls ~/.claude/plugins/cache/parallel-agent-skills/parallel/
```

### 9d. parallel-cli binary

```bash
parallel-cli --version
```

### 9e. parallel-cli auth

```bash
parallel-cli auth --json
```

### 9f. parallel-cli balance

```bash
parallel-cli balance get
```

### 9g. loop-engineering skill

```bash
ls ~/.agents/skills/loop-engineering
```

Every command should succeed. The universal core is complete. Continue to Part 2 if your project needs domain-specific skills, or return to `../docs/USER-GUIDE.md` for the bootstrap prompt.

---

# Part 2. Domain-specific skills install

Domain-specific skills complement the universal core. Install them based on what a particular project does. Skip this part if your project does not need any of the domains below.

The four common combinations are also available as starter packs via `bash .project/playbook/scripts/install-skills.sh <pack>` where `<pack>` is `xrpl`, `xrpl-hooks`, `frontend`, `baseline`, or `all` (shorthand for all four packs at once). See `../docs/USER-GUIDE.md`. The catalog below covers every supported skill including ones not in any pack.

## Prerequisite for Part 2

Most Part 2 installs use `npx skills add ...`, which requires Node.js. Install Node 20 or newer from https://nodejs.org or via your platform's package manager, then confirm.

```bash
node --version
```

You should see `v20.x.x` or newer. If your project does not use any `npx skills add` based skill (for example, only MCP-based skills from https://mcpmarket.com/), Node is not strictly required.

## The install pattern (works for every skill in the catalog)

Each domain skill follows the same four sub-steps. Substitute the install command from the catalog.

### Pattern step 1. Run the install in a regular terminal

**Where to find skills to install.** Two cross-referenced sources.

- **`../reference/tools/SKILLS-INVENTORY.md`** is the canonical inventory. It catalogs the universal core skills already installed and recommends domain skills organized by project shape (XRPL, Hooks, EVM, email-heavy, frontend, etc.) with a description and install command per entry. A tier guide at the bottom of that file classifies the broader ecosystem (A install now, B install when the phase kicks in, C evaluate per project, D avoid). It also lists canonical reference URLs per domain that Claude can fetch on demand. Read the inventory first to decide *what* to install on this project.
- The **catalog section further down in this file** (under "Catalog: install commands per skill") is the install-only view. Each entry is a single copy-paste-ready code fence. Use it to *paste and run*.

If a skill exists in the wild that is not in `../reference/tools/SKILLS-INVENTORY.md` yet, add a row there first (so the inventory stays the single source of truth for what the project depends on), then add the install command to the catalog section below, then run it.

```bash
# Substitute the actual install command from the catalog
npx skills add <org>/<skill-name>
```

### Pattern step 2. Reload plugins inside Claude Code

```
/reload-plugins
```

If you exited Claude Code earlier, re-open it first.

```bash
claude
```

### Pattern step 3. Verify the skill loaded

Try a known command from the skill (most skills register slash commands under a namespace), or check the cache directory.

```bash
ls ~/.claude/plugins/cache/
```

### Pattern step 4. Update the inventory

Add a row to `../reference/tools/SKILLS-INVENTORY.md` so the inventory matches what is actually installed.

## Catalog: install commands per skill

Each skill below has a single-command code fence ready to copy and paste.

### XRPL ecosystem

#### XRPL-Commons/xrpl-dev-skills

Any XRPL project. Covers NFTs (XLS-20), payments (XRP, cross-currency, escrows, checks, payment channels), client SDKs (xrpl.js, xrpl-py), wallet integration (Xaman, Crossmark, GemWallet), security patterns, and native DEX/AMM (XLS-30: AMMCreate, Deposit, Withdraw, Bid, Vote, LP tokens, auction slots). Hooks are NOT covered; see the next entry.

```bash
npx skills add https://github.com/XRPL-Commons/xrpl-dev-skills
```

#### Xahau Hooks knowledge (no installable skill)

`wojake/XRPL-Protocol-Network-Hooks-Docs` was previously listed here, but it is a documentation repo, not a valid Claude skill (no `SKILL.md`), and `npx skills add` rejects it. For Xahau Hooks knowledge (SetHook transactions, WASM and C patterns, deployment to Hooks Testnet and Xahau mainnet, common use cases like NFT royalty enforcement, payment automation, spend limits, account firewalls), point Claude at the reference URLs via WebFetch on demand:

- https://xrpl-hooks.readme.io/docs/introduction
- https://hooks.xrpl.org/

See `../reference/tools/SKILLS-INVENTORY.md` "Domain context beyond skills" for the canonical list.

### Email and customer communications

#### resend/resend-skills

Any SaaS using Resend for transactional or marketing email. Bundle of five skills: send, best-practices, React Email HTML, CLI management, inbound agent inbox.

```bash
npx skills add resend/resend-skills
```

### Diagrams and visual docs

#### WH-2099/mermaid-skill

Diagram-as-code workflows. 23 diagram types (sequence, ER, Gantt, etc.). Complements Gemini Nano Banana for higher-design editorial canvases.

```bash
npx skills add WH-2099/mermaid-skill
```

#### SpillwaveSolutions/plantuml

Architecture diagram-as-code.

```bash
npx skills add SpillwaveSolutions/plantuml
```

### Security and compliance

#### utkusen/sast-skills

Any production-bound SaaS. SAST scanner covering 14 vulnerability classes (SQLi, XSS, SSRF, IDOR, RCE, JWT, hardcoded secrets, path traversal, SSTI, XXE, GraphQL injection, file upload, business logic, missing auth) plus analysis and report helpers across 16 skill files. Supports `SECURITY-POSTURE.md` Rules 2 and 5.

```bash
npx skills add utkusen/sast-skills
```

#### Gitleaks Secret Scanning

Pre-commit secret scanning. Supports `SECURITY-POSTURE.md` Rule 1. Discovery and install via https://mcpmarket.com/.

### Observability

#### getsentry/skills

Production error tracking via Sentry. Maps to `rules/DEVELOPMENT-BUILD.md` Phase 8 (Monitoring and incident response).

```bash
npx skills add getsentry/skills
```

### Frontend and UX

#### anthropics/claude-code (frontend-design)

Frontend-heavy SaaS. Avoids generic AI-styled UI output by enforcing modern component patterns.

```bash
npx skills add anthropics/claude-code --skill frontend-design
```

#### vercel-labs/agent-skills (web-design-guidelines)

General web design guidance from Vercel Labs. Complements `anthropics/claude-code --skill frontend-design` rather than duplicating it.

```bash
npx skills add vercel-labs/agent-skills --skill web-design-guidelines
```

#### vercel-labs/agent-skills (vercel-react-best-practices)

React 19 modern patterns. Server Components, suspense, transitions, the modern React mental model.

```bash
npx skills add vercel-labs/agent-skills --skill vercel-react-best-practices
```

#### shadcn/ui

Direct shadcn component generation, slot patterns, Radix primitives integration.

```bash
npx skills add shadcn/ui
```

Slash-command alternative inside Claude Code.

```
/plugin install shadcn@claude-code-skills
```

#### nextlevelbuilder/ui-ux-pro-max-skill

Premium UX patterns beyond the default component library. Progressive disclosure, trust signals, micro-interactions, motion design.

```bash
npx skills add https://github.com/nextlevelbuilder/ui-ux-pro-max-skill
```

### Design review and previews

#### anthropics/skills (web-artifacts-builder)

Shareable high-fidelity interactive previews of UI changes.

```bash
npx skills add anthropics/skills --skill web-artifacts-builder
```

### EVM / Ethereum ecosystem

#### Ethereum Development Master, Solidity Contract Patterns, Smart Contract Security Audit

Discovery and install via https://mcpmarket.com/. EVM-based projects (Ethereum mainnet, Layer 2s, sidechains) covering OpenZeppelin RBAC/UUPS patterns and Slither/Foundry-based contract analysis.

## Common starter packs (copy a whole block at once)

If your project shape fits one of these common patterns, copy the matching block to run all the relevant installs in one go.

### Starter pack. XRPL SaaS

```bash
npx skills add https://github.com/XRPL-Commons/xrpl-dev-skills
npx skills add resend/resend-skills
npx skills add utkusen/sast-skills
```

### Starter pack. XRPL SaaS with Xahau Hooks

Same installable skills as the XRPL SaaS pack (Hooks-specific knowledge is URL-only; see the Hooks knowledge entry above).

```bash
npx skills add https://github.com/XRPL-Commons/xrpl-dev-skills
npx skills add resend/resend-skills
npx skills add utkusen/sast-skills
```

### Starter pack. Frontend-heavy SaaS with strict tech stack (Next.js 15 + shadcn/ui)

```bash
npx skills add anthropics/claude-code --skill frontend-design
npx skills add vercel-labs/agent-skills --skill web-design-guidelines
npx skills add vercel-labs/agent-skills --skill vercel-react-best-practices
npx skills add shadcn/ui
npx skills add https://github.com/nextlevelbuilder/ui-ux-pro-max-skill
npx skills add anthropics/skills --skill web-artifacts-builder
```

### Starter pack. Production-ready SaaS (any domain) baseline

```bash
npx skills add utkusen/sast-skills
npx skills add getsentry/skills
npx skills add resend/resend-skills
```

After running any starter pack, reload plugins inside Claude Code.

```
/reload-plugins
```

Then update `../reference/tools/SKILLS-INVENTORY.md` to reflect what is installed.

## Notes on the install patterns

- **The `--skill <name>` flag** selects a single skill from a parent skill collection (used above for `anthropics/claude-code`, `vercel-labs/agent-skills`, `anthropics/skills`). Without the flag, the install adds all skills the parent collection ships.
- **The slash-command marketplace form** (`/plugin install <name>@<marketplace>`) is the alternative install path that the `superpowers` plugin uses (see Part 1 Step 3). Most domain skills use the `npx skills add` form instead. When both forms exist (e.g. `shadcn/ui`), pick whichever you prefer.
- **Skills that wrap a CLI binary** may have a separate binary install plus the skill install. The `parallel-agent-skills` plugin wrapping the `parallel-cli` binary in Part 1 Steps 5 to 7 is the canonical example.
- **After every install**, do not skip `/reload-plugins`. Without it, the skill is on disk but Claude Code has not picked it up for the current session.
- **For projects with strong tech-stack opinions**, pair the skill installs with project-specific persona customization. The project's working `.project/DESIGNER-PERSONA.md` and `.project/DEVELOPER-PERSONA.md` should name the chosen stack and the non-negotiable conventions. See `personas/DESIGNER-PERSONA.md` "Tech-stack customization" section for the override-block pattern.

## Where to find more skills beyond the catalog above

- **Claude Marketplaces.** https://claudemarketplaces.com/
- **MCP Market.** https://mcpmarket.com/
- **Awesome Claude Skills.** https://github.com/ComposioHQ/awesome-claude-skills
- **Anthropic's official skills repo.** https://github.com/anthropics/skills
- **Community curated list.** https://github.com/inbharatai/claude-skills

The tier guidance and skill recommendations above are the playbook's curated set. Update them as the Claude Code skill ecosystem evolves.

## Knowledge URLs worth bookmarking per domain

Some ecosystems publish curated reference URLs Claude can fetch on demand. The canonical set lives in `../reference/tools/SKILLS-INVENTORY.md` "Domain context beyond skills" section. Add new entries there as you discover them.

---

When everything in Part 1 is installed and the relevant Part 2 skills are added, return to `../docs/USER-GUIDE.md` for the bootstrap prompt that kicks off a new project. After the agent install (User Guide Step 6c or wizard Phase 3), run the read-only health check from your project root to confirm the whole install in one pass:

```bash
bash .project/playbook/scripts/verify-install.sh
```
