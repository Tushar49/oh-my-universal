# Skill: ultraqa

> Comprehensive QA testing with iterative fix cycles. Run everything, fix everything, repeat.
> Inspired by: oh-my-claudecode (ultraqa skill)

## When to Trigger

- User says "full QA", "test everything", "QA pass", "make all tests pass"
- After a large change or refactor that may have broken multiple things
- Before a release or merge when you need confidence that nothing is broken
- When verify reports failures and you want to systematically fix them all

## Workflow

### Step 1 — Discover Checks

Identify ALL available verification commands in the project:
- **Unit tests:** `npm test`, `pytest`, `go test ./...`, etc.
- **Integration tests:** if they exist and are runnable locally
- **Lint:** `eslint`, `ruff`, `golangci-lint`, etc.
- **Type check:** `tsc --noEmit`, `mypy`, `pyright`, etc.
- **Build:** `npm run build`, `go build`, `cargo build`, etc.
- **Format check:** `prettier --check`, `black --check`, `gofmt -l`, etc.

Record the full list. If unsure what's available, check `package.json`, `Makefile`, `pyproject.toml`, or equivalent.

### Step 2 — Run Full Suite

Run ALL checks. Capture output for each.

For each check, record:
- Command run
- Result: PASS / FAIL
- If FAIL: error count, error details

### Step 3 — Categorize Failures

For each failure, determine:

- **Test bug:** The test itself is wrong (outdated assertion, flaky setup)
- **Implementation bug:** The code under test is broken
- **Environment issue:** Missing dependency, wrong version, config problem
- **Pre-existing:** Failure existed before the current changes

### Step 4 — Fix Cycle

For each failure, starting with the easiest to fix:

1. Analyze the error
2. Make the fix (one logical change at a time)
3. Re-run the SPECIFIC failed check to verify the fix
4. Run a quick regression check (re-run previously passing tests near the changed code)
5. If fix introduces new failures → revert and try a different approach

### Step 5 — Re-run Full Suite

After fixing all identified issues, run the FULL suite again from Step 2.

- If all pass → **done**, go to Step 6
- If new failures → categorize and fix (back to Step 3)
- **Max 5 full cycles.** If still failing after 5 cycles, report remaining issues.

### Step 6 — Report

Produce the final QA report.

## Output Format

```markdown
## QA Report: {context / what was changed}

### Checks Discovered
| Check | Command | Available |
|-------|---------|-----------|
| Unit tests | `npm test` | YES |
| Lint | `npm run lint` | YES |
| Type check | `tsc --noEmit` | YES |
| Build | `npm run build` | YES |

### Cycle Summary
| Cycle | Failures Found | Fixed | New Regressions | Remaining |
|-------|---------------|-------|-----------------|-----------|
| 1 | 8 | 6 | 0 | 2 |
| 2 | 2 | 2 | 1 | 1 |
| 3 | 1 | 1 | 0 | 0 |

### Failures Fixed
| # | Check | Error | Category | Fix Applied |
|---|-------|-------|----------|-------------|
| 1 | test | `TypeError: x is not a function` | implementation bug | Fixed import in `src/utils.ts` |
| 2 | lint | `no-unused-vars` in `src/api.ts:12` | implementation bug | Removed dead variable |
| 3 | type | `Type 'string' not assignable to 'number'` | test bug | Updated test assertion type |

### Final Status
- **Result:** ALL PASS / PARTIAL (n remaining)
- **Cycles used:** {n} of 5
- **Total failures found:** {count}
- **Total fixed:** {count}
- **Regressions introduced and resolved:** {count}

### Remaining Issues (if PARTIAL)
| # | Check | Error | Category | Why Not Fixed |
|---|-------|-------|----------|--------------|
| 1 | {check} | {error} | {category} | {explanation} |
```

## Rules

- Run ALL checks, not just tests. Lint and type errors matter too.
- Fix one thing at a time. Verify after each fix. Don't batch fixes blindly.
- Track regressions explicitly. If fixing A breaks B, that's critical information.
- Categorize before fixing. Don't waste time fixing a flaky test that has nothing to do with your changes.
- Pre-existing failures should be noted but don't block the QA pass. Focus on NEW failures.
- If a fix requires significant refactoring, note it as a remaining issue rather than risking a cascade of regressions.
- Max 5 full cycles is a hard limit. If you're still failing after 5, the problem needs a different approach (use trace or plan).

## Not Responsible For

- One-shot verification without fix loops (use verify for that)
- Build-only fix cycles (use build-fix for that)
- Unlimited persistent fixing beyond QA scope (use ralph for that)
- Writing new tests (use tdd for that)
- Performance testing (use perf-audit)
- Security testing (use security-review)
