# Memory Hygiene

## About this file

A companion rule doc (like `SECURITY-POSTURE.md`, `SECURITY-AUDIT.md`, and `LOOP-ENGINEERING.md`) alongside the six numbered rule docs. It covers how the team keeps its three memory layers trustworthy over time: per-agent `MEMORY.md` files, the shared knowledge folder, and the session-facing summaries that feed both.

Every agent inherits this discipline the same way it inherits the security baseline. The memory system is the playbook's core promise: iteration propagates through memory, not through a human re-briefing every agent. That promise decays silently if memory grows without pruning. This doc is the maintenance schedule.

## Why hygiene is load-bearing

Two failure modes, both invisible until they hurt.

**The injection cliff.** Claude Code auto-injects only the first 200 lines or 25KB (whichever is smaller) of an agent's `MEMORY.md` at invocation. Everything past that line silently never reaches the agent. An agent whose memory file has grown to 400 lines is not an agent with more memory; it is an agent with the *oldest half* of its memory and no idea the newer half exists, or the reverse, depending on how the file was ordered. Nothing errors. The agent just gets quietly dumber.

**Context poisoning.** A stale entry is worse than no entry. A decision that was reversed three weeks ago but still reads as current in a memory file will steer an agent confidently in the wrong direction. The agent has no way to know the entry is stale; it trusts its memory. Superseded facts must be removed or explicitly marked reversed, not left standing.

## Rules for per-agent MEMORY.md

1. **Stay under the injection budget.** Keep `MEMORY.md` under 200 lines and 25KB at all times. The `verify-install.sh` script warns when a memory file crosses the budget.
2. **Most useful first.** Order the file so the top holds what the agent needs next session: current focus, then recent decisions, then durable conventions. If the file is ever truncated, the bottom is what gets lost, so the bottom holds the most expendable content.
3. **Delete superseded facts, do not append corrections.** When a fact changes, rewrite the entry in place. Memory is working state, not an audit log. The audit log lives in git history and the knowledge folder.
4. **Compact on exit.** Each agent updates its memory at the end of meaningful work. That update is also the compaction moment: fold finished threads into one-line outcomes, drop anything the project's canonical docs now record, and cut resolved TODOs entirely.
5. **What belongs elsewhere, goes elsewhere.** A fact that matters to more than one agent goes to the knowledge folder, then gets *removed* from the private memory once written there. A fact the canonical artifacts (`REQUIREMENTS.md`, `DESIGN.md`, code) already record does not belong in memory at all.

## Rules for the knowledge folder

The knowledge folder's dated-entries format (see `../../knowledge/README.md`) is append-only inside a file: prior entries are the record and are not edited. Hygiene works at the file and folder level instead.

1. **Reversals are explicit.** When a decision is reversed, the new dated entry says so and names the entry it supersedes. A reader must never have to guess which of two conflicting entries is current.
2. **Summarize long files at the top.** When a topic file exceeds roughly 150 lines, add or refresh a short **Current position** section directly under the title: three to six lines stating what is true *now*, so no reader has to reconstruct the present from the entry history. The dated entries below remain untouched.
3. **Split and merge on the existing convention.** A file covering two topics splits; two files that constantly cross-reference merge. This is already the folder's rule; hygiene means actually doing it when the smell appears, not deferring it.
4. **Graduate stable knowledge to docs.** An entry that has been stable long enough to be canonical belongs in `docs/` (the shareable artifacts). Move the content, leave a one-line pointer entry behind.

## The review ritual

Hygiene needs an owner and a cadence, or it does not happen.

- **Owner.** The **architect** agent owns the knowledge-folder review; each agent owns its own `MEMORY.md`. The architect already reads cross-cutting decisions as part of its lane, which makes it the natural auditor of the shared layer.
- **Cadence.** At every lifecycle stage transition, and at least once a month during the continuous stages (build, ship, iterate). The prompt is one line:

  ```
  Using the architect agent, run the memory hygiene review from
  .project/playbook/reference/rules/MEMORY-HYGIENE.md: check every
  knowledge file for missing Current position sections, unmarked
  reversals, and graduation candidates. Report before changing anything.
  ```

- **Mechanical check.** `bash .project/playbook/scripts/verify-install.sh` flags any per-agent `MEMORY.md` over the injection budget. Run it as part of the review.

The review reports before it edits. Pruning shared memory is a destructive act; the architect proposes the compaction and the human approves it, the same approval discipline the wizard uses for persona files.

## What this doc does not cover

Session memory for the human-and-Claude working thread (a project may keep one, as this playbook's own source repo does) is personal working state, not team memory, and is out of scope here. So is Codex's generated "Memories" feature; treat that as convenience state, never as source of truth, per `AGENTS.md`.

## See also

- `../../knowledge/README.md` — the dated-entries format and the write-when test.
- `TEAM-PERSONAS.md` — the two persistence mechanisms and how agents are instructed to use them.
- `../agents/README.md` — the `memory: project` frontmatter that creates per-agent memory.
- `CONTEXT-ECONOMY.md` — the same discipline one layer up: everything else that loads into a session, and the handoff prompt that writes task state into these memory layers before a session is cleared.
