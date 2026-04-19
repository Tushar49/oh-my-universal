# oh-my-universal

Universal agent enhancement layer that works across ALL AI coding CLIs.
Combines the best features from oh-my-codex, oh-my-claudecode, oh-my-openagent,
and clawhip into a single unified system.

## What This Does

Adds superpowers to your AI coding agents - regardless of which CLI you use:
- **Auto-planning** before implementation (plan -> critique -> execute)
- **Code review** on every significant change
- **Memory/context persistence** across sessions
- **Multi-agent delegation** for complex tasks
- **Self-maintaining docs** - agents update documentation as they work
- **Discord notifications** when long tasks complete
- **Cross-project skills** - use these skills from any project directory

## Supported CLIs

| CLI | How it connects | Status |
|-----|----------------|--------|
| Copilot CLI | `/add-dir E:\Projects\oh-my-universal` | Planned |
| Claude Code | `--plugin-dir` or symlink `.claude/` | Planned |
| OpenAI Codex | Global hooks via `.codex/` | Planned |
| Gemini CLI | AGENTS.md symlink or copy | Planned |
| OpenCode | Plugin system | Planned |

## Quick Start

```bash
# From any project directory, add this repo's skills:

# Copilot CLI
copilot
/add-dir E:\Projects\oh-my-universal

# Claude Code  
claude --plugin-dir E:\Projects\oh-my-universal

# OpenAI Codex
# (install hooks globally - see docs/SETUP.md)
```

## Directory Structure

```
oh-my-universal/
├── .github/
│   ├── copilot-instructions.md   # Universal agent rules
│   ├── agents/                   # Custom agents (planner, reviewer, etc.)
│   └── prompts/                  # Reusable workflow prompts
├── .research/                    # Source research from all oh-my repos
├── skills/                       # Cross-project skills
├── config/                       # Configuration
├── docs/                         # Setup guides, architecture
├── AGENTS.md                     # Codex/Gemini entry
├── CLAUDE.md                     # Claude Code entry
└── README.md
```

## Features (Planned)

### From oh-my-codex
- [ ] Task delegation with tmux workers
- [ ] Pre/post hooks for quality gates
- [ ] Auto-planning before implementation

### From oh-my-claudecode
- [ ] Team mode (multi-agent orchestration)
- [ ] Plugin system
- [ ] Session memory persistence

### From oh-my-openagent
- [ ] Agent stack initialization
- [ ] Deep init for project understanding
- [ ] Cross-provider support

### From clawhip
- [ ] Discord notification hooks
- [ ] Memory offload to persistent storage
- [ ] Event-driven architecture

### Universal additions
- [ ] Auto-maintain docs (agents update docs at every run)
- [ ] Self-reviewing code (auto code-review before commit)
- [ ] Cross-project skill loading
- [ ] Unified config across all CLIs
