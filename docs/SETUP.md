# Setup Guide

## Prerequisites

- An AI coding CLI: Copilot CLI, Claude Code, OpenAI Codex, Gemini CLI, or OpenCode
- This repo cloned to a known location (e.g., `E:\Projects\oh-my-universal`)

## Per-CLI Setup

### Copilot CLI (recommended)

**Option A: Per-session (temporary)**
```bash
copilot
/add-dir /path/to/oh-my-universal
```
Skills are available for this session only.

**Option B: User-level agents (permanent)**
Copy agent files to your user agents directory:
```bash
# macOS/Linux
cp oh-my-universal/.github/instructions/*.instructions.md ~/.copilot/instructions/

# Windows
copy oh-my-universal\.github\instructions\*.instructions.md %USERPROFILE%\.copilot\instructions\
```

**Option C: Symlink (permanent, auto-updates)**
```bash
# Create a symlink so Copilot always loads the latest skills
# Windows (as admin):
mklink /D "%USERPROFILE%\.copilot\instructions\oh-my-universal" "E:\Projects\oh-my-universal\.github\instructions"
```

### Claude Code

**Option A: Plugin directory**
```bash
claude --plugin-dir /path/to/oh-my-universal
```

**Option B: Symlink .claude/skills**
```bash
# From your project directory:
ln -s /path/to/oh-my-universal/.claude/skills/oh-my-universal .claude/skills/oh-my-universal
```

### OpenAI Codex

Codex reads `AGENTS.md` from cwd. Two approaches:

**Option A: Symlink AGENTS.md**
```bash
# From your project (if you don't have your own AGENTS.md):
ln -s /path/to/oh-my-universal/AGENTS.md AGENTS.md
```

**Option B: Include in your AGENTS.md**
Add to your project's AGENTS.md:
```markdown
For development skills (plan, review, tdd, etc.), read the skill files
in /path/to/oh-my-universal/skills/
```

### Gemini CLI

Same as Codex — reads AGENTS.md.

### OpenCode

```bash
# Add as plugin
opencode plugin add /path/to/oh-my-universal
```

Or symlink the skills directory.

## Verify Setup

After connecting, test with:
```
"run doctor"
```
If the agent recognizes the doctor skill and runs a health check, setup is working.

## Using Skills

Once connected, just use natural language:

| Say this | What happens |
|----------|-------------|
| "plan this refactoring" | Creates structured plan with self-critique |
| "review my changes" | High-signal code review |
| "ultrawork: add auth" | Full lifecycle: plan -> implement -> verify -> review |
| "tdd: add login" | Test-driven: failing test -> implement -> refactor |
| "fix the build" | Auto-fix (3 attempts max) |
| "merge features from {repo}" | Structured external repo integration |
| "wrap up" | End-of-session cleanup |

Skills work with ANY project — they read the project's own structure, conventions,
and config files to adapt their behavior.
