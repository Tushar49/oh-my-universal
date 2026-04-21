# Skill: cost-tracker

> Track token usage, API costs, and context efficiency across sessions.
> Inspired by: pro-workflow cost telemetry, awesome-claude-code burn-rate trackers

## When to Trigger

- User says "show costs", "track spending", "budget check", "how much did that cost"
- User says "cost report", "token usage", "spending summary"
- Auto-enabled in ecomode (skills/ecomode.md)
- At session end for summary reporting

## Metrics Tracked

### Per-Skill Costs
- Tokens in (prompt) per skill invocation
- Tokens out (completion) per skill invocation
- Total cost per skill (based on model pricing)

### Session-Level
- Total tokens in/out for the session
- Total estimated cost ($)
- Cost per task completed
- Average tokens per file changed
- Cost per test fixed (when used with build-fix/tdd)

### Efficiency Ratios
- Tokens per file changed — lower is better
- Cost per test fixed — tracks build-fix efficiency
- Context utilization — how much of the context window was used vs wasted
- Retry cost — extra tokens spent on failed attempts

## Budget Alerts

| Threshold | Action |
|-----------|--------|
| 50% of budget | Info: "Halfway through session budget" |
| 75% of budget | Warning: "Approaching budget limit — consider ecomode" |
| 90% of budget | Alert: "Near budget limit — switching to ecomode recommended" |
| 100% of budget | Stop: "Budget exhausted — pause and review" |

Budget is configured in project config or session state:
```yaml
# config/agent.yml or .agent/config.yml
budget:
  session_max: 5.00      # USD per session
  daily_max: 20.00       # USD per day
  alert_threshold: 0.75  # fraction before warning
```

## History

Cost data is appended to `.metrics/costs.md` after each session:

```markdown
## 2025-01-15 — Session abc123

| Metric | Value |
|--------|-------|
| Duration | 42 min |
| Tokens in | 125,400 |
| Tokens out | 18,200 |
| Est. cost | $2.14 |
| Files changed | 8 |
| Tests fixed | 3 |
| Cost/file | $0.27 |
| Cost/test-fix | $0.71 |

### Per-Skill Breakdown
| Skill | Invocations | Tokens | Cost |
|-------|-------------|--------|------|
| plan | 1 | 12,400 | $0.19 |
| build-fix | 3 | 45,600 | $0.68 |
| verify | 2 | 8,200 | $0.12 |
| tdd | 2 | 34,100 | $0.51 |
```

## Workflow

### Step 1 — Initialize
At session start, initialize counters: tokens_in, tokens_out, cost, files_changed, skill_usage map.

### Step 2 — Track
After each skill invocation, record token usage and compute incremental cost.
Use model pricing from config or sensible defaults.

### Step 3 — Alert
Check running total against budget thresholds after each operation.
If threshold crossed, emit the appropriate alert level.

### Step 4 — Report
At session end (or on demand), produce the cost summary.
Append to `.metrics/costs.md` for historical tracking.

## Output Format

### Quick Check
```
💰 Session Cost — $2.14 / $5.00 budget (43%)
   Tokens: 125.4K in, 18.2K out
   Efficiency: $0.27/file, $0.71/test-fix
```

### Full Report
```
Cost Report — Session abc123
=============================
Duration:      42 min
Total cost:    $2.14 / $5.00 (43%)
Tokens in:     125,400
Tokens out:    18,200
Files changed: 8
Tests fixed:   3

Per-Skill:
  plan       — 1x  — $0.19 (9%)
  build-fix  — 3x  — $0.68 (32%)
  tdd        — 2x  — $0.51 (24%)
  verify     — 2x  — $0.12 (6%)
  other      — 5x  — $0.64 (30%)

Efficiency:
  $0.27 per file changed
  $0.71 per test fixed
  78% context utilization
```

## Integration Points

- **ecomode** — cost-tracker auto-enables in ecomode; ecomode triggers when budget alert fires
- **session-manager** — cost summary included in session handoff notes
- **hud** — cost ticker shown in HUD status line when enabled
- **autopilot** — cost tracked per autopilot phase for ROI analysis

## Rules

- Cost estimates are approximate — based on published model pricing, not actual billing
- Never block operations based on cost alone — alerts are advisory
- History file (`.metrics/costs.md`) is append-only — never delete previous entries
- When model pricing is unknown, use conservative estimates (higher rather than lower)
- Token counts should include both user messages and tool call overhead
- In ecomode, track savings compared to normal mode

## Not Responsible For

- Actual billing or payment processing
- Model-specific token counting (use approximate heuristics)
- Setting budget limits (that's user config)
- Optimizing prompts to reduce cost (that's ecomode's job)
