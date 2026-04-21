# Skill: pipeline

> Generic sequential stage runner — define and execute multi-stage pipelines with validation and rollback.
> Inspired by: oh-my-codex pipeline skill

## When to Trigger

- User says "run pipeline", "define pipeline", "execute stages"
- User defines stages: "stage 1: ..., stage 2: ..."
- User asks to run a built-in pipeline: "run CI pipeline", "deploy pipeline", "release pipeline"
- When a multi-step process needs structured execution with pass/fail gates

## Workflow

### Step 1 — Define the Pipeline

Accept a pipeline definition from the user, or select a built-in one. Each stage has:

- **name** — short identifier
- **action** — command or task to execute
- **validate** — condition that must be true for the stage to pass
- **rollback** (optional) — action to undo the stage if a later stage fails

Pipeline definition format:
```yaml
stages:
  - name: lint
    action: "run lint"
    validate: "zero errors"
  - name: test
    action: "run tests"
    validate: "all pass"
  - name: build
    action: "npm run build"
    validate: "exit code 0"
```

### Step 2 — Execute Stages

Run each stage sequentially:

1. Announce stage start: `▶ Stage N: {name}`
2. Execute the action
3. Check validation condition
4. If pass: mark stage as ✅ and proceed
5. If fail: mark stage as ❌ and enter failure handling

### Step 3 — Handle Failures

When a stage fails, present options:

- **retry** — run the same stage again (max 2 retries)
- **skip** — skip this stage and continue (user must confirm)
- **abort** — stop the pipeline, no rollback
- **rollback-all** — run rollback actions for all completed stages in reverse order

### Step 4 — Report Results

After pipeline completes (or aborts), show full summary.

### Built-in Pipelines

**CI Pipeline** (lint → test → build):
```yaml
stages:
  - name: lint
    action: "run project linter"
    validate: "zero errors (warnings OK)"
  - name: test
    action: "run test suite"
    validate: "all tests pass"
  - name: build
    action: "run build command"
    validate: "exit code 0, no errors"
```

**Deploy Pipeline** (build → stage → verify → promote):
```yaml
stages:
  - name: build
    action: "build production artifacts"
    validate: "build succeeds"
  - name: stage
    action: "deploy to staging"
    validate: "staging is accessible"
    rollback: "tear down staging deploy"
  - name: verify
    action: "run smoke tests against staging"
    validate: "all smoke tests pass"
    rollback: "tear down staging deploy"
  - name: promote
    action: "promote staging to production"
    validate: "production is healthy"
    rollback: "rollback production to previous version"
```

**Release Pipeline** (changelog → bump → tag → publish):
```yaml
stages:
  - name: changelog
    action: "generate changelog from commits"
    validate: "changelog file updated"
  - name: bump
    action: "bump version number"
    validate: "version file updated"
  - name: tag
    action: "create git tag"
    validate: "tag exists"
    rollback: "delete git tag"
  - name: publish
    action: "publish package"
    validate: "package available in registry"
```

## Output Format

```markdown
## Pipeline: {name}

| # | Stage | Status | Duration | Notes |
|---|-------|--------|----------|-------|
| 1 | lint | ✅ pass | 3.2s | 0 errors, 2 warnings |
| 2 | test | ✅ pass | 12.1s | 47/47 tests passed |
| 3 | build | ❌ fail | 8.4s | TypeScript error in src/api.ts:23 |

**Result:** ❌ FAILED at stage 3 (build)
**Action taken:** abort (user choice)
**Stages completed:** 2/3
```

On success:
```markdown
## Pipeline: {name}

| # | Stage | Status | Duration | Notes |
|---|-------|--------|----------|-------|
| 1 | lint | ✅ pass | 3.2s | clean |
| 2 | test | ✅ pass | 12.1s | 47/47 |
| 3 | build | ✅ pass | 5.6s | dist/ ready |

**Result:** ✅ ALL STAGES PASSED (21.0s total)
```

## Rules

- Stages MUST execute in order. No parallel execution unless user explicitly defines parallel groups.
- Each stage must have at least a name and action. Validate is strongly recommended but optional (defaults to "exit code 0").
- Never auto-skip a failed stage. Always present failure options to the user.
- Rollback runs in reverse order (last completed stage first).
- Max 2 retries per stage. After that, force abort or skip.
- Built-in pipelines should be adapted to the actual project (detect package manager, test runner, etc).
- Pipeline definitions can come from markdown, YAML, or natural language — parse flexibly.

## Not Responsible For

- Continuous integration server setup (use CI platform docs)
- Individual stage implementation (use the appropriate skill — tdd, build-fix, release, etc.)
- Deployment infrastructure (use container-sandbox or platform-specific tools)
- Fixed lifecycle management (use autopilot for 5-phase flow, ultrawork for lifecycle)
