---
applyTo: "**"
---

# oh-my-universal Skills (39 total)

When working on ANY file in this project, you have access to these cross-project
development skills. Use them proactively.

## Skill Quick Reference

### Core Workflow

| Say this | Skill invoked | What happens |
|----------|--------------|-------------|
| "plan this" | plan | Structured plan -> self-critique -> execute |
| "ultrawork: {task}" | ultrawork | Full lifecycle: plan -> implement -> verify -> review -> commit |
| "autopilot: {idea}" | autopilot | Autonomous 5-phase pipeline: idea to working code |
| "verify this works" | verify | Evidence-based change verification |
| "fix the build" | build-fix | Auto-fix errors (3 attempts max) |
| "tdd: {feature}" | tdd | Test-driven: write failing test -> implement -> refactor |

### Investigation

| Say this | Skill invoked | What happens |
|----------|--------------|-------------|
| "deep dive into" | deep-dive | Causal tracing + Socratic questioning |
| "trace this" | trace | Structured hypothesis-driven debugging |
| "ask codex / gemini" | ask | Query multiple AI models, cross-validate |
| "map this codebase" | architecture | Understand structure quickly |

### Quality

| Say this | Skill invoked | What happens |
|----------|--------------|-------------|
| "review my changes" | review | High-signal code review (bugs/security only) |
| "thorough review" | multi-model-review | 4-perspective deep review |
| "check security" | security-review | Repo-wide security audit |
| "visual check" | visual-verdict | Screenshot-based UI review |
| "optimize / profile" | perf-audit | Find and fix performance bottlenecks |
| "pre-commit check" | pre-commit-check | Quality gate before commit |

### Documentation

| Say this | Skill invoked | What happens |
|----------|--------------|-------------|
| "update docs" | doc-maintainer | Update affected documentation |
| "update wiki" | wiki | Auto-maintained project knowledge base |
| "remember this" | remember | Save learnings for future sessions |
| "keep writing style" | writer-memory | Persist tone, style, narrative continuity |

### Operations

| Say this | Skill invoked | What happens |
|----------|--------------|-------------|
| "cut a release" | release | Changelog, version bump, git tag, publish |
| "list hooks" | hooks | Pre/post hooks for agent lifecycle events |
| "check dirty" | dirty-guard | Block dangerous git ops on dirty worktree |
| "tag this run" | run-tagging | Unique session identity for audit trails |
| "parity check" | parity-check | Smoke test tools, skills, environment |
| "hand off" | handoff | State handoff between agent runs |
| "show progress" | status-line | Terminal progress indicators |
| "show status" | hud | Heads-up display for agent progress |

### Meta

| Say this | Skill invoked | What happens |
|----------|--------------|-------------|
| "improve yourself" | self-improve | Learn from failures, improve skills |
| "make this a skill" | skillify | Extract repeatable pattern into new skill |
| "run doctor" | doctor | Project health check |
| "setup mcp" | mcp-setup | Auto-configure MCP servers |
| "resume session" | session-manager | Manage, resume, fork agent sessions |
| "wrap up" | session-protocol | End-of-session cleanup |
| "run mission" | mission-runner | Execute scoped task missions from missions/ |

### Collaboration

| Say this | Skill invoked | What happens |
|----------|--------------|-------------|
| "delegate this" | team | Split into subtasks, parallelize |
| "merge {repo}" | repo-merge | Structured external repo integration |
| "notify me" | notify | Send completion notification |
| "refactor this" | refactor | Detect smells, improve structure |

## Auto-Trigger Guidance

Proactively use these skills in these situations:
- **Before multi-file changes**: follow `skills/plan.md`
- **Before committing**: follow `skills/pre-commit-check.md`
- **After implementing**: follow `skills/verify.md`
- **End of session**: follow `skills/session-protocol.md`
- **When build fails**: follow `skills/build-fix.md`
- **On dirty worktree**: follow `skills/dirty-guard.md`
- **Session start**: follow `skills/run-tagging.md`

Read the full skill file from `skills/{name}.md` for detailed workflow.
