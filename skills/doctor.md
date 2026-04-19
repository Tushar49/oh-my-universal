# Skill: doctor

> Validate project health and prerequisites. Quick diagnostic that
> catches setup issues before they cause failures.
> Inspired by: oh-my-codex (doctor), career-ops (doctor.mjs)

## When to Trigger

- First time in a new project
- User says "doctor", "health check", "is everything set up?"
- When something fails unexpectedly (diagnose first)
- After cloning or pulling major changes

## Checks to Run

### 1. Runtime Environment
- [ ] Node.js version (if package.json exists)
- [ ] Python version (if requirements.txt or setup.py exists)
- [ ] Go version (if go.mod exists)
- [ ] Rust toolchain (if Cargo.toml exists)

### 2. Dependencies
- [ ] Are dependencies installed? (node_modules, venv, etc.)
- [ ] Are there lockfile mismatches?
- [ ] Any known vulnerable dependencies?

### 3. Configuration
- [ ] Do required config files exist?
- [ ] Are environment variables set?
- [ ] Are there example configs that haven't been copied?

### 4. Build & Test
- [ ] Does the project build successfully?
- [ ] Do tests pass?
- [ ] Does the linter pass?

### 5. Agent Setup
- [ ] Does AGENTS.md or CLAUDE.md exist?
- [ ] Does .github/copilot-instructions.md exist?
- [ ] Are referenced files present? (cv.md, profile.yml, etc.)

### 6. Git Status
- [ ] Is the working tree clean?
- [ ] Are there uncommitted changes?
- [ ] What branch are we on?

## Modes

### Fast (default)
Environment, config, git status, file presence checks only.

### Full (--full flag)
Also runs build, tests, linter, dependency audit. Slower but thorough.

## Output Format

```
Project Doctor — {project name}
================================

✓ Node.js v22.17.0
✓ Dependencies installed
✓ Config files present
✗ Tests failing (2 failures)
  → Run: npm test to see details
✓ Agent instructions found
⚠ 3 uncommitted files

Result: 1 issue, 1 warning
```

## Rules

- Run checks SILENTLY - only show results, not the process
- Pass/fail for each check, with fix instructions for failures
- Don't try to auto-fix anything unless user says "doctor --fix"
- Keep it fast - skip slow checks (full test suite) unless asked
- Adapt checks to the project type (don't check npm in a Python project)
- Not responsible for: codebase understanding (see architecture skill), code review (see review skill)
