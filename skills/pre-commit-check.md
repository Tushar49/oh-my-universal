# Workflow Spec: pre-commit-check

> Quality gate before committing. Runs review + verify + security checks.
> This is a WORKFLOW SPEC — it describes when and how to trigger skills.
> Actual enforcement requires CLI-specific adapters (see Phase 4).

## Trigger

Before committing significant changes (agent should proactively suggest this).

## Workflow

```
1. VERIFY    → Run skills/verify.md on changed files
2. REVIEW    → Run skills/review.md on the diff
3. SECURITY  → Run skills/security-review.md IF changes touch auth/input/deps
4. GATE      → Block commit if CRITICAL issues found
5. COMMIT    → Proceed if clean, or after user acknowledges warnings
```

### Gate Policy

| Review result | Action |
|--------------|--------|
| No issues | Commit freely |
| Warnings only | Commit with note, recommend fixing later |
| Critical issues | Show findings, recommend fixing before commit |
| Security critical | Strongly recommend fixing. Show exact vulnerability. |

**The agent should RECOMMEND, not BLOCK.** Only the user decides whether to commit.

### Adapter Notes (for Phase 4)

| CLI | How to implement |
|-----|-----------------|
| Copilot CLI | Agent proactively runs before suggesting commit |
| Claude Code | Hook: `tool.execute.before` on git commit |
| Codex | `.codex/hooks.json` pre-commit hook |
| Git native | `.git/hooks/pre-commit` script |
