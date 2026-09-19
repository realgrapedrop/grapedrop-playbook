# Pre-Development Blueprint

## About this file

A reference doc for the team during the requirements stage of the project lifecycle. Describes the seven artifacts that together form the complete pre-development blueprint a project produces before any production code gets written. The architect, end-user, developer, designer, brand, bizdev, and compliance personas all read from this doc when working on the requirements stage; the doc explains what each artifact covers, which persona owns it, where it lives, and what it feeds into next.

Sixth of six rule docs in the playbook (`TEAM-PERSONAS.md`, `DESIGN-METHODOLOGY.md`, `DEVELOPMENT-BUILD.md`, `BUSINESS-OPERATIONS.md`, `BUG-TRACKING.md`, `PRE-DEVELOPMENT-BLUEPRINT.md` this file).

## Why this exists

The requirements stage in the eight-stage lifecycle is the most encompassing of any stage. Calling it "requirements" can mislead readers into thinking it produces a single `REQUIREMENTS.md` doc and nothing more. In practice the requirements stage produces a complete pre-development blueprint — seven distinct artifacts that together:

1. Justify the project (why are we building this).
2. Define what the system must do (the rules).
3. Describe how users interact with the system (the journeys).
4. Sketch the visual surfaces (what the user sees).
5. Blueprint the technical layer (how it runs).
6. Set the project boundaries (what we are and are not committing to).
7. Stage the delivery (the path to MVP).

Each persona owns part of the blueprint. None of them owns all of it. The blueprint as a whole is what unblocks the build stage; missing one of the seven artifacts is a known pattern for a project that gets stuck mid-build because nobody wrote down what they were doing.

## The seven artifacts

### 1. Strategy and Viability

**What it covers.** The business purpose, the target user personas, the success metrics (KPIs), and the justification for the project. Why are we building this. Who is it for. What does success look like. This artifact answers the question every reviewer (CFO, investor, partner, regulator) asks first.

**Persona owners.** End-user (target user personas and journeys). Brand (positioning and voice). BizDev (market shape and partner dependencies). CFO (financial viability and KPIs).

**Where it lives.** `docs/STRATEGY.md` for larger projects, or absorbed into the design spec at `docs/specs/<topic>-design.md` for smaller ones.

**Feeds into.** The use cases artifact (because user personas drive the journeys) and the project delivery plan (because KPIs drive scope decisions).

### 2. Requirements (functional and non-functional)

**What it covers.** The specific rules of the system. Functional requirements (what features must exist, identified by FR codes such as FR-XYZ-001). Non-functional requirements (how the system must perform, identified by NFR codes such as NFR-PERF-001). Each requirement is a single rule the platform must satisfy, written so it is testable.

**Persona owners.** Architect (load-bearing technical requirements). End-user (user-facing requirements). Compliance (regulated-surface requirements per `regulatory-frames-in-scope.md`).

**Where it lives.** `docs/REQUIREMENTS.md`.

**Feeds into.** The design artifact (because requirements constrain the principles and domain model) and the architecture artifact (because requirements determine the components and integrations).

### 3. Use Cases

**What it covers.** How users interact step-by-step with the system to achieve specific goals. Each use case names the user, the goal, the preconditions, the steps the user walks through, and the outcome. Use cases turn target personas into concrete interaction stories.

**Persona owners.** End-user (the canonical author and quality-bar holder per the End-User persona).

**Where it lives.** `docs/USE_CASES.md`.

**Feeds into.** The requirements artifact (because each use case generates one or more testable requirements) and the UX/UI design artifact (because each use case maps to one or more screen flows).

### 4. UX/UI Design

**What it covers.** Visual wireframes, screen flows, and information layout for the engineering team. The intent is to communicate what the user sees and how they navigate, not the final visual identity. UX/UI design at this stage is sufficient to validate the use cases and unblock engineering.

**Persona owners.** Designer (per the Designer persona). Brand-level visual identity (logo, primary palette, typeface family) is CFO-approved per the brand-call authority but does not block the UX/UI design pass.

