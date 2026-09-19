# Default Decisions

## What this file is

The wizard's decision register. When the conversational bootstrap wizard (`START-PLAYBOOK.md`) runs in autonomous mode (Phase 5), it reads this file to know what default to apply for every per-persona customization decision, what signal in the user's input materials would trigger an override, and what to do when no signal is present.

The wizard does not ask the user about these decisions during the run. The wizard applies the defaults (or the inferred override), captures the reasoning, and surfaces the full set in a single consolidated summary (Phase 6) for the user to accept, modify, or reject.

This file is read by the wizard. Humans rarely read it directly. The audit trail of which defaults were applied to a given project lands in the project's `.project/playbook/knowledge/BOOTSTRAP-PROPOSAL.md` (the summary written during Phase 5) and then in `PROJECT-OVERVIEW.md` (the initial knowledge entry written during Phase 7).

## How the wizard uses this file

For each persona on the curated team list, the wizard walks the per-persona section below in order:

1. Read the project context built in Phase 4 (input materials, brainstorm output, or the vanilla flag).
2. For each decision in the persona's section, check the **Override triggers** column. If a trigger is present in the project context, apply the corresponding override. Otherwise apply the **Default**.
3. Record the chosen decision and the reasoning in the proposal. The proposal lists, for every decision, both what was chosen and why.
4. If a decision genuinely cannot be inferred and the default is not safe to assume blindly, surface the decision as **flagged** in the proposal so the user reviews it explicitly during Phase 6.

The wizard does not skip persona customization. Every persona on the curated team gets a customized file written from the defaults plus the inferred overrides.

## Cross-cutting decisions that affect multiple personas

These decisions land as project-wide knowledge entries in `.project/playbook/knowledge/`. The wizard writes them once and references them from every persona that touches them.

| Decision | Default | Override triggers | Knowledge entry written |
|---|---|---|---|
| Accessibility floor | WCAG 2.2 AA on every shipping surface | Inputs explicitly mention government, healthcare, education, or vulnerable-population audience → consider AAA on specific surfaces and flag the AA-vs-AAA call for user review. Inputs explicitly state a relaxed accessibility posture → flag for user decision (do not silently lower the floor) | `accessibility-floor.md` |
| Brand asset locations | Three-tier hybrid: external source files (Figma + Drive), in-repo masters (`images/`), in-repo deployable derivatives (`website/assets/`) | Inputs explicitly state a different asset workflow → match the stated workflow and document the deviation | `brand-asset-locations.md` |
| Regulatory frames in scope | Derived from project context. Baseline US federal + state for any project handling money, customer data, or regulated transactions. Add EU AI Act when project uses AI on decisions affecting users. Add jurisdiction-specific frames per the audience the inputs describe. GDPR delivered in shape via privacy-by-design defaults; named explicitly when first EU customer is present in the inputs | Inputs explicitly name a regulatory framework not in the inferred set → add it. Inputs explicitly state a jurisdiction is out of scope → add it to the Deferred list | `regulatory-frames-in-scope.md` |
| Release gate authority | Blocking by default with a documented CFO exception path | None at this stage. The safer default holds regardless of project shape; advisory-only is reopened only on explicit user override during Phase 6 | `release-gate-authority.md` |
| Partner program framework | Three-tier (Strategic / Channel / Technology) with a four-threshold deal-authority gate. Dollar threshold scales by company stage: pre-seed $25k, seed $50k, Series A $100k, growth-stage $250k. Other three thresholds (any customer data sharing, new jurisdiction outside active scope, public marketing rights) always blocking regardless of stage | Inputs explicitly state a different partner tiering or threshold convention → match the stated convention | `partner-program-framework.md` |
| Microcopy authority | End-User per-string. Brand surface-level on a documented quarterly cadence. Regulated language routes to Compliance for precise wording. Disagreement escalates to CFO | None at this stage. The split is universally appropriate for any user-facing product. Override only on explicit user request during Phase 6 | `microcopy-authority.md` |

The wizard writes these knowledge entries even for vanilla projects, so the cross-cutting decisions have a canonical location from day one.

## Per-persona decisions

### Architect

