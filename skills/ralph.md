# Skill: ralph

> Persistent verify-and-fix loop until task is fully complete. Keep trying until it works.
> Inspired by: oh-my-claudecode (ralph agent), oh-my-codex ($ralph)

## When to Trigger

- User says "ralph this", "keep trying until it works", "don't stop until tests pass", "fix loop"
- When a task needs repeated attempt-verify-fix cycles to reach completion
- When you've implemented something and need to hammer it until all checks pass
- When build-fix's 3 attempts aren't enough — ralph is the unlimited persistence mode

## Workflow

### Step 1 — Initialize

Set up the loop:
- **Goal:** What does "done" look like? (all tests pass, build succeeds, lint clean, etc.)
- **Verification commands:** The exact commands to run (e.g., `npm test`, `npm run build`, `npm run lint`)
- **Max iterations:** Default 10, can be overridden by user
- **Escalation ladder:** Plan how approach changes with iteration count

### Step 2 — Implement

Make the initial implementation or change. If already implemented, skip to Step 3.

### Step 3 — Verify

Run ALL verification commands. Capture full output.

- If all pass → **done**, go to Step 6
- If any fail → record failures, go to Step 4

### Step 4 — Analyze and Fix

Apply the escalation ladder based on current iteration:

**Iterations 1-3 — Simple Fixes:**
- Read the error message carefully
- Apply the most obvious fix
- One change at a time, re-verify after each

**Iterations 4-6 — Deeper Analysis:**
- Re-read surrounding code for context
- Check if the fix approach is fundamentally wrong
- Consider refactoring the solution, not just patching errors
- Look for patterns in repeated failures

**Iterations 7-10 — Alternative Approach:**
- Step back and reconsider the entire approach
- Search for examples of similar solutions in the codebase
- Try a different implementation strategy
- If stuck, document what was tried and why it failed

### Step 5 — Re-verify

Go back to Step 3. Repeat until all checks pass or max iterations reached.

### Step 6 — Report

Produce the final report with iteration history.

## Output Format

```markdown
## Ralph Report: {task description}

### Goal
{what "done" looks like}

### Verification Commands
- `{command 1}`
- `{command 2}`

### Iteration Log
| # | Action Taken | Result | Errors Remaining |
|---|-------------|--------|-----------------|
| 1 | {initial implementation} | FAIL | 5 errors |
| 2 | {fixed missing import} | FAIL | 3 errors |
| 3 | {fixed type mismatch} | FAIL | 1 error |
| 4 | {refactored return type} | PASS | 0 |

### Summary
- **Status:** PASS / FAIL (max iterations reached)
- **Iterations:** {n} of {max}
- **Errors fixed:** {count}
- **Time spent:** {duration}
- **Escalation level reached:** Simple / Deeper / Alternative

### Remaining Issues (if FAIL)
- {issue 1 — why it resists fixing}
- {issue 2 — what was tried}
```

## Rules

- ALWAYS verify after EVERY fix. Never batch multiple fixes without re-running checks.
- Track every iteration — what was changed, what the result was.
- Follow the escalation ladder. Don't jump to alternative approaches on iteration 2.
- If the same error reappears after being fixed, that's a signal to escalate immediately.
- Don't fix tests to make them pass — fix the implementation to satisfy the tests.
- If max iterations reached without success, report honestly. Don't claim partial success as done.
- One logical fix per iteration. Don't shotgun multiple changes hoping something sticks.

## Not Responsible For

- Deciding WHAT to implement (use plan or ultrawork for that)
- Debugging root causes without a clear goal (use trace for that)
- One-shot verification without fix loops (use verify for that)
- Build-only failures with simple fixes (use build-fix for quick 3-attempt cycles)
