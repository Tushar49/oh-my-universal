# CLI Detection Strategy — How Each Tool Discovers Skills

> Documents how each CLI tool discovers and loads skills/instructions,
> and the strategy for making oh-my-universal skills auto-discoverable by ALL tools.
> Created: 2026-04-20

---

## 1. GitHub Copilot CLI

**Discovery Files:**
| File | Purpose | Priority |
|------|---------|----------|
| `.github/copilot-instructions.md` | Global instructions for ALL Copilot interactions | Primary |
| `.github/instructions/*.instructions.md` | Scoped instructions (path globs in frontmatter) | Secondary |
| `.github/prompts/*.prompt.md` | User-invocable prompt templates | On-demand |
| `.github/agents/*.agent.md` | Agent definitions with tool specs | On-demand |

**How It Works:**
- Copilot CLI reads `.github/copilot-instructions.md` automatically on every session.
- Instructions files in `.github/instructions/` are auto-loaded when working on matching file paths.
- Prompts and agents are user-invoked (not auto-loaded).
- Custom instructions support YAML frontmatter with `applyTo` globs.
- The `skill` tool in Copilot CLI allows invoking project-scoped skills.

**Skill Loading Pattern:**
```
Session Start
  → Read .github/copilot-instructions.md (always)
  → Read .github/instructions/*.instructions.md (path-scoped)
  → User invokes: /prompt-name or @agent-name
  → Skills referenced in instructions are followed as behavioral guidelines
```

**Config Location:** `~/.copilot/` or VS Code settings

---

## 2. Claude Code

**Discovery Files:**
| File | Purpose | Priority |
|------|---------|----------|
| `CLAUDE.md` | Project root instructions (always loaded) | Primary |
| `.claude/CLAUDE.md` | Project-scoped instructions | Primary |
| `~/.claude/CLAUDE.md` | Global user instructions | Fallback |
| `.claude/skills/*/SKILL.md` | Skill definitions | Auto-inject |
| `.claude/agents/*.md` | Agent subagent definitions | On-demand |
| `.claude/commands/*.md` | Slash commands | On-demand |

**How It Works:**
- Claude Code reads `CLAUDE.md` and `.claude/CLAUDE.md` automatically.
- Skills in `.claude/skills/` are auto-injected when their trigger conditions match.
- oh-my-claudecode extends this with plugin system, hooks.json, and MCP servers.
- Skills have YAML frontmatter with `name`, `description`, `triggers` arrays.
- Slash commands are invoked as `/command-name`.

**Skill Loading Pattern:**
```
Session Start
  → Read CLAUDE.md (project root)
  → Read .claude/CLAUDE.md (project-scoped)
  → Read ~/.claude/CLAUDE.md (global)
  → Scan .claude/skills/*/SKILL.md (auto-inject by trigger match)
  → User invokes: /skill-name or /command-name
```

**Config Location:** `~/.claude/settings.json`, `~/.claude/config.json`

---

## 3. OpenAI Codex CLI

**Discovery Files:**
| File | Purpose | Priority |
|------|---------|----------|
| `AGENTS.md` | Primary agent instructions (always loaded) | Primary |
| `.codex/config.toml` | Codex configuration | Config |
| `.codex/hooks.json` | Lifecycle hooks | Auto |

**How It Works:**
- Codex reads `AGENTS.md` at project root automatically.
- All instructions, skill references, and routing must be in AGENTS.md or files it references.
- oh-my-codex extends via `.omx/` state directory and hooks.
- Skills are invoked via `$skill-name` syntax in prompts.
- No separate skill file directory — everything routes through AGENTS.md.

**Skill Loading Pattern:**
```
Session Start
  → Read AGENTS.md (always)
  → Load .codex/hooks.json (if present)
  → User invokes: $skill-name in natural language
  → AGENTS.md routes to skill instructions (inline or referenced)
```

**Config Location:** `~/.codex/config.toml`, `~/.codex/`

---

## 4. Gemini CLI

**Discovery Files:**
| File | Purpose | Priority |
|------|---------|----------|
| `AGENTS.md` | Primary agent instructions (shared with Codex) | Primary |
| `GEMINI.md` | Gemini-specific instructions | Primary |
| `.gemini/` | Gemini-specific config directory | Config |

