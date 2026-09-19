# Business Operations

## About this file

Fourth of six rule docs in the playbook (`TEAM-PERSONAS.md`, `DESIGN-METHODOLOGY.md`, `DEVELOPMENT-BUILD.md`, `BUSINESS-OPERATIONS.md` this file, `BUG-TRACKING.md`, `PRE-DEVELOPMENT-BLUEPRINT.md`). Tooling inventory lives separately at `../tools/SKILLS-INVENTORY.md`. Companion to `DESIGN-METHODOLOGY.md` (product and brand planning) and `DEVELOPMENT-BUILD.md` (engineering and deployment). This doc covers the functional areas a successful SaaS needs beyond product and engineering: legal, brand, design system, sales, customer success, marketing, people operations, community, support, compliance, finance, partnerships.

Each functional area pairs with a persona file in `../personas/`. The persona file is the "teammate" Claude puts on when working in that area; this doc is the "what work to do and when." The two together replace the role a specialist hire would play in a fully staffed company.

The tiers below are guidelines, not gates. Tier 2 work often starts during Tier 1 (a Tier 1 founder usually drafts the Tier 2 sales playbook before the first paying customer arrives). The sequencing reflects when each function becomes load-bearing, not the only moment it can be started.

## Tier framework at a glance

| Tier | When | What this stage decides |
|---|---|---|
| **Tier 1. Concept and pre-customer** | Before any paying customer | The legal, brand, and design foundations that everything else builds on |
| **Tier 2. First customers and closed beta** | First paying customers through closed beta | The go-to-market motion, customer success, hiring discipline |
| **Tier 3. Capital and scale** | Raising capital or scaling past the founding team | Audit-ready operations, support at volume, partnerships |

Twelve functions split across the three tiers. The function count per tier scales down as the work compounds, because Tier 3 functions depend on Tier 1 and Tier 2 work being in place first.

## Tier 1. Concept and pre-customer

Three foundations that must be in place before any paying customer. These are the functions where a single oversight or missing artifact can compound into months of cleanup later.

### 1.1 Legal foundation

**Why this matters at this tier.** Without a clean legal foundation, every later round of investment or contract negotiation stalls in diligence. IP assignments missed at the contractor stage can derail a Series A. Privacy policy gaps trigger regulatory exposure the moment the first user signs up.

**Owner.** `personas/LEGAL-PERSONA.md` (working with outside counsel for entity formation and complex contract review).

**Artifacts.** Incorporation documents (LLC or C-corp). IP assignment agreements signed by every contractor and founder. Terms of Service. Privacy Policy. Standard NDA template.

**Example prompt.**

```
Using the LEGAL persona, draft the IP assignment agreement
template a new contractor will sign before contributing code.
Reference current best practice from the YC Startup Library
legal mechanics guide. Flag any clauses that require outside
counsel review before use.
```

**Common pitfall.** Treating legal as a one-time setup. Reality is the legal foundation evolves as the product evolves. The Privacy Policy needs an update every time you collect a new field. The ToS needs an update every time you change pricing or refund terms. Schedule a quarterly legal review.

**Framework citation.** Y Combinator Startup Library, "Startup Legal Mechanics."

### 1.2 Brand identity

**Why this matters at this tier.** Brand is the first thing a prospect notices and the first thing investors form an opinion on. Without a documented brand identity, the product website, sales deck, and onboarding emails drift apart and the company looks amateur to anyone who pattern-matches across surfaces.

**Owner.** `personas/BRAND-PERSONA.md`.

**Artifacts.** Positioning statement (one sentence on who you are for and what you do better than alternatives). Visual style guide (logo, color palette, typography, spacing). Voice and tone guide (how the brand sounds in writing). Naming conventions (product names, feature names, internal-vs-external naming).

**Example prompt.**

```
Using the BRAND persona, draft the positioning statement and
voice and tone guide for a new SaaS in the <category> space.
Audience is <persona>. Closest competitors are <list>. The
wedge against those competitors is <differentiator>. Refer to
the First Round Review startup branding process for the
positioning structure.
```

**Common pitfall.** Sounding like every other SaaS in the category. Brand work that does not actively differentiate the product is wasted work. The visual style guide should pass a "could this be any other competitor" test.

**Framework citation.** First Round Review, startup branding process.

### 1.3 Design system and accessibility

**Why this matters at this tier.** Building product UI without a design system from day one accumulates design debt. Three months in, every screen looks slightly different and the team spends real engineering time on UI inconsistency cleanup. Establishing the system before any UI exists is the cheapest moment to do so.

**Owner.** `personas/DESIGNER-PERSONA.md`.

