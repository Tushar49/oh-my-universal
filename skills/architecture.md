# Skill: architecture

> Map and understand codebase structure. Produces an architecture overview
> that helps agents navigate unfamiliar codebases quickly.
> Inspired by: oh-my-openagent (Atlas), everything-claude-code

## When to Trigger

- First time working in a new codebase
- User says "analyze this codebase", "show me the architecture"
- Before a major refactoring effort
- When onboarding to understand a project

## Analysis Steps

### Step 1 — Directory Scan
Map the top-level structure:
- What directories exist and what they contain
- How deep is the nesting?
- What naming patterns are used?

### Step 2 — Entry Points
Identify:
- Main entry point (index.js, main.py, App.tsx, etc.)
- Config files (package.json, tsconfig, etc.)
- Build/test commands
- Agent instruction files (AGENTS.md, CLAUDE.md, copilot-instructions.md)

### Step 3 — Dependency Map
- What are the key dependencies?
- What frameworks/libraries are used?
- What's the tech stack?

### Step 4 — Data Flow
- Where does data come from? (APIs, files, databases)
- How does data flow through the system?
- Where does data go? (output, storage, external services)

### Step 5 — Key Patterns
- What architectural pattern is used? (MVC, microservices, monolith, etc.)
- What conventions does the codebase follow?
- What's unusual or non-standard?

## Output Format

```markdown
# Architecture Overview: {project name}

## Tech Stack
- **Language:** {language + version}
- **Framework:** {if any}
- **Build:** {build tool + command}
- **Test:** {test command}
- **Package manager:** {npm/pip/cargo/etc}

## Directory Structure
{tree with descriptions}

## Entry Points
| Entry | File | Purpose |
|-------|------|---------|

## Key Dependencies
| Dependency | Version | Used for |
|-----------|---------|----------|

## Data Flow
{brief description or diagram}

## Conventions
| Convention | Example |
|-----------|---------|

## Non-Obvious Things
- {gotcha 1}
- {gotcha 2}
```

## Rules

- Be BRIEF. The goal is quick orientation, not exhaustive documentation.
- Focus on the 20% of the codebase that matters for 80% of tasks
- Skip node_modules, build output, and generated files
- If the project has existing architecture docs, read those first
- Persist via the project's memory backend (native memory tool, or `.memory/architecture.md` as fallback)
- Not responsible for: environment/setup validation (see doctor skill), code review (see review skill)
