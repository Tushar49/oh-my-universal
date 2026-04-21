# Hooks — Agent Lifecycle Event Handlers

> Hooks fire automatically at lifecycle events. Unlike skills (invoked on demand), hooks are reactive — they run without being asked.

## What Are Hooks?

Hooks are short instruction files that tell the agent what to do at specific moments:
- **Session starts** → load context, show status
- **Before a tool call** → check permissions, guard against destructive ops
- **After a tool call** → verify results, log outcomes
- **On failure** → recover, log, retry
- **At session end** → save state, produce handoff

The agent reads these definitions and applies them at the right moments. No runtime needed — pure behavioral instructions.

## How Hooks Work

1. Agent reads `hooks/` at session start
2. Builds internal event → hook mappings
3. Before/after each lifecycle event, checks for matching hooks
4. Executes hook behavior inline (not as a separate process)

Hooks are advisory in markdown-only CLIs — the agent follows them as instructions. In CLIs with native hook support (Claude Code `hooks.json`, Codex `.codex/hooks.json`), they can be enforced programmatically.

## Hook Categories

| Category | Hooks | Purpose |
|----------|-------|---------|
| **Session** | session-start, session-end | Lifecycle bookends — load/save context |
| **Tool** | pre-tool, post-tool, tool-failure | Wrap every tool call with guards and verification |
| **Skill** | skill-start, skill-end | Track skill activation and completion |
| **Keyword** | keyword-detector | Auto-trigger skills from user input |
| **Memory** | memory-save, memory-load | Persist and retrieve learnings |
| **Safety** | permission-check, dirty-guard-hook, context-guard | Prevent destructive ops, manage resources |
| **Quality** | verify-deliverables, code-simplifier-hook | Ensure completeness and simplicity |
| **Subagent** | subagent-start, subagent-end | Monitor delegated work |
| **Context** | pre-compact, context-inject | Manage context window lifecycle |
| **Total** | **19 hooks** | |

## Hook File Format

Each hook is a markdown file (~20-40 lines) with:

```markdown
# Hook: {name}

> One-line description

## Trigger
When this hook fires.

## Behavior
What the agent does.

## Input
What context the hook receives.

## Output / Side Effects
What changes after the hook runs.

## Example
Concrete example of the hook in action.
```

## Hooks vs Skills

| | Hooks | Skills |
|---|---|---|
| **Activation** | Automatic — fires on events | Manual — invoked by user or agent |
| **Duration** | Instant — inline check/action | Extended — multi-step workflow |
| **Blocking** | Guard hooks can block operations | Skills run to completion |
| **Scope** | Single lifecycle moment | Full workflow |
| **Analogy** | Git hooks, middleware | CLI commands, scripts |

## Creating Custom Hooks

1. Create a new `.md` file in `hooks/`
2. Follow the format above (Trigger, Behavior, Input, Output, Example)
3. Name it descriptively: `{event}-{purpose}.md` or `{purpose}-hook.md`
4. The agent picks it up automatically at next session start

### Priority

If multiple hooks fire on the same event:
- Guard hooks run first (can block)
- Action hooks run next (fire-and-forget)
- Transform hooks run last (modify output)
- Within each type, lower priority number = runs earlier (default: 50)

### Disabling a Hook

Add `Enabled: false` in the hook's frontmatter, or move the file out of `hooks/`.

## CLI-Specific Notes

| CLI | Hook Support |
|-----|-------------|
| Claude Code | Native via `.claude/hooks.json` — can wire these as real scripts |
| Codex CLI | Native via `.codex/hooks.json` |
| Copilot CLI | Behavioral — embed in `copilot-instructions.md` |
| Cursor | Rules-based via `.cursor/rules/*.mdc` |
| Windsurf | Rules-based via `.windsurfrules` |