**Artifacts.** Component library (buttons, inputs, modals, tables, navigation). Design tokens (colors, type scale, spacing scale, motion). Accessibility baseline (WCAG AA target, keyboard navigation patterns, color contrast minimums, semantic HTML conventions).

**Example prompt.**

```
Using the DESIGNER persona, propose the initial component
library and design token set for a new SaaS web application.
Target a clean, modern, professional aesthetic suitable for
<industry>. Include accessibility requirements at WCAG AA level
and call out the components most likely to be reused across
the product.
```

**Common pitfall.** Designing a beautiful component library that nobody uses because the engineering team did not adopt it as the only source of truth. Codify "no inline styles, no one-off components" in the developer persona's rules.

**Framework citation.** Figma's "Design system 102" guide for the component library taxonomy.

## Tier 2. First customers and closed beta

Five functions that come online when paying customers arrive. The work in this tier is the foundation of a repeatable go-to-market motion.

### 2.1 Sales playbook

**Why this matters at this tier.** The founder is the first salesperson, and the playbook captures what works so the next salesperson can repeat it. Premature hiring of an Account Executive before the founder has closed 10 to 20 customers personally is one of the single most expensive mistakes in early-stage SaaS.

**Owner.** `personas/SALES-PERSONA.md` (the persona; the founder is typically the literal owner until product-market fit is proven).

**Artifacts.** Ideal Customer Profile (ICP) one-pager. Qualification framework (e.g. BANT or MEDDIC adapted to your motion). Demo script. Objection handling cheat sheet. Pricing rules of engagement. Discount approval ladder.

**Example prompt.**

```
Using the SALES persona, draft the ICP one-pager and demo
script for a new SaaS in the <category> space. The ICP should
include firmographic signals, behavioral signals, and explicit
disqualifiers. The demo script should be a 30-minute structure
with timing per section and the three objections most likely
to surface. Refer to SaaStr's founder-led sales guides.
```

**Common pitfall.** Hiring an AE before closing the first 10 to 20 customers yourself. SaaStr's repeated guidance: the founder must prove the motion before delegating it. Early AEs are there to stress-test a playbook, not invent one.

**Framework citations.** SaaStr, "Dear SaaStr: When Should I Hire My First AE?" Y Combinator, "How to Sell" by Tyler Bosmeny.

### 2.2 Customer success

**Why this matters at this tier.** Early customers churn if no one is actively helping them succeed with the product. The first customer success hire shapes the retention story for years. Hiring a CS upsell specialist too early instead of a trusted problem-solver is the second most common early-stage CS mistake.

**Owner.** `personas/CUSTOMER-SUCCESS-PERSONA.md`.

**Artifacts.** Onboarding checklist (the steps every new customer walks through). Health metric definition (what indicates a customer is succeeding versus drifting). QBR template (quarterly business review structure). Expansion playbook (when and how to introduce upsell conversations, only after trust is established).

**Example prompt.**

```
Using the CUSTOMER-SUCCESS persona, draft the onboarding
checklist and health metric definitions for a new SaaS where
the primary use case is <use case>. The onboarding should
target time-to-first-value of <duration> and explicitly avoid
upsell conversations during the first 30 days. Reference
SaaStr's CS hiring guidance on trust-first sequencing.
```

**Common pitfall.** Hiring a CS upsell expert before the product is reliable. Early customers need a problem-solver they trust, not a salesperson disguised as CS.

**Framework citation.** SaaStr, "Dear SaaStr: Who Should I Hire First for Customer Success?"

### 2.3 Marketing operations

**Why this matters at this tier.** Marketing without a tracked attribution chain is fire-and-forget. At the closed-beta stage, marketing operations exists to capture lead source, track engagement, and feed sales the qualified contacts. Over-investing in paid acquisition or content SEO at this stage is premature; founder-led channels (warm outbound, LinkedIn, personal network) carry the load.

**Owner.** `personas/MARKETING-PERSONA.md`.

**Artifacts.** CRM (HubSpot, Pipedrive, or equivalent) configured with lead-source tracking, deal stages, and contact properties. Mailing list provider integrated with the website. Basic analytics (web traffic, conversion to demo, demo to signup). Marketing automation for transactional emails (welcome, password reset, deal-stage updates).

**Example prompt.**

```
Using the MARKETING persona, propose the closed-beta marketing
operations stack and the analytics events to track. The CRM
should support lead-source attribution back to the founder-led
channel (LinkedIn DM, warm intro, podcast appearance, etc.).
Avoid recommending paid acquisition channels at this stage.
Refer to OpenView's GTM benchmarks for stage-appropriate
channel choices.
```

**Common pitfall.** Pouring budget into paid ads or SEO content before the founder has validated which message converts. OpenView's data is clear: closed-beta companies should rely on founder-led channels until the message is locked.

**Framework citation.** OpenView, SaaS benchmarks and GTM playbooks.

