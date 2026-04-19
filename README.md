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
| Copilot CLI | `/add-dir` or copy `.github/instructions/` to `~/.copilot/instructions/` | ✅ Ready |
| Claude Code | `--plugin-dir` or symlink `.claude/skills/` | ✅ Ready |
| OpenAI Codex | AGENTS.md routes to skills/ | ✅ Ready |
| Gemini CLI | AGENTS.md routes to skills/ | ✅ Ready |
| OpenCode | Plugin or AGENTS.md | ✅ Ready |

See [docs/SETUP.md](docs/SETUP.md) for detailed per-CLI setup instructions.

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

## Features

### Core Skills (Phase 1) ✅
- [x] **plan** — Structured planning with self-critique before implementation
- [x] **review** — High-signal code review (bugs, security, logic only)
- [x] **ultrawork** — Full lifecycle: plan → implement → verify → review → commit
- [x] **verify** — Evidence-based change verification (tests + manual checks)
- [x] **doc-maintainer** — Auto-update documentation after code changes
- [x] **remember** — Memory persistence across sessions (native tools → .memory/ fallback)
- [x] **architecture** — Map and understand codebase structure
- [x] **doctor** — Project health check (fast + full modes)

### Cross-Project Skills (Phase 2) ✅
- [x] **security-review** — Repo-wide security audit (threats, auth, deps, CVEs)
- [x] **tdd** — Test-driven development: Red → Green → Refactor
- [x] **build-fix** — Auto-fix build failures (3 attempts max, then escalate)
- [x] **team** — Multi-agent delegation with serial fallback
- [x] **repo-merge** — Merge features from external repos (research → matrix → port)

### Workflow Specs (Phase 3) ✅
- [x] **pre-commit-check** — Quality gate: verify + review + security before commit
- [x] **session-protocol** — End-of-session: docs + memory + verify + commit prep
- [x] **notify** — Notifications: console, system toast, Discord webhook

### CLI Adapters (Phase 4) ✅
- [x] Copilot CLI: `.github/instructions/skills.instructions.md`
- [x] Claude Code: `.claude/skills/oh-my-universal/SKILL.md`
- [x] Codex/Gemini/OpenCode: `AGENTS.md`
- [x] Setup guide: `docs/SETUP.md`
