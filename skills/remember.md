# Skill: remember

> Persist context and learnings across agent sessions.
> Stores project-specific memory that any future session can read.
> Inspired by: oh-my-claudecode (remember), clawhip (memory-offload)

## When to Trigger

- End of every session: save key learnings
- User says "remember this", "save this for later"
- When a pattern or convention is discovered that should persist
- When a bug fix reveals something non-obvious about the codebase

## Memory Backend Priority

1. Use the platform's native memory/store tools if available (e.g., `store_memory` in Copilot CLI).
2. Fall back to repo-local `.memory/` files.
3. If neither available, report memory candidates to the user.

## Memory Storage

Memories are stored in `.memory/` at the project root:

```
.memory/
  conventions.md       # Coding conventions discovered
  gotchas.md          # Non-obvious things that trip you up
  decisions.md        # Architecture decisions and why
  session-log.md      # What happened in each session
```

### conventions.md
```markdown
# Project Conventions

| Convention | Example | Discovered |
|-----------|---------|------------|
| {pattern} | {example} | {date} |
```

### gotchas.md
```markdown
# Gotchas

| Gotcha | Why it matters | Discovered |
|--------|---------------|------------|
| {issue} | {impact} | {date} |
```

### decisions.md
```markdown
# Architecture Decisions

## {YYYY-MM-DD}: {Decision Title}
**Context:** {why this came up}
**Decision:** {what was decided}
**Alternatives:** {what was considered}
**Consequences:** {what this means going forward}
```

### session-log.md
```markdown
# Session Log

## {YYYY-MM-DD HH:MM} — {summary}
- {what was done}
- {what was learned}
- {what's left to do}
```

## How to Save

At the end of a session (or when triggered):
1. Review what was done this session
2. Extract conventions, gotchas, or decisions worth saving
3. Append to the appropriate memory file
4. Don't duplicate existing entries

## How to Load

At the START of every session:
1. Check if `.memory/` exists
2. If yes, read `conventions.md` and `gotchas.md` (quick context load)
3. Read `decisions.md` only if working on architecture
4. Read `session-log.md` only if user asks "what did we do last time?"

## Rules

- Keep memories SHORT. One line per convention, one paragraph per decision.
- Don't save obvious things (language syntax, common patterns)
- DO save project-specific quirks that would surprise a new contributor
- .memory/ files should be gitignored (add to .gitignore if not already present)
- If user wants shared memory, move to `docs/` instead
- Not responsible for: project documentation (see doc-maintainer), code review (see review skill)
