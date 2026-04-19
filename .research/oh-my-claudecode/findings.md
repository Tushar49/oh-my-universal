# oh-my-claudecode Research

> Source: https://github.com/Yeachan-Heo/oh-my-claudecode

## What It Is
Claude Code orchestration layer with multi-agent routing, lifecycle hooks,
skills, and MCP wiring. Installed as a Claude Code plugin.

## Key Skills (PORT THESE)

| Skill | What it does | Port priority |
|-------|-------------|---------------|
| `ralplan` | Plan with critique loop | HIGH |
| `ultrawork` | Full workflow: plan -> implement -> verify | HIGH |
| `team` | Multi-agent orchestration | HIGH |
| `ralph` | Persistent completion loop | MEDIUM |
| `setup` | Project setup/doctor | HIGH |
| `release` | Release management | LOW |
| `remember` | Memory persistence across sessions | HIGH |
| `wiki` | Project knowledge base | MEDIUM |
| `visual-verdict` | Visual review of changes | MEDIUM |
| `verify` | Verification pass | MEDIUM |
| `skillify` | Create new skills | LOW |
| `deep-interview` | Deep research | LOW (we have this) |

## Hooks (IMPORTANT - port these patterns)
- `config` - config transformation
- `tool` - tool registration
- `chat.message` - message interception
- `chat.params` - parameter modification
- `event` - event handling
- `tool.execute.before` / `tool.execute.after` - pre/post tool hooks
- `experimental.session.compacting` - session management

## Configuration
- `.claude-plugin/plugin.json` - plugin manifest
- `.mcp.json` - MCP server registration
- `skills/` tree

## Dependencies
- Node 20+/Bun, Claude Code, @anthropic-ai/claude-agent-sdk, better-sqlite3
