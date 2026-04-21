---
description: "Operations: release, hooks, dirty-guard, run-tagging, parity-check, handoff, hud, cancel, workflow-state, container-sandbox, worktree-sandbox, git-master, cost-tracker, dependency-upgrade, compact-guard, permission-tuner, output-styles"
argument-hint: "release | hooks | dirty-guard | git-master | handoff | hud | cost-tracker | dependency-upgrade | ..."
---

# Operations — Skill Group

Release management, git workflows, sandboxing, and operational tooling.

## Routing

Read the skill file based on the argument:

| Input | Skill file | What it does |
|-------|-----------|--------------|
| `release` or `publish` | `skills/release.md` | Changelog, version bump, git tag, publish |
| `hooks` | `skills/hooks.md` | Lifecycle hook management |
| `dirty-guard` or `dirty` | `skills/dirty-guard.md` | Guard against dirty worktree operations |
| `run-tagging` or `tag-run` | `skills/run-tagging.md` | Tag and track command runs |
| `parity-check` or `parity` | `skills/parity-check.md` | Cross-environment parity validation |
| `handoff` | `skills/handoff.md` | Session handoff documentation |
| `hud` or `status` | `skills/hud.md` | Heads-up display / status dashboard |
| `cancel` or `abort` | `skills/cancel.md` | Graceful task cancellation |
| `workflow-state` or `state` | `skills/workflow-state.md` | Workflow state persistence |
| `container-sandbox` or `sandbox` | `skills/container-sandbox.md` | Container-based sandboxing |
| `worktree-sandbox` or `worktree` | `skills/worktree-sandbox.md` | Git worktree sandboxing |
| `git-master` or `git` | `skills/git-master.md` | Advanced git operations |
| `cost-tracker` or `costs` | `skills/cost-tracker.md` | Token and cost tracking |
| `dependency-upgrade` or `upgrade-deps` | `skills/dependency-upgrade.md` | Dependency upgrade workflows |
| `compact-guard` or `compaction` | `skills/compact-guard.md` | Context compaction guard |
| `permission-tuner` or `permissions` | `skills/permission-tuner.md` | Permission configuration tuning |
| `output-styles` or `output-mode` | `skills/output-styles.md` | Output format configuration |

Read the matched skill file and execute its workflow.
