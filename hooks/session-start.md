# Hook: session-start

> Initialize agent context at the beginning of every session.

## Trigger

Fires once when a new agent session begins (first user message or CLI startup).

## Behavior

1. **Load project memory** — read `.memory/project.md`, `.memory/decisions.md`, `.memory/failures.md`
2. **Check pending handoffs** — look for `.memory/handoff.md` from a previous session; if found, summarize it and resume
3. **Show HUD** — display a one-line status: branch, active plan, last session summary, uncommitted changes count
4. **Run parity-check** — compare `.memory/` state against actual project state (do files referenced still exist? are TODOs stale?)
5. **Load active plan** — if `.memory/active-plan.md` exists, inject it as working context

## Input

- Project root directory
- `.memory/` directory contents
- Git status (branch, dirty files, recent commits)
- Previous session handoff (if any)

## Output / Side Effects

- Agent context populated with project memory and conventions
- HUD line printed to user
- Stale handoff consumed (renamed to `.memory/handoff-{date}.md`)
- Warnings emitted for stale TODOs or missing referenced files

## Example

```
🟢 Session start — main branch, 2 uncommitted files
   Plan: "Add auth middleware" (3/7 tasks done)
   Handoff: Previous session completed API routes, paused at tests
   Memory: 12 decisions, 3 failure patterns loaded
```
