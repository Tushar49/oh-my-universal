# oh-my-codex Research

> Source: https://github.com/Yeachan-Heo/oh-my-codex

## What It Is
Codex workflow layer: adds stronger default sessions, plan-before-execute flow,
persistent project state, team runtime, and a skills system on top of OpenAI Codex CLI.

## Key Skills (PORT THESE)

| Skill | What it does | Port priority |
|-------|-------------|---------------|
| `$plan` | Create implementation plan before coding | HIGH |
| `$ralplan` | Enhanced planning with critique loop | HIGH |
| `$ultrawork` | Full workflow: plan -> implement -> verify | HIGH |
| `$code-review` | Auto code review | HIGH |
| `$security-review` | Security-focused review | MEDIUM |
| `$tdd` | Test-driven development flow | MEDIUM |
| `$analyze` | Codebase analysis | MEDIUM |
| `$team` | Multi-agent team delegation via tmux | HIGH |
| `$ralph` | Persistent completion loop | MEDIUM |
| `$deep-interview` | Deep research interview | LOW (we have this) |
| `$ultraqa` | Quality assurance | MEDIUM |
| `$build-fix` | Build-fix loop | MEDIUM |
| `$web-clone` | Clone web UI | LOW |
| `$cancel` | Cancel running tasks | LOW |
| `$ecomode` | Reduce token usage | LOW |

## Configuration
- `.omx/` - project state, plans, logs, wiki
- `.codex/config.toml` - Codex config
- `.codex/hooks.json` - hook mapping
- `AGENTS.md` - agent instructions

## Hooks
- Pre/post execution hooks via `.codex/hooks.json` and `.omx/hooks/*.mjs`

## Dependencies
- Node 20+, Codex CLI, Rust/Cargo (workspace build), tmux/psmux (team mode)
