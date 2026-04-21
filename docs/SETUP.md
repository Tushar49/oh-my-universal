# Setup Guide

## Prerequisites

- An AI coding CLI (any one of the 7 supported CLIs listed below)
- Git
- This repo cloned locally:
  ```bash
  git clone https://github.com/Tushar49/oh-my-universal.git
  ```

### Optional Prerequisites

Some skills benefit from external tools. All are optional — core skills work without them.

| Skill | External tool | Why |
|-------|--------------|-----|
| **ask** | Multiple CLI tools (e.g., `claude`, `codex`, `gemini`) | Cross-validates answers across models |
| **notify** | Discord webhook URL | Sends notifications when tasks complete |
| **visual-verdict** | Screenshot capability (browser or system) | UI review via screenshots |
| **release** | `npm` / `git` | Version bump, changelog, publish |
| **mcp-setup** | MCP-compatible CLI | Auto-configures MCP servers |

---

## Per-CLI Setup

> Replace `/path/to/oh-my-universal` with your actual clone path throughout.

---

### Copilot CLI

**Option A: Per-session (temporary)**
```bash
copilot
/add-dir /path/to/oh-my-universal
```
Skills are available for this session only. Run this each time you start Copilot CLI.

**Option B: Copy instructions (permanent)**
```bash
# macOS/Linux
cp oh-my-universal/.github/instructions/*.instructions.md ~/.copilot/instructions/

# Windows
copy oh-my-universal\.github\instructions\*.instructions.md %USERPROFILE%\.copilot\instructions\
```
Skills load automatically in every Copilot CLI session. Re-copy after updates.

**Option C: Symlink (permanent, auto-updates)**
```bash
# macOS/Linux
ln -s /path/to/oh-my-universal/.github/instructions ~/.copilot/instructions/oh-my-universal

# Windows (run as Administrator)
mklink /D "%USERPROFILE%\.copilot\instructions\oh-my-universal" "C:\path\to\oh-my-universal\.github\instructions"
```
Always loads the latest version — no re-copy needed.

---

### Claude Code

**Option A: Plugin directory (recommended)**
```bash
claude --plugin-dir /path/to/oh-my-universal
```
Run this each time you start Claude Code, or add it to a shell alias.

**Option B: Symlink skills (permanent)**
```bash
# From your project directory:
mkdir -p .claude/skills
ln -s /path/to/oh-my-universal/.claude/skills/oh-my-universal .claude/skills/oh-my-universal
```
Skills load automatically when Claude Code opens this project.

---

### OpenAI Codex

Codex reads `AGENTS.md` from the current working directory.

**Option A: Symlink AGENTS.md (if you have no existing AGENTS.md)**
```bash
ln -s /path/to/oh-my-universal/AGENTS.md AGENTS.md
```

**Option B: Reference from your own AGENTS.md**
Add this line to your project's `AGENTS.md`:
```markdown
For development skills (plan, review, tdd, etc.), read the skill files
in /path/to/oh-my-universal/skills/
```

---

### Gemini CLI

Gemini CLI reads `GEMINI.md` (preferred) or `AGENTS.md` from the current working directory.

**Option A: Symlink GEMINI.md (if you have no existing GEMINI.md)**
```bash
ln -s /path/to/oh-my-universal/GEMINI.md GEMINI.md
```

**Option B: Reference from your own GEMINI.md**
Add this line to your project's `GEMINI.md`:
```markdown
For development skills (plan, review, tdd, etc.), read the skill files
in /path/to/oh-my-universal/skills/
```

---

### Cursor

Cursor loads rules from `.cursor/rules/`. Two options:

**Option A: Symlink the rules directory**
```bash
# From your project directory:
mkdir -p .cursor/rules
ln -s /path/to/oh-my-universal/.cursor/rules/skills.mdc .cursor/rules/skills.mdc
```

**Option B: Copy the rules file**
```bash
mkdir -p .cursor/rules
cp /path/to/oh-my-universal/.cursor/rules/skills.mdc .cursor/rules/skills.mdc
```
Re-copy after updates.

---

### Windsurf

Windsurf loads rules from `.windsurfrules` in the project root.

**Option A: Symlink (recommended)**
```bash
ln -s /path/to/oh-my-universal/.windsurfrules .windsurfrules
```

**Option B: Copy the file**
```bash
cp /path/to/oh-my-universal/.windsurfrules .windsurfrules
```
Re-copy after updates.

---

### OpenCode

**Option A: Plugin (recommended)**
```bash
opencode plugin add /path/to/oh-my-universal
```

**Option B: Symlink AGENTS.md**
Same as the Codex setup — OpenCode also reads `AGENTS.md` from cwd.

---

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
This verifies all skills, hooks, contracts, and CLI adapters are consistent.

---

## Using Skills

Once connected, use natural language. All 47 skills are available:

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

Skills work with ANY project — they read the project's own structure, conventions,
and config files to adapt their behavior.
