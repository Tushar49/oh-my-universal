# Skill: config-sync

> Sync agent rules and configuration across CLI frameworks. One update propagates to all.
> Inspired by: awesome-claude-code Rulesync, ClaudeCTX patterns

## When to Trigger

- User says "sync configs", "update all CLI files", "check for config drift"
- After editing any CLI config file (CLAUDE.md, copilot-instructions.md, AGENTS.md, etc.)
- When setting up a project for multi-CLI support
- When onboarding a new CLI to an existing project

## Workflow

### Step 1 — Discover Config Files

Scan the project for known CLI config files:

| CLI | Config locations |
|---|---|
| Copilot CLI | `.github/copilot-instructions.md` |
| Claude Code | `CLAUDE.md`, `.claude/settings.json`, `.claude/skills/` |
| Codex CLI | `AGENTS.md`, `.codex/` |
| Cursor | `.cursor/rules/*.mdc`, `.cursorrules` |
| Windsurf | `.windsurfrules` |
| Gemini | `GEMINI.md` |

Report what exists:
```markdown
## Config Discovery

| CLI | File | Status |
|---|---|---|
| Copilot | .github/copilot-instructions.md | ✓ found |
| Claude | CLAUDE.md | ✓ found |
| Codex | AGENTS.md | ✗ missing |
| Cursor | .cursorrules | ✓ found |
```

### Step 2 — Extract Portable Content

Identify content that is PORTABLE (should sync) vs CLI-SPECIFIC (should not):

**Portable (SYNC these):**
- Project conventions (naming, style, patterns)
- Codebase structure descriptions
- Build/test/lint commands
- Skill/workflow descriptions
- Architecture decisions and constraints
- File organization rules

**CLI-Specific (DO NOT sync):**
- Hook configurations (`hooks.json`, `.codex/hooks.json`)
- MCP server settings
- Agent-specific tool configurations
- CLI-specific syntax (frontmatter, MDC format, YAML config)
- Memory/state file paths

### Step 3 — Detect Drift

Compare portable content across all config files:

1. Parse each config file into sections (conventions, commands, rules, structure)
2. Diff sections across files
3. Classify differences:
   - **Drift** — same rule exists in multiple files but with different wording/values
   - **Missing** — rule exists in one file but not others
   - **Conflict** — contradictory rules across files

```markdown
## Drift Report

| Rule/Section | Copilot | Claude | Codex | Status |
|---|---|---|---|---|
| Build command | `npm run build` | `npm run build` | missing | MISSING in Codex |
| Test command | `npm test` | `jest --coverage` | `npm test` | DRIFT (Claude differs) |
| Style guide | "Use ESLint" | "Use ESLint" | "Use ESLint" | IN SYNC |
```

### Step 4 — Propagate Changes

Based on drift analysis, update files:

**For MISSING content:**
- Generate the section in the target file's format
- Adapt syntax (markdown headers for Copilot/Claude/Codex, MDC for Cursor, plain text for Windsurf)

**For DRIFT:**
- Present both versions to the user
- Ask which is canonical (or merge both)
- Update all files to match

**For new CLI setup (no config file exists):**
- Generate a complete config file from the union of all existing configs
- Use the target CLI's format conventions
- Include only portable content

### Step 5 — Validate

After sync:
1. Verify each config file is syntactically valid for its CLI
2. Check that no CLI-specific settings were accidentally overwritten
3. Report what was changed

## Output Format

```markdown
## Config Sync: {project}

**Files scanned:** {N}
**Drift detected:** {N} items
**Changes made:** {N} files updated

### Changes
| File | Action | Details |
|---|---|---|
| AGENTS.md | CREATED | Generated from Copilot + Claude configs |
| .cursorrules | UPDATED | Added missing build commands |
| CLAUDE.md | UPDATED | Fixed test command drift |

### Still Divergent (CLI-Specific)
- Copilot: MCP server config (not portable)
- Claude: hooks.json (not portable)
```

## Rules

- NEVER sync CLI-specific settings. Only portable project knowledge.
- When generating a missing config file, use that CLI's idiomatic format (don't just copy markdown verbatim into a `.cursorrules` file).
- On drift, ALWAYS ask the user which version is canonical before overwriting. Never auto-resolve conflicting rules.
- Treat the most recently edited file as the likely source of truth (but confirm with user).
- Preserve CLI-specific sections in each file — only update the portable sections.
- Config sync is idempotent — running it twice with no changes should produce no diff.
- Add a sync marker comment at the bottom of synced sections: `<!-- synced by config-sync {date} -->` (in formats that support comments).

## Not Responsible For

- CLI-specific adapter setup or installation (use mcp-setup or doctor)
- Generating skill files (use skillify or command-gen)
- Validating that rules are correct or useful (only syncs what exists)
- Managing MCP servers, hooks, or other runtime configurations