**Where it lives.** Wireframes in Figma (the playbook's design-system source-of-truth split documented in the Designer persona); the approved screens land in code under the project's component library.

**Feeds into.** The technical architecture (because UI choices constrain the API surface and the data model) and the project delivery plan (because each wireframe is one or more implementation tasks).

### 5. Technical Architecture

**What it covers.** The underlying system design, the database structures, the third-party integrations, the deployment topology, and the load-bearing technical decisions. Architecture decision records (ADRs) capture the why behind each load-bearing choice and what was considered and rejected.

**Persona owners.** Architect (per the Architect persona). Joint with Compliance on regulated-surface design per `release-gate-authority.md`.

**Where it lives.** `docs/DESIGN.md` (principles, domain model, key flows), `docs/ARCHITECTURE.md` (components, deployment, sequence diagrams), `docs/adr/NNNN-<slug>.md` (per-decision ADRs), specialized layer docs as needed (e.g., `docs/AI_POSTURE.md`, `docs/DATA_PRODUCT.md`, `docs/INFRASTRUCTURE.md`).

**Feeds into.** The constraints and assumptions artifact (because architecture decisions tie into stacks, vendors, and dependencies) and the project delivery plan (because architecture determines the build sequence).

### 6. Constraints and Assumptions

**What it covers.** The project boundaries. Budgets. Technology stacks. Deadlines. Dependencies on third-party services or partner deliverables. Assumptions the team is making (for example: "we assume the customer pipeline closes by Q2"; "we assume the cloud provider's uptime SLA is sufficient for our customer commitments"). Every assumption is a hidden risk; naming it makes it reviewable.

**Persona owners.** Architect (technical constraints and stacks). CFO (budget and timeline). BizDev (partner dependencies). Compliance (regulatory deadlines and regulator-cooperation windows).

**Where it lives.** A section within `docs/DESIGN.md` for smaller projects, or its own doc at `docs/CONSTRAINTS.md` for larger ones.

**Feeds into.** The project delivery plan (because constraints shape what the MVP can include) and the risk register (because every assumption that turns out wrong is a risk to flag).

### 7. Project Delivery Plan

**What it covers.** The initial release scope (MVP), the developer tasks (user stories or implementation plan), the milestone calendar, the dependencies between tasks, and the risk register. The plan is the bridge between the pre-development blueprint and the build stage.

**Persona owners.** Architect (drafts the overall sequence). Developer (drafts the implementation plans via the `superpowers:writing-plans` skill). CFO (sign-off on scope and timeline).

**Where it lives.** Implementation plans under `docs/superpowers/plans/YYYY-MM-DD-<topic>.md`. Milestone calendar and MVP scope often live in `docs/BUSINESS_PLAN.md` or `docs/PROJECT_PLAN.md`. The risk register is a section within the plan or its own doc at `docs/RISKS.md`.

**Feeds into.** The build stage. Once the delivery plan is signed off, the developer persona executes the implementation plans per the `superpowers:executing-plans` or `superpowers:subagent-driven-development` discipline.

## How the seven artifacts fit together

The seven artifacts are not produced sequentially in isolation. They feed each other, and the team often works on several in parallel.

```
Strategy & Viability
        ↓
    Use Cases ←──→ Requirements ←──→ Constraints & Assumptions
        ↓                ↓                       ↓
    UX/UI Design ←──→ Technical Architecture ────┘
                            ↓
                Project Delivery Plan
                            ↓
                        (Build stage)
```

Strategy comes first because it answers "why." Use cases and requirements develop together — each use case spawns requirements, and each requirement is validated against a use case. UX/UI design follows the use cases and informs the technical architecture. Constraints surface as decisions are made and bound everything. The delivery plan is the synthesis that turns the blueprint into a buildable sequence.

## How this maps to the lifecycle stages

The seven artifacts above are all produced during the lifecycle's **requirements stage** in the eight-stage flow shown in the README intro (`concept → requirements → design → architecture → planning → build → ship → iterate`). In the more granular phase structure in `DESIGN-METHODOLOGY.md`, they span Phase 2 (Concept, which produces strategy and viability), Phase 3 (Product Definition, which produces requirements and use cases), and Phase 4 (Product Build Plan, which produces technical architecture, constraints, and delivery plan). The README intro uses the simpler eight-stage framing where these all fall under "requirements"; the methodology rule doc uses the more granular phase structure. Both are internally consistent and describe the same work.

## When to consult this doc

| Persona | Stage of project | Why to read |
|---|---|---|
| Architect | Requirements stage; planning stage | To know what artifacts the requirements stage produces and which ones the architect owns. The architect is the most common author across the seven artifacts. |
| End-user | Requirements stage | To know how strategy, use cases, and UX/UI design connect, and to hold the quality bar on use cases. |
| Developer | Planning stage; build stage | To know what was decided in the pre-development blueprint before writing implementation plans or production code. |
| Designer | Requirements stage | To know how UX/UI design fits between use cases (input) and technical architecture (downstream constraint). |
| Compliance | Requirements stage; release-gate review | To know which artifacts touch regulated surfaces and need a Compliance review. |
| Brand | Requirements stage | To know where the brand persona contributes to strategy and viability. |
| BizDev | Requirements stage | To know where partner-deal dependencies land in constraints and assumptions. |
| CFO | Throughout | To know where financial viability, budget, brand-call authority, and exception-path authority apply across the blueprint. |

## Common pitfalls

- **Skipping the use cases artifact.** Teams jump from strategy directly to requirements without writing use cases. The result is requirements that don't trace to user journeys, and a build phase where developers discover use cases ad hoc by asking the end-user persona at PR time. Always write use cases before or alongside requirements.
- **Treating UX/UI design as decorative.** UX/UI design at this stage is sufficient to validate the use cases and unblock engineering. It is not the final brand or visual identity work. The Designer persona produces "good enough to build against" wireframes; brand-level polish happens later in parallel.
- **Skipping constraints.** Teams write strategy, requirements, use cases, design, and architecture, and then build without ever writing the constraints. The result is a build that exceeds budget, misses deadlines, or depends on a partner that has not delivered. Write constraints and assumptions explicitly.
- **Treating the delivery plan as a Gantt chart.** The delivery plan is the path to MVP plus the risk register. It is not a fully resolved schedule of every task. It is the smallest plan that lets engineering start building confidently, with the known risks named.
- **Not revisiting the blueprint when reality teaches you something new.** The blueprint is not signed in stone after the requirements stage closes. Earlier-stage artifacts get revisited deliberately, the same way the iterate stage feeds back into earlier stages. Update the artifact; do not let it rot.

## See also

- `DESIGN-METHODOLOGY.md` for the lifecycle Phases 2 through 5 expanded with example prompts and per-phase artifacts.
- `DEVELOPMENT-BUILD.md` for what happens after the pre-development blueprint is complete (the build stage and beyond).
- `BUG-TRACKING.md` for the discipline that surrounds the build stage and feeds back into the blueprint when bugs reveal an unaddressed requirement or a wrong assumption.
- `TEAM-PERSONAS.md` for the persona-as-team concept and persona-to-artifact mapping.
- `../../docs/LIFECYCLE.md` for the eight-stage lifecycle context that frames this blueprint.
