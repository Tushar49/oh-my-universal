# Skill: deliverables

> Stage-based deliverable verification for pipelines and missions.
> Inspired by: oh-my-claudecode templates/deliverables.json

## When to Trigger

- User says "check deliverables", "what's missing", "verify outputs"
- User says "deliverable status", "what did we produce", "stage report"
- Auto-run in autopilot phase 5 (verification/delivery)
- After each pipeline stage completes (via pipeline skill integration)
- When mission-runner evaluates success criteria

## Deliverable Types

| Type | Verification Method |
|------|-------------------|
| `file` | File exists at expected path |
| `test` | Test command exits 0 |
| `coverage` | Coverage meets threshold (from coverage report) |
| `doc` | Documentation file exists and is non-empty |
| `lint` | Linting passes with no errors |
| `build` | Build command exits 0 |
| `commit` | Changes are committed (clean working tree) |
| `custom` | Custom shell command returns expected output |

## Deliverable Definition

Deliverables can be defined inline or in a deliverables file:

### Inline (in mission.md or pipeline stage)
```markdown
## Deliverables
- [ ] `file:src/auth/middleware.ts` — Auth middleware implementation
- [ ] `test:npm test -- --grep "auth"` — Auth tests pass
- [ ] `coverage:80` — Coverage at or above 80%
- [ ] `doc:docs/auth.md` — Auth module documentation
- [ ] `lint:npm run lint` — No linting errors
```

### File-Based (`.deliverables.json`)
```json
{
  "stage": "implementation",
  "items": [
    { "type": "file", "path": "src/auth/middleware.ts", "label": "Auth middleware" },
    { "type": "test", "command": "npm test -- --grep auth", "label": "Auth tests pass" },
    { "type": "coverage", "threshold": 80, "label": "Coverage >= 80%" },
    { "type": "doc", "path": "docs/auth.md", "label": "Auth docs" },
    { "type": "lint", "command": "npm run lint", "label": "Clean lint" }
  ]
}
```

## Workflow

### Step 1 — Discover
Find deliverable definitions from:
1. Current mission's `mission.md` (success criteria section)
2. Pipeline stage definition (if running in a pipeline)
3. `.deliverables.json` in project root or mission directory
4. Explicit user request ("check these deliverables: ...")

### Step 2 — Check
For each deliverable, run the appropriate verification:
- **file** — `test -f {path}` and check non-empty
- **test** — run the command, check exit code
- **coverage** — parse coverage report, compare to threshold
- **doc** — check file exists, has content, has expected sections
- **lint** — run lint command, check for zero errors
- **build** — run build command, check exit code
- **commit** — `git status --porcelain` is empty
- **custom** — run command, check output matches expected

### Step 3 — Report
Produce a deliverable checklist with status for each item.

### Step 4 — Act
If missing deliverables are found:
- Suggest which skills can produce them (e.g., "run tdd to fix failing tests")
- In autopilot mode, attempt to produce missing deliverables automatically
- In manual mode, list missing items for the user to address

## Output Format

### Deliverable Report
```
Deliverables — security-hardening
===================================
✅ file    src/auth/middleware.ts       — Auth middleware
✅ test    npm test -- --grep auth      — Auth tests pass (12/12)
⚠️  coverage 73% (target: 80%)          — Coverage below threshold
✅ doc     docs/auth.md                 — Auth documentation
❌ lint    npm run lint                 — 3 errors remaining
✅ commit  clean working tree           — Changes committed

Score: 4/6 delivered (67%)
Missing: coverage (+7% needed), lint (3 errors)
```

### Stage Summary (for pipeline integration)
```
Stage 3: Implementation — 4/6 deliverables (67%)
  Missing: coverage, lint
  Suggestion: run build-fix to resolve lint errors, then tdd for coverage
```

## Integration Points

- **pipeline** — deliverables skill checks outputs after each pipeline stage
- **mission-runner** — maps mission success criteria to deliverable checks
- **verify** — deliverables skill delegates to verify for test/build/lint checks
- **autopilot** — auto-runs in phase 5 to confirm all outputs are present
- **hooks** — `verify-deliverables` hook triggers this skill post-stage

## Deliverable Stages

For multi-stage pipelines, deliverables can be scoped to stages:

| Stage | Typical Deliverables |
|-------|---------------------|
| Planning | Plan document, task breakdown |
| Implementation | Source files, passing tests |
| Testing | Coverage report, all tests green |
| Documentation | README updates, API docs |
| Review | Clean lint, no security issues |
| Delivery | Build artifact, committed changes |

## Rules

- Check deliverables non-destructively — never modify files during verification
- Report partial deliverables (e.g., file exists but is empty) as warnings, not failures
- When a deliverable check fails, include the error output for debugging
- Score is `delivered / total` — partial items count as 0
- In autopilot mode, attempt to fix missing deliverables up to 2 times before reporting failure
- Never mark a deliverable as delivered if the check did not actually pass

## Not Responsible For

- Producing the deliverables (that's implementation skills like tdd, build-fix, writer)
- Defining what deliverables are needed (that's mission.md or pipeline stages)
- Running the full test suite (delegate to verify skill)
- Fixing lint errors (delegate to build-fix skill)
