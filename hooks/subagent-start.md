# Hook: subagent-start

> Track sub-agent delegation — log, set timeout, monitor.

## Trigger

Fires when the agent delegates work to a sub-agent (task tool, background agent, parallel exploration).

## Behavior

1. **Log delegation** — record what task was delegated, to which agent type, with what context
2. **Set timeout** — establish a maximum wait time based on task complexity (default: 5 min)
3. **Track in `.runs/`** — create a tracking entry with run ID, start time, expected deliverables
4. **Validate prompt** — check that the sub-agent prompt includes sufficient context (no dangling references)
5. **Set expectations** — define what a successful result looks like (files, answer, report)

## Input

- Sub-agent type (explore, task, general-purpose, code-review)
- Delegation prompt
- Expected deliverables
- Parent task context

## Output / Side Effects

- Delegation logged to session trace
- Tracking entry created with timeout
- Prompt validation warnings (if context seems insufficient)
- Timer started for timeout monitoring

## Example

```
🤖 subagent-start: explore "Find all authentication patterns in src/"
   Agent: explore (Haiku)
   Run ID: #sub-2024-0615-003
   Timeout: 120s
   Expected: List of auth patterns with file paths
   Prompt check: ✓ sufficient context
```
