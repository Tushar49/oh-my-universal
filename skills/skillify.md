# Skill: skillify

> Create new skills from observed patterns. When the agent does something
> useful repeatedly, extract it into a reusable skill file.
> Inspired by: oh-my-claudecode (skillify)

## When to Trigger

- Agent notices it's doing the same workflow 3+ times
- User says "make this a skill", "save this workflow"
- After developing a useful pattern that should be reusable

## Workflow

### Step 1 — Identify the Pattern

What makes a good skill?
- It's a repeatable workflow (not a one-off task)
- It has clear inputs and outputs
- It's project-agnostic (works across codebases)
- It would save time if standardized

### Step 2 — Extract the Skill

Create a new file in `skills/{name}.md` following this template:

```markdown
# Skill: {name}

> {1-line description of what this skill does}
> Inspired by: {source, if any}

## When to Use

- {trigger condition 1}
- {trigger condition 2}

## Workflow

### Step 1 — {name}
{instructions}

### Step 2 — {name}
{instructions}

## Output Format

{what the output looks like}

## Rules

- {rule 1}
- {rule 2}
- Not responsible for: {boundary}
```

### Step 3 — Integrate

1. Add the skill to the routing tables:
   - `.github/copilot-instructions.md` skill table
   - `AGENTS.md` skill list
   - `.claude/skills/oh-my-universal/SKILL.md` router
   - `.github/instructions/skills.instructions.md` quick reference
2. Update `docs/PROGRESS.md`
3. Commit with message: `feat: add {name} skill`

### Step 4 — Test

Try using the skill by name. Verify:
- The trigger conditions work
- The workflow produces useful output
- The rules prevent misuse

## Quality Checklist

Before committing a new skill:
- [ ] Has clear "When to Use" triggers
- [ ] Has structured workflow steps
- [ ] Has output format template
- [ ] Has "Not responsible for" boundary
- [ ] Is platform-agnostic (no CLI-specific assumptions)
- [ ] Uses advisory language ("should", not "will auto-trigger")
- [ ] Is concise (under 100 lines)

## Rules

- Skills should be SMALL and focused. One skill = one workflow.
- If a skill does 3+ unrelated things, split it.
- Every skill must have a "Not responsible for" section.

## Not Responsible For

- Using other skills (see their respective files)
