# Skill: workflow-state

> Formal state machine for skill/workflow transitions and reconciliation. Tracks what's running, prevents conflicts.
> Inspired by: oh-my-codex STATE_MODEL.md (authoritative per-mode state, transition rules, reconciliation)

## When to Trigger

- Always active as background state tracking when any skill runs
- User says "show state", "reset state", "what's running"
- On session resume — reconcile state before doing anything else
- When a skill transition fails or state appears inconsistent

## Workflow

### Step 1 — State Definitions

The workflow state machine uses these states:

| State | Description |
|-------|-------------|
| `idle` | No skill active. Awaiting user input. |
| `planning` | A plan is being created (plan, analyst, architecture skills). |
| `executing` | Code changes are being made (ultrawork, autopilot, refactor, build-fix). |
| `testing` | Tests are running or being written (tdd, verify skills). |
| `reviewing` | Code is being reviewed (review, multi-model-review, security-review). |
| `committing` | Changes are being committed or released (release, pre-commit-check). |
| `blocked` | Skill cannot proceed — needs user input or external dependency. |
| `cancelled` | Skill was aborted via cancel skill. |
| `completed` | Skill finished successfully. |

### Step 2 — Transition Rules

Valid state transitions (anything not listed is INVALID):

```
idle -> planning, executing, testing, reviewing
planning -> executing, blocked, cancelled, completed
executing -> testing, reviewing, committing, blocked, cancelled, completed
testing -> executing, reviewing, blocked, cancelled, completed
reviewing -> executing, committing, blocked, cancelled, completed
committing -> completed, blocked, cancelled
blocked -> planning, executing, testing, reviewing (resume)
cancelled -> idle
completed -> idle
```

Invalid transitions MUST be rejected with an explanation of why.

### Step 3 — State Persistence

Save state to `.state/workflow-state.json`:

```json
{
  "current": "executing",
  "previous": "planning",
  "skill": "ultrawork",
  "run_tag": "2025-01-15-feature-auth",
  "entered_at": "2025-01-15T10:30:00Z",
  "history": [
    { "state": "idle", "at": "2025-01-15T10:00:00Z" },
    { "state": "planning", "at": "2025-01-15T10:05:00Z", "skill": "plan" },
    { "state": "executing", "at": "2025-01-15T10:30:00Z", "skill": "ultrawork" }
  ],
  "context": {
    "plan_file": ".runs/2025-01-15-feature-auth/plan.md",
    "files_changed": ["src/auth.ts", "src/middleware.ts"],
    "last_checkpoint": "Step 3 of 7"
  }
}
```

### Step 4 — Conflict Resolution

When two skills try to run simultaneously:
1. Check if the new skill is compatible with the current state
2. If compatible (e.g., running `review` during `executing`), allow it with a sub-state
3. If incompatible (e.g., two `executing` skills), reject the second with an explanation
4. If the current skill is `blocked`, allow the new skill to preempt it

### Step 5 — Session Reconciliation

On session resume (new conversation with existing state file):
1. Read `.state/workflow-state.json`
2. Check if the state makes sense (was the skill actually running?)
3. If state is `executing` but no recent changes exist, mark as `blocked` or `cancelled`
4. If state is `blocked`, present the blocking reason and ask user what to do
5. If state file is corrupt or missing, reset to `idle`

## Output Format

```markdown
## Workflow State

**Current:** {state} ({skill name})
**Since:** {timestamp}
**Run:** {run-tag}

### History
| # | State | Skill | Entered | Duration |
|---|-------|-------|---------|----------|
| 1 | idle | — | 10:00 | 5m |
| 2 | planning | plan | 10:05 | 25m |
| 3 | executing | ultrawork | 10:30 | active |

### Context
- Plan: {plan file path}
- Files changed: {count}
- Last checkpoint: {step N of M}
```

## Rules

- State transitions MUST follow the transition rules. No exceptions.
- ALWAYS persist state before and after transitions. Crash recovery depends on this.
- State file MUST be valid JSON. If it's corrupt, reset to `idle` and warn the user.
- The `blocked` state MUST include a reason. Never block without explanation.
- History is append-only. Never delete history entries.
- On reconciliation, prefer safety: if in doubt, set state to `blocked` rather than `executing`.
- State tracking should be lightweight. Don't slow down the actual skill execution.

## Not Responsible For

- Executing any skill (only tracks state — skills do their own work)
- Deciding which skill to run (user or autopilot decides, this skill just validates transitions)
- Persisting skill-specific data (each skill manages its own `.runs/` output)
- Process-level isolation (use container-sandbox for that)
