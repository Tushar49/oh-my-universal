# Skill: multi-model-review

> Use a different perspective for code review by explicitly asking the agent
> to "think like a different reviewer" — mimicking multi-model review benefits.
> Inspired by: everything-claude-code, levnikolaevich/claude-code-skills

## When to Trigger

- For critical changes (auth, payments, data migration)
- User says "thorough review", "multi-perspective review"
- Before deploying to production
- When a standard review didn't feel sufficient

## Workflow

Since we can't switch models mid-session in most CLIs, we simulate multi-model
review by doing multiple review passes with DIFFERENT PERSPECTIVES:

### Pass 1 — "The Bug Hunter"
Review the code looking ONLY for bugs:
- Logic errors, off-by-one, null dereference
- Race conditions, deadlocks
- Error handling gaps
- State management issues

### Pass 2 — "The Security Auditor"
Review looking ONLY for security:
- Invoke `skills/security-review.md` workflow
- Focus on the changed code's attack surface
- Trust boundary crossings

### Pass 3 — "The Maintainer" (3 months from now)
Review as if you're seeing this code for the first time in 3 months:
- Is the intent clear without context?
- Are there any "wtf" moments?
- Would a new team member understand this?
- Are there comments where the code should be clearer instead?

### Pass 4 — "The Performance Engineer"
Review looking ONLY for performance:
- Are there O(n^2) patterns?
- N+1 queries?
- Memory leaks?
- Unnecessary computation?

## Output Format

```markdown
## Multi-Perspective Review: {scope}

### Pass 1: Bug Hunter
{findings or "No bugs found"}

### Pass 2: Security Auditor
{findings or "No security issues"}

### Pass 3: Maintainer
{findings or "Code is clear"}

### Pass 4: Performance Engineer
{findings or "No performance concerns"}

### Combined Verdict
**Risk Level:** LOW / MEDIUM / HIGH
**Findings:** {total count}
**Recommendation:** {ship / fix then ship / needs rework}
```

## Rules

- Each pass looks at the SAME code but through a DIFFERENT lens
- Don't repeat findings across passes (each perspective covers unique ground)
- If a pass finds nothing, say so — don't invent problems
- This is more thorough than `review.md` — use for critical changes only

## Not Responsible For

- Test coverage (see tdd)
- Implementation (see ultrawork)
