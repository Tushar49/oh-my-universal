# oh-my-openagent Research

> Source: https://github.com/code-yeongyu/oh-my-openagent

## What It Is
OpenCode plugin with Claude Code compatibility. 11 agents, 52 lifecycle hooks,
26 tools. Features 3-tier MCP system, hashline edit safety, and background-agent
orchestration.

## Key Agents (PORT THESE)

| Agent | What it does | Port priority |
|-------|-------------|---------------|
| Sisyphus | Persistent task executor | HIGH |
| Hephaestus | Build/fix specialist | HIGH |
| Oracle | Deep research/analysis | MEDIUM (we have deep-research) |
| Librarian | Documentation maintainer | HIGH |
| Explore | Codebase explorer | LOW (built-in to Copilot) |
| Atlas | Architecture mapping | HIGH |
| Prometheus | Innovation/planning | MEDIUM |
| Metis | Strategic planning | MEDIUM |
| Momus | Code critic/reviewer | HIGH |
| Multimodal-Looker | Visual analysis | LOW |
| Sisyphus-Junior | Lightweight task runner | LOW |

## Key Features
- IntentGate classifier - routes requests to correct agent
- Hashline LINE#ID - safe line-based editing
- 3-tier MCP: built-in + .mcp.json + skill-embedded
- Background-agent orchestration
- Multi-level config merge (project + user)

## Configuration
- `.opencode/oh-my-opencode.jsonc` (project)
- `~/.config/opencode/oh-my-opencode.jsonc` (user)
- `.opencode/skills/*`, `.opencode/command/*`

## Dependencies
- Bun 1.3.11, OpenCode plugin SDK, @ast-grep/napi, better-sqlite3
