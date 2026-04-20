# Skill: status-line

> Compact terminal progress indicators during long operations — one-line updates showing skill, step, and elapsed time.
> Inspired by: awesome-claude-code (claude-pace, claude-powerline, CCometixLine, ccstatusline)

## When to Trigger

- Auto-enabled during autopilot, ultrawork, and team workflows
- User says "enable status", "show progress", "show status"
- User says "disable status", "quiet mode" to turn off
- Manually invocable: "status" to show current state

## Workflow

### Step 1 — Detect Mode
Check if status output is enabled:
- **On by default** in autopilot, ultrawork, and team skills
- **Off by default** in single-shot tasks and scripted usage
- User can toggle with "enable status" / "disable status"

### Step 2 — Emit Status Lines
At the **start** of each major step, output a single status line before any other output.
Status lines go at the very top of the response — never buried in prose.

### Step 3 — Update on Phase Changes
Emit a new status line when:
- Moving to a new step in a workflow (plan -> implement -> verify)
- A sub-skill is invoked
- A significant milestone is reached (tests pass, review complete)
- An error occurs

## Output Format

### Single-Agent Format
```
⟐ [{skill}:{step}/{total}] {description} | {files_touched} files | {elapsed}
```

Examples:
```
⟐ [ultrawork:1/6] planning changes | 0 files | 0s
⟐ [ultrawork:2/6] implementing auth module | 3 files | 12s
⟐ [ultrawork:3/6] running tests | 3 files | 28s
⟐ [ultrawork:4/6] self-reviewing diff | 3 files | 35s
⟐ [ultrawork:5/6] updating README | 4 files | 40s
⟐ [ultrawork:6/6] preparing commit | 4 files | 45s
```

### Multi-Agent Format
When running team or parallel workflows:
```
⟐ [team:{step}/{total}] {agent-name} running {skill} | {files} files | {elapsed}
```

Examples:
```
⟐ [team:1/5] coordinator assigning tasks | 0 files | 0s
⟐ [team:2/5] agent-1 running refactor | 4 files | 20s
⟐ [team:3/5] agent-2 running build-fix | 2 files | 45s
⟐ [team:4/5] waiting for agents to complete | 6 files | 60s
⟐ [team:5/5] merging results | 6 files | 72s
```

### Error Status
```
⟐ [ultrawork:3/6] ✗ tests failed (2 failures) | 3 files | 30s
⟐ [build-fix:1/3] retrying after test failure | 3 files | 32s
```

### Completion Status
```
⟐ [ultrawork:done] 4 files changed, all checks passed | 48s total
```

## Configuration Modes

### Verbose Mode
Show every sub-step, including skill internals:
```
⟐ [ultrawork:3/6] verify: running npm test | 3 files | 28s
⟐ [ultrawork:3/6] verify: running eslint | 3 files | 31s
⟐ [ultrawork:3/6] verify: running tsc | 3 files | 33s
⟐ [ultrawork:3/6] verify: all checks passed | 3 files | 35s
```

### Minimal Mode (default)
Show only phase changes — one line per workflow step:
```
⟐ [ultrawork:3/6] running verification | 3 files | 28s
```

### Disabled
Produce no status output. For clean scripted usage or when piping output.

## Elapsed Time

- Track from workflow start, not step start
- Use seconds for < 2 minutes, then switch to `Xm Ys` format
- Estimate, don't measure precisely — this is informational, not a benchmark

```
⟐ [autopilot:3/5] executing plan | 8 files | 1m 20s
```

## CLI-Specific Notes

| CLI | How Status Works |
|-----|-----------------|
| Copilot CLI | Use `report_intent` tool for intent. Status lines go in response text. |
| Claude Code | Output at start of each response. Could also use hooks for injection. |
| Codex CLI | Output at start of each response. |
| Cursor | Output at start of each response. |

For CLIs with native status bars (Claude Code's `statusline` setting), the agent's text-based status line supplements — not replaces — the native display.

## Rules

- Status lines are exactly ONE line — never multi-line
- Status lines go at the TOP of the response, before any explanation
- Use the `⟐` marker consistently — it makes status lines greppable
- File count is cumulative for the workflow, not per-step
- Never show status lines in final output to the user (e.g., commit messages, generated files)
- When disabled, produce ZERO status output — no partial, no summary
- Don't count reading files as "files touched" — only created/modified files
- Elapsed time is approximate — don't waste effort on precise measurement

## Not Responsible For

- Token/cost tracking (that's CLI-native or out of scope)
- Context window percentage (CLI-specific, not measurable from markdown skills)
- Git branch display (use doctor or verify for that)
- Replacing native status bars in CLIs that have them
- Rate limit monitoring (CLI-specific feature)
