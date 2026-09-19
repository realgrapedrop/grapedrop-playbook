# Bug Tracking

## About this file

The playbook's load-bearing reference for bug tracking with GitHub Issues. Defines the repository setup, the label and Issue Type taxonomy, the lifecycle, the triage cadence, and the discipline for prioritizing bugs by severity and priority. Read this whenever you (or any persona-backed agent) are filing, triaging, fixing, verifying, closing, or prioritizing a bug. The Developer persona is the primary reader; the Compliance, Customer Success, Support, and Architect personas also read sections relevant to their lane.

This file is GitHub-specific because GitHub Issues is the recommended bug tracker for projects built on this playbook (cost, code-co-location, ecosystem). For a discussion of when to migrate to a dedicated bug tracker like Linear, see the per-project knowledge entry on bug-tracking tool choice.

Fifth of six rule docs in the playbook (`TEAM-PERSONAS.md`, `DESIGN-METHODOLOGY.md`, `DEVELOPMENT-BUILD.md`, `BUSINESS-OPERATIONS.md`, `BUG-TRACKING.md` this file, `PRE-DEVELOPMENT-BLUEPRINT.md`). The shorter Phase 5 Bug tracking summary in `DEVELOPMENT-BUILD.md` is preserved as a quick reference for the build flow; this file is the deeper reference the agents read when actually doing the work.

## Why bugs need a system

Bugs without a system get dropped between a Slack thread and someone's memory. They get rediscovered weeks later, costing time twice. They block releases when the count grows unmanaged. They erode customer trust when fixed silently and credit is never claimed. They erode the team's trust when the same fix gets done two different ways by two different people.

A real bug-tracking system gives you four things at once.

1. **A durable record** that survives sessions, team members, and releases.
2. **A triage surface** where you decide which bugs ship in the next release and which wait.
3. **A prioritization surface** where you decide what gets done in what order.
4. **An audit surface** where compliance reviewers and future-team-members can see what was caught, when, why, and how.

For projects built on this playbook, that system is GitHub Issues plus a Project v2 board.

## Repository setup

Five files in `.github/` carry most of the discipline. None of them are optional for a serious project.

### `.github/ISSUE_TEMPLATE/bug.yml` (Issue Form, YAML)

