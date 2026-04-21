# Skill: git-master

> Git workflow management — branches, PRs, merges, conflict resolution, and history cleanup.
> Inspired by: oh-my-codex git-master skill

## When to Trigger

- User says "manage branches", "create PR", "resolve conflicts", "clean up git history"
- User asks about branching strategy, merge vs rebase, or git workflows
- A merge conflict needs resolution
- Git history needs cleanup (squash, rebase, amend)
- User needs help with PR creation, review, or merge strategy

## Workflow

### Step 1 — Assess the Situation

Understand the current git state:

1. Check current branch, clean/dirty status, ahead/behind remote
2. List recent branches and their relationship to main/master
3. Identify any pending merges, rebases, or conflicts
4. Determine the team's workflow (GitHub Flow, GitFlow, Trunk-Based)

### Step 2 — Branch Management

**Creating branches:**
- Use descriptive names: `feat/{ticket}-{short-desc}`, `fix/{ticket}-{short-desc}`, `chore/{desc}`
- Branch from the correct base (main for features, release branch for hotfixes)
- Set upstream tracking: `git push -u origin {branch}`

**Naming conventions:**
| Prefix | Purpose | Example |
|--------|---------|---------|
| `feat/` | New feature | `feat/user-auth` |
| `fix/` | Bug fix | `fix/login-crash` |
| `chore/` | Maintenance | `chore/update-deps` |
| `docs/` | Documentation | `docs/api-reference` |
| `refactor/` | Code restructure | `refactor/auth-module` |

### Step 3 — PR Workflow

**Creating a PR:**
1. Ensure branch is up to date with base: `git fetch origin && git rebase origin/main`
2. Push the branch: `git push -u origin {branch}`
3. Create PR with: title, description, linked issues, reviewers
4. PR description template:
   - **What:** One-line summary of the change
   - **Why:** Problem being solved or feature being added
   - **How:** Brief technical approach
   - **Testing:** What was tested and how
   - **Screenshots:** If UI changes

**Review checklist:**
- [ ] Code compiles and tests pass
- [ ] No unrelated changes included
- [ ] Commit messages are clear
- [ ] Documentation updated if needed
- [ ] No secrets or sensitive data committed

**Merge strategy:**
- **Squash merge** — for feature branches with messy history (default recommendation)
- **Merge commit** — for long-lived branches where individual commits matter
- **Rebase merge** — for clean linear history (only if team agrees)

### Step 4 — Conflict Resolution

When merge conflicts are detected:

1. Identify conflicting files: `git diff --name-only --diff-filter=U`
2. For each conflicting file:
   - Show both sides of the conflict clearly
   - Explain what each side changed and why
   - Suggest a resolution based on the intent of both changes
3. Apply the resolution
4. Run tests after resolving to ensure nothing broke
5. Complete the merge/rebase

### Step 5 — History Management

**Interactive rebase** (cleaning up before PR):
1. `git rebase -i HEAD~{N}` — identify commits to squash, edit, or reorder
2. Squash fixup commits into their parent
3. Reword unclear commit messages
4. Drop debug/WIP commits

**Amending the last commit:**
- `git commit --amend` — fix message or add forgotten changes
- Only for unpushed commits, or force-push with team agreement

**Recovering from mistakes:**
- `git reflog` — find the commit before the mistake
- `git reset --hard {ref}` — restore to that state
- `git cherry-pick {sha}` — rescue specific commits

## Output Format

```markdown
## Git: {action description}

### Current State
- **Branch:** {current branch}
- **Status:** {clean/dirty, ahead/behind}
- **Base:** {target branch for merge/PR}

### Action Taken
{description of what was done}

### Result
- **Branch:** {resulting branch state}
- **Commits:** {number of commits, squashed status}
- **Conflicts:** {resolved/none}
- **PR:** {URL if created}

### Recommended Next Steps
1. {next action}
```

For conflict resolution:
```markdown
## Conflict Resolution: {branch} -> {base}

### Conflicting Files
| File | Ours (HEAD) | Theirs ({branch}) | Resolution |
|------|------------|-------------------|------------|
| src/api.ts | Added auth check | Changed response format | Keep both changes |
| package.json | Updated dep A | Updated dep B | Merge both updates |

### Resolution Applied
- `src/api.ts` — combined auth check with new response format
- `package.json` — both dependency updates included

### Verification
- [x] All conflicts resolved
- [x] Tests pass
- [x] Build succeeds
```

## Rules

- NEVER force-push to main/master or shared branches without explicit user confirmation.
- NEVER rewrite history on branches that others are working on.
- Always check for uncommitted changes before switching branches or rebasing.
- Commit messages should be clear and follow conventional commits format when the project uses it.
- When in doubt about merge strategy, prefer squash merge — it's safest.
- Always run tests after conflict resolution before completing the merge.
- If a rebase goes wrong, `git rebase --abort` is always an option. Mention it.

## Not Responsible For

- Checking for pre-commit cleanliness (use dirty-guard)
- Running code in isolated worktrees (use worktree-sandbox)
- CI/CD pipeline execution (use pipeline)
- Code review quality assessment (use review or multi-model-review)
- Release tagging and changelog generation (use release)
