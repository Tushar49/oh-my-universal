# oh-my-universal - Agent Instructions

> Universal agent enhancement layer. These instructions apply to ALL agents
> working in this repo.

## What This Repo Is

This is a cross-project skills repo. It provides reusable agents, skills, and
hooks that enhance AI coding CLIs (Copilot, Claude, Codex, Gemini, OpenCode).

It is NOT a standalone project - it's used FROM other project directories via
`/add-dir`, `--plugin-dir`, or symlinks.

## Self-Maintenance Rules (CRITICAL)

Every agent session MUST:
1. Update `docs/PROGRESS.md` with what was done
2. Update any docs that are affected by changes
3. Commit changes in logical batches before session ends
4. If new skills/agents were created, update README.md feature list

## Sources of Truth

| File | Purpose |
|------|---------|
| `docs/REQUIREMENTS.md` | User requirements and constraints |
| `docs/PROGRESS.md` | Progress tracker (update every session) |
| `.research/` | Raw research from source repos |
| `skills/` | Cross-project skills |
| `.github/agents/` | Custom agents |

## Architecture

```
User's project (e.g. JobApplications/)
  |
  /add-dir oh-my-universal/
  |
  +-> loads agents from .github/agents/
  +-> loads skills from skills/
  +-> loads prompts from .github/prompts/
  +-> applies rules from copilot-instructions.md
```

## Quality Standards

- kebab-case for all file names
- Every skill/agent must have a clear description
- Every feature must be tracked in PROGRESS.md
- Commit after every logical unit of work
