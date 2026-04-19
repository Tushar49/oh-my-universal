# User Requirements - oh-my-universal

## Origin

The user (Tushar Agarwal) wants a unified agent enhancement system that combines
the best features from multiple "oh-my-*" repos into one system that works
across ALL AI coding CLIs (Copilot, Claude, Codex, Gemini, OpenCode).

## Core Requirements

1. **Universal compatibility** - must work with Copilot CLI, Claude Code, OpenAI Codex, Gemini CLI, OpenCode
2. **Cross-project usage** - install once in E:\Projects\oh-my-universal\, use from ANY project dir
3. **Auto-maintaining docs** - agents must update documentation at every run
4. **Self-reviewing** - auto code-review before commits
5. **Planning before implementation** - always plan -> critique -> execute
6. **Memory persistence** - context carries across sessions
7. **Repo merge capability** - skills for merging features from external repos (like career-ops merge)
8. **Discord notifications** - notify when long tasks complete (optional)

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

**For Codex:**
Install hooks globally in ~/.codex/ that reference oh-my-universal skills.

## Source Repos

| Repo | Key features to extract |
|------|------------------------|
| oh-my-codex | Hooks system, task delegation, tmux workers, auto-planning |
| oh-my-claudecode | Team mode, plugin system, session memory |
| oh-my-openagent | Agent stack, deep init, cross-provider support |
| clawhip | Discord hooks, memory offload, event architecture |
| claw-code | CLI harness patterns (reference only, not porting) |

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
