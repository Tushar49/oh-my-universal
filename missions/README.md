# Missions

> Scoped task specifications that AI agents pick up and execute autonomously.

## What is a Mission?

A mission is a self-contained work package — the **WHAT** that needs to be done.
Skills are the **HOW** — reusable patterns agents use to complete missions.

Each mission lives in its own directory under `missions/` and contains:

| File | Purpose | Required |
|------|---------|----------|
| `mission.md` | Goal, focus areas, success criteria | Yes |
| `sandbox.md` | Evaluation constraints, scope boundaries | Recommended |

## Missions vs Skills

| | Missions | Skills |
|---|---------|--------|
| **Nature** | Specific tasks with an end state | Reusable patterns with no end state |
| **Scope** | Scoped to a project or problem | Generic across any project |
| **Completion** | Done when success criteria pass | Always available |
| **Location** | `missions/{name}/` | `skills/{name}.md` |
| **Contains** | Goals, criteria, constraints | Workflows, triggers, rules |
| **Example** | "Increase test coverage by 15%" | "How to write and run tests" |

An agent uses skills like `plan`, `build-fix`, `verify`, and `security-review`
to complete missions like `security-hardening` or `test-coverage-boost`.

## Directory Structure

```
missions/
  _template/          # Copy this to create a new mission
    mission.md        # Goal + success criteria template
    sandbox.md        # Evaluation constraints template
  security-hardening/
    mission.md
    sandbox.md
  test-coverage-boost/
    mission.md
    sandbox.md
  ...
```

## Creating a Mission

1. Copy `_template/` to a new directory: `cp -r missions/_template missions/my-mission`
2. Edit `mission.md` — define the goal, focus areas, and success criteria
3. Edit `sandbox.md` — define evaluation constraints and scope boundaries
4. Run: "pick a mission" or "run mission my-mission"

### Writing Good Success Criteria

Success criteria should be:
- **Measurable** — a tool or command can verify them
- **Specific** — no ambiguity about what "done" means
- **Independent** — each criterion can pass or fail on its own

Good: "All tests pass with `npm test`"
Bad: "Code quality is improved"

Good: "No high/critical CVEs in `npm audit`"
Bad: "Dependencies are secure"

### Writing Good Sandbox Constraints

Sandbox constraints are hard boundaries the agent MUST NOT cross:
- Files or directories that should not be modified
- Behaviors to avoid (e.g., "do not change the public API")
- Scope limits (e.g., "focus only on the auth module")

The optional `evaluator` frontmatter in sandbox.md specifies a command
the agent runs to validate the mission programmatically.

## Sandboxes

Every mission has an optional `sandbox.md` that defines the **evaluation contract** — how the
mission outcome is tested and what scope the agent is allowed to touch.

Sandboxes use YAML frontmatter to specify an evaluator command, output format, and keep policy.
The markdown body lists allowed changes and avoid constraints.

```yaml
---
evaluator:
  command: npm test -- --grep "auth"
  format: json
  keep_policy: pass_only
---
```

See [docs/SANDBOX_SPEC.md](../docs/SANDBOX_SPEC.md) for the full specification including
field reference, keep policies, and evaluation output format.

## How Agents Execute Missions

Agents use the `mission-runner` skill:

1. **List** — scan `missions/` for available missions
2. **Load** — read `mission.md` for goals + `sandbox.md` for constraints
3. **Plan** — decompose into steps using the `plan` skill
4. **Execute** — work through steps using appropriate skills
5. **Validate** — check every success criterion, produce PASS/FAIL report
6. **Report** — present results with evidence

See `skills/mission-runner.md` for the full workflow.

## Example Missions

| Mission | Description |
|---------|-------------|
| `security-hardening` | Audit and harden security across the codebase |
| `test-coverage-boost` | Increase test coverage for untested critical paths |
| `performance-baseline` | Establish performance baselines and fix bottlenecks |
| `docs-from-scratch` | Generate comprehensive documentation from scratch |
| `dependency-cleanup` | Audit and clean up project dependencies |
