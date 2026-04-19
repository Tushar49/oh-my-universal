# Skill: doc-maintainer

> Automatically update documentation after code changes.
> Agents should invoke this after every significant change.
> Inspired by: oh-my-openagent (Librarian), everything-claude-code

## When to Trigger

- After implementing features that change user-facing behavior, APIs, or configuration
- User says "update docs", "fix documentation"
- As part of ultrawork workflow (Step 5)
- When documentation is visibly out of sync with code

## What to Check and Update

### 1. README.md
- Does it still accurately describe what the project does?
- Are setup instructions still correct?
- Are command examples still valid?
- Is the file structure diagram still accurate?

### 2. Progress/Backlog Trackers
- Are completed items marked done?
- Are new items added for discovered work?

### 3. API/Reference Docs
- Do function signatures match the code?
- Are new endpoints/commands documented?
- Are deprecated items marked?

### 4. Configuration Docs
- Are config file examples up to date?
- Are new config options documented?
- Are default values correct?

### 5. Routing Tables (for multi-agent repos)
- Are all prompts/modes/agents listed in routing tables?
- Are all routing tables consistent with each other?
- Are file paths correct?

## Rules

- Only update docs that are DIRECTLY affected by the changes
- Don't rewrite docs that are fine - make surgical updates
- If a doc file doesn't exist for a new feature, flag it but don't create it
  unless the user asks
- Keep doc updates in the same commit as the code change when possible
- Use the same naming conventions as the rest of the project
- NEVER add fluff to docs - be concise and actionable
- Not responsible for: agent memory/session logs (see remember skill), code review (see review skill)
