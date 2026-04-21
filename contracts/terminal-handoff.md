# Contract: terminal-handoff

> Every skill MUST end in a terminal state. No hanging, no ambiguity. Handoffs include all context needed to continue.

## Invariants

### 1. Terminal States

Every skill execution MUST end in exactly one of these terminal states:

| State | Meaning | Next action |
|---|---|---|
| `finished` | Skill completed successfully. All deliverables produced. | Proceed to next task or idle. |
| `blocked` | Skill cannot proceed. External dependency or user input needed. | Present blocker, wait for resolution. |
| `failed` | Skill encountered an error it cannot recover from. | Report error, suggest recovery. |
| `cancelled` | User or system aborted the skill. | Clean up, return to idle. |
| `needs-input` | Skill paused, waiting for specific user input to continue. | Present question, resume on answer. |

A skill that ends without declaring one of these states is in violation of this contract.

### 2. Handoff Format

When transitioning between states or between skills, the handoff MUST include:

```markdown
## Handoff: {skill name} → {terminal state}

**Run:** {run-tag or timestamp}
**Duration:** {how long the skill ran}
**State:** {terminal state}

### What Was Done
- {completed item 1}
- {completed item 2}

### What Remains (if not finished)
- {remaining item 1}
- {remaining item 2}

### Context for Continuation
- {key decision or state that the next agent needs}
- {file paths, branch names, test results}

### Blocker Details (if blocked/needs-input)
- **What is needed:** {specific input or resolution}
- **Who can resolve:** user / external system / different skill
- **Suggested action:** {what to do next}
```

Not every field is required for every state — `finished` needs less context than `blocked`.

### 3. No Hanging

A skill MUST NOT:
- Exit without setting a terminal state
- Leave workflow-state in `executing` or `testing` without completing
- Silently stop producing output without declaring a state
- Defer state declaration to "later" or "the next skill"

If a skill is interrupted (context window limit, crash, timeout), the `skill-end` hook is responsible for detecting the missing terminal state and setting it to `failed` with reason "interrupted — no terminal state declared."

### 4. Escalation Rules

When a skill encounters a problem, follow this escalation ladder:

| Situation | Action |
|---|---|
| Recoverable error (test failure, lint error) | Retry once. If retry fails, set `failed`. |
| Missing input (needs a file path, config value) | Set `needs-input`. Ask the user. |
| External dependency unavailable (API down, service offline) | Set `blocked`. Log the dependency. |
| User says "stop", "cancel", "abort" | Set `cancelled` immediately. No retry. |
| Ambiguous situation (unclear if done or stuck) | Set `needs-input`. Ask the user to confirm. |
| Unrecoverable error (permissions, corrupt state) | Set `failed`. Include full error context. |

NEVER silently retry more than once. If the first retry fails, escalate.

## Violations

- Skill ends without declaring a terminal state
- Skill declares `finished` but deliverables are missing or incomplete
- Skill declares `blocked` without specifying what is blocking and who can resolve it
- Skill enters `needs-input` without presenting a clear, answerable question
- Skill retries silently more than once without escalating
- Handoff missing critical context that the next agent needs to continue

## Enforcement

| Component | What it checks |
|---|---|
| `hooks/skill-end.md` | Verifies a terminal state was declared before the skill exits |
| `hooks/verify-deliverables.md` | Validates that `finished` state has actual deliverables |
| `skills/workflow-state.md` | Records the terminal state in transition history |
| `skills/handoff.md` | Produces the full handoff document on session end |

## Examples

**Valid (finished):**
```
Skill: review → finished
Duration: 2m 15s
What was done: reviewed 4 files, found 2 warnings, 0 critical issues
```

**Valid (blocked):**
```
Skill: build-fix → blocked
What remains: fix type error in auth.ts:45
Blocker: Need to know if UserSession.token should be string | null or string | undefined
Who can resolve: user (architecture decision)
```

**Invalid (hanging):**
```
Skill: ultrawork
[... agent produces code changes ...]
[... context window ends ...]
[no terminal state declared]
```
This is a violation. The skill-end hook should detect this and set state to `failed` with reason "interrupted."
