# Skill: review

> Auto code review. Reviews staged/unstaged changes with extremely high signal.
> Only surfaces genuine bugs, security issues, and logic errors.
> Inspired by: oh-my-codex ($code-review), oh-my-openagent (Momus), claude-forge

## When to Trigger

- User says "review", "check my changes", "look at this code"
- Before committing significant changes (auto-trigger suggestion)
- After implementing a plan (as verification step)

## Workflow

### Inputs
- Staged changes: `git diff --cached`
- Unstaged changes: `git diff`
- Branch diff: `git diff <default-branch>..HEAD` (use the repo's default branch — main, master, etc.)
- Specific files: user-specified paths

### Review Dimensions

**1. Correctness**
- Does the code do what it claims?
- Are there off-by-one errors, null checks, race conditions?
- Are edge cases handled?

**2. Security**
- Hardcoded secrets or credentials?
- SQL injection, XSS, path traversal?
- Unsafe deserialization or eval?
- Permissions/auth bypass?

**3. Logic Errors**
- Incorrect conditionals or comparisons?
- Wrong variable used?
- Missing error handling?
- Infinite loops or unbounded recursion?

**4. Breaking Changes**
- Does this change break existing callers?
- Are API contracts preserved?
- Are config files still compatible?

### What NOT to Review
- Style, formatting, naming preferences (linters handle this)
- "I would have done it differently" opinions
- Trivial changes (typos, comments, whitespace)
- Things that are clearly intentional design choices

## Output Format

```markdown
## Code Review: {summary}

**Risk Level:** LOW / MEDIUM / HIGH / CRITICAL
**Files reviewed:** {count}

### Issues Found

#### 🔴 CRITICAL: {title}
**File:** `path/to/file:line`
**Issue:** {what's wrong}
**Fix:** {how to fix it}

#### 🟡 WARNING: {title}
**File:** `path/to/file:line`
**Issue:** {what's wrong}
**Suggestion:** {recommendation}

### ✅ Looks Good
- {positive observation about the change}
```

## Rules

- If NO issues found, say "Looks good" and move on. Don't invent problems.
- Maximum 5 findings per review. If more, prioritize by severity.
- Every finding must be actionable (include a fix, not just a complaint)
- NEVER comment on style or formatting
- Be specific: cite exact file:line, show the problematic code

## Not Responsible For

- Planning (see plan skill)
- Documentation (see doc-maintainer)
