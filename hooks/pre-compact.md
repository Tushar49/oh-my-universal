# Hook: pre-compact

> Save critical state before context compaction — preserve key decisions and progress.

## Trigger

Fires when:
- Context guard reaches 85% threshold
- User requests context compaction
- Agent decides to compact proactively (long session, many tool outputs)

## Behavior

1. **Save critical state** — write active plan progress, key decisions, and current task state to `.memory/`
2. **Preserve key decisions** — extract and save all important decisions made this session
3. **Snapshot progress** — record which plan steps are done, in-progress, and pending
4. **Warn user** — inform that compaction is happening and what will be preserved
5. **Mark compaction point** — record in session log for handoff continuity

## Input

- Current context contents (what's loaded)
- Active plan and progress
- Decisions made this session
- Unsaved work or state

## Output / Side Effects

- `.memory/compact-state-{timestamp}.md` created with critical state
- Active plan progress saved
- Decisions persisted to `.memory/decisions.md`
- User warned about compaction
- Post-compact, `memory-load` hook re-injects essential context

## Example

```
📦 pre-compact: Context at 87%, compacting
   Saving: active plan (5/9 steps done), 3 decisions, current file context
   Written to: .memory/compact-state-20240615-1423.md
   After compaction: memory-load will re-inject critical context
   ⚠️ Some earlier conversation details will be summarized
```
