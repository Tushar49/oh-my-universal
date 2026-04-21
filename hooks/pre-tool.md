# Hook: pre-tool

> Guard and log every tool call before execution.

## Trigger

Fires before ANY tool call — file edits, shell commands, git operations, network requests.

## Behavior

1. **Log intent** — record what tool is about to be called and why
2. **Permission check** — classify the operation as safe/risky/destructive (delegate to `permission-check` hook)
3. **Dirty guard** — for file edits, check if target file has uncommitted changes
4. **Dedup check** — if the same tool call was made recently with identical args, warn about repetition
5. **Context check** — verify the tool call makes sense given the current plan step

## Input

- Tool name and arguments
- Current plan step (if active)
- Git status of affected files
- Recent tool call history (last 10)

## Output / Side Effects

- Tool call logged to internal session trace
- Operation blocked if guard fails (with explanation)
- Warning emitted for risky operations (but not blocked)
- Dedup warning if identical call detected

## Example

```
🔧 pre-tool: edit src/auth.ts
   ✓ Permission: safe (file edit, existing file)
   ✓ Dirty guard: file is clean
   ✓ Context: matches plan step 3 "add auth middleware"
   → Proceeding
```
