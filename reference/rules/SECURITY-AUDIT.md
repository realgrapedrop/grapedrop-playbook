# Security Audit and Issue Discovery

## About this file

The playbook's reference for running audits and turning what they find into tracked, fixable, verifiable work. It defines the audit roles, the three issue lenses (UI/UX, security, functional bugs), the risk rating, the two-part deliverable (an audit report plus a GitHub tracking report), the issue and mitigation-report templates, and the closure process. The Security Auditor persona is the primary reader; the Developer, Designer, and Compliance personas read the sections relevant to their remediation lane.

This file is a standalone companion to the numbered methodology docs, not part of the numbered series, in the same way `SECURITY-POSTURE.md` sits alongside them. It is deliberately GitHub-specific and leans on `BUG-TRACKING.md` for the mechanics it would otherwise duplicate: the label and Issue Type taxonomy, the severity-vs-priority distinction, the bug lifecycle, the triage cadence, and the `gh` CLI vocabulary. Read `BUG-TRACKING.md` first; this file adds the audit-specific layer on top of it.

The examples use XRPL and validator-operation flavor in places because the playbook's first project is an XRPL product. The structure is domain-neutral; swap the examples for your own surface.

## The two jobs of an audit

An audit produces two things, and conflating them is the most common failure.

1. **The audit report.** The technical record of what is wrong, ranked by impact, written for a reader who needs to understand risk. This is the source of truth.
2. **The tracking artifacts.** Every finding turned into a GitHub issue a developer or designer can action without re-reading the report, linked back to the report by a stable finding ID, and carried through to a verified close.

The first without the second is a PDF nobody acts on. The second without the first loses the why. The auditor delivers both.

## The three lenses

The auditor sweeps a surface through three lenses. Security gets the deepest, most structured treatment; all three file into the same tracker.

| Lens | What it looks for | Owner of the fix |
|---|---|---|
| **Security** | Vulnerabilities: authn/authz gaps, injection, secrets handling, insecure config, dependency CVEs, key handling, infrastructure hardening, and (for on-chain products) signing and consensus-participation risk | Developer, with Compliance on regulated surfaces |
| **UI/UX** | Accessibility failures (WCAG), broken or unreachable states, layout breakage, contrast and focus issues, confusing or incorrect copy | Designer, with Enduser on copy |
| **Functional bug** | Behavior that does not match the spec: wrong results, error states, edge-case failures, regressions | Developer |

A security audit runs the full report process below. A UI or functional sweep can skip the report and file findings directly as bugs per `BUG-TRACKING.md`, using the same severity discipline.

## Multi-agent workflow

A thorough audit fans out, then synthesizes. The lead auditor coordinates specialist sub-agents and a remediation agent.

- **Code reviewer.** Static analysis, dependency auditing, application-layer vulnerabilities.
- **Infrastructure specialist.** OS and server hardening, systemd and service config, firewall, secrets management. (Name the actual OS and runtime in scope, e.g. Ubuntu LTS plus a Node service.)
- **Domain specialist.** The risks specific to the product's domain. For an XRPL product this is validator key handling, `rippled` interaction, and consensus-participation risk. For a payments product it is settlement and reconciliation. Define this per project.
- **Remediation agent.** Translates findings into developer-actionable GitHub issues, acceptance criteria, and the closure process.

The flow:

1. Specialists perform discovery, static analysis, infrastructure review, and domain-specific analysis in parallel.
2. The lead auditor synthesizes all technical findings into the audit report (Deliverable 1).
3. The remediation agent turns the finalized findings into the GitHub tracking report (Deliverable 2).
4. The lead reviews both for consistency and traceability before delivery.

## Risk rating

Audit findings use the same four-tier severity and priority ladders as `BUG-TRACKING.md` (P0 through P3), so a finding and the issue it becomes carry one consistent scale. The older Critical/High/Medium/Low naming maps directly: Critical = P0, High = P1, Medium = P2, Low/Informational = P3. Use the P-scale in issues; the descriptive names are fine in the report prose.

