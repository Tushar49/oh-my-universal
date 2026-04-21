# Skill: debug

> Hands-on debugging workflow — step through code, inspect state, find and fix bugs.
> Inspired by: oh-my-claudecode debug skill

## When to Trigger

- User says "debug this", "fix this bug", "why is this crashing", "step through"
- A test is failing and the user wants to find and fix the root cause
- An error message or stack trace is provided and needs investigation
- When the bug is reasonably localized and needs hands-on fixing (not hypothesis-driven analysis)

## Workflow

### Step 1 — Reproduce the Bug

Run the failing case and capture the exact error:

1. Identify the command, test, or action that triggers the bug
2. Run it and capture full output (error message, stack trace, exit code)
3. If the bug is intermittent, run it multiple times to confirm
4. Record the reproduction steps clearly

If the bug can't be reproduced, STOP and ask the user for more context.

### Step 2 — Inspect State at Failure Point

Read the error and trace it to the source:

1. Parse the stack trace — identify the file, line, and function where the error occurs
2. Read the relevant code around the failure point
3. Add temporary debug logging if needed (console.log, print, logger.debug)
4. Re-run with logging to see variable state at the failure point
5. Check inputs: what values are being passed? Are they what you expect?

### Step 3 — Narrow Down

Binary search through the code path to find where things go wrong:

1. Identify the entry point and the failure point
2. Add logging at the midpoint — is state correct there?
3. If correct at midpoint, the bug is between midpoint and failure point
4. If incorrect at midpoint, the bug is between entry point and midpoint
5. Repeat until you've isolated the exact line or condition

Shortcuts for common patterns:
- **Off-by-one:** Check loop bounds, array indices, string slicing
- **Null/undefined:** Check all optional values, function return values, API responses
- **Type mismatch:** Check type coercions, parseInt/parseFloat, JSON parsing
- **Race condition:** Check async/await usage, promise chains, shared state
- **Stale state:** Check caching, memoization, closures capturing old values

### Step 4 — Identify Root Cause

Once narrowed down, clearly state:

- **What:** The exact line or condition causing the bug
- **Why:** The underlying reason (wrong logic, missing check, bad assumption)
- **When:** Under what conditions it triggers (always, edge case, specific input)

### Step 5 — Fix and Verify

Apply the fix and confirm it works:

1. Make the minimal change that fixes the root cause
2. Re-run the original failing case — it must now pass
3. Run the full test suite — no regressions
4. Remove any temporary debug logging added in Step 2
5. If the bug revealed a gap in test coverage, add a test for it

## Output Format

```markdown
## Debug: {bug description}

### Reproduction
**Command:** `{command that triggers the bug}`
**Error:** `{error message or unexpected behavior}`
**Stack trace:** (if applicable)
```
{relevant stack trace lines}
```

### Investigation
1. Read `{file}:{line}` — {what was found}
2. Added logging at `{file}:{line}` — variable `{name}` = `{value}` (unexpected)
3. Narrowed to `{file}:{lines}` — {condition} is wrong because {reason}

### Root Cause
**File:** `{file}:{line}`
**Cause:** {clear explanation of the bug}
**Trigger:** {when/how it happens}

### Fix Applied
**Changed:** `{file}:{line}` — {description of change}
**Verification:**
- [x] Original failing case now passes
- [x] Full test suite passes ({N} tests)
- [x] Debug logging removed
- [ ] New test added for this case
```

## Rules

- ALWAYS reproduce the bug before attempting to fix it. No fix without reproduction.
- Read the actual error message and stack trace carefully. Don't guess — trace.
- Make the MINIMAL fix. Don't refactor unrelated code while debugging.
- Remove ALL temporary debug logging before declaring the fix complete.
- If you add a fix but tests still fail, you haven't found the real root cause. Go back to Step 3.
- If the bug reveals a missing test, add one. Future regressions should be caught.
- If you can't reproduce or can't find the cause after reasonable effort, say so. Don't invent a fix.

## Not Responsible For

- Hypothesis-driven root cause analysis without hands-on fixing (use trace)
- Performance issues that aren't bugs (use perf-audit)
- Security vulnerabilities (use security-review)
- Refactoring code that works but is messy (use refactor)
- Build or dependency errors (use build-fix or doctor)
