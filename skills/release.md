# Skill: release

> Release management: changelog generation, version bump, git tag, and optional publish.
> Inspired by: oh-my-claudecode (release)

## When to Trigger

- User says "release", "cut a release", "bump version", "prepare release", "publish"
- After a set of features or fixes are merged and ready for release

## Workflow

### Step 1 — Analyze Commits

Find the latest git tag and collect all commits since then:
```bash
git describe --tags --abbrev=0   # latest tag
git log {latest-tag}..HEAD --oneline --no-decorate
```

If no tags exist, use all commits from the beginning.

Categorize each commit by conventional commit prefix:
- `feat:` / `feature:` — new feature (minor bump)
- `fix:` / `bugfix:` — bug fix (patch bump)
- `BREAKING CHANGE:` or `!:` — breaking change (major bump)
- `chore:` / `docs:` / `style:` / `refactor:` / `test:` / `ci:` — maintenance (no bump, but included in changelog)

If commits don't follow conventional format, do best-effort categorization by reading the message content.

### Step 2 — Generate Changelog Entry

Create or update `CHANGELOG.md` at the project root. Prepend the new release entry:

```markdown
## [{version}] — {YYYY-MM-DD}

### Breaking Changes
- {commit message} ({short SHA})

### Features
- {commit message} ({short SHA})

### Fixes
- {commit message} ({short SHA})

### Other
- {commit message} ({short SHA})
```

Omit empty sections. Link each version header to a git compare URL if the repo has a remote.

### Step 3 — Bump Version

Detect the project's version file (check in order):
1. `package.json` — update `"version": "{new}"`
2. `pyproject.toml` — update `version = "{new}"`
3. `Cargo.toml` — update `version = "{new}"`
4. `VERSION` or `version.txt` — replace contents
5. If none found, create `VERSION` file

Apply semver bump based on commit analysis:
- Any `BREAKING CHANGE` — **major** bump (1.x.x -> 2.0.0)
- Any `feat` (no breaking) — **minor** bump (1.1.x -> 1.2.0)
- Only `fix`/`chore`/other — **patch** bump (1.1.1 -> 1.1.2)

User can override with: "bump major", "bump minor", "bump to 2.0.0"

### Step 4 — Create Git Tag

```bash
git add CHANGELOG.md {version-file}
git commit -m "chore: release v{version}"
git tag -a v{version} -m "Release v{version}"
```

Ask user before pushing:
```bash
git push origin HEAD
git push origin v{version}
```

### Step 5 — Publish (Optional)

Only run if user explicitly requests. Detect and suggest the publish command:
- `package.json` exists — `npm publish`
- `Cargo.toml` exists — `cargo publish`
- `pyproject.toml` exists — `python -m build && twine upload dist/*`
- Custom publish command in `package.json` scripts — `npm run publish` or `npm run release`

Always confirm with user before executing a publish command.

## Output Format

```markdown
## Release: v{version}

**Previous version:** v{previous}
**Bump type:** major / minor / patch

### Changes Since v{previous}

#### Breaking Changes
- {message} ({SHA})

#### Features
- {message} ({SHA})

#### Fixes
- {message} ({SHA})

### Actions Taken
- [x] Commits analyzed: {count} commits since v{previous}
- [x] CHANGELOG.md updated
- [x] Version bumped: {old} -> {new} in {file}
- [x] Git tag created: v{version}
- [ ] Pushed to remote (awaiting confirmation)
- [ ] Published to {registry} (awaiting confirmation)
```

## Rules

- NEVER push tags or publish without explicit user confirmation
- Support dry-run mode: show what would happen without making changes ("dry run release", "preview release")
- If CHANGELOG.md already exists, prepend new entry — don't overwrite existing content
- Version detection must be language-agnostic: check all version file formats
- If conventional commits aren't used, still produce a changelog — just put everything under "Changes"
- Keep the changelog concise: one line per commit, no descriptions or bodies
- Tag format is always `v{version}` (e.g., `v1.2.3`)

## Not Responsible For

- Writing release notes for GitHub Releases (suggest the changelog content, but user creates the release)
- CI/CD pipeline configuration (see build-fix skill)
- Hotfix branching or release branch management
- Dependency updates or lockfile changes
