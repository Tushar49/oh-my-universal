# Setup Guide

## Prerequisites

- An AI coding CLI: Copilot CLI, Claude Code, OpenAI Codex, Gemini CLI, OpenCode, Cursor, or Windsurf
- This repo cloned to a known location (e.g., `E:\Projects\oh-my-universal`)

### Optional Prerequisites

Some skills benefit from external tools (all are optional):

| Skill | External tool | Why |
|-------|--------------|-----|
| **ask** | Multiple CLI tools (e.g., `claude`, `codex`, `gemini`) | Cross-validates answers across models |
| **notify** | Discord webhook URL | Sends notifications when tasks complete |
| **visual-verdict** | Screenshot capability (browser or system) | UI review via screenshots |
| **release** | `npm` / `git` | Version bump, changelog, publish |
| **mcp-setup** | MCP-compatible CLI | Auto-configures MCP servers |

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

Gemini CLI reads `GEMINI.md` (preferred) or `AGENTS.md` from cwd.

**Option A: Symlink GEMINI.md**
```bash
# From your project (if you don't have your own GEMINI.md):
ln -s /path/to/oh-my-universal/GEMINI.md GEMINI.md
```

**Option B: Include in your GEMINI.md**
Add to your project's GEMINI.md:
```markdown
For development skills (plan, review, tdd, etc.), read the skill files
in /path/to/oh-my-universal/skills/
```

### Cursor

Skills are loaded via `.cursor/rules/skills.mdc`. Either:
- Symlink the `.cursor/` directory from oh-my-universal
- Copy `.cursor/rules/skills.mdc` to your project

### Windsurf

Skills are loaded via `.windsurfrules`. Either:
- Symlink `.windsurfrules` from oh-my-universal
- Copy `.windsurfrules` to your project root

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

You can also run:
```
"run parity-check"
```
This verifies all skills, tools, and environment are configured correctly.

## Using Skills

Once connected, just use natural language. All 38 skills are available:

| Say this | What happens |
|----------|-------------|
| "plan this refactoring" | Creates structured plan with self-critique |
| "review my changes" | High-signal code review |
| "ultrawork: add auth" | Full lifecycle: plan -> implement -> verify -> review |
| "autopilot: build the API" | Fully autonomous 5-phase pipeline |
| "tdd: add login" | Test-driven: failing test -> implement -> refactor |
| "fix the build" | Auto-fix (3 attempts max) |
| "deep-dive into the auth bug" | Two-stage causal tracing + Socratic questioning |
| "trace this error" | Hypothesis-driven debugging |
| "ask: is this approach correct?" | Cross-validate with multiple models |
| "visual-verdict on the homepage" | Screenshot-based UI review |
| "merge features from {repo}" | Structured external repo integration |
| "release a new version" | Changelog, version bump, git tag |
| "wrap up" | End-of-session cleanup |

Skills work with ANY project - they read the project's own structure, conventions,
and config files to adapt their behavior.
