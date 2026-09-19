# Context Economy

## About this file

A companion rule doc, like `MEMORY-HYGIENE.md` and `LOOP-ENGINEERING.md`, alongside the six numbered rule docs. It covers how the team spends its context window: which model does which work, what loads into every session before you type, how to brief an agent so the first answer is close, and when to end a session instead of stretching it.

The context window is the working memory of one session. Everything the model can see at once lives there: instructions, tool listings, files it has read, and the whole conversation so far. It is finite, and it is what you pay for.

Every agent inherits this discipline the same way it inherits the security baseline. The human running the session is the primary reader, because most of the levers here are the human's to pull.

Every mechanical claim in this file was checked against Anthropic's documentation on 2026-09-18, with Claude Code v2.1.277 installed. The sources are listed at the bottom. Claude Code changes often. When a command here stops matching what you see, trust the linked page and fix this file.

## Why this is load-bearing

Claude Code sends the full conversation with every request. Each tool call is another request carrying everything before it. Prompt caching makes the repeated part cheap, but not free, and a long session costs more per turn than a short one for the same question.

Cost is half of it. The other half is quality. Anthropic's own guidance says it plainly: "Long sessions with irrelevant context can reduce performance." A session stuffed with three unrelated tasks gives worse answers on the fourth, and nothing errors. It is the same silent decay `MEMORY-HYGIENE.md` describes for memory files, one layer up.

This playbook raises the stakes. It installs seventeen agents, several plugins, and up to four skill packs, and it encourages parallel dispatch. Used carelessly, that is an expensive way to get mediocre output. Used with the six rules below, it is the opposite.

## Rule 1. The capable model directs, a cheaper model reads

A subagent is a separate Claude session that a main session starts for one job. It has its own context window. It does the reading, and only its summary comes back. That keeps the main session small, which is the point. The catch is the bill: a subagent that runs on your most expensive model costs the same per token as the main session, and a parallel dispatch starts several at once.

Claude Code picks a subagent's model in this order:

1. A `model` named for that one invocation.
2. The `model` line in the agent's definition file.
3. The `CLAUDE_CODE_SUBAGENT_MODEL` environment variable.
4. The main session's model.

**The seventeen agents are already covered by step 2.** Each one pins `sonnet` or `opus` in its frontmatter, so invoking the developer from a session running the top model does not run the developer on the top model. `verify-install.sh` checks that every installed agent still has that line.

**The gap is everything else.** The built-in `general-purpose`, `Explore`, and `Plan` subagents have no pinned model, so they fall through to step 4 and inherit whatever the main session runs. A request like "research these three modules in parallel using separate subagents" is three sessions on your most expensive model, mostly reading files. Close the gap one of two ways.

Name the model in the request:

```
Research the authentication module, the database layer, and the API
surface in parallel using separate subagents running on sonnet. Each
returns a one-page summary with file paths. Then synthesize.
```

Or set a default once, in your shell profile or in the `env` block of `.claude/settings.json`:

```bash
export CLAUDE_CODE_SUBAGENT_MODEL=sonnet
```

The variable sits at step 3, below the agent file. It sets the model for unpinned subagents and leaves the `opus` agents (architect, legal, compliance, security-auditor) alone. For simple lookup work, Anthropic's cost guide suggests `haiku`.

Reading, searching, summarizing, and running tests are work a mid-tier model does well. Judgment about what the summaries mean is what you keep the capable model for. If a cheaper subagent returns thin results on a hard question, rerun that one on a stronger model. Do not raise the default for all of them.

**Subagents are not free even when cheap.** Each one starts cold: its first request cannot read the main session's cache, and its cache lives five minutes by default. Dispatch a subagent when the work would otherwise flood the main session with material it does not need to keep, such as logs, test output, or a directory of documents. For a lookup in one file you can name, the main session reading it directly is cheaper. Law 7 in `LOOP-ENGINEERING.md` applies here too: the right number of parallel agents is usually a low single digit.

**What an agent owes the session that called it.** An agent's final message lands in the caller's context. Return conclusions, decisions, and file paths. Do not paste back the raw material you read. Put long output in a file and return the path.

## Rule 2. Keep the baseline small

A new session is not empty. Before your first prompt it already holds the system prompt, the tool listings, `CLAUDE.md`, memory files, and one description for every installed skill. You pay for that baseline on every turn of every session. Run `/context` to see yours, and `/context all` for the full breakdown.

Four things set the size of the baseline, in rough order of how much the playbook affects them.

**Skills.** A skill's body loads only when it is invoked, but its description loads into every session so Claude knows the skill exists. Each description can run up to 1,536 characters. The skill packs install whole repositories, and some repositories ship many skills: on one machine with all four packs installed, I counted 65 skills and about 26KB of descriptions, including skills written for one company's internal workflow. So:

- Install the packs the project needs, not `all`. The wizard already picks a pack from your materials.
- Turn off what you do not use without deleting it. In `.claude/settings.json` for one project, or `~/.claude/settings.json` for every project:

  ```json
  {
    "skillOverrides": {
      "sred-work-summary": "off",
      "blog-writing-guide": "off",
      "sast-graphql": "name-only"
    }
  }
  ```

  `"off"` hides the skill from Claude and from the `/` menu. `"name-only"` keeps the name visible and drops the description. `"user-invocable-only"` hides it from Claude but leaves `/name` working for you.
- Remove for good with `npx skills remove <name>`, then delete its row from `../tools/SKILLS-INVENTORY.md`.

**MCP servers.** MCP is the protocol Claude Code uses to connect outside tools. Their full tool definitions are deferred by default through tool search, so only names and server instructions load up front (see "Tool search" in `../tools/SKILLS-INVENTORY.md`). That makes MCP cheaper than it used to be, not free. Run `/mcp` and disable servers you are not using; the toggle keeps the configuration. Where a command line tool exists (`gh`, `aws`, `gcloud`), prefer it. A CLI adds no listing at all.

**CLAUDE.md.** It loads in full at session start. Anthropic's guidance is to keep it under 200 lines and move workflow detail into skills, which load on demand. `verify-install.sh` warns past 200 lines. The playbook's own pattern already fits: `CLAUDE.md` holds pointers, and the persona files and rule docs hold the detail.

**Agent memory.** Each agent's `MEMORY.md` injects into that agent's context. The budget and the pruning rules are in `MEMORY-HYGIENE.md`.

## Rule 3. Brief the whole task up front

Iterating toward a good answer is the expensive path. Every correction resends the conversation, and each wrong turn leaves its residue in context for the rest of the session. A complete first brief usually gets most of the way in one pass, which leaves one or two small corrections instead of ten.

A brief has four parts. Write them as prose, not as a form.

- **The job.** The whole task and its goal, not the first step of it.
- **The why.** What the output is for and who reads it. Anthropic's prompting guide is explicit that explaining the motivation behind an instruction produces more targeted work.
- **The guardrails.** What could go wrong, stated as limits: files not to touch, decisions that belong to another persona, sources to trust, which model subagents run on.
- **Done.** What finished looks like. Capable models tend to do too much, not too little: extra files, extra abstraction, scope nobody asked for. A stated done condition is the brake. A test that passes, a named file with named sections, an example of the output.

An example, to the developer agent:

```
Using the developer agent, add rate limiting to the public API.

Why: we open the beta to 200 users next week and the enrichment endpoint
calls a paid upstream service. One runaway client must not run up the bill.

Guardrails: limits live in middleware, not in handlers. Do not touch the
auth module; the architect owns that decision. Read docs/ARCHITECTURE.md
for the request path rather than exploring the tree.

Done: the limiter is covered by tests that pass, the limit is one config
value, and docs/ARCHITECTURE.md has a short section describing it. Stop
there. Dashboards and alerting are a separate task.
```

When the task is not clear enough to brief, do not start it and hope. The core already ships the tools for getting clear: `superpowers:brainstorming` interviews you and produces a spec, and `superpowers:writing-plans` turns a spec into tasks. Plan mode (`Shift+Tab`) makes Claude propose an approach before it edits anything, which is cheaper than undoing a wrong one.

Name files when you know them. "Add validation to the login function in `auth.ts`" reads one file. "Improve the auth code" scans the tree.

## Rule 4. One task per session, and hand off through disk

Use one session for one task. A session that did a schema migration this morning carries that whole history into this afternoon's copy edit, paying for it on every turn and reasoning through it on every answer.

- **Switching to unrelated work: `/clear`.** It costs nothing. Run `/rename` first if you may want to `/resume` the old session.
- **Same task, session grown long: hand off, then `/clear`.** See below.
- **Same task, want continuity in place: `/compact`.** It replaces the history with a summary. It is itself a large request, because it reads what it summarizes, so run it at a natural break while the session is active, not mid-task and not after a long pause. `/compact keep the failing test output and the schema decisions` tells it what to preserve.
- **Went down a wrong path: `/rewind`.** It truncates back to an earlier turn, which is already cached. Cheaper than compacting, and the dead end leaves the context entirely.

There is no documented token count at which a session turns bad, so I do not give one. Watch `/context` for how full the window is and `/usage` for what the session has cost. Treat a sense that answers are getting vaguer or forgetting earlier decisions as the signal.

**The handoff.** This playbook's memory layers are the handoff medium, and that is by design. Anthropic's prompting guide notes that current models are "extremely effective at discovering state from the local filesystem" and that a fresh context can beat compaction. So write the state down, then start clean:

```
Before I clear this session: update your MEMORY.md with where this task
stands, write any decision other agents need to
.project/playbook/knowledge/<topic>.md, and give me a handoff brief I can
paste into a new session. The brief covers the goal, what is done, what is
left, the files that matter, and what we ruled out and why.
```

Then `/clear`, and paste the brief. The "ruled out" part matters most. It is what a summary drops first and what stops the next session from repeating a dead end.

## Rule 5. Pick the model and effort at the top of the session

Prompt caching is why a long session is affordable at all. The API stores the unchanged start of each request, so a repeat read is billed at a small fraction of the normal input price. The match is exact and runs from the start of the request: change something early, and everything after it is reprocessed at full price, once.