| Tier | Audit meaning |
|---|---|
| **P0 / Critical** | Direct path to compromise: remote code execution, key or secret theft, cross-tenant data exposure, money sent to the wrong place, or material disruption of a load-bearing on-chain surface (for an XRPL validator, consensus participation). |
| **P1 / High** | Serious impact with moderate exploitability, or a major feature broken with no good workaround. |
| **P2 / Medium** | Moderate impact, or requires chaining other conditions, or a minor feature notably degraded. |
| **P3 / Low / Informational** | Best-practice deviation, cosmetic defect, or edge-case nuisance. |

Severity is technical impact; priority is business urgency. Assign both, per the severity-vs-priority section and the four-question checklist in `BUG-TRACKING.md`. Sort the report highest-risk first.

## Deliverable 1: the audit report

The primary output. Focused on risk identification and high-level recommendation, not on issue mechanics.

### Executive summary
- One paragraph on the surface and deployment audited.
- Finding counts by severity.
- Overall posture assessment.
- The top three to five urgent priorities.

### Methodology and scope
What was analyzed, what tools and techniques were used, and the limitations. State explicitly what was not checked. Name the authorized scope and confirm testing stayed inside it.

### Prioritized findings
Each finding uses exactly this structure, sorted highest-risk first.

**[SEVERITY-XXX] Short, descriptive title** (e.g. `[P0-001]`)

**Category.** For example Authentication and Authorization | Secrets Management | Dependency Vulnerability | Secure Configuration | Infrastructure Hardening | Accessibility | Functional Correctness | (domain) Key Management | (domain) On-chain Integration.

**Description.** Two to four sentences on the issue and its exact location (file and line, URL, config key, or screen).

**Risk / impact.** The concrete consequence if exploited or shipped.

**Likelihood / exploitability.** High / Medium / Low with a short justification.

**Recommendation.** Specific remediation steps, plus the better architectural alternative when one exists. Include code or config examples where they help. Reference the relevant standard or domain guidance.

**Evidence.** Screenshot, log excerpt, request/response, or config diff.

**References** (optional).

### Positive observations
The security strengths that already exist. An audit that only lists failures is not trusted.

### Remediation roadmap
Immediate / short-term / medium-term actions, plus suggested CI/CD security tooling (dependency scanning, secret scanning, SAST) to keep the surface clean going forward.

## Deliverable 2: the GitHub tracking report

Written for the developer or designer who will fix the issue. Self-contained and directly usable to populate GitHub. It builds on `BUG-TRACKING.md`; it does not restate the label taxonomy, the lifecycle, or the `gh` commands defined there.

### Tracking strategy
- Total issues to create and the recommended setup: a parent tracking issue (or a Project v2 view filtered to the audit) that links every child finding. Title it for the audit, e.g. `Security Audit Remediation for <surface> (<month year>)`.
- Audit-specific labels layered on the `BUG-TRACKING.md` taxonomy: `provenance:audit`, `security/<tier>` where useful, `fix-verified`, `needs-security-review`. Severity and priority use the existing `severity:p*` / `priority:p*` fields and mirror labels.
- The create / update / close workflow references the bug lifecycle in `BUG-TRACKING.md`; the audit-specific additions are the mitigation report and the security-reviewer sign-off below.

### GitHub issue template for findings
Each finding becomes an issue with these sections:

- **Finding ID** (e.g. `P0-001`) and **original audit reference**.
- **Description and risk** (carried from the report).
- **Detailed remediation steps** (expanded into developer-actionable form).
- **Files / components affected**.
- **Suggested implementation approach** (code, config, or architectural alternative).
- **Testing and verification steps**.
- **Acceptance criteria / definition of done** (a testable checklist).
- **Mitigation report** (filled on completion; template below).
- **References / links**.

