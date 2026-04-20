# oh-my-universal for Codex / Gemini / OpenCode

Read `.github/copilot-instructions.md` for all project rules.

## Key Points

- This is a cross-project skills repo with **39 skills**, not a standalone project
- Skills in `skills/` can be used from any project directory
- Always update `docs/PROGRESS.md` after every session

## Available Skills (39)

### Core Workflow

| Skill | File | What it does |
|-------|------|-------------|
| plan | `skills/plan.md` | Structured planning (plan -> critique -> execute) |
| ultrawork | `skills/ultrawork.md` | Full lifecycle: plan -> implement -> verify -> review -> commit |
| autopilot | `skills/autopilot.md` | Autonomous 5-phase pipeline: idea to working code |
| verify | `skills/verify.md` | Evidence-based change verification |
| build-fix | `skills/build-fix.md` | Auto-fix build/test failures (3 attempts max) |
| tdd | `skills/tdd.md` | Test-driven development: Red -> Green -> Refactor |

### Investigation

| Skill | File | What it does |
|-------|------|-------------|
| deep-dive | `skills/deep-dive.md` | Causal tracing + Socratic questioning |
| trace | `skills/trace.md` | Structured hypothesis-driven debugging |
| ask | `skills/ask.md` | Query multiple AI models, cross-validate |
| architecture | `skills/architecture.md` | Map and understand codebase structure |

### Quality

| Skill | File | What it does |
|-------|------|-------------|
| review | `skills/review.md` | High-signal code review (bugs/security only) |
| multi-model-review | `skills/multi-model-review.md` | 4-perspective review |
| security-review | `skills/security-review.md` | Repo-wide security audit |
| visual-verdict | `skills/visual-verdict.md` | Screenshot-based UI review |
| perf-audit | `skills/perf-audit.md` | Performance profiling and optimization |
| pre-commit-check | `skills/pre-commit-check.md` | Quality gate before commit |

### Documentation

| Skill | File | What it does |
|-------|------|-------------|
| doc-maintainer | `skills/doc-maintainer.md` | Auto-update docs after code changes |
| wiki | `skills/wiki.md` | Auto-maintained project knowledge base |
| remember | `skills/remember.md` | Persist learnings in .memory/ files |
| writer-memory | `skills/writer-memory.md` | Writing context: tone, style, continuity |

### Operations

| Skill | File | What it does |
|-------|------|-------------|
| release | `skills/release.md` | Changelog, version bump, git tag, publish |
| hooks | `skills/hooks.md` | Pre/post hooks for agent lifecycle events |
| dirty-guard | `skills/dirty-guard.md` | Block dangerous git ops on dirty worktree |
| run-tagging | `skills/run-tagging.md` | Unique session identity for audit trails |
| parity-check | `skills/parity-check.md` | Smoke test tools, skills, environment |
| handoff | `skills/handoff.md` | State handoff between agent runs |
| status-line | `skills/status-line.md` | Terminal progress indicators |
| hud | `skills/hud.md` | Heads-up display for agent progress |

### Meta

| Skill | File | What it does |
|-------|------|-------------|
| self-improve | `skills/self-improve.md` | Learn from failures, improve skills |
| skillify | `skills/skillify.md` | Create new skills from patterns |
| doctor | `skills/doctor.md` | Project health check and setup validation |
| mcp-setup | `skills/mcp-setup.md` | Auto-configure MCP servers |
| session-manager | `skills/session-manager.md` | Manage, resume, fork agent sessions |
| session-protocol | `skills/session-protocol.md` | End-of-session cleanup workflow |
| mission-runner | `skills/mission-runner.md` | Execute scoped task missions from missions/ directory |

### Collaboration

| Skill | File | What it does |
|-------|------|-------------|
| team | `skills/team.md` | Multi-agent delegation with fallback |
| repo-merge | `skills/repo-merge.md` | Merge features from external repos |
| notify | `skills/notify.md` | Notifications: console, system, Discord |
| refactor | `skills/refactor.md` | Code smell detection + improvements |
