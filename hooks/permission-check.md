# Hook: permission-check

> Classify operations by risk level and enforce permission gates.

## Trigger

Fires before file writes, shell commands, network requests, package installs, and git operations (called by `pre-tool` hook).

## Behavior

1. **Classify operation** — assign a risk level based on the operation type:
   - **Safe** (auto-approve): read files, list directories, run tests, git status
   - **Normal** (auto-approve with log): edit existing files, create new files, git add/commit
   - **Risky** (warn): delete files, install packages, run unknown scripts, git push
   - **Destructive** (block + confirm): `rm -rf`, `git reset --hard`, force push, drop database
2. **Check project overrides** — read `.config/permissions.yml` for project-specific rules
3. **Apply decision** — auto-approve safe/normal, warn for risky, block destructive

## Input

- Tool name and arguments
- Operation classification rules
- Project permission overrides (if any)

## Output / Side Effects

- Safe/normal operations proceed silently
- Risky operations proceed with a warning logged
- Destructive operations blocked with explanation and user prompt
- All classifications logged to session trace

## Example

```
🔒 permission-check: bash "rm -rf node_modules && npm install"
   Classification: destructive (rm -rf)
   Decision: BLOCKED
   → "rm -rf node_modules" is destructive. Proceed? (yes/skip)
```

```
🔒 permission-check: edit src/index.ts
   Classification: normal (edit existing file)
   Decision: auto-approved
```
