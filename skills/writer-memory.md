# Skill: writer-memory

> Enhanced persistent context for writing projects — maintains tone, style, narrative state, and continuity across sessions.
> Inspired by: oh-my-claudecode (writer-memory), clawhip (memory-offload)

## When to Trigger

- User is working on documentation, blog posts, technical writing, or creative writing
- User says "remember the tone", "keep the style consistent", "continue where we left off"
- When continuing a multi-session writing project
- User says "remember this", "what did we decide about X" (in a writing context)
- Background: auto-capture decisions and corrections during any writing session

## Workflow

### Step 1 — Initialize Memory Store

Check if `.memory/writing/` exists at the project root.
- If yes, load the style guide and context for the current project
- If no, create `.memory/writing/` with empty template files

Support multiple projects via namespaces:
```
.memory/writing/
  {project-name}/
    style-guide.md
    context.md
    outline.md
    continuity-log.md
```

Default project is `default/` if no project name is specified.

### Step 2 — Capture Context (Auto + Explicit)

**Auto-capture** (runs in background during writing sessions):
- Every architectural or structural decision ("let's use numbered lists", "keep sections under 500 words")
- Every failed approach ("that introduction was too formal, rewrite it")
- Every user correction ("don't use passive voice", "shorter paragraphs")
- Tone and voice observations from existing content

**Explicit capture** (user triggers):
- "Remember this" — store the specific fact or decision
- "Remember the tone" — analyze current output and save tone profile
- "Save style guide" — generate a style guide from accumulated observations

### Step 3 — Context Injection

At session start (for writing tasks):
1. Read `style-guide.md` — apply tone, voice, and formatting rules
2. Read `context.md` — understand current project state
3. Read `outline.md` — know the structure and what's done vs pending
4. Skip `continuity-log.md` unless user asks "what did we write last time?"

### Step 4 — Memory Maintenance

**Staleness check:** Flag memories older than 30 days without reference for user review.
- Prompt: "These writing memories haven't been referenced in 30+ days: {list}. Keep or archive?"

**Dedup:** Before saving a new memory, check if a similar one already exists. Update rather than duplicate.

## Memory Files

### style-guide.md
```markdown
# Style Guide — {project name}

> Last updated: {YYYY-MM-DD}

## Voice & Tone
- {e.g., "Conversational but precise. Second person (you)."}

## Formatting Rules
- {e.g., "Headers use sentence case. Max 3 heading levels."}

## Word Preferences
| Use | Don't Use |
|-----|-----------|
| {preferred} | {avoided} |

## Sentence Style
- {e.g., "Short sentences. Max 20 words. Active voice."}
```

### context.md
```markdown
# Project Context — {project name}

> Last updated: {YYYY-MM-DD}

## Current State
{what's been written, what's in progress}

## Key Decisions
| Decision | Reason | Date |
|----------|--------|------|
| {decision} | {why} | {YYYY-MM-DD} |

## Open Questions
- {unresolved questions about content or direction}
```

### outline.md
```markdown
# Outline — {project name}

> Last updated: {YYYY-MM-DD}

## Structure
- [ ] {section 1} — {status: draft/done/pending}
- [ ] {section 2} — {status}
```

### continuity-log.md
```markdown
# Continuity Log — {project name}

## {YYYY-MM-DD} — {session summary}
- Wrote: {what was produced}
- Changed: {what was revised}
- Next: {what's planned}
```

## Output Format

When user queries memory:
```markdown
## Writer Memory: {query}

**Project:** {project name}
**Relevant memories:**
- {memory 1 with date}
- {memory 2 with date}

**Style reminders:**
- {active style rules that apply to this context}
```

## Rules

- Keep memories SHORT. One line per preference, one paragraph per decision.
- Don't store obvious things (basic grammar, universal style rules)
- DO store project-specific voice, terminology, and structural choices
- `.memory/writing/` should be gitignored unless user explicitly wants to share
- Use platform-native memory tools (e.g., `store_memory` in Copilot CLI) in ADDITION to file-based storage, not instead of
- Different from `remember` skill: writer-memory handles writing content (tone, style, narrative). Remember handles code context (conventions, gotchas). They complement each other.

## Not Responsible For

- Code conventions or technical decisions (see remember skill)
- Project documentation generation (see wiki or doc-maintainer skill)
- Code review or analysis (see review skill)
- File-level persistent context (see session-protocol skill)
