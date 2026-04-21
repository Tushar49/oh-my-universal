# oh-my-universal for Codex / Gemini / OpenCode

Read `.github/copilot-instructions.md` for all project rules.

## Key Points

- This is a cross-project skills repo with **69 skills**, **19 lifecycle hooks**, and **4 behavior contracts**, not a standalone project
- Skills in `skills/` can be used from any project directory
- Always update `docs/PROGRESS.md` after every session

## Available Skills (69)

### Core Workflow

| Skill | File | What it does |
|-------|------|-------------|
| plan | `skills/plan.md` | Structured planning (plan -> critique -> execute) |
| ultrawork | `skills/ultrawork.md` | Full lifecycle: plan -> implement -> verify -> review -> commit |
| autopilot | `skills/autopilot.md` | Autonomous 5-phase pipeline: idea to working code |
| verify | `skills/verify.md` | Evidence-based change verification |
| build-fix | `skills/build-fix.md` | Auto-fix build/test failures (3 attempts max) |
| tdd | `skills/tdd.md` | Test-driven development: Red -> Green -> Refactor |
| ralph | `skills/ralph.md` | Persistent verify-and-fix loop until complete (max 10 iterations) |
| pipeline | `skills/pipeline.md` | User-defined sequential stage runner with rollback |
| ecomode | `skills/ecomode.md` | Token-efficient execution mode |

### Investigation

| Skill | File | What it does |
|-------|------|-------------|
| deep-dive | `skills/deep-dive.md` | Causal tracing + Socratic questioning |
| trace | `skills/trace.md` | Structured hypothesis-driven debugging |
| ask | `skills/ask.md` | Query multiple AI models, cross-validate |
| architecture | `skills/architecture.md` | Map and understand codebase structure |
| analyst | `skills/analyst.md` | Requirements gap analysis |
| autoresearch | `skills/autoresearch.md` | Systematic multi-source research with cross-validation |
| external-context | `skills/external-context.md` | Load external docs/URLs into agent context |
| debug | `skills/debug.md` | Hands-on step-through debugging workflow |
| deep-interview | `skills/deep-interview.md` | Socratic intent-clarification loop with ambiguity scoring |
| scientist | `skills/scientist.md` | Data analysis with statistical rigor |
| ultrathink | `skills/ultrathink.md` | Deep reasoning for complex decisions |

### Quality

| Skill | File | What it does |
|-------|------|-------------|
| review | `skills/review.md` | High-signal code review (bugs/security only) |
| multi-model-review | `skills/multi-model-review.md` | 4-perspective review |
| security-review | `skills/security-review.md` | Repo-wide security audit |
| visual-verdict | `skills/visual-verdict.md` | Screenshot-based UI review |
| perf-audit | `skills/perf-audit.md` | Performance profiling and optimization |
| pre-commit-check | `skills/pre-commit-check.md` | Quality gate before commit |
| designer | `skills/designer.md` | UI/UX specs from requirements |
| ai-slop-cleaner | `skills/ai-slop-cleaner.md` | Strip AI cliches and fluff from output |
| ultraqa | `skills/ultraqa.md` | Comprehensive QA with iterative fix cycles |
| deliverables | `skills/deliverables.md` | Validate all expected outputs exist and meet acceptance criteria |
| api-design | `skills/api-design.md` | REST/GraphQL API design — endpoints, versioning, errors, pagination |
| critic | `skills/critic.md` | Structured multi-perspective review of plans, specs, and analysis |

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
| hud | `skills/hud.md` | Heads-up display for agent progress |
| cancel | `skills/cancel.md` | Kill-switch to abort operations safely |
| workflow-state | `skills/workflow-state.md` | State machine for workflow transitions |
| container-sandbox | `skills/container-sandbox.md` | Isolated container sandbox execution |
| worktree-sandbox | `skills/worktree-sandbox.md` | Git worktree parallel isolation |
| git-master | `skills/git-master.md` | Git workflow management (branches, PRs, conflicts) |
| cost-tracker | `skills/cost-tracker.md` | Track and report token/API costs per session |
| dependency-upgrade | `skills/dependency-upgrade.md` | Safe dependency upgrades with compatibility checks and rollback |
| compact-guard | `skills/compact-guard.md` | State preservation through context compaction |
| permission-tuner | `skills/permission-tuner.md` | Denial pattern analysis and permission optimization |

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
| command-gen | `skills/command-gen.md` | Scaffold reusable commands and PRPs |
| config-sync | `skills/config-sync.md` | Sync agent rules across CLI frameworks |
| deepinit | `skills/deepinit.md` | Deep project initialization and scaffolding |
| rules-discovery | `skills/rules-discovery.md` | Auto-discover and surface project conventions and rules |
| web-clone | `skills/web-clone.md` | URL-driven website cloning with visual + functional verification |
| output-styles | `skills/output-styles.md` | Configurable output modes (verbose, compact, structured) |

### Collaboration

| Skill | File | What it does |
|-------|------|-------------|
| team | `skills/team.md` | Multi-agent delegation with fallback |
| repo-merge | `skills/repo-merge.md` | Merge features from external repos |
| notify | `skills/notify.md` | Notifications: console, system, Discord |
| refactor | `skills/refactor.md` | Code smell detection + improvements |

## Lifecycle Hooks

The `hooks/` directory contains 19 lifecycle hooks covering session, tool,
skill, keyword, memory, safety, quality, subagent, and context events.
See `hooks/README.md` for the full list.

## Contracts

4 formal behavior contracts in `contracts/` that all skills and hooks MUST respect.
See `contracts/README.md` for details.
