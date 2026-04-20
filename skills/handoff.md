# Skill: handoff

> Structured state handoff between agent runs for seamless session continuity.
> Inspired by: oh-my-codex (candidate-handoff pattern), oh-my-claudecode (artifact-first handoff)

## When to Trigger

- User says "hand off", "prepare handoff", "end of day", "save state"
- At end of a session (as part of session-protocol, after step 5)
- When switching between agents or CLI tools mid-task
- Auto at session end (if enabled)

## Workflow

### Step 1 — Gather state

Collect the current session state:
1. **What was done** — completed tasks, changes made, tests passed
2. **What's pending** — remaining items, next steps
3. **Key decisions** — architectural choices, tradeoffs, rationale
4. **Blockers** — anything preventing progress
5. **Files modified** — list with change type (new/modified/deleted)
6. **Test results** — last test run status, failures if any
7. **Open questions** — things that need user input or clarification

### Step 2 — Resolve run tag

If run-tagging is active, use the current run tag for the handoff filename.
Otherwise, generate a timestamp-based name: `handoff-{YYYY-MM-DD}-{HHMMSS}`.

### Step 3 — Write handoff document

Save to `.handoffs/{run-tag}-handoff.md` (create `.handoffs/` if it doesn't exist).

Keep the document BOUNDED:
- Reference large artifacts by path, don't embed them inline
- Summarize test output, don't paste full logs
- Link to plans and specs rather than duplicating content

### Step 4 — Update run metadata

If run-tagging is active, update `.runs/{run-tag}/meta.json` with:
- `status: "handed-off"`
- `handoffPath: ".handoffs/{run-tag}-handoff.md"`

### Step 5 — Confirm handoff

Report to the user what was saved and where.

## Loading a Handoff (Session Start)

At the start of a new session:

1. Check `.handoffs/` for pending handoff files
2. If found, present the latest handoff summary to the user
3. User chooses:
   - **Accept** — load full context and continue from where the previous session left off
   - **Reject** — start fresh, ignore the handoff
   - **Partial** — cherry-pick specific items from the handoff to carry forward
4. After loading, mark the handoff as consumed: rename to `{filename}.loaded` or add `loaded: true` to metadata

## Output Format

### Handoff Document

```markdown
## Handoff: {task description}
**Run:** {run-tag}
**Date:** {YYYY-MM-DD HH:MM UTC}
**Status:** IN_PROGRESS | BLOCKED | READY_FOR_REVIEW

### Done
- [x] {completed item} ({file or detail})
- [x] {completed item}

### Remaining
- [ ] {pending item}
- [ ] {pending item}

### Key Decisions
- {decision}: {rationale} (see {reference if any})

### Blockers
- {blocker description}

### Open Questions
- {question needing user input}

### Files Modified
| File | Change | Notes |
|------|--------|-------|
| src/auth.ts | new | JWT authentication module |
| package.json | modified | added jsonwebtoken dep |
| src/old-auth.ts | deleted | replaced by new module |

### Test Results
- Last run: {PASS/FAIL} — {N} passed, {N} failed
- Failures: {brief summary or "none"}

### Artifacts
| Kind | Path | Description |
|------|------|-------------|
| plan | .plans/auth-plan.md | Implementation plan |
| eval | .artifacts/review-001.md | Code review findings |

### Recommended Next Steps
1. {most important next action}
2. {second priority}
3. {third priority}
```

### Session Start (Handoff Found)

```
📋 Pending handoff found: run-2026-04-20-a7f3b1
   Task: "refactor auth module"
   Status: IN_PROGRESS
   Done: 3 items | Remaining: 2 items | Blockers: 1

   Options:
   1. Accept  → continue from handoff (loads full context)
   2. Reject  → start fresh (handoff preserved but ignored)
   3. Partial → cherry-pick items to carry forward
```

## Rules

- Handoff documents are HUMAN-READABLE markdown — a person should be able to understand the state without tools
- Keep handoffs BOUNDED — reference artifacts by path, don't embed large content
- `.handoffs/` directory should be gitignored — handoffs are operational, not project artifacts
- Never auto-accept a handoff — always present it to the user for review
- Handoff format is CLI-AGNOSTIC — a handoff from Claude Code must be loadable in Copilot CLI and vice versa
- One handoff per run — if multiple handoffs exist, present the most recent first
- Stale handoffs (> 7 days old) should be flagged with a warning but still loadable
- Extends session-protocol: handoff is a more structured version of session-protocol's step 6

## Not Responsible For

- Persisting memory/conventions across sessions (see remember skill)
- Run identity and tagging (see run-tagging skill)
- Session cleanup or commit preparation (see session-protocol skill)
- Merging work from parallel agent runs — handoff is sequential, not concurrent
