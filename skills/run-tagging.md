# Skill: run-tagging

> Assign a unique identity to each agent session to prevent lane reuse and enable audit trails.
> Inspired by: oh-my-codex (fresh-run-tagging pattern)

## When to Trigger

- Automatically at session start (if enabled in project config)
- When resuming work — detect if previous run state is stale
- User says "tag this run", "new run", "fresh start"

## Workflow

### Step 1 — Generate run tag

Create a unique run ID:

```
run-{YYYY-MM-DD}-{short-hash}
```

Where `short-hash` is the first 6 characters of a hash derived from timestamp + random value.

Example: `run-2026-04-20-a7f3b1`

### Step 2 — Create run metadata

Create `.runs/{run-tag}/meta.json`:

```json
{
  "runTag": "run-2026-04-20-a7f3b1",
  "startedAt": "2026-04-20T14:30:22Z",
  "task": "{user's initial task description}",
  "status": "active",
  "cli": "{agent/cli name}",
  "project": "{project root path}"
}
```

### Step 3 — Tag artifacts

All artifacts produced during this session should reference the run tag:
- Plans: `.plans/{run-tag}-plan.md`
- Reports: include `Run: {run-tag}` in header
- Commits: include `[{run-tag}]` in commit message body (optional)
- Memory entries: tag with run ID for traceability
- Handoffs: `.handoffs/{run-tag}-handoff.md`

### Step 4 — Staleness check

Before reusing any previous run's artifacts:
1. Read the previous run's `meta.json`
2. If `status` is `active` and age > 2 hours → mark as `stale`
3. Stale runs require explicit `--resume` to continue; otherwise start fresh
4. Completed runs (`status: "done"`) are never resumed — always start a new run

### Step 5 — Close run

At session end, update `meta.json`:

```json
{
  "status": "done",
  "endedAt": "2026-04-20T16:45:00Z",
  "summary": "{brief summary of what was accomplished}",
  "artifacts": ["list", "of", "artifact", "paths"]
}
```

## Output Format

```
🏷️ Run: run-2026-04-20-a7f3b1
   Task: {task description}
   Started: 2026-04-20 14:30 UTC
   Status: active
```

When detecting a previous run:

```
⚠️ Previous run detected: run-2026-04-19-c3d2e1
   Status: active (stale — 18 hours old)
   Task: "refactor auth module"

   Options:
   1. Resume previous run → loads context from run-2026-04-19-c3d2e1
   2. Start fresh run     → new tag, clean slate
   3. View previous run   → inspect artifacts without resuming
```

## Rules

- Every session gets a unique run tag — no reuse of active tags
- Run tags are SHORT and human-readable (not full UUIDs)
- `.runs/` directory should be gitignored — run metadata is ephemeral
- Staleness threshold: 2 hours by default (configurable)
- Closing a run is best-effort — if the session crashes, the run stays `active` until staleness kicks in
- Run tagging is OPTIONAL — projects can disable it. Don't force it on simple tasks.
- When folded into session-protocol, run tagging happens at Step 0 (before any other work)

## Not Responsible For

- Persisting session memory across runs (see remember skill)
- Structured handoff documents (see handoff skill)
- Git branch management or CI/CD tagging
- Preventing lane reuse at the infrastructure level — this is advisory, not enforced
