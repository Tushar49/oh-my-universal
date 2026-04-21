# Hook: memory-save

> Persist important learnings at key moments — decisions, failures, corrections.

## Trigger

Fires at key moments during a session:
- After a significant decision is made
- After a failure is diagnosed and resolved
- When the user corrects the agent's approach
- After a successful pattern is established
- At session end (always)

## Behavior

1. **Extract insight** — identify what was learned (decision rationale, failure cause, correction, pattern)
2. **Classify** — categorize as decision, failure-pattern, convention, preference, or fact
3. **Dedup** — check `.memory/` for existing entries that cover the same insight
4. **Write** — append to the appropriate `.memory/` file with timestamp and context
5. **Summarize** — keep entries concise (1-3 sentences max)

## Input

- The event that triggered the save (decision, failure, correction)
- Relevant conversation context
- Current `.memory/` contents (for dedup)

## Output / Side Effects

- New entry written to `.memory/decisions.md`, `.memory/failures.md`, or `.memory/conventions.md`
- Duplicate entries skipped (with note)
- Memory index updated if maintained

## Example

```
💾 memory-save: decision
   "Use bcrypt over argon2 for password hashing — project targets Node 16 which has native bcrypt bindings"
   Written to .memory/decisions.md
```

```
💾 memory-save: failure-pattern
   "npm install fails with ERESOLVE when react 18 + react-dom 17 coexist — fix: align versions"
   Written to .memory/failures.md
```
