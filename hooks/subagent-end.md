# Hook: subagent-end

> Process sub-agent results — validate, merge, update parent state.

## Trigger

Fires when a sub-agent returns results — successfully, with errors, or on timeout.

## Behavior

1. **Validate output** — check that the sub-agent produced the expected deliverables
2. **Quality check** — scan results for hallucinations, incomplete answers, or obvious errors
3. **Merge results** — integrate sub-agent findings into parent context
4. **Update tracking** — mark the delegation as complete in `.runs/` with outcome
5. **Handle failures** — if sub-agent failed or timed out, decide: retry, do it yourself, or skip

## Input

- Sub-agent run ID and type
- Return status (success, failed, timeout)
- Sub-agent output (results, files, errors)
- Expected deliverables from `subagent-start`

## Output / Side Effects

- Results merged into parent agent's working context
- Tracking entry updated with outcome and duration
- Failed delegations logged with diagnosis
- Retry triggered for recoverable failures (once)

## Example

```
🤖 subagent-end: #sub-2024-0615-003 (explore)
   Status: success (34s)
   Results: Found 4 auth patterns across 7 files
   Validation: ✓ all referenced files exist
   Merged into parent context
```

```
🤖 subagent-end: #sub-2024-0615-004 (task)
   Status: timeout (120s exceeded)
   Decision: Retry with simpler prompt (attempt 2/2)
```
