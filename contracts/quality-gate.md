# Contract: quality-gate

> Minimum quality bar for all implementations. Build, test, security, and documentation standards that must be met.

## Invariants

### 1. Build Must Pass

Before any implementation is considered complete:
- The project MUST build successfully with the existing build command
- No new compiler errors, type errors, or build warnings introduced
- If the project has no build step, this gate is skipped (not failed)

**Detecting the build command:**
- Check `package.json` scripts (`build`, `compile`, `tsc`)
- Check `Makefile`, `CMakeLists.txt`, `build.gradle`, `Cargo.toml`
- Check CI config (`.github/workflows/`, `.gitlab-ci.yml`) for build steps
- If no build command is found, log "no build step detected" and skip

### 2. Tests Must Pass

All existing tests MUST pass after changes:
- No regressions — tests that passed before MUST still pass
- New code SHOULD have tests (warn if missing, don't block)
- Test coverage should not decrease (warn if it does, don't block)

**Test command detection:** same strategy as build — check package.json, Makefile, CI config.

**What counts as "pass":**
- All test suites exit with code 0
- No test marked as `skip` that was previously passing (detected if test framework supports it)
- Flaky tests (pass sometimes, fail sometimes) are flagged but don't block

### 3. No New Security Vulnerabilities

Changes MUST NOT introduce known security issues:
- No hardcoded secrets, API keys, passwords, or tokens in committed code
- No new dependencies with known critical CVEs (check with `npm audit`, `pip audit`, etc.)
- No obvious injection vectors (SQL, XSS, command injection) in new code
- Auth/permissions changes require explicit review flag

**Scope:** only NEW code is checked. Pre-existing vulnerabilities are not this contract's responsibility (they should be tracked separately).

### 4. Documentation Updated

When changes affect public APIs or user-facing behavior:
- README must reflect new/changed functionality
- API documentation must be updated (if it exists)
- CHANGELOG must have an entry (if the project uses one)
- Inline code comments for non-obvious logic

**What counts as "public API change":**
- New exported function, class, or module
- Changed function signature (parameters, return type)
- Changed behavior of existing function
- New CLI command or flag
- New configuration option

**What does NOT require doc updates:**
- Internal refactoring with no behavior change
- Test-only changes
- Dev tooling changes

## Gate Policy

| Check | Result | Action |
|---|---|---|
| Build | PASS | Proceed |
| Build | FAIL | **BLOCK** — must fix before proceeding |
| Tests | PASS | Proceed |
| Tests | FAIL (regression) | **BLOCK** — must fix regressions |
| Tests | WARN (no tests for new code) | Warn, recommend adding tests, proceed |
| Security | PASS | Proceed |
| Security | FAIL (secrets in code) | **BLOCK** — must remove secrets |
| Security | WARN (new dep with CVE) | Warn with CVE details, recommend updating, proceed |
| Docs | PASS | Proceed |
| Docs | WARN (docs not updated) | Warn, recommend updating, proceed |

**BLOCK means:** the agent should strongly recommend fixing the issue before committing. The agent does NOT have veto power — the user makes the final decision.

## Violations

- Committing code that doesn't build
- Committing code that causes test regressions
- Committing hardcoded secrets
- Declaring a skill `finished` when quality gates have not been checked
- Skipping quality gates without logging the skip reason

## Enforcement

| Component | What it checks |
|---|---|
| `skills/pre-commit-check.md` | Runs build + test + security review before commit |
| `hooks/verify-deliverables.md` | Checks that tests were run and docs updated |
| `skills/verify.md` | Runs tests and reports results |
| `skills/security-review.md` | Scans for security issues in changed code |
| `skills/review.md` | Code review catches quality issues |

## Examples

**All gates pass:**
```
Quality Gate: feature-auth
   ✓ Build: npm run build — success (4.2s)
   ✓ Tests: npm test — 47 passed, 0 failed
   ✓ Security: no secrets, no new CVEs
   ✓ Docs: README updated with auth section
   
   PASS — ready to commit
```

**Regression detected:**
```
Quality Gate: refactor-utils
   ✓ Build: success
   ✗ Tests: 45 passed, 2 FAILED
     - src/utils.test.ts: "formatDate returns ISO string" — REGRESSION
     - src/utils.test.ts: "parseConfig handles empty input" — REGRESSION
   ✓ Security: clean
   ⚠ Docs: no doc changes needed
   
   BLOCKED — 2 test regressions must be fixed
```

**Warnings only:**
```
Quality Gate: add-caching
   ✓ Build: success
   ⚠ Tests: 30 passed, 0 failed (but no tests for new CacheManager class)
   ⚠ Security: new dep "redis@4.6.0" — no known CVEs but not audited
   ⚠ Docs: README does not mention caching configuration
   
   PASS with warnings — recommend adding tests and docs before shipping
```
