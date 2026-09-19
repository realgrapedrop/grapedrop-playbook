# SaaS Project Methodology

## About this file

Second of six rule docs in the playbook (`TEAM-PERSONAS.md`, `DESIGN-METHODOLOGY.md` this file, `DEVELOPMENT-BUILD.md`, `BUSINESS-OPERATIONS.md`, `BUG-TRACKING.md`, `PRE-DEVELOPMENT-BLUEPRINT.md`). Tooling inventory lives separately at `../tools/SKILLS-INVENTORY.md`. A repeatable playbook for taking a SaaS project from idea to positioned product. Captures the order in which artifacts get created, how each one flows into the next, and the example Claude prompts you would actually use at each step.

This doc covers the five planning and definition phases. The two implementation and operations phases (writing the code, testing, bug tracking, deploying, monitoring, iterating) live in `DEVELOPMENT-BUILD.md`.

## Why a flow

Ad-hoc development with an AI partner produces inconsistent results because each session starts from a different mental model of the project. A documented flow fixes that. Every phase produces a named artifact. Every later phase references the earlier artifacts as inputs. Claude reads the inputs at the start of each phase, so the project stays coherent across sessions and across team members. Skipping a phase is allowed when it does not apply (a side project may not need a Business Plan), but a phase is never silently skipped without a written reason.

The flow also separates concerns deliberately. The Concept phase decides what to build. The Product Definition phase decides what it must do. The Product Build Plan phase decides how it works. The Product Positioning phase decides how to sell it. Mixing those concerns in a single artifact produces a doc no one can read. Keeping them separate produces docs each audience can use.

## Inputs from the other process docs

This playbook assumes the other process docs are in place.

- `../tools/SKILLS-INVENTORY.md` tells you which Claude Code skills you have, so the example prompts below that invoke `superpowers:brainstorming` or `superpowers:writing-plans` resolve to real installed tools.
- `TEAM-PERSONAS.md` tells you which teammates exist, so the "use the Architect persona" or "use the Brand persona" notes below resolve to actual persona files in `.project/`.
- `.claude/CLAUDE.md` references both of the above so Claude sees them on every session start.

If any of those is missing or stale, fix it first. The playbook runs cleaner when the foundation is solid.

## The flow at a glance

| Phase | What it decides | Primary artifact(s) |
|---|---|---|
| 1. Foundation | What tools you have, how you talk to Claude | `../tools/SKILLS-INVENTORY.md`, `TEAM-PERSONAS.md`, `.claude/CLAUDE.md` |
| 2. Concept | What you are building and why | A design spec in `docs/specs/` |
| 3. Product Definition | What it does and what it must satisfy | `USE_CASES.md`, `REQUIREMENTS.md` |
| 4. Product Build Plan | How it works under the hood | `DESIGN.md`, `ARCHITECTURE.md`, specialized docs |
| 5. Product Positioning | How it fits the world | `BRAND_STRATEGY.md`, `BUSINESS_PLAN.md`, `GO_TO_MARKET.md` |

Phases 6 and 7 (Implementation and Iteration) live in `DEVELOPMENT-BUILD.md`. Implementation covers the writing-plans and subagent-driven-development skills plus the testing, bug tracking, code review, deployment, and monitoring practices that surround the code itself. Iteration covers the loop back from production reality into the planning phases above.

Each phase below explains why it matters, what it produces, an example Claude prompt to drive it, and what flows from it into the next phase.

## Phase 1. Foundation. Set up the tools and the project context.

### 1.1 Take inventory of installed skills

**Why.** Claude Code uses plugin skills (brainstorming, writing plans, deep research, etc.) to do non-trivial work well. Knowing which skills are installed lets you compose them deliberately instead of stumbling onto them by accident.

**Artifact.** `.project/playbook/reference/tools/SKILLS-INVENTORY.md` with the list of installed plugins and what each skill does.

**Example prompt.**

