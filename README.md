![grapedrop playbook. A chart of the eight lifecycle stages in order: concept, requirements, design, architecture, planning, build, ship, iterate. Under each stage it names who leads it and what it produces. The architect leads concept and produces a design spec. The end user and architect lead requirements and produce use cases and REQUIREMENTS.md. The architect and designer lead design and produce DESIGN.md. The architect leads architecture and produces ARCHITECTURE.md and ADRs. The developer leads planning and produces an implementation plan. The developer and QA engineer lead build and produce code with tests passing. The developer and support lead ship, running in production. Whoever owns the area leads iterate and produces updated docs. A band across the bottom reads: memory carries every decision forward, a security baseline on every change, a separate checker grades the work. Credit line: designed and built by a senior architect with 21 years of experience, @realgrapedrop.](images/grapedrop-playbook-hero.png)

[![ci](https://github.com/realgrapedrop/grapedrop-playbook/actions/workflows/ci.yml/badge.svg)](https://github.com/realgrapedrop/grapedrop-playbook/actions/workflows/ci.yml) [![release](https://img.shields.io/github/v/release/realgrapedrop/grapedrop-playbook)](https://github.com/realgrapedrop/grapedrop-playbook/releases)

Every project has a lifecycle. Software is no exception: an idea becomes a concept, then requirements, design, architecture, a plan, working code, a release, and the iteration that follows. Each stage calls for a different strength — an architect for the load-bearing decisions, a developer to build and test, a designer for the experience, an end-user advocate for the real use cases, a brand strategist for the voice, a compliance lead for safety. A project moves well when the right person leads each stage and everyone remembers what came before.

That is what this playbook builds: **the team you always wished you had**, in place on day one — no hiring loop, no onboarding ramp. You bring the idea; the playbook ships seventeen specialist agents, decides which ones your project needs, tailors each persona to your work, and takes you from cloned playbook to a working project in about fifteen to twenty-five minutes. From then on you have AI agentic teammates inside Claude Code or Codex — not chat prompts, but agents that work autonomously within their lane, planning, writing code, running tests, and taking real actions through their tools until a task is done. Each brings its own specialized skills, voice, and cross-session memory, and they work together: dispatched in parallel on independent tracks, handing off decisions through shared memory, the way a real team does.

The chart above is the whole idea on one page: every stage has a named lead and a named output, so nothing depends on one long chat remembering what it was doing. Here is what is inside.

### Your team of seventeen AI agents

The playbook ships with seventeen specialist roles. Six lead the stages in the chart.

- **architect** (load-bearing design decisions and ADRs)
- **developer** (code, tests, code review, build and ship)
- **designer** (design system, components, accessibility)
- **brand** (positioning, voice, brand strategy)
- **compliance** (audit-ready controls, regulated-surface review, breach response)
- **end user** (use cases, user journeys, user-facing copy)

Eleven more sit alongside them, covering engineering quality and the functional areas beyond product and engineering.

- **security-auditor** (audits across UI, security, and functional bugs; finds, files, and verifies issues)
- **qa-engineer** (understands the whole platform; writes and runs automated functional tests; verifies bug fixes before they close)
- **legal** (contracts, IP, regulatory filings)
- **sales** (pipeline, deal cycle, customer acquisition)
- **customer-success** (onboarding, retention, account health)
- **marketing** (demand generation, content, channels)
- **people** (hiring, culture, org design)
- **community** (developer relations, ecosystem, public presence)
- **support** (intake, triage, customer-facing resolution)
- **finance** (modeling, runway, vendor and revenue accounting)
- **bizdev** (partnerships, integrations, channel relationships)

Each agent has its own voice and responsibilities defined in a persona file. Each has cross-session memory, so a conversation with the architect last week informs the architect's next response this week, automatically. You invoke any of them by name in Claude Code: `@agent-architect` or natural language.

One honest caveat on Codex. The native agent installs (the seventeen subagent definitions, and the per-agent memory they carry) are Claude Code only today. In Codex the same personas work as prompts: you point Codex at a persona file and it adopts the role for the task. That covers the voice and the responsibilities, but not the autonomous subagent dispatch or the automatic cross-session memory. The full support matrix is in `AGENTS.md`; native Codex subagent definitions are tracked for a future release.

### How the team works together

The band along the bottom of the chart is the system that makes the team more than seventeen separate chatbots. The full breakdown, and how each piece works with you, is in **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)**. The short version:

**Memory at three layers.** Each agent has its own cross-session memory. Cross-cutting decisions land in a shared knowledge log every agent reads at session start. And the lifecycle artifacts themselves (`REQUIREMENTS.md`, `DESIGN.md`, `ARCHITECTURE.md`, the plans) are team memory. Together they carry every revision forward to every agent that needs it, with no manual re-briefing.

**Skills and tools.** Skills are the curated workflows the team calls up at any stage: brainstorming, writing plans, systematic debugging, test-driven development, code review. They work in both Claude Code and Codex. A skill's instructions load only when it is invoked; its one-paragraph description loads every session, so the wizard installs the packs your project needs instead of everything. The full list is at `reference/tools/SKILLS-INVENTORY.md`, and the rules for keeping a seventeen-agent team affordable (which model does which work, what loads before you type, when to start a fresh session) are in `reference/rules/CONTEXT-ECONOMY.md`.

**The eight-stage lifecycle.** The numbered line across the top of the chart is the path every project follows: **concept → requirements → design → architecture → planning → build → ship → iterate**. Stages run in parallel where they do not block each other and get revisited when reality teaches you something new. The stage-by-stage breakdown, with the lead persona and artifact for each, is in **[docs/LIFECYCLE.md](docs/LIFECYCLE.md)**.

**The wizard and the security baseline.** The wizard is the conversational bootstrap at `START-PLAYBOOK.md` that stands up your customized team in one pass. The security baseline is the six rules at `.claude/SECURITY-POSTURE.md` that every agent inherits, installed on first run and preserved on re-runs.

## Get started

Three commands and one prompt. Pick the lane that matches where you are. You need [Claude Code](https://docs.claude.com/en/docs/claude-code) installed; Codex works too, with the caveat above.

### A new project

```bash
mkdir -p ~/projects/<your-project-name> && cd ~/projects/<your-project-name>
git clone https://github.com/realgrapedrop/grapedrop-playbook .project/playbook
echo ".project/" >> .gitignore
```

If you have anything written down about the idea (a concept doc, a deck, notes), drop it in `.project/playbook/input/`. The more the wizard can read, the less it has to ask. Then run `claude` and paste:

```
Read .project/playbook/START-PLAYBOOK.md and run it in unattended
mode: read input/, decide everything from the decision register,
install everything, do not stop for my approval, and give me the
final summary with what to review and how to adjust.
```

### A project you already have

Run this from the root of your existing repository. The `.gitignore` line comes first on purpose: `.project/` holds a nested clone and private persona files, and it should never be committed.

```bash
cd ~/projects/<your-existing-repo>
echo ".project/" >> .gitignore
git clone https://github.com/realgrapedrop/grapedrop-playbook .project/playbook
```

Then run `claude` and paste:

```
Read .project/playbook/START-PLAYBOOK.md and bootstrap this existing
project in unattended mode. Read the repository to understand it, not
just input/. Do not overwrite any file I already have. Give me the
final summary with what to review and how to adjust.
```

Here the repository is the input. The wizard reads your README, manifests, docs, and theme files to learn what the project is and what stage it is in, then picks the team for that stage. It is built to be safe in a repo with history:

- It adds a marked block to your `CLAUDE.md`. It does not replace the file, and re-running updates only that block.
- If you already have an agent with the same name as one of ours, yours is backed up to `.claude/playbook-backup/agents/` before ours is installed. Agents with other names are not touched.
- Conventions your repo already shows (test layout, ADR folder, review process) win over the playbook's defaults.
- Everything it changes shows up in `git diff`, so you can review it like any other change.

### What happens next, in both lanes

The wizard installs the tools, installs the seventeen agents, reads your materials, chooses three to eight personas to tailor now, writes every decision and its reasoning to one proposal file, and checks its own work with `verify-install.sh`. It comes back once, with a summary: what to review first, what it decided, what needs a human hand (two once-per-machine logins), and the one-line prompts to change anything. About fifteen to twenty-five minutes.

Prefer to approve each step? Swap the prompt for the guided one in the **[User Guide](docs/USER-GUIDE.md)**, which also covers the fully manual path (about 30 to 45 minutes).

Then put the team to work:

```
Using the architect agent, run a brainstorming session for <your idea>
and produce a dated design spec under docs/specs/.
```

**Already installed?** To pull a newer version of the playbook, see [Updating the playbook](docs/USER-GUIDE.md#updating-the-playbook).

### Two habits that pay for themselves

- **Spend context on purpose.** Seventeen agents can burn a usage limit fast. Name a cheaper model for delegated reading, keep one task per session, and brief the whole job up front. Six rules, with sources: [`CONTEXT-ECONOMY.md`](reference/rules/CONTEXT-ECONOMY.md).
- **Decide the design before you prompt for it.** Put the brand on disk as a `design-system/` folder, keep a template for every asset you make twice, and package each recurring job as a project skill with a human review step. Five steps: [`DESIGN-PRODUCTION.md`](reference/rules/DESIGN-PRODUCTION.md).

## Documentation

| Doc | What's in it |
|---|---|
| **[docs/USER-GUIDE.md](docs/USER-GUIDE.md)** | The operator's guide, with a table of contents: getting started (install and bootstrap), working with the team, updating the playbook, and the refresh prompt |
| **[docs/LIFECYCLE.md](docs/LIFECYCLE.md)** | The eight-stage lifecycle in detail, with the stage / lead / artifact table |
| **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** | The logical architecture (how the pieces work with you), the folder structure, and the two-copy security baseline |
| **[scripts/MANUAL‑INSTALL.md](scripts/MANUAL-INSTALL.md)** | Command-by-command manual install and the full domain-skill catalog |
| **[START-PLAYBOOK.md](START-PLAYBOOK.md)** | The wizard engine — the script Claude runs during bootstrap (humans start at the User Guide) |
| **[reference/rules/](reference/rules/)** | The rule docs: security posture, audit, methodology, build, team personas, loop engineering, memory hygiene, context economy, design production, and more |

## Who built this

I am a software architect with 21 years in the field. I have spent the last couple of years working with AI, and I hold professional certifications that cover the full delivery lifecycle, from the first requirement to running in production.

Vibe coding gets you to a demo fast. What it skips is everything I was trained to do around the code: write the requirement down, make the design decision on purpose, plan before building, test, review, secure, ship, and learn from what happens next. Those are the steps that decide whether a project gets finished.

This playbook is that discipline, packaged so you do not need two decades of experience to have it. If you build by prompting, clone it, paste one prompt, and your project starts with the structure a senior team would have given it: a lifecycle, a specialist for each stage, memory that carries decisions forward, and checks that do not take the model's word for it.

Find me on X: [@realgrapedrop](https://x.com/realgrapedrop).

## License

Free for almost everyone. You can use it under either of two licenses, your choice.

- **Learning, hobby projects, research.** Free, under the [PolyForm Noncommercial License](LICENSE-NONCOMMERCIAL.md). Charities, schools, public research bodies, and government institutions can use it for any purpose, at any size.
- **Building something to sell.** Free, under the [PolyForm Small Business License](LICENSE-SMALL-BUSINESS.md), if your company has fewer than 100 people and under 1,000,000 USD in revenue last tax year (in 2019 dollars, adjusted for inflation). That covers solo founders and freelancers.
- **Larger companies using it commercially** need a commercial license. Write to captain@grapedrop.xyz.

If you share it, keep the `Required Notice` line from the top of the `LICENSE` file. This summary is for convenience. The license files are what govern.
