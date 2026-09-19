# Build, Test, Ship, Iterate

## About this file

Third of six rule docs in the playbook (`TEAM-PERSONAS.md`, `DESIGN-METHODOLOGY.md`, `DEVELOPMENT-BUILD.md` this file, `BUSINESS-OPERATIONS.md`, `BUG-TRACKING.md`, `PRE-DEVELOPMENT-BLUEPRINT.md`). Tooling inventory lives separately at `../tools/SKILLS-INVENTORY.md`. Picks up where `DESIGN-METHODOLOGY.md` leaves off. Covers turning the planning and positioning artifacts into shipped code, with the practices that surround the code: implementation planning, code execution, testing, code review, bug tracking, continuous integration, deployment, monitoring, and iteration.

The build phase is where good planning either pays off or gets exposed. The docs from `DESIGN-METHODOLOGY.md` (spec, use cases, requirements, design, architecture) are the inputs. The output is working code in production, plus a feedback loop back into the planning docs when reality teaches something new.

## The build flow at a glance

| Phase | What it produces | Driving skill(s) |
|---|---|---|
| 1. Implementation plan | A task-by-task plan in `docs/plans/` | `superpowers:writing-plans` |
| 2. Execute the plan | Code commits, optionally a branch | `superpowers:subagent-driven-development` |
| 3. Test | Unit, integration, functional, and smoke tests | `superpowers:test-driven-development` |
| 4. Code review | Reviewed code | `superpowers:requesting-code-review`, `superpowers:receiving-code-review` |
| 5. Bug tracking | A maintained issue tracker with triage | none specific (uses the project's tracker) |
| 6. Continuous integration | Automated checks on every change | none specific (uses the project's CI) |
| 7. Deployment | Code in staging then production | none specific (uses the project's deploy pipeline) |
| 8. Monitoring and incident response | Live signal and on-call response | none specific (uses the project's monitoring stack) |
| 9. Iteration loop | Updates that ripple back into `DESIGN-METHODOLOGY.md` artifacts | `superpowers:brainstorming` for substantive changes |

Each phase below explains why it matters, the artifact or state it produces, and the example Claude prompts to drive it.

## Phase 1. Implementation plan

**Why.** Code is built best when the work is decomposed into bite-sized, ordered tasks with clear acceptance criteria. The writing-plans skill produces exactly that. Each task is two to five minutes of work, has concrete files to modify, and a verification step. Without a plan, sessions wander and similar work gets reinvented across the codebase.

**Artifact.** `docs/plans/YYYY-MM-DD-<feature>-plan.md`.

**Example prompt.**

```
/superpowers:writing-plans Based on the spec at
docs/specs/YYYY-MM-DD-<topic>-design.md and the requirements at
docs/REQUIREMENTS.md, write an implementation plan to ship
<specific scope>. Break the work into bite-sized tasks. Each
task should name the files to modify, the test to write or
update, and the verification step. Save to docs/plans/.
```

**Flows to.** Phase 2.

## Phase 2. Execute the plan

**Why.** The subagent-driven-development skill executes a plan task by task with fresh subagents and a two-stage review pattern (spec compliance, then code quality). Fresh subagents prevent context pollution; the two-stage review catches issues before they compound across tasks.

**Artifact.** Code commits. Optionally a development branch when the work is isolated enough to need one.

**Example prompt.**

```
/superpowers:subagent-driven-development Execute the plan at
docs/plans/YYYY-MM-DD-<feature>-plan.md. Dispatch a fresh
implementation subagent per task. After each task, run a spec
compliance review, then a code quality review, then mark the
task complete. Commit at task boundaries with messages that
follow the project's commit style.
```

**Alternative for solo execution without subagents.**

```
/superpowers:executing-plans Execute the plan at
docs/plans/YYYY-MM-DD-<feature>-plan.md inline. Run the
verification step after each task and stop if any verification
fails. Commit at task boundaries.
```

**Flows to.** Phase 3.

## Phase 3. Test

**Why.** Tests are how the team learns whether the code does what it claims. A test suite that catches real regressions is worth its weight; a suite that passes regardless of what the code does is worse than no suite because it produces false confidence. The TDD skill keeps the discipline tight: red (write a failing test), green (write the smallest code that passes it), refactor (clean up without changing behavior).

**Artifact.** Test files alongside the code they cover, plus any standalone integration or functional test packages.

**Test types worth distinguishing.**

| Type | What it tests | When it runs |
|---|---|---|
| **Unit** | A single function or class in isolation | On every save and on every CI run |
| **Integration** | Two or more units working together (database, queue, etc.) | On every CI run |
| **Functional** | A complete user-facing flow end to end | On every CI run, slower; smoke subset on every save |
| **Smoke** | A small set of critical paths that must always work | Immediately after every deploy |
| **Contract** | The interface between this service and a partner | On every CI run, plus on every partner version bump |
| **Performance** | Response times, throughput, resource use under load | Scheduled (daily, weekly) and before any major release |

**Example prompt for writing a new test.**

```
/superpowers:test-driven-development Write a failing test for
<specific behavior> in <file path>. The test should fail
because the behavior is not yet implemented. Then write the
minimal code to make the test pass. Then refactor while
keeping the test green.
```

**Example prompt for filling a test gap on existing code.**

```
The function at <file>:<line> has no test coverage. Read the
function, identify the behaviors it claims, and write tests
that would catch a regression in each behavior. If any behavior
is ambiguous, flag it as a question instead of writing a test
that locks in an assumption.
```

**Flows to.** Phase 4.

## Phase 4. Code review

**Why.** Two eyes catch issues one set misses. Claude as a reviewer catches issues a human reviewer misses (and vice versa) because the two have different blind spots. The requesting-code-review and receiving-code-review skills give a template for each side of that interaction so the review is structured and actionable rather than vibes.

**Artifact.** Review comments addressed; merged or rebased code.

**Example prompt for asking Claude to review.**

```
/superpowers:requesting-code-review Review the diff from
<commit-range>. Focus on correctness, error handling, edge
cases, and adherence to the patterns in CLAUDE.md and the
relevant persona files. Flag anything that looks like a
regression or a missing test. Report findings as a structured
list with severity (blocker, important, nice-to-have).
```

**Example prompt for responding to review feedback.**

```
/superpowers:receiving-code-review Apply the review feedback
from <reviewer-source>. For each item, either implement the
change or write a brief response explaining why you are
declining. Group the fixes by file so commits stay clean.
```

**Flows to.** Phase 5 if bugs are found that need formal tracking, otherwise Phase 6 for CI.

## Phase 5. Bug tracking

**For the full reference** on GitHub Issues-based bug tracking (repository setup, label and Issue Type taxonomy, severity vs priority distinction, the four-question prioritization checklist, lifecycle, triage cadence, AI-agent workflow with `gh`, postmortem discipline, bug-debt management), read `BUG-TRACKING.md`. This Phase 5 section is the quick reference for the build flow; the deeper rule doc is where the discipline lives.

**Why.** Bugs need a place to live that survives across sessions, across team members, and across releases. Without a tracker, bugs get lost between a Slack thread and someone's memory. The tracker also doubles as the input for triage decisions (which bugs ship in the next release, which wait).

**Artifact.** A maintained issue tracker (GitHub Issues, Linear, Jira, or whatever the project uses), plus per-bug context captured at file time.

**Bug filing template.**

| Field | Content |
|---|---|
| **Title** | One sentence. What is wrong, in plain language. |
| **Steps to reproduce** | Numbered list. Exact actions a fresh reader can follow. |
| **Expected behavior** | What should have happened. |
| **Actual behavior** | What did happen, with error messages or screenshots. |
| **Environment** | Browser, OS, version, role, tenant, anything that scopes the issue. |
| **Severity** | Blocker (production down), Critical (major feature broken), Major (minor feature broken), Minor (cosmetic). |
| **First seen** | Commit SHA or release tag where the regression started, if known. |
| **Related artifacts** | Spec, requirement, or test that should have caught this. |

**Example prompt for triaging a bug.**

```
Triage the bug at <issue link or paste>. Read the steps to
reproduce, attempt them against the current main branch, and
report whether the bug reproduces. If it does, identify the
likely affected component from docs/ARCHITECTURE.md, propose a
severity, and suggest the smallest fix scope.
```

**Example prompt for fixing a bug.**

```
/superpowers:systematic-debugging The bug at <issue link>
reproduces. Investigate the root cause systematically (do not
guess). Once the cause is identified, write a failing test
that captures it, then fix the code, then verify the test
passes. Update the issue with the cause, the fix, and the test
reference. Commit the fix referencing the issue id.
```

**Example prompt for verifying a fix before close.**

```
The bug at <issue link> claims to be fixed in <commit SHA>.
Re-run the original steps to reproduce against current main.
Confirm the actual behavior now matches the expected behavior.
If yes, close the issue with a verification note. If no,
re-open with what is still wrong.
```

**Flows to.** Phase 6 (the fix runs through CI).

## Phase 6. Continuous integration

**Why.** CI is the safety net that catches regressions before they reach production. The point of CI is not to run tests; the point is to make running tests unavoidable. Every pull request, every push to main, every deploy candidate goes through CI. A failing CI build blocks merge.

**Artifact.** A CI configuration in the project (`.github/workflows/`, `.gitlab-ci.yml`, or equivalent) and a green build on every change.

**What CI should run.**

- Lint and format checks on every change.
- Unit and integration tests on every change.
- Functional tests on every change (slower, but worth the time).
- Security scans (dependency vulnerabilities, SAST) on every change.
- Build artifacts (Docker images, packages) on changes that touch deployable code.
- A staging deploy on every merge to main, if the project has a staging environment.

**Example prompt for adding a CI check.**

```
Add a CI step that <describe check>. The check should run on
every pull request and every push to main. It should fail the
build if <failure condition>. Update the existing CI config at
<path> and verify the syntax is correct without running.
```

**Example prompt for debugging a CI failure.**

```
The CI build at <build url> is failing. Read the logs, identify
the failing step, propose the root cause, and write the fix.
If the failure is in a test, do not modify the test to pass
unless the test is genuinely wrong; fix the code under test.
```

**Flows to.** Phase 7 once CI is green.

## Phase 7. Deployment

**Why.** Code in main is not yet code in production. Deployment is the act of moving the artifact from CI through staging into production with the discipline to roll back if it goes wrong. A deploy without a rollback story is a hope, not a deploy.

**Artifact.** Code running in staging, then production, with a documented rollback path.

**Deployment discipline.**

- **Staging before production, always.** Even hotfixes go through staging unless the staging environment is itself broken.
- **Smoke tests after every deploy.** A handful of critical paths that the deploy pipeline runs automatically. If they fail, rollback is automatic.
- **Feature flags for risky changes.** Ship the code dark, turn the flag on per tenant, expand the flag, then remove the flag once the feature is stable.
- **Database migrations are their own deploy.** Forward-compatible (old code can read the new schema) before code, then backward-compatible (new code can read the old schema) cleanup after.
- **Rollback is one command.** Practice it. A rollback you have never run is not a rollback.

**Example prompt for prepping a deploy.**

```
The change in <commit-range> is ready to deploy. Walk through
the deploy checklist: tests green, docs updated, migrations
prepared (forward-compatible), feature flag defaults set
correctly, rollback path documented. Report any item that is
not yet satisfied.
```

**Example prompt for handling a deploy issue.**

```
The deploy of <commit SHA> failed smoke tests in <stage>. Roll
back to <previous commit>, verify smoke tests pass on the
rollback, then investigate the root cause of the failure
without re-deploying. Report the cause and the proposed fix.
```

**Flows to.** Phase 8 once the deploy is live.

## Phase 8. Monitoring and incident response

**Why.** Code in production behaves differently than code in staging. Monitoring is how you find out. Incident response is how you contain it when something goes wrong. A platform without monitoring is shipping blind. A platform with monitoring but without an on-call rotation is shipping blind at night and on weekends.

**Artifact.** Dashboards for the key signals, alert routing to the on-call person, an incident response playbook, and a postmortem cadence.

**What to monitor.**

- **Availability.** Is the service responding? At what error rate?
- **Latency.** P50, P95, P99 response times on the critical paths.
- **Throughput.** Requests per second, jobs per minute.
- **Resource use.** CPU, memory, disk, network for each host.
- **Business signals.** Sign-ups, deals processed, payments cleared. These catch the "everything looks fine technically but no one is using it" failure mode.
- **Security signals.** Failed auth attempts, unusual access patterns, sensitive-data access patterns.

**Alert routing.**

- Page only on actionable signals. An alert that is acknowledged and ignored is alert fatigue.
- Define severity tiers. Critical alerts page immediately; warnings go to a queue reviewed at the start of the next business day.
- Every alert links to a runbook. The on-call person should never wake up at 3 AM and have to guess what to do.

**Example prompt for adding an alert.**

```
Add an alert for <signal> with threshold <threshold>. Route to
the <severity> channel. Link the alert to a runbook at
<runbook path>. Verify the alert fires correctly in staging
before enabling in production.
```

**Example prompt for an incident response.**

```
Incident <id> is active. Symptom: <symptom>. Walk through the
incident response playbook. Identify the affected component
from the diagram in docs/ARCHITECTURE.md, propose the
containment action (roll back, disable a feature flag,
scale up, etc.), and document the timeline in the incident
record as you go.
```

**Example prompt for a postmortem.**

```
Incident <id> is resolved. Draft a postmortem covering the
timeline, the root cause, the contributing factors, what went
well in the response, what could go better, and the action
items with owners. Save it to docs/postmortems/. Use blameless
language; the goal is system improvement, not blame
assignment.
```

**Flows to.** Phase 9 when production reality teaches something that changes the planning docs.

## Phase 9. Iteration loop

**Why.** No first version of any doc is the final version. Customer feedback, market shifts, regulatory news, design-partner conversations, and production incidents all produce updates that ripple through the artifacts back in `DESIGN-METHODOLOGY.md`. The iteration phase is where you keep the planning docs honest with what the build phase actually learned.

**Artifact.** Updates to any of the `DESIGN-METHODOLOGY.md` docs, or a new dated spec for a substantial direction change.

**Example prompt for a small ripple update.**

```
The bug at <issue> revealed that REQUIREMENTS.md FR-<id> is
ambiguous. Propose the smallest edit to FR-<id> that removes
the ambiguity, plus any downstream edits to USE_CASES.md,
DESIGN.md, or ARCHITECTURE.md that the FR change implies.
Apply the edits, then commit.
```

**Example prompt for a substantive direction change.**

```
The customer conversation surfaced <new constraint or new
opportunity>. Walk through every doc that references the
affected area (USE_CASES, REQUIREMENTS, DESIGN, ARCHITECTURE,
BRAND_STRATEGY, BUSINESS_PLAN, GO_TO_MARKET) and propose
updates. Save the proposal as a dated spec in docs/specs/
before editing the production docs. Major direction changes
loop back to Phase 2 of DESIGN-METHODOLOGY.md (a new spec).
```

**Flows to.** Whichever phase the update touches. Small ripples stay in BUILD. Substantive direction changes loop back to `DESIGN-METHODOLOGY.md` Phase 2 (a new spec) and re-enter the playbook flow from there.

## When the product builds its own AI agent features

Some products this playbook bootstraps call the Claude API directly and hand the model tools to use. Once a product wires up more than a handful of tools, two problems surface. Tool definitions eat the context window before any work starts. And the model picks the wrong tool more often as the list grows past thirty or so.

The tool search tool solves both. The tool search tool is a Claude API capability: instead of loading every tool definition up front, you mark the rarely used ones with `defer_loading: true` and add a search tool to the request. The model starts with only the search tool plus your three to five most-used tools. When it needs something else, it searches the catalog by name or description, and the API loads only the matches. Context stays small, tool selection stays accurate, and the approach scales to thousands of tools.

**Reach for it when** the product exposes ten or more tools, tool definitions cross ten thousand tokens, or the product connects multiple servers over the Model Context Protocol (MCP). Below ten tools, plain tool calling is simpler and fine.

**Practices that make it work.**

- Keep the three to five most-used tools loaded. Defer the rest with `defer_loading: true`.
- Never defer the search tool itself. At least one tool must stay loaded, or the request errors.
- Namespace tool names by service (`github_`, `slack_`) so one search surfaces the right group.
- Write descriptions with the words a user would use for the task. The search reads tool names, descriptions, argument names, and argument descriptions.
- Prime the search with a system-prompt line naming the tool categories available ("you can search for tools to work with GitHub, Slack, and Sentry"), so the model knows what is discoverable.

**What the setup looks like.** Add the search tool to the request, keep your most-used tools loaded, and mark the rest `defer_loading: true`. In TypeScript (`@anthropic-ai/sdk`):

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

const response = await client.messages.create({
  model: "claude-opus-4-8",
  max_tokens: 2048,
  messages: [{ role: "user", content: "Open a GitHub issue for the failing deploy." }],
  tools: [
    // The search tool itself stays loaded. Never give it defer_loading.
    { type: "tool_search_tool_regex_20251119", name: "tool_search_tool_regex" },

    // Your 3-5 most-used tools stay loaded normally.
    {
      name: "github_create_issue",
      description: "Open a GitHub issue in a repo",
      input_schema: { type: "object", properties: { repo: { type: "string" }, title: { type: "string" } }, required: ["repo", "title"] },
    },

    // Everything else is defined here but kept out of context until the model discovers it.
    {
      name: "slack_post_message",
      description: "Post a message to a Slack channel",
      input_schema: { type: "object", properties: { channel: { type: "string" }, text: { type: "string" } }, required: ["channel", "text"] },
      defer_loading: true,
    },
    {
      name: "sentry_list_issues",
      description: "List unresolved issues for a Sentry project",
      input_schema: { type: "object", properties: { project: { type: "string" } }, required: ["project"] },
      defer_loading: true,
    },
  ],
});
```

**What happens at runtime.** The model discovers the deferred tools itself, in three steps, with no extra code from you:

1. It emits a `server_tool_use` block calling the search tool with a query (a Python regex such as `slack` for the regex variant, or natural language for BM25).
2. The API returns a `tool_search_tool_result` holding 3 to 5 `tool_reference` blocks and auto-expands them into full tool definitions. You do not handle the expansion.
3. The model calls the discovered tool with a normal `tool_use` block. Discovered tools stay available for the rest of the conversation, so it does not re-search.

Two search variants ship: `tool_search_tool_regex_20251119` (the model writes Python regex patterns, 200-character cap) and `tool_search_tool_bm25_20251119` (natural-language queries). Both search tool names, descriptions, argument names, and argument descriptions. Limits: up to 10,000 tools in the catalog, 3 to 5 returned per search, supported on Opus 4.0+, Sonnet 4.0+, Haiku 4.5+, and Fable 5. For tools coming from MCP servers, defer them via `mcp_toolset` in the MCP connector. The full API reference and the MCP connector setup are in the tool search section of `../tools/SKILLS-INVENTORY.md`.

**For an autonomous loop, use the Claude Agent SDK.** The example above is a single API call. When the product needs an agent that keeps working on its own — calling tools, reading the results, deciding the next step, and repeating until the task is done — reach for the Claude Agent SDK (`@anthropic-ai/claude-agent-sdk`). It embeds the same agent loop that powers Claude Code in your product, and you do not need the Claude Code CLI installed to use it. The loop is: receive the prompt, evaluate, execute the tools the model asked for, feed the results back, and repeat until the model responds with no tool calls.

The SDK ships the two built-in tools that answer "the agent finds what it needs as it goes":

- **`ToolSearch`** dynamically discovers and loads tools on demand instead of preloading all of them. MCP server tool schemas are deferred by default and surfaced through this tool, so adding more servers does not bloat every request.
- **`Agent`** spawns a subagent for an isolated subtask. The subagent starts with a fresh context and returns only its final result to the parent, which keeps the main agent's context lean.

Production guardrails the playbook expects on any SDK agent:

- Cap the loop with `maxTurns` (tool-use round trips) and `maxBudgetUsd` (hard spend ceiling). Without limits an open-ended prompt can run long.
- Choose a `permissionMode`: `"default"` with an approval callback for interactive apps, `"acceptEdits"` for an autonomous agent on a dev machine, and `"bypassPermissions"` only in isolated CI or containers.
- Scope each subagent's `tools` to the minimum it needs, and prefer subagents for large subtasks so the parent context stays small.

A minimal autonomous agent in TypeScript:

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({
  prompt: "Find and fix the failing tests in the auth module.",
  options: {
    // ToolSearch discovers tools on demand; Agent spawns subagents for subtasks.
    allowedTools: ["Read", "Edit", "Bash", "Glob", "Grep", "ToolSearch", "Agent"],
    settingSources: ["project"], // load CLAUDE.md, skills, and hooks from the project
    permissionMode: "acceptEdits", // autonomous on a dev machine
    maxTurns: 30, // stop runaway loops
    maxBudgetUsd: 5, // hard spend cap
  },
})) {
  if (message.type === "result") {
    console.log(message.subtype === "success" ? message.result : `Stopped: ${message.subtype}`);
  }
}
```

For the loop lifecycle, message types, permission modes, hooks, and subagent configuration, see the Claude Agent SDK row in `../tools/SKILLS-INVENTORY.md`.

## Common build pitfalls and how to avoid them

- **Tests that pass but do not verify.** Easy to write, worse than no tests because they produce false confidence. Read the test and ask "what would the test catch if the code were silently broken?" If the answer is "nothing," delete the test or rewrite it.
- **Bug tracker as a graveyard.** Bugs filed and never triaged become noise that nobody reads. Triage on a fixed cadence (weekly is a good default). Close anything that is not actually a bug or that the team will never fix.
- **CI that catches nothing meaningful.** If CI has never blocked a merge, something is wrong with the CI not with the codebase. Add a check that would have caught a recent regression. Repeat until CI starts blocking real issues.
- **Deploy without rollback.** A deploy you cannot roll back in one command is a hope, not a deploy. Make rollback a first-class operation in the deploy pipeline, and practice it on a quiet day so it works on a loud day.
- **Monitoring without alert routing.** Dashboards no one looks at are wallpaper. Route the signals that matter to the people who can act on them, and prune the dashboards that do not surface action.
- **Postmortem without action items.** A postmortem that documents the incident but produces no system change is theater. Every postmortem ends with action items, owners, and dates.
- **Iteration without spec discipline.** Customer feedback applied directly to code (skipping the spec and the planning docs) drifts the project away from its own design. Capture substantive changes as a new dated spec first, then implement.

## Where to find the references

This doc points at `DESIGN-METHODOLOGY.md` for the planning artifacts that BUILD reads from, `TEAM-PERSONAS.md` for the team-of-voices concept the prompts above invoke, and `../tools/SKILLS-INVENTORY.md` for the specific Claude Code skills referenced in the example prompts. If any of those is missing on your machine, start with `../tools/SKILLS-INVENTORY.md` and walk forward.
