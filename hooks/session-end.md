# Hook: session-end

> Persist state and produce a handoff document before the session closes.

## Trigger

Fires when the session is ending — user says goodbye, context is about to expire, or explicit session close.

## Behavior

1. **Save memories** — write new decisions, patterns, and learnings to `.memory/`
2. **Produce handoff** — create `.memory/handoff.md` summarizing what was done, what's pending, and blockers
3. **Update docs** — if code changed, check whether README or related docs need updating
4. **Suggest commit** — if there are uncommitted changes, suggest a commit message and offer to commit
5. **Log session** — append session summary to `.memory/session-log.md` with timestamp

## Input

- All changes made during the session (files created, edited, deleted)
- Decisions made and rationale
- Current plan progress
- Uncommitted git changes

## Output / Side Effects

- `.memory/handoff.md` created/updated
- `.memory/session-log.md` appended
- New memories persisted to `.memory/decisions.md`
- Commit suggestion shown (not auto-committed)

## Example

```
📋 Session end — saving state
   Handoff: Written to .memory/handoff.md
   Changes: 4 files modified, 1 created
   Suggested commit: "feat: add rate limiting middleware"
   Memories: 2 new decisions saved, 1 failure pattern recorded
```
