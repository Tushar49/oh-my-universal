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
| **plan** | `skills/plan.md` | Structured planning before implementation (plan -> critique -> execute) |
| **review** | `skills/review.md` | High-signal code review (bugs, security, logic errors only) |
| **ultrawork** | `skills/ultrawork.md` | Full lifecycle: plan -> implement -> verify -> review -> document -> commit |
| **doc-maintainer** | `skills/doc-maintainer.md` | Auto-update documentation after code changes |
| **remember** | `skills/remember.md` | Persist learnings across sessions in .memory/ files |
| **architecture** | `skills/architecture.md` | Map and understand codebase structure quickly |
| **doctor** | `skills/doctor.md` | Project health check and setup validation |
| **verify** | `skills/verify.md` | Evidence-based change verification (tests, build, manual checks) |
| **security-review** | `skills/security-review.md` | Repo-wide security audit (threats, auth, deps, trust boundaries) |
| **tdd** | `skills/tdd.md` | Test-driven development: Red -> Green -> Refactor |
| **build-fix** | `skills/build-fix.md` | Auto-fix build/test failures (max 3 attempts, then escalate) |
| **team** | `skills/team.md` | Multi-agent delegation with serial fallback |
| **repo-merge** | `skills/repo-merge.md` | Merge features from external repos (research -> matrix -> port) |
| **pre-commit-check** | `skills/pre-commit-check.md` | Quality gate: verify + review + security before commit |
| **session-protocol** | `skills/session-protocol.md` | End-of-session: docs + memory + verify + commit prep |
| **notify** | `skills/notify.md` | Notifications: console, system toast, Discord webhook |

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
| `skills/` | Cross-project skills (the main product) |

## Quality Standards

- kebab-case for all file names
- Every skill must have: trigger conditions, workflow steps, output format, rules
- Skills must be CLI-agnostic (no Copilot-specific or Claude-specific instructions)
- Commit after every logical unit of work
