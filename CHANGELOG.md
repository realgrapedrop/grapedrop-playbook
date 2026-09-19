# Changelog

All notable changes to this playbook are recorded here. The most recent release is at the top.

Versions follow [Semantic Versioning](https://semver.org). MAJOR for a backward-incompatible change to the playbook structure or bootstrap flow (file moves that break references, removed personas, install-script signature changes). MINOR for a backward-compatible content addition or significant doc restructure that keeps existing references working. PATCH for a typo fix or small clarification.

The current version also lives in the `VERSION` file at the repo root. Every release updates both this file and `VERSION` in the same commit; `install-agents.sh` stamps `VERSION` into downstream projects at `.claude/playbook-version` so an installed project knows which release it came from.

## [v2.2.0] - 2026-09-18 - Renamed grapedrop-playbook; bootstrap an existing project; a production line for design assets

Two additions. The playbook can now be installed into a repository that already has code and history, safely. And it gains a process for producing visual assets that does not depend on long correction loops.

The mechanical claims in the new design doc were checked against Anthropic's documentation on 2026-09-18 (Claude Code v2.1.277). One correction to common advice is worth stating here: `/design` does ship as a bundled skill, but it only works where artifacts work, which excludes API key sessions and Bedrock, Google Cloud, and Foundry.

### Added

- **Existing project mode in `START-PLAYBOOK.md`.** A new opt-in prompt, and detection in Phase 0. The repository becomes the input: the wizard reads the README, manifests, docs, theme files, and recent commits (delegated to a cheaper model), infers the skill pack from the code, curates the team for the stage the project is in, and lets conventions the repo already shows win over register defaults. It combines with unattended mode.
- **The wizard now writes the project's `CLAUDE.md`.** `docs/USER-GUIDE.md` and `AGENTS.md` have long said the bootstrap creates `.claude/CLAUDE.md`. Nothing did. Phase 7 now writes a short block between `<!-- playbook:start -->` and `<!-- playbook:end -->` markers. On a new project it creates the file. On an existing project it appends to the file that is there and never rewrites the rest. Re-running replaces only the block.
- **A new guardrail, in every mode: never replace a file the project already had.**
- **`install-agents.sh` backs up colliding agents on a first install.** If `.claude/agents/developer.md` (or any shipped name) already exists, differs from the playbook's copy, and no version stamp is present, the project's file is copied to `.claude/playbook-backup/agents/` before the playbook's is installed. The backup sits outside `.claude/agents/` so Claude Code does not load it as a live agent. Agents with other names are never touched. Once the stamp exists, a re-run refreshes without backing up, as before.
- **`reference/rules/DESIGN-PRODUCTION.md`**, a new companion rule doc. Five steps: a `design-system/` folder on disk before any asset, with a short pointer block in `CLAUDE.md` (Claude Code's built-in design skill looks for a project design system and ranks it above its own choices); a template for every asset made twice; a project skill per recurring job, in `.claude/skills/` so it loads only in that project; two human review gates on a `/design` canvas, with the availability limits and a local HTML fallback; and a learning rule with a brake (confirm before saving, save tokens not literals, git as the undo, never loosen a gate). It ends with security notes on scraped content, untrusted SVGs, third party scraping services, and reading a skill before installing it.
- **Wired into the designer, brand, and marketing agents**, each with a role specific line, and into `reference/personas/DESIGNER-PERSONA.md`. A "Design system on disk" decision was added to the Designer section of `reference/rules/DEFAULT-DECISIONS.md`: extract on existing projects, defer on new projects with no brand, because a placeholder system would be invented brand values.
- **Two `verify-install.sh` checks** in Check 6: the playbook block exists in `CLAUDE.md`, and `.project/` is gitignored when the project is a git repo. Warnings only.
- **`docs/USER-GUIDE.md`**: "Adopting the playbook in an existing project" and "Producing design assets". Three design rows in the `reference/tools/SKILLS-INVENTORY.md` cheat sheet (`/design`, `/design-sync`, `/dataviz`).

### Changed

- **`README.md` "Get started" is rewritten as two lanes**, a new project and a project you already have. Each is three commands and one paste prompt, and both default to the unattended wizard. It states what the wizard will and will not touch in an existing repo, and ends with the two habits from this release and the last.
- **Step 2 of the User Guide and both README lanes now add `.project/` to `.gitignore`.** No step did before. In an existing repo the line comes before the clone, because `.project/` holds a nested clone and private persona files.

### Fixed

- **`input/README.md` said 15 personas.** It is 17.

### Renamed for publication

- **The public repository is `realgrapedrop/grapedrop-playbook`.** Every clone command in `README.md` and `docs/USER-GUIDE.md`, both README badges, and the `Required Notice` line at the top of `LICENSE` now use that name. "Playbook" alone is a crowded word on GitHub, where it mostly means Ansible; the coined prefix makes the project findable and ties it to its author.
- **Nothing changes inside an installed project.** The clone target is still `.project/playbook/`. That is a folder name on your disk, not the repository name, so existing installs need no migration. To follow the new location: `git -C .project/playbook remote set-url origin https://github.com/realgrapedrop/grapedrop-playbook`.
- **`README.md` gains a License section** that states the PolyForm Noncommercial 1.0.0 terms in plain language: free for personal, research, educational, and nonprofit use; a commercial license is required to use it in or for a business, including to build a product for sale. The license itself is unchanged.

### New hero image

- **`images/grapedrop-playbook-hero.png`** replaces the old illustrated hero at the top of `README.md`. It is a chart, not an illustration: the eight stages in order, who leads each one, and what each one produces, over a band stating the three things that hold it together (memory, the security baseline, a separate checker). It carries the credit line "Designed and built by a senior architect with 21 years of experience". The `.svg` beside it is the editable source, and a `.webp` is included. The PNG is about a fifth the size of the image it replaces.
- **The README prose that walked through the old picture was reworded** to describe the chart, and the alt text now states the full content of the chart for screen readers.
- **`README.md` gains a "Who built this" section**, in the first person: who the author is, what vibe coding skips, and what the playbook packages. It replaces the one-line credit at the foot of the file.

### Fixed: one list of eight stages

- **`docs/LIFECYCLE.md` contradicted itself.** Its header gave the eight stages as concept, requirements, design, architecture, planning, build, ship, iterate, and said positioning runs as a parallel track. Its table then listed Foundation as stage 1 and Positioning as stage 5. The header, the README, and the hero image are canonical. The table now matches them, with a lead and an artifact per stage. Foundation (the bootstrap) and Positioning are described under the table as what they are: setup before Stage 1, and a track that runs alongside.
- **Stage numbers that depended on the old table were corrected.** "Stage 2 (Concept)" is now Stage 1 in `docs/USER-GUIDE.md` and `START-PLAYBOOK.md`. The architect, end-user, developer, designer, brand, and marketing agent definitions cite the right stages; brand and marketing now cite the positioning track instead of a "Stage 5" that does not exist. `reference/rules/DESIGN-METHODOLOGY.md` keeps its own numbered phases, which are a separate thing and were already labeled as phases.
- The old `images/playbook-hero.png` and `.webp` were removed.

### A note on sources

The design process was prompted by publicly shared material on designing with Claude, including two third party skills. Those skills carry no license, so nothing from them is included here: no text, templates, or scripts. This release is an independent write-up of the method, checked against Anthropic's documentation, with guards added where a review of that material found gaps (learned rules saved without confirmation, and scraped SVGs rendered in a browser without cleaning).

### Upgrading

No migration. Re-run `install-agents.sh` to pick up the three updated agent definitions. Existing installs will see one new warning from `verify-install.sh` until the `CLAUDE.md` block exists; ask Claude to "run START-PLAYBOOK.md Phase 7, the CLAUDE.md block only" to add it.

## [v2.1.0] - 2026-09-18 - Context economy: keeping a seventeen-agent team affordable and sharp

A team of seventeen agents, several plugins, and four skill packs can burn through a usage limit fast. It can also get quietly worse, because a crowded context window degrades answers without raising an error. This release adds the discipline for spending context well, and fixes two places where the playbook itself was the cause of the waste.

Every mechanical claim in the new rule doc was checked against Anthropic's documentation on 2026-09-18 (Claude Code v2.1.277), and the sources are linked from it. Several popular claims on this topic did not survive that check and were left out on purpose; the doc lists them.

### Added

- **`reference/rules/CONTEXT-ECONOMY.md`**, a new companion rule doc. Six rules: the capable model directs while a cheaper model reads; keep the session baseline small; brief the whole task up front (the job, the why, the guardrails, what done looks like); one task per session with a handoff through the memory layers; pick the model and effort at the top of the session, with a table of which mid-session changes force a full uncached reread; and write prompts plainly.
- **Wired into all 17 agent definitions**, the same way `MEMORY-HYGIENE.md` was. Each agent is told that its final message lands in the caller's context, so it returns conclusions and file paths instead of raw material, reads only what the task needs, and stops at the done condition in its brief.
- **`verify-install.sh` Check 7, context baseline.** Warns when `CLAUDE.md` passes the documented 200-line guidance. Warns when an installed agent has lost its `model` line, because that agent then inherits the main session's model. Reports how many skills load a description into every session and roughly how much text that is. The skill count is reported, not judged, because no documented limit exists. Warnings only; the exit code contract is unchanged.
- **"Keeping sessions lean" in `docs/USER-GUIDE.md`**: the six habits in short form, plus a handoff prompt that writes task state to agent memory and the knowledge folder before a session is cleared.
- **Seven rows in the `reference/tools/SKILLS-INVENTORY.md` cheat sheet**: `/effort`, `/context`, `/usage`, `/clear`, `/compact`, disabling an MCP server, and turning off a skill with `skillOverrides`. The Codex column says "Not verified here" for these, because I did not verify them.

### Changed

- **The parallel dispatch examples now name a model.** Both examples in `docs/USER-GUIDE.md` asked for "separate subagents" with no model. The seventeen agents pin their own model, but ad hoc subagents inherit the main session's, so the example as written ran every reader on the most expensive model available. The rule doc also documents `CLAUDE_CODE_SUBAGENT_MODEL` for setting that default once. It resolves below an agent's own `model` line, so it does not downgrade the `opus` agents.
- **The manual install path no longer tells every project to install `all` skill packs.** `docs/USER-GUIDE.md` Step 6b now shows `baseline` and explains the trade. The "Updating the playbook" block re-runs the packs you installed instead of `all`. `START-PLAYBOOK.md` Phase 2 tells the wizard to recommend only the matching packs.
- **`reference/agents/README.md`** explains the `model` line as a cost control, documents the resolution order and the optional `effort` field, and lists the values `model` accepts today (`fable` and full model IDs, in addition to the aliases it already listed).
- **`reference/rules/LOOP-ENGINEERING.md`**: the Delegation field of the loop contract now names the model for the maker and the checker.
- **`README.md` and `docs/ARCHITECTURE.md`** no longer say skills "load on demand, so the catalog grows without crowding any one session." That is true of a skill's body and false of its description.
- Pointers added in `AGENTS.md`, `reference/rules/TEAM-PERSONAS.md`, `reference/rules/MEMORY-HYGIENE.md`, and `START-PLAYBOOK.md` Phase 8.

### Fixed

- **`install-skills.sh` help text said `all` installs "10 distinct skills total."** It installs 10 skill repos. Several ship many skills each; on a machine with all four packs I counted 65 skills and about 26KB of description text loaded into every session, including skills written for one vendor's internal workflow. The help text now says so.
- **One `/agents` reference that v2.0.1 missed.** The opening of `reference/agents/README.md` still said `/agents` lists the installed team. It now points at `ls .claude/agents/`.

### Upgrading

No migration. After pulling, re-run `install-agents.sh` so the 17 installed agent definitions pick up the new rule line. Until you do, `verify-install.sh` Check 3 reports all 17 as differing from the reference. That is accurate, and it clears on re-run.

If you installed `all` skill packs earlier, nothing breaks. Run `verify-install.sh` to see your count, then turn off what the project does not use with `skillOverrides` (rule doc, Rule 2).

### Not done in this release

The `baseline` pack still installs the whole `getsentry/skills` and `utkusen/sast-skills` repos. Narrowing it to named skills would shrink every downstream session, but it changes what ships, so it is a separate decision.

## [v2.0.1] - 2026-08-02 - Agent verification no longer points at the removed /agents wizard

Claude Code v2.1.198 removed the interactive `/agents` wizard. The command still exists, but it no longer opens anything: running it prints a reminder to ask Claude or edit `.claude/agents/` directly. The **Library** and **Running** tabs it used to show are gone. Several places in this playbook told you to open that wizard and count 17 agents in the Library tab, which is no longer possible.

Nothing about the agent files changed. Locations, frontmatter fields, and `memory: project` are all unchanged, and `memory: project` is still the documented recommended default. Only the terminal UI went away, so this is a docs correction with no migration.

### Changed

- **Agent verification now uses the checker this playbook already ships.** `docs/USER-GUIDE.md` Step 7a, `START-PLAYBOOK.md` Phase 3, `reference/agents/README.md`, and the `install-agents.sh` next-steps text now point at `verify-install.sh` (its Check 3 asserts all 17 agents and flags any differing from reference) or `ls .claude/agents/`, instead of a Library tab that no longer exists.
- **Live agents are `/tasks`, not the Running tab.** Updated in `docs/USER-GUIDE.md` (the smoke-test expectation, the "seeing your team" guidance, and the stop-an-agent list, where the interactive step is now pressing `x` in `/tasks`). Subagents also run in the background by default as of v2.1.198, so a finished one stays listed there marked done.
- **`reference/tools/SKILLS-INVENTORY.md` invocation cheat sheet.** The "list installed agents" row no longer claims a Claude Code slash command, because there isn't one; it points at `ls .claude/agents/` or asking Claude. A new row covers seeing what is running. The single "reload after install" row was split, because it was only ever correct for skills and plugins.
- **`AGENTS.md`** Claude Code entry point, same correction.

### Fixed

- **The "restart your session to load a new agent" instruction was stale.** `docs/USER-GUIDE.md` quoted superseded documentation. Claude Code watches `.claude/agents/` and `~/.claude/agents/` and picks up an added or edited definition within seconds, so neither a restart nor `/reload-plugins` is needed for agents. The two genuine restart exceptions are now documented: a brand-new `agents/` directory that did not exist when the session started, and sessions run with `--disable-slash-commands`.
- **Two `/reload-plugins` instructions that covered agents were narrowed to skills and plugins.** Step 6d ("Reload Claude Code") listed the 17 agent definitions among what the reload re-scans, and the "Updating the playbook" section said the reload loads "the refreshed agents and skills." Both now say skills and plugins, and note that agents need nothing. Every other `/reload-plugins` instruction in the playbook is skills-or-plugins context and is unchanged, including all five in `scripts/MANUAL-INSTALL.md`, which covers core tooling and skills but has no agent-install step.

### Why this matters

The install scripts and the wizard both ended with "go look at the Library tab," so the last step of onboarding was an instruction that could not be followed. Pointing verification at `verify-install.sh` fixes that and improves on the original: a checked answer that also catches agents which drifted from the reference copy, rather than a human counting rows in a dialog.

## [v2.0.0] - 2026-08-02 - The working directory is now .project/ instead of .internal/

The directory that holds everything the playbook installs into a project has been renamed from `.internal/` to `.project/`. A project now looks like `~/projects/<project-name>/.project/`, with the playbook clone at `.project/playbook/` and the customized personas alongside it at `.project/<ROLE>-PERSONA.md`. Nothing about the structure inside the directory changed, and nothing about what the scripts do changed. Only the name is different.

`.internal/` described where the folder sat relative to the outside world. `.project/` describes what is in it: the project's own working files. That reads correctly the first time someone opens a project and sees the folder, which matters for a directory whose whole job is to be discovered and read by an agent or a new teammate.

This is a MAJOR release because the rename breaks references in every project already installed. The migration is one `mv` and two `sed` lines; it is written out in `docs/USER-GUIDE.md` under "Updating the playbook."

### Changed

- **Every reference to `.internal/` became `.project/`** across the shipped artifact: `README.md`, `AGENTS.md`, `START-PLAYBOOK.md`, `docs/USER-GUIDE.md`, `docs/ARCHITECTURE.md`, `knowledge/README.md`, all 17 agent definitions in `reference/agents/`, the rule docs in `reference/rules/`, `reference/tools/SKILLS-INVENTORY.md`, `reference/personas/DESIGNER-PERSONA.md`, and `scripts/MANUAL-INSTALL.md`.
- **The install and verify scripts** — the path constants that make the install work: `SRC`, `SEC_SRC`, and `VER_SRC` in `install-agents.sh`, `PLAYBOOK` in `verify-install.sh`, plus every usage line and next-steps message in `install-core.sh` and `install-skills.sh`.
- **`reference/rules/TEAM-PERSONAS.md`** — the "About the .internal directory" section is now "About the .project directory". The rationale is unchanged and still holds: the directory is gitignored, and it sits outside the `.claude/` write boundary so Claude can update operational files without a permission prompt.
- **`.gitignore`** and the CI install smoke test in `.github/workflows/ci.yml`, which stands up its throwaway project at the new path.

### Migration

For any project installed from v1.15.0 or earlier, run this once from the project root, then re-run the installers:

```bash
mv .internal .project
sed -i 's|\.internal|.project|g' .gitignore
sed -i 's|\.internal/|.project/|g' .claude/CLAUDE.md
sed -i 's|\.internal/|.project/|g' .claude/SECURITY-POSTURE.md
```

`.claude/SECURITY-POSTURE.md` is in that list because `install-agents.sh` writes it on first run only and preserves it thereafter, so re-running the installers will not correct the path inside it, and `verify-install.sh` Check 4 would otherwise report drift against the playbook reference copy permanently. Confirm the `.gitignore` edit matched; that line is user-written and may not have the shape the `sed` expects.

Customized personas move with the folder and are not touched. `grep -rn '\.internal' --exclude-dir=.git .` finds anything else in the project that still points at the old name.

### Why this matters

The playbook's directory is the first thing an agent reads and the first unfamiliar thing a human sees in a bootstrapped repo. A name that describes contents rather than privacy posture removes a small, permanent explanation from every future onboarding. The cost is a one-time rename, paid once, by a migration that fits in three lines.

## [v1.15.0] - 2026-07-07 - Unattended bootstrap: drop materials in input/, get a standing team and one summary

The wizard's Phase 5 has been autonomous since v1.4.0, but the flow around it still held roughly eight approval gates: the host-tool question, per-phase confirmations, the proposal review. For a user who has stocked `input/` well, those gates are ceremony. This release adds an opt-in unattended mode: paste one prompt, walk away, come back to a customized team, a full decision record, a verified install, and a single summary that leads with what to review and how to change it. The guided flow is unchanged and stays the default; it is the right experience for a first-time user, and the unattended prompt is an explicit opt-in.

### Added

- **`START-PLAYBOOK.md` "Unattended mode" section** — the mode spec, governed by the playbook's own loop-engineering discipline: run until done, stop only for an honest reason (a failed script, or completion), never grade your own work, leave a record. Phase gates become checkpoints appended to `ONBOARDING-STATE.md`. Steps that genuinely need a human hand (the `superpowers` slash commands, the Parallel.ai browser OAuth — both once per machine, neither scriptable) are deferred with their exact commands rather than blocked on. Flagged decisions take the register default anyway and move to the top of the proposal marked "review first." Phase 6 auto-accepts, with `BOOTSTRAP-PROPOSAL.md` preserved as the full audit trail. Phase 8 runs `verify-install.sh` (the wizard never grades its own install) and delivers a five-part summary contract: review-first items, decisions made, deferrals, verification result, and the adjustment levers.
- **The unattended paste prompt** in `START-PLAYBOOK.md` "How to run this", alongside the guided one.
- **Session-start mode detection** — the wizard's first action now sets the mode from the user's prompt, and an unattended resume against a leftover `ONBOARDING-STATE.md` re-checks deferred items instead of re-running the bootstrap.

### Changed

- **`START-PLAYBOOK.md` guardrails** — annotated for the two modes: the per-file approval guardrail and the gate guardrail are guided-mode rules (in unattended mode the opening prompt is the approval, granted in advance for what the proposal records); the stop-on-script-failure guardrail holds in both modes.
- **`docs/USER-GUIDE.md` Step 5** — documents the unattended variant: what it decides, what it defers and why, the empty-`input/` behavior (baseline pack, vanilla team, said plainly in the summary), and when to pick each mode.
- **`README.md`** Get started wizard bullet and **`docs/ARCHITECTURE.md`** wizard bullet — both note the unattended option.

### Why this matters

The playbook tells downstream teams to hand recurring, verifiable work to loops that stop honestly and leave a record. Onboarding is that shape for everyone except a first-timer: the decisions are already register-driven, the installs are already scripted, and the output is already auditable. What the gates bought was trust, and the unattended mode buys it differently — with a decision record on disk, an independent verify pass, and a summary that leads with the items most worth a human look. The user's time goes to judgment, not to pressing next.

## [v1.14.0] - 2026-07-07 - The repo maintains itself: auto-releases, a version guard, weekly health checks

v1.13.0 gave the playbook checks that run when a human pushes. This release adds the automation that runs when nobody does. Releases publish themselves, the version bookkeeping enforces itself, and the parts of the playbook that rot on the outside world's schedule (external URLs, upstream skill repos) are probed weekly, with failures filed as issues instead of waiting to be noticed. All of it runs on the built-in Actions token; no personal credentials are involved.

### Added

- **`.github/workflows/release.yml`** — when `VERSION` changes on main, the workflow creates the matching git tag and publishes a GitHub Release whose notes are that version's CHANGELOG entry. The Releases page now tracks `CHANGELOG.md` in lockstep with no manual step, and downstream projects get a clean surface for "what shipped since my stamp."
- **`ci.yml` version-guard job** — fails any push or pull request where `VERSION` and the newest CHANGELOG entry disagree. The "bump both in the same commit" release rule from v1.13.0 is now enforced, not remembered.
- **`.github/workflows/health.yml`** — a Monday-morning scheduled run (plus manual dispatch) that checks the two things the per-push CI cannot: external links in every doc (lychee, online mode, tolerant of bot-hostile 403/429 responses), and whether every upstream skill repo the install scripts reference still exists. The upstream list is parsed out of the install scripts at run time, so the check can never drift from what the scripts actually install. On failure the workflow files a single `health`-labeled issue (or appends to the open one) with the findings and the fix path — the playbook's own loop-engineering discipline (discover, file where work is tracked, stop) applied to the playbook itself.
- **README badges** — CI status and latest release, linked to the Actions and Releases pages.

### Changed

- **`docs/USER-GUIDE.md`** "Updating the playbook" — notes that every release is published automatically on the Releases page with its changelog entry, making it the quickest way to see what shipped since the project's version stamp.

### Why this matters

A framework that tells downstream teams to hand recurring, verifiable work to autonomous loops should not be doing its own recurring, verifiable work by hand. Releasing, version bookkeeping, and rot detection are exactly that shape: machine-checkable done-conditions, tedious to do manually, recurring forever. Now the human steps in this repo are the ones that genuinely need judgment — writing the change, writing its changelog entry — and everything downstream of the push happens on its own.

## [v1.13.0] - 2026-07-07 - Promises become checks: verify script, version stamping, memory hygiene, CI

The playbook was strong on design and thin on enforcement: the install's correctness, the sync of the two security-baseline copies, the health of agent memory, and the repo's own links and scripts were all guaranteed by prose that humans and agents were trusted to follow. This release converts those promises into checks. It also states the Codex support level honestly instead of implying parity.

### Added

- **`scripts/verify-install.sh`** — a read-only post-install health check, run from the project root. Verifies in one pass: the playbook clone, the version stamp against the clone's `VERSION`, all 17 agents installed (and whether any differ from the reference), the security baseline present *and diffed against the playbook reference copy* (drift is now a reported warning, not a silent state), the universal-core tools, and the memory surfaces — including a warning when any per-agent `MEMORY.md` exceeds the 200-line/25KB auto-inject budget. Exit 0 when nothing is broken; warnings never block. Wired into `docs/USER-GUIDE.md` (Step 6e and Updating the playbook), `scripts/MANUAL-INSTALL.md`, `START-PLAYBOOK.md` Phase 3 Verify, and the `install-agents.sh` next-steps text.
- **`VERSION` file and version stamping.** The repo root gains a `VERSION` file (single line, matches the CHANGELOG's current release). `install-agents.sh` stamps it to `.claude/playbook-version` on every run, so a downstream project knows which playbook release its install and persona customizations came from. This is the anchor the update flow was missing: `docs/USER-GUIDE.md` "Updating the playbook" now starts with comparing the stamp against the pulled `VERSION`, reading the CHANGELOG entries between them, and ends with a verify run, plus guidance for merging improved persona templates into customized copies via `git log` and `diff`.
- **`reference/rules/MEMORY-HYGIENE.md`** — a companion rule doc (alongside `SECURITY-POSTURE.md`, `SECURITY-AUDIT.md`, `LOOP-ENGINEERING.md`) for keeping the memory layers trustworthy over time. Names the two silent failure modes (the auto-inject cliff at 200 lines/25KB, and context poisoning by stale entries), sets five rules for per-agent `MEMORY.md` (stay under budget, most useful first, delete superseded facts, compact on exit, route shared facts to knowledge), four rules for the knowledge folder (explicit reversals, a Current position summary on long files, split/merge, graduate stable entries to `docs/`), and a review ritual owned by the architect agent at stage transitions and monthly during the continuous stages. Referenced from all 17 agent shims (the architect's line names its ritual ownership), `reference/rules/TEAM-PERSONAS.md`, `knowledge/README.md`, and the README rule-docs row.
- **CI at `.github/workflows/ci.yml`.** Three jobs on every push and pull request: `shellcheck` plus `bash -n` over `scripts/*.sh`; an offline lychee run that fails on any broken internal doc link (fragments included); and an install smoke test that stands up a throwaway project, runs `install-agents.sh` against a stubbed `claude` binary, asserts 17 agents plus baseline plus matching version stamp, proves the re-run preserves a customized baseline, and finishes with a passing `verify-install.sh`. The repo's shipped scripts and cross-linked docs no longer regress silently.

### Changed

- **`scripts/install-agents.sh`** — stamps the version (see above), points at `verify-install.sh` in its next-steps output, documents both in the header comment, and drops an unused variable flagged by shellcheck.
- **`scripts/install-core.sh`** — one printf call reworked to satisfy shellcheck (SC2059); behavior unchanged.
- **`README.md`** — the team section now carries an honest Codex caveat: native subagent installs and per-agent memory are Claude Code only today; Codex gets persona-as-prompt, with the support matrix in `AGENTS.md`. Previously the intro implied the two tools were equivalent. The rule-docs table row adds memory hygiene.
- **`docs/ARCHITECTURE.md`** — the runtime bullet gains the same Codex caveat; the folder tree adds `VERSION` and the verify script; the downstream-files list adds `.claude/playbook-version`; the two-copy security-baseline section now notes the sync is checked by `verify-install.sh`, not just promised.
- **`reference/agents/*.md` (all 17)** — each rule-docs list gains a `MEMORY-HYGIENE.md` line, placed before the security-posture line; the architect's names its ownership of the knowledge-folder review ritual.
- **`reference/rules/TEAM-PERSONAS.md`** and **`knowledge/README.md`** — both memory-convention sections now point at `MEMORY-HYGIENE.md` for the maintenance discipline.

### Deferred

- **A living example project** — a small public repo bootstrapped by the playbook, serving as demonstration and regression fixture. It needs its own repository and a real bootstrap run, so it is tracked as future work rather than half-shipped here.
- **Native TOML subagent definitions for Codex** plus an `install-agents-codex.sh` — still the plan for closing the Codex gap for real (carried from v1.6.0). This release makes the gap honest in the meantime.

### Why this matters

A framework that configures other projects has to hold itself to the standard it preaches. Every guarantee in this release existed before as a sentence in a doc: "the scripts verify the install", "keep the two copies in sync", "memory carries context forward", "works with Claude Code or Codex". Now the install is verified by a script, the sync is diffed, the memory budget is measured against the real injection limit, the claims about Codex match the shipped behavior, and CI re-proves all of it on every change.

## [v1.12.0] - 2026-06-25 - Loop engineering added to the universal core and the framework

The playbook now ships loop engineering — the discipline of building a system that runs a coding agent on a recurring job (failing CI, an issue inbox, dependency upgrades, a flaky-test hunt) without a human prompting each turn, and that stops on its own when the work is done or it hits an honest wall. It arrives in two halves: the `loop-engineering` skill is installed as part of the universal core so it lands on every project, and a new rule doc captures the discipline behind it. This is a backward-compatible content addition — the install-script signatures are unchanged and every existing reference still resolves — hence MINOR, not MAJOR.

The skill is referenced from upstream (`invincible04/awesome-loop-engineering`, MIT) via `npx skills add`, the same pattern the playbook already uses for every third-party domain skill. Nothing is vendored into the repo, so there is no license mixing with the playbook's PolyForm Noncommercial terms.

### Added

- **`reference/rules/LOOP-ENGINEERING.md`** — the new rule doc, eleventh in the set. Covers what a loop is and is not (it can stop itself; a cron job cannot), the when-it-fits test (a machine-checkable done-condition plus tedious trial-and-error, recurring at least weekly), the maker/checker split (the agent that does the work never grades it), the eleven-part loop contract, the four honest stop conditions (goal met, budget spent, stalled, needs a human), the seven non-negotiable laws, the two-diff test that proves a checker before you trust it, and where loops fit the continuous lifecycle stages.
- **`loop-engineering` skill in the universal core.** `scripts/install-core.sh` gains Step 7, which installs the skill via `npx skills add invincible04/awesome-loop-engineering --skill loop-engineering --global`. The step is idempotent (skips when `~/.agents/skills/loop-engineering` already exists) and degrades gracefully: because it is the only core step that needs Node, a missing or pre-20 Node warns and skips just this step rather than failing the rest of the core, and prints the one command to add it later.
- **`scripts/MANUAL-INSTALL.md`** — Step 7b (the manual install of the skill) and Step 9g (its verification), plus the Part 1 intros updated to name the fourth core component.
- **`reference/tools/SKILLS-INVENTORY.md`** — a dedicated `loop-engineering` core-skill section, and the skill added to the "assumes the core skills above… are installed everywhere" line.

### Changed

- **`START-PLAYBOOK.md`** Phase 1 — the Announce text now describes the universal core as four things, the Codex branch gains the manual `npx skills add` step (the skill is tool-agnostic and lands in the shared `~/.agents/skills/` path Codex reads), and the Verify step adds the loop-engineering check.
- **`docs/USER-GUIDE.md`** — Step 6a now lists the universal core as four things and notes the Node-20 graceful skip; Step 6d adds the skill to the reload re-scan list; Step 6e adds its verification command.
- **`docs/LIFECYCLE.md`** — a pointer noting that for the continuous Ship and Iterate stages, recurring work can be handed to an autonomous loop, with the discipline in `reference/rules/LOOP-ENGINEERING.md`.
- **`README.md`** — the rule-docs row in the Documentation table now names loop engineering.
- **`reference/agents/qa-engineer.md`** and **`reference/agents/developer.md`** — each gains a `LOOP-ENGINEERING.md` reference in its rule-docs list, matching the maker/checker split (QA owns the checker, Developer builds the maker).

### Why this matters

Loop engineering is the discipline that lets a project's agent team do recurring, verifiable work unattended instead of one hand-typed prompt at a time — the natural next step once a project reaches the continuous lifecycle stages and a test suite can vouch for "done." Putting the skill in the universal core means every project the playbook stands up can build a loop without a separate install, and the rule doc makes the team build them honestly: stop conditions first, a separate checker that cannot be cheated, and the human staying the engineer rather than just the person who presses go.

## [v1.11.0] - 2026-06-18 - README slimmed to a front door; operator content moved into a docs/USER-GUIDE.md with a table of contents

The README had grown to 482 lines doing four unrelated jobs at once: the pitch, the full eight-step install walkthrough, day-to-day team operations, and reference material (lifecycle deep-dive, folder structure, security-baseline rationale). A reader arriving to install had to scroll past the pitch; a reader wanting the lifecycle table had to scroll past the install steps; a returning user looking for how to update had nowhere obvious to look. The content is now reorganized so the README is a slim front door and everything an operator does lives in one navigable guide. All cross-references were updated in the same pass, so existing links continue to resolve (hence MINOR, not MAJOR).

### Added

- **`docs/USER-GUIDE.md`** — the operator's guide, opening with a table of contents and covering getting started (former README Steps 1 through 8: the wizard path and the manual path), working with the team day to day, updating the playbook in an existing project, and the session refresh prompt. One doc, one audience (someone using the playbook), TOC-navigable so a returning user jumps straight to "Updating the playbook."
- **`docs/LIFECYCLE.md`** — the eight-stage lifecycle deep-dive with the stage / lead / artifact table (former README "The lifecycle in eight stages").
- **`docs/ARCHITECTURE.md`** — folder structure and how the pieces fit, including a "Two copies of the security baseline" section that summarizes and points to the authoritative copy in `reference/rules/TEAM-PERSONAS.md`.

### Changed

- **`README.md`** reduced from 482 to ~100 lines. Keeps the hero image, the seventeen-agent team, the three-layer memory model, the skills note, the lifecycle teaser (now linking `docs/LIFECYCLE.md`), the wizard/knowledge/security overviews, a slim **Get started** section (clone command, the two-path pointer to the User Guide, and an "Already installed?" pointer to the updating section), and a **Documentation** map table linking every doc.
- **`START-PLAYBOOK.md`** "How to run this" gains a one-line reframe: it is the wizard engine Claude follows; humans begin at `docs/USER-GUIDE.md`. The Phase 8 next-step pointer now targets `docs/LIFECYCLE.md` instead of the README.
- **Cross-references repointed** in `scripts/MANUAL-INSTALL.md` (six refs), `scripts/install-core.sh`, `scripts/install-skills.sh`, `reference/rules/PRE-DEVELOPMENT-BLUEPRINT.md`, `reference/rules/DESIGN-METHODOLOGY.md` (added a Lifecycle overview row), `reference/tools/SKILLS-INVENTORY.md`, `AGENTS.md` ("Read these first"), and `.claude/CLAUDE.md` ("Read these first").

### Removed

- **README "Security baseline lives in two places on purpose" section** deleted as a duplicate; the authoritative copy already lives in `reference/rules/TEAM-PERSONAS.md`, and `docs/ARCHITECTURE.md` carries a short summary plus a pointer.

### Why this matters

A front-door README that fits on a screen or two converts better and is cheaper to maintain. Moving everything an operator does into one TOC-navigable guide means a reader opens exactly one file and jumps to their moment — first install, day-to-day work, or updating — instead of scrolling a 482-line README or guessing which doc holds the update steps. Reference material (lifecycle, architecture) stays separate because it serves a different audience.

## [v1.10.0] - 2026-06-06 - QA Engineer added as the 17th persona and agent, wired into the bug-fix verification gate

The playbook gains a QA Engineer: the teammate who understands the whole platform end to end and turns manual checks into an automated functional and end-to-end test suite. It writes the tests, runs them, keeps them trustworthy (no flaky greens retried into silence), escalates to a human when a test genuinely needs one, and acts as the gate that proves a bug fix works before its issue closes. The role was deliberately split out rather than folded into the Developer persona: the Developer owns change-scoped unit tests and TDD on the code being written, while the QA Engineer owns the horizontal, whole-platform functional suite and the automated verification that fixes hold. It also complements the Security Auditor (which finds the unknown) by proving the known.

### Added

- **`reference/personas/QA-ENGINEER-PERSONA.md`** — the six-section persona (whole-platform understanding, behavior-first test names, trustworthy green over flaky coverage, honest human escalation, verdicts backed by run output).
- **`reference/agents/qa-engineer.md`** — the agent shim (model `sonnet`, `memory: project`, preloads `superpowers:test-driven-development`, `superpowers:systematic-debugging`, and `superpowers:verification-before-completion`) pointing at the persona and its rule docs.

### Changed

- **Team count 16 to 17** across `README.md` (narrative team description, install/verify steps, folder-structure comments), `START-PLAYBOOK.md` (Phase 3 announce and verify, vanilla branches), `AGENTS.md` (specialist table), `reference/agents/README.md` (team-at-a-glance table), `reference/rules/TEAM-PERSONAS.md` (template count and table), and `scripts/install-agents.sh` (usage text). The `/agents` Library total moves from "23 total" to "24 total" (17 project agents plus 7 built-ins).
- **`reference/rules/BUG-TRACKING.md` verify step** now names the QA Engineer as the primary verify actor: run the functional test that covers the fix (writing one if none exists) before the issue closes, alongside the reporter or Developer.
- **`reference/personas/DEVELOPER-PERSONA.md` When to Switch** gains a pointer routing functional/E2E suites, automated regression, and bug-fix verification to the QA Engineer, so the boundary is explicit from both sides.

### Why this matters

The bug-fix flow needs a real gate: a fix is not done because a unit test passes, it is done because the functional behavior a user relies on is proven to work again. Giving that gate to a dedicated teammate with its own memory of suites, coverage gaps, and quarantined flakes keeps verification honest and keeps the regression suite trustworthy over time, instead of it decaying into a pile of skipped or retried tests nobody believes.

## [v1.9.0] - 2026-06-06 - Security Auditor added as the 16th persona and agent, with a new audit rule doc

The playbook gains a Security Auditor: the teammate who hunts for what is wrong before a user or an attacker finds it, across three lenses (UI/UX defects, security vulnerabilities, and functional bugs). Security is its deepest, most structured lens; UI and functional bugs file through the same discipline. It finds and files; the Developer, Designer, and Compliance personas own the fixes. The role ships as a generic template (XRPL/validator content stays only as flavored examples), broken out into the playbook's standard three-file shape: a six-section persona, a rule doc that holds the operational detail, and a thin agent shim. The team count moves from 15 to 16 everywhere it is stated.

### Added

- **`reference/personas/SECURITY-AUDITOR-PERSONA.md`** — the six-section persona (Who I Am, What I Optimize For, Voice and Style, What NOT to Do, When to Use, When to Switch, plus See also and example prompts). Adversarial by default, evidence-based, severity calibrated not inflated.
- **`reference/rules/SECURITY-AUDIT.md`** — a standalone rule doc (companion to the numbered six, like `SECURITY-POSTURE.md`) holding the audit methodology, the three lenses, the finding structure, the two-deliverable report (audit report plus GitHub tracking report), the issue and mitigation-report templates, and the closure process. It defers to `BUG-TRACKING.md` for the label taxonomy, severity-vs-priority, the lifecycle, and the `gh` CLI rather than duplicating them.
- **`reference/agents/security-auditor.md`** — the agent shim (model `opus`, `memory: project`, preloads `superpowers:systematic-debugging`) pointing at the persona and its rule docs.

### Changed

- **Team count 15 to 16** across `README.md` (narrative team description, install/verify steps, folder-structure comments), `START-PLAYBOOK.md` (Phase 3 announce and verify, vanilla branches), `AGENTS.md` (specialist table), `reference/agents/README.md` (team-at-a-glance table), `reference/rules/TEAM-PERSONAS.md` (template count and table), and `scripts/install-agents.sh` (usage text). The `/agents` Library total moves from "22 total" to "23 total" (16 project agents plus 7 built-ins).
- **`scripts/install-agents.sh`** install logic is unchanged; it already counts agent definitions dynamically (excluding `README.md`), so it picks up the 16th agent automatically. Only the hardcoded usage text was updated.

### Why this matters

Every project needs someone whose job is to assume the optimistic path is wrong and go looking for the proof. Folding audit work into the Developer persona meant it competed with shipping for attention and rarely won. A dedicated auditor with its own memory of audits run, findings filed, and surfaces owed a re-audit keeps quality and security on a separate, durable track, while remediation stays with the personas that own the code, the UI, and the controls.

## [v1.8.7] - 2026-06-02 - Platform labels moved out of code blocks so the GitHub copy button only copies the command

The README install code blocks in sub-steps 6a, 6b, and 6c each carried the platform label as a `# comment` line inside the code fence (e.g., `# macOS / Linux / Git Bash / WSL`). When a reader clicked the GitHub copy icon on the rendered README, the copy included the comment line. Pasting into a terminal works (shell comments are no-ops) but the noise is bad UX. The pattern moves the label out of the code block and into a bold prose statement above it, so the copy button only ever captures the command itself.

### Changed

- **`README.md` sub-step 6a (Universal core)** code blocks reshaped. Was: bash block with a `# macOS / Linux / Git Bash / WSL` comment and a PowerShell block with a `# Windows PowerShell (with WSL installed)` comment. Now: bold prose statement above each block, code block contains only `bash .internal/playbook/scripts/install-core.sh` (or the `wsl` prefix variant).
- **`README.md` sub-step 6b (Domain skills)** same reshape applied to the `install-skills.sh all` command and its WSL variant.
- **`README.md` sub-step 6c (AI agents)** same reshape applied to the `install-agents.sh` command and its WSL variant.

### Why this matters

The GitHub README copy button is the path a new user follows for the install. Every character it copies is a character that lands in the user's terminal. Comment-as-platform-label was a fine pattern for source readability but a poor pattern for the install UX. Bold prose statement above the block reads at least as well to the human reader and produces a copy that is exactly one command.

## [v1.8.6] - 2026-06-02 - install-agents.sh now skips the folder README.md instead of installing it as a 16th agent

The `install-agents.sh` script counted every `.md` file in `reference/agents/` and copied each one into `.claude/agents/`. The folder also contains a `README.md` (documentation for the agent-definition file shape), so on every install run the script reported `16 agent definition(s) available` and copied `README.md` into `.claude/agents/README.md` as if it were a 16th agent. The script reported `Failed: 0` because the copy succeeded, but the resulting `.claude/agents/README.md` is not a valid Claude Code subagent definition and would either be ignored or warn at session start.

### Fixed

- **`scripts/install-agents.sh` pre-flight count** changed from `find "$SRC" -maxdepth 1 -name '*.md' -type f` to `find "$SRC" -maxdepth 1 -name '*.md' -type f -not -name 'README.md'`. The count is now an accurate 15.
- **`scripts/install-agents.sh` install loop** updated to skip any source file whose basename is `README` when no explicit agent list is passed. Comment in the loop documents the exclusion. Explicit per-name installs (`bash install-agents.sh architect developer`) are unaffected — they only install what is passed in.

### Verified after the fix

- Re-running the script reports `15 agent definition(s) available in .internal/playbook/reference/agents` and installs exactly the 15 expected agents (architect, bizdev, brand, community, compliance, customer-success, designer, developer, enduser, finance, legal, marketing, people, sales, support). No `README.md` lands in `.claude/agents/`.

### One-time cleanup users may need

Any project that ran the previous version of `install-agents.sh` and ended up with a `.claude/agents/README.md` file should delete it once: `rm .claude/agents/README.md`. Future `install-agents.sh` re-runs no longer create it.

## [v1.8.5] - 2026-06-02 - Hero image updated with cleaner AI-agent figure rendering

The hero image at `images/playbook-hero.png` was regenerated with cleaner persona figure rendering. The previous version used faceless deep-navy humanoid silhouettes; the new version uses lighter teal AI-agent figures with single illuminated sensor points. Same composition, same labels, same palette, same lifecycle ribbon — just sharper visual identity for the team members. Composition was preserved exactly so the README alt text and the body walkthrough still match what the reader sees.

### Changed

- **`images/playbook-hero.png`** replaced with the new generation. PNG size dropped from about 700 KB to about 480 KB thanks to cleaner gradients in the new figures.
- **`images/playbook-hero.webp`** regenerated from the same source at about 95 KB.

### Unchanged

- README alt text (composition is identical: title, KNOWLEDGE books, SECURITY shield, central cube with AI WIZARD hat and SKILLS cards, six labeled persona figures, lifecycle ribbon).
- README intro body (the walkthrough sections still match what the picture shows).
- Aspect ratio (16:9 horizontal at 1600x893).
- Color palette (deep navy, warm teal, muted gold, pure white).

## [v1.8.4] - 2026-06-02 - New README sub-section explains the three-layer team memory pattern

The README intro covered the team (the bullet list of fifteen agents) and the knowledge folder (one of the four pillars from the hero diagram), but did not explicitly explain how memory works across the team or how cross-agent handoffs propagate as the lifecycle iterates. A reader new to the playbook would not see how the architect's decisions reach the developer next week, or how a build-stage discovery feeds back into requirements without anyone manually re-briefing every other agent. The new sub-section makes that explicit.

### Added

- **README "How the team remembers and iterates" sub-section** inserted between "Your team of fifteen AI agents" and "The skills they invoke." Five short paragraphs covering the three memory layers in plain language: (1) per-agent `MEMORY.md` files at `.claude/agent-memory/<agent>/MEMORY.md` and Claude Code's auto-injection at session start; (2) the shared knowledge folder at `.internal/playbook/knowledge/` and how cross-agent handoffs propagate through it; (3) the canonical lifecycle artifacts (`USE_CASES.md`, `REQUIREMENTS.md`, `DESIGN.md`, `ARCHITECTURE.md`, ADRs in `docs/adr/`, implementation plans under `docs/superpowers/plans/`) as cross-team memory that updates carry forward through. The closing paragraph ties the three layers to the iteration pattern explicitly. The sub-section cross-references the existing "The knowledge that accumulates" section as the deeper dive on the second layer.

### Why this matters

The lifecycle is intentionally not waterfall. Stages run in parallel where they do not block each other; earlier stages get revisited when reality teaches the team something new in build. For that to work, the team needs a memory pattern where revisions propagate automatically rather than requiring a human to re-brief every agent. The three-layer pattern was already built into the playbook (the agent definitions use Claude Code's `memory: project` frontmatter; the knowledge folder is already in place; the canonical docs are read at session start), but the README intro did not explain it. This patch closes that gap.

## [v1.8.3] - 2026-06-02 - Specialist-role list in README reformatted as bullet points

The README section "Your team of fifteen AI agents" listed all fifteen specialist roles inside a single wrapped paragraph. The paragraph form made the roles hard to scan and obscured the six-plus-nine split that the picture and the surrounding prose already call out. Reformatted the two role lists as bullet points so each role and its one-line responsibility reads at a glance. The lead-in sentences, the cross-session memory description, and the invocation guidance stay as prose.

### Changed

- **`README.md` "Your team of fifteen AI agents" section** restructured. The six visible-in-the-picture roles (architect, developer, designer, brand, compliance, end user) are now a bullet list with each role's parenthetical responsibility preserved verbatim. The nine other roles (legal, sales, customer-success, marketing, people, community, support, finance, bizdev) are a second bullet list with a brief one-line job description per role for symmetry with the first list. The closing sentences about persona files, cross-session memory, and invocation syntax remain in prose, unchanged.

## [v1.8.2] - 2026-06-02 - Stage 7 label in the lifecycle-in-eight-stages table shortened to "Ship"

The README's "## The lifecycle in eight stages" table had stage 7 labeled "Ship and operate." The "What happens" column already lists "staging, production, monitoring, incidents," which is the operate aspect. The shorter label "Ship" also aligns with the SHIP marker on the hero image lifecycle ribbon. Stage-label parity with the diagram and the eight-stage intro flow is the right thing.

### Changed

- **`README.md` Stage 7 label** in the lifecycle table changed from "Ship and operate" to "Ship." Description, lead persona, and artifact columns are unchanged. The shorter label now matches the SHIP marker in the hero image and the `concept → ... → ship → iterate` flow in the intro.

## [v1.8.1] - 2026-06-02 - Codex coverage added to README section 6c (AI agents)

v1.6.0 added Codex (OpenAI) support across the playbook but missed section 6c in the README. The section described the install-agents.sh script and `.claude/agents/` install path with no mention of Codex. A Codex user reading the manual install path (Steps 6 and 7 rather than the wizard at Step 5) had no guidance on what to do for the agent install step. v1.8.1 closes that gap.

### Added

- **README section 6c "For Codex users" sub-paragraph** after the existing Claude Code code blocks. Explains that Codex has its own native subagent system (file format TOML at `.codex/agents/<name>.toml`, listed and switched via `/agent`), but the playbook ships only the Markdown form today. Codex users have two options. (1) The persona-as-prompt fallback (read the persona file at `reference/personas/<ROLE>-PERSONA.md` and ask Codex to adopt the voice). (2) Hand-write TOML subagent files at `.codex/agents/<name>.toml` derived from the Markdown personas. Notes that the security baseline copy step still applies on the Codex path, and points at `AGENTS.md` and `START-PLAYBOOK.md` Phase 3 Codex branch for the full reference. Parallel TOML subagent definitions plus an `install-agents-codex.sh` script remain tracked as a future playbook release.

### Why this matters

v1.6.0's Codex-support work covered the README Step 1 dual-tool install, the `AGENTS.md` proper Codex entry-point section, the `SKILLS-INVENTORY` invocation cheat sheet, and the `START-PLAYBOOK.md` Phase 0 / Phase 1 / Phase 3 branching. Section 6c was missed because the wizard path in Step 5 covered it, and the implicit assumption was that Codex users would take the wizard path. In practice a Codex user reading the manual Steps 6 and 7 still needs to know what to do at the agent-install step. This patch is a small one-paragraph addition that makes the manual path equally usable in either host tool.

## [v1.8.0] - 2026-06-02 - New PRE-DEVELOPMENT-BLUEPRINT rule doc; lifecycle revert to eight stages

Two bundled changes. First, v1.7.2's decision to split use cases into its own stage was reverted in favor of keeping "requirements" as a single broader stage. The reasoning: requirements as a stage encapsulates many distinct artifacts (strategy, use cases, functional and non-functional rules, UX wireframes, technical architecture, constraints, delivery plan), not just one. Calling it "requirements" with use cases bundled in is more accurate than splitting because there are six other sub-artifacts that would also have to become stages by the same logic. Second, the comprehensive framework for what the requirements stage actually produces was pulled out of the README intro and into a new dedicated rule doc the team can reference during planning work.

### Added

- **New `reference/rules/PRE-DEVELOPMENT-BLUEPRINT.md`** (sixth rule doc, about 170 lines). Documents the seven artifacts the requirements stage produces — strategy and viability, functional and non-functional requirements, use cases, UX/UI design, technical architecture, constraints and assumptions, and the project delivery plan. For each artifact: what it covers, which persona owns it, where it lives, what it feeds into next. Includes an ASCII flow diagram of how the seven artifacts feed each other, a mapping to the lifecycle's eight-stage and seven-phase framings, a per-persona "when to read this doc" table, and a common-pitfalls section. Calibrated against the seven-part "Complete Pre-Development Blueprint" framework the project maintainer noted.

### Changed

- **`README.md` intro lifecycle section** reverted to the eight-stage flow `concept → requirements → design → architecture → planning → build → ship → iterate` after v1.7.2 had split use cases out as its own stage. The flow still appears on its own bolded line (from v1.7.1). The requirements stage description now mentions that it produces the pre-development blueprint and points at the new `reference/rules/PRE-DEVELOPMENT-BLUEPRINT.md` for the full framework.
- **`README.md` lifecycle section heading** reverted from "The nine-stage lifecycle" to "The eight-stage lifecycle."
- **`AGENTS.md` README description** reverted from "nine-stage lifecycle" to "eight-stage lifecycle."
- **All five existing rule-doc `About this file` headers updated** to reflect the new total. `TEAM-PERSONAS.md` is now "First of six," `DESIGN-METHODOLOGY.md` is "Second of six," `DEVELOPMENT-BUILD.md` is "Third of six," `BUSINESS-OPERATIONS.md` is "Fourth of six," `BUG-TRACKING.md` is "Fifth of six." The four older rule docs were previously stale at "of four" (BUG-TRACKING.md was added in v1.5.0 but the four older rule docs were not updated to reference it at the time); this release also fixes that older inconsistency.

### Rationale

Requirements as a stage name is the umbrella concept that scales. Splitting use cases off as its own stage looked clean for the README's flow but raised the question of why not also split strategy, UX/UI design, technical architecture, constraints, and the delivery plan — each of which produces its own distinct artifact. The cleaner answer is to keep the stage name broad and document the artifacts the stage produces in a dedicated reference doc, which is what `PRE-DEVELOPMENT-BLUEPRINT.md` now does. The hero image's eight-marker lifecycle ribbon stays correctly aligned with the README's eight-stage flow, no image regeneration needed.

## [v1.7.2] - 2026-06-02 - Lifecycle flow becomes nine stages with use cases as its own step

The README intro lifecycle had been listed as eight stages (`concept → requirements → ...`) with use cases folded into the requirements stage as a sub-artifact. This obscured that use cases is a discrete intermediate step that produces its own artifact (`USE_CASES.md`) before requirements (`REQUIREMENTS.md`) get written. The canonical `DESIGN-METHODOLOGY.md` treats them as separate sub-phases (3.1 and 3.2). v1.7.2 pulls use cases out as its own visible stage and presents the flow on its own bolded line for readability.

### Changed

- **`README.md` intro lifecycle section** is now nine stages instead of eight:

```
concept → use cases → requirements → design → architecture → planning → build → ship → iterate
```

The flow appears on its own bolded line directly under the lead-in sentence so the sequence reads at a glance instead of being buried in prose.

- **`README.md` intro lifecycle section heading** renamed from "The eight-stage lifecycle" to "The nine-stage lifecycle."
- **`README.md` artifact mapping** updated to give use cases its own artifact (`USE_CASES.md`) separate from requirements (`REQUIREMENTS.md`). Previously the requirements stage was credited with producing both artifacts; now each stage owns its own.
- **`README.md` hero-image alt text** updated to remove the "eight-stage" qualifier. The alt now describes what is literally in the image (a ribbon with eight markers for concept, requirements, design, architecture, planning, build, ship, and iterate) without claiming a stage count. The image is acknowledged in the body as bundling use cases and requirements under a single ribbon marker for visual simplicity.
- **`AGENTS.md` README description** updated from "Five-step bootstrap, eight-stage lifecycle, persona system, install scripts" to "Bootstrap walkthrough, nine-stage lifecycle, persona system, install scripts."

### Not changed

- **The hero image at `images/playbook-hero.png`** stays as-is with its eight visible ribbon markers. The user explicitly accepted that the image can imply use cases within the requirements marker; a future image regeneration may add a USE CASES marker but it is not required.
- **The lifecycle-in-eight-stages table further down the README** stays as-is. It uses a different framing (Foundation → Concept → Definition → Architecture → Positioning → Build → Ship-and-operate → Iterate) that groups use cases plus requirements under "Definition" and combines other stages. The intro is the engineering-flow view; the table is the project-lifecycle view; both are internally consistent.

## [v1.7.1] - 2026-06-02 - Friendlier intro framing and "Getting started" section name

Two polish edits on top of v1.7.0. The intro got a sentence framing the value proposition in human terms ("the team you always wished you had on day one"), and the "Bootstrap your project" section heading became "Getting started" to match how new users actually read GitHub READMEs (they look for "Getting started," not "Bootstrap your project").

### Added

- **README intro humanizing paragraph** between the opening "you bring the idea, the playbook brings everything else" pitch and the "here is what is inside" walkthrough lead. Reads: "Think of it as the team you always wished you had on day one — already in place when you start, with their own voices, their own workflows, and their own memory of every decision the project has made. No hiring loop. No onboarding ramp. Open Claude Code or Codex on Monday morning and the architect, the developer, the designer, the brand strategist, the compliance lead, and the rest are right there, ready to work."

### Changed

- **`README.md` section heading** renamed from "Bootstrap your project" to "Getting started." This is the section that holds the eight-step bootstrap walkthrough. The new name matches the convention users expect when scanning a GitHub README for where to start.
- **`scripts/MANUAL-INSTALL.md` cross-references updated** to point at the new heading name. Five references in the manual-install doc previously said `see "Bootstrap your project" section in ../README.md`; they now say `see "Getting started" section in ../README.md`. The internal links continue to resolve correctly.

## [v1.7.0] - 2026-06-02 - Hero image plus plain-language intro that walks through it

The README intro previously presented the playbook as a five-phase numbered process (Bootstrap, Activate, Move through the lifecycle, Stay safe, Build memory). The framing was procedural but did not give a new reader an immediate visual or plain-English picture of what was inside the playbook. New users had to read all five numbered paragraphs and assemble the mental model themselves. v1.7.0 ships a labeled hero diagram at the top of the README and rewrites the intro as a plain-language walkthrough of the diagram's elements, so a new reader gets the picture in under a minute.

### Added

- **`images/playbook-hero.png`** at the playbook root. Labeled isometric diagram showing the project (central crystalline cube), the team (six labeled persona figures), the lifecycle (eight-stage ribbon along the bottom), the four supporting pillars (KNOWLEDGE books upper-left, SECURITY shield upper-right, SKILLS card fan upper-left of cube, AI WIZARD hat upper-right of cube), and the title `PROJECT LIFECYCLE PLAYBOOK`. Optimized PNG at about 700 KB; a WebP fallback at about 80 KB also ships at `images/playbook-hero.webp`. Aspect ratio 16:9 horizontal, rendered at 1600x893.
- **README hero image at the top of the intro** with descriptive alt text covering every labeled element of the diagram for accessibility (WCAG 2.2 AA per the playbook's stated floor).
- **Six labeled walkthrough sections in the intro** that map one-to-one to the diagram's elements. Each section explains one part of the playbook in plain language: the team of fifteen AI agents, the skills they invoke, the eight-stage lifecycle, the AI wizard that sets it all up, the knowledge that accumulates, and the security baseline every change inherits.

### Changed

- **README title** changed from "Playbook - The Project Lifecycle" to "Project Lifecycle Playbook" to match the title rendered in the hero image.
- **README intro** restructured from a five-phase numbered list (Bootstrap, Activate, Move through the lifecycle, Stay safe, Build memory) to a plain-language walkthrough that uses the hero diagram as the visual anchor. Same playbook concepts conveyed, framed as "here is what is inside, walking through the picture" rather than "the playbook moves you through five phases."

### Rationale

The five-phase numbered list shipped in v1.4.2 was a procedural improvement over the original feature-list bullets, but it still required the reader to assemble the playbook's mental model from text alone. Adding a labeled diagram and walking through its elements in plain prose gives a reader the model visually first and the supporting detail second. The new structure also makes each load-bearing concept (AI agents, skills, lifecycle, wizard, knowledge, security) its own section heading, so a reader scanning the README can jump directly to the section relevant to them.

The intro stays close to the same length and the same concepts as v1.4.2; only the framing and the addition of the hero image are new. The bootstrap step-by-step section below the intro is unchanged.

## [v1.6.1] - 2026-06-02 - Correct lifecycle stage order in README intro

The README intro previously listed the eight-stage lifecycle as "Concept, positioning, design, architecture, planning, build, ship, iterate." This put Positioning at position 2, which contradicts the canonical structure in `reference/rules/DESIGN-METHODOLOGY.md` where Product Positioning is Phase 5 (brand strategy, business plan, go-to-market) and runs as a parallel track alongside engineering, not as the second step after Concept. The natural slot at position 2 is Requirements (what the system must do, as captured in `USE_CASES.md` and `REQUIREMENTS.md`), which then flows into Design and Architecture.

### Fixed

- **`README.md` Phase 3 stage list** corrected from `Concept, positioning, design, architecture, planning, build, ship, iterate` to `Concept, requirements, design, architecture, planning, build, ship, iterate`. The corrected sequence matches the natural progression captured in `DESIGN-METHODOLOGY.md` (concept feeds product definition feeds design feeds architecture feeds implementation feeds iteration).
- **`README.md` named-artifact list in the same sentence** updated to match. Removed `BRAND_STRATEGY.md` from the inline list (positioning is now called out as a separate parallel track) and added `USE_CASES.md`, `REQUIREMENTS.md` as the requirements-stage artifacts.
- **New sentence in the same Phase 3 description** explaining that positioning runs as a parallel track (brand strategy, business plan, go-to-market) alongside engineering rather than as a step in the main flow.

## [v1.6.0] - 2026-06-01 - Codex (OpenAI) supported alongside Claude Code

The playbook previously assumed Claude Code as the host AI coding tool. The wizard scripts, install commands, prompt syntax, and tool-specific entry-point guidance were all Claude-Code-flavored. Codex (OpenAI) had matured by mid-2026 into a real alternative with a comparable feature set (skills, subagents, MCP, `AGENTS.md` as the project-instructions file). The playbook now supports both tools side-by-side, with explicit guidance on what is shared, what differs, and how to invoke the equivalent operations in each.

### Added

- **`reference/tools/SKILLS-INVENTORY.md` Tool support section** at the top of the file. Documents which agent each install path serves, what is shared (domain skills via `~/.agents/skills/`, `superpowers` plugin, `parallel-cli` binary, `AGENTS.md` entry point), and what is not shared (subagent file format, memory pattern, `parallel-agent-skills` Claude-only plugin).
- **`reference/tools/SKILLS-INVENTORY.md` Invocation syntax cheat sheet** mapping the eleven most common operations (skill invocation, agent list, plugin install, MCP add, file mention, persona invocation, model pick, memory inspection, and more) between Claude Code and Codex.
- **`reference/tools/SKILLS-INVENTORY.md` Codex install command** added to the `superpowers` plugin section (`/plugins` marketplace browser, search "Superpowers").
- **`AGENTS.md` proper Codex entry-point section** that covers subagent invocation, skill invocation, file mention, MCP add, and memory. Acknowledges the subagent file-format gap (Codex TOML vs Claude Markdown+YAML) and documents the persona-as-prompt fallback for Codex users until parallel TOML subagent definitions ship in a future release.
- **`README.md` Step 1 dual-tool install** with separate Claude Code and Codex install commands. Notes that the wizard and most prompts in this playbook default to Claude Code syntax with the Codex equivalents in `SKILLS-INVENTORY.md`.
- **`START-PLAYBOOK.md` Phase 0** asks the user which tool they are running and branches Phase 1 and Phase 3 accordingly.
- **`START-PLAYBOOK.md` Phase 1 Codex branch** that walks the manual install of Superpowers via Codex's `/plugins` marketplace and notes that the `parallel-agent-skills` Claude-only plugin step is skipped.
- **`START-PLAYBOOK.md` Phase 3 Codex branch** that documents the persona-as-prompt fallback (read `.internal/playbook/reference/personas/<ROLE>-PERSONA.md` and adopt the voice) and manually copies the security baseline.

### Changed

- **`reference/tools/SKILLS-INVENTORY.md` title** changed from "Installed Claude Code Skills Inventory" to "Skills Inventory" (drops the tool-specific framing now that both tools are supported).
- **`reference/tools/SKILLS-INVENTORY.md` About section** generalized to "AI coding agent plugin skills" rather than "Claude Code plugin skills."
- **`reference/tools/SKILLS-INVENTORY.md` parallel-agent-skills section** flagged Claude-Code-only with explicit Codex guidance to invoke `parallel-cli` directly.
- **`AGENTS.md` Tool-specific entry points section** restructured. Claude Code stays as the primary entry point. Codex gets its own dedicated subsection (was previously folded into a thin "Other AI coding agents" note).
- **`START-PLAYBOOK.md` Phase 0 announcement** time estimate updated from "30 to 45 minutes" to "15 to 25 minutes" to reflect the autonomous flow shipped in v1.4.0, and Phase 6/7 labels updated to "Determine the team and decisions autonomously" and "Present the proposal and execute on approval" to match the v1.4.0 wizard structure.

### Out of scope for this release (deferred)

- **Native TOML subagent definitions for Codex** at `reference/agents-codex/<name>.toml` so Codex users get auto-loaded persona-backed subagents. Tracked as a future v1.7.0 work item. The current Codex experience is the persona-as-prompt fallback documented in `AGENTS.md`.
- **A `install-core-codex.sh` / `install-agents-codex.sh` parallel install path** so Codex users get a script-driven install instead of the manual walk-through. Tracked as a future v1.7.0 work item.
- **Per-prompt Codex equivalents** in BUG-TRACKING.md, DESIGN-METHODOLOGY.md, DEVELOPMENT-BUILD.md, BUSINESS-OPERATIONS.md, and the persona templates. The Invocation syntax cheat sheet in SKILLS-INVENTORY covers the syntax map; per-prompt rewrites would multiply the playbook's example-prompt surface area and are deferred until the per-tool prompt difference proves itself worth the maintenance cost.

### Rationale

Codex CLI matured into GA in 2025-2026 with skills (GA Dec 2025), subagents (GA), MCP support (GA), and `AGENTS.md` as the open-standard project-instructions file (adopted by Codex, Cursor, Gemini CLI, Windsurf, Copilot). The playbook positioned itself as a generic SaaS playbook for AI-coding-agent-driven development; restricting it to Claude Code would miss a meaningful share of the target audience. The dual-tool support keeps the playbook usable for either tool without forcing one user to read past the other's syntax.

## [v1.5.3] - 2026-06-01 - Scrub maintainer-project identification from CHANGELOG and DEFAULT-DECISIONS

The CHANGELOG and `DEFAULT-DECISIONS.md` previously identified the maintainer's first project by name as the calibration source for the wizard defaults and the v1.5.2 cleanup. The playbook is meant for any team to use; the maintainer's own project is a private context that should not appear in public artifacts. Replaced all named references with generic phrasing ("the maintainer's first project," "the maintainer's persona walkthrough") that preserves the calibration provenance without identifying the source project.

### Changed

- **`CHANGELOG.md` v1.4.0 entry** body language changed from "Calibrated against the [named project] persona walkthrough" to "Calibrated against the maintainer's first persona walkthrough."
- **`CHANGELOG.md` v1.5.2 entry** title changed from "Strip [named project]-specific leakage" to "Strip project-specific leakage." Body language adjusted to match (three additional name removals in the same entry).
- **`reference/rules/DEFAULT-DECISIONS.md` Maintenance log** initial-publication note changed from "derived from the persona walkthrough that produced the [named project] customized persona set" to "derived from the maintainer's first persona walkthrough."

### Why this matters

The playbook is positioned for any team building a SaaS on top of Claude Code (with XRPL starter packs as the named-stack option). Identifying the maintainer's own project in public artifacts crosses a confidentiality line that the project owner explicitly does not want crossed. Future CHANGELOG entries describe the change without identifying the originating project; if a specific project's needs drove a playbook change, the entry says "the maintainer's first project" or "a project that ran the wizard" rather than the project name.

## [v1.5.2] - 2026-06-01 - Strip project-specific leakage from BUG-TRACKING.md

The new `BUG-TRACKING.md` rule doc shipped in v1.5.0 had project-specific knowledge-file references and persona names baked in from the maintainer's first use of the playbook. Anyone cloning the standalone playbook would hit broken `release-gate-authority.md` references and a `PERSONA-CFO.md` reference to a voice persona that does not exist in the playbook templates. The XRPL-oriented examples (mainnet, testnet, EVM Sidechain, Hooks, on-chain writes, mint, signing, wire) were correct for the playbook's positioning and were preserved. The project-specific bits were stripped.

### Changed

- **`reference/rules/BUG-TRACKING.md`** references to `release-gate-authority.md` replaced with generic language about the project's release-gate policy. The doc now teaches the concept ("blocking by default with a documented exception path") without pre-shipping a specific implementation, since release-gate policy is appropriately a per-project knowledge entry rather than a playbook default.
- **`reference/rules/BUG-TRACKING.md`** reference to `PERSONA-CFO.md` replaced with generic language about brand-call authority. The CFO concept stays (it is a generic SaaS role); the specific filename pointing at a project-only voice persona is gone.
- **`reference/rules/BUG-TRACKING.md`** "Where to find the references" table updated. Removed the `PERSONA-CFO.md` row; added a `FINANCE-PERSONA.md` row that points at the actual playbook template. The Developer persona row now leads with the playbook template path and notes the project-customized copy as the second-priority lookup.
- **`reference/rules/BUG-TRACKING.md`** "Customer Success (or BizDev pre-launch)" phrase generalized to "Customer Success (or whoever owns customer-facing communication when Customer Success is not yet staffed)." The "BizDev pre-launch" pattern came from the maintainer's persona walkthrough and is not a playbook-default convention.

### Verified preserved

- All XRPL-flavored examples and load-bearing categories (money, on-chain state, signing, authentication, regulated data, mainnet vs testnet, mint flow, wire) stay. The playbook positions itself for SaaS built on top of Claude Code with XRPL starter packs (`xrpl`, `xrpl-hooks`); XRPL-flavored bug examples reinforce that positioning rather than fight it.

## [v1.5.1] - 2026-06-01 - Wire BUG-TRACKING.md and SECURITY-POSTURE.md into the personas that touch them

v1.5.0 created the new `BUG-TRACKING.md` rule doc but did not wire it into the agent shims or the persona templates that should pick it up at session start. Six personas touch bugs in their lane (Developer, Compliance, Customer Success, Support, Architect, End-User) and each one needed an explicit pointer so the agents would actually find and follow the new discipline. Same gap for `SECURITY-POSTURE.md` in the Developer persona template, which referenced the build flow and the team-personas template but never the security baseline. Both gaps closed in one PATCH.

### Changed

- **Six agent shims at `reference/agents/`** updated to add a `BUG-TRACKING.md` reference line in their "Your relevant rule docs" section: `developer.md`, `compliance.md`, `customer-success.md`, `support.md`, `architect.md`, `enduser.md`. Each pointer includes a one-line description tied to that persona's lane (Developer owns the discipline; Compliance owns regulated-surface bug handling and postmortem; Customer Success owns customer-reported bug routing; Support owns intake and provenance tagging; Architect owns structural-bug ADR triggers; End-User owns user-facing bug copy).
- **Six persona templates at `reference/personas/`** updated to add `BUG-TRACKING.md` to their "See also" section: `DEVELOPER-PERSONA.md`, `COMPLIANCE-PERSONA.md`, `CUSTOMER-SUCCESS-PERSONA.md`, `SUPPORT-PERSONA.md`, `ARCHITECT-PERSONA.md`, `ENDUSER-PERSONA.md`. The Developer template also picked up a `SECURITY-POSTURE.md` pointer that was missing from the original; symmetry with the agent shim it sits behind.
- **Support persona template "See also" line for Phase 5** updated to clarify that the deeper bug-tracking reference is now `BUG-TRACKING.md` and the Phase 5 section in `DEVELOPMENT-BUILD.md` is the quick reference for the build flow.

### Why this matters

Agent shims drive what each persona reads at session start. A reference doc that exists but is not linked from the right shim is invisible to the agent that should use it. The same pattern applies to the persona templates that future projects use as their starting point: missing references in the template mean every customized persona file inherits the gap. Wiring `BUG-TRACKING.md` and `SECURITY-POSTURE.md` into both layers closes the loop so the new rule doc is actually picked up by every persona whose lane intersects bug-tracking work.

## [v1.5.0] - 2026-06-01 - New BUG-TRACKING rule doc for GitHub Issues discipline

The playbook had a Phase 5 Bug tracking section inside `DEVELOPMENT-BUILD.md` but no dedicated reference for the GitHub Issues mechanics, the severity-versus-priority distinction, the four-question prioritization checklist, the lifecycle, the triage cadence, the AI-agent workflow with `gh`, the postmortem discipline, or the bug-debt management practice. Developer agents triaging or prioritizing a bug had to figure out the discipline from scratch each time. New `BUG-TRACKING.md` rule doc consolidates the practice.

### Added

- **New `reference/rules/BUG-TRACKING.md`** (about 350 lines). Fifth of five rule docs alongside `TEAM-PERSONAS.md`, `DESIGN-METHODOLOGY.md`, `DEVELOPMENT-BUILD.md`, `BUSINESS-OPERATIONS.md`. Covers repository setup (`.github/ISSUE_TEMPLATE/bug.yml` Issue Form, PR template, CODEOWNERS, label seed), the Issue Type / Label / Project v2 field separation that GitHub modernized in 2024-2025, the severity-versus-priority distinction with separate P0-P3 ladders for each, the four-question prioritization checklist, escalation triggers to CFO and Compliance, when to mark wontfix, Projects v2 board pattern (single org-level board with auto-add and auto-status workflows), the full file→triage→prioritize→assign→reproduce→fix→review→verify→close lifecycle, three-layer triage cadence (daily / weekly / monthly), filing-a-bug-well guidance (including the Copilot-coding-agent angle that issues now double as agent prompts), commit / PR / issue linking conventions including auto-close keywords and `gh issue develop` for linked branches, Sub-issues for grouped bugs, AI-agent workflow patterns with the canonical `gh` CLI vocabulary table, four example prompts (file, triage, fix, verify), Sentry-to-GitHub integration discipline, customer-reported bug routing through Customer Success, postmortem discipline (blameless template, lesson-into-control loop), bug-debt management with the severity-weighted backlog formula plus zero-bug-policy versus bug-budget patterns, and a common-pitfalls section.
- **Severity vs Priority distinction documented as load-bearing.** Severity is the technical impact (how bad is the failure); priority is the business urgency (when must it be fixed). The AI agents that triage most often conflate these; the distinction now has its own subsection with four-tier ladders and worked examples.
- **The four-question prioritization checklist.** Agents that are unsure walk the checklist in order. The first "yes" sets the priority floor. Covers regulated-surface impact, customer-blocking impact, deadline urgency, and team-unblocking impact.

### Changed

- **`DEVELOPMENT-BUILD.md` Phase 5** opens with a one-paragraph pointer to the new `BUG-TRACKING.md` rule doc. The existing Phase 5 content (the bug filing template plus the three example prompts) is preserved as the quick reference for the build flow; the deeper discipline now lives in `BUG-TRACKING.md`.

### Rationale

The shift to a dedicated bug-tracking rule doc follows the same pattern as the other rule docs: when a topic shows up in multiple personas' work (Developer triages, Compliance flags regulated-surface bugs, Customer Success handles customer-reported bugs, Architect contributes to root-cause analysis on structural bugs), the topic earns its own rule doc rather than living inside one persona's working file. The new doc is also calibrated against 2026 GitHub practice: Issue Types (GA), Projects v2 with built-in automations (Projects classic deprecated), `gh issue develop` for linked branches, Sub-issues for grouped bugs, and the Copilot coding agent (`@copilot` assignee) workflow that has been GA since September 2025.

## [v1.4.3] - 2026-06-01 - Security baseline now installs on bootstrap; SKILLS-INVENTORY wired in

Two issues addressed in one PATCH.

**1.** The README previously claimed `START-PLAYBOOK.md` Phase 1 copied the playbook's reference security posture into `.claude/SECURITY-POSTURE.md`. This claim was not true. Neither Phase 1 nor any of the three install scripts actually copied the file. A fresh user running the wizard end-to-end finished bootstrap with the reference at `.internal/playbook/reference/rules/SECURITY-POSTURE.md` and no `.claude/SECURITY-POSTURE.md`, which meant Claude Code would not auto-load the security rules on session start (it reads from `.claude/`). The security baseline was supposed to be the load-bearing constraint every persona inherits; without the install, the constraint was not inherited.

**2.** `SKILLS-INVENTORY.md` (the catalog of installed Claude Code skills with what each one does) was thinly wired into user-facing surfaces. After Phases 1 through 3 a user had 18+ new skills installed and no signpost to the catalog explaining what they all do. The file was referenced from the rules docs and one persona template but not from the wizard or the README install step.

### Added

- **`install-agents.sh` installs the security baseline.** New step at the end of the script copies `.internal/playbook/reference/rules/SECURITY-POSTURE.md` to `.claude/SECURITY-POSTURE.md` on first run. On re-run, an existing `.claude/SECURITY-POSTURE.md` is preserved so project customizations are not overwritten. Reports the action in the script's standard `[ OK ]` / `[WARN]` format. Failures increment the existing `FAILED` counter so re-runs surface the issue.
- **Script header comment** updated to document the new security-baseline copy behavior alongside the agents copy.
- **`START-PLAYBOOK.md` Phase 3 Verify section** updated to mention the security-baseline install and to point at `reference/tools/SKILLS-INVENTORY.md` as the catalog of what got installed in Phases 1 and 2.
- **`README.md` Step 6c (AI agents install) body** updated to mention that the same script installs the security baseline.
- **`README.md` Step 6e (verify the install)** picks up `ls .claude/SECURITY-POSTURE.md` as a sixth verification check and a new paragraph pointing at the SKILLS-INVENTORY catalog.

### Fixed

- **`README.md` Source layout paragraph** stale claim corrected. Previously read: "The bootstrap script (`START-PLAYBOOK.md` Phase 1) copies the reference into `.claude/`." Now reads: "The `install-agents.sh` script (run during Step 6c / wizard Phase 3) copies the reference into `.claude/` on first run; on re-run an existing `.claude/SECURITY-POSTURE.md` is preserved so project customizations are not overwritten."

### Rationale for the idempotency choice

The copy is idempotent in the no-overwrite direction (skip on existing) rather than the overwrite direction (replace on existing) because customized `.claude/SECURITY-POSTURE.md` content represents project-specific decisions (added rules, jurisdiction-specific notes, vendor-specific clauses) that overwriting on re-run would silently destroy. The right pattern for re-syncing a customized copy to the latest playbook reference is a manual diff and merge by the project owner, not an automatic clobber by an install script.

## [v1.4.2] - 2026-05-31 - README intro polished into a five-phase process

The README.md intro previously presented the playbook as a six-bullet feature list ("the playbook brings: an eight-stage lifecycle, 15 persona-backed agents, a bootstrap wizard, install scripts, a security baseline, a project-knowledge folder"). Read as a feature list, the bullets did not tell the user what would actually happen when they used the playbook. Restructured into a five-phase process that maps directly to the user's experience: bootstrap once, activate the team, move through the lifecycle, stay safe, build institutional memory.

### Changed

- **README.md intro paragraphs** broken from one long paragraph plus one feature-list paragraph into three shorter context paragraphs (what a lifecycle is, what kind of lifecycle this is, what this playbook is) plus the five-phase process list.
- **README.md feature bullets** replaced with **a five-phase numbered process**: (1) Bootstrap once, (2) Activate the team, (3) Move through the eight-stage lifecycle, (4) Stay safe, (5) Build institutional memory. Each phase explains what happens, what the user gets, and where to look next. The same content from the old feature list is preserved; the framing is procedural instead of catalog-shaped.
- **README.md "Bootstrap your project" section header paragraph** updated for consistency. Step 5 (the wizard) framed as "the recommended one-paste shortcut" rather than "an optional one-paste shortcut" to align with the autonomous-by-default direction of v1.4.0 and the Preferred reframe of Step 3 in v1.4.1. Time estimates differentiated: wizard path 15 to 25 minutes, manual path 30 to 45 minutes.

### Fixed

- **README.md intro stale 30 to 45 minute wizard estimate.** v1.4.0 made the wizard autonomous and dropped the typical time to 15 to 25 minutes; the intro bullet still cited the pre-autonomy 30 to 45 minute figure. Corrected.
- **README.md intro semicolons and long sentences** broken into shorter sentences for plain-English readability consistent with the persona voice rules.

## [v1.4.1] - 2026-05-31 - Step 3 reframed from Optional to Preferred

The README.md Step 3 (drop project materials into `.internal/playbook/input/`) was labeled "Optional," which undersold its importance. With the autonomous Phase 5 introduced in v1.4.0, materials in `input/` directly determine how much the wizard can decide on its own. More materials means better inferred defaults, fewer flagged items in the proposal, and less back-and-forth during the Phase 6 review. Calling Step 3 "Optional" tells users it does not matter; calling it "Preferred" tells the truth that it makes the rest of the bootstrap measurably faster and more accurate.

### Changed

- **README.md Step 3 heading** renamed from "Step 3. (Optional) Drop project materials into the input folder" to "Step 3. (Preferred) Drop project materials into the input folder."
- **README.md Step 3 body** rewritten to explain the cause and effect: good materials in `input/` → wizard infers regulatory scope, audience, product category, and stage automatically → fewer questions in Phase 6. Empty `input/` → either conversational brainstorm (works but adds 10 to 15 minutes of dialogue) or vanilla team (no customization, customization work shifts to later). The skip-allowed language is preserved for users who genuinely have nothing project-relevant on disk.

### Fixed

- **README.md Step 3 stale reference** to "the bootstrap script in Step 6 reads everything there." Step 6 is the install script; the wizard that reads `input/` is in Step 5. Corrected.

## [v1.4.0] - 2026-05-31 - Autonomous persona-customization flow in the wizard

The conversational bootstrap wizard previously walked persona customization conversationally: per persona, draft → ask 2-3 questions → wait for approval → write → next persona. With 5 to 8 personas at 5 to 8 minutes each, that was 25 to 65 minutes of per-decision Q&A on a topic surface most users do not have an opinion on. Replaced with an autonomous decision flow plus a single consolidated review.

### Added

- **New `reference/rules/DEFAULT-DECISIONS.md`** the wizard's decision register. Per-persona defaults, cross-cutting defaults, override triggers per decision, universal fallback rule for genuinely-ambiguous cases. Calibrated against the maintainer's first persona walkthrough that produced eight customized personas and six cross-cutting knowledge entries in May 2026. The wizard reads this file during Phase 5 and applies defaults plus inferred overrides automatically. Humans rarely read it directly; the audit trail for any given project lands in that project's `BOOTSTRAP-PROPOSAL.md` and `PROJECT-OVERVIEW.md`.
- **`BOOTSTRAP-PROPOSAL.md`** as a new artifact the wizard writes during Phase 5. Single consolidated document listing the proposed team, every per-persona decision with reasoning, every cross-cutting decision with reasoning, the exact list of files the wizard will write on approval, and a Flagged section for any items the wizard could not safely default. Preserved after Phase 7 as the permanent audit trail of what the wizard decided and why.
- **Three new accept paths in Phase 6**: "accept" (executes the proposal as written), "accept with changes" plus specific changes (updates and re-presents), "show me file X" (renders a specific draft before deciding). "Reject and restart" remains as the fourth option for genuinely-off-target proposals.

### Changed

- **START-PLAYBOOK.md Phase 5** rewritten from "propose the team" (conversational) to "determine the team and decisions autonomously" (autonomous). Reads the decision register, curates the team, applies per-persona and cross-cutting defaults, infers overrides from the project context, drafts every persona file and every knowledge entry in memory, writes the consolidated proposal. Does not ask the user about per-decision choices.
- **START-PLAYBOOK.md Phase 6** rewritten from "customize each chosen persona" (per-persona Q&A loop) to "present the proposal and execute on approval" (single review surface). The user reads the proposal file, the wizard waits for one of four reply patterns, and executes accordingly. Pause-and-resume is now grounded in the proposal file rather than an in-progress state file.
- **START-PLAYBOOK.md Phase 7** updated to include cross-cutting decisions in `PROJECT-OVERVIEW.md` (one line per knowledge entry written, with the path) and to preserve `BOOTSTRAP-PROPOSAL.md` as the audit trail.
- **README.md Step 5 description** rewritten to match the new autonomous behavior. Time estimate adjusted from "about 30 to 45 minutes" to "about 15 to 25 minutes" reflecting the speed-up. New paragraph explains why autonomous decision-making is the default ("most users do not know which test discipline, accessibility floor, audit framework, or partner tiering convention is right for their project").

### Rationale

Per-decision conversational Q&A optimizes for user control but assumes the user has a confident opinion on every decision. In practice, most users meet the bootstrap wizard with no opinion on test discipline scope, accessibility framework choice, audit posture, partner-tiering convention, or microcopy authority pattern, and the conversational format forces a guess on each. The autonomous flow plus consolidated review delivers a more accurate result (the defaults are calibrated against the patterns that ship the cleanest), a faster experience (one review surface, not 20), and a clearer audit trail (the proposal file captures every decision and its reasoning in one place that the user reads once and the project preserves forever).

The flow preserves user control in three places: the user accepts or rejects the whole proposal; the user can request specific changes before execution; the user can drill into any individual file before deciding. The pattern matches how senior reviewers operate on technical proposals: read the whole, comment on parts, approve once.

## [v1.3.0] - 2026-05-30 - Windows command variants in Step 6

Step 6 (Install the three tools) previously showed only one `bash` command per install (6a, 6b, 6c) with no guidance for Windows users. The install scripts already worked on Windows under Git Bash or WSL (per the script headers), but the README never said so. Closed that gap.

### Added

- README **Step 6 intro note** stating that the bash commands in 6a, 6b, and 6c run unchanged on Windows from Git Bash or WSL, and that the PowerShell variants below each command use `wsl` and require WSL to be installed.
- README **6a, 6b, 6c PowerShell variants** beneath each existing bash command. Each macOS/Linux/Git Bash/WSL fence is now labeled with a comment, and a second PowerShell fence shows the `wsl bash ...` equivalent for native Windows PowerShell users.

### Unchanged

- 6d (`/reload-plugins`) and 6e (`claude --version`, `parallel-cli --version`, etc.) are terminal-agnostic and unchanged. The slash command runs inside Claude Code regardless of host shell, and the verify commands work the same in PowerShell as in bash.

## [v1.2.0] - 2026-05-30 - Conversational bootstrap wizard step

The Bootstrap section intro had been advertising a conversational bootstrap wizard ("from cloned playbook to working project in about 30 to 45 minutes") but no step in the README actually invoked it. Closed that gap.

### Added

- README **new Step 5 "Run the conversational bootstrap wizard"** as an optional shortcut, recommended for first-time users. Pastes the full `START-PLAYBOOK.md` Phase 0-8 prompt at the Claude Code prompt. Wizard handles the install (Step 6) and AI agent setup (Step 7) in one conversational flow with approval pauses at every meaningful decision. Includes an eight-phase breakdown so the reader understands what the wizard will do before pasting the prompt, time estimate (30 to 45 minutes), and explicit "skip Steps 6 and 7 and go to Step 8" routing if the user takes the shortcut.

### Changed

- README Bootstrap section grows from 7 steps to 8 to accommodate the wizard step. Current Step 5 (Install the three tools) is renumbered to Step 6 with sub-steps 6a-6e. Current Step 6 (Set up the AI agents) is renumbered to Step 7 with sub-steps 7a-7d. Begin Stage 2 is renumbered to Step 8.
- All cross-references updated to the new numbering ("Step 5c" → "Step 6c", "Step 6d" → "Step 7d", body references to "from 5b" → "from 6b", etc.).
- "Working with the team after bootstrap" section's opening line now references the wizard branch: "After Step 7 finishes (or Step 5 if you took the wizard shortcut)..."

## [v1.1.0] - 2026-05-30 - Post-release documentation improvements

Improvements landed shortly after the initial release based on first-user feedback and a research pass through the official Claude Code subagents docs. No breaking changes. All Claude Code subagent behavior described in the playbook is now cited from the official docs.

### Added

- README new dedicated **Step 6 "Set up the AI agents"** with four sub-steps. AI agents are the load-bearing piece of the playbook and now get their own step instead of being a sub-step under Install. Sub-steps: 6a Verify the AI agents are registered, 6b How to invoke an AI agent, 6c Smoke test (recommended), 6d Customize the personas for this project.
- README **6b "How to invoke an AI agent"** with the three documented explicit invocation patterns (natural language, `@-mention`, `--agent` CLI flag) plus a fourth implicit pattern (automatic delegation). Each with syntax, example, and when-to-use guidance.
- README **6b parallel-dispatch note**: how to request multi-lane work in one natural-language prompt and have Claude orchestrate via the Agent tool.
- README **6b one-off general-purpose subagent note**: for tasks not matching any persona, the user can describe work to the main session and Claude dispatches a `general-purpose` subagent under the hood without needing a new agent definition file.
- README **6b stop-key documentation**: `Esc` (preserves work), `Ctrl+X Ctrl+K` twice within 3 seconds (kills background subagents), `Ctrl+C`, `Ctrl+B` (background), and the `/agents` Running tab.
- README **"Working with the team after bootstrap" section** explaining day-to-day agent invocation patterns, switching between agents within a session, and re-customizing a persona later.
- README **optional functional smoke test** (invoke the developer agent on `git status`) to verify the agent system fires end-to-end.
- README **`/agents` dialog tab explanation** (Library, Running) so users do not interpret empty Running as a failed install.
- README **Step 5d alternative**: documented that exiting Claude Code and starting a new session also re-loads subagents (per the official docs "subagents are loaded at session start"), as an alternative to `/reload-plugins`.
- `CHANGELOG.md` at the playbook root with semantic versioning.

### Changed

- README **Bootstrap section restructured to 7 steps**. Step 5 installs the three tools (with sub-steps 5a-5e for universal core, domain skills, AI agents, reload Claude Code, verify install). Step 6 is the dedicated AI agents setup (6a-6d). Step 7 is Begin Stage 2.
- README **Step 5 and Step 6 sub-steps use consistent `**5X. Label.**` bold-prefix pattern** for visual rhythm (5a/5b/5c/5d/5e and 6a/6b/6c/6d).
- README **install commands now have descriptions ABOVE the code fence** rather than below. Same fix applied in MANUAL-INSTALL.md and reference/agents/README.md.
- README **intro consolidated** into a single paragraph followed by a bulleted "what the playbook brings" summary.
- README **lifecycle section moved** from eight paragraph blocks to a single four-column HTML table (Stage, What happens, Lead, Artifact) with explicit column widths so the Stage column does not wrap.
- README **Step 5c renamed** from "Persona-backed agents" to "AI agents" (sentence-case, parallel with 5a/5b labels).

### Fixed

- **`/agents` dialog tabs**: corrected from "three tabs" (speculation) to "two documented tabs" (Library + Running) per the official subagents docs. The Library tab is also the create/edit/delete management view.
- **MANUAL-INSTALL.md Step 3a**: description now precedes the `/plugin marketplace add` command rather than following it.
- **reference/agents/README.md**: description now precedes the `install-agents.sh` command rather than following it.

### Documented (corrections from earlier speculation)

- Agent invocation: three explicit patterns (natural language, `@-mention`, `--agent` flag) plus automatic delegation (implicit, best-effort). The `@-mention` form is the only guaranteed per-task invocation.
- Agent lifecycle: agents are on-demand. A definition file in `.claude/agents/` does not execute until invoked. The Running tab populates only while an agent is actively working.
- Memory injection: first 200 lines or 25KB of `MEMORY.md` (whichever is smaller) auto-injects into the agent's system prompt at invocation time, not session start.
- Session restart: subagents are loaded at session start per the official docs. No `/reload-plugins` needed on a fresh session unless agent definitions changed since the last session.

## [v1.0.0] - 2026-05-30 - Initial release

First public version of the playbook. Ships with:

### Structure

- `README.md` at root: Project Lifecycle playbook with the eight-stage lifecycle, bootstrap procedure, folder structure, security baseline pattern.
- `START-PLAYBOOK.md` at root: 8-phase conversational bootstrap script Claude reads and executes.
- `AGENTS.md` at root: multi-tool entry point for any AI coding agent (Claude Code, Cursor, Cline, Codex).
- `input/`: empty folder where users drop project materials before bootstrap (gitignored).
- `knowledge/`: project-shared decision log convention.
- `scripts/`: install automation (install-core.sh, install-skills.sh, install-agents.sh) plus MANUAL-INSTALL.md for the hand-walked alternative.
- `reference/`: Claude-facing definitions split into rules/, agents/, personas/, tools/.

### Personas

- 15 generic persona templates in `reference/personas/` (architect, bizdev, brand, community, compliance, customer-success, designer, developer, enduser, finance, legal, marketing, people, sales, support).
- 15 matching native Claude Code agent definitions in `reference/agents/` with `memory: project` enabled for cross-session recall.

### Rules

- `reference/rules/TEAM-PERSONAS.md`: persona-as-team concept and persona-to-agent mapping.
- `reference/rules/DESIGN-METHODOLOGY.md`: lifecycle Stages 2 through 5 (planning and positioning).
- `reference/rules/DEVELOPMENT-BUILD.md`: lifecycle Stages 6 through 8 (build, ship, iterate).
- `reference/rules/BUSINESS-OPERATIONS.md`: functional areas beyond product and engineering, organized by maturity tier.
- `reference/rules/SECURITY-POSTURE.md`: six-rule security baseline that every persona inherits.

### Tools

- `reference/tools/SKILLS-INVENTORY.md`: catalog of installable Claude Code skills with tier guidance and per-project-shape recommendations.
- Starter packs: `xrpl`, `xrpl-hooks`, `frontend`, `baseline`, plus `all` to install all four.

### Conventions

- `.claude/CLAUDE.md` and `.claude/SECURITY-POSTURE.md` are the production locations Claude Code reads on every session start; `.claude/` requires explicit user approval to write to even in `bypassPermissions` mode.
- `.internal/<ROLE>-PERSONA.md` is where each project's customized persona files live (the playbook personas in `reference/personas/` are templates).
- `.internal/playbook/knowledge/` is the project-shared decision and learning log; distinct from per-agent memory (`.claude/agent-memory/<agent>/MEMORY.md`) and from personal session memory (`~/.claude/projects/<slug>/memory/`).

## Maintenance convention for future entries

When making a change to the playbook, add a new entry at the top of this file before the most recent version. Use the next version per semver: PATCH for typo fixes, MINOR for new sections or non-breaking restructure, MAJOR for moves that break existing references or remove things users depend on. Each entry follows the shape above: version with date, one-line summary, then sections for Added, Changed, Removed, Fixed, Security as relevant.
