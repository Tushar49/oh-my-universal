# Skill: hud

> Heads-up display - compact status line showing agent progress at a glance.
> Inspired by: oh-my-claudecode (hud, status-line)

## When to Trigger

- User says "show status", "enable hud", "what's happening"
- Auto-enabled during multi-step skills: autopilot, ultrawork, team
- User says "disable hud" to turn off

## Workflow

### Step 1 — Gather State

Collect current agent state from context:
- **Active skill:** which skill is currently running (e.g., ultrawork, plan, review)
- **Phase/step:** current step out of total (e.g., step 3/5)
- **Files modified:** count of files created or edited this session
- **Tests:** count of tests run and pass/fail status
- **Elapsed time:** approximate time since task started
- **Errors:** count of errors or retries encountered

### Step 2 — Render Status Line

Display a single compact line at the START of each response:

```
[{skill}:{phase}] {files} files modified | {tests} tests {status} | {time} elapsed
```

### Step 3 — Update Each Turn

Refresh the status line at the start of every subsequent response while HUD is enabled. Values update based on accumulated session state.

## Output Format

### Compact (default)

```
[ultrawork:step3/5] 4 files modified | 12 tests passed | 2m elapsed
```

### With errors

```
[autopilot:execution] 6 files modified | 8/10 tests passed | 2 errors | 5m elapsed
```

### Idle / no active skill

```
[idle] 0 files modified | no tests run | ready
```

### Disabled

When user says "disable hud", stop rendering the status line. Acknowledge:
```
HUD disabled.
```

## Rules

- Status line is ONE line - never multi-line or verbose
- Render at the START of each response, before any other content
- Use plain text, no emoji (keep it terminal-friendly across platforms)
- Don't let status reporting slow down actual work - gather state from context only
- When no skill is active, show `[idle]`
- When step count is unknown, omit it: `[review]` not `[review:step?/?]`
- If HUD was not explicitly enabled and no multi-step skill is running, don't show it
- Track enabled/disabled state for the current session only

## Not Responsible For

- Token usage tracking (CLI-specific, not available in markdown skills)
- Terminal status bar integration (CLI-specific hooks)
- Cost estimation
- Agent spawn counts (see team skill)
