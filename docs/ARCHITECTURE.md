# How the playbook is put together

![Playbook logical architecture diagram. The scene reads left to right as a control loop on a white background. On the far left, a warm amber human figure labeled YOU holds a glowing idea lightbulb above an inbox tray labeled input/. An arrow labeled "drop idea + materials" points to a dark wizard hat on a podium labeled BOOTSTRAP WIZARD. A second arrow, "stands up team," points to a wide platform slab labeled CLAUDE CODE / CODEX, the runtime. Three teal AI-agent figures stand on the slab under the label THE TEAM, with an x17 badge. Floating above them, a fan of cards and a wrench labeled SKILLS & TOOLS feeds into the team, and a three-layer stack labeled MEMORY reads and writes to the team. A striped shield labeled SECURITY BASELINE runs underneath the slab as a foundation. On the far right, a crystalline glass cube on a glowing podium is labeled YOUR PROJECT, reached by an arrow labeled "build + update artifacts" from the team and an arrow labeled "invoke by name" arcing from YOU to the team. Along the bottom, an eight-marker lifecycle ribbon runs concept, requirements, design, architecture, planning, build, ship, iterate, with a curved arrow looping iterate back to concept.](../images/logical-architecture.png)

This document explains the architecture in two passes. First the logical architecture:
the moving parts and how they work with you. Then the physical layout: the folders on
disk and where each part lives.

## Logical architecture

The playbook is a team of agentic AI agents that runs inside your coding tool and works a
project through a lifecycle. You stay in the loop the whole way. You bring the idea and
direct the work; the team does the building and remembers everything it learns.

There are nine logical pieces. The diagram above shows how they connect.

- **You, the operator.** You own the project. You drop materials in, invoke agents by
  name, and accept or reject what they propose. Nothing happens without you.
- **The bootstrap wizard.** A conversational setup script at `START-PLAYBOOK.md`. It
  reads anything you drop in `input/`, decides every per-persona choice, and stands up
  a customized team in one pass. You run it once per project, guided by default or
  fully unattended on request (one summary at the end, adjust afterward).
- **The runtime.** Claude Code or Codex. This is the host tool the agents run inside.
  The playbook does not replace your tool; it configures it. Native subagent installs
  and per-agent memory are Claude Code only today; Codex runs the personas as prompts
  (see `AGENTS.md` for the support matrix).
- **The team.** Seventeen specialist agents (architect, developer, designer, and the
  rest). You invoke one by name and it works autonomously within its lane until the
  task is done.
- **Skills and tools.** The curated workflows and external tools an agent calls when a
  task needs them. A skill's instructions load on demand. Its short description loads
  every session, so install the packs a project needs, not all of them. See
  `../reference/rules/CONTEXT-ECONOMY.md` for how the team keeps sessions small.
- **Memory, in three layers.** Per-agent memory (what each agent did before), the
  shared knowledge folder (cross-cutting decisions every agent reads), and the
  canonical artifacts (`REQUIREMENTS.md`, `DESIGN.md`, `ARCHITECTURE.md`, plans, code).
  Together they are how the team remembers across sessions and hands off between agents.
- **The security baseline.** Six rules at `.claude/SECURITY-POSTURE.md` that every
  agent inherits. It sits under everything else as a foundation.
- **Your project.** The artifacts and code the team produces. This is the output.
- **The lifecycle.** The eight stages the work flows through: concept, requirements,
  design, architecture, planning, build, ship, iterate. The path is not one way; the
  team revisits earlier stages when reality teaches it something new.

### How it works with you

The loop runs the same way every time, whatever the task.

1. **You bring an idea and materials.** Drop notes, specs, or research in `input/`.
2. **The wizard stands up the team.** It reads your materials, tailors each persona to
   your project, installs the agents, and lays down the security baseline. Once per
   project.
3. **You invoke an agent by name.** In Claude Code, `@agent-architect` or natural
   language; in Codex, name the agent or use `/agent`.
4. **The agent loads its context and works.** It reads its own persona, its per-agent
   memory, the shared knowledge folder, and the security baseline, then calls the
   skills and tools the task needs.
5. **The agent produces or updates an artifact** and writes back to memory and
   knowledge. The work lands in your project; the lesson lands in the team's memory.
6. **The next agent picks it up.** Because the change is in shared memory and the
   canonical artifacts, the next agent you invoke starts from the updated state. No
   manual re-briefing.

That last point is the whole design. Iteration propagates across the team through
memory, not through you repeating yourself. The picture at the top of `README.md`
shows the same system from the team's point of view; this one shows it from yours.

## Folder structure

The logical pieces above map onto these folders on disk.

```
.project/playbook/
├── README.md          # Front door: what the playbook is, the team, the lifecycle
├── START-PLAYBOOK.md  # Bootstrap script (the prompt to paste into Claude Code is at the top)
├── VERSION            # Playbook release version; installers stamp it into .claude/
├── input/             # Drop project materials here (gitignored)
├── knowledge/         # Project-shared decisions and learnings
├── docs/              # Human-facing guides (getting started, using the team, lifecycle, this file)
├── scripts/           # Install and verify scripts plus MANUAL-INSTALL.md
└── reference/         # What Claude reads to act
    ├── rules/         # Detailed lifecycle phase docs
    ├── agents/        # 17 native Claude Code agent definitions
    ├── personas/      # 17 generic persona templates
    └── tools/         # SKILLS-INVENTORY.md
```

Project files outside the playbook that the bootstrap and the agents create or maintain:

```
AGENTS.md                                # Multi-tool entry point (any AI coding agent reads this)
.claude/CLAUDE.md                        # Project conventions and identity policy
.claude/SECURITY-POSTURE.md              # Six security rules (production copy)
.claude/agents/                          # Installed team (copied by install-agents.sh)
.claude/playbook-version                 # Version stamp written by install-agents.sh
.claude/agent-memory/<agent>/MEMORY.md   # Per-agent cross-session memory (auto-managed)
.project/<ROLE>-PERSONA.md               # Customized personas (from reference/personas/ templates)
docs/                                    # Shareable project artifacts (use cases, requirements, design, etc.)
docs/specs/                              # Dated design specs from brainstorming
docs/plans/                              # Dated implementation plans
```

## Two copies of the security baseline

The security baseline ships in two copies on purpose. `.claude/SECURITY-POSTURE.md` is the production copy Claude enforces; `.project/playbook/reference/rules/SECURITY-POSTURE.md` is the playbook reference copy that travels with the playbook. The split exists because the `.claude/` directory requires explicit user approval to write to even in `bypassPermissions` mode, so a long-running Claude session cannot silently weaken the rules. The `install-agents.sh` script (run during Step 6c / wizard Phase 3) copies the reference into `.claude/` on first run; on re-run an existing `.claude/SECURITY-POSTURE.md` is preserved so project customizations are not overwritten. Keep them in sync after bootstrap; the `.claude/` copy is the source of truth. The sync is checked, not just promised: `bash .project/playbook/scripts/verify-install.sh` diffs the two copies and warns when they differ, so drift is a reported state instead of a silent one.

The full rationale lives in `../reference/rules/TEAM-PERSONAS.md` under "Security baseline lives in two places on purpose."
