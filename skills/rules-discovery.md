# Skill: rules-discovery

> Auto-discover and apply project conventions and rules from config files.
> Inspired by: oh-my-claudecode templates/rules/, auto-discovered .claude/rules/

## When to Trigger

- User says "discover rules", "what conventions does this project use", "scan for rules"
- User says "show project config", "what linting rules are active"
- Automatically at `deepinit` (skills/deepinit.md) — conventions are part of project understanding
- At session start when `.rules/conventions.md` is stale or missing

## What It Scans

### Code Style & Formatting
| File | Extracts |
|------|----------|
| `.editorconfig` | Indent style/size, charset, line endings, trim trailing whitespace |
| `.prettierrc` / `.prettierrc.*` | Print width, quote style, semicolons, trailing commas |
| `biome.json` / `biome.jsonc` | Formatter and linter rules |
| `.eslintrc.*` / `eslint.config.*` | Linting rules, plugin configs, extends |
| `.stylelintrc.*` | CSS/SCSS linting conventions |
| `rustfmt.toml` | Rust formatting rules |
| `.clang-format` | C/C++ formatting rules |
| `.rubocop.yml` | Ruby style conventions |

### Language & Build Config
| File | Extracts |
|------|----------|
| `tsconfig.json` | Strict mode, target, module system, paths |
| `pyproject.toml` | Python version, tooling (ruff, black, mypy), project metadata |
| `Cargo.toml` | Rust edition, features, workspace config |
| `go.mod` | Go version, module path |
| `Makefile` / `Justfile` | Available targets, build/test/lint commands |
| `package.json` | Scripts (test, lint, build), engines, type (module/commonjs) |

### CI/CD & Quality
| File | Extracts |
|------|----------|
| `.github/workflows/*.yml` | CI steps, required checks, test commands |
| `.gitlab-ci.yml` | Pipeline stages, linting jobs |
| `.pre-commit-config.yaml` | Pre-commit hooks and their configs |
| `codecov.yml` | Coverage thresholds |
| `.nvmrc` / `.node-version` / `.python-version` | Runtime version constraints |

### Naming & Structure
- Directory structure patterns (src/, lib/, tests/, __tests__/)
- File naming conventions (kebab-case, camelCase, PascalCase)
- Test file naming patterns (*.test.ts, *.spec.js, test_*.py)
- Export patterns (barrel files, named vs default exports)

## Output: `.rules/conventions.md`

Generated summary injected into agent context:

```markdown
# Project Conventions

Auto-discovered on 2025-01-15. Re-run with "discover rules" to refresh.

## Code Style
- Indent: 2 spaces (from .editorconfig)
- Quotes: single (from .prettierrc)
- Semicolons: no (from .prettierrc)
- Line width: 100 chars (from .prettierrc)
- Trailing commas: all (from .prettierrc)

## Language
- TypeScript: strict mode, ES2022 target, ESM (from tsconfig.json)
- Node.js: >= 18.0.0 (from package.json engines)

## Testing
- Framework: vitest (from package.json scripts)
- Pattern: **/*.test.ts (from directory scan)
- Coverage threshold: 80% (from vitest.config.ts)

## Linting
- ESLint with @typescript-eslint (from eslint.config.js)
- Prettier for formatting (from .prettierrc)
- Pre-commit: lint-staged + husky (from package.json)

## Build & Run
- `npm test` — run tests
- `npm run lint` — lint code
- `npm run build` — build project
- `npm run dev` — development server

## Naming
- Files: kebab-case (observed)
- Components: PascalCase (observed)
- Tests: {name}.test.ts co-located with source
```

## Workflow

### Step 1 — Scan
Enumerate known config files in the project root and common subdirectories.
Read each file and extract relevant conventions.

### Step 2 — Analyze
Cross-reference findings to build a coherent picture:
- Resolve conflicts (e.g., .editorconfig vs .prettierrc indent settings)
- Identify the primary test framework and linting toolchain
- Detect naming patterns from file listings

### Step 3 — Generate
Write `.rules/conventions.md` with discovered conventions, grouped by category.
Include the source file for each convention so the user can verify.

### Step 4 — Inject
At session start, if `.rules/conventions.md` exists and is recent (< 7 days), load it into context.
If stale, re-scan automatically.

## Output Format

### Discovery Report
```
Rules Discovery — {project name}
==================================
Scanned 14 config files, found 23 conventions.

Code Style:    6 rules (from .editorconfig, .prettierrc)
Language:      4 rules (from tsconfig.json, package.json)
Testing:       3 rules (from vitest.config.ts, package.json)
Linting:       5 rules (from eslint.config.js, .prettierrc)
Build:         3 commands (from package.json, Makefile)
Naming:        2 patterns (from directory scan)

Written to .rules/conventions.md
```

## Integration Points

- **deepinit** — rules-discovery runs as part of deep project initialization
- **hooks** — discovered lint/test commands feed into pre-commit hook configuration
- **session-protocol** — conventions are loaded into context at session start
- **config-sync** — conventions file is tracked for cross-agent consistency

## Rules

- Never modify discovered config files — this skill is read-only discovery
- Always cite the source file for each convention found
- When configs conflict, note both and let the user resolve
- Rescan when user runs "discover rules" even if conventions.md exists
- Skip binary files and node_modules/vendor directories
- If no config files found, report "no conventions discovered" — do not invent defaults

## Not Responsible For

- Enforcing conventions (that's linting tools and hooks)
- Creating config files (that's project setup)
- Resolving conflicting conventions (flag them, don't decide)
- Runtime version management (that's the user's toolchain)
