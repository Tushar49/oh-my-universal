# Contract: state-precedence

> State layering, rollback rules, and forbidden transitions. Defines how state flows and what transitions are illegal.

## Invariants

### 1. Precedence Order

State is resolved in this order — higher layers override lower ones:

```
session state  >  project state  >  global state
```

- **Global state:** defaults from oh-my-universal config, user-level preferences
- **Project state:** `.state/` directory, project-specific settings, `.memory/`
- **Session state:** current workflow state, in-flight skill context, run metadata

When the same key exists at multiple layers, the highest layer wins. Lower layers are fallbacks, not overrides.

### 2. Rollback on Failure

When a skill fails or is cancelled:
- Session state rolls back to the pre-skill snapshot
- Project state rolls back ONLY if the skill explicitly modified it (partial rollback)
- Global state is NEVER modified by skills — no rollback needed

**Rollback means:**
- `workflow-state.json` reverts to the state before the skill started
- Files created by the failed skill are NOT auto-deleted (user may want to inspect them)
- The skill's run directory (`.runs/{tag}/`) is preserved with status `failed`

### 3. Forbidden Transitions

These state transitions are INVALID and must be rejected:

| From | To | Why |
|---|---|---|
| `completed` | `planning` | Completed work cannot re-enter planning. Start a new run. |
| `completed` | `executing` | Same — completed is terminal for that run. |
| `cancelled` | `executing` | Cancelled work cannot resume. Start a new run. |
| `cancelled` | `testing` | Same — cancelled is terminal. |
| `idle` | `committing` | Cannot commit without executing first. |
| `idle` | `completed` | Cannot complete without doing work. |

Valid transitions are defined in `skills/workflow-state.md`. Anything not listed there is forbidden.

### 4. Auto-Timeout for Stale States

If a state has been active for too long without progress, it is stale:

| State | Timeout | Action |
|---|---|---|
| `executing` | 30 minutes with no file changes | Mark as `blocked`, reason: "stale — no progress detected" |
| `testing` | 15 minutes with no test output | Mark as `blocked`, reason: "stale — tests not producing output" |
| `blocked` | 24 hours | Mark as `cancelled`, reason: "auto-timeout — blocked too long" |
| `planning` | 60 minutes with no plan output | Mark as `blocked`, reason: "stale — planning not producing output" |

Timeouts are advisory in markdown-only CLIs (agent checks on session resume). In CLIs with timer support, they can be enforced automatically.

## Violations

- Setting session state that contradicts project state without explicit override
- Attempting a forbidden transition (must be rejected with an error message)
- Failing to roll back session state after a skill failure
- Leaving a skill in a non-terminal state indefinitely (see auto-timeout)

## Enforcement

| Component | What it checks |
|---|---|
| `skills/workflow-state.md` | Validates all transitions against the allowed list |
| `hooks/skill-start.md` | Snapshots pre-skill state for rollback |
| `hooks/skill-end.md` | Rolls back on failure, validates terminal state |
| `hooks/session-start.md` | Reconciles stale states on session resume |

## Examples

**Valid:** `idle` → `planning` → `executing` → `testing` → `completed` → `idle`

**Invalid:** `completed` → `executing` — rejected because completed is terminal. The agent should say: "This run is complete. Start a new task to continue working."

**Rollback:** Skill enters `executing`, modifies 3 files, then fails. State rolls back to `idle`. The 3 files remain on disk but `workflow-state.json` reflects `idle` with a note about the failed run.