### 2.4 People operations and hiring

**Why this matters at this tier.** The first three to five hires define the team's culture for the next several years. Unstructured interviews produce inconsistent hiring quality and bias. Setting up scorecards before the first interview pays off for every subsequent hire.

**Owner.** `personas/PEOPLE-PERSONA.md`.

**Artifacts.** Job description template (role, responsibilities, what success looks like in 30/60/90 days). Structured interview scorecard (uniform rubric scored independently by each interviewer). Compensation philosophy (equity bands, salary bands by level, geographic adjustments). Onboarding checklist for new hires.

**Example prompt.**

```
Using the PEOPLE persona, draft the structured interview
scorecard for a <job-role> hire at a Tier 2 SaaS company. The
scorecard should have four to six categories, each with an
explicit rubric for what "exceeds expectations" versus "meets
expectations" versus "below" looks like. Scorers should grade
independently and reconcile after, per Google's structured
interviewing guidance.
```

**Common pitfall.** Skipping the scorecard because "we're a small team and we all just know." Three hires later the inconsistencies in evaluation surface as performance problems.

**Framework citations.** First Round Review on structured interviewing. Google's "Guide to structured interviewing for better hiring practices."

### 2.5 Developer relations and community

**Why this matters at this tier.** Required for product-led-growth or API-first products. Optional for top-down enterprise sales-led products. When required, community is a retention driver, not a marketing afterthought. Treating it as marketing destroys the trust signal that makes community work.

**Owner.** `personas/COMMUNITY-PERSONA.md`.

**Artifacts.** Community charter (what the community is, what it is not, how members participate). Hosting infrastructure (Discord, Slack, Discourse, GitHub Discussions, depending on audience). Contribution norms (code of conduct, escalation paths). Engagement metrics using the Orbit Model (Love, Reach, Gravity) or equivalent.

**Example prompt.**

```
Using the COMMUNITY persona, draft the community charter and
the first six months of engagement plan for a new <product
type> SaaS. The community should serve <audience> with the
goal of <retention | product feedback | both>. Use the Orbit
Model framing for engagement metrics. Explicitly avoid treating
community as a marketing acquisition channel.
```

**Common pitfall.** Measuring community by acquisition KPIs (new signups). The right measure is retention and engagement depth among existing users.

**Framework citation.** The Orbit Model (orbit-love/orbit-model on GitHub).

## Tier 3. Capital and scale

Four functions that activate at scale, or earlier if specific triggers fire (selling to Enterprise, raising institutional capital, hitting compliance thresholds). The functions here are the structural underpinnings of an audit-ready, fundable company.

### 3.1 Support at scale

**Why this matters at this tier.** Founder-led support stops scaling somewhere between 50 and 500 customers, depending on product complexity. Past that point, the support team needs a knowledge base, a ticketing system, and a tier 1 / tier 2 escalation pattern. Help Scout reports that a well-maintained knowledge base can reduce support ticket volume by at least 30%.

**Owner.** `personas/SUPPORT-PERSONA.md`.

**Artifacts.** Knowledge base (customer-facing self-serve docs covering the top 50 most common questions). Ticketing system (Zendesk, Intercom, Help Scout, or equivalent). Tier 1 vs Tier 2 split (tier 1 handles the knowable, tier 2 escalates to engineering). SLA targets per ticket severity.

**Example prompt.**

```
Using the SUPPORT persona, propose the initial knowledge-base
information architecture for a SaaS where the most common
customer questions are <list>. Each KB article should follow a
problem / cause / solution structure with a "see also" section.
Target a self-serve resolution rate of 30% within the first 90
days of publishing, per Help Scout benchmarks.
```

**Common pitfall.** Letting the knowledge base go stale. Schedule a quarterly KB review by the support team. Outdated KB articles destroy trust faster than no KB.

**Framework citation.** Help Scout, knowledge base benchmark and best practices.

### 3.2 Compliance operations

**Why this matters at this tier.** Enterprise customers require SOC 2 (often Type II), GDPR compliance documentation, and increasingly SOC 2 + ISO 27001. These are not one-time projects; they are continuous monitoring programs. Trigger early if selling to Enterprise from day one; otherwise activate at Tier 3.

**Owner.** `personas/COMPLIANCE-PERSONA.md` (typically the CFO or a dedicated compliance lead).

**Artifacts.** SOC 2 readiness assessment (gap analysis against the trust services criteria). SOC 2 Type I report (point-in-time attestation), then Type II report (continuous over a 6 to 12 month period). GDPR compliance checklist (data inventory, lawful basis documentation, DPIA for high-risk processing, DPA templates for sub-processors). Compliance automation tooling (Vanta, Drata, Secureframe, or equivalent).

