# Skill: deepinit

> Deep project initialization — scaffold a new project from scratch with best practices.
> Inspired by: oh-my-claudecode deepinit skill

## When to Trigger

- User says "init project", "scaffold", "create new project", "start from scratch"
- User describes a project idea and wants a working starting point
- A directory is empty or has only a README and needs full project structure

## Workflow

### Step 1 — Gather Requirements

Determine the project type and stack from user input or context:

- **Language/runtime:** Node.js, Python, Rust, Go, etc.
- **Framework:** React, Next.js, FastAPI, Express, etc.
- **Project type:** library, CLI tool, web app, API server, monorepo
- **Features:** database, auth, testing, CI/CD, Docker, etc.

If anything is unclear, ask once with a concise list of options.

### Step 2 — Generate Directory Structure

Create the project skeleton appropriate for the stack:

```
project/
├── src/               # or lib/, app/, pkg/
│   └── index.{ext}    # entry point
├── tests/             # or __tests__/, test/
│   └── index.test.{ext}
├── .gitignore
├── README.md
├── LICENSE
└── {config files}     # package.json, pyproject.toml, Cargo.toml, go.mod
```

Adapt structure to language conventions (e.g., `src/main.rs` for Rust, `cmd/` for Go CLI).

### Step 3 — Configure Tooling

Set up the standard toolchain for the chosen stack:

- **Package manager:** npm/pnpm/yarn, pip/poetry/uv, cargo, go modules
- **Linter:** ESLint, ruff/flake8, clippy, golangci-lint
- **Formatter:** Prettier, black/ruff, rustfmt, gofmt
- **Test runner:** Jest/Vitest, pytest, cargo test, go test
- **Type checking:** TypeScript, mypy/pyright, (built-in for Rust/Go)
- **Build tool:** esbuild/tsc, setuptools/hatch, cargo build, go build

Include reasonable defaults in config files (not empty configs).

### Step 4 — Set Up CI/CD

Generate CI config appropriate for the platform:

- GitHub Actions (`.github/workflows/ci.yml`) — default
- Include: lint, test, build steps
- Include: caching for dependencies
- Target: latest stable + LTS versions of the runtime

### Step 5 — Add Agent Config

Create agent instruction files so AI tools work well with the project:

- `CLAUDE.md` or `AGENTS.md` — project context for AI assistants
- `.github/copilot-instructions.md` — GitHub Copilot project instructions
- Include: build/test/lint commands, project structure overview, key conventions

### Step 6 — Initialize and Verify

1. Install dependencies (`npm install`, `pip install -e .`, etc.)
2. Run the linter — should pass with zero errors
3. Run the test suite — starter test should pass
4. Run the build — should produce output
5. Initialize git repo if not already initialized

## Output Format

```markdown
## Project Initialized: {name}

**Stack:** {language} + {framework} + {tools}
**Directory:** {path}

### Structure
```
{tree output}
```

### Tooling
| Tool | Choice | Config |
|------|--------|--------|
| Package manager | {name} | {config file} |
| Linter | {name} | {config file} |
| Formatter | {name} | {config file} |
| Test runner | {name} | {config file} |
| CI | GitHub Actions | .github/workflows/ci.yml |

### Verification
- [x] Dependencies installed
- [x] Linter passes
- [x] Tests pass (1/1)
- [x] Build succeeds
- [x] Git initialized with initial commit

### Next Steps
1. {first thing to build}
2. {suggested architecture decision}
3. {security consideration}
```

## Rules

- ALWAYS use the language community's standard conventions (don't invent new patterns).
- Include a working test from the start, even if it's just a smoke test.
- .gitignore must cover: dependencies, build output, env files, OS files, editor files.
- README must include: project description, setup instructions, how to run/test/build.
- LICENSE defaults to MIT unless user specifies otherwise.
- Don't over-scaffold — start minimal and let the user add complexity as needed.
- If the user has existing files, preserve them. Don't overwrite without asking.
- Generated code should actually run. Verify with the toolchain, don't assume.

## Not Responsible For

- Diagnosing issues in existing projects (use doctor)
- Adding features to an existing project (use plan or ultrawork)
- Setting up deployment infrastructure (use container-sandbox or pipeline)
- Framework-specific tutorials or teaching (use deep-dive for research)
