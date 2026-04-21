# Hook: tool-failure

> Handle tool failures — log, diagnose, and attempt recovery.

## Trigger

Fires when a tool call fails — non-zero exit code, exception, timeout, or unexpected output.

## Behavior

1. **Log failure** — append to `.memory/failures.md` with timestamp, tool, args, error output
2. **Classify error** — transient (network, timeout) vs permanent (syntax error, missing file) vs unknown
3. **Check patterns** — compare against `.memory/failures.md` for recurring issues
4. **Suggest fix** — for build/test failures, suggest running `build-fix` skill; for file issues, suggest trace
5. **Auto-retry** — if error is transient (network timeout, rate limit), retry once after a short wait
6. **Escalate** — if same error occurred 3+ times, warn user and suggest a different approach

## Input

- Tool name and arguments
- Error output / stack trace
- Exit code
- Previous failure history from `.memory/failures.md`

## Output / Side Effects

- `.memory/failures.md` updated with new entry
- Automatic retry for transient failures (once)
- Fix suggestion shown to user
- Pattern warning if recurring failure detected

## Rate Limit Handling

When a tool call fails with 429/rate-limit error:

1. **Log** the rate limit with timestamp and retry-after header value
2. **Wait** for the specified retry-after duration (or 60s default if no header)
3. **Auto-resume** the operation that was rate-limited
4. If rate-limited **3+ times** in a session, switch to ecomode to reduce API calls
5. Log cumulative rate-limit events to `.memory/failures.md` with a `[rate-limit]` tag

```
⏳ tool-failure: rate-limit on "api call"
   Retry-after: 45s
   Occurrence: 2/3 (ecomode triggers at 3)
   Action: waiting 45s then auto-retry
```

## Example

```
❌ tool-failure: bash "npm run build"
   Error: TypeScript error TS2339 — Property 'foo' does not exist
   Classification: permanent (type error)
   Pattern: First occurrence
   Suggestion: Check src/auth.ts:42 — missing property. Run build-fix skill?
   Logged to .memory/failures.md
```
