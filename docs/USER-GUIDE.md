# User Guide

Everything you do with the playbook after cloning it: install and bootstrap a new project, work with the team day to day, and pull updates into an existing project.

For the eight-stage lifecycle methodology, see [`LIFECYCLE.md`](LIFECYCLE.md). For folder layout and how the pieces fit, see [`ARCHITECTURE.md`](ARCHITECTURE.md).

## Contents

- [Getting started](#getting-started) — install, bootstrap, set up the agents
  - [Step 1. Install your AI coding tool](#step-1-install-your-ai-coding-tool-once-per-machine)
  - [Step 2. Create your project folder and clone the playbook](#step-2-create-your-project-folder-and-clone-the-playbook)
  - [Step 3. Drop project materials into the input folder](#step-3-preferred-drop-project-materials-into-the-input-folder)
  - [Step 4. Open Claude Code from your project root](#step-4-open-claude-code-from-your-project-root)
  - [Step 5. Run the conversational bootstrap wizard](#step-5-run-the-conversational-bootstrap-wizard-optional-shortcut-recommended-for-first-time-users)
  - [Step 6. Install the three tools](#step-6-install-the-three-tools)
  - [Step 7. Set up the AI agents](#step-7-set-up-the-ai-agents)
  - [Step 8. Begin Stage 1 (Concept)](#step-8-begin-stage-1-concept)
- [Working with the team](#working-with-the-team) — invoking agents, switching personas, memory
- [Updating the playbook](#updating-the-playbook) — pull the latest into an existing install
- [Adopting the playbook in an existing project](#adopting-the-playbook-in-an-existing-project) — what the wizard reads, merges, and never overwrites
- [Producing design assets](#producing-design-assets) — design system first, templates, project skills, review on a canvas
- [Keeping sessions lean](#keeping-sessions-lean) — six habits that cut token spend, and the handoff prompt
- [Refresh prompt](#refresh-prompt) — re-orient a long or compacted session

## Getting started

Eight steps from a clean machine to a working project with a customized team. Step 5 is the recommended one-paste shortcut (the conversational bootstrap wizard) that handles Steps 6 and 7 for you in one flow, end to end in about 15 to 25 minutes. Steps 6 and 7 are the manual path for users who want to drive each install command and customize personas themselves; the manual path takes about 30 to 45 minutes. Step 6 installs the three tools. Step 7 sets up the AI agents (verify, learn how to invoke, smoke test, customize personas) and gets its own step because the AI agent team is the load-bearing piece of this playbook.

### Step 1. Install your AI coding tool (once per machine)

The playbook works with either Claude Code or Codex. Pick whichever you prefer. The wizard, install scripts, and most example prompts in this playbook are written for Claude Code; a Codex equivalent for each common operation lives in the Invocation syntax cheat sheet at `.project/playbook/reference/tools/SKILLS-INVENTORY.md`.

**Claude Code (Anthropic).** Install from https://docs.claude.com/en/docs/claude-code. Confirm on PATH.

```bash
claude --version
```

**Codex (OpenAI).** Install from https://developers.openai.com/codex/cli. Confirm on PATH.

```bash
codex --version
```

Skip if your chosen tool already prints a version string. You can install both side-by-side on the same machine if you want to switch between them later; they do not conflict.

### Step 2. Create your project folder and clone the playbook

```bash
mkdir -p ~/projects/<your-project-name>
cd ~/projects/<your-project-name>
git clone https://github.com/realgrapedrop/grapedrop-playbook .project/playbook
echo ".project/" >> .gitignore
```

Replace `<your-project-name>` with whatever you want to call your project. The clone URL above is the playbook repo (the one you are reading right now). The `.gitignore` line keeps the playbook clone and your private persona files out of your project's history once you run `git init`. `verify-install.sh` warns if it is missing.

**Adding the playbook to a repository you already have?** Skip the `mkdir`, run the other two lines from your repo root with the `.gitignore` line first, and read [Adopting the playbook in an existing project](#adopting-the-playbook-in-an-existing-project) before Step 5.

### Step 3. (Preferred) Drop project materials into the input folder

If you have any existing materials about the project (PDF concept doc, pitch deck, feature list, customer notes, brand notes, anything), drop them into `.project/playbook/input/`. The more the wizard in Step 5 has to read, the more it can decide for you autonomously and the less back-and-forth you have during the proposal review.

```bash
ls .project/playbook/input/
```

The cause and effect is direct. With good materials in `input/`, the wizard infers your project's regulatory scope, audience, product category, and stage from the inputs and applies the right defaults across every persona automatically. With nothing in `input/`, the wizard either falls back to a conversational brainstorm (which works but adds 10 to 15 minutes of dialogue) or installs a vanilla team with no customization (you can come back later to customize each persona, but that work shifts to later instead of being done upfront).

You can still skip this step. The wizard handles an empty `input/` cleanly. But if you have anything project-relevant on disk already, putting it in `input/` is the single biggest thing you can do to make the rest of the bootstrap fast and accurate. Contents of `input/` are gitignored, so private materials stay private.

### Step 4. Open Claude Code from your project root

```bash
claude
```

Keep this Claude Code window open for the rest of the bootstrap. Step 5 uses it directly for the wizard prompt. Steps 6 and 7 (the manual path) also use it for slash commands and the agent setup.

### Step 5. Run the conversational bootstrap wizard (optional shortcut, recommended for first-time users)

The playbook ships a conversational wizard script at `.project/playbook/START-PLAYBOOK.md`. The wizard does the install (Step 6 below) and the AI agent setup (Step 7 below) in one walkthrough. Phases 1 to 3 pause for your approval at install steps. Phases 5 and 6 are autonomous, then present a single consolidated proposal for you to accept, modify, or reject. Total time about 15 to 25 minutes. You can stop and resume anytime; the proposal at `.project/playbook/knowledge/BOOTSTRAP-PROPOSAL.md` is the resumable state.

In the Claude Code window from Step 4, paste this single prompt.

```
Read .project/playbook/START-PLAYBOOK.md and walk me through it
step by step. I am new to all this. Pause for my approval at every
meaningful step.
```

What the wizard does, in order.

- **Phase 0.** Welcome and orient. Announces the eight phases.
- **Phases 1-3.** Installs the universal core, domain skills, and AI agents (the same install commands you would run yourself in Step 6 below). Pauses to walk you through the four `superpowers` slash commands and the browser OAuth for Parallel.ai when prompted.
- **Phase 4.** Reads everything in `.project/playbook/input/` (or runs a brainstorm dialogue with you if `input/` is empty) to understand your project.
- **Phase 5 (autonomous).** Determines the right team (3 to 8 personas), the right per-persona decisions (test discipline, accessibility floor, regulatory scope, audit posture, partner tiering, microcopy authority, etc.), and the right cross-cutting decisions for your project on its own, using your input materials and the default decision register at `.project/playbook/reference/rules/DEFAULT-DECISIONS.md`. Drafts every persona file and every knowledge entry in memory. Writes a single consolidated proposal to `.project/playbook/knowledge/BOOTSTRAP-PROPOSAL.md` listing every choice, the reasoning behind each, and the exact files it will write on approval. Does not ask you about decisions individually.
- **Phase 6.** Presents the proposal. You reply with "accept" (executes everything as proposed), "accept with changes" plus your specific changes (updates and re-presents), "show me file X" (renders a specific draft before deciding), or "reject and restart" (scraps the proposal and re-runs Phase 4 and Phase 5 with new guidance).
- **Phase 7.** Writes an initial `PROJECT-OVERVIEW.md` to the knowledge folder summarizing what your project is, who it serves, the team you customized, and the cross-cutting decisions captured. Preserves `BOOTSTRAP-PROPOSAL.md` as the audit trail of what the wizard decided and why.
- **Phase 8.** Confirms next steps and points at lifecycle Stage 1 (Concept).

Why autonomous decision-making is the default: most users do not know which test discipline, accessibility floor, audit framework, or partner tiering convention is right for their project. The defaults in the decision register are calibrated to be correct for 80 to 95 percent of projects, and the small fraction of decisions the wizard genuinely cannot infer are surfaced in the proposal under a Flagged section for your explicit input. A single consolidated review is faster, more consistent, and more accurate than 20 individual per-decision questions across an unfamiliar topic surface.

**The unattended variant (fully hands-off).** If you have good materials in `input/` and do not want to approve each phase, paste this instead. The wizard decides everything from the decision register, installs everything, auto-accepts its own proposal (which stays on disk at `BOOTSTRAP-PROPOSAL.md` as the full record), runs the `verify-install.sh` health check on its own work, and comes back exactly once with a summary: decisions to review first, everything it decided, anything it deferred (the two once-per-machine steps that need a human — the `superpowers` slash commands and the Parallel.ai browser login — are skipped and listed with their exact commands, never blocked on), the verification result, and the one-line prompts to adjust any persona or decision afterward.

```
Read .project/playbook/START-PLAYBOOK.md and run it in unattended
mode: read input/, decide everything from the decision register,
install everything, do not stop for my approval, and give me the
final summary with what to review and how to adjust.
```

Guided is the right default the first time you ever bootstrap a project; unattended is the right choice once you trust the flow and feed it a well-stocked `input/` folder. With an empty `input/`, unattended installs the generic baseline and a vanilla team, and says so in the summary.

If you take this option, **skip Steps 6 and 7 and go directly to Step 8**. The wizard has done everything Steps 6 and 7 cover.

If you prefer to drive each install command and customize the personas yourself (or the wizard fails partway and you want manual control), skip this step and continue to Step 6 below.

### Step 6. Install the three tools

Five sub-steps: install the universal core (6a), domain skills (6b), and AI agents (6c); reload Claude Code so it sees everything (6d); verify the install (6e). On Windows, the bash commands in 6a, 6b, and 6c run unchanged from Git Bash or WSL. The PowerShell variants shown beneath each command use `wsl` to invoke the same scripts and require WSL to be installed.

**6a. Universal core.** The universal core is four things: the `superpowers` plugin (engineering skills like brainstorming, writing-plans, subagent-driven-development), the `parallel-cli` binary (the Parallel.ai web research and data enrichment CLI tool), the `parallel-agent-skills` plugin (the Claude Code skills that wrap `parallel-cli`), and the `loop-engineering` skill (designing and scaffolding autonomous agent loops; tool-agnostic, installed via `npx skills add`, so it needs Node 20 or newer). These are required for every project regardless of project shape. The script pauses for a browser OAuth login to Parallel.ai and for four `superpowers` slash commands that you run inside the Claude Code window from Step 4. If Node is missing or older than 20, the script skips just the `loop-engineering` step (the rest of the core still completes) and prints the one command to add it later.

**On macOS, Linux, Git Bash, or WSL.**

```bash
bash .project/playbook/scripts/install-core.sh
```

**On Windows PowerShell with WSL installed.**

```powershell
wsl bash .project/playbook/scripts/install-core.sh
```

**6b. Domain skills.** Domain skills are project-specific tools (XRPL development, Xahau Hooks docs, Next.js + shadcn/ui frontend patterns, security scanning, error tracking via Sentry, transactional email via Resend, etc.). The playbook ships four starter packs that bundle the most useful skills per project shape. Pass the pack or packs that match your project: a single pack (e.g. `baseline`) or a subset (e.g. `xrpl frontend`). Requires Node 20 or newer for the underlying `npx skills add` commands.

Install what you will use, not everything. Every installed skill loads its description into every session, whether or not you ever invoke it. Passing `all` works, but it lands around 65 skills from 10 repos, and you pay for that listing on every turn. You can add a pack later in one command. The reasoning, and how to turn off individual skills you do not need, is in [`CONTEXT-ECONOMY.md`](../reference/rules/CONTEXT-ECONOMY.md) Rule 2.

**On macOS, Linux, Git Bash, or WSL.**

```bash
bash .project/playbook/scripts/install-skills.sh baseline
```

**On Windows PowerShell with WSL installed.**

```powershell
wsl bash .project/playbook/scripts/install-skills.sh baseline
```

**6c. AI agents.** The AI agents are 17 native Claude Code subagent definitions, one per persona (architect, bizdev, brand, community, compliance, customer-success, designer, developer, enduser, finance, legal, marketing, people, qa-engineer, sales, security-auditor, support). Each has `memory: project` enabled so it recalls its prior state across sessions. The script copies the definitions from `.project/playbook/reference/agents/` into `.claude/agents/`, which is the location Claude Code reads agents from. The same script also installs the six-rule security baseline at `.claude/SECURITY-POSTURE.md` (copied from `.project/playbook/reference/rules/SECURITY-POSTURE.md`) on first run; existing project customizations are preserved on re-run.

**On macOS, Linux, Git Bash, or WSL.**

```bash
bash .project/playbook/scripts/install-agents.sh
```

**On Windows PowerShell with WSL installed.**

```powershell
wsl bash .project/playbook/scripts/install-agents.sh
```

**For Codex users.** Codex has its own native subagent system (file format TOML at `.codex/agents/<name>.toml`, listed via `/agent`, invoked by name in prose or via `/agent` to switch threads), but the playbook ships only the Claude Code Markdown form today. Two options. **(1) Persona-as-prompt fallback.** Read the persona file at `.project/playbook/reference/personas/<ROLE>-PERSONA.md` and ask Codex to adopt the voice for the task. Works in any Codex session without writing subagent files. Documented in `AGENTS.md` under the Codex section and in `START-PLAYBOOK.md` Phase 3 Codex branch. **(2) Hand-write TOML subagent files** at `.codex/agents/<name>.toml` derived from the Markdown personas. Codex auto-loads them from this path; once installed, switch via `/agent`. Parallel TOML subagent definitions plus an `install-agents-codex.sh` script are tracked as a future playbook release. The security baseline copy step (the `cp` of `SECURITY-POSTURE.md` into `.claude/`) still applies on the Codex path; copy it manually or run `install-agents.sh` and skip the agent-install errors that follow.

**6d. Reload Claude Code.** After all three install scripts have finished, return to the Claude Code window from Step 4 and run the slash command below so Claude Code re-scans the freshly-installed `superpowers` plugin, `parallel-agent-skills` plugin, `loop-engineering` skill, and the domain skills from 6b.

This is a skills-and-plugins step. The 17 agent definitions from 6c need nothing: Claude Code watches `.claude/agents/` and picks them up within seconds. The one exception is if `.claude/agents/` did not exist when your session started, since the watcher only covers directories that were already there — in that case exit Claude Code (`/exit`) and start a new session in the same project root.

```
/reload-plugins
```

**6e. Verify the install.** Quick checks that the core tools landed cleanly. Run these in the terminal where the install scripts ran. Expected: Claude Code prints a version string, `parallel-cli` prints a version and JSON with `"authenticated": true` and a non-zero balance, `ls ~/.agents/skills/loop-engineering` lists the loop-engineering skill files, and `ls ~/.agents/skills/` lists the loop-engineering skill plus the domain skills installed by 6b (one directory per skill, matching the packs you installed).

```bash
claude --version
parallel-cli --version
parallel-cli auth --json
parallel-cli balance get
ls ~/.agents/skills/loop-engineering
ls ~/.agents/skills/
ls .claude/SECURITY-POSTURE.md
```

Then run the health check, which verifies everything the three scripts should have produced in one pass: all 17 agents installed and current, the security baseline present and diffed against the playbook reference, the version stamp, the core tools, and the memory surfaces. It is read-only and safe to run anytime.

```bash
bash .project/playbook/scripts/verify-install.sh
```

Exit code 0 means nothing is broken. Warnings are informational (a customized security baseline, bootstrap phases not yet run) and do not block work. Right after a fresh install, warnings about `PROJECT-OVERVIEW.md` and a root `AGENTS.md` are normal; the bootstrap wizard produces those later.

The full catalog of installed skills with what each one does lives at `.project/playbook/reference/tools/SKILLS-INVENTORY.md`. Read it after install to see your complete tool surface in one place.

For a fully manual command-by-command walk-through (skipping the scripts), see [`../scripts/MANUAL-INSTALL.md`](../scripts/MANUAL-INSTALL.md).

### Step 7. Set up the AI agents

The AI agents are the load-bearing piece of this playbook. Four sub-steps. Verify the 17 agents are registered with Claude Code (7a), learn how to invoke an agent (7b), confirm an agent fires end-to-end via a smoke test (7c), then customize the personas for this project's voice and constraints (7d).

**7a. Verify the AI agents are registered.** Agents are files on disk, so verification is a file check. Run the playbook's own checker from your project root.

```bash
bash .project/playbook/scripts/verify-install.sh
```

Check 3 asserts all 17 agents are installed and reports any that differ from the playbook reference copy. If you ran Step 6e you have already seen this pass; re-running is free. To eyeball the files directly:

```bash
ls .claude/agents/
```

You should see 17 `.md` files, one per persona. Each carries frontmatter naming its model (`opus` or `sonnet`) and `memory: project`. You can also just ask Claude in the session: "which subagents are available?"

> **A note on `/agents`.** Older guides (including earlier versions of this one) told you to run `/agents` and count the team in a **Library** tab, with a **Running** tab for live agents. As of Claude Code v2.1.198 that interactive wizard is gone. The command still exists, but running it now just prints a reminder to ask Claude or edit `.claude/agents/` directly. Nothing about the agent files themselves changed. Live agents are now in `/tasks` instead; see "Stopping a running agent" under Working with the team.

Agents are on-demand. A definition file in `.claude/agents/` does not execute anything; it sits available until invoked. Seeing nothing running right after install is the expected state.

**7b. How to invoke an AI agent.** There are three documented invocation patterns where you name the agent, plus a fourth implicit pattern where Claude picks an agent automatically. Per the [subagents docs](https://code.claude.com/docs/en/sub-agents.md). Each suits a different situation.

- **Natural language (most common).** Name the agent in your prompt and Claude typically delegates to it. Use this for everyday work. If Claude does not delegate (responds without spawning the agent), fall back to the `@-mention` form.

  ```
  Using the architect agent, draft the principles section
  of docs/DESIGN.md based on the spec at docs/specs/.
  ```

- **`@-mention` (guaranteed).** Forces the named agent to run for that task. Syntax: `@agent-<name>` or `@"<name> (agent)"`. Use this when natural language is not delegating reliably, or for verification (where you want to be sure the agent actually fires).

  ```
  @agent-developer run the failing test you wrote last
  session, find why it fails, and fix it.
  ```

- **`--agent` CLI flag (whole-session).** Start Claude Code with the agent already active for the entire session. Use this when an entire session focuses on one persona (a long architecture-design session, a multi-hour security audit, etc.).

  ```bash
  claude --agent architect
  ```

- **Automatic delegation (implicit, best-effort).** If you do not name an agent at all, Claude can still pick one based on your task description plus each agent's `description` frontmatter field. Best-effort, not guaranteed; the docs say "Claude decides whether to delegate." For critical work or verification, name the agent explicitly via natural language or `@-mention` rather than relying on auto-delegation. To make a specific agent more eagerly auto-invoked, you can add the phrase "use proactively" to its `description` frontmatter.

To interrupt a running agent at any time, press `Esc` (preserves work done so far) or `Ctrl+X Ctrl+K` twice within 3 seconds (kills all running background subagents in the session).

**Parallel dispatch.** For compound work, ask the main session to dispatch multiple agents in parallel by naming the lanes in one request. Claude orchestrates via the Agent tool; there is no special slash command for parallel dispatch. Example.

```
Research the authentication module, database layer, and API
surface in parallel using separate subagents running on sonnet.
Each returns a one-page summary with file paths. Then synthesize
the findings.
```

Name the model. The seventeen agents each pin their own model, but ad hoc subagents like these do not, so they inherit whatever your main session runs. Three parallel readers on your most expensive model is the costliest way to read files. See [`CONTEXT-ECONOMY.md`](../reference/rules/CONTEXT-ECONOMY.md) Rule 1 for how to set a default once instead.

**One-off tasks that do not match a persona.** For work that does not fit any of the 17 personas, just describe it to Claude in the main session without naming an agent. Claude can dispatch a `general-purpose` subagent under the hood if the task benefits from isolation, without you needing to create a new agent definition file. The general-purpose subagent has no memory and no persona; it is a one-shot worker. For repeated work in a new lane, create a proper persona file via Step 7d instead.

**7c. Smoke test (recommended).** Confirm an agent actually fires end-to-end. Paste this at the Claude Code prompt; it uses the natural-language invocation pattern from 7b.

```
Using the developer agent, run `git status` and report what you see.
```

What you should observe.

- The developer agent appears in `/tasks` while it works. Subagents run in the background by default as of Claude Code v2.1.198, so a completed one stays listed there marked done, sorted below anything still running.
- You see real output from `git status` (likely `fatal: not a git repository` if you have not run `git init` in your project folder yet, which is fine; the point is the agent fired and reported back).
- If the agent does not fire (Claude responds without delegating), use the `@-mention` form from 7b instead: `@agent-developer run git status and report`.

**7d. Customize the personas for this project.** The 17 agents from Step 6c are installed as generic templates. This sub-step customizes them to your project's voice, audience, and constraints using whatever you dropped in `input/` (or a brainstorm dialogue if `input/` is empty). In the Claude Code window, paste this prompt (a natural-language invocation that triggers the onboarding-wizard flow).

```
Read .project/playbook/START-PLAYBOOK.md Phase 4 through Phase 7
and walk me through it step by step. I am new to all this. Pause
for my approval at every persona before writing.
```

The script reads your `input/` folder, recommends 3 to 7 personas to customize first, walks through each via short Q&A, writes each to `.project/<ROLE>-PERSONA.md` on your approval, and writes an initial `PROJECT-OVERVIEW.md` to the knowledge folder. You can stop and resume anytime; the script captures state to `.project/playbook/knowledge/ONBOARDING-STATE.md`. Personas not customized in this session stay as generic templates in `reference/personas/`; you can come back to customize any of them later (re-run this prompt with the persona name, e.g. "customize the LEGAL persona for this project").

The full script lives at `.project/playbook/START-PLAYBOOK.md` if you want to read what it will do before you start.

### Step 8. Begin Stage 1 (Concept)

The customized agents from Step 7d are ready. Invoke the architect agent (natural-language pattern, see Step 7b) to brainstorm your idea.

```
Using the architect agent, run a brainstorming session for
<one-line description of your idea>. Produce a dated design
spec under docs/specs/.
```

From there you flow through the lifecycle stages in [`LIFECYCLE.md`](LIFECYCLE.md).

## Working with the team

After Step 7 finishes (or Step 5 if you took the wizard shortcut), the 17 agents live in `.claude/agents/` (installed in Step 6c) and the customized persona files live in `.project/<ROLE>-PERSONA.md` (written in Step 7d). Claude Code loads the agent definitions at the start of every session per the [Claude Code subagents docs](https://code.claude.com/docs/en/sub-agents.md).

**Three documented ways to invoke an agent** (per the Claude Code subagents docs).

- **Natural language.** Name the agent in your prompt and Claude typically delegates. Most common pattern. Example: `Using the architect agent, draft the principles section of docs/DESIGN.md`.
- **`@-mention` (guaranteed).** Forces the named agent to run for that task. Use when natural language is not delegating reliably. Syntax: `@agent-<name>` (e.g. `@agent-architect`) or `@"architect (agent)"`. Example: `@agent-developer run the failing test you wrote last session, find why it fails, and fix it.`
- **Whole-session via `--agent` flag.** Start Claude Code with the agent already active for the entire session: `claude --agent architect`. Useful when an entire session focuses on one persona.

**Implicit by artifact ownership.** Beyond the explicit patterns above, the `.claude/CLAUDE.md` that the bootstrap script writes for your project declares which persona owns which artifact (e.g. "the architect persona owns docs/DESIGN.md"). When you work on an owned artifact without naming an agent, Claude defaults to that persona's voice through the natural-language delegation path.

**Parallel multi-agent work.** Request it in natural language; Claude orchestrates via the Agent tool. Example: `Research the authentication module, database layer, and API surface in parallel using separate subagents running on sonnet, then synthesize the findings`. There is no slash command for parallel dispatch; the user expresses intent in natural language. Name the model as the example does: ad hoc subagents inherit the main session's model unless told otherwise.

**Seeing your team, and seeing what is running.** These are two separate questions now.

- **Which agents exist** is a file question: `ls .claude/agents/`, or `bash .project/playbook/scripts/verify-install.sh` for a checked answer, or ask Claude in the session.
- **Which agents are working right now** is [`/tasks`](https://code.claude.com/docs/en/commands). Most of the time it is empty, and that is the normal state.

The old `/agents` wizard that answered both in one dialog was removed in Claude Code v2.1.198.

**Switching agents within a session.** Just invoke the next one by name. Each agent's `memory: project` frontmatter means the first 200 lines (or 25KB, whichever is smaller) of its `MEMORY.md` at `.claude/agent-memory/<agent>/` auto-inject into the agent's system prompt at invocation time, so it picks up its own thread regardless of what other agent ran last in the session.

**Stopping a running agent.**

- **`Esc`** interrupts the current response or tool call. Preserves the work done so far.
- **`Ctrl+C`** interrupts a running operation.
- **`Ctrl+X Ctrl+K`** (press twice within 3 seconds to confirm) kills all running background subagents in the session.
- **`Ctrl+B`** backgrounds a running task without stopping it.
- From `/tasks`, press `x` on the agent to stop it. A subagent you stop this way does not auto-resume.

**Claude Code session restart.** Close and reopen Claude Code in your project root. All 17 agents auto-reload from `.claude/agents/` per the documented session-start behavior. No manual action needed.

**Per-agent memory persistence.** Each agent's `MEMORY.md` at `.claude/agent-memory/<agent>/` persists on disk across sessions. The next time the agent is invoked, the first 200 lines or 25KB of its MEMORY.md auto-injects into its system prompt so the agent picks up where it left off.

**Adding a new agent later.** Drop a new `.md` file in `.claude/agents/`, or ask Claude to write one for you, or run `bash .project/playbook/scripts/install-agents.sh <new-agent-name>` for one this playbook ships. No restart and no `/reload-plugins` needed: Claude Code watches `.claude/agents/` and `~/.claude/agents/` and picks up an added or edited definition within a few seconds, so the next delegation uses it.

Two cases still need a restart, per the subagents docs. The watcher only covers directories that existed when the session started, so the very first agent file in a brand-new `agents/` directory needs one. And sessions started with `--disable-slash-commands` do not watch these directories at all.

**Removing an agent.** Delete the `.md` file from `.claude/agents/` and restart your session. The agent's `MEMORY.md` at `.claude/agent-memory/<agent>/` is preserved unless you delete that directory manually.

**Re-customizing a persona later.** Read `../START-PLAYBOOK.md` Phase 6 only and apply it to the named persona. Example: "Read START-PLAYBOOK.md Phase 6 and customize just the LEGAL persona for this project."

**See the team at a glance.** [`../reference/agents/README.md`](../reference/agents/README.md) (table with role, model, memory scope, when to invoke each) or the root [`../AGENTS.md`](../AGENTS.md) (same table in multi-tool format for AI tools beyond Claude Code).

## Updating the playbook

You installed the playbook once by cloning it into `.project/playbook` (Step 2). When a newer version ships, you do not clone again. You pull the latest into that same folder and re-run the install scripts, which carry any new or changed content into your project's `.claude/`.

**One-time migration if you installed before v2.0.0.** Earlier releases put everything in `.internal/` instead of `.project/`. The install scripts now look in `.project/` and will not find a `.internal/` install. Rename the folder once, from your project root, before running any of the commands below:

```bash
# 1. Rename the working directory (it is gitignored, so this is a plain move)
mv .internal .project

# 2. Point your gitignore at the new name
sed -i 's|\.internal|.project|g' .gitignore

# 3. Update the paths inside the files the installers will not rewrite for you
sed -i 's|\.internal/|.project/|g' .claude/CLAUDE.md
sed -i 's|\.internal/|.project/|g' .claude/SECURITY-POSTURE.md
```

Step 3 covers `.claude/SECURITY-POSTURE.md` on purpose. `install-agents.sh` writes that file on first run only and then leaves it alone, so your security customizations survive re-runs. That also means re-running the installers will not fix the old path inside it, and `verify-install.sh` Check 4 would report drift against the playbook reference copy forever for a reason unrelated to any customization you made.

Check the `.gitignore` edit landed. The line is yours, not the installer's, so it may not match the shape above; if `grep project .gitignore` comes back empty, add `.project/` by hand. Getting this wrong makes your personas and operational notes committable.

Then re-run the installers below. Your customized personas move with the folder and are not overwritten. If you reference `.internal/` anywhere else (your own `AGENTS.md`, notes, scripts), update those too: `grep -rn '\.internal' --exclude-dir=.git .` finds what is left.

Your project knows which version it installed from: `install-agents.sh` stamps the playbook version to `.claude/playbook-version`. Check it before updating so you know how far behind you are and which `CHANGELOG.md` entries to read. Every release is also tagged and published automatically on the [Releases page](https://github.com/realgrapedrop/grapedrop-playbook/releases) with its changelog entry, so that page is the quickest way to see what shipped since your stamp.

Run this from your project root:

```bash
# 1. See what you have vs what is current
cat .claude/playbook-version
git -C .project/playbook pull
cat .project/playbook/VERSION

# 2. Read CHANGELOG.md in .project/playbook/ for the entries between those
#    two versions. MAJOR entries can require manual steps; the entry says so.

# 3. Re-run the installers to carry the changes into .claude/
bash .project/playbook/scripts/install-core.sh
bash .project/playbook/scripts/install-agents.sh
bash .project/playbook/scripts/install-skills.sh <the packs you installed>

# 4. Verify the update landed cleanly
bash .project/playbook/scripts/verify-install.sh
```

Windows (WSL) uses the same lines with `wsl bash ...` in place of `bash ...`, matching Step 6.

One update surface stays manual on purpose: your customized personas at `.project/<ROLE>-PERSONA.md`. The installers never touch them. If a new playbook version improves a persona *template*, compare it against your customized copy and merge what you want: `git -C .project/playbook log --oneline -- reference/personas/` shows what changed and when, and `diff .project/playbook/reference/personas/<ROLE>-PERSONA.md .project/<ROLE>-PERSONA.md` shows how yours differs. The version stamp tells you which release your customizations started from.

All three scripts are safe to re-run. `install-core.sh` checks state at each step and skips anything already done. `install-agents.sh` refreshes the 17 agent definitions but preserves your project's persona customizations, and it leaves an existing `.claude/SECURITY-POSTURE.md` untouched so your security customizations are not overwritten (see "Two copies of the security baseline" in [`ARCHITECTURE.md`](ARCHITECTURE.md)). `install-skills.sh` is idempotent for skills already installed.

After the scripts finish, run `/reload-plugins` inside Claude Code so the refreshed skills and plugins load into your session. The refreshed agents need no reload; Claude Code picks those up from `.claude/agents/` on its own. To see what changed in the version you just pulled, read `CHANGELOG.md` in `.project/playbook/`.

One caveat. The commands above assume `.project/playbook` is its own clone of the playbook repo, which is what Step 2 produces and what `.gitignore` keeps out of your project's git history. If you vendored the playbook into your project's own commits instead, `git -C .project/playbook pull` will not work because that folder is not a separate repo; in that case, delete `.project/playbook` and re-clone it per Step 2, then re-run the installers above.

## Adopting the playbook in an existing project

The playbook was written for an empty folder, but it installs cleanly into a repository with code and history. The wizard has a mode for it. The difference is where it learns about the project: from the repository itself, not only from `input/`.

**Set up.** From your repo root, with a clean working tree if you can manage it, so the wizard's changes are easy to tell apart from yours:

```bash
echo ".project/" >> .gitignore
git clone https://github.com/realgrapedrop/grapedrop-playbook .project/playbook
```

Then open `claude` and paste the guided prompt, or add "in unattended mode" to the first line to run it hands-off:

```
Read .project/playbook/START-PLAYBOOK.md and bootstrap this existing
project. Read the repository to understand it, not just input/. Do
not overwrite any file I already have. Pause for my approval at
every meaningful step.
```

**What it does differently.**

- **Reads the repo.** README, manifests, `docs/`, your existing `CLAUDE.md` and `AGENTS.md`, theme files, CI config, and recent commits. It delegates that reading to a cheaper model and works from the summary. `input/` still counts, and what you state there outranks what the code implies.
- **Picks skills from the code.** It recommends a skill pack from your manifests and configs, not from a description.
- **Curates for your stage.** A shipped product needs qa-engineer, security-auditor, and support sooner than a concept does. The summary tells you which lifecycle stage it thinks you are in, and why.
- **Defers to your conventions.** Where the repo already shows a convention, yours wins over the playbook default, and the proposal records the file that proves it.

**What it will not do.**

- **Replace your `CLAUDE.md`.** It appends a block between `<!-- playbook:start -->` and `<!-- playbook:end -->` markers. Re-running the wizard updates only what is between them. If you have no `CLAUDE.md`, it creates `.claude/CLAUDE.md` with only that block.
- **Lose an agent of yours.** On a first install, `install-agents.sh` copies any agent you already have under a colliding name (say, your own `developer.md`) to `.claude/playbook-backup/agents/` before installing the playbook's. To keep yours alongside, rename the file and its `name:` line and move it back into `.claude/agents/`. Agents with other names are never touched.
- **Touch your `AGENTS.md`, `README.md`, or `.mcp.json`.** If you already have an `AGENTS.md`, the wizard leaves it and offers two lines you can add yourself.

**Check the result** the way you would check any change: `git diff` should show additions only in files that were yours, and `bash .project/playbook/scripts/verify-install.sh` confirms the block, the gitignore line, the agents, and the security baseline.

**A good first task.** If the project has a visual surface and no written design system, extract one. Your theme files usually hold a complete token set nobody wrote down. The one-request prompt is in [`DESIGN-PRODUCTION.md`](../reference/rules/DESIGN-PRODUCTION.md).

## Producing design assets

Short prompts and long correction loops are the expensive way to get generic design. The playbook's method is to decide the design before prompting for it. The full version, with the security notes, is [`DESIGN-PRODUCTION.md`](../reference/rules/DESIGN-PRODUCTION.md). In brief:

1. **Put the brand on disk.** A committed `design-system/` folder with tokens, foundations, voice, and logos, plus a few lines in `CLAUDE.md` pointing at it. Claude Code's built-in design skill looks for a project design system first and ranks it above its own choices. Extract it from what exists; never let an agent invent a brand value.
2. **Keep a template for every asset you make twice.** A carousel, a deck, a social image. Layout is where correction loops go.
3. **Package each recurring job as a project skill** in `.claude/skills/`, so it loads only in this project and git tracks every change to it.
4. **Review twice on a canvas.** Options before the build, the finished asset after. `/design` publishes an editable canvas as a private artifact. It needs a claude.ai sign in on a paid plan and is not available with an API key or on Bedrock, Google Cloud, or Foundry; the fallback is a local HTML file.
5. **Let the skill learn, with a brake.** It confirms a rule with you before saving it, and every learned change is a reviewable diff.

```
Using the designer agent, build design-system/ for this project following
.project/playbook/reference/rules/DESIGN-PRODUCTION.md Step 1. Extract
before asking: read our theme files and published site first. Mark anything
you cannot confirm as unknown and ask me about it at the end. Then add the
short design system block to CLAUDE.md.
```

## Keeping sessions lean

A team of seventeen agents can burn through a usage limit fast, and a crowded session gives worse answers, not just pricier ones. The full discipline, with sources, is in [`CONTEXT-ECONOMY.md`](../reference/rules/CONTEXT-ECONOMY.md). The working version is six habits.

- **Name a cheaper model for delegated reading.** The seventeen agents pin their own models. Ad hoc subagents do not. Say "running on sonnet" in the request, or set `CLAUDE_CODE_SUBAGENT_MODEL=sonnet` once.
- **Look at what loads before you type.** Run `/context`. Turn off skills and MCP servers this project does not use (`skillOverrides` in settings, and the `/mcp` panel). Keep `.claude/CLAUDE.md` under 200 lines.
- **Brief the whole task.** The job, the why, the guardrails, and what done looks like. One complete brief beats ten corrections, because every correction resends the conversation.
- **One task per session.** `/clear` between unrelated tasks. It costs nothing.
- **Choose the model and effort at the start.** Switching either mid-session usually makes the next turn reread the entire conversation at full price. Claude Code asks you to confirm for that reason.
- **Write plainly.** No capital letter emphasis, and a goal instead of a numbered script.

**The handoff prompt.** When a session has grown long and the task is not finished, do not push on. Have the state written to disk, then start clean. Your agents' memory and the knowledge folder were built for this.

```
Before I clear this session: update your MEMORY.md with where this task
stands, write any decision other agents need to
.project/playbook/knowledge/<topic>.md, and give me a handoff brief I can
paste into a new session. The brief covers the goal, what is done, what is
left, the files that matter, and what we ruled out and why.
```

Then run `/clear` and paste the brief. To check what a session has cost and how well the prompt cache is working, run `/usage`.

`bash .project/playbook/scripts/verify-install.sh` reports your context baseline in Check 7: the size of `CLAUDE.md`, whether every agent still pins a model, and how many skills load into each session.

## Refresh prompt

If a Claude Code session has run long or been compacted, paste this to re-orient. If the task is unfinished and you have a choice, prefer the handoff prompt above and a clean session.

```
Re-read .project/playbook/README.md and follow the doc order it
lists. Confirm the current state of each artifact mentioned in the
rule docs. Report any gaps where an artifact named in the playbook
has not yet been created on this project.
```
