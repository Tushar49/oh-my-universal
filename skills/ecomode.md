# Skill: ecomode

> Token-efficient execution mode — minimize token usage while maintaining quality.
> Inspired by: oh-my-codex ecomode

## When to Trigger

- User says "save tokens", "be concise", "ecomode", "efficient mode"
- User says "enable ecomode" or "disable ecomode" to toggle
- Context usage exceeds 70% (auto-enable, works with context-guard hook)
- Task is simple and doesn't need verbose output
- Context is running low and remaining work is significant

## Workflow

### Step 1 — Assess Context Budget

Check current context usage. If above 70%, auto-enable ecomode. Otherwise, check if user explicitly requested it.

### Step 2 — Apply Eco Behaviors

When ecomode is active, apply these constraints:

- **Shorter responses** — 1-2 sentences for confirmations, no restating what was done
- **Skip non-essential verification** — don't re-read files you just wrote unless there's a reason to doubt
- **Compress output** — summarize results instead of showing full output
- **Avoid redundant reads** — if you read a file this session, don't read it again unless it changed
- **Batch operations** — combine multiple edits, searches, and commands into fewer tool calls
- **Skip scaffolding narration** — no "I'll now..." or "Let me..." preamble

### Step 3 — Preserve Safety

NEVER skip these regardless of ecomode:

- Correctness checks (run tests after changes)
- Security checks (input validation, secret scanning)
- Destructive operation confirmation
- Error handling in generated code

### Step 4 — Track Savings

Maintain a rough estimate of tokens saved:
- Skipped re-read: ~500 tokens saved per file
- Compressed response: ~200 tokens saved per response
- Batched tool calls: ~300 tokens saved per batch

Report savings when ecomode is disabled or session ends.

## Output Format

```markdown
## Ecomode: {ON | OFF}

**Context usage:** {estimate}%
**Behaviors active:**
- [x] Short responses
- [x] Skip redundant reads
- [x] Compress output
- [ ] Skip verification (only non-essential)

**Estimated savings this session:** ~{N}k tokens
```

When toggling:
```
🟢 Ecomode ON — shorter responses, fewer reads, compressed output.
   Safety checks still active. Say "disable ecomode" to return to normal.
```
```
🔴 Ecomode OFF — returning to full verbosity.
   Session savings: ~{N}k tokens.
```

## Rules

- NEVER skip correctness, security, or safety checks. Eco means efficient, not sloppy.
- NEVER omit error handling or edge cases in generated code to save tokens.
- When ecomode is active, prefer showing diffs over full files.
- If a task is complex enough that brevity would cause confusion, temporarily override eco for that response.
- Auto-enable at 70% context is a suggestion, not a hard rule — if the user is in the middle of something complex, mention it but don't force the switch.
- Ecomode persists until explicitly disabled or session ends.
- If the user says "more detail" or asks a follow-up question, give a full answer for that response without disabling ecomode globally.

## Not Responsible For

- Deciding what tasks to skip entirely (that's the user's call)
- Context window management or session splitting (use session-manager)
- Summarizing previous conversation (use handoff)
- Reducing code complexity (use refactor)
