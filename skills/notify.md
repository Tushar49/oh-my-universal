# Skill: notify

> Send notifications when long tasks complete.
> Platform-adaptive: Discord webhook, system notification, or console output.

## When to Trigger

- After a long-running task completes(build, test suite, batch processing)
- After background agent finishes
- User says "notify me when done"

## Workflow

### 1. Console Output (always available)
```
🔔 Task complete: {task name}
   Result: {PASS/FAIL}
   Duration: {time}
```

### 2. System Notification (if available)
- Windows: PowerShell `New-BurntToastNotification` or `[System.Windows.Forms.MessageBox]`
- macOS: `osascript -e 'display notification'`
- Linux: `notify-send`

### 3. Discord Webhook (if configured)
If `config/notify.yml` exists with a webhook URL:
```yaml
discord:
  webhook_url: "https://discord.com/api/webhooks/..."
  mention: "@user"  # optional
```

Send via:
```bash
curl -H "Content-Type: application/json" \
  -d '{"content":"🔔 Task complete: {name} — {result}"}' \
  {webhook_url}
```

## Output Format

```
🔔 {project}: {task name}
Result: {PASS ✓ / FAIL ✗}
Duration: {time}
Details: {1-line summary}
```

## Rules

- Always output to console (minimum viable notification)
- Only attempt system/Discord notifications if configured
- Don't block on notification delivery failures
- Keep messages SHORT — just the essentials

## Not Responsible For

- Task execution (see other skills)
- Error handling (see build-fix)