### Prioritized issues to create
For each finding (or a logically grouped set of low-severity findings), provide a copy-paste-ready block:

- **Suggested issue title**
- **Labels** (comma-separated, from the `BUG-TRACKING.md` taxonomy plus the audit labels above)
- **Priority / suggested milestone**
- **Full issue body** (pre-written Markdown, incorporating the audit description plus expanded, actionable remediation and the recommended alternative)
- **Acceptance criteria / definition of done** (e.g. "PR merged to main, security review approved, change deployed to staging, no secrets in logs or env, automated tests passing")
- **Estimated effort** (optional T-shirt size)

Keep every P0 and P1 finding as its own issue. Group P2/P3 only when grouping genuinely helps the reader.

### Mitigation reporting template
Goes inside each issue; the assignee completes it before close.

```
Mitigation Report for [Finding ID]

- Date completed:
- Implemented changes:
  - Files modified:
  - PR / commit links:
  - Configuration or infrastructure changes:
- How the original risk was addressed:
- Testing and verification performed:
- Residual risk (if any):
- Evidence attached (screenshots, logs, config diffs, test results):
- Developer sign-off:
- Security reviewer sign-off (required for P0/P1):
```

### Closure process
Layered on the `BUG-TRACKING.md` lifecycle (`file → triage → prioritize → assign → reproduce → fix → review → verify → close`), with the audit additions in bold.

1. Create every issue from this report using the supplied bodies and labels.
2. Link each issue to the parent tracking issue or Project view by its **[SEVERITY-XXX] finding ID**.
3. Developer or Designer implements the fix and opens a PR referencing the issue (`Fixes #<num>`).
4. Review per `DEVELOPMENT-BUILD.md` Phase 4. **For P0/P1 security findings, a security review is required, not optional.**
5. Merge to main (or release branch).
6. **Assignee completes the Mitigation Report section with evidence.**
7. **The auditor (or an automated check) re-tests and verifies the original risk is gone, not just that a test passes.**
8. Close only when the definition of done is fully satisfied and the mitigation report is populated.
9. Reference the final state back to the audit report.

Recommended automations: Project v2 rules that move cards on label change or PR merge; required status checks before merging security-labeled PRs; a documented residual-risk exception process for findings the business accepts rather than fixes (the exception is an owner and CFO decision, logged, per the escalation triggers in `BUG-TRACKING.md`).

## After remediation

- Produce a lightweight **remediation verification addendum** once all P0/P1 items are closed: which findings were fixed, the verifying evidence, and any accepted residual risk.
- Re-audit on a cadence: after any major change to a load-bearing surface, and on a fixed schedule (e.g. every six months) otherwise.
- Fold ongoing security tooling (dependency scanning, secret scanning, SAST, and for UI work automated accessibility checks) into CI so the next audit starts from a cleaner baseline.

## Final notes for the auditor

- Authorization and scope first. Never run intrusive or destructive tests against production or outside the agreed scope.
- Produce both deliverables, clearly separated. Deliverable 1 stays focused on risk; Deliverable 2 must be actionable without re-reading Deliverable 1.
- Maintain perfect traceability: every issue references its original finding ID.
- Prioritize the load-bearing surfaces of the product (money, on-chain writes, signing, authentication, regulated data; for a validator, key protection and consensus) as the highest-urgency items in both deliverables.
- Be precise, evidence-based, and practical for the production environment actually in scope.

## Where to find the references

| Concern | Doc |
|---|---|
| Label taxonomy, severity vs priority, lifecycle, `gh` CLI, triage cadence | `BUG-TRACKING.md` |
| The security baseline every persona inherits | `SECURITY-POSTURE.md` |
| Code review and the Phase 4 review gate | `DEVELOPMENT-BUILD.md` |
| The auditor's voice and responsibility | `../personas/SECURITY-AUDITOR-PERSONA.md` |
| Escalation and residual-risk / CFO authority | `BUG-TRACKING.md` (escalation triggers) |
