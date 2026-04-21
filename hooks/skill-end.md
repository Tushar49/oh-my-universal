# Hook: skill-end

> Finalize skill execution — verify deliverables and update state.

## Trigger

Fires when a skill completes — successfully, with errors, or aborted.

## Behavior

1. **Update workflow state** — clear active skill from session state
2. **Verify deliverables** — check that skill produced its expected outputs (files, commits, reports)
3. **Record outcome** — log result (success/partial/failed) to session log with run ID
4. **Notify** — inform user of completion with summary
5. **Chain next** — if skill is part of a pipeline, trigger the next skill

## Input

- Skill name and run ID
- Completion status (success, partial, failed, aborted)
- Deliverables produced (files created/modified, commits made)
- Errors encountered during execution

## Output / Side Effects

- Session state cleared (no active skill)
- Run logged to `.memory/session-log.md`
- Missing deliverables flagged as warnings
- Next skill in pipeline triggered (if applicable)

## Example

```
✅ skill-end: pre-commit-check (#run-2024-0615-001)
   Status: success
   Deliverables: ✓ lint passed, ✓ review complete, ✓ no secrets found
   Duration: 12s
   Next: → ready to commit
```
