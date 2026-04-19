# Skill: verify

> Verify that a change actually works. Runs tests, build, type-checks,
> and manual sanity checks. Produces evidence-based pass/fail report.
> Supports diff-aware mode: verify only files/areas that actually changed.
> Inspired by: oh-my-claudecode (verify), oh-my-codex ($ultraqa), claude-workflow-v2

## When to Use

- After implementing a change (agent should proactively verify)
- User says "verify", "does this work?", "test this"
- As part of ultrawork workflow (Step 3)
- Before committing significant changes

## Modes

### Full Verify (default)
Runs all automated checks + manual review on the entire project.
Use for: first-time verify, after major changes, before releases.

### Diff-Aware Verify (`--diff` or "verify my changes")
Only verifies files and areas that actually changed. Faster, more focused.
Use for: incremental changes, quick checks, pre-commit.

**How diff-aware works:**
1. Get changed files: `git diff --name-only` (unstaged) or `git diff --cached --name-only` (staged)
2. For each changed file:
   - Run file-specific tests if the project has them (e.g., `npm test -- --testPathPattern={file}`)
   - Run linter on just that file
   - Manual review on just the diff hunks
3. Skip unchanged files entirely
4. Still run the full build (builds are all-or-nothing)

## Verification Steps

### Step 1 — Automated Checks
Run whatever the project has:
- Test suite (project's test command, or file-scoped tests in diff-aware mode)
- Build (project's build command — always full, not file-scoped)
- Linter (project's lint command, or file-scoped in diff-aware mode)
- Type checker (if configured)

If none exist, note "No automated checks configured" and proceed to manual.

### Step 2 — Manual Sanity Check

**Full mode:** Review all files in scope.
**Diff-aware mode:** Review only the diff hunks:
- For each changed hunk: does the change match the stated intent?
- Are there obvious errors (syntax, imports, typos)?
- Does the change break any existing behavior?
- Are there adjacent lines that SHOULD have changed but didn't?

### Step 3 — Evidence Report
```
## Verification Report

**Change:** {what was changed}
**Mode:** full / diff-aware ({N} files checked)
**Result:** PASS / FAIL / PARTIAL

### Automated
| Check | Result | Details |
|-------|--------|---------|
| Tests | ✓ pass / ✗ fail | {N} passed, {N} failed |
| Build | ✓ pass / ✗ fail | {output} |
| Lint | ✓ pass / ✗ fail | {N} warnings |

### Manual ({N} files reviewed)
- {file}: {observation}
- {file}: {observation}

### Verdict
{1-2 sentence summary: safe to commit or needs fixes}
```

## Rules

- Report facts, not opinions. "Tests pass" not "looks good to me"
- If automated checks fail, show the actual error output
- If no automated checks exist, be MORE thorough with manual review
- Don't skip verification just because the change "looks simple"
- In diff-aware mode, still run the full build — partial builds lie
- Not responsible for: planning (see plan skill), code review beyond the current change (see review skill)