| Decision | Default | Override triggers |
|---|---|---|
| Cleaner-regulatory-story tiebreaker | Apply (the regulatory-cleaner option wins on technical ties) | None. The default is safe for any project with any compliance surface and harmless for purely-internal projects |
| ADR cadence and format | Formal `docs/adr/NNNN-<slug>.md`, status fields Proposed/Accepted/Superseded/Deprecated, append-only after acceptance | Inputs explicitly state a different ADR convention (different format, different location, lighter cadence) → match the stated convention |
| KYC and AML decision pattern | Joint with Compliance and Legal (Architect contributes technical layer; Compliance owns the call). The persona file states this explicitly so future agents do not assume Architect alone decides | Inputs state the project has no KYC or AML surface → drop the KYC/AML section from the persona file rather than write a "not applicable" note |
| Chain or framework lock-in policy | Every load-bearing component has an explicit migration plan documented in its ADR | None. Reversibility is a universal architectural discipline |

### Developer

| Decision | Default | Override triggers |
|---|---|---|
| Test discipline scope | TDD required for money, on-chain writes, signing, authentication, authorization. Test-after acceptable elsewhere | If no money/on-chain/auth code in project, the persona file states "TDD scope is currently empty for this project; test-after is the working default" rather than fabricating a strict-TDD posture. If project is healthcare, safety-critical, or otherwise has a category where misunderstanding has direct cost equal to financial misunderstanding, extend TDD to that category |
| Code review depth | Medium: block on correctness and security, comment on style and naming, approve through stylistic preference | Inputs explicitly state a different review posture (strict-everywhere or light-everywhere) → match the stated posture |
| Production deploy authorization | Requires sign-off from CFO (financial implications, brand exposure) and Compliance (regulatory implications) | Inputs explicitly state a different deploy authority (e.g. CTO-only, no formal authorization) → match the stated authority. If project has no production surface yet, the persona file states the authorization is "TBD until production surface exists" |
| Mainnet smart contract deploy | Requires third-party audit before Compliance gate. No exceptions | Inputs state the project has no on-chain smart contract surface → drop the section from the persona file |
| On-chain reserve operations | Execution requires CFO authorization regardless of who wrote the code | Inputs state the project has no on-chain reserve operations → drop the section from the persona file |

### Designer

| Decision | Default | Override triggers |
|---|---|---|
| Design system source of truth | Code canonical for components, tokens, spacing, color, typography. Figma canonical for layout exploration, full pages, marketing comps, customer-onboarding wireframes. When the two drift, code wins for components, Figma wins for unimplemented flows | Inputs state design is Figma-only with no code system → Figma-first variant. Inputs state design is code-only with no Figma → all-code variant. Both variants are documented in the persona file rather than the hybrid |
| Design system on disk | `design-system/` at the repo root, committed, with a short token block in `CLAUDE.md` pointing at it, per `DESIGN-PRODUCTION.md` Step 1. On an existing project, extract from the repo's theme files and published site before asking the owner anything. On a new project with no brand yet, defer until the Brand persona has a direction; do not generate a placeholder system | Inputs include a brand guide or an existing design system → import it as the source of truth rather than extracting. Project has no visual surface (a CLI, a library, an API) → skip, and the persona file says so |
| Pre-launch focus | Marketing site + customer onboarding + component library hardening | Inputs state the project is post-launch or scaling-stage → swap to the existing top-traffic surface as the focus |
| Brand-call escalation | Visual identity at the brand level (logo, primary palette, typeface family) routes to CFO per the brand-call authority in `PERSONA-CFO.md` | If project has no separate CFO persona, the call routes to the founder per `PERSONA-CEO.md` |

### Brand

