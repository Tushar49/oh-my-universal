# Hook: skill-start

> Track skill activation — set workflow state and start monitoring.

## Trigger

Fires when any skill activates — whether user-invoked, keyword-triggered, or called by another skill.

## Behavior

1. **Set workflow state** — record which skill is active in session state (prevents conflicting skills)
2. **Start HUD** — show skill name and expected steps in status line
3. **Tag run** — assign a unique run ID for tracking in `.runs/` or session log
4. **Load skill memory** — check `.memory/` for previous runs of this skill and their outcomes
5. **Validate preconditions** — check that skill's prerequisites are met (e.g., clean worktree for commit skills)

## Input

- Skill name and trigger source (user, keyword, another skill)
- Skill definition file contents
- Current session state (active plan, other running skills)
- Previous run history for this skill

## Output / Side Effects

- Session state updated with active skill
- HUD shows skill progress
- Run ID assigned and logged
- Precondition failure blocks skill start (with explanation)

## Example

```
🎯 skill-start: pre-commit-check (triggered by user)
   Run: #run-2024-0615-001
   Preconditions: ✓ staged changes exist, ✓ no other skill active
   Steps: verify → review → security-scan → report
   HUD: [pre-commit-check] Step 1/4
```
