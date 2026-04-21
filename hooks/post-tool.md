# Hook: post-tool

> Verify results and update status after every tool call.

## Trigger

Fires after ANY tool call completes — success or failure.

## Behavior

1. **Verify result** — check that the tool call produced expected output (file exists, command exited 0, etc.)
2. **Check for errors** — scan output for error patterns (stack traces, "FAIL", non-zero exit codes)
3. **Update status line** — refresh HUD with current progress (files changed, tests passing, etc.)
4. **Track progress** — if working through a plan, mark the current step's tool calls as done
5. **Trigger follow-up** — if output suggests a problem (lint warnings, deprecation notices), note for later

## Input

- Tool name, arguments, and return value
- Exit code (for shell commands)
- File diff (for edit operations)
- Current plan progress

## Output / Side Effects

- Status line updated
- Errors logged to session trace
- Plan progress updated
- Follow-up items queued if issues detected

## Example

```
🔧 post-tool: bash "npm test"
   Result: exit 0, 47 tests passed
   Status: Step 4/7 complete
   ✓ No errors detected
```
