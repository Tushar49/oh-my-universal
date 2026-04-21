# Skill: mission-runner

> Pick up and execute scoped missions from the `missions/` directory.
> Missions are self-contained work packages with goals, constraints, and success criteria.
> Uses other skills (plan, trace, build-fix, verify, etc.) to complete the mission.
> Inspired by: oh-my-codex (missions/)

## When to Trigger

- User says "run mission", "pick a mission", "what missions are available"
- User says "execute mission {name}", "start mission {name}"
- Agent identifies a mission that matches the current context

## Workflow

### Step 1 — List Available Missions

Scan `missions/` for subdirectories (skip `_template` and `README.md`).
Each valid mission has at minimum a `mission.md` file.

Present the list:

```
Available missions:
  1. security-hardening — Audit and harden security across the codebase
  2. test-coverage-boost — Increase test coverage for untested critical paths
  ...
```

If the user didn't specify which mission, ask them to pick one.
If the context makes it obvious (e.g., user just mentioned security), auto-select and confirm.

### Step 2 — Load Mission Spec

Read two files from `missions/{name}/`:

| File | Purpose | Required |
|------|---------|----------|
| `mission.md` | Goal, focus areas, success criteria | Yes |
| `sandbox.md` | Evaluation constraints, scope boundaries | No (but recommended) |

Extract:
- **Goal** — what the mission aims to achieve
- **Focus areas** — specific files, modules, or areas to target
- **Success criteria** — measurable pass/fail conditions (numbered list)
- **Constraints** — what NOT to do, scope boundaries
- **Evaluator command** — from sandbox.md frontmatter (if any)

### Step 3 — Plan the Mission

Use the `plan` skill to decompose the mission into concrete steps.

The plan MUST:
- Map each success criterion to at least one step
- Respect all constraints from sandbox.md
- Reference the focus areas from mission.md
- Include a verification step for each success criterion

### Step 4 — Execute

Work through the plan step by step, using appropriate skills:

| Situation | Skill to use |
|-----------|-------------|
| Need to understand existing code | `trace`, `deep-dive` |
| Need to fix build/test failures | `build-fix` |
| Writing new code | Follow the plan, use `tdd` if appropriate |
| Need to generate docs | `wiki` |
| Security-related work | `security-review` |
| Performance-related work | `perf-audit` |
| Need to verify progress | `verify` |

After each major step, check progress against the success criteria.

### Step 5 — Validate Against Success Criteria

After execution, evaluate EVERY success criterion from mission.md:

```
## Mission Report: {mission name}

| # | Success Criterion | Status | Evidence |
|---|-------------------|--------|----------|
| 1 | {criterion text} | PASS | {what proves it} |
| 2 | {criterion text} | FAIL | {what's missing} |
| 3 | {criterion text} | PASS | {what proves it} |

Overall: PASS (3/3) or PARTIAL (2/3) or FAIL (0/3)
```

If sandbox.md specifies an evaluator command, run it and include its output.

### Step 6 — Report

Present the mission report to the user with:
- Overall PASS/PARTIAL/FAIL status
- Per-criterion breakdown with evidence
- List of files changed
- Any deviations from the plan
- Recommendations for follow-up (if PARTIAL or FAIL)

## Rules

- ALWAYS read both mission.md and sandbox.md before starting
- NEVER violate constraints from sandbox.md — they are hard boundaries
- If a mission has no success criteria, ask the user to define them before starting
- If a mission is too large, suggest breaking it into sub-missions
- Report honestly — don't mark PASS unless you have evidence
- A mission is complete only when ALL success criteria pass
- If stuck on a criterion after 3 attempts, mark it FAIL with explanation

## Output Format

```markdown
## Mission Report: {mission name}

**Status:** PASS / PARTIAL / FAIL
**Success criteria:** {N}/{total} met

| # | Success Criterion | Status | Evidence |
|---|-------------------|--------|----------|
| 1 | {criterion text} | PASS | {what proves it} |
| 2 | {criterion text} | FAIL | {what's missing} |

### Files Changed
- {list of files modified}

### Deviations from Plan
- {any deviations}

### Follow-up Recommendations
- {if PARTIAL or FAIL, what to do next}
```

## Not Responsible For

- Creating new missions (user does that)
- Maintaining the missions directory
