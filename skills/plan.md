# Skill: plan

> Plan before implementing. Creates a structured plan, gets critique, then executes.
> Inspired by: oh-my-codex ($plan, $ralplan), planning-with-files, claude-workflow-v2

## When to Trigger

- User says "plan this", "let's plan", "how should we approach"
- Before any multi-file change (agent should proactively plan)
- Before refactoring, new features, or architecture changes

## Workflow

### Step 1 — Understand the Request

Read the user's request carefully. Identify:
- What needs to change (scope)
- What files are involved (blast radius)
- What could go wrong (risks)
- What depends on what (ordering)

### Step 2 — Create Plan

Write a structured plan with:

```markdown
## Plan: {task title}

### Problem
{1-2 sentence problem statement}

### Approach
{How you'll solve it - the strategy, not the steps}

### Changes
| # | File | Change | Why |
|---|------|--------|-----|
| 1 | path/to/file | What changes | Reason |

### Risks
- {risk 1} - mitigation: {how to handle}
- {risk 2} - mitigation: {how to handle}

### Order of Operations
1. {first thing to do}
2. {second thing}
3. {test/verify}

### NOT Changing
- {files/areas explicitly out of scope}
```

### Step 3 — Self-Critique (Rubber Duck)

Before executing, challenge your own plan:
- Did I miss any files that reference what I'm changing?
- Could this break existing tests?
- Is there a simpler approach?
- Am I over-engineering this?
- What would a code reviewer flag?

Revise the plan if the critique finds issues.

### Step 4 — Execute

Only after the plan is solid:
1. Implement changes in the planned order
2. After each file, verify it's consistent with the plan
3. If something unexpected comes up, STOP and revise the plan
4. Don't deviate from the plan without updating it first

### Step 5 — Verify

After implementation:
- Run tests if they exist
- Run linters if configured
- Verify the changes match the plan
- Note any deviations from the plan

## Rules

- NEVER skip planning for multi-file changes
- Plans should be BRIEF - no essays, just structure
- If the task is trivial (single file, < 10 lines), skip the plan
- The plan is a living document - update it as you learn more
- Share the plan with the user before executing (unless the user asked for autonomous execution)
- Not responsible for: verification (see verify skill), documentation updates (see doc-maintainer)
