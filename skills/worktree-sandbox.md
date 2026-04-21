# Skill: worktree-sandbox

> Git worktree-based parallel agent isolation. Each agent works in its own branch and directory — no merge conflicts.
> Inspired by: awesome-claude-code /create-worktrees, viwo-cli patterns

## When to Trigger

- User says "work in parallel", "try both approaches", "isolate this work", "create worktree"
- When delegating subtasks to parallel subagents via team skill
- When comparing two different implementation approaches (A/B)
- When experimenting with risky changes that shouldn't touch the main branch

## Workflow

### Step 1 — Plan Worktrees

Determine what worktrees are needed:

```markdown
## Worktree Plan: {task description}

| # | Branch Name | Directory | Purpose | Agent |
|---|-------------|-----------|---------|-------|
| 1 | {task}-approach-a | .worktrees/{task}-a | {description} | subagent-1 |
| 2 | {task}-approach-b | .worktrees/{task}-b | {description} | subagent-2 |
```

**Naming conventions:**
- Branch: `wt/{task-slug}-{variant}` (e.g., `wt/auth-refactor-a`)
- Directory: `.worktrees/{task-slug}-{variant}`

### Step 2 — Create Worktrees

For each planned worktree:

```bash
# Create branch and worktree from current HEAD
git worktree add .worktrees/{name} -b wt/{branch-name}
```

Verify each worktree is ready:
- Directory exists and contains the project
- Branch is created and checked out
- Working tree is clean

### Step 3 — Delegate Work

When integrating with the team skill:
1. Each subagent receives: worktree path, branch name, task description, constraints
2. Subagent MUST work exclusively within its worktree directory
3. Subagent commits to its own branch (not main)
4. Subagent reports results when complete

When working manually (no subagents):
1. Switch to a worktree: `cd .worktrees/{name}`
2. Make changes, commit to the worktree branch
3. Return to main: `cd {original-dir}`
4. Repeat for other worktrees

### Step 4 — Merge Results

After all worktrees complete:

**For parallel features (all merge):**
```bash
# From main branch
git merge wt/{branch-1} --no-ff -m "merge: {description}"
git merge wt/{branch-2} --no-ff -m "merge: {description}"
```

**For A/B comparison (pick winner):**
1. Review both approaches — compare code quality, test results, performance
2. Present comparison to user with recommendation
3. Merge the chosen approach, discard the other
4. Document why the winner was chosen

**Conflict resolution:**
- If merge conflicts occur, present them to the user
- Show the conflicting changes side by side
- Let the user decide resolution

### Step 5 — Cleanup

After merge (or on abort):

```bash
# Remove worktree and delete branch
git worktree remove .worktrees/{name}
git branch -d wt/{branch-name}
```

Remove all worktrees for a task:
```bash
git worktree list | grep ".worktrees/{task}" | while read dir _; do
  git worktree remove "$dir" --force
done
```

## Output Format

```markdown
## Worktree Status: {task}

**Active worktrees:** {N}
**Status:** WORKING / READY_TO_MERGE / MERGED / ABORTED

| # | Worktree | Branch | Status | Commits | Summary |
|---|----------|--------|--------|---------|---------|
| 1 | .worktrees/{name} | wt/{branch} | done | 3 | {summary} |
| 2 | .worktrees/{name} | wt/{branch} | in-progress | 1 | {summary} |

### Merge Plan
- {which branches merge and in what order}
- {conflict risk assessment}

### Comparison (A/B mode)
| Criterion | Approach A | Approach B | Winner |
|-----------|-----------|-----------|--------|
| {criterion} | {detail} | {detail} | A / B |
```

## Rules

- ALWAYS create worktrees from the current HEAD. Never from stale branches.
- Worktree directories MUST be under `.worktrees/` (add to `.gitignore` if not already).
- Each worktree gets its own branch — NEVER share branches between worktrees.
- Max 5 worktrees at a time (resource limits). Clean up before creating more.
- ALWAYS clean up worktrees after merge or abort. Orphaned worktrees waste disk space.
- If a merge has conflicts, STOP and present them to the user. Never auto-resolve.
- Subagents MUST NOT modify files outside their worktree directory.
- The parent agent is responsible for merge — subagents only commit to their branch.

## Not Responsible For

- Task decomposition (use team skill for breaking work into subtasks)
- Code review of merged results (use review skill)
- Process-level isolation (use container-sandbox for full sandboxing)
- Branch strategy or release management (use release skill)