```
List the Claude Code skills currently installed on this machine,
group them by plugin, and save the inventory to
.project/playbook/reference/tools/SKILLS-INVENTORY.md with a short
note explaining when each skill is most useful.
```

**Flows to.** Phase 1.2, where you set up the project context that references those skills.

### 1.2 Establish project context

**Why.** Claude Code reads `.claude/CLAUDE.md` at session start. That file is where you tell Claude how this project communicates, what voices it uses, where its private notes live, and what to never do. Setting it up once means every later session starts from the same baseline.

**Artifact.** `.claude/CLAUDE.md` at the repo root, plus persona files and operational notes under `.project/`. See `TEAM-PERSONAS.md` (this folder) for the `.project/` pattern and persona team concept.

**Example prompt.**

```
Read the existing .claude/CLAUDE.md if it exists and propose
additions for our project. We need: an ARCHITECT-PERSONA, an
ENDUSER-PERSONA, a DEVELOPER-PERSONA, the no-AI-attribution rule
in commit messages, and the git identity policy. Place persona
files in .project/ and reference them from .claude/CLAUDE.md
by relative path.
```

**Flows to.** Phase 2. With the context in place, every brainstorm now happens in the right voice and with the right guardrails.

## Phase 2. Concept. Turn the idea into a structured spec.

### 2.1 Brainstorm the concept

**Why.** A vague idea cannot be turned into use cases, requirements, or architecture. The brainstorming skill walks you through a dialogue that produces a structured design spec. The spec captures the problem, the audience, the wedge, the constraints, the success criteria, and the explicit out-of-scope items. Every later phase reads from this spec.

**Artifact.** A dated design spec at `docs/specs/YYYY-MM-DD-<topic>-design.md`.

**Example prompt.**

```
/superpowers:brainstorming I want to build a SaaS that solves
<problem> for <audience>. My hypothesis is <core thesis>. The
wedge against existing solutions is <differentiator>. Help me
turn this into a structured design spec. Save it under
docs/specs/ when we have alignment.
```

**Flows to.** Phase 3. The spec becomes the input for the use cases doc.

## Phase 3. Product Definition. What does it do?

### 3.1 Use cases

**Why.** Use cases translate the spec into concrete user journeys. Who shows up, what they are trying to accomplish, what they do step by step, and what is deliberately left out. This is the doc that proves the spec is real because it forces you to walk through specific scenarios end to end.

**Artifact.** `docs/USE_CASES.md`.

**Example prompt.**

```
Based on the spec at docs/specs/YYYY-MM-DD-<topic>-design.md,
draft docs/USE_CASES.md. Cover the primary user journeys, the
actors involved, the surface each actor touches, and a
"deliberately left out" section that records what we are NOT
solving in this scope. Use plain language so a non-engineer
can read it end to end.
```

**Flows to.** Phase 3.2. Use cases become the input for requirements.

### 3.2 Requirements

**Why.** Requirements turn use cases into testable statements. Each requirement is a single rule the platform must satisfy, identified by a code (FR-* for functional, NFR-* for non-functional). Constraints, assumptions, and a traceability matrix linking requirements back to differentiators round out the doc. This is the doc engineering builds against.

**Artifact.** `docs/REQUIREMENTS.md`.

**Example prompt.**

```
From docs/USE_CASES.md and docs/specs/YYYY-MM-DD-<topic>-design.md,
draft docs/REQUIREMENTS.md. Include functional requirements
(FR-* codes), non-functional requirements (NFR-* codes), a
glossary, personas, assumptions, constraints, an explicit "out
of scope" list, and a traceability matrix that maps each
requirement to the differentiator or use case it serves.
```

**Flows to.** Phase 4. Requirements become the input for design.

## Phase 4. Product Build Plan. How is it built?

### 4.1 Design

**Why.** Design captures the load-bearing principles, the domain model, and the key flows in prose and small diagrams. It explains the why behind architectural choices. Design is the doc a senior engineer or a counsel reads to understand the platform without diving into the architecture diagrams or the code.

**Artifact.** `docs/DESIGN.md`.

