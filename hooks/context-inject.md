# Hook: context-inject

> At session start, inject project conventions, recent changes, and active plan from memory.

## Trigger

Fires at session start (after `memory-load`) and after context compaction (to re-inject essentials).

## Behavior

1. **Load project conventions** — read `.memory/conventions.md` for project-specific rules
2. **Load recent changes** — read git log (last 5 commits) to understand recent momentum
3. **Load active plan** — inject `.memory/active-plan.md` if it exists
4. **Load relevant context** — based on the user's first message, pre-load likely-needed files
5. **Set agent personality** — apply any project-specific tone, style, or behavioral instructions

## Input

- `.memory/` contents (conventions, active plan, recent state)
- Git log (recent commits)
- User's first message (for relevance filtering)
- Project configuration files

## Output / Side Effects

- Agent context populated with project knowledge
- Active plan resumed (if any)
- Recent change awareness established
- Agent ready to work without needing re-orientation

## Example

```
💉 context-inject: session start
   Conventions: 12 rules loaded (TypeScript strict, ESLint, Jest)
   Recent: 3 commits in last 24h (auth middleware, tests, docs)
   Active plan: "Add rate limiting" — step 3/7 in progress
   Pre-loaded: src/middleware/, package.json, tsconfig.json
```
