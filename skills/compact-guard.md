# Skill: compact-guard

> Protect critical state through context compaction cycles. Never lose the thread.
> Inspired by: pro-workflow compact-guard

## When to Trigger

- Automatically when context usage exceeds ~85% capacity
- User says "save state", "prepare for compaction", "preserve context"
- Before any operation that might trigger context window reduction
- When the agent detects it's approaching token limits

## Workflow

### Step 1 — Identify Critical State

Before ANY compaction or context reduction, inventory what MUST survive:

| Priority | Category | Example |
|----------|----------|---------|
| P0 | Active plan | Current task steps, progress, next action |
| P1 | Key decisions | Architecture choices, rejected alternatives, why |
| P2 | Modified files | Every file created/edited this session with summary of changes |
| P3 | Open questions | Unresolved issues, things waiting on user input |
| P4 | Test results | Last test run status, failing tests, error messages |
| P5 | Memories | Session-specific context, learned patterns |

### Step 2 — Save to Persistent Storage

Write critical state to `.memory/compact-state.md`:

```markdown
# Compact Guard State — {timestamp}

## Active Plan
{current task description and progress}
- [ ] Step 1: {done/in-progress/pending}
- [ ] Step 2: {done/in-progress/pending}

## Key Decisions
- {decision 1}: chose X because Y
- {decision 2}: rejected Z because W

## Modified Files
| File | Action | Summary |
|------|--------|---------|
| src/auth.ts | edited | Added token refresh logic |
| tests/auth.test.ts | created | 3 test cases for token flow |

## Open Questions
- {question 1} — waiting on {what}
- {question 2} — blocked by {what}

## Test Status
- Last run: {pass/fail} — {N} passed, {N} failed
- Key failure: {test name} — {error summary}

## Context Notes
- {anything else the next context window needs to know}
```

### Step 3 — Verify After Compaction

After context is compacted or a new context window begins:

1. Check if `.memory/compact-state.md` exists
2. Read it and compare against current context
3. For any P0-P2 items missing from context, re-inject them
4. For P3-P5 items, summarize and make available on demand
5. Confirm with user: "Restored state from compaction. Current task: {summary}. Continue?"

### Step 4 — Clean Up

Once the state has been successfully restored:
- Archive the compact-state file to `.memory/compact-history/{timestamp}.md`
- Don't delete — keep for forensic review if needed

## Output Format

### Before compaction
```
🛡️ COMPACT GUARD: Saving critical state

  Plan: 3/7 steps complete — "Implementing OAuth flow"
  Decisions: 2 recorded
  Modified files: 4 tracked
  Open questions: 1 pending
  Test status: 12/14 passing

  State saved to .memory/compact-state.md
  Safe to compact.
```

### After compaction
```
🛡️ COMPACT GUARD: Restoring state

  Loaded: .memory/compact-state.md (saved 3m ago)
  Plan: restored — resuming at step 4/7
  Files: 4 modified files re-identified
  Context: ready to continue

  Resuming: "Implementing OAuth flow" — next step: add refresh token endpoint
```

## Rules

- P0 (active plan) is NON-NEGOTIABLE. If the plan is lost, the session is effectively broken.
- Save state BEFORE compaction, not after. Once context is reduced, the state is gone.
- Keep the state file compact — summaries, not full file contents. Link to files, don't inline them.
- State file is markdown, not JSON — human-readable for manual recovery.
- If no compaction occurs, the state file is still useful as a session checkpoint.
- Don't save state for trivial sessions (quick one-off questions). Only for multi-step tasks.
- Archive old state files, don't delete them. Storage is cheap, lost context is expensive.

## Not Responsible For

- Deciding when to compact (that's the runtime's job)
- Managing conversation history or token counts
- Session persistence across days (use session-manager for that)
- Backup of actual file contents (use git for that)