Effort level is how much the model reasons before it answers: `low`, `medium`, `high`, `xhigh`, `max`, set with `/effort` or in `/model`. Lower effort means fewer thinking tokens, and thinking tokens bill as output. With a good brief, `medium` handles most work. Drop to `low` for small corrections to something that is already close.

Two changes look free and are not.

| Change mid-session | Effect on the cache |
|---|---|
| Switch model with `/model` | Full reread. Each model has its own cache. |
| Change effort | Full reread on most models. The exception: Fable 5.1 on Claude Code v2.1.260 or later, signed in with an API key or a Claude subscription, keeps the cache. Not on Bedrock, Google Cloud, or a gateway. |
| Turn on fast mode | Full reread, once per conversation. |
| The `opusplan` model setting | Every plan mode toggle is a model switch. |
| Enable or disable a plugin's skills or agents | Cache kept. The change is appended. |
| Connect or disconnect an MCP server | Cache kept while its tools are deferred, which is the default. |
| Edit `CLAUDE.md` | Cache kept, because the edit does not apply until `/clear`, `/compact`, or restart. |
| `/compact` | Rebuilds the conversation layer by design. |

Claude Code asks you to confirm a model or effort change while the cache is warm. That prompt is the cost warning. Read it as one.

In practice: choose the model and effort when the session starts. If the tail of a task needs a cheaper model, that is usually a reason to hand off and start a new session (Rule 4), not to switch in place. `/usage` shows a `Prompt cache (main)` line with the share of input served from cache and the likely cause of the last miss. When a session feels expensive, look there first.

Do not let a session sit idle and then resume it for a one-line question. On an API key the cache lives five minutes by default; on a subscription, one hour for the main conversation. After that, the next message reprocesses everything.

## Rule 6. Write prompts plainly

Habits that helped older models now cost tokens.

- **Skip the capital letters.** Anthropic's guide says current models are more responsive to the system prompt, and that "CRITICAL: You MUST" style language now causes overtriggering. It recommends plain phrasing: "Use this tool when..." Say the thing once, in a normal voice, with the reason.
- **Prefer a goal to a script.** The guide's words: "Prefer general instructions over prescriptive steps," because the model's own plan is often better than one written by hand. A numbered procedure belongs where order is a requirement, such as the bootstrap wizard's gates. It does not belong in a request to fix a bug.
- **Match self-check instructions to the model.** Asking Claude to verify its answer against test criteria is still recommended in general. Opus 5 is the documented exception: it verifies without being told, and a carried-over "double check your work" causes over-verification, adding tokens and latency. If you copy an old prompt forward, reread it for this.

The playbook's shipped prompts and agent definitions already follow these. Hold the same line in the prompts you add to your project's `CLAUDE.md` and persona files.

## What this doc leaves out, on purpose

Advice on this topic travels fast and is often half right. I checked the following and did not adopt them.

- **A fixed token threshold for starting a new session.** Numbers circulate. None are in Anthropic's documentation, and the right point depends on the task.
- **Percentage claims for prompt cleanup** (a given percent fewer tokens, a given percent more accuracy). The direction is documented. I could not find the figures in any Anthropic source, so they are not here.
- **Dollar comparisons for one specific task.** Savings from Rule 1 depend on how much of a task is delegated reading. Measure your own with `/usage`.
- **Third party meta connectors that front many MCP servers.** Tool search already defers MCP definitions natively, and a broker adds another party that handles your credentials. That is a `SECURITY-POSTURE.md` question before it is a cost question.
- **"Never ask for verification."** See Rule 6. It is model specific.

## Codex

The mechanics in this file are Claude Code's. The principles carry to Codex unchanged: a cheaper model for delegated reading, a small baseline, a complete brief, one task per session, and no model switching mid-task. The commands, settings keys, and cache behavior do not carry, and I have not verified Codex equivalents. Check Codex's own documentation before relying on any command named here.

## The mechanical check

`bash .project/playbook/scripts/verify-install.sh` runs a context baseline check (Check 7). It warns when `CLAUDE.md` passes 200 lines and when an installed agent has lost its `model` line, and it reports how many skills load into each session and roughly how much description text they carry. It reports the skill count without judging it, because no documented limit exists. The number is there so you see it.

## Sources

- Manage costs effectively: https://code.claude.com/docs/en/costs
- How Claude Code uses prompt caching: https://code.claude.com/docs/en/prompt-caching
- Subagents, including the model resolution order: https://code.claude.com/docs/en/sub-agents
- Skills, including `skillOverrides`: https://code.claude.com/docs/en/skills
- MCP and tool search: https://code.claude.com/docs/en/mcp
- Prompting best practices: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices

## See also

- `MEMORY-HYGIENE.md` for the memory file budget, which is the same problem at the memory layer.
- `LOOP-ENGINEERING.md` for token and dollar ceilings on unattended work.
- `../tools/SKILLS-INVENTORY.md` for the tool search section and the command cheat sheet.
- `../agents/README.md` for which model each agent runs on and why.