**How It Works:**
- Gemini CLI reads `AGENTS.md` and `GEMINI.md` at project root.
- Same routing pattern as Codex: instructions in markdown files.
- Gemini-specific features (1M token context, multimodal) noted in GEMINI.md.
- No hooks system in Gemini CLI currently.

**Skill Loading Pattern:**
```
Session Start
  → Read AGENTS.md (always)
  → Read GEMINI.md (if present, Gemini-specific overrides)
  → User invokes skills via natural language references
```

**Config Location:** `~/.gemini/`, environment variables

---

## 5. Cursor

**Discovery Files:**
| File | Purpose | Priority |
|------|---------|----------|
| `.cursor/rules/*.mdc` | Rule files with frontmatter globs | Primary |
| `.cursorrules` | Legacy: single rules file | Fallback |
| `.cursor/agents/*.md` | Agent definitions (newer versions) | On-demand |

**How It Works:**
- Cursor reads all `.mdc` files in `.cursor/rules/` automatically.
- Each `.mdc` file has YAML frontmatter with `globs` for file-path matching.
- Rules are context-injected when the user is working on matching files.
- `.cursorrules` is the legacy single-file format (still supported).
- Agent mode can reference agent definitions.

**Skill Loading Pattern:**
```
Session Start
  → Scan .cursor/rules/*.mdc (all files)
  → Match rules to current file context via globs
  → Inject matching rules as system context
  → .cursorrules loaded as global fallback
```

**Config Location:** `~/.cursor/`, VS Code-style settings

---

## 6. Windsurf

**Discovery Files:**
| File | Purpose | Priority |
|------|---------|----------|
| `.windsurfrules` | Project rules file | Primary |
| `.windsurf/rules/*.md` | Scoped rules (newer format) | Primary |

**How It Works:**
- Windsurf reads `.windsurfrules` at project root.
- Newer versions support directory-based rules in `.windsurf/rules/`.
- Format is similar to Cursor's `.cursorrules` — plain markdown instructions.
- No hooks, skills, or agent system — pure instruction injection.

**Skill Loading Pattern:**
```
Session Start
  → Read .windsurfrules (always)
  → Scan .windsurf/rules/*.md (if present)
  → All instructions injected as system context
```

**Config Location:** Windsurf settings UI

---

## 7. OpenCode

**Discovery Files:**
| File | Purpose | Priority |
|------|---------|----------|
| `AGENTS.md` | Primary instructions (shared with Codex/Gemini) | Primary |
| `.opencode/` | OpenCode-specific config | Config |

**How It Works:**
- OpenCode reads `AGENTS.md` at project root.
- Similar pattern to Codex/Gemini: markdown-first instruction loading.
- Plugin support for extensions.
- oh-my-opencode (oh-my-openagent fork) extends with agents and skills.

**Skill Loading Pattern:**
```
Session Start
  → Read AGENTS.md (always)
  → Load .opencode/ config (if present)
  → Skills invoked via natural language
```

**Config Location:** `~/.opencode/`

---

## Universal Discovery Strategy

### The Problem

Each CLI has its own discovery mechanism. A skill needs to be findable by:
- Copilot CLI → `.github/copilot-instructions.md` or `.github/prompts/`
- Claude Code → `CLAUDE.md` or `.claude/skills/`
- Codex / Gemini / OpenCode → `AGENTS.md`
- Cursor → `.cursor/rules/`
- Windsurf → `.windsurfrules`

### The Solution: Hub-and-Spoke Model

```
                    skills/plan.md          ← SINGLE SOURCE OF TRUTH
                         │
          ┌──────────────┼──────────────┐
          │              │              │
    CLAUDE.md      AGENTS.md     .github/copilot-instructions.md
    (references     (references     (references skills/plan.md
     skills/)        skills/)        in routing table)
          │              │              │
    .cursor/rules/  .windsurfrules  .github/instructions/
    (generated)     (generated)     (auto-generated)
```

### Implementation

