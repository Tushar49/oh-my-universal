# Skill: dependency-upgrade

> Safe dependency upgrades with compatibility checks, testing, and rollback plans.
> Inspired by: claude-workflow-v2 (/dependency-upgrade command)

## When to Trigger

- User says "upgrade dependencies", "update packages", "bump versions"
- Security audit flags outdated dependencies
- Renovate/Dependabot PRs need review
- Major framework upgrade (React 18->19, Node 18->20, Python 3.11->3.12)

## Scope Difference from Other Skills

| Skill | Focus |
|-------|-------|
| `build-fix.md` | Fix broken builds after they fail |
| `release.md` | Version bump the project itself |
| `dependency-upgrade.md` | Upgrade third-party dependencies safely |

## Workflow

### Step 1 — Inventory Current State

1. List all dependencies and their current versions
2. Check for known vulnerabilities (`npm audit`, `pip-audit`, `cargo audit`)
3. Identify how far behind each dependency is (patch, minor, major)
4. Check lockfile health (any conflicts or resolution issues?)

### Step 2 — Classify Upgrades by Risk

| Category | Risk | Examples | Strategy |
|----------|------|----------|----------|
| Patch (x.y.Z) | Low | Bug fixes, security patches | Batch and apply |
| Minor (x.Y.0) | Medium | New features, deprecation warnings | Group by domain |
| Major (X.0.0) | High | Breaking changes, API removals | One at a time |

### Step 3 — Pre-Upgrade Safety Net

Before touching anything:
1. Ensure all tests pass on current versions
2. Capture current test output as baseline
3. Commit/stash any pending changes
4. Create a dedicated branch: `chore/deps-upgrade-YYYY-MM-DD`

### Step 4 — Apply Upgrades (Phased)

**Phase 1: Patch upgrades (batch)**
```bash
# Node: npm update (respects semver ranges)
# Python: pip install --upgrade <pkg> for each
# Rust: cargo update
```
Run tests. If green, commit.

**Phase 2: Minor upgrades (grouped by domain)**
Group related packages (e.g., all testing libs, all linting, all framework):
- Upgrade one group at a time
- Run tests after each group
- Check for deprecation warnings in output
- Commit each successful group separately

**Phase 3: Major upgrades (one at a time)**
For each major upgrade:
1. Read the changelog/migration guide
2. Check for breaking changes that affect our codebase
3. Apply the upgrade
4. Fix all compiler/linter errors
5. Fix all failing tests
6. Run the full test suite
7. Commit with detailed message listing breaking changes addressed

### Step 5 — Post-Upgrade Verification

- [ ] All tests pass
- [ ] No new deprecation warnings (or they are documented)
- [ ] Build succeeds
- [ ] Lockfile is clean (no resolution conflicts)
- [ ] Application starts and basic functionality works
- [ ] No new security vulnerabilities introduced

### Step 6 — Rollback Plan

If issues are found after merge:
1. `git revert <merge-commit>` — instant rollback
2. Re-lock dependencies: `npm ci` / `pip install -r requirements.txt`
3. Verify rollback restores previous behavior
4. Investigate the issue on a separate branch

## Anti-Patterns

- **Never upgrade everything at once** — if tests break, you can't tell which dep caused it
- **Never ignore deprecation warnings** — they become errors in the next major version
- **Never skip reading changelogs for major bumps** — breaking changes are documented there
- **Never upgrade peer dependencies independently** — they must stay compatible

## Rules

- Always ensure tests pass before starting upgrades (baseline)
- Upgrade in phases: patch → minor → major (ascending risk)
- One major upgrade at a time — never batch breaking changes
- Commit each successful upgrade group separately for easy rollback
- Read changelogs/migration guides before every major bump
- Document any deprecation warnings introduced by upgrades
- Lockfile must be clean after every upgrade phase

## Not Responsible For

- Fixing broken builds unrelated to dependency changes (see build-fix)
- Bumping the project's own version (see release)
- Security audit beyond dependency CVEs (see security-review)
- Implementing migration code for breaking API changes (see plan, ultrawork)
