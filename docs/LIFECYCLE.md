# The lifecycle in eight stages

The path every project follows:

**concept → requirements → design → architecture → planning → build → ship → iterate**

Stages 1 and 2 run once per project. Stages 3 to 5 are mostly once per project but get revisited as the product grows. Stages 6, 7, 8 are continuous. Stages run in parallel where they do not block each other, and earlier stages get revisited when reality teaches you something new. **Positioning** (brand strategy, business plan, go-to-market) runs as a parallel track alongside engineering, not as a step in the main flow.

<table>
  <thead>
    <tr>
      <th width="18%">Stage</th>
      <th width="32%">What happens</th>
      <th width="18%">Lead</th>
      <th width="32%">Artifact</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>1. Concept</td>
      <td>Brainstorm a vague idea into a structured spec</td>
      <td>architect</td>
      <td><code>docs/specs/&lt;topic&gt;-design.md</code></td>
    </tr>
    <tr>
      <td>2. Requirements</td>
      <td>Spec to use cases to testable requirements</td>
      <td>end-user, architect</td>
      <td><code>docs/USE_CASES.md</code>, <code>docs/REQUIREMENTS.md</code></td>
    </tr>
    <tr>
      <td>3. Design</td>
      <td>The design doc: principles, user experience, the UI system</td>
      <td>architect, designer</td>
      <td><code>docs/DESIGN.md</code></td>
    </tr>
    <tr>
      <td>4. Architecture</td>
      <td>Technical architecture, load-bearing decisions, diagrams</td>
      <td>architect</td>
      <td><code>docs/ARCHITECTURE.md</code>, ADRs, diagrams</td>
    </tr>
    <tr>
      <td>5. Planning</td>
      <td>Turn the architecture into an ordered implementation plan</td>
      <td>developer</td>
      <td>Implementation plan</td>
    </tr>
    <tr>
      <td>6. Build</td>
      <td>Code, tests, review</td>
      <td>developer, qa-engineer</td>
      <td>Working code, tests passing in CI</td>
    </tr>
    <tr>
      <td>7. Ship</td>
      <td>Staging, production, monitoring, incidents</td>
      <td>developer, support</td>
      <td>Code running in production</td>
    </tr>
    <tr>
      <td>8. Iterate</td>
      <td>Real-world learning fed back through earlier stages</td>
      <td>persona owning the area</td>
      <td>Updated docs</td>
    </tr>
  </tbody>
</table>

Two things sit outside the eight stages on purpose.

- **Foundation comes first, once.** Before Stage 1, you and Claude run the bootstrap in `../START-PLAYBOOK.md`: install the tools and the agents, tailor the personas, and lay down the security baseline. It produces `.claude/CLAUDE.md`, the customized personas, the knowledge folder, and `.claude/SECURITY-POSTURE.md`. It is setup, not a stage of the product.
- **Positioning runs alongside.** Brand strategy, the business plan, and go-to-market are led by brand, marketing, and the founder, and produce `docs/BRAND_STRATEGY.md`, `docs/BUSINESS_PLAN.md`, and `docs/GO_TO_MARKET.md`. The work starts once the concept is clear and continues through build. It informs the stages without blocking them.

Each stage has a named artifact and example prompts you can paste into your agent at every step. The requirements stage produces the pre-development blueprint detailed in `../reference/rules/PRE-DEVELOPMENT-BLUEPRINT.md` (strategy, use cases, functional and non-functional rules, UX wireframes, technical architecture, constraints, and the delivery plan).

Stage detail lives in `../reference/rules/DESIGN-METHODOLOGY.md` (Stages 1 to 4, and the positioning track), `../reference/rules/DEVELOPMENT-BUILD.md` (Stages 5 to 8), and `../START-PLAYBOOK.md` (Foundation).

For the continuous stages (Ship and Iterate), once a test suite or benchmark can vouch for "done", the team can hand recurring work — keeping CI green, dependency upgrades, issue-inbox triage — to an autonomous loop that runs unattended and stops on its own. The discipline and the when-it-fits test are in `../reference/rules/LOOP-ENGINEERING.md`; the `loop-engineering` skill (universal core) does the interview-and-scaffold.