**Example prompt.**

```
From docs/REQUIREMENTS.md and docs/USE_CASES.md, draft
docs/DESIGN.md. Open with five to seven design principles, each
in two or three sentences. Then describe the domain model (core
entities, relationships, lifecycles), the data classification
policy, and the three or four most important end-to-end flows.
Use the Architect persona.
```

**Flows to.** Phase 4.2. Design feeds architecture.

### 4.2 Architecture

**Why.** Architecture is the concrete answer to how the system runs. Components, deployment, sequence diagrams, container inventory, integration points, and the architecture decision records (ADRs) that document why each load-bearing choice was made. This is the doc engineering, security review, and disaster recovery all read from.

**Artifact.** `docs/ARCHITECTURE.md` plus the rendered diagrams referenced from it (typically saved under `images/`).

**Example prompt for the doc.**

```
From docs/DESIGN.md and docs/REQUIREMENTS.md, draft
docs/ARCHITECTURE.md. Include a logical architecture diagram
(described in alt-text, image reference at images/<topic>.png),
a containers table, a key sequence diagrams section for the
most important flows, an integration table, and an ADRs table
where each row records a load-bearing choice with its
alternatives and rationale.
```

**Diagrams go with the architecture doc.** The doc's alt-text and prose are necessary but not sufficient. A rendered diagram makes the architecture legible at a glance to a reviewer who is not going to read the prose end to end. Generate the diagrams in three steps. The recommended generator is Gemini Nano Banana; it currently produces the cleanest editorial-style diagrams in this category. The same prompt format works on other image generators if you ever need to swap.

**Step 1. Write a from-scratch image-generation prompt.** Save the prompt as `.project/image-prompt/<topic>-v<n>.md` so it is versioned and re-runnable. The prompt describes the canvas, the layout, every chip and lane, the arrow set, the color palette, the chip-count check, and the ban on rendering style-descriptor words. Use a from-scratch prompt (not an image-edit prompt) for any change that adds, removes, or repositions a lane or major structural element. Use an image-edit prompt for small additive changes (a sub-label on an existing chip, a single new chip in an existing lane); those are faster and disturb the surrounding canvas less. Treat from-scratch and image-edit as two distinct prompt families saved as separate files.

**Example prompt for writing the prompt.**

```
Write a from-scratch Gemini Nano Banana image prompt for the
logical architecture diagram. The diagram has <N> horizontal
swim lanes, each named: <lane list>. Inside each lane:
<chip list per lane>. Arrows: <arrow set>. Colors: pure white
background, dark slate text, a single accent color for lane
labels and numbered arrows, light gray chip borders. Include
explicit rules for chip count per lane, a falsifiable
chip-count check at the end, and a ban on rendering style
words (DASHED, BROKEN, GRAY) as visible text. Save the prompt
to .project/image-prompt/logical-architecture-v1.md.
```

**Step 2. Generate and review.** Run the prompt in Gemini Nano Banana. Save the result under `.project/image-prompt/`. Then have Claude view the rendered image, check it against the prompt's hard rules, and report what passed and what failed. Common failures include a lane that got merged into another, a chip that got dropped, a chip that got duplicated as floating text outside the chip border, a style-descriptor word that appeared on the canvas, or an arrow that intersected a chip it should have bypassed. Iterate the prompt with targeted patches that preserve the parts that worked and fix the part that failed. Keep iterating until the render is right; image-generation is stochastic and two or three rounds are normal.

**Example prompt for the review.**

```
Review the rendered image at .project/image-prompt/<file>.png
against the prompt at .project/image-prompt/<topic>-v<n>.md.
Walk through each hard rule and the chip-count check. Report
each item as pass or fail. If any item failed, propose the
smallest targeted patch to the prompt that fixes the failure
without disturbing the parts that already render correctly.
```