**Example prompt.**

```
Using the COMPLIANCE persona, propose the SOC 2 readiness
roadmap for a SaaS preparing for its first Type I report in
the next six months. Include the controls map across security,
availability, processing integrity, confidentiality, and
privacy. Recommend whether to start with Type I or proceed
directly to Type II based on the customer profile. Reference
Vanta and Drata for automation tooling tradeoffs.
```

**Common pitfall.** Treating SOC 2 as a one-time project. The audit is annual and the controls are continuous. Compliance automation tooling that runs daily checks is the only sustainable path.

**Framework citations.** Vanta SOC 2 automation guide. Drata, "SOC 2 for Startups: Timelines, Readiness, and Your First Report." GDPR.eu compliance checklist.

### 3.3 Finance and accounting

**Why this matters at this tier.** Manual revenue tracking in a spreadsheet survives until the first audit, then breaks expensively. SaaS revenue recognition under ASC 606 (US) or IFRS 15 (international) is not optional once an auditor reviews the books. Setting up automated subscription billing and revenue recognition before the first audit is the cheap moment to do so. The Finance persona also owns fundraising operations (data room, investor pipeline, investor updates) since the artifacts overlap heavily with audit-readiness.

**Owner.** `personas/FINANCE-PERSONA.md`.

**Artifacts.** Subscription billing system (Stripe Billing, Maxio, Chargebee, or equivalent). Revenue recognition automation (ASC 606 compliant, contract-aware). Monthly investor update template. Quarterly board update template. Data room structure (legal, financial, customer, team, IP). Fundraising pipeline tracker (investor stage, last contact, follow-up).

**Example prompt.**

```
Using the FINANCE persona, propose the subscription billing and
revenue recognition setup for a SaaS approaching $1M ARR. The
billing system should support per-seat, usage-based, and flat
subscription models. Revenue recognition must be ASC 606
compliant from day one of the new setup. Reference Maxio's
ASC 606 guidance for the contract modification scenarios.
Separately, propose the data room structure for an upcoming
Series A raise.
```

**Common pitfall.** Manual revenue tracking that produces material misstatements during Series A diligence. The fix at that stage takes weeks of accountant time and can delay or kill the round.

**Framework citations.** Maxio, "Revenue Recognition Software for B2B SaaS." ASC 606 / IFRS 15 standards.

### 3.4 Partnerships and business development

**Why this matters at this tier.** Bespoke partner integrations distract the core team before product-market fit is achieved. At Tier 3, with the product validated and the team large enough to support partner work without distraction, partnerships become a real growth channel.

**Owner.** `personas/BIZDEV-PERSONA.md`.

**Artifacts.** Partner tiering model (technology partner, channel partner, strategic partner; each with different commercial terms). Joint go-to-market plan template (per partner). Partner enablement materials (sales playbook for the partner's reps, technical integration guides). Partner contract template (revenue share, IP, exclusivity, termination).

**Example prompt.**

```
Using the BIZDEV persona, draft the partner tiering model for
a SaaS that wants to add three technology partners and two
channel partners in the next year. Each tier should have
explicit qualification criteria, commercial terms, and
enablement deliverables. The model should prevent the team from
saying yes to every partner conversation; only partners that
clear the tier criteria get a formal partnership.
```

**Common pitfall.** Saying yes to every partner conversation. Without a tiering model, the team commits engineering time to bespoke integrations that never generate meaningful revenue.

## Common pitfalls across all tiers

- **Premature delegation.** Hiring a specialist for a function before the founder has personally proven the motion. Applies to AE hiring (Tier 2 sales), CS upsell specialists (Tier 2 CS), and outside-counsel-as-default (Tier 1 legal).
- **Delayed structural foundations.** Postponing legal, compliance, or revenue recognition because "we'll fix it before the audit." The fix is always more expensive at audit time than at setup time.
- **Treating community as marketing.** Community works because members trust the space; marketing-style measurement destroys that trust signal.
- **Skipping the persona file.** Working in a functional area without a persona file means every session re-establishes the voice and rules from scratch. The persona file is a permanent context-saver.

## Cross-references

- `DESIGN-METHODOLOGY.md` Phase 5 (Product Positioning) overlaps with Tier 1 Brand and Tier 2 Marketing functions in this doc. Treat them as parallel tracks.
- `DEVELOPMENT-BUILD.md` Phase 5 (Bug tracking) overlaps with Tier 3 Support. Both flow into the support team's queue.
- `TEAM-PERSONAS.md` defines the persona file template these functions reference.
- `../personas/<ROLE>-PERSONA.md` for each function's owner.

## Next

If a function in this doc is not yet covered by a persona file in `../personas/`, write the persona file from the template before doing the function work. The persona is what saves you time on the actual function work.