The modern recommended pattern is YAML Issue Forms, not markdown templates. Forms give you required fields, dropdowns, validation, auto-labeling, and a more structured payload that AI agents (including GitHub's Copilot coding agent, which has been GA since September 2025) can read reliably.

Minimum fields a bug form should have:

| Field | Type | Required | Why |
|---|---|---|---|
| Title | input | yes | One sentence in plain language describing what is wrong |
| Summary | textarea | yes | One paragraph context for the reader |
| Steps to reproduce | textarea | yes | Numbered list a fresh reader can follow |
| Expected behavior | textarea | yes | What should have happened |
| Actual behavior | textarea | yes | What did happen, with error messages or screenshots |
| Environment | textarea | yes | Browser, OS, version, role, tenant, chain (mainnet vs testnet), build SHA |
| Severity | dropdown | yes | P0 / P1 / P2 / P3 (see the prioritization section) |
| First seen | input | no | Commit SHA, release tag, or "first noticed by customer X on date Y" |
| Related artifacts | textarea | no | Spec, requirement, ADR, or test that should have caught this |

Each form maps required fields to auto-applied labels (e.g., severity dropdown auto-applies `severity:p0` through `severity:p3`).

### `.github/ISSUE_TEMPLATE/config.yml`

Disables blank issues so every issue uses a template. Adds contact links for security disclosures, support requests, and feature ideas so those flows do not pollute the bug queue.

### `.github/PULL_REQUEST_TEMPLATE.md`

The PR template requires every PR to link a GitHub Issue. The auto-close keywords (`Fixes #123`, `Closes #123`, `Resolves #123`) live in the template so authors do not forget. PRs that touch regulated-surface code (money, on-chain writes, signing, authentication, regulated data) reference the relevant requirement ID and trigger the project's release-gate policy if the project defines one.

### `.github/CODEOWNERS`

Routes pull request review by directory. CODEOWNERS triggers on **pull requests, not issues**; it does not assign or notify on issues. Use issue assignment for issue routing. CODEOWNERS belongs in the repo because it makes the review pipeline deterministic, not because it touches the issue surface.

### `.github/labels.yml` or equivalent (label seed)

Labels are seeded from a single source of truth in the repo so the taxonomy stays consistent. Manual label drift (people creating ad-hoc labels in the UI) erodes the taxonomy within weeks; seeding from a file prevents it.

## Issue Types, Labels, and Severity

GitHub now distinguishes three concepts that older repositories often confused.

| Concept | Purpose | Example | Storage |
|---|---|---|---|
| Issue Type | What kind of work this is | bug, task, feature, epic | Org-level Issue Types (GA, replaces the older convention of using `type:bug` labels) |
| Label | Tags for taxonomy and filtering | `severity:p0`, `area:commodities`, `status:needs-info`, `provenance:sentry` | Repo-level labels |
| Project v2 field | Workstream state for prioritization and planning | Single-select Status, single-select Priority, iteration field for sprint | Org-level Project v2 board |

**The modern convention**: type via Issue Type, severity and priority via Project v2 single-select fields (with mirror labels for repo-level filtering when needed), and area/component via labels. This replaces the older practice of stuffing everything into labels.

### Severity vs Priority

These are different concepts and get conflated constantly. The doc that fixes this is short and worth memorizing.

- **Severity** is the technical impact: how bad is the failure when it happens. Independent of how many users hit it or how soon you need to fix it.
- **Priority** is the business urgency: when does this need to be fixed, given everything else on the team's plate.

A bug can be high severity and low priority (rare crash on a feature nobody uses yet). Or low severity and high priority (cosmetic bug on a landing page during a launch week). The agent that triages must assign both.

The playbook recommends a four-tier scale for each.

### Severity ladder

| Tier | Meaning | Examples |
|---|---|---|
| **P0** | Critical. Production is broken or unsafe. Money, on-chain state, or regulated data is at risk. Immediate response. | Wire goes to wrong account. Signing service signs against a missing prerequisite. Customer cannot complete payment. Token mints with wrong metadata. Data exposure. |
| **P1** | High. Major feature broken or seriously degraded. Workaround painful or non-existent. Fix targeted within the current sprint. | Login fails for one role. Mint flow times out half the time. Export produces wrong totals. Sentry alert fires on every page load. |
| **P2** | Medium. Minor feature broken or notably awkward. Workaround exists. Fix targeted in a near-term sprint. | Date picker rejects valid date format. Sort order wrong on a non-critical column. Notification email subject line malformed. |
| **P3** | Low. Cosmetic, edge-case, or nuisance. Fix when convenient or batched. May be wontfix. | Hover tooltip has a typo. Icon misaligned by 1 pixel. Help text uses outdated terminology. |

### Priority ladder

The priority ladder mirrors the severity tiers but answers a different question: "when must this be fixed?"

| Tier | Meaning |
|---|---|
| **P0** | Today. Drop other work. Stop the line. |
| **P1** | This sprint. Inside the current iteration window. |
| **P2** | A near sprint. Inside the next two iterations. |
| **P3** | Backlog. Fix when convenient, batched, or never. |

## How to prioritize bugs

The prioritization decision is the hardest part of bug tracking and the one AI agents most often get wrong. Two heuristics keep agents calibrated.

### Heuristic 1: impact × urgency

Walk the bug through two questions, in this order.

**Impact (severity input).**

- Who is affected? One user, one segment, all users? Internal team, customers, regulators?
- What is the scope of damage if not fixed? Money lost, on-chain state corrupted, regulated data exposed, brand exposure, customer-trust hit?
- Is the failure mode reversible? Off-chain bugs are usually reversible. On-chain bugs (duplicate mint, wrong-account wire) often are not.
- Does the bug touch a load-bearing surface per the project (money, on-chain writes, signing, authentication, authorization)?

**Urgency (priority input).**

- Is there a deadline this bug must be fixed before? A customer demo, a release cut, a regulatory window, a launch?
- Is the bug visible to customers? A public-facing bug on a high-traffic surface costs trust by the hour.
- Is a workaround available? Is the workaround documented and shareable?
- Does the bug block other work on the team?

Plot impact and urgency on a 2x2 mental grid. High-impact + high-urgency = P0 priority. High-impact + low-urgency = P1 or P2 priority (still important, not blocking). Low-impact + high-urgency = P1 or P2 priority (visible but not damaging). Low-impact + low-urgency = P3 priority or wontfix.

### Heuristic 2: the four-question checklist

When an AI agent or any persona is unsure about priority, walk this four-question checklist in order. The first "yes" sets the floor.

1. **Does this affect money, on-chain state, signing, or regulated data?** If yes, floor is P1. If unreproducible loss already occurred, floor is P0.
2. **Is a customer blocked from completing a core task?** If yes, floor is P1. If multiple customers, floor is P0.
3. **Is there a scheduled deadline (launch, demo, release, regulatory window) before which this must be fixed?** If the deadline is inside the current sprint, floor is at least P1. If the deadline is this week, floor is P0.
4. **Does fixing this unblock other team members from shipping their own work?** If yes, floor is at least P2.

If all four are "no," priority is P3 or wontfix.

### Escalation triggers

The Developer persona and the Compliance persona escalate to the CFO when any of these are true.

- **A P0 priority bug stays unresolved for more than 24 hours.** P0 is "drop other work." If 24 hours has passed and the bug is not fixed, the CFO needs to know whether to allocate more people, shift scope, or accept the exposure.
- **A bug touches a regulated surface and requires a release-gate exception.** If the project defines a release-gate policy (typically a project-level knowledge entry that documents who can hold, who can override, and how exceptions are logged), regulated-surface releases are blocking by default and the CFO or equivalent override authority writes the documented exception.
- **The bug exposes a control gap that recurs.** A single bug is a bug. The same kind of bug landing twice in a quarter is a control problem that needs Compliance review.
- **Customer impact is material (revenue at risk, contract at risk, brand exposure).** Customer-facing communication on a material bug routes through whoever owns brand-call authority on the project (typically the CFO or founder).

### When to mark wontfix

Closing a bug as wontfix is a legitimate decision. The discipline is to record why.

- **Already fixed by a future planned change.** Link the planned change and close with that note. Better than leaving the bug open against a soon-to-be-deleted surface.
- **By-design behavior the reporter misunderstood.** Comment with the design rationale, link the spec or ADR, and close. Update the user-facing copy if the misunderstanding is likely to recur.
- **Outside the project's scope.** Bugs in upstream dependencies usually belong upstream; file there and close locally with the link.
- **Not worth the fix cost.** Rare cosmetic bugs on low-traffic surfaces. Document the cost-benefit reasoning so the next reviewer does not relitigate.

Do not close wontfix without writing the reason. A wontfix without rationale is a bug that gets refiled in three months.

## Projects v2 for the board view

The recommended pattern is a single org-level Project v2 board fed by all repos, with auto-add and auto-status workflows enabled. Per-repo boards become hard to manage as the team scales.

**Status field (single-select).** Triage, In Progress, In Review, Blocked, Done. Issues land in Triage automatically via the auto-add workflow. PR open transitions to In Review. PR merge transitions to Done.

**Priority field (single-select).** P0, P1, P2, P3. Set during triage. Mirrors a `priority:p0` through `priority:p3` label for repo-level filter views.

**Iteration field.** Two-week or one-week cycles depending on the team's cadence. The current iteration field is the implicit sprint board.

**Severity field (single-select).** P0, P1, P2, P3. Separate from priority per the distinction documented above. Mirrors a `severity:p0` through `severity:p3` label.

**Built-in automations.** Auto-add new issues to the board. Auto-set status when PR opens, merges, or closes. Auto-archive after 14 days in Done. Projects (classic) is deprecated; use Projects v2 exclusively.

## The bug lifecycle

Every bug walks the same path. Each transition has a named actor.

```
file → triage → prioritize → assign → reproduce → fix → review → verify → close
```

| Step | Actor | What happens |
|---|---|---|
| File | Anyone (customer via support, team member, Sentry, automated check) | Issue created via the Bug Issue Form. Lands in Triage on the Project board. |
| Triage | Developer persona on daily cadence | Read the issue, set Issue Type to Bug, set severity, set area label. Confirm reproducibility steps are present. |
| Prioritize | Developer + the persona owning the affected surface | Set Priority field using the heuristic above. P0 triggers immediate action; P1-P3 enter sprint planning. |
| Assign | Developer persona or persona owner of the area | Pick an assignee. For Copilot-eligible bugs, assignee can be `@copilot` for an async draft-PR run. |
| Reproduce | Assignee | Walk the steps against current main. If reproducible, proceed. If not, mark `needs-info`, ping the reporter, and pause. |
| Fix | Assignee (human or Copilot agent) | Write a failing test, fix the code, verify the test passes. `gh issue develop <num>` creates a branch linked to the issue for auto-close. |
| Review | CODEOWNERS on the PR | Standard PR review per `DEVELOPMENT-BUILD.md` Phase 4. Block on correctness and security. |
| Verify | QA Engineer, reporter, or Developer | Run the functional test that covers the fix (the QA Engineer writes one if none exists), then walk the original repro steps against the fix. Confirm the actual behavior now matches the expected behavior. |
| Close | Whoever verified | PR merge with `Fixes #<num>` auto-closes the issue. Add a verification note in the closing comment. |

**Reopen rules.** An issue closed but observed again gets reopened, not refiled. Reopen with the new evidence appended; do not start a new issue thread for the same bug.

## Triage cadence

Three layers, each at a different rhythm.

**Daily quick triage (15 minutes).** Developer persona walks the new-issues queue. Triage and prioritize each fresh issue. Mark `needs-info` on the ones that lack repro steps. Apply the area label. The goal is to clear the new-issues queue every working day so no issue waits more than 24 hours for an initial read.

**Weekly grooming (45 minutes).** Developer persona plus relevant area owners walk the backlog. Re-evaluate priority on issues that have aged. Close anything that is now stale or no longer relevant. Identify stuck issues (`status:blocked`, no movement in 14 days) and unblock or escalate.

**Monthly bug-debt review (60 minutes).** Developer persona plus CFO (when material) review the severity-weighted backlog metric. If the metric is growing, agree on a remediation plan: stop-the-line week, a dedicated sprint, or a deliberate bug-budget decision per the bug-debt section below.

## Filing a bug well

Modern GitHub bug-tracking practice has shifted because issues now double as agent prompts. If an issue is well-written, the GitHub Copilot coding agent (assigned by adding `@copilot` as assignee or via the agents panel) can spawn a draft-PR run against it. This raises the bar on issue clarity: every required field in the bug form is now also a prompt input.

**Title.** One sentence, plain language, what is wrong. Not a question. Not a summary. "Wire beneficiary attestation fails when the trade ID contains an underscore" beats "Wire bug" or "Why does this fail?"

**Reproduction steps.** Numbered, atomic, fresh-reader-readable. Each step starts with a verb. Include the inputs verbatim. Include the expected timing of any UI feedback ("page should redirect within 2 seconds").

**Environment metadata.** Build SHA matters as much as browser version for a SaaS. Include the chain or network for any on-chain bug (mainnet, testnet, EVM Sidechain, Hooks testnet). Include the role (operator vs holder vs admin) for any auth-related bug.

**Severity assignment.** Apply the four-question checklist. If you genuinely cannot decide, default to P2 and flag in the issue body that the severity needs Developer review.

## Linking commits, PRs, and issues

GitHub closes issues automatically when a merged PR contains an auto-close keyword referencing the issue.

**Auto-close keywords.** `Fixes #123`, `Closes #123`, `Resolves #123`. Case-insensitive. Work in PR body, PR title, and commit messages on the PR branch. Use one of these on every bug-fix PR.

**`gh issue develop <num>`.** Creates a branch on the GitHub side already linked to the issue. Auto-names from the issue title if `--name` is omitted. Use `--checkout` to switch to the new branch locally. The linked-branch association makes auto-close work even if the PR description forgets the keyword.

**Sub-issues for grouped bugs.** When one parent bug spawns several follow-ups (an epic-style bug investigation), use Sub-issues to track them as children of the parent. The parent issue shows a progress bar against the children. Native `gh` CLI support is not yet shipped as of mid-2026 (tracked in `cli/cli#10298`); use `gh api` against the REST sub-issues endpoint or a community `gh` extension (`yahsan2/gh-sub-issue`) when needed.

**Mentions vs links.** Use `#<num>` to link an issue (no notification side effect). Use `@<user>` to notify someone. Mentions in a closed issue do not surface in the recipient's inbox the same way mentions in open issues do; if an issue is closed and you need a person to see the comment, also assign them.

## AI agent workflow patterns

The Developer persona and any agent doing bug work follows these patterns.

### Read context first

Before proposing a fix, the agent reads:

1. The full issue body via `gh issue view <num>`.
2. Any linked issues, PRs, or commits referenced in the body.
3. The relevant files via the project's `docs/ARCHITECTURE.md` map (the architecture doc points at where the affected code lives).
4. Any related ADRs in `docs/adr/` if the bug is structural.
5. The release-gate impact per the project's release-gate policy (if the project defines one in its knowledge folder) when the bug touches a regulated surface.

Skipping the context read produces fixes that introduce regressions or duplicate prior work.

### `gh` CLI vocabulary

The agent uses `gh` for all GitHub operations per the system prompt. The relevant subset for bug work:

| Command | Use |
|---|---|
| `gh issue create --template bug.yml` | File a new bug |
| `gh issue view <num>` | Read the full issue |
| `gh issue list --label severity:p0 --state open` | Triage view |
| `gh issue comment <num> --body "..."` | Add a triage or fix-progress note |
| `gh issue edit <num> --add-label "..."` | Adjust labels |
| `gh issue edit <num> --add-assignee @copilot` | Assign Copilot coding agent to spawn a draft-PR run |
| `gh issue develop <num> --checkout` | Create a linked branch and switch to it locally |
| `gh issue close <num> --comment "Verified fix in <PR>"` | Close after verification |
| `gh issue reopen <num> --comment "Repro still observed on <SHA>"` | Reopen with new evidence |
| `gh api -X PUT /repos/{owner}/{repo}/issues/{issue}/sub_issue --field sub_issue_id=<num>` | Attach a sub-issue (until native `gh` support ships) |

### When the agent creates vs comments vs closes

- **Create** when the bug is new and not represented in any existing open issue. Always check first with `gh issue list --search "<keywords>"`.
- **Comment** when the bug is the same as an existing issue (add evidence) or when adding a triage note, fix progress, or verification result.
- **Close** only after verifying the fix against the original repro steps. The agent does not close on the strength of a passing test alone; it confirms the user-facing actual behavior now matches the expected behavior.

### Example prompts

These are the canonical example prompts. The `DEVELOPMENT-BUILD.md` Phase 5 section preserves shorter versions for quick reference; the fuller versions live here.

**File a new bug.**

```
File a bug for the following symptom: <one-sentence description>.
Use the .github/ISSUE_TEMPLATE/bug.yml form. Fill every required
field. Walk the four-question prioritization checklist in
BUG-TRACKING.md and assign the severity and priority floors that
checklist produces. If unsure, default to P2 and flag the issue
body for Developer review. After filing, paste the new issue
number in the chat.
```

**Triage an open bug.**

```
Triage issue <num>. Read the issue body and any linked references.
Attempt the steps to reproduce against the current main branch.
Report whether the bug reproduces. If it does, identify the
likely affected component from docs/ARCHITECTURE.md, set the area
label, walk the four-question checklist, and propose severity and
priority. If the bug touches a regulated surface, flag the release-
gate impact per the project's release-gate policy.
```

**Fix a triaged bug.**

```
/superpowers:systematic-debugging Issue <num> reproduces.
Investigate the root cause systematically (do not guess). Once
the cause is identified, write a failing test that captures it,
then fix the code, then verify the test passes. Run
'gh issue develop <num> --checkout' to create the linked branch.
Commit with 'Fixes #<num>' in the body so the issue auto-closes
on merge. Update the issue with a comment summarizing the cause,
the fix, and the test reference.
```

**Verify a fix before close.**

```
Issue <num> claims to be fixed by PR <pr-num>. Re-run the
original steps to reproduce against the merged commit on main.
Confirm the actual behavior now matches the expected behavior.
If yes, close the issue with a verification note citing the
commit SHA and the test that now covers the regression. If no,
reopen with what is still wrong.
```

## Integration with error monitoring

Sentry, Bugsnag, Rollbar, and similar tools catch errors in production automatically. They are not bug trackers; they are bug *detectors*. The output of detection becomes input to tracking.

**Sentry to GitHub Issues.** Sentry's native GitHub integration creates an issue when an alert rule fires. Auto-created issues land in Triage on the Project board same as human-filed ones. Tag with `provenance:sentry` so the team can filter.

**Triage of auto-created issues.** Auto-created issues need the same human triage pass: validate the error is reproducible, set severity, set priority, set area. Sentry's grouping is not always right; an alert that fires once is not necessarily a P0 bug.

**Closing the loop.** When a Sentry-originated issue is fixed, link the Sentry issue ID in the close comment so the monitoring side picks up the resolution.

## Customer-reported bugs

Customer reports enter through support (KB tickets, support email, customer success conversations) and need a clean handoff to the engineering bug-tracking surface.

**Tag with `provenance:customer` and `area:<surface>`.** This lets Customer Success and Support filter for status updates without scanning the whole queue.

**Tag with `customer:<name>` if a specific customer is affected.** Useful for renewal-risk conversations: "we found this bug for customer X two weeks ago and shipped the fix on date Y."

**Closing the loop.** When a customer-reported bug is fixed, Customer Success (or whoever owns customer-facing communication when Customer Success is not yet staffed) is responsible for telling the customer. Engineering does not communicate directly with the customer on closure; the closure note in the issue is the source-of-truth for the next customer-facing message.

**Severity floor.** Customer-reported bugs that block a customer from completing a core task are P1 minimum. P0 if the bug also touches money, on-chain state, or regulated data.

## Postmortem discipline

Every P0 bug warrants a written postmortem. P1 bugs warrant one when the bug surfaces a control gap that recurs or when customer impact is material. P2 and P3 do not.

**Blameless template.** What happened, when, how it was detected, how it was contained, root cause, contributing factors, what we learned, what we will change. The template explicitly avoids naming individuals; the system that allowed the bug to ship is the subject.

**Lesson-into-control loop.** Every postmortem produces at least one durable control improvement (a test, a runbook update, a release-gate addition, a monitoring rule). The bug is closed only after the control improvement is in flight, not when the fix ships.

**Where postmortems live.** `docs/postmortems/YYYY-MM-DD-<short-slug>.md`. Indexed in the project's `docs/README.md`.

## Bug debt management

The severity-weighted backlog metric is the early signal. The formula is straightforward.

```
severity-weighted backlog = 8 × (open P0) + 4 × (open P1) + 2 × (open P2) + 1 × (open P3)
```

The number itself is less interesting than the trend. A flat or declining trend is healthy. A growing trend is a signal the team needs to either ship more bug fixes or stop accepting new feature work until the metric flattens.

**Zero-bug policy.** The strictest pattern: no P0 or P1 bug stays open across a sprint boundary. New P0/P1 bugs interrupt feature work. Hard to sustain at growth-stage scale; works well pre-launch.

**Bug budget.** The pragmatic pattern: the team accepts a documented number of open P2 and P3 bugs (the bug budget) and feature work continues until the budget is exceeded, at which point new feature work pauses for a bug-debt sprint. P0 and P1 always interrupt regardless of budget.

**Stop the line.** When the severity-weighted backlog grows past a documented threshold (set per project), the team agrees to a dedicated bug-debt sprint and pauses new feature work. The trigger is a CFO and Developer decision based on the metric trend and the upcoming roadmap pressure.

## Common pitfalls

- **"Will reproduce later" closes.** Closing an issue because the agent could not reproduce on first attempt, without asking the reporter for more environment detail. The right move is `needs-info` plus a comment asking specific questions, not a close.
- **Reopen flooding.** Reopening the same issue every time a similar-looking error fires, when the new error is actually a different root cause. Each genuinely different root cause is a new issue. The way to keep the relationship visible is `Related to #<original>` in the body, not reopen.
- **Severity drift.** Bugs filed at P0 in the heat of the incident, then never re-evaluated when the actual scope turns out to be smaller. Triage the next day; downgrade as warranted.
- **Stale milestones.** Milestones set at file time and never updated when the release date moves. Milestones are mutable; keep them honest or stop using them.
- **Treating Sentry alerts as P0 by default.** Auto-created bugs need human triage. An error that fires once for one user in one session is not a P0.
- **Closing without verification.** Marking an issue as closed because the test passes, without re-running the original repro steps. Tests prove the code path now behaves as intended; verification proves the user-facing failure mode is gone.

## Where to find the references

| Concern | Doc |
|---|---|
| The shorter Phase 5 Bug tracking summary | `DEVELOPMENT-BUILD.md` Phase 5 |
| The release-gate pattern for regulated-surface bug fixes (project-defined) | The project's own knowledge folder, typically `.project/playbook/knowledge/release-gate-authority.md` if the project documents one |
| The Developer persona test discipline | Template at `reference/personas/DEVELOPER-PERSONA.md`; customized project copy at `.project/DEVELOPER-PERSONA.md` if the project has run the wizard |
| The Finance / CFO persona for escalation and brand-call authority | Template at `reference/personas/FINANCE-PERSONA.md`; customized project copy at `.project/FINANCE-PERSONA.md` if the project has run the wizard |
| The skills inventory (the `superpowers` skills cited in the prompts) | `reference/tools/SKILLS-INVENTORY.md` |
| GitHub Issue Forms syntax | https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms |
| Projects v2 built-in automations | https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project/using-the-built-in-automations |
| `gh issue develop` manual | https://cli.github.com/manual/gh_issue_develop |
| Copilot coding agent (assignee `@copilot`) | https://docs.github.com/copilot/concepts/agents/coding-agent/about-coding-agent |
| Sub-issues REST endpoints | https://docs.github.com/en/rest/issues/sub-issues |