**Step 3. Install the image and update the doc.** When the render is clean, copy it into the canonical path the doc references (e.g. `images/<topic>.png`) and also into the image-edit base path (e.g. `.project/image-prompt/<topic>-reference.png`) so future image-edits start from this version instead of an older one. Then update the alt-text and any prose references in `docs/ARCHITECTURE.md` so they match the canvas exactly. If you renumbered arrows, changed chip layout, renamed a lane, or added a sub-label, every prose reference to those elements needs to update too. Commit the image, the prompt, and the doc together as one change so the artifacts stay in sync.

**Example prompt for the install.**

```
The render at .project/image-prompt/<file>.png is approved.
Install it as images/<topic>.png and as
.project/image-prompt/<topic>-reference.png. Update the
alt-text and prose references in docs/ARCHITECTURE.md so they
match the canvas (lane count, chip names, arrow numbers,
sub-labels). Commit and push the image, the prompt, and the
doc together with a CTO-persona message.
```

**Flows to.** Phase 4.3 (specialized layers) where they apply, and to Phase 5 (positioning) in parallel. Specialized layer docs benefit from the same three-step diagram process when they have their own visual surface (an AI use map, a data product flow, an infrastructure topology).

### 4.3 Specialized layers

**Why.** Most SaaS projects have one or two specialized concerns that deserve their own doc: AI posture if AI is meaningful to the product, a data product doc if you sell data, an infrastructure doc when you are ready to deploy. These are children of the architecture doc, not replacements for it.

**Artifacts.** `docs/AI_POSTURE.md`, `docs/DATA_PRODUCT.md`, `docs/INFRASTRUCTURE.md`, or whatever specialized layers your project demands.

**Example prompt.**

```
Draft docs/AI_POSTURE.md. The platform uses AI for <list use
cases>. Cover the AI orchestrator, model stack, output paths,
human gate, audit trail, signed envelope schema, model card
practice, bias audit cadence, and regulatory posture (EU AI
Act, applicable state laws). Walk every layer in plain language
for a non-engineer first, then drill into the technical detail.
```

**Flows to.** Phase 5 if not already started in parallel, then Phase 6.

## Phase 5. Product Positioning. How does it fit the world?

This phase often runs in parallel with Phase 4 because branding and architecture inform each other. Listed here for sequence completeness; in practice start the brand work as soon as the concept is approved.

### 5.1 Brand strategy

**Why.** Brand strategy decides what you stand for, who you compete with, and what positioning lines you will use in every customer conversation. Without it, the marketing copy contradicts the product story and the sales team improvises.

**Artifact.** `docs/BRAND_STRATEGY.md`.

**Example prompt.**

```
From docs/specs/YYYY-MM-DD-<topic>-design.md and any market
research notes, draft docs/BRAND_STRATEGY.md. Include the brand
thesis, the competitive landscape, the four to six load-bearing
differentiators (D1 through Dn), positioning lines against the
nearest competitor, brand voice rules, and a "what we will
never claim" section that protects credibility.
```

**Flows to.** 5.2 and 5.3.

### 5.2 Business plan

**Why.** The business plan converts the product story into a financial story. Market size, revenue model, pricing, cost structure, go-to-market timeline, fundraising posture if applicable. This is the doc an investor, a CFO, or a co-founder needs to see.

**Artifact.** `docs/BUSINESS_PLAN.md`.

**Example prompt.**

```
From docs/USE_CASES.md, docs/BRAND_STRATEGY.md, and any market
research notes, draft docs/BUSINESS_PLAN.md. Include
introduction, problem statement, proposed solution, market
opportunity (TAM, SAM, SOM), business model and revenue lines,
competitive advantage, go-to-market summary, financial
projections (placeholder if not yet modeled), risks, and
the ask if fundraising. Use the Brand persona for the narrative sections and the Finance persona for the financial projections.
```

**Flows to.** 5.3.

### 5.3 Go-to-market

**Why.** The business plan says what you will sell. The go-to-market plan says how you will reach buyers, what the sales motion looks like, what each phase of the rollout requires, and what success looks like at each phase.

**Artifact.** `docs/GO_TO_MARKET.md`.

