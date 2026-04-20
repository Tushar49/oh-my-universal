# Skill: self-improve

> Analyze agent failures and improve skill/instruction files to prevent recurrence.
> Inspired by: oh-my-claudecode (self-improve)

## When to Trigger

- User says "improve yourself", "learn from this failure", "why do you keep making this mistake"
- After 2+ retries on the same task
- After a session with repeated failures or poor results
- User explicitly asks to analyze recent mistakes

## Workflow

### Step 1 — Identify the Failure

Examine recent context for what went wrong:
- What task was attempted?
- What was the expected outcome vs actual outcome?
- How many retries were needed?
- What error messages or bad outputs appeared?

### Step 2 — Root Cause Analysis

Trace the failure back to instructions:
- Which skill file was active during the failure?
- What instruction was followed (or missing)?
- Was the issue: unclear wording, wrong assumption, missing edge case, conflicting rules?
- Check `.memory/improvements.md` for past fixes to the same area (avoid regressions).

### Step 3 — Propose Improvement

Generate a specific, minimal edit to the relevant skill or instruction file:

```markdown
## Proposed Change

**File:** skills/{skill}.md
**Section:** {section name}
**Problem:** {what the current text causes}
**Confidence:** HIGH / MEDIUM / LOW

```diff
- old instruction text
+ improved instruction text
```

**Expected Impact:** {how this prevents the failure}
```

Present the diff to the user. Do NOT auto-apply.

### Step 4 — Apply and Log (with approval)

After user approves:
1. Apply the edit to the skill file.
2. Append an entry to `.memory/improvements.md`:

```markdown
## {date} — {topic}
- **File changed:** {path}
- **Problem:** {1-line description}
- **Fix:** {1-line description of change}
- **Confidence:** {level}
- **Triggered by:** {what failure prompted this}
```

## Output Format

```
Self-Improvement Analysis
=========================

Problem Observed:
  {What went wrong}

Root Cause:
  {Why current instructions led to failure}

Affected File: skills/{name}.md, line ~{N}

Proposed Change:
  - {old instruction}
  + {improved instruction}

Confidence: {HIGH/MEDIUM/LOW}
Expected Impact: {How this prevents recurrence}

Apply this change? (y/n)
```

## Rules

- NEVER auto-apply changes - always show diff and wait for user approval
- One improvement per invocation - don't batch unrelated fixes
- Keep edits minimal and surgical - don't rewrite entire skill files
- Check `.memory/improvements.md` before proposing to avoid reverting past fixes
- If confidence is LOW, say so and explain why the fix might not help
- Improvements must be concrete instruction changes, not vague suggestions
- Create `.memory/improvements.md` if it doesn't exist

## Not Responsible For

- Fixing code bugs (see review skill)
- Writing new skills from scratch (that's a user decision)
- Changing user preferences or project config
- Improving performance or speed - only correctness and clarity
