# Mission: Security Hardening

Audit and harden security across the codebase. Find vulnerabilities, fix them, and establish guardrails to prevent regressions.

## Goal

Bring the project to a baseline security posture where common vulnerability classes are addressed, dependencies are clean, and input boundaries are enforced.

## Focus Areas

- Input validation and sanitization on all user-facing entry points
- Authentication and authorization boundaries
- Dependency vulnerabilities (CVEs in direct and transitive deps)
- Secrets and credential exposure (hardcoded keys, leaked env vars)
- HTTP security headers and CORS configuration

## Success Criteria

1. `security-review` skill passes clean with no HIGH or CRITICAL findings
2. `npm audit` (or equivalent) reports zero high/critical CVEs
3. All user inputs are validated or sanitized before use
4. No hardcoded secrets, API keys, or credentials in source code
5. Auth boundaries enforce least-privilege on all protected routes

## Constraints

- Do not change the public API contract (routes, request/response shapes)
- Do not add new dependencies unless strictly required for a fix
- Do not disable or weaken existing security measures to make checks pass
- Focus on the application code — infrastructure (Docker, CI) is out of scope
