# Skill: session-manager

> Manage, resume, and fork agent sessions with persistent state.
> Inspired by: oh-my-claudecode (project-session-manager)

## When to Trigger

- User says "resume session", "list sessions", "fork this", "save session"
- User says "new session" with a name or description
- When the user wants to explore an alternative approach without losing progress

## Workflow

### Step 1 — Detect Intent

Identify the session operation:
- **list** — show recent sessions with summaries
- **save** — persist current session state
- **resume** — load a previous session's context
- **fork** — branch current session into a new one

### Step 2 — List Sessions

Read `.sessions/` directory. For each `{session-id}/` subdirectory, read `state.md` and display:

```
Sessions:
| ID         | Branch         | Status | Last Active | Summary                    |
|------------|----------------|--------|-------------|----------------------------|
| ses_abc123 | feature/auth   | active | 2m ago      | Implementing OAuth flow    |
| ses_def456 | feature/api    | paused | 1h ago      | API refactoring            |
```

If no sessions exist, say so and offer to save the current one.

### Step 3 — Save Session

Create `.sessions/{session-id}/` with a generated ID (format: `ses_{8-char-hex}`).

Write `.sessions/{session-id}/state.md`:

```markdown
# Session: {session-id}

- **Created:** {timestamp}
- **Branch:** {current git branch}
- **Status:** active
- **Summary:** {user-provided or auto-generated 1-line summary}

## Plan
{Current plan or task description}

## Modified Files
{List of files created/edited this session}

## Decisions Made
{Key decisions and their rationale}

## Memories
{Any session-specific context worth preserving}

## Next Steps
{What was planned but not yet done}
```

### Step 4 — Resume Session

1. Read `.sessions/{session-id}/state.md`.
2. Display the session summary to the user.
3. Check if the git branch still exists. If so, suggest switching to it.
4. Load the plan, decisions, and next steps as current context.
5. Update status to `active` and timestamp.

### Step 5 — Fork Session

1. Save current session state (Step 3).
2. Create a new session with a new ID.
3. Copy the current state to the new session.
4. Add a `forked_from` field linking back to the original.
5. If possible, create a new git branch from the current one.
6. Update the original session status to `paused`.

## Output Format

### After save
```
Session saved: ses_abc123
  Branch: feature/auth
  Summary: Implementing OAuth flow
  Files tracked: 4
  State: .sessions/ses_abc123/state.md
```

### After resume
```
Resumed session: ses_abc123
  Branch: feature/auth (checked out)
  Last active: 1h ago
  Next steps:
    1. Finish token refresh logic
    2. Add unit tests for auth middleware
```

### After fork
```
Forked session: ses_abc123 -> ses_ghi789
  New branch: feature/auth-alt
  Original paused at: step 3/5
  Fork starts with same context, clean slate for changes.
```

## Rules

- Session IDs are auto-generated - never ask the user to pick an ID
- Always show session summary before resuming (let user confirm it's the right one)
- Store state as readable markdown, not opaque JSON
- Create `.sessions/` directory if it doesn't exist
- Don't delete sessions unless user explicitly asks
- Git branch operations are suggestions, not requirements - work without git too
- Keep state files compact - summaries, not full transcripts
- Forked sessions are independent after creation - changes don't propagate back

## Not Responsible For

- Git worktree management (too CLI-specific and environment-dependent)
- Terminal/tmux pane management
- Cross-machine session sync
- Session search across transcripts (use grep on `.sessions/`)
