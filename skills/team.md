# Skill: team

> Multi-agent task delegation. Break complex tasks into subtasks,
> delegate to parallel subagents, merge results.
> Inspired by: oh-my-codex ($team), oh-my-claudecode (team), oh-my-openagent (Sisyphus)

## When to Trigger

- Task naturally decomposes into 3+ independent subtasks
- User says "team this", "parallelize", "delegate"
- When speed matters and subtasks don't depend on each other
- Complex cross-cutting tasks (e.g., update 5 modules independently)

## When NOT to Use

- Subtasks depend on each other (do them serially instead)
- Task is small enough for one agent (overhead of delegation > time saved)
- Only 1-2 subtasks (just do them sequentially)

## Workflow

### Step 1 — Decompose

Break the task into independent subtasks:

```markdown
## Task Decomposition: {main task}

| # | Subtask | Scope | Dependencies | Can parallelize? |
|---|---------|-------|-------------|-----------------|
| 1 | {subtask} | {files/area} | None | Yes |
| 2 | {subtask} | {files/area} | None | Yes |
| 3 | {subtask} | {files/area} | Subtask 1 | No (serial) |
```

**Rules for decomposition:**
- Each subtask must have a clear, verifiable deliverable
- Subtasks must NOT modify the same files (merge conflicts)
- Each subtask must include enough context to work independently

### Step 2 — Delegate

If the platform supports parallel subagents:
- Launch one subagent per independent subtask
- Each gets: task description, relevant file paths, constraints, expected output
- Max 5 parallel subagents (resource limits)

**Fallback if no subagent support:**
- Do each subtask serially
- Complete one fully before starting the next
- Use clear section headers: `## Subtask 1: {name}`, `## Subtask 2: {name}`

### Step 3 — Monitor

For parallel execution:
- Wait for all subagents to complete
- Collect results from each

For serial execution:
- Verify each subtask before moving to the next

### Step 4 — Merge

1. Review all subtask outputs for consistency
2. Resolve any conflicts (same file modified, naming inconsistencies)
3. Run verification on the combined result (invoke verify skill if platform supports it, otherwise follow skills/verify.md workflow)
4. Report merged result

## Output Format

```markdown
## Team Result: {main task}

**Subtasks:** {N} ({N} parallel, {N} serial)
**Status:** COMPLETE / PARTIAL ({N}/{N} succeeded)

### Subtask Results
| # | Subtask | Status | Output |
|---|---------|--------|--------|
| 1 | {name} | ✓ done | {summary} |
| 2 | {name} | ✓ done | {summary} |
| 3 | {name} | ✗ failed | {error} |

### Merge Notes
- {any conflicts resolved}
- {any manual steps needed}

### Verification
{result of combined verification}
```

## Rules

- Always verify the COMBINED result, not just individual subtasks
- If a subtask fails, complete the others and report partial results
- Don't delegate trivially small tasks (overhead > benefit)
- Each subtask prompt must be self-contained (subagents don't share context)

## Not Responsible For

- Individual code review (see review)
- Planning the overall approach (see plan)
