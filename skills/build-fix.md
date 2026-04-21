# Skill: build-fix

> Auto-fix build, test, or lint failures. Read error output, identify root cause,
> apply fix, re-run. Max 3 attempts then escalate to user.
> Inspired by: oh-my-codex ($build-fix), oh-my-openagent (Hephaestus)

## When to Trigger

- Build, test, or lint command fails
- Agent should proactively use after any code change that might break the build
- User says "fix the build", "why is this failing", "fix tests"

## Workflow

### Step 1 — Capture Error

Run the failing command and capture FULL output:
- Build errors: compiler/transpiler output
- Test failures: test runner output with failing test names + stack traces
- Lint errors: linter output with file:line references

### Step 2 — Diagnose

Read the error output and classify:

| Error type | Pattern | Common fix |
|-----------|---------|-----------|
| Import/module not found | "Cannot find module", "ModuleNotFoundError" | Install dep or fix import path |
| Type error | "is not a function", "TypeError" | Fix type mismatch, check API |
| Syntax error | "Unexpected token", "SyntaxError" | Fix syntax at reported line |
| Test assertion | "Expected X, received Y" | Fix implementation or update test |
| Missing file | "ENOENT", "FileNotFoundError" | Create file or fix path |
| Permission | "EACCES", "PermissionError" | Fix permissions or run as appropriate user |
| Config | "Invalid configuration" | Fix config file syntax/values |

### Step 3 — Fix (Attempt 1)

1. Apply the most likely fix based on diagnosis
2. Re-run the exact same command
3. If it passes → DONE, report what was fixed

### Step 4 — Fix (Attempt 2, if needed)

1. Re-read the error (it may have changed)
2. Try a different approach
3. Re-run

### Step 5 — Fix (Attempt 3, if needed)

1. Re-read, try the last reasonable approach
2. Re-run

### Step 6 — Escalate (if still failing)

After 3 failed attempts:
```
## Build Fix: ESCALATED

**Command:** {what was run}
**Error:** {current error message}
**Attempts:**
1. {what was tried} — {result}
2. {what was tried} — {result}
3. {what was tried} — {result}

**Root cause hypothesis:** {best guess}
**Suggested next steps:** {what a human should investigate}
```

Stop and ask the user for guidance. Don't keep trying endlessly.

## Output Format (on success)

```
## Build Fix: RESOLVED

**Command:** {what was run}
**Error:** {original error}
**Fix:** {what was changed}
**Attempts:** {N}
**Verification:** {command} — PASS
```

## Rules

- Max 3 fix attempts, then escalate. No infinite loops.
- Fix the ACTUAL error, not symptoms. Read the full stack trace.
- After fixing, run the ORIGINAL command again (not a subset)
- Don't change tests to match broken code (fix the code instead)
- If fixing one thing breaks another, revert and reassess

## Not Responsible For

- Security issues (see security-review)
- Code quality beyond fixing the error (see review)
