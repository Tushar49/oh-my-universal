# Hook: context-guard

> Monitor context window usage and take action before overflow.

## Trigger

Fires periodically during the session — after every few tool calls, long outputs, or large file reads.

## Behavior

1. **Estimate usage** — track approximate context consumption (input + output tokens)
2. **Threshold actions**:
   - **70%** — warn user: "Context at 70%, consider wrapping up or compacting"
   - **85%** — trigger `pre-compact` hook, suggest compaction, start saving critical state
   - **95%** — force-save all state to `.memory/`, produce emergency handoff, warn imminent end
3. **Track growth rate** — estimate how many more exchanges fit before limit
4. **Suggest optimizations** — recommend shorter outputs, file references instead of inline content

## Input

- Estimated context usage (tokens or percentage)
- Current session state (active plan, unsaved work)
- Rate of context consumption (tokens per exchange)

## Output / Side Effects

- Warning messages at threshold crossings
- `pre-compact` hook triggered at 85%
- Emergency state save at 95%
- Growth rate estimate shown to user
- Context-saving suggestions offered

## Example

```
⚠️ context-guard: 72% context used
   Rate: ~2.5K tokens/exchange, ~12 exchanges remaining
   Suggestion: Consider compacting context or saving state

🚨 context-guard: 93% context used
   Action: Saving critical state to .memory/emergency-handoff.md
   Remaining: ~3 exchanges
   → Recommend: finish current task, session ending soon
```
