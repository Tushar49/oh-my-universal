# Skill: session-protocol

> End-of-session cleanup workflow. Updates docs, saves memory, prepares commit.
> This is a WORKFLOW SPEC — agents should follow this at end of every session.

## When to Trigger

Agent should proactively run this when:
- User says "done", "wrap up", "that's all"
- Session is ending
- After completing a major task

## Workflow

```
1. DOC-MAINTAIN  → Run skills/doc-maintainer.md on affected docs
2. REMEMBER      → Run skills/remember.md to save learnings
3. PROGRESS      → Update progress tracker (if project has one)
4. VERIFY        → Quick verify on final state (skills/verify.md fast mode)
5. PREPARE       → Stage changes, suggest commit message
6. REPORT        → Summarize what was done this session
```

### Step Details

**1. Doc Maintenance**
- Check if README, API docs, or config docs need updating
- Only update docs that are DIRECTLY affected by session changes

**2. Save Memory**
- Extract any conventions, gotchas, or decisions discovered
- Save via native memory tools (preferred) or .memory/ files (fallback)
- Don't save obvious things — only project-specific surprises

**3. Update Progress**
- If project has docs/PROGRESS.md or similar tracker, mark items done
- Add new discovered tasks to backlog

**4. Quick Verify**
- Run project's test/build/lint if fast (< 30 seconds)
- Skip slow checks unless user asks

**5. Prepare Commit**
- Stage relevant changes
- Suggest a descriptive commit message
- DO NOT auto-commit. Prepare the recommendation and let user decide.

**6. Session Report**
```markdown
## Session Summary

**Duration:** {approximate}
**Changes:** {N} files modified, {N} files created
**Key outcomes:**
- {what was accomplished}
- {what was learned}

**Left to do:**
- {remaining items}

**Commit ready:** {yes/no} — suggested message: "{message}"
```

## Rules

- This is a RECOMMENDATION workflow, not a mandatory gate
- Never auto-commit without user approval
- Keep it fast — the session is ending, user wants to wrap up
- If the session was just Q&A with no code changes, skip steps 1-5

## Output Format

```markdown
## Session Summary

**Duration:** {approximate}
**Changes:** {N} files modified, {N} files created
**Key outcomes:**
- {what was accomplished}
- {what was learned}

**Left to do:**
- {remaining items}

**Commit ready:** {yes/no} — suggested message: "{message}"
```

## Not Responsible For

- Code implementation (see ultrawork, plan)
- Code review beyond quick sanity check (see review skill)
- Full verification (see verify skill)
