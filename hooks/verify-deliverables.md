# Hook: verify-deliverables

> After implementation, check that all planned items were delivered.

## Trigger

Fires when:
- A skill completes (via `skill-end` hook)
- User says "done", "finished", "ship it"
- A plan's final step is reached
- Before committing a batch of changes

## Behavior

1. **Load plan** — read the active plan or skill's expected deliverables
2. **Check files** — verify all planned files were created/modified
3. **Run tests** — if tests exist, run them and confirm they pass
4. **Check docs** — if code changed, verify related docs were updated
5. **Report gaps** — list any missing deliverables with suggestions

## Input

- Active plan with expected deliverables
- Files changed during the session
- Test results (if run)
- Documentation file list

## Output / Side Effects

- Checklist of deliverables with pass/fail status
- Missing items flagged as warnings
- Tests run if not already run this session
- Suggestions for completing gaps

## Example

```
📋 verify-deliverables: Plan "Add auth middleware"
   ✓ src/middleware/auth.ts — created
   ✓ src/middleware/auth.test.ts — created, 8 tests passing
   ✗ README.md — not updated (auth section missing)
   ✗ CHANGELOG.md — not updated
   
   2/4 deliverables complete. Update docs before committing?
```
