# Skill: cancel

> Kill-switch to abort any running skill/mode immediately. Save progress, report status, clean up.
> Inspired by: oh-my-claudecode (cancelomc / /oh-my-claudecode:cancel)

## When to Trigger

- User says "cancel", "stop", "abort", "kill it"
- Ctrl+C equivalent — user wants immediate halt
- When a skill is stuck, looping, or going in the wrong direction
- When the user changes their mind mid-execution

## Workflow

### Step 1 — Identify Active Skill

Determine what is currently running:
- Check `.state/workflow-state.json` for active state (if workflow-state skill is active)
- Check `.runs/` for the latest run tag with no `completed` marker
- Check context for any in-progress skill (autopilot, ultrawork, team, etc.)

### Step 2 — Save Progress

Save current progress to `.runs/{run-tag}/cancelled-state.md`:
- What was completed (with file paths, commits, outputs)
- What was in-progress (current step, partial work)
- What was queued (remaining steps not yet started)
- Reason for cancellation (user-initiated, error, timeout)

### Step 3 — Clean Up

- Remove any temp files created by the cancelled skill
- Revert any uncommitted partial writes that would leave code in a broken state
- Release any locks or resources
- Do NOT commit partial work unless the user explicitly asks

### Step 4 — Report

Present a summary of what happened.

## Output Format

```markdown
## Cancelled: {skill-name} — {run-tag}

### Status at Cancellation
- **State:** {executing / planning / testing / reviewing}
- **Elapsed:** {time since skill started}
- **Reason:** {user-initiated / error / timeout}

### Completed
- [x] {step 1 description} — {output/commit}
- [x] {step 2 description} — {output/commit}

### In-Progress (Aborted)
- [ ] {step 3 description} — {what was done so far}

### Queued (Not Started)
- [ ] {step 4 description}
- [ ] {step 5 description}

### Cleanup
- Reverted: {files reverted or "none"}
- Temp files removed: {count or "none"}
- Partial commits: {kept / reverted / "none"}

### Resume
To resume from where you left off:
> {command or instruction to continue}
```

## Rules

- Cancellation is IMMEDIATE. Do not finish the current step — stop as soon as possible.
- ALWAYS save progress before cleaning up. Progress data is more valuable than a clean state.
- NEVER commit partial work unless the user explicitly says "commit what you have".
- If the cancelled skill had pending file writes, list them so the user can decide.
- If no skill is running, say so. Don't pretend to cancel something.
- After cancellation, return to idle state. The user decides what to do next.

## Not Responsible For

- Undoing committed work (use `git revert` manually)
- Deciding whether to resume (present the option, let the user choose)
- Cancelling external processes (CI pipelines, deployments — those need manual intervention)
- Killing background servers or detached processes (use system tools directly)
