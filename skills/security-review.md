# Skill: security-review

> Repo-wide or feature-scoped security audit. Examines trust boundaries,
> auth flows, secrets exposure, and dependency vulnerabilities.
> Different from `review.md` which is diff-scoped correctness review.
> Inspired by: oh-my-codex ($security-review), claude-forge

## When to Trigger

- Agent should proactively suggest for: auth changes, API endpoints, user input handling
- User says "security review", "audit security", "check for vulnerabilities"
- Before deploying to production
- When adding new dependencies

## Scope Difference from `review.md`

| Dimension | review.md | security-review.md |
|-----------|-----------|-------------------|
| Scope | Current diff/changes | Entire feature or repo |
| Focus | Correctness, logic, bugs | Threats, trust boundaries, vulnerabilities |
| Trigger | After every change | Before deploy, after auth changes, periodic |
| Output | Per-line findings | Threat surface report |

## Workflow

### 1. Secrets & Credentials
- Hardcoded API keys, passwords, tokens in source code
- Secrets in config files that should be in environment variables
- .env files committed to git
- Credentials in logs or error messages

### 2. Authentication & Authorization
- Auth bypass paths (missing middleware, unchecked routes)
- Session management (expiry, rotation, invalidation)
- Permission escalation risks
- Default/weak credentials

### 3. Input Handling
- SQL injection (raw queries, string concatenation)
- XSS (unescaped user input in HTML/templates)
- Path traversal (user input in file paths)
- Command injection (user input in shell commands)
- Unsafe deserialization

### 4. Dependencies
- Known CVEs in dependencies (run `npm audit` / `pip-audit` etc.)
- Outdated dependencies with security patches available
- Typosquatting risks in package names
- Unnecessary dependencies with large attack surface

### 5. Configuration & Defaults
- Debug mode enabled in production configs
- CORS misconfiguration (wildcard origins)
- Missing rate limiting on sensitive endpoints
- Verbose error messages exposing internals
- Missing security headers (CSP, HSTS, X-Frame-Options)

### 6. Trust Boundaries
- Where does untrusted data enter the system?
- What transformations happen before it reaches sensitive operations?
- Are there adequate validation/sanitization boundaries?

## Output Format

```markdown
## Security Audit: {scope}

**Risk Level:** LOW / MEDIUM / HIGH / CRITICAL
**Scope:** {repo-wide / feature: auth / component: API}
**Date:** {YYYY-MM-DD}

### Critical Findings
{any finding that could lead to data breach or unauthorized access}

### High Findings
{vulnerabilities that should be fixed before deploy}

### Medium Findings
{issues that increase attack surface but aren't immediately exploitable}

### Dependency Report
| Package | Version | CVE | Severity | Fix available? |
|---------|---------|-----|----------|---------------|

### Recommendations
1. {prioritized action item}
2. {next action}

### Not Checked
- {areas outside scope or requiring manual testing}
```

## Rules

- Findings must be specific: show the vulnerable code, not just the category
- Don't report theoretical risks without evidence in the codebase
- Run actual audit tools where available (npm audit, pip-audit, etc.)

## Not Responsible For

- General code quality (see review skill)
- Build verification (see verify skill)
