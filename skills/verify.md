# Skill: verify

> Verify that a change actually works. Runs tests, build, type-checks,
> and manual sanity checks. Produces evidence-based pass/fail report.
> Inspired by: oh-my-claudecode (verify), oh-my-codex ($ultraqa)

## When to Use

- After implementing a change (agent should proactively verify)
- User says "verify", "does this work?", "test this"
- As part of ultrawork workflow (Step 3)
- Before committing significant changes

## Verification Steps

### Step 1 — Automated Checks
Run whatever the project has:
- Test suite (project's test command)
- Build (project's build command)
- Linter (project's lint command)
- Type checker (if configured)

If none exist, note "No automated checks configured" and proceed to manual.

### Step 2 — Manual Sanity Check
For each file changed:
- Does the change match the stated intent?
- Are there obvious errors (syntax, imports, typos)?
- Does the change break any existing behavior?

### Step 3 — Evidence Report
```
## Verification Report

**Change:** {what was changed}
**Result:** PASS / FAIL / PARTIAL

### Automated
| Check | Result | Details |
|-------|--------|---------|
| Tests | ✓ pass / ✗ fail | {N} passed, {N} failed |
| Build | ✓ pass / ✗ fail | {output} |
| Lint | ✓ pass / ✗ fail | {N} warnings |

### Manual
- {observation 1}
- {observation 2}

### Verdict
{1-2 sentence summary: safe to commit or needs fixes}
```

## Rules

- Report facts, not opinions. "Tests pass" not "looks good to me"
- If automated checks fail, show the actual error output
- If no automated checks exist, be MORE thorough with manual review
- Don't skip verification just because the change "looks simple"
- Not responsible for: planning (see plan skill), code review beyond the current change (see review skill)
