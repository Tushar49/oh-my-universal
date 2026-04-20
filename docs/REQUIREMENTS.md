# User Requirements - oh-my-universal

## Origin

The user (Tushar Agarwal) wants a unified agent enhancement system that combines
the best features from multiple "oh-my-*" repos into one system that works
across ALL AI coding CLIs (Copilot, Claude, Codex, Gemini, OpenCode, Cursor, Windsurf).

## Core Requirements

1. **Universal compatibility** - must work with Copilot CLI, Claude Code, OpenAI Codex, Gemini CLI, OpenCode, Cursor, Windsurf (7 CLIs)
2. **Cross-project usage** - install once in E:\Projects\oh-my-universal\, use from ANY project dir
3. **Auto-maintaining docs** - agents must update documentation at every run
4. **Self-reviewing** - auto code-review before commits
5. **Planning before implementation** - always plan -> critique -> execute
6. **Memory persistence** - context carries across sessions
7. **Repo merge capability** - skills for merging features from external repos (like career-ops merge)
8. **Discord notifications** - notify when long tasks complete (optional)
9. **Autonomous pipelines** - autopilot mode for zero-intervention workflows
10. **Lifecycle hooks** - pre/post hooks for all agent operations
11. **Session management** - resume, fork, and hand off sessions with persistent state
12. **Visual review** - screenshot-based UI feedback
13. **Multi-model queries** - cross-validate answers across AI models
14. **Release management** - changelog, version bump, git tag, publish
15. **Self-improvement** - analyze failures and improve skill files

## Skill Count

**38 skills** across 7 categories:
- Core Workflow (6): plan, ultrawork, autopilot, verify, build-fix, tdd
- Investigation (4): deep-dive, trace, ask, architecture
- Quality (6): review, multi-model-review, security-review, visual-verdict, perf-audit, pre-commit-check
- Documentation (4): doc-maintainer, wiki, remember, writer-memory
- Operations (8): release, hooks, dirty-guard, run-tagging, parity-check, handoff, status-line, hud
- Meta (6): self-improve, skillify, doctor, mcp-setup, session-manager, session-protocol
- Collaboration (3): team, repo-merge, notify

## How User Wants to Use It

Example scenario: User is in E:\Projects\JobApplications\ working with Copilot CLI.
They want to use oh-my-universal's planning/review skills from that directory.

**For Copilot CLI:**
```
copilot
/add-dir E:\Projects\oh-my-universal
```
This makes oh-my-universal's agents, prompts, and skills available in the current session.

**For Claude Code:**
```
claude --plugin-dir E:\Projects\oh-my-universal
```

**For Gemini CLI:**
Reads GEMINI.md / AGENTS.md from the repo. See docs/SETUP.md.

**For Codex:**
Install hooks globally in ~/.codex/ that reference oh-my-universal skills.

## Source Repos

| Repo | Key features to extract |
|------|------------------------|
| oh-my-codex | Hooks system, task delegation, tmux workers, auto-planning, dirty-guard, run-tagging, parity-check, handoff |
| oh-my-claudecode | Team mode, plugin system, session memory, autopilot, deep-dive, ask, trace, visual-verdict, wiki, writer-memory, release, self-improve, hud, session-manager, mcp-setup, hooks (29 agents, 35 skills, 20 hooks) |
| oh-my-openagent | Agent stack, deep init, cross-provider support |
| clawhip | Discord hooks, memory offload, event architecture |
| claw-code | CLI harness patterns (reference only, not porting) |
| awesome-claude-code | Status-line patterns (claude-pace, claude-powerline, CCometixLine) |

## Non-Requirements

- Do NOT create a new CLI tool (use existing CLIs)
- Do NOT require Python (Node.js only for scripts)
- Do NOT duplicate project-specific configs (those stay in each project's repo)
- Do NOT require internet connection for core features (Discord is optional)

## Quality Standards

Same standards as JobApplications repo:
- kebab-case naming for all files
- Proper directory hierarchy
- Agent instructions in every entrypoint file
- Commit in logical batches
- Update docs after every change
