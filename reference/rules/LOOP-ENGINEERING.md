# Loop Engineering

## About this file

The playbook's reference for loop engineering: building a system that runs a coding agent on a recurring job without a human prompting each turn. Read this when a project has tedious, repeating work — failing CI, an issue inbox, dependency upgrades, a flaky-test hunt — and you want the agent to do it unattended and stop on its own when the job is done or it hits an honest wall.

The hands-on companion is the `loop-engineering` skill, part of the universal core (see `../tools/SKILLS-INVENTORY.md`). This file is the why and the discipline; the skill is the interview-and-scaffold that produces a runnable loop. Invoke it by saying "build a loop", "/goal", "/loop", "Ralph loop", or "loop contract". It works in Claude Code and Codex. Source and the deeper handbook: https://github.com/invincible04/awesome-loop-engineering.

The Developer and QA Engineer personas are the primary readers. The Architect reads "When a loop fits" before standing one up; the Security Auditor reads the workspace and budget constraints in the contract.

## What a loop is, and what it is not

A loop is not a cron job. A cron job repeats blindly on a clock. A loop discovers what to work on, hands it to a maker, has a separate checker verify the result, writes its progress to disk, decides what is next, and stops for a stated reason. The defining property is that it can stop itself. If the thing you are building cannot decide on its own when to halt, it is not a loop — it is an automation with a bug.

Build the stop conditions first. They are what let you walk away from it.

## When a loop fits (decide this before building anything)

A loop pays off only when both of these are true:

1. There is a **machine-checkable success criterion** — a test passes, the build goes green, a schema validates, a rubric returns PASS. Something a machine can confirm with no human looking.
2. Reaching it takes **tedious trial and error** you would otherwise grind through by hand, turn after turn.

If you cannot say how a machine would *know* the work is done, stop. A loop with no verifiable done-condition does not converge; it thrashes and burns tokens. Find a checkable proxy first, or keep prompting by hand. Do not reach for a loop to avoid understanding the work.

Two more preconditions. The work has to **recur often enough to repay** the loop's fixed setup cost — a rough floor is weekly; rarer than that, write a script. And the agent has to have **an engineer's tools** to get unstuck on its own: read logs, reproduce a failure, run its own code. If the check exists but the agent cannot run it, you have a human relay, not a loop.

Good candidates: fixing failing CI, triaging an issue inbox, dependency upgrades against a solid test suite, performance tuning against a benchmark, flaky-test hunts, keeping a doc build green. Poor candidates: open-ended design, anything where "good" is a matter of taste with no proxy, genuine one-offs.

## The maker / checker split

The single most important rule: the agent that does the work never grades its own work. A model marking its own homework is far too generous. Split the job in two.

- The **maker** does the work and *shows evidence* — the exact command it ran and the real output — rather than asserting success.
- The **checker** is a separate call that decides whether "done" is true. It returns PASS or FAIL with evidence, and may ESCALATE.

They must not be the same call. The checker is the asset you own and maintain; the maker is a commodity that gets better for free with every model release. Spend your design effort on the checker.

## The loop contract

Before scaffolding, the skill fills an eleven-part contract — the design artifact the loop is built from and reviewed against. Every field names a command, a path, or a number, never a vibe.

1. **Objective** — the recurring work; what the loop should make true.
2. **Done-condition** — the exact command or check that proves it, with no human looking. Answer this first and hard; if you cannot, you are not ready to build.
3. **Trigger** — a schedule, an event (push, new issue, CI failure), or an adaptive cadence.
4. **Discover / intake** — how a run picks what to work on.
5. **Workspace** — where it acts, and what is strictly off-limits (a worktree or sandbox; never force-push, touch secrets, change deps, or hit prod).
6. **Context** — what each run reads so it does not re-derive the project from zero.
7. **Delegation** — which agent is the maker, which separate one is the checker, and which model each runs on. An unattended loop multiplies whatever each turn costs, so name the models here instead of letting both inherit the most expensive one (`CONTEXT-ECONOMY.md` Rule 1). The maker is the commodity; if one role gets the stronger model, make it the checker.
8. **Verification** — the gates that must pass: tests, lint, types, an LLM-as-judge rubric.
9. **Memory / state** — where progress is stored so a run resumes after a restart.
10. **Budget** — the hard ceilings: max iterations, runtime, tokens, and a dollar cap if a credential can spend money.
11. **Hand-off** — when it escalates to a human instead of pressing on.

## The four honest stop conditions

Every loop must be able to stop for exactly one of these, and say which:

- **Goal met** — the separate checker confirms the done-condition.
- **Budget spent** — an iteration, token, time, or dollar ceiling tripped.
- **Stalled** — the same failure twice with no new evidence. Stop thrashing.
- **Needs a human** — high-risk or ambiguous, so it escalates. This is a success state, not a failure.

## The non-negotiable laws

Bake the first five into every maker's instructions. The last two are yours to own; the loop cannot enforce them for you.

1. The maker never grades its own work — a separate checker decides "done".
2. Never weaken or delete a test, or narrow a check, to make it pass. Fix the cause. If the test is wrong, escalate; do not silently edit it.
3. A loop that cannot stop is a bug. Wire the four stop conditions before the first run.
4. Memory lives on disk, not in the context. Read it first each turn, write it last. The agent forgets between runs; the repo does not.
5. Fix only the cause; do not widen scope. The smallest change that could be right.
6. Verification stays the engineer's responsibility. "Done" is a claim, not a proof.
7. The fleet scales to your review rate, not the tool's lane count. You are the serial bottleneck; the right number of parallel agents is usually a low single digit.

## Prove the checker before you trust it

The checker is the asset the loop rests on, so test it like code. Feed it two diffs for the same red check: one that fixes the cause, one that deletes or weakens the check. Confirm it PASSes only the first and FAILs (or ESCALATEs) the second. If the cheat slips through, the rubric is too loose — tighten it until the laziest passing path is to do the real work. This two-diff test is the smallest honest evaluation of a loop, and the one that matters most.

## What a loop never does for you

- **Verification.** A loop running unattended is also a loop making mistakes unattended. The separate checker makes "done" mean something; it does not make it certain.
- **Comprehension.** The faster it ships, the faster understanding-debt grows. Schedule time to read what it built.
- **Intent.** Why the work matters and what "good" means come from a human. The loop cannot tell the difference between using it to move faster on work you understand and using it to avoid understanding the work. You can.

Build the loop like someone who intends to stay the engineer, not just the person who presses go.

## Where loops fit the lifecycle

Loops belong to the continuous stages — Ship and Iterate (`../../docs/LIFECYCLE.md`). Once the build is real and a test suite or benchmark can vouch for "done", a loop is how the team keeps CI green, the dependency tree current, and the issue inbox triaged without a human in the inner loop. It complements the build discipline in `DEVELOPMENT-BUILD.md` (the loop is the unattended form of the same test-gated change) and the triage cadence in `BUG-TRACKING.md` (an issue-inbox loop runs that cadence on a schedule).

The per-tool mechanics — `/goal` and sub-agents in Claude Code, `codex exec` and `.codex/agents/` in Codex, and the native brakes each tool ships — live in the skill's own `reference/tool-mapping.md`. Start there when you build the first one.
