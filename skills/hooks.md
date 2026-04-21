# Skill: hooks

> Pre/post hooks system for all agent operations - intercept lifecycle events to guard, transform, and extend behavior.

## When to Trigger

- Always active - hooks fire automatically on their registered events
- User says "list hooks", "show hooks", "what hooks are active"
- User says "add hook", "create hook for {event}"
- When configuring a new project's agent automation

## Workflow

### Step 1 - Discover Hooks
At session start (or when asked), scan `.hooks/` for hook definitions.
List active hooks grouped by event.

### Step 2 - Register
Build an internal table of event -> hooks mappings, sorted by priority.
Three hook types: **guard** (can block), **action** (side effects), **transform** (modify I/O).

### Step 3 - Intercept
Before/after each operation, check if any hooks are registered for that event.
Execute matching hooks in priority order, respecting type semantics.
Guards run first; if any guard FAILs, the operation aborts.

### Step 4 - Report
If a guard blocks an operation, explain WHY and what the user can do.
If an action hook fails, log it but don't interrupt the workflow.

## Output Format

### Listing Hooks
```
Hooks - {project name}
========================
pre-edit:
  + dirty-guard (guard, priority 10)
pre-commit:
  + quality-gate (guard, priority 10)
post-commit:
  + doc-update (action, priority 20)
  + notify (action, priority 50)

4 hooks active across 3 events
```

### Guard Failure
```
BLOCKED: dirty-guard (pre-edit)
   File src/auth.ts has uncommitted changes.
   -> Commit or stash changes before editing.
   -> Override with: "skip guard" or "edit anyway"
```

## Rules

- Guard hooks RECOMMEND blocking - the user can override with "skip guard" or "edit anyway"
- Action hook failures are logged, never fatal
- Transform hooks must be idempotent - running twice produces the same result
- Hooks must be fast (< 5 seconds each). Slow hooks should be action type, not guard.
- Never add hooks that require network access to guard operations (offline-first)
- Hook files in `.hooks/` are project-specific. User-global hooks go in `~/.config/oh-my-universal/hooks/`

See `docs/HOOKS_REFERENCE.md` for the complete hook library, hook definition format, and all 19 built-in hooks.

## Not Responsible For

- Implementing CLI-specific hook wiring (that's Phase 4 adapter work)
- Running the actual build/test/lint commands (delegate to verify, build-fix skills)
- Auto-fixing guard failures (suggest fixes, don't force them)
- Managing git hooks in `.git/hooks/` (that's a separate system - this is agent hooks)
