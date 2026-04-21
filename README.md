# oh-my-universal

**47 cross-project skills**, **19 lifecycle hooks**, and **4 behavior contracts** for AI coding CLIs. Universal agent enhancement layer
that works across ALL major AI coding CLIs. Combines the best patterns from
oh-my-codex, oh-my-claudecode, oh-my-openagent, clawhip, and more into a single
unified system.

## What This Does

Adds superpowers to your AI coding agents - regardless of which CLI you use:
- **Auto-planning** before implementation (plan -> critique -> execute)
- **Code review** on every significant change
- **Memory/context persistence** across sessions
- **Multi-agent delegation** for complex tasks
- **Self-maintaining docs** - agents update documentation as they work
- **Discord notifications** when long tasks complete
- **Cross-project skills** - use these skills from any project directory
- **Autonomous pipelines** - idea to validated code with zero intervention
- **Screenshot-based UI review** - visual feedback on UI changes
- **Lifecycle hooks** - intercept agent events to guard and extend behavior

## Compatible CLIs

| CLI | How it connects | Entry file | Status |
|-----|----------------|------------|--------|
| Copilot CLI | `/add-dir` or copy `.github/instructions/` | `.github/copilot-instructions.md` | ✅ Ready |
| Claude Code | `--plugin-dir` or symlink `.claude/skills/` | `CLAUDE.md` | ✅ Ready |
| OpenAI Codex | AGENTS.md routes to skills/ | `AGENTS.md` | ✅ Ready |
| Gemini CLI | GEMINI.md / AGENTS.md routes to skills/ | `GEMINI.md` | ✅ Ready |
| OpenCode | Plugin or AGENTS.md | `AGENTS.md` | ✅ Ready |
| Cursor | Rules file | `.cursor/rules/skills.mdc` | ✅ Ready |
| Windsurf | Rules file | `.windsurfrules` | ✅ Ready |

See [docs/SETUP.md](docs/SETUP.md) for detailed per-CLI setup instructions.

## Quick Start

```bash
# From any project directory, add this repo's skills:

# Copilot CLI
copilot
/add-dir E:\Projects\oh-my-universal

# Claude Code  
claude --plugin-dir E:\Projects\oh-my-universal

# Gemini CLI
# (reads GEMINI.md / AGENTS.md automatically - see docs/SETUP.md)

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
├── skills/                       # 47 cross-project skills
├── hooks/                        # 19 lifecycle hooks
├── contracts/                    # 4 behavior contracts
├── config/                       # Configuration
├── docs/                         # Setup guides, architecture
├── AGENTS.md                     # Codex/Gemini entry
├── GEMINI.md                     # Gemini CLI entry
├── CLAUDE.md                     # Claude Code entry
└── README.md
```

## Skills (47 total)

### Core Workflow (6 skills)
| Skill | Description |
|-------|-------------|
| **plan** | Structured planning with self-critique before implementation |
| **ultrawork** | Full lifecycle: plan -> implement -> verify -> review -> commit |
| **autopilot** | Fully autonomous 5-phase pipeline: idea to validated working code |
| **verify** | Evidence-based change verification (tests + manual checks) |
| **build-fix** | Auto-fix build failures (3 attempts max, then escalate) |
| **tdd** | Test-driven development: Red -> Green -> Refactor |

### Investigation (5 skills)
| Skill | Description |
|-------|-------------|
| **deep-dive** | Two-stage investigation: causal tracing + Socratic questioning |
| **trace** | Evidence-driven debugging with structured hypothesis testing |
| **ask** | Query multiple AI models and cross-validate answers |
| **architecture** | Map and understand codebase structure |
| **analyst** | Requirements gap analysis - find missing specs before coding |

### Quality (7 skills)
| Skill | Description |
|-------|-------------|
| **review** | High-signal code review (bugs, security, logic only) |
| **multi-model-review** | 4-perspective review: bug hunter, security, maintainer, perf |
| **security-review** | Repo-wide security audit (threats, auth, deps, CVEs) |
| **visual-verdict** | Screenshot-based UI review with structured visual feedback |
| **perf-audit** | Performance profiling: identify bottlenecks, measure, optimize |
| **pre-commit-check** | Quality gate: verify + review + security before commit |
| **designer** | UI/UX specs from requirements - wireframes, components, tokens |

### Documentation (4 skills)
| Skill | Description |
|-------|-------------|
| **doc-maintainer** | Auto-update documentation after code changes |
| **wiki** | Auto-maintained project knowledge base (reduces token usage) |
| **remember** | Memory persistence across sessions (native tools -> .memory/ fallback) |
| **writer-memory** | Enhanced persistent context for writing projects (tone, style, narrative) |

### Operations (12 skills)
| Skill | Description |
|-------|-------------|
| **release** | Release management: changelog, version bump, git tag, publish |
| **hooks** | Pre/post hooks for agent operations - intercept lifecycle events |
| **dirty-guard** | Block dangerous git operations with uncommitted changes |
| **run-tagging** | Unique identity per agent session for audit trails |
| **parity-check** | Agent health and contract smoke tests |
| **handoff** | Structured state handoff between agent runs |
| **status-line** | Compact terminal progress indicators during long operations |
| **hud** | Heads-up display - compact status showing agent progress |
| **cancel** | Kill-switch to safely abort running operations |
| **workflow-state** | State machine for agent workflow transitions |
| **container-sandbox** | Run untrusted code in isolated container sandbox |
| **worktree-sandbox** | Git worktree parallel isolation for safe experimentation |