**Example prompt.**

```
From docs/BUSINESS_PLAN.md and docs/BRAND_STRATEGY.md, draft
docs/GO_TO_MARKET.md. Describe the channel strategy, the
sales motion, the phased rollout (closed beta, general
availability, expansion), pricing positioning, partner
strategy, success metrics per phase, and the customer onboarding
flow. Use the Marketing persona, with Brand for positioning and Sales for the motion details.
```

**Flows to.** `DEVELOPMENT-BUILD.md`. By the end of Phase 5 you have a complete set of planning and positioning artifacts. `DEVELOPMENT-BUILD.md` picks up here and walks the implementation, testing, bug tracking, deployment, monitoring, and iteration phases.

## Common pitfalls and how to avoid them

- **Skipping Phase 1.** Tempting because it feels like setup. Skipping it produces docs in inconsistent voices that read badly when you go to share them.
- **Writing requirements before use cases.** Requirements without use cases are abstract and untestable. Use cases force you to walk through scenarios that surface missing requirements.
- **Mixing design and architecture.** Design is principles and why. Architecture is components and how. Mixing them produces a doc that is too abstract to build from and too detailed to read quickly.
- **Writing the business plan after the architecture is locked.** Pricing, channel choices, and partner strategy can change architectural requirements. Run brand and business work in parallel with the build plan so each informs the other.
- **Skipping the spec on a "small change."** Most "small changes" turn out to touch more docs than expected. A 100-line spec saved at the start of the change pays for itself in coherence by the end.
- **Jumping to DEVELOPMENT-BUILD.md without finishing Phase 5.** The implementation phase reads from the brand and business artifacts (a feature priority decision often hinges on go-to-market timing). Land Phase 5 first.

## Where to put the artifacts

| Artifact | Path |
|---|---|
| Design specs | `docs/specs/YYYY-MM-DD-<topic>-design.md` |
| Use cases | `docs/USE_CASES.md` |
| Requirements | `docs/REQUIREMENTS.md` |
| Design | `docs/DESIGN.md` |
| Architecture | `docs/ARCHITECTURE.md` |
| Brand strategy | `docs/BRAND_STRATEGY.md` |
| Business plan | `docs/BUSINESS_PLAN.md` |
| Go-to-market | `docs/GO_TO_MARKET.md` |
| AI posture (if applicable) | `docs/AI_POSTURE.md` |
| Data product (if applicable) | `docs/DATA_PRODUCT.md` |
| Infrastructure | `docs/INFRASTRUCTURE.md` |
| Skills inventory | `.project/playbook/reference/tools/SKILLS-INVENTORY.md` |
| Personas overview | `.project/playbook/reference/rules/TEAM-PERSONAS.md` |
| Persona templates | `.project/playbook/reference/personas/<ROLE>-PERSONA.md` |
| Project's working persona files | `.project/<ROLE>-PERSONA.md` |
| Design playbook (this file) | `.project/playbook/reference/rules/DESIGN-METHODOLOGY.md` |
| Build and ship | `.project/playbook/reference/rules/DEVELOPMENT-BUILD.md` |
| Business operations | `.project/playbook/reference/rules/BUSINESS-OPERATIONS.md` |
| Bootstrap script | `.project/playbook/START-PLAYBOOK.md` |
| Methodology entry point | `.project/playbook/README.md` |
| Lifecycle overview | `.project/playbook/docs/LIFECYCLE.md` |
| Operational notes | `.project/<topic>.md` |
| Implementation plans | `docs/plans/YYYY-MM-DD-<feature>-plan.md` (created during BUILD) |

The `docs/` tree is for shareable project artifacts. The `.project/` tree is for the operational files Claude needs to read freely (see `TEAM-PERSONAS.md` for the gitignore-the-`.project`-directory pattern).

## Next

Read `DEVELOPMENT-BUILD.md` for the implementation, testing, bug tracking, deployment, monitoring, and iteration phases that turn these artifacts into shipped code.
