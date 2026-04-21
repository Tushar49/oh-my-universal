# oh-my-universal - Agent Instructions

> Universal agent enhancement layer. These instructions apply to ALL agents
> working in this repo OR using this repo's skills via /add-dir.

## What This Repo Is

This is a cross-project skills repo. It provides reusable agents, skills, and
hooks that enhance AI coding CLIs (Copilot, Claude, Codex, Gemini, OpenCode).

It is NOT a standalone project - it's used FROM other project directories via
`/add-dir`, `--plugin-dir`, or symlinks.

## Available Skills

| Skill | File | What it does |
|-------|------|-------------|
| | | **Core Workflow** |
| **plan** | `skills/plan.md` | Structured planning before implementation (plan -> critique -> execute) |
| **ultrawork** | `skills/ultrawork.md` | Full lifecycle: plan -> implement -> verify -> review -> document -> commit |
| **autopilot** | `skills/autopilot.md` | Autonomous 5-phase pipeline: idea to validated working code, zero intervention |
| **verify** | `skills/verify.md` | Evidence-based change verification (tests, build, manual checks) |
| **build-fix** | `skills/build-fix.md` | Auto-fix build/test failures (max 3 attempts, then escalate) |
| **tdd** | `skills/tdd.md` | Test-driven development: Red -> Green -> Refactor |
| | | **Investigation** |
| **deep-dive** | `skills/deep-dive.md` | Two-stage investigation: causal tracing + Socratic questioning |
| **trace** | `skills/trace.md` | Evidence-driven debugging with structured hypothesis testing |
| **ask** | `skills/ask.md` | Query multiple AI models and cross-validate answers |
| **architecture** | `skills/architecture.md` | Map and understand codebase structure quickly |
| **analyst** | `skills/analyst.md` | Requirements gap analysis - find missing specs before coding |
| | | **Quality** |
| **review** | `skills/review.md` | High-signal code review (bugs, security, logic errors only) |
| **multi-model-review** | `skills/multi-model-review.md` | 4-perspective review: bug hunter, security, maintainer, perf |
| **security-review** | `skills/security-review.md` | Repo-wide security audit (threats, auth, deps, trust boundaries) |
| **visual-verdict** | `skills/visual-verdict.md` | Screenshot-based UI review with structured visual feedback |
| **perf-audit** | `skills/perf-audit.md` | Performance profiling: identify bottlenecks, measure, optimize |
| **pre-commit-check** | `skills/pre-commit-check.md` | Quality gate: verify + review + security before commit |
| **designer** | `skills/designer.md` | UI/UX specs from requirements - wireframes, components, tokens |
| | | **Documentation** |
| **doc-maintainer** | `skills/doc-maintainer.md` | Auto-update documentation after code changes |
| **wiki** | `skills/wiki.md` | Auto-maintained project knowledge base, reduces token usage |
| **remember** | `skills/remember.md` | Persist learnings across sessions in .memory/ files |
| **writer-memory** | `skills/writer-memory.md` | Persistent writing context: tone, style, narrative continuity |
| | | **Operations** |
| **release** | `skills/release.md` | Release management: changelog, version bump, git tag, publish |
| **hooks** | `skills/hooks.md` | Pre/post hooks for agent lifecycle events (guard, transform, extend) |
| **dirty-guard** | `skills/dirty-guard.md` | Block dangerous git ops when worktree has uncommitted changes |
| **run-tagging** | `skills/run-tagging.md` | Unique session identity to prevent lane reuse and enable audit |
| **parity-check** | `skills/parity-check.md` | Agent health smoke tests: verify tools, skills, environment |
| **handoff** | `skills/handoff.md` | Structured state handoff between agent runs for continuity |
| **status-line** | `skills/status-line.md` | Compact terminal progress indicators during long operations |
| **hud** | `skills/hud.md` | Heads-up display showing agent progress at a glance |
| **cancel** | `skills/cancel.md` | Kill-switch to abort running operations safely |
| **workflow-state** | `skills/workflow-state.md` | State machine for agent workflow transitions |
| **container-sandbox** | `skills/container-sandbox.md` | Run untrusted code in isolated container sandbox |
| **worktree-sandbox** | `skills/worktree-sandbox.md` | Git worktree parallel isolation for safe experimentation |
| | | **Meta** |
| **self-improve** | `skills/self-improve.md` | Analyze agent failures and improve skills to prevent recurrence |
| **skillify** | `skills/skillify.md` | Create new skills from observed repeatable patterns |
| **doctor** | `skills/doctor.md` | Project health check and setup validation |
| **mcp-setup** | `skills/mcp-setup.md` | Auto-detect project type and configure MCP servers |
| **session-manager** | `skills/session-manager.md` | Manage, resume, and fork agent sessions with persistent state |
| **session-protocol** | `skills/session-protocol.md` | End-of-session: docs + memory + verify + commit prep |
| **mission-runner** | `skills/mission-runner.md` | Execute scoped task missions from missions/ directory |
| **command-gen** | `skills/command-gen.md` | Scaffold reusable commands and PRPs |
| **config-sync** | `skills/config-sync.md` | Sync agent rules across CLI frameworks |
| | | **Collaboration** |
| **team** | `skills/team.md` | Multi-agent delegation with serial fallback |
| **repo-merge** | `skills/repo-merge.md` | Merge features from external repos (research -> matrix -> port) |
| **notify** | `skills/notify.md` | Notifications: console, system toast, Discord webhook |
| **refactor** | `skills/refactor.md` | Detect code smells, apply improvements preserving behavior |

## Lifecycle Hooks

The `hooks/` directory contains 19 lifecycle hooks covering the complete agent
lifecycle: session, tool, skill, keyword, memory, safety, quality, subagent,
and context events. See `hooks/README.md` for the full list.

## Contracts

4 formal behavior contracts in `contracts/` that all skills and hooks MUST respect:

| Contract | What it enforces |
|----------|-----------------|
| `state-precedence` | Session > project > global state; rollback on failure; forbidden transitions |
| `terminal-handoff` | Every skill must end in a terminal state (finished/blocked/failed/cancelled/needs-input) |
| `team-mutation` | Claim-and-version protocol for parallel sub-agent work |
| `quality-gate` | Build + test + security + docs gates before commit |

See `contracts/README.md` for details.

## How to Use From Another Project

```
# Copilot CLI (from any project directory)
copilot
/add-dir E:\Projects\oh-my-universal

# Then use skills by name:
# "plan this refactoring"
# "review my changes"
# "ultrawork: add authentication"
# "run doctor"
```

## Self-Maintenance Rules (CRITICAL)

Every agent session MUST:
1. Update `docs/PROGRESS.md` with what was done
2. Update any docs that are affected by changes
3. Commit changes in logical batches before session ends
4. If new skills/agents were created, update this file's skill table

## Sources of Truth

| File | Purpose |
|------|---------|
| `docs/REQUIREMENTS.md` | User requirements and constraints |
| `docs/PROGRESS.md` | Progress tracker (update every session) |
| `.research/` | Raw research from source repos |
| `.research/unified-feature-matrix.md` | Master feature porting plan |
| `skills/` | Cross-project skills (47 total - the main product) |
| `hooks/` | 19 lifecycle hooks for agent events |
| `contracts/` | 4 behavior contracts for skills and hooks |

## Quality Standards

- kebab-case for all file names
- Every skill must have: trigger conditions, workflow steps, output format, rules
- Skills must be CLI-agnostic (no Copilot-specific or Claude-specific instructions)
- Commit after every logical unit of work