| Decision | Default | Override triggers |
|---|---|---|
| Voice ownership | Fully inherits from `PERSONA-CEO.md` (the Brand persona is the founder's voice, not a separate brand-strategist voice). Cadence: founder drafts, CFO approves | Inputs state the project has a dedicated brand team with its own voice → standalone Brand voice; the founder still has brand-call authority but the day-to-day drafting is Brand's |
| Scope boundary with Marketing | Brand owns positioning, tagline, hook, voice and tone rules, do-not-use word list, visual identity rules. Marketing owns campaigns, content calendar, CRM, channel mix, attribution | None. The split is universally appropriate for any team that will eventually have both Brand and Marketing functions |

### Compliance

| Decision | Default | Override triggers |
|---|---|---|
| Legal absorption | Compliance absorbs Legal. One persona handles regulatory analysis, KYC and AML rulings, audit-evidence catalog, breach-response runbook, and the legal documents (ToS, Privacy Policy, contracts, regulatory correspondence) | Inputs explicitly state a separate Legal lane is required → preserve a separate Legal persona; Compliance focuses on the regulatory and audit work |
| Audit posture | Derived from customer profile inferred from inputs. Enterprise B2B → SOC 2 Type II as year-1 target (skip Type I). Consumer or pre-revenue → defer formal audit until first customer requires it. Healthcare → HIPAA plus SOC 2. Government → FedRAMP plus SOC 2 | Inputs explicitly state a different audit framework or target → match the stated framework |
| ISO 27001 readiness | Not in scope unless customer, partner, or jurisdiction explicitly requires it in the inputs | Inputs explicitly require ISO 27001 → add it to the audit timeline |
| Breach response runbook | Owned by Compliance. Covers detection, triage, containment, notification windows (GDPR-shape windows by default plus state breach-notification statutes), counsel engagement, regulator correspondence, customer correspondence, postmortem and remediation. Exercised at minimum annually | None. Breach response is a universal compliance discipline |

### BizDev

| Decision | Default | Override triggers |
|---|---|---|
| BizDev versus Sales boundary | BizDev does everything customer-facing pre-launch (partner deals, first paying customer conversations, channel deals). Direct Sales as a separate persona is dormant; reopens when pipeline volume exceeds what one lane can manage | Inputs state the project is consumer-direct (B2C app, indie SaaS, self-serve product) → activate Sales (or equivalent self-serve growth persona) immediately and demote BizDev to partner-only. Inputs state the project is post-launch with active direct-sales motion → Sales is already active; BizDev focuses on partnerships only |
| Partner tiering framework | Three-tier (Strategic / Channel / Technology) with explicit criteria per tier | None. The three-tier framework fits any project that will have partners |
| Deal authority dollar threshold | Scaled by inferred company stage. Pre-seed: $25k. Seed: $50k. Series A: $100k. Growth-stage: $250k. Other three thresholds (any customer data sharing, new jurisdiction outside active scope, public marketing rights) always blocking regardless of stage | Inputs explicitly state a different threshold convention → match the stated convention |

### End-User

| Decision | Default | Override triggers |
|---|---|---|
| Use-case authorship cadence | Anyone can draft a use case; End-User holds the quality bar before merge. Quality bar covers journey coherence, value-statement validity, flow consistency, terminology consistency | None. The cadence is universally appropriate; it does not gate authorship, only reviews it |
| Microcopy authority | End-User per-string. Brand surface-level on a documented quarterly cadence. Regulated language routes to Compliance for the precise wording. Disagreement escalates to CFO under brand-call authority | None. The split is universally appropriate for any user-facing product |
| Testing discipline pre-launch | Load-bearing flows tested with proxies coordinated through BizDev. Non-load-bearing copy ships on End-User judgment. Full target-user testing reopens post-launch | Inputs state the project is post-launch with users → drop the proxy mechanic; default to direct target-user testing on load-bearing flows. Inputs state the project has no load-bearing flows in the financial, safety, or auth sense → the persona file states the testing discipline is "judgment-based until a load-bearing flow is identified" |

### Other personas

The remaining personas (Marketing, Customer Success, Support, Community, Sales, People, Finance — when they are on the curated team) have their own customization defaults documented inline in their persona templates at `reference/personas/`. They follow the same pattern: the wizard reads the template, applies the inline defaults plus any inferred overrides from inputs, writes the customized file, and records the reasoning in the proposal.

## Universal fallback when a decision cannot be inferred

When the wizard genuinely cannot infer the right answer from the inputs and the default could materially shape the project, the wizard does not pick silently. It flags the decision in the Phase 6 proposal under a **Flagged for your decision** section. The user reviews the flagged items explicitly and either confirms the proposed default, picks an alternative, or asks the wizard for a recommendation.

Items that go into the Flagged section are rare by design. The defaults above are calibrated so 80 to 95 percent of decisions are made automatically and only the genuinely project-specific calls reach the user.

## How to update this file

When experience reveals a default that should change, edit the relevant row above and add a dated note under the Maintenance log below. Wizard runs after the edit will use the updated default. Existing projects that already ran the wizard are not affected (their proposals captured the default at the time of their run).

## Maintenance log

### 2026-09-18 - Design system on disk

Added the Designer decision "Design system on disk" with the release of `DESIGN-PRODUCTION.md`. The default location is `design-system/` at the repo root. The wizard extracts on existing projects and defers on new projects with no brand, because a placeholder system would be a set of invented brand values.

### 2026-05-31 - Initial register

Initial publication of the decision register, derived from the maintainer's first persona walkthrough in May 2026. Eight functional persona decisions captured. Six cross-cutting knowledge-entry decisions captured. Universal fallback rule documented.
