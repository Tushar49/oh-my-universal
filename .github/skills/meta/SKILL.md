---
description: "Meta: self-improve, skillify, doctor, mcp-setup, session-manager, session-protocol, mission-runner, command-gen, config-sync, rules-discovery, web-clone"
argument-hint: "self-improve | skillify | doctor | mcp-setup | session-manager | mission-runner | command-gen | config-sync | rules-discovery | web-clone"
---

# Meta — Skill Group

Self-improvement, diagnostics, configuration, and meta-skills.

## Routing

Read the skill file based on the argument:

| Input | Skill file | What it does |
|-------|-----------|--------------|
| `self-improve` or `improve` | `skills/self-improve.md` | Self-improvement from failure analysis |
| `skillify` | `skills/skillify.md` | Convert workflows into reusable skills |
| `doctor` | `skills/doctor.md` | Validate project health and prerequisites |
| `mcp-setup` or `mcp` | `skills/mcp-setup.md` | MCP server configuration |
| `session-manager` or `sessions` | `skills/session-manager.md` | Session lifecycle management |
| `session-protocol` or `wrap-up` | `skills/session-protocol.md` | Session wrap-up protocol |
| `mission-runner` or `mission` | `skills/mission-runner.md` | Run scoped task missions |
| `command-gen` or `gen-command` | `skills/command-gen.md` | Generate CLI commands |
| `config-sync` or `sync-config` | `skills/config-sync.md` | Sync configuration across CLIs |
| `deepinit` or `init` | `skills/deepinit.md` | Deep project initialization |
| `rules-discovery` or `discover-rules` | `skills/rules-discovery.md` | Discover project rules and conventions |
| `web-clone` or `clone-site` | `skills/web-clone.md` | Clone web pages/sites |

Read the matched skill file and execute its workflow.
