# Hook: dirty-guard-hook

> Check worktree cleanliness before git operations — prevent accidental overwrites.

## Trigger

Fires before:
- Git operations (commit, checkout, rebase, merge, stash)
- File edits to files with uncommitted changes
- Any destructive operation on tracked files

## Behavior

1. **Check git status** — run `git status --porcelain` to detect dirty files
2. **Classify changes** — staged, unstaged, untracked, conflicted
3. **Match against target** — if the operation targets a specific file, check only that file
4. **Guard decision**:
   - Clean worktree → PASS
   - Dirty but target file is clean → PASS with warning about other dirty files
   - Target file is dirty → FAIL with diff preview
   - Merge conflicts present → FAIL (resolve conflicts first)

## Input

- Operation type (git command, file edit)
- Target file path (if applicable)
- Git status output

## Output / Side Effects

- PASS: operation proceeds
- FAIL: operation blocked with explanation and suggested action (commit, stash, or discard)
- Diff of dirty target file shown to user on FAIL
- Invokes `dirty-guard` skill for detailed worktree analysis if needed

## Example

```
🛡️ dirty-guard: pre-edit src/auth.ts
   Git status: src/auth.ts has unstaged changes (+12 -3)
   Decision: FAIL
   → File has uncommitted changes. Options:
     1. git stash — save changes temporarily
     2. git add && git commit — commit current changes
     3. "edit anyway" — override guard (changes may conflict)
```