#### 1. Skills as Markdown (Universal)
Skills live in `skills/*.md` — plain markdown that ANY agent can read and follow.
No CLI-specific code, no hooks, no plugins. Just instructions.

#### 2. Entrypoint Files Reference Skills
Each CLI's entrypoint file includes a routing table pointing to skill files:

**CLAUDE.md:**
```markdown
Read skills/ directory for available workflows.
When user says "plan this" → follow skills/plan.md
When user says "review" → follow skills/review.md
```

**AGENTS.md:**
```markdown
## Available Skills
| Trigger | File | Description |
|---------|------|-------------|
| "plan this" | skills/plan.md | Structured planning |
| "review" | skills/review.md | Code review |
```

**.github/copilot-instructions.md:**
```markdown
## Skill Routing
When user requests planning → read and follow skills/plan.md
When user requests review → read and follow skills/review.md
```

#### 3. Generator for IDE-Specific Files
For IDEs that need specific file formats:

```bash
# Generate .cursor/rules/ from skills/
node bin/generate.js --target cursor

# Generate .windsurfrules from skills/
node bin/generate.js --target windsurf
```

This produces `.cursor/rules/plan.mdc`, `.windsurfrules`, etc. from the canonical skill files.

#### 4. Auto-Discovery Convention
Skills use consistent frontmatter:

```yaml
---
name: plan
description: Structured planning before implementation
triggers:
  - "plan this"
  - "let's plan"
  - "how should we approach"
category: workflow
---
```

The generator reads this frontmatter to produce routing tables for each CLI.

### File Layout for Maximum Discovery

```
project/
├── CLAUDE.md                           # Claude Code entrypoint
├── AGENTS.md                           # Codex/Gemini/OpenCode entrypoint
├── .windsurfrules                      # Windsurf entrypoint (generated)
├── .github/
│   ├── copilot-instructions.md         # Copilot CLI entrypoint
│   ├── instructions/                   # Copilot scoped instructions (generated)
│   └── prompts/                        # Copilot prompt templates
├── .claude/
│   └── skills/                         # Claude Code skill symlinks (generated)
├── .cursor/
│   └── rules/                          # Cursor rules (generated)
├── skills/                             # ← CANONICAL SKILL FILES
│   ├── plan.md
│   ├── review.md
│   ├── ultrawork.md
│   └── ...
├── config/                             # Skill configuration
│   └── skills.yml                      # Skill registry with metadata
└── bin/
    └── generate.js                     # Generate CLI-specific files from skills/
```

### Key Principles

1. **Single source of truth:** Skills live in `skills/*.md`. Everything else is generated or references these.
2. **Markdown-first:** Skills are plain markdown instructions. No CLI-specific code.
3. **Progressive enhancement:** Skills work as basic instructions on any CLI. CLI-specific features (hooks, MCP, status bars) are optional enhancements.
4. **Generator, not templates:** A build step produces CLI-specific files. Don't maintain N copies manually.
5. **Graceful degradation:** If a CLI can't do something (e.g., status bar, hooks), the skill degrades to console output or behavioral instructions.

### CLI Capability Matrix

| Capability | Copilot | Claude | Codex | Gemini | Cursor | Windsurf | OpenCode |
|------------|---------|--------|-------|--------|--------|----------|----------|
| Read skill files | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Auto-inject by trigger | ✗ | ✓ | ✗ | ✗ | ✓* | ✗ | ✗ |
| Lifecycle hooks | ✗ | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ |
| Slash commands | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| MCP servers | ✓ | ✓ | ~ | ~ | ✓ | ✓ | ~ |
| Status bar | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Subagent spawning | ✓ | ✓ | ~ | ~ | ~ | ✗ | ~ |
| Image/vision input | ✓ | ✓ | ~ | ✓ | ✓ | ✓ | ~ |
| Plugin system | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ |

`✓` = supported, `✗` = not supported, `~` = partial/emerging, `*` = via glob matching

### Detection Priority (for skill auto-injection)

When an agent starts, the entrypoint file should instruct it to:

1. Check if `skills/` directory exists
2. Read skill frontmatter for trigger matching
3. Load matching skills into context
4. For unmatched skills: make them available on user request

This ensures skills are discoverable regardless of which CLI is running.
