# Hook: memory-load

> Inject relevant memories into agent context at session start or context switch.

## Trigger

Fires at:
- Session start (always — via `session-start` hook)
- Context switch (agent moves to a different part of the codebase)
- Before skill activation (load skill-specific memories)
- After context compaction (re-inject critical memories)

## Behavior

1. **Scan `.memory/`** — read all memory files (decisions, failures, conventions, project notes)
2. **Filter by relevance** — match memories to current context (files being worked on, active plan, skill)
3. **Prioritize** — rank by recency and importance (recent failures > old conventions)
4. **Inject** — add relevant memories to agent's working context
5. **Summarize if large** — if memory corpus exceeds context budget, summarize older entries

## Input

- Current context (active files, plan, skill)
- `.memory/` directory contents
- Context budget (how much space is available for memory injection)

## Output / Side Effects

- Relevant memories added to agent's working context
- Agent is aware of past decisions, known failures, project conventions
- Large memory sets summarized to fit context budget
- Memory load logged to session trace

## Example

```
📂 memory-load: session start
   Loaded: 8 decisions, 3 failure patterns, 5 conventions
   Relevant to current context: 4 decisions, 1 failure pattern
   Context budget used: 2.1KB of 8KB allocated
```
