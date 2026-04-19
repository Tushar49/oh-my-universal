# Skill: ultrawork

> Full task lifecycle: plan -> implement -> verify -> review -> commit.
> The "do everything right" workflow.
> Inspired by: oh-my-codex ($ultrawork), oh-my-claudecode (ultrawork)

## When to Trigger

- User says "ultrawork", "do this properly", "full workflow"
- For any significant task that warrants the full treatment

## Workflow

```
1. PLAN        → Create structured plan (follow skills/plan.md workflow, or invoke the named skill if the platform supports it)
2. IMPLEMENT   → Execute the plan, file by file
3. VERIFY      → Run tests, linters, type-checkers (follow skills/verify.md workflow, or invoke the named skill if the platform supports it)
4. REVIEW      → Self-review changes (follow skills/review.md workflow, or invoke the named skill if the platform supports it)
5. DOCUMENT    → Update relevant docs (follow skills/doc-maintainer.md workflow, or invoke the named skill if the platform supports it)
6. COMMIT      → Suggest committing in logical batches with good messages
```

### Step 1 — Plan
Follow the workflow in skills/plan.md (or invoke the named skill if the platform supports it). Create a structured plan, self-critique it,
and share with the user for approval (unless the user asked for autonomous execution).

### Step 2 — Implement
Execute the plan in order. For each file:
- Make the change
- Verify it's consistent with the plan
- If a surprise comes up, pause and revise the plan

### Step 3 — Verify
Run the project's test/lint/build commands:
- Test suite (project's test command)
- Linter (project's lint command)
- Build (project's build command)
- Type checking if available
- If nothing exists, do a manual sanity check

### Step 4 — Review
Follow the workflow in skills/review.md (or invoke the named skill if the platform supports it) on your own changes.
Fix any issues found before proceeding.

### Step 5 — Document
Follow the workflow in skills/doc-maintainer.md (or invoke the named skill if the platform supports it) to update any docs affected by the changes.
This includes README, API docs, changelogs, progress trackers.

### Step 6 — Commit
Suggest committing. Only commit if user approves or repo workflow permits autonomous commits.
- Group related changes together
- Write descriptive commit messages (not "fix stuff")
- Use conventional commits format: feat/fix/refactor/docs/chore

## Rules

- If ANY step fails, stop and report. Don't push through broken code.
- The user can skip steps explicitly ("skip the review")
- For trivial tasks, suggest using plan+implement only (skip verify/review/doc)
- Always report what was done at the end
- When user invokes ultrawork, do NOT separately invoke plan — ultrawork includes planning. Plan skill is for standalone planning only.
