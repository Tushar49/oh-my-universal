# Skill: command-gen

> Scaffold reusable slash commands and PRPs (Product Requirements Prompts) from manual workflows.
> Inspired by: awesome-claude-code /create-command, /create-prp patterns

## When to Trigger

- User says "create a command for", "scaffold a prompt", "make this reusable", "generate PRP"
- After doing the same multi-step workflow manually 2+ times
- User describes a repeatable workflow they want automated
- User says "turn this into a prompt" or "save this as a command"

## Workflow

### Step 1 — Analyze the Workflow

Identify the repeatable pattern:
- **What does the user do manually?** (steps, tools, files involved)
- **What varies between runs?** (these become parameters)
- **What stays the same?** (these become the template body)
- **What CLI is active?** (auto-detect from project config files)

Detect the target CLI by checking which config files exist:
| File present | CLI |
|---|---|
| `.github/copilot-instructions.md` | Copilot CLI |
| `CLAUDE.md` or `.claude/` | Claude Code |
| `AGENTS.md` | Codex / OpenAgent |
| `.cursor/rules/` | Cursor |

If multiple CLIs are detected, generate for all of them.

### Step 2 — Choose Output Mode

**Slash Command mode** (default):
- For task-oriented workflows (build, test, deploy, fix)
- Output: executable command file the agent can run

**PRP mode** (when user says "generate PRP" or the workflow is a product/feature request):
- For requirement-oriented workflows (feature specs, design docs, architecture decisions)
- Output: structured product requirement prompt with goals, constraints, acceptance criteria

### Step 3 — Generate the Command

#### Slash Command Format

For **Copilot CLI** — save to `.github/prompts/{name}.prompt.md`:
```markdown
---
description: "{one-line description}"
---
# {Command Name}

{Instructions for the agent to follow when this command is invoked.}

## Parameters
- `${{PARAM_1}}` — {description}
- `${{PARAM_2}}` — {description}

## Steps
1. {step}
2. {step}

## Output
{what to produce}
```

For **Claude Code** — save to `.claude/commands/{name}.md`:
```markdown
# {Command Name}

{Instructions for the agent.}

## Arguments
- $ARGUMENTS — {what the user passes}

## Steps
1. {step}
2. {step}
```

For **SKILL.md router** — append entry to `.claude/skills/{project}/SKILL.md`:
```markdown
### {name}
{one-line description}
**Trigger:** "{trigger phrase}"
**File:** `{path to command file}`
```

#### PRP Format

Save to `.github/prompts/{name}.prompt.md` or `.claude/commands/{name}.md`:
```markdown
# PRP: {Feature/Product Name}

## Goal
{What should be built and why — 2-3 sentences}

## Context
{Current state, relevant background, user needs}

## Requirements
- [ ] {Functional requirement 1}
- [ ] {Functional requirement 2}
- [ ] {Non-functional requirement}

## Constraints
- {Technical constraint}
- {Scope constraint}
- {Timeline constraint}

## Acceptance Criteria
- {Criterion 1 — specific, testable}
- {Criterion 2}

## Out of Scope
- {Explicitly excluded item}
```

### Step 4 — Register the Command

1. Create the command file in the appropriate location
2. If a SKILL.md router exists, add an entry
3. If a prompt index exists, update it
4. Report what was created and how to invoke it

## Output Format

```markdown
## Command Generated: {name}

**Mode:** Slash Command / PRP
**CLI:** {detected CLI(s)}
**Files created:**
- `{path}` — {description}

**Invoke with:**
- Copilot: `/prompt {name}`
- Claude: `/{name}`
- Other: `{invocation}`

**Parameters:**
- `{param}` — {description}
```

## Rules

- ALWAYS auto-detect the CLI from project config files. Don't ask the user which CLI they use.
- If multiple CLIs are detected, generate for ALL of them in one pass.
- Parameters must have clear names and descriptions. Use `${{SNAKE_CASE}}` for Copilot, `$ARGUMENTS` for Claude.
- PRP mode generates requirements, NOT implementation. The agent that runs the PRP decides how to build it.
- Generated commands should be self-contained — another agent should understand them without context.
- Keep commands concise. If a command needs > 50 lines of instructions, it should probably be a skill instead (suggest skillify).
- NEVER generate commands that contain hardcoded secrets, paths, or environment-specific values. Use parameters.

## Not Responsible For

- Executing the generated command (invoke it separately)
- Creating full skill files (use skillify for multi-step workflows with rules and output formats)
- CLI-specific adapter setup (use mcp-setup for that)
- Syncing generated commands across CLIs (use config-sync for that)
