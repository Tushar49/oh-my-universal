# Contributing to oh-my-universal

Thanks for your interest in improving oh-my-universal! This guide covers how to add skills, hooks, missions, and contracts.

## Adding a New Skill

1. Copy the template: `cp skills/plan.md skills/my-skill.md`
2. Follow the required structure:
   - `# Skill: name` with blockquote description
   - `## When to Trigger` — conditions that activate this skill
   - `## Workflow` — numbered steps with clear instructions
   - `## Output Format` — what the skill produces
   - `## Rules` — constraints and invariants
   - `## Not Responsible For` — explicit scope boundaries
3. Update ALL 8 CLI adapter files (or use `config-sync` skill)
4. Add to README.md skills table
5. Submit PR

## Adding a New Hook

1. Create `hooks/my-hook.md`
2. Define: Event Trigger, Behavior, Input, Output/Side Effects, Example
3. Update `hooks/README.md` hook table
4. Update the `skills/hooks.md` hook registry
5. Submit PR

## Adding a New Mission

1. Copy template: `cp -r missions/_template missions/my-mission`
2. Edit mission.md with: Goal, Focus Areas, Success Criteria, Constraints
3. Edit sandbox.md with: evaluation command, scope limits
4. Submit PR

## Adding a New Contract

1. Create `contracts/my-contract.md`
2. Define: invariants, enforcement rules, violation handling
3. Contracts are ALWAYS enforced — they cannot be overridden
4. Update `contracts/README.md`
5. Submit PR

## Testing Your Changes

Run the parity-check skill to verify everything is consistent:
```
"run parity-check"
```

You can also run the doctor skill for a health check:
```
"run doctor"
```

## CLI Adapter Files

When adding a skill, update all 8 adapters so every CLI sees it:

| CLI | Adapter file |
|-----|-------------|
| Copilot CLI | `.github/copilot-instructions.md` |
| Copilot CLI (instructions) | `.github/instructions/skills.instructions.md` |
| Claude Code | `.claude/skills/oh-my-universal/SKILL.md` |
| Codex / OpenCode | `AGENTS.md` |
| Gemini CLI | `GEMINI.md` |
| Cursor | `.cursor/rules/skills.mdc` |
| Windsurf | `.windsurfrules` |

Or just run the `config-sync` skill after adding your skill file — it updates all adapters automatically.

## Style Guidelines

- Keep skills under 100 lines
- Use plain language, no jargon
- Every skill must have "Not Responsible For" to prevent scope creep
- Hooks must be SHORT (20-40 lines)
- Contracts must be PRECISE (no ambiguity)
- Use kebab-case for all file names
- Write for the agent, not the human — clear instructions beat clever prose

## Commit Conventions

- Group changes logically: one commit per skill/hook/contract
- Prefix commits: `skill:`, `hook:`, `contract:`, `mission:`, `docs:`, `adapter:`
- Update PROGRESS.md with your changes
