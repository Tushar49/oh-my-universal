# Skill: dirty-guard

> Block dangerous git operations when the worktree has uncommitted changes.
> Inspired by: oh-my-codex (resume-dirty-guard pattern)

## When to Trigger

- Before any destructive git operation: reset, checkout, clean, force-push, branch delete
- Before agent resume/rebase that could overwrite local changes
- Proactively at session start if a dirty worktree is detected
- Automatically before: resume, checkout, reset, rebase operations

## Workflow

### Step 1 — Detect dirty state

Run `git status --porcelain`. If output is non-empty, the worktree is dirty.

Classify changes:
- `M` — modified tracked files (highest risk)
- `A` — staged but uncommitted (high risk)
- `??` — untracked files (lower risk, but still worth flagging)
- `D` — deleted files (medium risk)

### Step 2 — Classify the requested operation

| Operation | Risk | Default |
|-----------|------|---------|
| `git reset --hard` | DESTRUCTIVE | BLOCK |
| `git checkout -- .` | DESTRUCTIVE | BLOCK |
| `git clean -fd` | DESTRUCTIVE | BLOCK |
| `git push --force` | DESTRUCTIVE | BLOCK |
| `git branch -D` | DESTRUCTIVE | BLOCK |
| `git rebase` | RISKY | WARN |
| `git stash drop` | RISKY | WARN |
| `git commit` | SAFE | ALLOW |
| `git push` | SAFE | ALLOW |
| `git pull` | SAFE | ALLOW |

### Step 3 — Block or warn

If the operation is DESTRUCTIVE and the worktree is dirty, BLOCK and show the guard message.
If the operation is RISKY, WARN but allow the user to proceed.
SAFE operations are never blocked.

### Step 4 — Offer recovery options

Always present clear options for how to proceed.

## Output Format

```
⚠️ DIRTY GUARD: Blocked `{operation}`

Uncommitted changes:
  M  src/auth.ts
  A  src/new-file.ts
  ?? temp/debug.log

Options:
  1. Commit first   → git add . && git commit -m "wip: save progress"
  2. Stash changes   → git stash push -m "before {operation}"
  3. Discard changes → git checkout -- . (you will lose uncommitted work)
  4. Force override  → say "force {operation}" or pass --force to proceed

Recommended: Option 1 or 2 to preserve your work.
```

## Rules

- ALWAYS check `git status --porcelain` before destructive operations — no exceptions
- NEVER silently discard uncommitted work
- User can override with explicit `--force` flag or saying "force {operation}"
- After override, log that the guard was bypassed (include in session memory)
- Untracked files (`??`) alone should WARN, not BLOCK — they are lower risk
- If ALL dirty files are in `.gitignore`-eligible paths (build output, node_modules), downgrade to WARN
- This skill is a behavioral instruction — agents should internalize it, not wait for explicit invocation

## Not Responsible For

- Preventing bad commits (see pre-commit-check skill)
- Branch protection or PR policies (those are server-side)
- Backup or recovery of lost work (that's git reflog territory)
- Deciding WHAT to commit — only protecting uncommitted work from destruction