### Meta (9 skills)
| Skill | Description |
|-------|-------------|
| **self-improve** | Analyze agent failures, improve skills to prevent recurrence |
| **skillify** | Create new skills from observed repeatable patterns |
| **doctor** | Project health check (fast + full modes) |
| **mcp-setup** | Auto-detect project type and configure MCP servers |
| **session-manager** | Manage, resume, and fork agent sessions with persistent state |
| **session-protocol** | End-of-session: docs + memory + verify + commit prep |
| **mission-runner** | Execute scoped task missions from missions/ directory |
| **command-gen** | Scaffold reusable commands and PRPs |
| **config-sync** | Sync agent rules across CLI frameworks |

### Collaboration (4 skills)
| Skill | Description |
|-------|-------------|
| **team** | Multi-agent delegation with serial fallback |
| **repo-merge** | Merge features from external repos (research -> matrix -> port) |
| **notify** | Notifications: console, system toast, Discord webhook |
| **refactor** | Detect code smells, apply improvements preserving behavior |

## Lifecycle Hooks

19 lifecycle hooks in `hooks/` covering the complete agent lifecycle:

| Category | Hooks |
|----------|-------|
| Session | session-start, session-end |
| Tool | pre-tool, post-tool, tool-failure |
| Skill | skill-start, skill-end |
| Keyword | keyword-detector |
| Memory | memory-save, memory-load |
| Safety | permission-check, dirty-guard-hook, context-guard |
| Quality | verify-deliverables, code-simplifier-hook |
| Subagent | subagent-start, subagent-end |
| Context | pre-compact, context-inject |

See `hooks/README.md` for detailed documentation.

## Contracts

4 formal behavior contracts in `contracts/` that all skills and hooks MUST respect:

| Contract | What it enforces |
|----------|-----------------|
| `state-precedence` | Session > project > global state; rollback on failure; forbidden transitions |
| `terminal-handoff` | Every skill must end in a terminal state (finished/blocked/failed/cancelled/needs-input) |
| `team-mutation` | Claim-and-version protocol for parallel sub-agent work |
| `quality-gate` | Build + test + security + docs gates before commit |

See `contracts/README.md` for details.

## Missions

Missions are scoped task specifications - self-contained work packages with clear success criteria.
While skills define HOW to work, missions define WHAT to do.

See `missions/README.md` for full documentation.

### Example Missions

| Mission | What it does |
|---------|-------------|
| `security-hardening` | Audit and fix security vulnerabilities |
| `test-coverage-boost` | Increase test coverage by 15%+ |
| `performance-baseline` | Establish perf baselines, fix bottlenecks |
| `docs-from-scratch` | Generate comprehensive project docs |
| `dependency-cleanup` | Remove unused deps, patch CVEs |

Create your own: copy `missions/_template/` and customize.

### CLI Adapters ✅
- Copilot CLI: `.github/instructions/skills.instructions.md`
- Claude Code: `.claude/skills/oh-my-universal/SKILL.md`
- Codex/OpenCode: `AGENTS.md`
- Gemini CLI: `GEMINI.md`
- Cursor: `.cursor/rules/skills.mdc`
- Windsurf: `.windsurfrules`
- Setup guide: `docs/SETUP.md`

## Sources

Built by combining the best patterns from:

| Source | Stars | What we took |
|--------|-------|-------------|
| [oh-my-codex](https://github.com/Yeachan-Heo/oh-my-codex) | - | plan, ultrawork, team, build-fix, tdd, dirty-guard, run-tagging, parity-check, handoff, state model, contracts |
| [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) | - | remember, team, session hooks, skill routing, autopilot, deep-dive, ask, trace, visual-verdict, wiki, writer-memory, release, self-improve, hud, session-manager, mcp-setup, hooks |
| [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) | - | architecture (Atlas), review (Momus), doc-maintainer (Librarian) |
| [clawhip](https://github.com/Yeachan-Heo/clawhip) | - | notify (Discord), memory offload |
| [planning-with-files](https://github.com/OthmanAdi/planning-with-files) | 19K | Persistent markdown planning approach |
| [caveman](https://github.com/JuliusBrussee/caveman) | 38K | Compact token-light skill design |
| [claude-forge](https://github.com/sangrokjung/claude-forge) | 659 | Security hooks, pre-commit gates, refactor patterns |
| [everything-claude-code](https://github.com/affaan-m/everything-claude-code) | 160K | Skill taxonomy, multi-perspective review |
| [awesome-claude-code](https://github.com/xavimondev/awesome-claude-code) | - | status-line patterns (claude-pace, claude-powerline), worktree isolation |
| [career-ops](https://github.com/santifer/career-ops) | - | repo-merge workflow (real-world tested) |
