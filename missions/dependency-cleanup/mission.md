# Mission: Dependency Cleanup

Audit and clean up project dependencies. Remove unused packages, update outdated ones, patch vulnerabilities, and eliminate duplicates.

## Goal

Achieve a clean, minimal dependency tree with no unused packages, no known critical vulnerabilities, and all direct dependencies on current stable versions.

## Focus Areas

- Unused dependencies (installed but never imported)
- Outdated dependencies (more than one major version behind)
- Security vulnerabilities (CVEs in direct and transitive deps)
- Duplicate packages (multiple versions of the same package in the lockfile)
- Dev vs production dependency classification (misplaced packages)

## Success Criteria

1. Zero unused dependencies detected by `depcheck` (or equivalent tool)
2. `npm audit` (or equivalent) reports zero high/critical vulnerabilities
3. Lockfile is clean and regenerated after changes
4. All tests pass after dependency changes — no regressions
5. Build succeeds and produces identical or smaller output

## Constraints

- Do not upgrade dependencies with known breaking changes without verifying compatibility
- Do not remove dependencies that appear unused but are loaded dynamically or via plugins
- Do not change the package manager (npm/yarn/pnpm) — use what the project already uses
- Do not add new dependencies as part of cleanup
- Test after every batch of changes — do not bulk-remove and hope for the best
