# Skill: hud

> Heads-up display - compact status line showing agent progress at a glance.
> Includes single-agent and multi-agent status formats, elapsed time tracking, and configuration modes.
> Inspired by: oh-my-claudecode (hud, status-line), awesome-claude-code (claude-pace, claude-powerline)

## When to Trigger

- User says "show status", "enable hud", "show progress", "what's happening"
- Auto-enabled during multi-step skills: autopilot, ultrawork, team
- User says "disable hud", "disable status", "quiet mode" to turn off
- Manually invocable: "status" to show current state

## Workflow

### Step 1 - Detect Mode
Check if status output is enabled:
- **On by default** in autopilot, ultrawork, and team skills
- **Off by default** in single-shot tasks and scripted usage
- User can toggle with "enable hud" / "disable hud"

### Step 2 - Gather State
Collect current agent state from context:
- **Active skill:** which skill is currently running
- **Phase/step:** current step out of total (e.g., step 3/5)
- **Files modified:** count of files created or edited this session
- **Tests:** count of tests run and pass/fail status
- **Elapsed time:** approximate time since task started
- **Errors:** count of errors or retries encountered

### Step 3 - Render Status Line
Display a single compact line at the START of each response. Refresh each turn while HUD is enabled.

## Output Format

### Single-Agent (default)
```
[{skill}:{step}/{total}] {description} | {files} files | {elapsed}
```

Examples:
```
[ultrawork:1/6] planning changes | 0 files | 0s
[ultrawork:3/6] running tests | 3 files | 28s
[ultrawork:6/6] preparing commit | 4 files | 45s
```

### Multi-Agent Format
When running team or parallel workflows:
```
[team:{step}/{total}] {agent-name} running {skill} | {files} files | {elapsed}
```

Examples:
```
[team:2/5] agent-1 running refactor | 4 files | 20s
[team:4/5] waiting for agents to complete | 6 files | 60s
```

### Error Status
```
[ultrawork:3/6] tests failed (2 failures) | 3 files | 30s
[build-fix:1/3] retrying after test failure | 3 files | 32s
```

### Completion
```
[ultrawork:done] 4 files changed, all checks passed | 48s total
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

## Configuration Modes

### Verbose Mode
Show every sub-step, including skill internals:
```
[ultrawork:3/6] verify: running npm test | 3 files | 28s
[ultrawork:3/6] verify: running eslint | 3 files | 31s
[ultrawork:3/6] verify: all checks passed | 3 files | 35s
```

### Minimal Mode (default)
Show only phase changes - one line per workflow step:
```
[ultrawork:3/6] running verification | 3 files | 28s
```

## Elapsed Time

- Track from workflow start, not step start
- Use seconds for < 2 minutes, then switch to `Xm Ys` format
- Estimate, don't measure precisely - this is informational

## CLI-Specific Notes

| CLI | How Status Works |
|-----|-----------------|
| Copilot CLI | Use `report_intent` tool for intent. Status lines go in response text. |
| Claude Code | Output at start of each response. Could also use hooks for injection. |
| Codex CLI | Output at start of each response. |
| Cursor | Output at start of each response. |

For CLIs with native status bars, the agent's text-based status line supplements - not replaces - the native display.

## Rules

- Status line is ONE line - never multi-line or verbose
- Render at the START of each response, before any other content
- Use plain text, no emoji (keep it terminal-friendly across platforms)
- Don't let status reporting slow down actual work - gather state from context only
- When no skill is active, show `[idle]`
- When step count is unknown, omit it: `[review]` not `[review:step?/?]`
- If HUD was not explicitly enabled and no multi-step skill is running, don't show it
- Track enabled/disabled state for the current session only
- File count is cumulative for the workflow, not per-step
- Never show status lines in final output to the user (e.g., commit messages, generated files)
- When disabled, produce ZERO status output - no partial, no summary
- Don't count reading files as "files touched" - only created/modified files
- Elapsed time is approximate - don't waste effort on precise measurement

## Not Responsible For

- Token usage tracking (CLI-specific, not available in markdown skills)
- Terminal status bar integration (CLI-specific hooks)
- Cost estimation (see cost-tracker skill)
- Agent spawn counts (see team skill)
- Context window percentage (CLI-specific, not measurable from markdown skills)
- Git branch display (use doctor or verify for that)
- Replacing native status bars in CLIs that have them
- Rate limit monitoring (CLI-specific feature)
